import SwiftUI
import Combine

// ── Modelo de datos (fiel al del web: chinola-datos-v3) ─────────────────────
// Una libreta es una contabilidad aparte con sus cuentas, tarjetas, préstamos,
// metas, categorías y movimientos. Todo Codable para guardarlo en el disco.

enum TipoMov: String, Codable, CaseIterable {
    case ingreso = "Ingreso"
    case gastoFijo = "Gasto Fijo"
    case gastoVariable = "Gasto Variable"
    case ahorro = "Ahorro"
    case transferencia = "Transferencia"

    var esGasto: Bool { self == .gastoFijo || self == .gastoVariable }
}

struct Cuenta: Codable, Identifiable, Hashable {
    var id: Int
    var nombre: String
    var banco: String = ""
    var saldo: Double = 0
    var color: String = "#137d41"
    var clase: String = "banco"        // banco · efectivo · ahorro…
    var icono: String = "banknote.fill"
}

struct Tarjeta: Codable, Identifiable, Hashable {
    var id: Int
    var nombre: String
    var banco: String = ""
    var limite: Double = 0
    var saldo: Double = 0               // deuda actual
    var corte: Int = 25
    var pago: Int = 5
    var color: String = "#d55948"
    var last4: String = "0000"
    var disponible: Double { max(0, limite - saldo) }
}

struct Prestamo: Codable, Identifiable, Hashable {
    var id: Int
    var nombre: String
    var entidad: String = ""
    var total: Double = 0
    var pagado: Double = 0
    var cuota: Double = 0
    var dia: Int = 1
    var color: String = "#825eb9"
    var sentido: String = "meDeben"     // meDeben · debo
    var pendiente: Double { max(0, total - pagado) }
}

struct Meta: Codable, Identifiable, Hashable {
    var id: Int
    var nombre: String
    var meta: Double = 0                // objetivo
    var ahorrado: Double = 0
    var mensual: Double = 0
    var color: String = "#825eb9"
    var icono: String = "target"
    var progreso: Double { meta > 0 ? min(1, ahorrado / meta) : 0 }
}

struct Categoria: Codable, Identifiable, Hashable {
    var id: Int
    var nombre: String
    var tipo: String = "Gasto"          // Gasto · Ingreso
    var limite: Double = 0
    var color: String = "#e0a92e"
    var icono: String = "tag.fill"
}

struct Movimiento: Codable, Identifiable, Hashable {
    var id: String
    var concepto: String
    var categoria: String = "Otros"
    var tipo: TipoMov = .gastoVariable
    var monto: Double = 0
    var fecha: String                    // ISO yyyy-MM-dd
    var recurrente: Bool = false
    var medio: String = ""               // "cuenta:<id>" | "tarjeta:<id>"
    var destino: String = ""             // solo transferencias
}

struct Libreta: Codable, Identifiable, Hashable {
    var id: String
    var nombre: String
    var tipo: String = "Personal"
    var icono: String = "book.closed.fill"
    var color: String = "#093a20"
    var cuentas: [Cuenta] = []
    var tarjetas: [Tarjeta] = []
    var prestamos: [Prestamo] = []
    var metas: [Meta] = []
    var categorias: [Categoria] = []
    var tx: [Movimiento] = []
}

// Contenedor persistido: libretas + cuál está activa.
struct Datos: Codable {
    var libretas: [Libreta] = []
    var activa: String = ""
}

// ── Estado de la app: la fuente de verdad, guardada en el disco ─────────────
final class AppEstado: ObservableObject {
    @Published var datos: Datos { didSet { guardar() } }

    private let url: URL = {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent("chinola-datos.json")
    }()

    init() {
        if let d = try? Data(contentsOf: url), let leido = try? JSONDecoder().decode(Datos.self, from: d) {
            datos = leido
        } else {
            datos = AppEstado.semilla()
        }
    }

    private func guardar() {
        if let d = try? JSONEncoder().encode(datos) { try? d.write(to: url) }
    }

    // Libreta activa (o la primera).
    var libreta: Libreta {
        get { datos.libretas.first(where: { $0.id == datos.activa }) ?? datos.libretas.first ?? Libreta(id: "vacia", nombre: "Personal") }
        set {
            if let i = datos.libretas.firstIndex(where: { $0.id == newValue.id }) { datos.libretas[i] = newValue }
        }
    }

    // ── Cálculos (mismos que el web) ────────────────────────────────────────
    private func mesActual() -> String { String(Movimiento.hoy().prefix(7)) }

    var ingresosMes: Double { sumaMes { $0.tipo == .ingreso } }
    var gastosMes: Double { sumaMes { $0.tipo.esGasto } }
    var balanceMes: Double { ingresosMes - gastosMes }

    private func sumaMes(_ filtro: (Movimiento) -> Bool) -> Double {
        let m = mesActual()
        return libreta.tx.filter { String($0.fecha.prefix(7)) == m && filtro($0) }
            .reduce(0) { $0 + abs($1.monto) }
    }

    var totalCuentas: Double { libreta.cuentas.reduce(0) { $0 + $1.saldo } }
    var deudaTarjetas: Double { libreta.tarjetas.reduce(0) { $0 + $1.saldo } }
    var deudaPrestamos: Double { libreta.prestamos.filter { $0.sentido == "debo" }.reduce(0) { $0 + $1.pendiente } }
    var porCobrar: Double { libreta.prestamos.filter { $0.sentido == "meDeben" }.reduce(0) { $0 + $1.pendiente } }
    var deudaTotal: Double { deudaTarjetas + deudaPrestamos }
    var patrimonio: Double { totalCuentas + porCobrar - deudaTotal }

    // Movimientos ordenados del más nuevo al más viejo.
    var movimientos: [Movimiento] { libreta.tx.sorted { $0.fecha > $1.fecha } }

    // Gastado este mes en una categoría.
    func gastadoCategoria(_ nombre: String) -> Double {
        let m = mesActual()
        return libreta.tx.filter { $0.categoria == nombre && $0.tipo.esGasto && String($0.fecha.prefix(7)) == m }
            .reduce(0) { $0 + abs($1.monto) }
    }
    var presupuestoTotal: Double { libreta.categorias.filter { $0.tipo == "Gasto" }.reduce(0) { $0 + $1.limite } }

    // Patrimonio mes a mes: parte del patrimonio de hoy y camina hacia atrás
    // restando el neto (ingresos − gastos) de cada mes. Devuelve del más viejo
    // al más nuevo.
    struct PuntoTendencia: Identifiable { let id = UUID(); let label: String; let valor: Double; let cambio: Double }
    func tendencia(_ n: Int = 12) -> [PuntoTendencia] {
        let cal = Calendar.current
        let ym = DateFormatter(); ym.dateFormat = "yyyy-MM"; ym.locale = Locale(identifier: "en_US_POSIX")
        let etiqueta = DateFormatter(); etiqueta.dateFormat = "MMM yy"; etiqueta.locale = Locale(identifier: "es")
        var res: [PuntoTendencia] = []
        var running = patrimonio
        for k in 0..<n {
            guard let d = cal.date(byAdding: .month, value: -k, to: Date()) else { continue }
            let mes = ym.string(from: d)
            let ing = libreta.tx.filter { $0.tipo == .ingreso && String($0.fecha.prefix(7)) == mes }.reduce(0.0) { $0 + abs($1.monto) }
            let gas = libreta.tx.filter { $0.tipo.esGasto && String($0.fecha.prefix(7)) == mes }.reduce(0.0) { $0 + abs($1.monto) }
            let neto = ing - gas
            res.append(PuntoTendencia(label: etiqueta.string(from: d).capitalized, valor: running, cambio: neto))
            running -= neto
        }
        return res.reversed()
    }

    func nombreMedio(_ medio: String) -> String {
        if let idc = Int(medio.replacingOccurrences(of: "cuenta:", with: "")), medio.hasPrefix("cuenta:"),
           let c = libreta.cuentas.first(where: { $0.id == idc }) { return c.nombre }
        if let idt = Int(medio.replacingOccurrences(of: "tarjeta:", with: "")), medio.hasPrefix("tarjeta:"),
           let t = libreta.tarjetas.first(where: { $0.id == idt }) { return t.nombre }
        return "Efectivo"
    }

    // ── Mutaciones ───────────────────────────────────────────────────────────
    // Registrar un movimiento y mover el saldo de su cuenta/tarjeta (como `aplica`).
    func agregar(_ mov: Movimiento) {
        var lb = libreta
        lb.tx.append(mov)
        aplicar(&lb, mov, signo: 1)
        libreta = lb
    }

    func borrar(_ mov: Movimiento) {
        var lb = libreta
        aplicar(&lb, mov, signo: -1)
        lb.tx.removeAll { $0.id == mov.id }
        libreta = lb
    }

    // Mueve el saldo de la cuenta/tarjeta según el tipo del movimiento.
    private func aplicar(_ lb: inout Libreta, _ m: Movimiento, signo: Double) {
        let monto = abs(m.monto) * signo
        func tocaCuenta(_ medio: String, _ delta: Double) {
            if medio.hasPrefix("cuenta:"), let id = Int(medio.dropFirst(7)),
               let i = lb.cuentas.firstIndex(where: { $0.id == id }) { lb.cuentas[i].saldo += delta }
            if medio.hasPrefix("tarjeta:"), let id = Int(medio.dropFirst(8)),
               let i = lb.tarjetas.firstIndex(where: { $0.id == id }) { lb.tarjetas[i].saldo += -delta }
        }
        switch m.tipo {
        case .ingreso: tocaCuenta(m.medio, monto)
        case .gastoFijo, .gastoVariable: tocaCuenta(m.medio, -monto)
        case .ahorro: tocaCuenta(m.medio, -monto)
        case .transferencia:
            tocaCuenta(m.medio, -monto)
            tocaCuenta(m.destino, monto)
        }
    }

    // Movimientos de una cuenta/tarjeta (para el extracto del detalle).
    func movimientosDe(_ medio: String) -> [Movimiento] {
        libreta.tx.filter { $0.medio == medio || $0.destino == medio }.sorted { $0.fecha > $1.fecha }
    }

    // Abonar a un préstamo: sube lo pagado y mueve la cuenta (entra si te deben,
    // sale si tú debes).
    func abonar(_ prestamoId: Int, monto: Double, medio: String) {
        var lb = libreta
        guard let pi = lb.prestamos.firstIndex(where: { $0.id == prestamoId }), monto > 0 else { return }
        lb.prestamos[pi].pagado = min(lb.prestamos[pi].total, lb.prestamos[pi].pagado + monto)
        let entra = lb.prestamos[pi].sentido == "meDeben"
        moverCuenta(&lb, medio, entra ? monto : -monto)
        libreta = lb
    }

    // Aportar a una meta: sube lo ahorrado y saca de la cuenta.
    func aportar(_ metaId: Int, monto: Double, medio: String) {
        var lb = libreta
        guard let mi = lb.metas.firstIndex(where: { $0.id == metaId }), monto > 0 else { return }
        lb.metas[mi].ahorrado += monto
        moverCuenta(&lb, medio, -monto)
        libreta = lb
    }

    // Pagar una tarjeta: baja la deuda y saca de la cuenta.
    func pagarTarjeta(_ tarjetaId: Int, monto: Double, medio: String) {
        var lb = libreta
        guard let ti = lb.tarjetas.firstIndex(where: { $0.id == tarjetaId }), monto > 0 else { return }
        lb.tarjetas[ti].saldo = max(0, lb.tarjetas[ti].saldo - monto)
        moverCuenta(&lb, medio, -monto)
        libreta = lb
    }

    private func moverCuenta(_ lb: inout Libreta, _ medio: String, _ delta: Double) {
        if medio.hasPrefix("cuenta:"), let id = Int(medio.dropFirst(7)),
           let i = lb.cuentas.firstIndex(where: { $0.id == id }) { lb.cuentas[i].saldo += delta }
    }

    // Cambiar de libreta activa · crear una libreta nueva.
    func cambiarLibreta(_ id: String) { datos.activa = id }
    func crearLibreta(_ nombre: String, tipo: String) {
        let n = nombre.trimmingCharacters(in: .whitespaces)
        guard !n.isEmpty else { return }
        let id = "lb\(Int(Date().timeIntervalSince1970))"
        datos.libretas.append(Libreta(id: id, nombre: n, tipo: tipo))
        datos.activa = id
    }

    // ── Semilla de ejemplo (primera vez) ────────────────────────────────────
    static func semilla() -> Datos {
        let cuentas = [
            Cuenta(id: 1, nombre: "Efectivo", banco: "", saldo: 24500, color: "#137d41", clase: "efectivo", icono: "banknote.fill"),
            Cuenta(id: 2, nombre: "Banco Popular", banco: "Popular", saldo: 59700, color: "#398ad6", clase: "banco", icono: "building.columns.fill")
        ]
        let categorias = [
            Categoria(id: 1, nombre: "Comida", tipo: "Gasto", color: "#e0a92e", icono: "cart.fill"),
            Categoria(id: 2, nombre: "Servicios", tipo: "Gasto", color: "#398ad6", icono: "bolt.fill"),
            Categoria(id: 3, nombre: "Salario", tipo: "Ingreso", color: "#137d41", icono: "banknote.fill")
        ]
        let hoy = Movimiento.hoy()
        let tx = [
            Movimiento(id: "s1", concepto: "Salario", categoria: "Salario", tipo: .ingreso, monto: 38000, fecha: hoy, medio: "cuenta:2"),
            Movimiento(id: "s2", concepto: "Supermercado", categoria: "Comida", tipo: .gastoVariable, monto: 2300, fecha: hoy, medio: "cuenta:1"),
            Movimiento(id: "s3", concepto: "Luz", categoria: "Servicios", tipo: .gastoFijo, monto: 1900, fecha: hoy, medio: "cuenta:1")
        ]
        let lb = Libreta(id: "personal", nombre: "Personal", tipo: "Personal",
                         cuentas: cuentas,
                         tarjetas: [Tarjeta(id: 1, nombre: "Visa Popular", banco: "Popular", limite: 50000, saldo: 12400, corte: 25, pago: 5, color: "#d55948", last4: "4821")],
                         prestamos: [Prestamo(id: 1, nombre: "Juan", entidad: "", total: 5000, pagado: 2000, dia: 30, color: "#825eb9", sentido: "meDeben")],
                         metas: [Meta(id: 1, nombre: "Viaje a Punta Cana", meta: 50000, ahorrado: 30000, color: "#825eb9", icono: "airplane")],
                         categorias: categorias, tx: tx)
        return Datos(libretas: [lb], activa: "personal")
    }
}

// Utilidades de fecha e importe.
extension Movimiento {
    static func hoy() -> String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; f.locale = Locale(identifier: "en_US_POSIX")
        return f.string(from: Date())
    }
}

// Formato de dinero (DOP, sin centavos, con separador de miles).
func fmtDinero(_ n: Double, moneda: String = "DOP") -> String {
    let f = NumberFormatter(); f.numberStyle = .decimal; f.maximumFractionDigits = 0; f.groupingSeparator = ","
    let s = f.string(from: NSNumber(value: abs(n).rounded())) ?? "0"
    return "\(moneda) \(s)"
}

// Color desde "#rrggbb".
extension Color {
    init(hexString s: String) {
        var h = s.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        if h.count == 3 { h = h.map { "\($0)\($0)" }.joined() }
        let v = UInt64(h, radix: 16) ?? 0
        self.init(.sRGB, red: Double((v >> 16) & 0xff) / 255, green: Double((v >> 8) & 0xff) / 255, blue: Double(v & 0xff) / 255)
    }
}
