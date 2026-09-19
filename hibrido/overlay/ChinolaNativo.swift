import SwiftUI
import UIKit

// Pantallas NATIVAS incrustadas en la app Capacitor. La web le pasa el JSON de
// la libreta (el de localStorage) y aquí se decodifica y se dibuja en SwiftUI.
// Todo autocontenido para no chocar con el resto del proyecto (prefijos CN…).

// ── Colores del tema Chinola (mismos valores del diseño) ────────────────────
func cnColor(_ hex: UInt) -> Color {
    Color(.sRGB, red: Double((hex >> 16) & 0xff) / 255, green: Double((hex >> 8) & 0xff) / 255, blue: Double(hex & 0xff) / 255, opacity: 1)
}
func cnColor(hexString s: String) -> Color {
    let t = s.trimmingCharacters(in: .whitespaces)
    // El diseño guarda los colores en oklch(...) (CSS). Se convierten a sRGB para
    // que las cuentas/categorías/metas se vean IGUAL que en la web y no en negro.
    if t.hasPrefix("oklch") { return cnOklch(t) }
    var h = t.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
    if h.count == 3 { h = h.map { "\($0)\($0)" }.joined() }
    let v = UInt64(h, radix: 16) ?? 0
    return Color(.sRGB, red: Double((v >> 16) & 0xff) / 255, green: Double((v >> 8) & 0xff) / 255, blue: Double(v & 0xff) / 255, opacity: 1)
}
// oklch(L C H) o oklch(L C H / a) → sRGB (fórmula de Björn Ottosson).
func cnOklch(_ s: String) -> Color {
    let dentro = s.drop(while: { $0 != "(" }).dropFirst().prefix(while: { $0 != ")" })
    let n = dentro.split(whereSeparator: { " /,".contains($0) }).compactMap { Double($0) }
    guard n.count >= 3 else { return CNC.ink }
    let L = n[0], C = n[1], hr = n[2] * .pi / 180
    let a = C * cos(hr), b = C * sin(hr)
    let l_ = L + 0.3963377774 * a + 0.2158037573 * b
    let m_ = L - 0.1055613458 * a - 0.0638541728 * b
    let s_ = L - 0.0894841775 * a - 1.2914855480 * b
    let l = l_ * l_ * l_, m = m_ * m_ * m_, q = s_ * s_ * s_
    let r =  4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * q
    let g = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * q
    let bl = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * q
    func gam(_ c: Double) -> Double { let x = max(0, c); return x <= 0.0031308 ? 12.92 * x : 1.055 * pow(x, 1 / 2.4) - 0.055 }
    func cl(_ c: Double) -> Double { min(1, max(0, c)) }
    return Color(.sRGB, red: cl(gam(r)), green: cl(gam(g)), blue: cl(gam(bl)), opacity: 1)
}
enum CNC {
    static let scr  = cnColor(0xfaf7ec)
    static let card = cnColor(0xffffff)
    static let soft = cnColor(0xf9f5e6)
    static let line = cnColor(0xe5e1d3)
    static let ink  = cnColor(0x132419)
    static let pmut = cnColor(0x516356)
    static let acc  = cnColor(0xefcb4c)
    static let pos  = cnColor(0x137d41)
    static let neg  = cnColor(0xd55948)
    static let info = cnColor(0x398ad6)
}

// ── Modelos (tolerantes: campos faltantes toman un valor por defecto) ───────
struct CNCuenta: Decodable, Identifiable { var id: Int = 0; var nombre: String = ""; var banco: String = ""; var saldo: Double = 0; var color: String = "#137d41"; var clase: String = "banco"; var icono: String = "banknote.fill"
    init(from d: Decoder) throws { let c = try d.container(keyedBy: K.self)
        id = (try? c.decodeIfPresent(Int.self, forKey: .id)) ?? 0
        nombre = (try? c.decodeIfPresent(String.self, forKey: .nombre)) ?? ""
        banco = (try? c.decodeIfPresent(String.self, forKey: .banco)) ?? ""
        saldo = (try? c.decodeIfPresent(Double.self, forKey: .saldo)) ?? 0
        color = (try? c.decodeIfPresent(String.self, forKey: .color)) ?? "#137d41"
        clase = (try? c.decodeIfPresent(String.self, forKey: .clase)) ?? "banco"
        icono = (try? c.decodeIfPresent(String.self, forKey: .icono)) ?? "banknote.fill" }
    enum K: String, CodingKey { case id, nombre, banco, saldo, color, clase, icono } }

struct CNCategoria: Decodable { var nombre: String = ""; var tipo: String = "Gasto"; var limite: Double = 0; var color: String = "#e0a92e"; var icono: String = "tag.fill"
    init(from d: Decoder) throws { let c = try d.container(keyedBy: K.self)
        nombre = (try? c.decodeIfPresent(String.self, forKey: .nombre)) ?? ""
        tipo = (try? c.decodeIfPresent(String.self, forKey: .tipo)) ?? "Gasto"
        limite = (try? c.decodeIfPresent(Double.self, forKey: .limite)) ?? 0
        color = (try? c.decodeIfPresent(String.self, forKey: .color)) ?? "#e0a92e"
        icono = (try? c.decodeIfPresent(String.self, forKey: .icono)) ?? "tag.fill" }
    enum K: String, CodingKey { case nombre, tipo, limite, color, icono } }

struct CNTarjeta: Decodable, Identifiable { var id: Int = 0; var nombre: String = ""; var saldo: Double = 0; var limite: Double = 0; var corte: Int = 0; var color: String = "#d55948"
    init(from d: Decoder) throws { let c = try d.container(keyedBy: K.self)
        id = (try? c.decodeIfPresent(Int.self, forKey: .id)) ?? 0
        nombre = (try? c.decodeIfPresent(String.self, forKey: .nombre)) ?? ""
        saldo = (try? c.decodeIfPresent(Double.self, forKey: .saldo)) ?? 0
        limite = (try? c.decodeIfPresent(Double.self, forKey: .limite)) ?? 0
        corte = (try? c.decodeIfPresent(Int.self, forKey: .corte)) ?? 0
        color = (try? c.decodeIfPresent(String.self, forKey: .color)) ?? "#d55948" }
    enum K: String, CodingKey { case id, nombre, saldo, limite, corte, color }
    var disponible: Double { max(0, limite - saldo) } }

struct CNPrestamo: Decodable, Identifiable { var id: Int = 0; var nombre: String = ""; var total: Double = 0; var pagado: Double = 0; var sentido: String = "meDeben"; var color: String = "#825eb9"
    init(from d: Decoder) throws { let c = try d.container(keyedBy: K.self)
        id = (try? c.decodeIfPresent(Int.self, forKey: .id)) ?? 0
        nombre = (try? c.decodeIfPresent(String.self, forKey: .nombre)) ?? ""
        total = (try? c.decodeIfPresent(Double.self, forKey: .total)) ?? 0
        pagado = (try? c.decodeIfPresent(Double.self, forKey: .pagado)) ?? 0
        sentido = (try? c.decodeIfPresent(String.self, forKey: .sentido)) ?? "meDeben"
        color = (try? c.decodeIfPresent(String.self, forKey: .color)) ?? "#825eb9" }
    enum K: String, CodingKey { case id, nombre, total, pagado, sentido, color }
    var pendiente: Double { max(0, total - pagado) } }

struct CNMeta: Decodable, Identifiable { var id: Int = 0; var nombre: String = ""; var meta: Double = 0; var ahorrado: Double = 0; var color: String = "#825eb9"; var icono: String = "target"
    init(from d: Decoder) throws { let c = try d.container(keyedBy: K.self)
        id = (try? c.decodeIfPresent(Int.self, forKey: .id)) ?? 0
        nombre = (try? c.decodeIfPresent(String.self, forKey: .nombre)) ?? ""
        meta = (try? c.decodeIfPresent(Double.self, forKey: .meta)) ?? 0
        ahorrado = (try? c.decodeIfPresent(Double.self, forKey: .ahorrado)) ?? 0
        color = (try? c.decodeIfPresent(String.self, forKey: .color)) ?? "#825eb9"
        icono = (try? c.decodeIfPresent(String.self, forKey: .icono)) ?? "target" }
    enum K: String, CodingKey { case id, nombre, meta, ahorrado, color, icono }
    var progreso: Double { meta > 0 ? min(1, ahorrado / meta) : 0 } }

struct CNMov: Decodable, Identifiable {
    var id: String = ""; var concepto: String = ""; var categoria: String = ""
    var tipo: String = ""; var monto: Double = 0; var fecha: String = ""; var medio: String = ""; var destino: String = ""; var recurrente: Bool = false
    init(from d: Decoder) throws { let c = try d.container(keyedBy: K.self)
        // id puede venir como número o texto.
        if let s = try? c.decodeIfPresent(String.self, forKey: .id) { id = s }
        else if let n = try? c.decodeIfPresent(Int.self, forKey: .id) { id = String(n) }
        concepto = (try? c.decodeIfPresent(String.self, forKey: .concepto)) ?? ""
        categoria = (try? c.decodeIfPresent(String.self, forKey: .categoria)) ?? ""
        tipo = (try? c.decodeIfPresent(String.self, forKey: .tipo)) ?? ""
        monto = (try? c.decodeIfPresent(Double.self, forKey: .monto)) ?? 0
        fecha = (try? c.decodeIfPresent(String.self, forKey: .fecha)) ?? ""
        medio = (try? c.decodeIfPresent(String.self, forKey: .medio)) ?? ""
        destino = (try? c.decodeIfPresent(String.self, forKey: .destino)) ?? ""
        recurrente = (try? c.decodeIfPresent(Bool.self, forKey: .recurrente)) ?? false }
    enum K: String, CodingKey { case id, concepto, categoria, tipo, monto, fecha, medio, destino, recurrente }
    var esIngreso: Bool { tipo == "Ingreso" }
    var esGasto: Bool { tipo.hasPrefix("Gasto") }
    var esTransfer: Bool { tipo == "Transferencia" } }

struct CNLibreta: Decodable {
    var nombre: String = "Personal"
    var cuentas: [CNCuenta] = []
    var tarjetas: [CNTarjeta] = []
    var prestamos: [CNPrestamo] = []
    var categorias: [CNCategoria] = []
    var metas: [CNMeta] = []
    var tx: [CNMov] = []
    init() {}
    init(from d: Decoder) throws { let c = try d.container(keyedBy: K.self)
        nombre = (try? c.decodeIfPresent(String.self, forKey: .nombre)) ?? "Personal"
        cuentas = (try? c.decodeIfPresent([CNCuenta].self, forKey: .cuentas)) ?? []
        tarjetas = (try? c.decodeIfPresent([CNTarjeta].self, forKey: .tarjetas)) ?? []
        prestamos = (try? c.decodeIfPresent([CNPrestamo].self, forKey: .prestamos)) ?? []
        categorias = (try? c.decodeIfPresent([CNCategoria].self, forKey: .categorias)) ?? []
        metas = (try? c.decodeIfPresent([CNMeta].self, forKey: .metas)) ?? []
        tx = (try? c.decodeIfPresent([CNMov].self, forKey: .tx)) ?? [] }
    enum K: String, CodingKey { case nombre, cuentas, tarjetas, prestamos, categorias, metas, tx }

    func categoria(_ nombre: String) -> CNCategoria? { categorias.first { $0.nombre == nombre } }
    func gastadoCategoria(_ nombre: String) -> Double {
        let mes = String(cnHoy().prefix(7))
        return tx.filter { $0.categoria == nombre && $0.esGasto && $0.fecha.hasPrefix(mes) }.reduce(0) { $0 + abs($1.monto) }
    }
    var presupuestoTotal: Double { categorias.filter { $0.tipo == "Gasto" }.reduce(0) { $0 + $1.limite } }
    var deudaTarjetas: Double { tarjetas.reduce(0) { $0 + $1.saldo } }
    private var mesActual: String { String(cnHoy().prefix(7)) }
    var ingresosMes: Double { tx.filter { $0.esIngreso && $0.fecha.hasPrefix(mesActual) }.reduce(0) { $0 + abs($1.monto) } }
    var gastosMes: Double { tx.filter { $0.esGasto && $0.fecha.hasPrefix(mesActual) }.reduce(0) { $0 + abs($1.monto) } }
    var balanceMes: Double { ingresosMes - gastosMes }
    func movimientosDe(_ medio: String) -> [CNMov] { tx.filter { $0.medio == medio || $0.destino == medio }.sorted { $0.fecha > $1.fecha } }
    func nombreMedio(_ medio: String) -> String {
        if medio.hasPrefix("cuenta:"), let id = Int(medio.dropFirst(7)), let c = cuentas.first(where: { $0.id == id }) { return c.nombre }
        if medio.hasPrefix("tarjeta:"), let id = Int(medio.dropFirst(8)), let t = tarjetas.first(where: { $0.id == id }) { return t.nombre }
        return "Efectivo"
    }

    static func desde(json: String) -> CNLibreta? {
        guard let data = json.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(CNLibreta.self, from: data)
    }

    var totalCuentas: Double { cuentas.reduce(0) { $0 + $1.saldo } }
    var porCobrar: Double { prestamos.filter { $0.sentido == "meDeben" }.reduce(0) { $0 + $1.pendiente } }
    var deudaTotal: Double { tarjetas.reduce(0) { $0 + $1.saldo } + prestamos.filter { $0.sentido == "debo" }.reduce(0) { $0 + $1.pendiente } }
    var patrimonio: Double { totalCuentas + porCobrar - deudaTotal }

    // Patrimonio mes a mes (viejo → nuevo), caminando hacia atrás por el neto.
    struct Punto: Identifiable { let id = UUID(); let label: String; let valor: Double; let cambio: Double }
    func tendencia(_ n: Int = 12) -> [Punto] {
        let cal = Calendar.current
        let ym = DateFormatter(); ym.dateFormat = "yyyy-MM"; ym.locale = Locale(identifier: "en_US_POSIX")
        let et = DateFormatter(); et.dateFormat = "MMM yy"; et.locale = Locale(identifier: "es")
        var res: [Punto] = []; var running = patrimonio
        for k in 0..<n {
            guard let d = cal.date(byAdding: .month, value: -k, to: Date()) else { continue }
            let mes = ym.string(from: d)
            let ing = tx.filter { $0.esIngreso && $0.fecha.hasPrefix(mes) }.reduce(0.0) { $0 + abs($1.monto) }
            let gas = tx.filter { $0.esGasto && $0.fecha.hasPrefix(mes) }.reduce(0.0) { $0 + abs($1.monto) }
            let neto = ing - gas
            res.append(Punto(label: et.string(from: d).capitalized, valor: running, cambio: neto))
            running -= neto
        }
        return res.reversed()
    }
}

func cnHoy() -> String {
    let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; f.locale = Locale(identifier: "en_US_POSIX")
    return f.string(from: Date())
}
func cnDinero(_ n: Double) -> String {
    let f = NumberFormatter(); f.numberStyle = .decimal; f.maximumFractionDigits = 0; f.groupingSeparator = ","
    return "RD$" + (f.string(from: NSNumber(value: abs(n).rounded())) ?? "0")
}

// Fecha "d MMM" desde ISO.
func cnFechaCorta(_ iso: String) -> String {
    let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; f.locale = Locale(identifier: "en_US_POSIX")
    guard let d = f.date(from: iso) else { return iso }
    let o = DateFormatter(); o.locale = Locale(identifier: "es"); o.dateFormat = "d MMM"
    return o.string(from: d)
}
/// "7 SEPTIEMBRE" — el formato que usa la app en las cabeceras de día.
func cnDiaCorto(_ iso: String) -> String {
    let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; f.locale = Locale(identifier: "en_US_POSIX")
    guard let d = f.date(from: iso) else { return iso }
    let o = DateFormatter(); o.locale = Locale(identifier: "es"); o.dateFormat = "d MMMM"
    return o.string(from: d).uppercased()
}

func cnDiaLargo(_ iso: String) -> String {
    let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; f.locale = Locale(identifier: "en_US_POSIX")
    guard let d = f.date(from: iso) else { return iso }
    let o = DateFormatter(); o.locale = Locale(identifier: "es"); o.dateFormat = "EEEE d 'de' MMMM"
    return o.string(from: d).capitalized
}

// Estado compartido: la libreta que la web empuja + las acciones que rebotan a
// la web (abrir "nuevo movimiento", abrir el detalle).
struct CNPerfilInfo: Decodable {
    var nombre: String = "Tú"; var email: String = ""; var plan: String = "Gratis"; var libretas: Int = 1; var local: Bool = true
    init() {}
    init(from d: Decoder) throws { let c = try d.container(keyedBy: K.self)
        nombre = (try? c.decodeIfPresent(String.self, forKey: .nombre)) ?? "Tú"
        email = (try? c.decodeIfPresent(String.self, forKey: .email)) ?? ""
        plan = (try? c.decodeIfPresent(String.self, forKey: .plan)) ?? "Gratis"
        libretas = (try? c.decodeIfPresent(Int.self, forKey: .libretas)) ?? 1
        local = (try? c.decodeIfPresent(Bool.self, forKey: .local)) ?? true }
    enum K: String, CodingKey { case nombre, email, plan, libretas, local }
    static func desde(json: String) -> CNPerfilInfo? {
        guard let d = json.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(CNPerfilInfo.self, from: d)
    }
}

final class CNDatos: ObservableObject {
    // Store COMPARTIDO: Capacitor puede atender la llamada JS con una instancia
    // del plugin distinta a la nuestra; si cada quien usa su propio CNDatos, los
    // datos que empuja la web nunca llegan a la pantalla (salía "No hay
    // movimientos"). Con un singleton, plugin y vista usan el MISMO store.
    static let shared = CNDatos()
    @Published var libreta = CNLibreta()
    @Published var perfil = CNPerfilInfo()
    var onNuevoMov: () -> Void = {}
    var onDetalleMov: (String) -> Void = { _ in }
    var onPerfil: (String) -> Void = { _ in }
    var onTendencia: () -> Void = {}
    var onAgregar: () -> Void = {}
    var onNuevaCategoria: () -> Void = {}
    var onNuevaMeta: () -> Void = {}
    var onAbrirCuenta: (Int) -> Void = { _ in }
    var onAbrirTarjeta: (Int) -> Void = { _ in }
    var onAbrirPrestamo: (Int) -> Void = { _ in }
    var onAbrirMeta: (Int) -> Void = { _ in }
    var onAccion: (String, String) -> Void = { _, _ in }   // (tipo, id) → flujo web
    var onCrearMov: ([String: Any]) -> Void = { _ in }     // guardar un movimiento nativo → web
    var onEditarMov: ([String: Any]) -> Void = { _ in }    // editar un movimiento (incluye id) → web
    var onBorrarMov: (String) -> Void = { _ in }           // borrar un movimiento por id → web
    // Guardar una "hoja" nativa (cuenta/tarjeta/préstamo/meta/abono/aporte/pago)
    // reusando toda la lógica de la web: (tipo, form, extra?) → enviarHoja.
    var onGuardarHoja: (String, [String: Any], [String: Any]?) -> Void = { _, _, _ in }
    var onSelector: () -> Void = {}
    var onVerPresupuesto: () -> Void = {}
    func cargar(json: String) { if let l = CNLibreta.desde(json: json) { libreta = l } }
    func cargarPerfil(json: String) { if let p = CNPerfilInfo.desde(json: json) { perfil = p } }
}

// ── Pantalla «Movimientos» NATIVA ──────────────────────────────────────────
// Título arriba (se va con el scroll), búsqueda sticky en liquid glass real
// (material) y la lista agrupada por día. Los datos vienen del web.
/// Botón redondo de 44pt (el tamaño táctil por defecto de iOS) con Liquid Glass.
struct CNBotonVidrio: View {
    let icono: String
    var acento: Bool = false
    var accion: () -> Void
    var body: some View {
        Button(action: accion) {
            Image(systemName: icono)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(acento ? Color(cnHex: 0x20180a) : .primary)
                .frame(width: 44, height: 44)
                .cnVidrio(Circle(), tinte: acento ? CNC.acc : nil)
        }
        .buttonStyle(.plain)
    }
}

struct CNMovs: View {
    @ObservedObject var datos: CNDatos
    @State private var q = ""

    private var movimientos: [CNMov] {
        let t = datos.libreta.tx.sorted { $0.fecha > $1.fecha }
        guard !q.isEmpty else { return t }
        let n = q.lowercased()
        return t.filter { $0.concepto.lowercased().contains(n) || $0.categoria.lowercased().contains(n) }
    }
    private var porDia: [(String, [CNMov])] {
        var orden: [String] = []; var mapa: [String: [CNMov]] = [:]
        for m in movimientos { if mapa[m.fecha] == nil { orden.append(m.fecha) }; mapa[m.fecha, default: []].append(m) }
        return orden.map { ($0, mapa[$0] ?? []) }
    }
    private func medioNombre(_ medio: String) -> String {
        if medio.hasPrefix("cuenta:"), let id = Int(medio.dropFirst(7)),
           let c = datos.libreta.cuentas.first(where: { $0.id == id }) { return c.nombre }
        if medio.hasPrefix("tarjeta:"), let id = Int(medio.dropFirst(8)),
           let t = datos.libreta.tarjetas.first(where: { $0.id == id }) { return t.nombre }
        return "Efectivo"
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 12, pinnedViews: [.sectionHeaders]) {
                // Título + calendario + «+» (se van con el scroll).
                HStack(alignment: .center, spacing: 10) {
                    Text("Movimientos").font(.system(size: 28, weight: .heavy)).foregroundColor(CNC.ink)
                    Spacer(minLength: 8)
                    circulo("calendar", acento: false) {}
                    circulo("plus", acento: true) { datos.onNuevoMov() }
                }
                .padding(.horizontal, 16).padding(.top, 0)

                Section(header: busqueda) {
                    if porDia.isEmpty {
                        vacio.padding(.horizontal, 14)
                    } else {
                        ForEach(porDia.indices, id: \.self) { i in
                            grupoDia(porDia[i].0, porDia[i].1).padding(.horizontal, 14)
                        }
                    }
                    Color.clear.frame(height: 110)
                }
            }
        }
        .background(CNC.scr.ignoresSafeArea())
    }

    private var busqueda: some View {
        HStack(spacing: 9) {
            HStack(spacing: 9) {
                Image(systemName: "magnifyingglass").font(.system(size: 15, weight: .semibold)).foregroundColor(CNC.pmut)
                TextField("Buscar movimiento…", text: $q).font(.system(size: 15)).foregroundColor(CNC.ink)
            }
            .padding(.horizontal, 14).frame(height: 44)
            .cnVidrio(Capsule())
            Image(systemName: "line.3.horizontal.decrease").font(.system(size: 17, weight: .semibold)).foregroundColor(CNC.ink)
                .frame(width: 46, height: 46)
                .cnVidrio(Circle())
        }
        .padding(.horizontal, 14).padding(.top, 2).padding(.bottom, 8)
        .background(.ultraThinMaterial)   // el contenido pasa por detrás al hacer scroll
    }

    private func grupoDia(_ fecha: String, _ items: [CNMov]) -> some View {
        let total = items.reduce(0.0) { $0 + ($1.esIngreso ? abs($1.monto) : ($1.esTransfer ? 0 : -abs($1.monto))) }
        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(cnDiaLargo(fecha).uppercased()).font(.system(size: 11, weight: .heavy)).tracking(0.4).foregroundColor(CNC.pmut)
                Spacer()
                Text((total >= 0 ? "+" : "−") + cnDinero(total)).font(.system(size: 11.5, weight: .heavy)).foregroundColor(CNC.pmut)
            }.padding(.horizontal, 6)
            VStack(spacing: 0) {
                ForEach(items.indices, id: \.self) { i in
                    fila(items[i])
                    if i < items.count - 1 { Rectangle().fill(CNC.line).frame(height: 0.5).padding(.leading, 58) }
                }
            }
            .background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(CNC.line, lineWidth: 0.5))
        }
    }

    private func fila(_ m: CNMov) -> some View {
        let entra = m.esIngreso
        let color: Color = entra ? CNC.pos : (m.esTransfer ? CNC.ink : CNC.neg)
        let cat = datos.libreta.categoria(m.categoria)
        let tinte = entra ? CNC.pos : (m.esTransfer ? CNC.info : (cat != nil ? cnColor(hexString: cat!.color) : cnColor(0xe0a92e)))
        let icono = entra ? "banknote.fill" : (m.esTransfer ? "arrow.left.arrow.right" : (cat?.icono ?? "tag.fill"))
        return Button { datos.onDetalleMov(m.id) } label: {
            HStack(spacing: 12) {
                cnGlifo(icono, tam: 17).foregroundColor(.white)
                    .frame(width: 34, height: 34).background(tinte).clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                VStack(alignment: .leading, spacing: 2) {
                    Text(m.concepto.isEmpty ? m.categoria : m.concepto).font(.system(size: 15, weight: .semibold)).foregroundColor(CNC.ink)
                        .lineLimit(1)
                    Text("\(m.categoria) · \(medioNombre(m.medio))").font(.system(size: 11.5)).foregroundColor(CNC.pmut).lineLimit(1)
                }
                Spacer(minLength: 6)
                Text((entra ? "+ " : (m.esTransfer ? "" : "− ")) + cnDinero(m.monto)).font(.system(size: 15, weight: .heavy)).foregroundColor(color)
            }
            .padding(.horizontal, 14).padding(.vertical, 11)
        }
        .buttonStyle(.plain)
    }

    private var vacio: some View {
        VStack(spacing: 6) {
            Text("No hay movimientos").font(.system(size: 15, weight: .bold)).foregroundColor(CNC.ink)
            Text("Aquí saldrá lo que anotes este mes.").font(.system(size: 13.5)).foregroundColor(CNC.pmut)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 26)
        .background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(CNC.line, lineWidth: 1))
    }

    @ViewBuilder private func circulo(_ icono: String, acento: Bool, _ tap: @escaping () -> Void) -> some View {
        Button(action: tap) {
            if acento {
                // El «+» en Liquid Glass tintado del color de la marca.
                Image(systemName: icono).font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(cnHex: 0x20180a))
                    .frame(width: 46, height: 46)
                    .cnVidrio(Circle(), tinte: CNC.acc)
                    .shadow(color: CNC.acc.opacity(0.35), radius: 10, y: 4)
            } else {
                Image(systemName: icono).font(.system(size: 18, weight: .semibold)).foregroundColor(CNC.ink)
                    .frame(width: 44, height: 44)
                    .cnVidrio(Circle())
            }
        }.buttonStyle(.plain)
    }
}

// Helper de color por si acaso (mismo que cnColor).
extension Color { init(cnHex: UInt) { self = cnColor(cnHex) } }

// ── Barra de menú NATIVA (liquid glass) ─────────────────────────────────────
// Vive encima del webview y cambia de pestaña llamando a la web. El material
// translúcido deja pasar el contenido por detrás, como el menú de iOS 26.
final class CNMenuEstado: ObservableObject {
    static let shared = CNMenuEstado()
    @Published var activa: String = "resumen"
    @Published var titulos: Bool = true
    var alTocar: (String) -> Void = { _ in }
}

/// Las 5 pestañas, en un solo sitio (las usa la barra nativa UITabBar).
enum CNTabs {
    struct T { let id: String; let titulo: String; let path: String }
    static let todas: [T] = [
        .init(id: "resumen", titulo: "Resumen", path: CNTabIcono.resumen),
        .init(id: "movs", titulo: "Movs.", path: CNTabIcono.movs),
        .init(id: "cuentas", titulo: "Cuentas", path: CNTabIcono.cuentas),
        .init(id: "plan", titulo: "Plan", path: CNTabIcono.plan),
        .init(id: "perfil", titulo: "Perfil", path: CNTabIcono.perfil)
    ]
}

struct CNBarraMenu: View {
    @ObservedObject var estado: CNMenuEstado
    /// false = el vidrio lo pone UIKit (UIGlassEffect) por fuera.
    var conFondo: Bool = true
    struct Item { let id: String; let label: String; let path: String }
    let items: [Item] = [
        .init(id: "resumen", label: "Resumen", path: CNTabIcono.resumen),
        .init(id: "movs", label: "Movs.", path: CNTabIcono.movs),
        .init(id: "cuentas", label: "Cuentas", path: CNTabIcono.cuentas),
        .init(id: "plan", label: "Plan", path: CNTabIcono.plan),
        .init(id: "perfil", label: "Perfil", path: CNTabIcono.perfil)
    ]
    var body: some View {
        HStack(spacing: 4) {
            ForEach(items, id: \.id) { it in
                let sel = estado.activa == it.id
                Button { estado.alTocar(it.id) } label: {
                    VStack(spacing: 3) {
                        CNIconoTab(d: it.path).frame(height: 25)
                        if estado.titulos {
                            Text(it.label).font(.system(size: 10.5, weight: .semibold))
                        }
                    }
                    .foregroundColor(sel ? CNC.pos : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 7)
                    // LA LENTE: cápsula de vidrio sobre la opción activa.
                    .background(lente(sel))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 6)
        .padding(.top, estado.titulos ? 7 : 11)
        .padding(.bottom, 7)
        .modifier(CNVidrio(activo: conFondo))
        .padding(.horizontal, conFondo ? 16 : 0)
        .padding(.bottom, conFondo ? 2 : 0)
    }

    @ViewBuilder private func lente(_ sel: Bool) -> some View {
        if sel {
            if #available(iOS 26.0, *) {
                Capsule().fill(.clear).glassEffect(.regular.interactive(), in: Capsule())
            } else {
                Capsule().fill(Color.white.opacity(0.18))
                    .overlay(Capsule().stroke(Color.white.opacity(0.38), lineWidth: 1))
            }
        }
    }
}

/// El vidrio de la barra. En iOS 26 usa **Liquid Glass de verdad**
/// (`.glassEffect`): transparente, con refracción en los bordes y brillo, como la
/// barra de Apple Music. En iOS anteriores no existe esa API, así que cae al
/// material esmerilado (lo mejor disponible ahí).
struct CNVidrio: ViewModifier {
    var activo: Bool = true
    func body(content: Content) -> some View {
        if !activo {
            content
        } else if #available(iOS 26.0, *) {
            content
                .glassEffect(.regular.interactive(), in: Capsule())
                .shadow(color: .black.opacity(0.18), radius: 26, y: 10)
        } else {
            content
                .background(
                    Capsule().fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.16), radius: 24, y: 8)
                )
                .overlay(Capsule().stroke(Color.white.opacity(0.6), lineWidth: 1))
        }
    }
}

/// Liquid Glass en CUALQUIER forma (círculos de «+», cerrar, búsqueda, botones
/// de las hojas…). iOS 26 → vidrio real; antes → material esmerilado.
struct CNVidrioForma<S: Shape>: ViewModifier {
    let forma: S
    var tinte: Color? = nil
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            if let t = tinte {
                content.glassEffect(.regular.tint(t).interactive(), in: forma)
            } else {
                content.glassEffect(.regular.interactive(), in: forma)
            }
        } else {
            content
                .background(forma.fill(.ultraThinMaterial))
                .background(tinte.map { forma.fill($0.opacity(0.55)) })
                .overlay(forma.stroke(Color.white.opacity(0.5), lineWidth: 0.8))
        }
    }
}

extension View {
    /// Vidrio (Liquid Glass en iOS 26) con la forma dada.
    func cnVidrio<S: Shape>(_ forma: S, tinte: Color? = nil) -> some View {
        modifier(CNVidrioForma(forma: forma, tinte: tinte))
    }
}

// ── Pantalla Tendencia (SwiftUI, misma que la nativa) ──────────────────────
struct CNTendencia: View {
    let libreta: CNLibreta
    var onClose: () -> Void = {}

    var body: some View {
        let puntos = libreta.tendencia()
        return VStack(spacing: 0) {
            ZStack {
                Text("Tendencia").font(.system(size: 17, weight: .bold)).foregroundColor(CNC.ink)
                HStack {
                    Button(action: onClose) {
                        Image(systemName: "xmark").font(.system(size: 17, weight: .semibold)).foregroundColor(CNC.pmut)
                            .frame(width: 44, height: 44).cnVidrio(Circle())
                            .shadow(color: .black.opacity(0.10), radius: 6, y: 2)
                    }
                    Spacer()
                }
            }
            .padding(.horizontal, 12).padding(.top, 14).padding(.bottom, 4)

            HStack(spacing: 16) {
                Image(systemName: "chevron.left").font(.system(size: 13, weight: .bold)).foregroundColor(CNC.pmut)
                Text("Últimos 12 meses").font(.system(size: 15, weight: .semibold)).foregroundColor(CNC.ink)
                Image(systemName: "chevron.right").font(.system(size: 13, weight: .bold)).foregroundColor(CNC.pmut)
            }.padding(.vertical, 8)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Patrimonio").font(.system(size: 14, weight: .semibold)).foregroundColor(CNC.info)
                            Spacer()
                            Text(cnDinero(libreta.patrimonio)).font(.system(size: 14, weight: .heavy)).foregroundColor(CNC.pos)
                        }
                        CNArea(valores: puntos.map { $0.valor }).frame(height: 130)
                    }
                    .padding(16).background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(CNC.line, lineWidth: 1))

                    VStack(spacing: 0) {
                        let filas = Array(puntos.reversed())
                        ForEach(filas.indices, id: \.self) { i in
                            HStack {
                                Text(filas[i].label).font(.system(size: 15, weight: .semibold)).foregroundColor(CNC.ink)
                                Spacer()
                                VStack(alignment: .trailing, spacing: 1) {
                                    Text(cnDinero(filas[i].valor)).font(.system(size: 15, weight: .heavy)).foregroundColor(CNC.ink)
                                    Text((filas[i].cambio >= 0 ? "+ " : "− ") + cnDinero(filas[i].cambio))
                                        .font(.system(size: 11.5, weight: .bold)).foregroundColor(filas[i].cambio >= 0 ? CNC.pos : CNC.neg)
                                }
                            }
                            .padding(.vertical, 12)
                            if i < filas.count - 1 { Divider().overlay(CNC.line) }
                        }
                    }
                    .padding(.horizontal, 16).background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(CNC.line, lineWidth: 1))

                    Color.clear.frame(height: 24)
                }
                .padding(.horizontal, 12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(CNC.scr.ignoresSafeArea())
    }
}

struct CNArea: View {
    var valores: [Double] = []
    var body: some View {
        GeometryReader { g in
            let w = g.size.width, h = g.size.height
            let vals = valores.isEmpty ? [0, 0] : valores
            let maxV = max(vals.max() ?? 1, 1), minV = min(vals.min() ?? 0, 0)
            let rango = max(maxV - minV, 1)
            let pts: [CGPoint] = vals.enumerated().map { i, v in
                CGPoint(x: vals.count > 1 ? w * CGFloat(i) / CGFloat(vals.count - 1) : 0,
                        y: h - (h - 8) * CGFloat((v - minV) / rango) - 4)
            }
            ZStack {
                VStack(spacing: 0) { ForEach(0..<4, id: \.self) { _ in Rectangle().fill(CNC.line).frame(height: 1); Spacer() } }
                Path { p in guard let f = pts.first else { return }
                    p.move(to: CGPoint(x: f.x, y: h)); p.addLine(to: f)
                    for q in pts.dropFirst() { p.addLine(to: q) }
                    p.addLine(to: CGPoint(x: pts.last!.x, y: h)); p.closeSubpath() }
                .fill(LinearGradient(colors: [CNC.acc.opacity(0.30), CNC.acc.opacity(0.02)], startPoint: .top, endPoint: .bottom))
                Path { p in guard let f = pts.first else { return }
                    p.move(to: f); for q in pts.dropFirst() { p.addLine(to: q) } }
                .stroke(CNC.acc, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            }
        }
    }
}

// ── Iconos SVG originales del menú (mismos paths que ICONOS_TAB del web) ────
// SwiftUI no entiende SVG; este intérprete mínimo dibuja los paths (M/L/H/V y
// arcos A) para usar los iconos EXACTOS de la app, no aproximaciones SF.
struct CNSVGShape: Shape {
    let d: String
    var viewBox: CGFloat = 24
    func path(in rect: CGRect) -> Path {
        let s = min(rect.width, rect.height) / viewBox
        let ox = rect.minX + (rect.width - viewBox * s) / 2
        let oy = rect.minY + (rect.height - viewBox * s) / 2
        var p = Path(); var cur = CGPoint.zero; var start = CGPoint.zero
        let pt = { (x: CGFloat, y: CGFloat) in CGPoint(x: ox + x * s, y: oy + y * s) }
        let toks = tokenize(d); var i = 0
        func num() -> CGFloat { let v = toks[i].num; i += 1; return v }
        while i < toks.count {
            let t = toks[i]; guard t.isCmd else { i += 1; continue }
            let c = t.cmd; i += 1
            switch c {
            case "M", "m":
                var x = num(); var y = num(); if c == "m" { x += cur.x; y += cur.y }
                cur = CGPoint(x: x, y: y); start = cur; p.move(to: pt(cur.x, cur.y))
                while i < toks.count, !toks[i].isCmd {
                    var lx = num(); var ly = num(); if c == "m" { lx += cur.x; ly += cur.y }
                    cur = CGPoint(x: lx, y: ly); p.addLine(to: pt(cur.x, cur.y)) }
            case "L", "l":
                while i < toks.count, !toks[i].isCmd {
                    var x = num(); var y = num(); if c == "l" { x += cur.x; y += cur.y }
                    cur = CGPoint(x: x, y: y); p.addLine(to: pt(cur.x, cur.y)) }
            case "H", "h":
                while i < toks.count, !toks[i].isCmd { var x = num(); if c == "h" { x += cur.x }; cur.x = x; p.addLine(to: pt(cur.x, cur.y)) }
            case "V", "v":
                while i < toks.count, !toks[i].isCmd { var y = num(); if c == "v" { y += cur.y }; cur.y = y; p.addLine(to: pt(cur.x, cur.y)) }
            case "A", "a":
                while i < toks.count, !toks[i].isCmd {
                    let rx = num(); _ = num(); _ = num(); let large = num() != 0; let sweep = num() != 0
                    var x = num(); var y = num(); if c == "a" { x += cur.x; y += cur.y }
                    arco(&p, from: cur, to: CGPoint(x: x, y: y), r: rx, large: large, sweep: sweep, pt: pt)
                    cur = CGPoint(x: x, y: y) }
            case "Z", "z": p.addLine(to: pt(start.x, start.y)); cur = start
            default: break
            }
        }
        return p
    }
    private func arco(_ p: inout Path, from a: CGPoint, to b: CGPoint, r: CGFloat, large: Bool, sweep: Bool, pt: (CGFloat, CGFloat) -> CGPoint) {
        let d = hypot(b.x - a.x, b.y - a.y); if d < 0.0001 { return }
        let rr = max(r, d / 2); let mx = (a.x + b.x) / 2, my = (a.y + b.y) / 2
        let ux = -(b.y - a.y) / d, uy = (b.x - a.x) / d
        let h = (rr * rr - d * d / 4).squareRoot(); let sign: CGFloat = (large == sweep) ? -1 : 1
        let cx = mx + sign * ux * h, cy = my + sign * uy * h
        let a1 = atan2(a.y - cy, a.x - cx); var a2 = atan2(b.y - cy, b.x - cx)
        if sweep { if a2 < a1 { a2 += 2 * .pi } } else { if a2 > a1 { a2 -= 2 * .pi } }
        let steps = max(2, Int(abs(a2 - a1) / (.pi / 24)))
        for k in 1...steps { let ang = a1 + (a2 - a1) * CGFloat(k) / CGFloat(steps); p.addLine(to: pt(cx + rr * cos(ang), cy + rr * sin(ang))) }
    }
    private struct Tok { var isCmd = false; var cmd: Character = " "; var num: CGFloat = 0 }
    private func tokenize(_ s: String) -> [Tok] {
        var out: [Tok] = []; var numBuf = ""
        func flush() { if !numBuf.isEmpty { out.append(Tok(isCmd: false, cmd: " ", num: CGFloat(Double(numBuf) ?? 0))); numBuf = "" } }
        for ch in s {
            if ch.isLetter { flush(); out.append(Tok(isCmd: true, cmd: ch, num: 0)) }
            else if ch == "-" { if !numBuf.isEmpty && (numBuf.last == "e" || numBuf.last == "E") { numBuf.append(ch) } else { flush(); numBuf.append(ch) } }
            else if ch == "." { if numBuf.contains(".") { flush() }; numBuf.append(ch) }
            else if ch.isNumber || ch == "e" || ch == "E" { numBuf.append(ch) }
            else { flush() }
        }
        flush(); return out
    }
}

enum CNTabIcono {
    static let resumen =
        "M5 3h3a2 2 0 0 1 2 2v3a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2z"
      + "M16 3h3a2 2 0 0 1 2 2v1a2 2 0 0 1-2 2h-3a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2z"
      + "M16 12h3a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-3a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2z"
      + "M5 14h3a2 2 0 0 1 2 2v3a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-3a2 2 0 0 1 2-2z"
    static let movs = "M7 4.5v15M7 19.5l-3-3M7 19.5l3-3M17 19.5v-15M17 4.5l-3 3M17 4.5l3 3"
    static let cuentas = "M7.5 5.5h9a4 4 0 0 1 4 4v5a4 4 0 0 1-4 4h-9a4 4 0 0 1-4-4v-5a4 4 0 0 1 4-4zM3.5 10h17M7 14.5h3.5"
    static let plan = "M12 3a9 9 0 1 0 0 18 9 9 0 0 0 0-18M12 3.4v7.6a1 1 0 0 0 1 1h7.6"
    static let perfil = "M12 11a4 4 0 1 0 0-8 4 4 0 0 0 0 8M4 21a8 8 0 0 1 16 0"
}

/// Convierte un icono SVG de la app en UIImage (plantilla) para usarlo en un
/// UITabBar nativo — igual que hace Batuta con sus PNG.
func cnIconoUIImage(_ d: String, lado: CGFloat = 26, grosor: CGFloat = 2) -> UIImage {
    let r = UIGraphicsImageRenderer(size: CGSize(width: lado, height: lado))
    let img = r.image { ctx in
        let p = CNSVGShape(d: d).path(in: CGRect(x: 0, y: 0, width: lado, height: lado))
        let c = ctx.cgContext
        c.addPath(p.cgPath)
        c.setLineWidth(grosor)
        c.setLineCap(.round)
        c.setLineJoin(.round)
        c.setStrokeColor(UIColor.label.cgColor)
        c.strokePath()
    }
    return img.withRenderingMode(.alwaysTemplate)
}

struct CNIconoTab: View {
    let d: String
    var body: some View {
        CNSVGShape(d: d).stroke(style: StrokeStyle(lineWidth: 2.3, lineCap: .round, lineJoin: .round)).frame(width: 24, height: 24)
    }
}

// ── Catálogo de iconos (mismos paths que ICONOS del web) ────────────────────
// Para que cuentas, categorías y metas usen EXACTAMENTE los mismos glifos que la
// web, no aproximaciones de SF Symbols.
enum CNIconos {
    static let paths: [String: String] = [
        "billete": "M2 6h20v12H2zM12 9.4a2.6 2.6 0 1 0 0 5.2 2.6 2.6 0 0 0 0-5.2M5.5 9.5h0M18.5 14.5h0",
        "casa": "M3 11l9-7 9 7v9a1 1 0 0 1-1 1h-5v-6H9v6H4a1 1 0 0 1-1-1z",
        "carrito": "M3 4h2l2 11h12M7 8h14l-2 7H8M8 19a1 1 0 1 0 2 0 1 1 0 1 0-2 0M16 19a1 1 0 1 0 2 0 1 1 0 1 0-2 0",
        "comida": "M6 3v8a3 3 0 0 0 6 0V3M9 11v10M17 3c-2 2-2 6 0 8v10",
        "cafe": "M4 8h13v5a4 4 0 0 1-4 4H8a4 4 0 0 1-4-4zM17 9h2a2 2 0 0 1 0 4h-2M4 21h13",
        "rayo": "M13 2 4 14h6l-1 8 9-12h-6z",
        "wifi": "M4 8a14 14 0 0 1 16 0M7 12a9 9 0 0 1 10 0M10 16a4 4 0 0 1 4 0M12 20h.01",
        "auto": "M4 16v-4l2-5h12l2 5v4M4 16h16M7 19a1 1 0 1 0 2 0M15 19a1 1 0 1 0 2 0",
        "gasolina": "M5 21V5a2 2 0 0 1 2-2h5v18M5 12h7M14 8h3a2 2 0 0 1 2 2v7a2 2 0 0 0 2 2",
        "birrete": "M2 9l10-4 10 4-10 4zM6 11v5c0 2 3 3 6 3s6-1 6-3v-5",
        "libro": "M4 5h7v14H4zM13 5h7v14h-7z",
        "salud": "M12 7v10M7 12h10M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18",
        "iglesia": "M12 3v6M9 6h6M6 21V11l6-4 6 4v10z",
        "regalo": "M3 9h18v3H3zM4 12v9h16v-9M12 9v12M8 9a2 2 0 1 1 4-2 2 2 0 1 1 4 2",
        "cine": "M3 6h18v10H3zM8 20h8M8 6v10M16 6v10",
        "musica": "M9 18V6l10-2v12M9 18a3 3 0 1 1-3-3 3 3 0 0 1 3 3M19 16a2 2 0 1 1-2-2 2 2 0 0 1 2 2",
        "tarjeta": "M2 6h20v12H2zM2 10h20M6 15h4",
        "usuario": "M12 11a4 4 0 1 0 0-8 4 4 0 0 0 0 8M4 21a8 8 0 0 1 16 0",
        "familia": "M8 10a3 3 0 1 0 0-6 3 3 0 0 0 0 6M17 11a2.5 2.5 0 1 0 0-5 2.5 2.5 0 0 0 0 5M2 20a6 6 0 0 1 12 0M15 20a5 5 0 0 1 7-4",
        "hucha": "M4 13a6 6 0 0 1 6-6h4a6 6 0 0 1 6 6v3H4zM7 18v2M17 18v2M16 11h1",
        "grafico": "M4 20V10M10 20V4M16 20v-7M22 20H2",
        "maleta": "M4 8h16v12H4zM9 8V5h6v3M4 14h16",
        "avion": "M2 13l20-6-8 14-2-5z",
        "mascota": "M6 9a2 2 0 1 0 0-4 2 2 0 0 0 0 4M18 9a2 2 0 1 0 0-4 2 2 0 0 0 0 4M9 20a3 3 0 0 1-3-3c0-2 2-3 3-5h6c1 2 3 3 3 5a3 3 0 0 1-3 3z",
        "ropa": "M9 4l3 2 3-2 5 4-3 3v9H7v-9L4 8z",
        "gym": "M4 9v6M20 9v6M7 7v10M17 7v10M7 12h10",
        "herramienta": "M14 4a4 4 0 0 1 6 6l-9 9-4 1 1-4z",
        "telefono": "M7 3h10v18H7zM10 19h4",
        "puntos": "M6 12h.01M12 12h.01M18 12h.01",
        "alquiler": "M4 21V9l8-6 8 6v12M9 21v-6h6v6M14 12h.01",
        "llave": "M14 7a4 4 0 1 1-3.5 5.9L4 19v-3h3v-3h3l.5-1A4 4 0 0 1 14 7",
        "sofa": "M4 11V8a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v3M2 12a2 2 0 0 1 4 0v5h12v-5a2 2 0 0 1 4 0v7H2z",
        "bombilla": "M9 18h6M10 21h4M12 3a6 6 0 0 1 4 10.5V17H8v-3.5A6 6 0 0 1 12 3",
        "agua": "M12 3s6 6.5 6 11a6 6 0 0 1-12 0c0-4.5 6-11 6-11",
        "basura": "M4 7h16M9 7V4h6v3M6 7l1 14h10l1-14M10 11v6M14 11v6",
        "bus": "M4 6h16v9H4zM4 15v3h2v-3M18 15v3h2v-3M7 9h10M6 19a1 1 0 1 0 2 0M16 19a1 1 0 1 0 2 0",
        "taxi": "M5 16v-4l2-5h10l2 5v4M5 16h14M9 7V5h6v2M7 19a1 1 0 1 0 2 0M15 19a1 1 0 1 0 2 0",
        "moto": "M5 18a3 3 0 1 0 0-6 3 3 0 0 0 0 6M19 18a3 3 0 1 0 0-6 3 3 0 0 0 0 6M8 15h5l3-6h2M11 9h4",
        "bici": "M6 19a3 3 0 1 0 0-6 3 3 0 0 0 0 6M18 19a3 3 0 1 0 0-6 3 3 0 0 0 0 6M9 16l3-8h3M8 8h4",
        "parking": "M8 18V6h4a3 3 0 0 1 0 6H8M4 3h16v18H4z",
        "taller": "M3 18h18M6 18V9l6-4 6 4v9M9 18v-4h6v4",
        "peaje": "M5 20V8h6v12M13 20V4h6v16M8 12h.01M16 8h.01",
        "supermercado": "M3 9l2-5h14l2 5M3 9h18v11H3zM9 13h6",
        "panaderia": "M4 12a5 5 0 0 1 5-5h6a5 5 0 0 1 0 10H9a5 5 0 0 1-5-5M9 9v6M13 9v6",
        "restaurante": "M4 4v6a3 3 0 0 0 6 0V4M7 10v10M14 4h5a1 1 0 0 1 1 1v6h-6z",
        "pizza": "M12 3 4 20l16-5zM11 11h.01M13 15h.01",
        "bebida": "M6 4h12l-2 6H8zM8 10l1 10h6l1-10M10 14h4",
        "farmacia": "M12 6v12M6 12h12M6 6h12v12H6z",
        "medico": "M8 3h8v4h4v10H4V7h4zM12 10v4M10 12h4",
        "dentista": "M8 3c2 0 2 2 4 2s2-2 4-2 3 3 2 8c-1 4-2 8-3 8s-1-4-3-4-2 4-3 4-2-4-3-8C5 6 6 3 8 3",
        "gafas": "M6 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6M18 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6M9 12h6",
        "peluqueria": "M6 4l12 12M18 4 6 16M6 20a2 2 0 1 0 0-4 2 2 0 0 0 0 4M18 20a2 2 0 1 0 0-4 2 2 0 0 0 0 4",
        "cuna": "M4 10v9M20 10v9M4 14h16M6 10a6 6 0 0 1 12 0",
        "colegio": "M12 3l8 4v3H4V7zM6 10v11M18 10v11M10 21v-6h4v6",
        "laptop": "M4 6h16v9H4zM2 18h20M9 18h6",
        "suscripcion": "M4 6h16v12H4zM8 10h8M8 14h5M17 14h.01",
        "juego": "M7 12h4M9 10v4M15 12h.01M17 14h.01M4 8h16v8H4z",
        "deporte": "M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18M12 3v18M3 12h18",
        "playa": "M12 12a7 7 0 0 1 10-4c-2 5-6 5-10 4M12 12v9M4 21h16",
        "hotel": "M4 20V6h16v14M8 10h.01M8 14h.01M12 10h.01M12 14h.01M16 10h.01M16 14h.01",
        "concierto": "M4 20V10l7-5v15M11 12h9v8M15 16h.01",
        "iglesia2": "M12 2v5M9 5h6M5 21V10l7-4 7 4v11M10 21v-6h4v6",
        "mano": "M8 12V5a2 2 0 0 1 4 0v6M12 11V4a2 2 0 0 1 4 0v8M16 9a2 2 0 0 1 4 0v6a6 6 0 0 1-6 6H10a6 6 0 0 1-6-6v-3a2 2 0 0 1 4 0",
        "impuesto": "M6 3h12v18H6zM9 8h6M9 12h6M9 16h3",
        "banco": "M3 10 12 4l9 6M5 10v10h14V10M9 20v-6h6v6",
        "seguro": "M12 3l8 3v6c0 5-4 8-8 9-4-1-8-4-8-9V6z M9 12l2 2 4-4",
        "nomina": "M4 5h16v14H4zM8 9h8M8 13h5M15 15a2 2 0 1 0 4 0 2 2 0 0 0-4 0",
        "propina": "M12 3v18M8 7h6a3 3 0 0 1 0 6h-4a3 3 0 0 0 0 6h6",
        "bolsa": "M6 8h12l-1 12H7zM9 8V5a3 3 0 0 1 6 0v3",
        "camion": "M3 7h11v9H3zM14 11h4l3 3v2h-7M6 19a1 1 0 1 0 2 0M16 19a1 1 0 1 0 2 0",
        "caja": "M4 8l8-4 8 4v9l-8 4-8-4zM4 8l8 4 8-4M12 12v9",
        "factura": "M6 3h12v18l-3-2-3 2-3-2-3 2zM9 8h6M9 12h6",
        "reloj": "M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18M12 7v5l4 2",
        "estrella": "M12 3l3 6 6 1-4.5 4.5L18 21l-6-3-6 3 1.5-6.5L3 10l6-1z",
        "corazon": "M12 20s-8-4.5-8-10a4.5 4.5 0 0 1 8-3 4.5 4.5 0 0 1 8 3c0 5.5-8 10-8 10",
        "planta": "M12 21V9M12 9C9 9 7 7 7 4c3 0 5 2 5 5M12 9c3 0 5-2 5-5-3 0-5 2-5 5M6 21h12",
        "limpieza": "M6 21h12l-1-9H7zM9 12V4h6v8M12 15v3",
        "mudanza": "M3 17h18M5 17V9l7-5 7 5v8M10 17v-5h4v5",
        "perro": "M5 11l2-5 3 2h4l3-2 2 5v6a3 3 0 0 1-3 3H8a3 3 0 0 1-3-3zM9 13h.01M15 13h.01M11 16h2",
        "gato": "M5 20V9l3-5 2 3h4l2-3 3 5v11zM9 13h.01M15 13h.01M10 16h4",
        "libro2": "M4 6a4 4 0 0 1 8 0 4 4 0 0 1 8 0v12a4 4 0 0 0-8 0 4 4 0 0 0-8 0z",
        "premio": "M8 3h8v6a4 4 0 0 1-8 0zM12 13v5M9 21h6M5 5H3v2a4 4 0 0 0 4 4M19 5h2v2a4 4 0 0 1-4 4",
        "moneda": "M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18M12 7v10M9.5 9.5h5M9.5 14.5h5",
        "cripto": "M9 4v16M7 8h5a2 2 0 0 1 0 4H7h5a2 2 0 0 1 0 4H7M12 4v2M12 18v2",
        "candado": "M6 11h12v10H6zM9 11V8a3 3 0 0 1 6 0v3M12 15v3"
    ]
    static let cat: [String: String] = [
        "Ingresos": "grafico", "Vivienda": "casa", "Alimentación": "comida", "Servicios": "rayo",
        "Transporte": "auto", "Educación": "birrete", "Salud": "salud", "Donaciones": "iglesia",
        "Entretenimiento": "cine", "Deudas": "tarjeta", "Personal": "usuario", "Ahorro": "hucha", "Otros": "puntos"
    ]
}

// Dibuja un glifo por nombre: si está en el catálogo del diseño lo pinta con
// CNSVGShape (idéntico a la web); si no, cae a un SF Symbol con ese nombre.
@ViewBuilder func cnGlifo(_ nombre: String, tam: CGFloat = 20, grosor: CGFloat = 2) -> some View {
    if let d = CNIconos.paths[nombre] {
        CNSVGShape(d: d).stroke(style: StrokeStyle(lineWidth: grosor, lineCap: .round, lineJoin: .round)).frame(width: tam, height: tam)
    } else {
        Image(systemName: nombre).font(.system(size: tam * 0.82, weight: .semibold))
    }
}

extension View { func tarjetaCN() -> some View {
    self.padding(14).frame(maxWidth: .infinity)
        .background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(CNC.line, lineWidth: 0.5))
} }

// ── Pantallas de DETALLE nativas (al tocar un item) ─────────────────────────
private func cnInicial(_ s: String) -> String {
    let p = s.split(separator: " ").prefix(2).compactMap { $0.first }; return String(p).uppercased()
}
struct CNDetCabecera: View {
    let inicial: String; let nombre: String; let sub: String
    var fondo: Color = cnColor(0x093a20); var cuadro: Color = CNC.info; var volverA: String = "Cuentas"
    var onClose: () -> Void
    var body: some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: 52)
            HStack(spacing: 12) {
                Button(action: onClose) { HStack(spacing: 2) { Image(systemName: "chevron.left").font(.system(size: 16, weight: .bold)); Text(volverA).font(.system(size: 15, weight: .semibold)) }.foregroundColor(.white).opacity(0.9) }.buttonStyle(.plain)
                Spacer(minLength: 0)
            }
            HStack(spacing: 12) {
                Text(inicial).font(.system(size: 15, weight: .heavy)).foregroundColor(.white)
                    .frame(width: 44, height: 44).background(cuadro).clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                VStack(alignment: .leading, spacing: 2) {
                    Text(nombre).font(.system(size: 20, weight: .heavy)).foregroundColor(.white)
                    Text(sub).font(.system(size: 12.5)).foregroundColor(.white.opacity(0.8))
                }
                Spacer(minLength: 0)
            }.padding(.top, 12)
        }
        .padding(.horizontal, 16).padding(.bottom, 16).background(fondo.ignoresSafeArea(edges: .top))
    }
}
struct CNDetCifra: View {
    let rotulo: String; let valor: String; var color: Color = CNC.ink; let cols: [(String, String, Color)]
    var body: some View {
        VStack(spacing: 14) {
            VStack(spacing: 3) { Text(rotulo).font(.system(size: 12.5, weight: .semibold)).foregroundColor(CNC.pmut); Text(valor).font(.system(size: 32, weight: .heavy)).foregroundColor(color) }
            HStack(spacing: 0) { ForEach(cols.indices, id: \.self) { i in
                VStack(spacing: 3) { Text(cols[i].0).font(.system(size: 11, weight: .semibold)).foregroundColor(CNC.pmut); Text(cols[i].1).font(.system(size: 16, weight: .heavy)).foregroundColor(cols[i].2) }.frame(maxWidth: .infinity)
                if i < cols.count - 1 { Rectangle().fill(CNC.line).frame(width: 0.5, height: 30) }
            } }
        }
        .padding(.vertical, 18).padding(.horizontal, 16).frame(maxWidth: .infinity)
        .background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous)).overlay(RoundedRectangle(cornerRadius: 18).stroke(CNC.line, lineWidth: 0.5))
    }
}
struct CNBotonAncho: View {
    let texto: String; var icono: String? = nil; var tap: () -> Void
    var body: some View {
        Button(action: tap) {
            HStack(spacing: 6) { if let ic = icono { Image(systemName: ic).font(.system(size: 15, weight: .heavy)) }; Text(texto).font(.system(size: 15.5, weight: .bold)) }
                .foregroundColor(Color(cnHex: 0x3a2c00)).frame(maxWidth: .infinity).padding(.vertical, 15)
                .cnVidrio(Capsule(), tinte: CNC.acc)
                .shadow(color: CNC.acc.opacity(0.35), radius: 12, y: 4)
        }.buttonStyle(.plain)
    }
}
private func cnCuerpo<C: View>(@ViewBuilder _ c: () -> C) -> some View {
    ScrollView(showsIndicators: false) { VStack(alignment: .leading, spacing: 14) { c(); Color.clear.frame(height: 40) }.padding(.horizontal, 16).padding(.top, 14) }.background(CNC.scr.ignoresSafeArea())
}

struct CNDetalleCuenta: View {
    @ObservedObject var datos: CNDatos; let cuentaId: Int; var onClose: () -> Void
    var body: some View {
        let medio = "cuenta:\(cuentaId)"; let lb = datos.libreta
        let c = lb.cuentas.first { $0.id == cuentaId }
        let movs = lb.movimientosDe(medio); let mes = String(cnHoy().prefix(7))
        let entra = movs.filter { ($0.esIngreso || ($0.esTransfer && $0.destino == medio)) && $0.fecha.hasPrefix(mes) }.reduce(0) { $0 + abs($1.monto) }
        let sale = movs.filter { ($0.esGasto || $0.tipo == "Ahorro" || ($0.esTransfer && $0.medio == medio)) && $0.fecha.hasPrefix(mes) }.reduce(0) { $0 + abs($1.monto) }
        return VStack(spacing: 0) {
            CNDetCabecera(inicial: cnInicial(c?.nombre ?? "?"), nombre: c?.nombre ?? "Cuenta", sub: ((c?.banco.isEmpty ?? true) ? "Sin banco" : c!.banco) + " · \(movs.count) mov.", cuadro: cnColor(hexString: c?.color ?? "#137d41"), onClose: onClose)
            cnCuerpo {
                CNDetCifra(rotulo: "Saldo disponible", valor: cnDinero(c?.saldo ?? 0), cols: [("Entró este mes", cnDinero(entra), CNC.pos), ("Salió este mes", cnDinero(sale), CNC.neg)])
                CNBotonAncho(texto: "Nuevo movimiento", icono: "plus") { datos.onAccion("nuevo", "") }
                Button { datos.onAccion("transferir", "\(cuentaId)") } label: {
                    HStack(spacing: 6) { Image(systemName: "arrow.left.arrow.right").font(.system(size: 14, weight: .bold)); Text("Transferir").font(.system(size: 15, weight: .semibold)) }
                        .foregroundColor(CNC.ink).frame(maxWidth: .infinity).padding(.vertical, 13)
                        .background(.ultraThinMaterial, in: Capsule()).overlay(Capsule().stroke(Color.white.opacity(0.5), lineWidth: 0.7))
                }.buttonStyle(.plain)
                Text("MOVIMIENTOS DE ESTA CUENTA").font(.system(size: 12.5, weight: .semibold)).foregroundColor(CNC.pmut).padding(.leading, 4)
                if movs.isEmpty { Text("Aquí saldrá lo que anotes con esta cuenta.").font(.system(size: 13.5)).foregroundColor(CNC.pmut).frame(maxWidth: .infinity, alignment: .leading).padding(16).background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 16)).overlay(RoundedRectangle(cornerRadius: 16).stroke(CNC.line, lineWidth: 1)) }
                else { VStack(spacing: 0) { ForEach(movs.indices, id: \.self) { i in filaMov(movs[i], medio); if i < movs.count - 1 { Rectangle().fill(CNC.line).frame(height: 0.5).padding(.leading, 58) } } }.background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 16)).overlay(RoundedRectangle(cornerRadius: 16).stroke(CNC.line, lineWidth: 0.5)) }
            }
        }
    }
    private func filaMov(_ m: CNMov, _ esta: String) -> some View {
        let entra = m.esIngreso || (m.esTransfer && m.destino == esta); let color = entra ? CNC.pos : CNC.neg
        return HStack(spacing: 12) {
            Image(systemName: m.esTransfer ? "arrow.left.arrow.right" : (entra ? "arrow.down" : "arrow.up")).font(.system(size: 13, weight: .bold)).foregroundColor(.white).frame(width: 32, height: 32).background(color).clipShape(Circle())
            VStack(alignment: .leading, spacing: 1) { Text(m.concepto).font(.system(size: 15, weight: .semibold)).foregroundColor(CNC.ink); Text("\(m.categoria) · \(cnFechaCorta(m.fecha))").font(.system(size: 11.5)).foregroundColor(CNC.pmut) }
            Spacer(minLength: 6); Text((entra ? "+ " : "− ") + cnDinero(m.monto)).font(.system(size: 15, weight: .heavy)).foregroundColor(color)
        }.padding(.horizontal, 14).padding(.vertical, 10)
    }
}

struct CNDetallePrestamo: View {
    @ObservedObject var datos: CNDatos; let prestamoId: Int; var onClose: () -> Void
    var body: some View {
        let p = datos.libreta.prestamos.first { $0.id == prestamoId }; let meDeben = (p?.sentido ?? "meDeben") == "meDeben"
        return VStack(spacing: 0) {
            CNDetCabecera(inicial: cnInicial(p?.nombre ?? "?"), nombre: p?.nombre ?? "Préstamo", sub: meDeben ? "Te debe" : "Le debes", fondo: cnColor(0x5a3fa0), cuadro: cnColor(0x825eb9), onClose: onClose)
            cnCuerpo {
                CNDetCifra(rotulo: meDeben ? "Te deben" : "Debes", valor: cnDinero(p?.pendiente ?? 0), color: cnColor(0x825eb9),
                    cols: [(meDeben ? "Prestaste" : "Te prestaron", cnDinero(p?.total ?? 0), CNC.ink), ("Ya \(meDeben ? "abonó" : "abonaste")", cnDinero(p?.pagado ?? 0), CNC.pos)])
                CNBotonAncho(texto: "Registrar un abono", icono: "plus") { datos.onAccion("abono", "\(prestamoId)") }
            }
        }
    }
}

struct CNDetalleTarjeta: View {
    @ObservedObject var datos: CNDatos; let tarjetaId: Int; var onClose: () -> Void
    var body: some View {
        let t = datos.libreta.tarjetas.first { $0.id == tarjetaId }
        return VStack(spacing: 0) {
            CNDetCabecera(inicial: cnInicial(t?.nombre ?? "?"), nombre: t?.nombre ?? "Tarjeta", sub: "Corte \(t?.corte ?? 0)", fondo: cnColor(0x9a3f3f), cuadro: CNC.neg, onClose: onClose)
            cnCuerpo {
                CNDetCifra(rotulo: "Deuda actual", valor: cnDinero(t?.saldo ?? 0), color: CNC.neg, cols: [("Límite", cnDinero(t?.limite ?? 0), CNC.ink), ("Disponible", cnDinero(t?.disponible ?? 0), CNC.pos)])
                CNBotonAncho(texto: "Pagar la tarjeta", icono: "creditcard") { datos.onAccion("pagoTarjeta", "\(tarjetaId)") }
            }
        }
    }
}

struct CNDetalleMeta: View {
    @ObservedObject var datos: CNDatos; let metaId: Int; var onClose: () -> Void
    var body: some View {
        let m = datos.libreta.metas.first { $0.id == metaId }; let prog = m?.progreso ?? 0
        return VStack(spacing: 0) {
            CNDetCabecera(inicial: "◎", nombre: m?.nombre ?? "Meta", sub: "Meta de ahorro", fondo: cnColor(0x5a3fa0), cuadro: cnColor(0x825eb9), volverA: "Plan", onClose: onClose)
            cnCuerpo {
                VStack(spacing: 14) {
                    ZStack {
                        Circle().stroke(CNC.soft, lineWidth: 12).frame(width: 128, height: 128)
                        Circle().trim(from: 0, to: CGFloat(prog)).stroke(cnColor(0x825eb9), style: StrokeStyle(lineWidth: 12, lineCap: .round)).rotationEffect(.degrees(-90)).frame(width: 128, height: 128)
                        VStack(spacing: 1) { Text("\(Int(prog * 100))%").font(.system(size: 28, weight: .heavy)).foregroundColor(CNC.ink); Text("logrado").font(.system(size: 11.5)).foregroundColor(CNC.pmut) }
                    }.padding(.top, 4)
                    CNDetCifra(rotulo: "Ahorrado", valor: cnDinero(m?.ahorrado ?? 0), color: cnColor(0x825eb9), cols: [("Objetivo", cnDinero(m?.meta ?? 0), CNC.ink), ("Te falta", cnDinero(max(0, (m?.meta ?? 0) - (m?.ahorrado ?? 0))), CNC.neg)])
                }
                CNBotonAncho(texto: "Aportar a la meta", icono: "plus") { datos.onAccion("aporte", "\(metaId)") }
            }
        }
    }
}

struct CNDetalleMov: View {
    @ObservedObject var datos: CNDatos; let movId: String; var onClose: () -> Void
    @State private var confirmarBorrar = false
    var body: some View {
        let m = datos.libreta.tx.first { $0.id == movId }; let entra = m?.esIngreso ?? false
        return VStack(spacing: 0) {
            CNDetCabecera(inicial: cnInicial(m?.concepto ?? "?"), nombre: m?.concepto ?? "Movimiento", sub: "\(m?.categoria ?? "") · \(cnFechaCorta(m?.fecha ?? ""))", fondo: cnColor(0x7a5f10), cuadro: cnColor(0xe0a92e), volverA: "Movimientos", onClose: onClose)
            cnCuerpo {
                VStack(spacing: 3) { Text("MONTO").font(.system(size: 11, weight: .semibold)).tracking(0.4).foregroundColor(CNC.pmut); Text((entra ? "+ " : "− ") + cnDinero(m?.monto ?? 0)).font(.system(size: 34, weight: .heavy)).foregroundColor(entra ? CNC.pos : CNC.neg) }
                    .frame(maxWidth: .infinity).padding(.vertical, 18).background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 18)).overlay(RoundedRectangle(cornerRadius: 18).stroke(CNC.line, lineWidth: 0.5))
                VStack(spacing: 0) {
                    filaInfo("tag.fill", cnColor(0xe0a92e), "Categoría", m?.categoria ?? ""); div()
                    filaInfo("banknote.fill", CNC.pos, "Cuenta", datos.libreta.nombreMedio(m?.medio ?? "")); div()
                    filaInfo("calendar", CNC.neg, "Fecha", cnFechaCorta(m?.fecha ?? "")); div()
                    filaInfo("repeat", cnColor(0x825eb9), "Se repite", (m?.recurrente ?? false) ? "Sí" : "No")
                }.background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 16)).overlay(RoundedRectangle(cornerRadius: 16).stroke(CNC.line, lineWidth: 0.5))
                CNBotonAncho(texto: "Editar movimiento", icono: "pencil") { datos.onAccion("editarMov", movId) }
                Button { confirmarBorrar = true } label: {
                    HStack(spacing: 6) { Image(systemName: "trash").font(.system(size: 14, weight: .bold)); Text("Eliminar movimiento").font(.system(size: 15, weight: .semibold)) }
                        .foregroundColor(CNC.neg).frame(maxWidth: .infinity).padding(.vertical, 14).background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 13)).overlay(RoundedRectangle(cornerRadius: 13).stroke(CNC.neg.opacity(0.3), lineWidth: 1))
                }.buttonStyle(.plain)
                .alert("¿Eliminar movimiento?", isPresented: $confirmarBorrar) {
                    Button("Cancelar", role: .cancel) {}
                    Button("Eliminar", role: .destructive) { datos.onBorrarMov(movId); onClose() }
                } message: { Text("Esto revierte su efecto en los saldos. No se puede deshacer.") }
            }
        }
    }
    private func filaInfo(_ icono: String, _ tinte: Color, _ titulo: String, _ valor: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icono).font(.system(size: 14, weight: .semibold)).foregroundColor(.white).frame(width: 29, height: 29).background(tinte).clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            Text(titulo).font(.system(size: 16)).foregroundColor(CNC.ink); Spacer(minLength: 8); Text(valor).font(.system(size: 15)).foregroundColor(CNC.pmut)
        }.padding(.horizontal, 14).padding(.vertical, 11)
    }
    private func div() -> some View { Rectangle().fill(CNC.line).frame(height: 0.5).padding(.leading, 57) }
}

// ── Formulario «Nuevo movimiento» NATIVO (guarda a la web) ──────────────────
struct CNNuevoMov: View {
    @ObservedObject var datos: CNDatos
    var onClose: () -> Void
    var editar: CNMov? = nil
    @State private var tipo = 2
    @State private var monto = ""
    @State private var concepto = ""
    @State private var cuentaId = 0
    @State private var categoria = ""
    @State private var fecha = Date()
    @State private var repetir = false
    private let tipos = ["Ingreso", "Fijo", "Variable", "Ahorro"]
    private let mapa = ["Ingreso", "Gasto Fijo", "Gasto Variable", "Ahorro"]

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.4).ignoresSafeArea()
            VStack(spacing: 0) {
                cabecera
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        pildoras
                        grupo { VStack(spacing: 2) {
                            Text("MONTO").font(.system(size: 11, weight: .semibold)).tracking(0.4).foregroundColor(CNC.pmut)
                            HStack(spacing: 6) { Text("RD$").font(.system(size: 20, weight: .heavy)).foregroundColor(CNC.pmut)
                                TextField("0", text: $monto).font(.system(size: 34, weight: .heavy)).foregroundColor(CNC.ink).keyboardType(.numberPad).multilineTextAlignment(.center).fixedSize() }
                        }.frame(maxWidth: .infinity).padding(.vertical, 16) }
                        grupo { TextField("Descripción o concepto", text: $concepto).font(.system(size: 16)).foregroundColor(CNC.ink).padding(.horizontal, 15).padding(.vertical, 13) }
                        VStack(spacing: 6) {
                            titulo("Cuándo y de dónde")
                            grupo {
                                HStack(spacing: 12) { cuadro("calendar", CNC.neg); Text("Fecha").font(.system(size: 16)).foregroundColor(CNC.ink); Spacer(); DatePicker("", selection: $fecha, displayedComponents: .date).labelsHidden() }.padding(.horizontal, 14).padding(.vertical, 7)
                                divi()
                                menuFila("banknote.fill", CNC.info, "Pagado con", cuentaNombre) { ForEach(datos.libreta.cuentas) { c in Button(c.nombre) { cuentaId = c.id } } }
                            }
                        }
                        VStack(spacing: 6) {
                            titulo("Categoría")
                            grupo { menuFila("tag.fill", cnColor(0xe0a92e), "Categoría", categoria.isEmpty ? "Otros" : categoria) { ForEach(datos.libreta.categorias, id: \.nombre) { c in Button(c.nombre) { categoria = c.nombre } }; Button("Otros") { categoria = "Otros" } } }
                        }
                        grupo { HStack(spacing: 12) { cuadro("repeat", cnColor(0x825eb9)); Text("Repetir cada mes").font(.system(size: 16)).foregroundColor(CNC.ink); Spacer(); Toggle("", isOn: $repetir).labelsHidden().tint(CNC.pos) }.padding(.horizontal, 14).padding(.vertical, 7) }
                        Color.clear.frame(height: 40)
                    }.padding(.horizontal, 16)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(CNC.scr.clipShape(CNRedondo(radio: 28, esquinas: [.topLeft, .topRight])))
            .ignoresSafeArea(edges: .bottom).padding(.top, 46)
        }
        .onAppear {
            if let m = editar {
                tipo = mapa.firstIndex(of: m.tipo) ?? 2
                monto = m.monto > 0 ? String(Int(m.monto.rounded())) : ""
                concepto = m.concepto
                categoria = m.categoria
                repetir = m.recurrente
                if m.medio.hasPrefix("cuenta:"), let id = Int(m.medio.dropFirst(7)) { cuentaId = id }
                let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; f.locale = Locale(identifier: "en_US_POSIX")
                if let d = f.date(from: m.fecha) { fecha = d }
            }
            if cuentaId == 0 { cuentaId = datos.libreta.cuentas.first?.id ?? 0 }
        }
    }

    private var cabecera: some View {
        VStack(spacing: 0) {
            Capsule().fill(CNC.line).frame(width: 40, height: 5).padding(.top, 8).padding(.bottom, 10)
            ZStack {
                Text(editar == nil ? "Nuevo movimiento" : "Editar movimiento").font(.system(size: 17, weight: .bold)).foregroundColor(CNC.ink)
                HStack {
                    Button(action: onClose) { Image(systemName: "xmark").font(.system(size: 15, weight: .bold)).foregroundColor(CNC.pmut).frame(width: 34, height: 34).cnVidrio(Circle()) }.buttonStyle(.plain)
                    Spacer()
                    Button(action: guardar) { HStack(spacing: 5) { Image(systemName: "checkmark").font(.system(size: 12, weight: .heavy)); Text("Guardar").font(.system(size: 14, weight: .bold)) }.foregroundColor(Color(cnHex: 0x3a2c00)).padding(.horizontal, 15).padding(.vertical, 8).cnVidrio(Capsule(), tinte: CNC.acc) }.buttonStyle(.plain)
                }
            }.padding(.horizontal, 16).padding(.bottom, 14)
        }
    }
    private var pildoras: some View {
        HStack(spacing: 4) { ForEach(tipos.indices, id: \.self) { i in
            Text(tipos[i]).font(.system(size: 13.5, weight: i == tipo ? .bold : .semibold)).foregroundColor(i == tipo ? .white : CNC.pmut)
                .frame(maxWidth: .infinity).padding(.vertical, 9).background(i == tipo ? cnColor(0x093a20) : Color.clear).clipShape(Capsule()).onTapGesture { tipo = i }
        } }.padding(4).background(CNC.soft).clipShape(Capsule())
    }
    private var cuentaNombre: String { datos.libreta.cuentas.first { $0.id == cuentaId }?.nombre ?? "Efectivo" }
    private func titulo(_ t: String) -> some View { Text(t.uppercased()).font(.system(size: 12.5, weight: .semibold)).tracking(0.3).foregroundColor(CNC.pmut).padding(.leading, 16).frame(maxWidth: .infinity, alignment: .leading) }
    private func grupo<C: View>(@ViewBuilder _ c: () -> C) -> some View { VStack(spacing: 0) { c() }.background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous)).overlay(RoundedRectangle(cornerRadius: 16).stroke(CNC.line, lineWidth: 0.5)) }
    private func divi() -> some View { Rectangle().fill(CNC.line).frame(height: 0.5).padding(.leading, 57) }
    private func cuadro(_ ic: String, _ tinte: Color) -> some View { Image(systemName: ic).font(.system(size: 14, weight: .semibold)).foregroundColor(.white).frame(width: 29, height: 29).background(tinte).clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous)) }
    private func menuFila<M: View>(_ icono: String, _ tinte: Color, _ titulo: String, _ valor: String, @ViewBuilder _ menu: () -> M) -> some View {
        Menu { menu() } label: {
            HStack(spacing: 12) { cuadro(icono, tinte); Text(titulo).font(.system(size: 16)).foregroundColor(CNC.ink); Spacer(minLength: 8); Text(valor).font(.system(size: 15)).foregroundColor(CNC.pmut); Image(systemName: "chevron.up.chevron.down").font(.system(size: 11, weight: .semibold)).foregroundColor(CNC.pmut.opacity(0.6)) }.padding(.horizontal, 14).padding(.vertical, 11)
        }
    }
    private func guardar() {
        let n = Double(monto.replacingOccurrences(of: ",", with: "")) ?? 0
        guard n > 0 else { onClose(); return }
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; f.locale = Locale(identifier: "en_US_POSIX")
        var dict: [String: Any] = [
            "concepto": concepto.isEmpty ? (categoria.isEmpty ? "Movimiento" : categoria) : concepto,
            "categoria": categoria.isEmpty ? "Otros" : categoria,
            "tipo": mapa[tipo], "monto": n, "fecha": f.string(from: fecha),
            "medio": "cuenta:\(cuentaId)", "recurrente": repetir
        ]
        if let m = editar { dict["id"] = m.id; datos.onEditarMov(dict) } else { datos.onCrearMov(dict) }
        onClose()
    }
}

// Esquinas redondeadas selectivas (iOS 15+, sin UnevenRoundedRectangle que es 16+).
struct CNRedondo: Shape {
    var radio: CGFloat
    var esquinas: UIRectCorner
    func path(in rect: CGRect) -> Path {
        Path(UIBezierPath(roundedRect: rect, byRoundingCorners: esquinas, cornerRadii: CGSize(width: radio, height: radio)).cgPath)
    }
}
