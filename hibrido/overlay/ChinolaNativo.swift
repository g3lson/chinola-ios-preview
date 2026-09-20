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
    // «transparent» no es un número hexadecimal: leído como tal daba 0, o sea
    // NEGRO, y el calendario salía con bandas y círculos negros por todos lados.
    if t.isEmpty || t == "transparent" || t == "none" { return .clear }
    // La web resuelve sus colores (var(), color-mix(), oklch()) a rgb()/rgba()
    // antes de mandarlos, así que aquí solo hay que leer los números.
    if t.hasPrefix("rgb") {
        let dentro = t.drop(while: { $0 != "(" }).dropFirst().prefix(while: { $0 != ")" })
        let n = dentro.split(whereSeparator: { " ,/".contains($0) }).compactMap { Double($0) }
        if n.count >= 3 {
            return Color(.sRGB, red: n[0] / 255, green: n[1] / 255, blue: n[2] / 255,
                         opacity: n.count > 3 ? n[3] : 1)
        }
        return .clear
    }
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
/// La paleta del tema que tiene puesto el usuario. La web tiene 31 temas y los
/// pinta con variables CSS; el nativo los recibe por `__chinolaTemaJSON` y los
/// guarda aquí, para que las pantallas nativas cambien de color con la app.
struct CNPaletaTema {
    var scr  = cnColor(0xfaf7ec)
    var card = cnColor(0xffffff)
    var soft = cnColor(0xf9f5e6)
    var line = cnColor(0xe5e1d3)
    var ink  = cnColor(0x132419)
    var pmut = cnColor(0x516356)
    var acc  = cnColor(0xefcb4c)
    var side = cnColor(0x1d3d28)      // la franja de la cabecera
    var pos  = cnColor(0x137d41)
    var neg  = cnColor(0xd55948)
    var info = cnColor(0x398ad6)
    var oscuro = false

    /// Del JSON que manda la web: { bg, card, suave, borde, tinta, gris, side,
    /// acento, pos, neg, oscuro }. Lo que falte se queda como está.
    static func desde(json: String) -> CNPaletaTema? {
        guard let d = json.data(using: .utf8),
              let o = (try? JSONSerialization.jsonObject(with: d)) as? [String: Any] else { return nil }
        var p = CNPaletaTema()
        func col(_ k: String, _ destino: inout Color) {
            if let v = o[k] as? String, !v.isEmpty, !v.contains("var(") { destino = cnColor(hexString: v) }
        }
        col("bg", &p.scr); col("card", &p.card); col("suave", &p.soft); col("borde", &p.line)
        col("tinta", &p.ink); col("gris", &p.pmut); col("side", &p.side); col("acento", &p.acc)
        col("pos", &p.pos); col("neg", &p.neg); col("info", &p.info)
        p.oscuro = (o["oscuro"] as? Bool) ?? false
        return p
    }
}

/// Los colores, siempre leídos del tema puesto (por eso son `var` calculadas:
/// al cambiar el tema, el siguiente dibujo ya sale del color nuevo).
enum CNC {
    static var tema = CNPaletaTema()
    static var scr: Color  { tema.scr }
    static var card: Color { tema.card }
    static var soft: Color { tema.soft }
    static var line: Color { tema.line }
    static var ink: Color  { tema.ink }
    static var pmut: Color { tema.pmut }
    static var acc: Color  { tema.acc }
    static var side: Color { tema.side }
    static var pos: Color  { tema.pos }
    static var neg: Color  { tema.neg }
    static var info: Color { tema.info }
    /// Lo que se escribe ENCIMA del acento (el amarillo de la marca pide tinta
    /// oscura; un acento oscuro pide tinta clara).
    static var sobreAcc: Color { cnSobre(tema.acc) }
}

/// La tinta que se lee encima de un color: oscura sobre claro y al revés.
func cnSobre(_ c: Color) -> Color { cnClaro(c) ? cnColor(0x20180a) : .white }

/// El margen seguro de arriba del aparato (59 pt con isla, 47 con muesca).
func cnMargenArriba() -> CGFloat {
    let escenas = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    let ventana = escenas.flatMap { $0.windows }.first { $0.isKeyWindow } ?? escenas.first?.windows.first
    return ventana?.safeAreaInsets.top ?? 47
}

/// ¿Este color es claro? (luminancia relativa, como hace la web en color.js)
func cnClaro(_ c: Color) -> Bool {
    let u = UIColor(c); var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    u.getRed(&r, green: &g, blue: &b, alpha: &a)
    return (0.299 * r + 0.587 * g + 0.114 * b) > 0.6
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

struct CNTarjeta: Decodable, Identifiable { var id: Int = 0; var nombre: String = ""; var banco: String = ""; var saldo: Double = 0; var limite: Double = 0; var corte: Int = 0; var pago: Int = 0; var color: String = "#d55948"
    init(from d: Decoder) throws { let c = try d.container(keyedBy: K.self)
        id = (try? c.decodeIfPresent(Int.self, forKey: .id)) ?? 0
        nombre = (try? c.decodeIfPresent(String.self, forKey: .nombre)) ?? ""
        saldo = (try? c.decodeIfPresent(Double.self, forKey: .saldo)) ?? 0
        limite = (try? c.decodeIfPresent(Double.self, forKey: .limite)) ?? 0
        corte = (try? c.decodeIfPresent(Int.self, forKey: .corte)) ?? 0
        pago = (try? c.decodeIfPresent(Int.self, forKey: .pago)) ?? 0
        banco = (try? c.decodeIfPresent(String.self, forKey: .banco)) ?? ""
        color = (try? c.decodeIfPresent(String.self, forKey: .color)) ?? "#d55948" }
    enum K: String, CodingKey { case id, nombre, banco, saldo, limite, corte, pago, color }
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

struct CNMeta: Decodable, Identifiable { var id: Int = 0; var nombre: String = ""; var meta: Double = 0; var ahorrado: Double = 0; var mensual: Double = 0; var color: String = "#825eb9"; var icono: String = "target"
    init(from d: Decoder) throws { let c = try d.container(keyedBy: K.self)
        id = (try? c.decodeIfPresent(Int.self, forKey: .id)) ?? 0
        nombre = (try? c.decodeIfPresent(String.self, forKey: .nombre)) ?? ""
        meta = (try? c.decodeIfPresent(Double.self, forKey: .meta)) ?? 0
        ahorrado = (try? c.decodeIfPresent(Double.self, forKey: .ahorrado)) ?? 0
        mensual = (try? c.decodeIfPresent(Double.self, forKey: .mensual)) ?? 0
        color = (try? c.decodeIfPresent(String.self, forKey: .color)) ?? "#825eb9"
        icono = (try? c.decodeIfPresent(String.self, forKey: .icono)) ?? "target" }
    enum K: String, CodingKey { case id, nombre, meta, ahorrado, mensual, color, icono }
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
    var onLimiteCategoria: (String, Double) -> Void = { _, _ in }   // (categoría, límite) → web
    var onMes: (Int) -> Void = { _ in }         // −1 / +1 desde la cabecera
    var onEmpezar: () -> Void = {}              // el «empieza aquí» del resumen vacío
    var onEditarPanel: () -> Void = {}          // organizar el panel (en la web)
    var onCalendario: () -> Void = {}           // abrir el calendario / periodo
    var onMesTira: (Int) -> Void = { _ in }     // saltar a un mes de la tira
    var onPlegar: () -> Void = {}               // plegar la cabecera clásica
    /// Editar el panel: (op, id, valor). op = quitar·ocultar·ancho·mover·agregar·grafico·rango·serie
    var onPanel: (String, String, String) -> Void = { _, _, _ in }
    /// Perfil: disparar una fila de los ajustes (grupo, fila, valor de lista).
    var onAjuste: (Int, Int, String?) -> Void = { _, _, _ in }
    var onPlan: () -> Void = {}
    @Published var ajustes: CNAjustes? = nil
    /// Subpantalla del perfil abierta (nativa).
    @Published var seccion: CNSeccion? = nil
    /// Pide a la web el modelo de una sección; la respuesta llega por
    /// `cargarSeccion`.
    var onAbrirSeccion: (String) -> Void = { _ in }
    /// Dispara una acción de la sección (su número) y vuelve a pedir el modelo.
    var onSeccionAccion: (Int, String?) -> Void = { _, _ in }
    /// Las hojas de la web, dibujadas en nativo.
    var onHojaCampo: (Int, String, String) -> Void = { _, _, _ in }
    var onHojaEnviar: () -> Void = {}
    @Published var hojaWeb: CNHojaWeb.Modelo? = nil
    @Published var periodo: CNPeriodo? = nil
    /// tipo: opcion · dia · antes · despues · aplicar · cerrar
    var onPeriodo: (String, Int) -> Void = { _, _ in }
    /// El detalle de un movimiento, armado por la web.
    @Published var movDetalle: CNMovDetalle? = nil
    var onMovAccion: (String) -> Void = { _ in }
    /// La pantalla de Cuentas, armada por la web.
    @Published var cuentas: CNCuentasModelo? = nil
    var onCuentasAccion: (String, Int) -> Void = { _, _ in }
    func cargarCuentas(json: String) { cuentas = CNCuentasModelo.desde(json: json) }
    func cargarMovDetalle(json: String) { movDetalle = CNMovDetalle.desde(json: json) }
    func cargarPeriodo(json: String) { periodo = CNPeriodo.desde(json: json) }
    func cargarHojaWeb(json: String) { hojaWeb = CNHojaWeb.Modelo.desde(json: json) }
    /// El panel del resumen, YA calculado por la web.
    @Published var resumen: CNResumenModelo? = nil
    func cargar(json: String) { if let l = CNLibreta.desde(json: json) { libreta = l } }
    func cargarPerfil(json: String) { if let p = CNPerfilInfo.desde(json: json) { perfil = p } }
    /// El tema de la web. Al cambiar, se avisa para que TODO se vuelva a dibujar
    /// con los colores nuevos (los de CNC son calculados).
    @Published var selloTema = 0
    func cargarSeccion(json: String) {
        if let x = CNSeccion.desde(json: json) { seccion = x }
    }
    func cargarAjustes(json: String) {
        if let a = CNAjustes.desde(json: json) { ajustes = a }
    }
    func cargarResumen(json: String) {
        if let m = CNResumenModelo.desde(json: json) { resumen = m }
    }
    func cargarTema(json: String) {
        guard let p = CNPaletaTema.desde(json: json) else { return }
        CNC.tema = p
        selloTema += 1
    }
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
                .foregroundColor(acento ? CNC.sobreAcc : .primary)
                .frame(width: 44, height: 44)
                .cnVidrio(Circle(), tinte: acento ? CNC.acc : nil)
        }
        .buttonStyle(.plain)
    }
}

/// Menú nativo (el del sistema) con el mismo botón de vidrio: filtros y
/// acciones salen pegados a su botón, como en cualquier app de iOS.
struct CNMenuVidrio<C: View>: View {
    let icono: String
    var acento: Bool = false
    var activo: Bool = false
    var lado: CGFloat = 44
    /// Color del glifo (blanco cuando va sobre la franja de la cabecera).
    var color: Color? = nil
    @ViewBuilder var contenido: () -> C
    var body: some View {
        Menu {
            contenido()
        } label: {
            Image(systemName: icono)
                .font(.system(size: acento ? 20 : 17, weight: .semibold))
                .foregroundColor(acento ? CNC.sobreAcc : (color ?? CNC.ink))
                .frame(width: lado, height: lado)
                .cnVidrio(Circle(), tinte: acento ? CNC.acc : (activo ? CNC.acc.opacity(0.5) : nil))
        }
    }
}

struct CNMovs: View {
    @ObservedObject var datos: CNDatos
    @State private var q = ""
    /// Los mismos filtros de la web, pero en menús del sistema.
    @State private var filtro = 0
    @State private var periodo = 0
    private static let filtros = ["Todos", "Ingresos", "Gastos", "Fijos", "Variables", "Ahorro"]
    private static let periodos = ["Todo", "Este mes", "Mes pasado", "Últimos 3 meses"]

    private var movimientos: [CNMov] {
        var t = datos.libreta.tx.sorted { $0.fecha > $1.fecha }
        switch filtro {
        case 1: t = t.filter { $0.esIngreso }
        case 2: t = t.filter { !$0.esIngreso && !$0.esTransfer }
        case 3: t = t.filter { $0.tipo.lowercased().contains("fijo") }
        case 4: t = t.filter { $0.tipo.lowercased().contains("variable") }
        case 5: t = t.filter { $0.tipo.lowercased().contains("ahorro") }
        default: break
        }
        if periodo > 0 {
            let cal = Calendar.current, hoy = Date()
            let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; f.locale = Locale(identifier: "en_US_POSIX")
            t = t.filter { m in
                guard let d = f.date(from: m.fecha) else { return true }
                switch periodo {
                case 1: return cal.isDate(d, equalTo: hoy, toGranularity: .month)
                case 2:
                    guard let anterior = cal.date(byAdding: .month, value: -1, to: hoy) else { return true }
                    return cal.isDate(d, equalTo: anterior, toGranularity: .month)
                default:
                    guard let desde = cal.date(byAdding: .month, value: -3, to: hoy) else { return true }
                    return d >= desde
                }
            }
        }
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
        // Sin franja de color: el título va sobre el fondo de la pantalla y se
        // va con el scroll; lo único que se queda arriba es el buscador, que es
        // lo que de verdad hace falta a mano mientras se rueda.
        return ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 12, pinnedViews: [.sectionHeaders]) {
                CNEspiaScroll { CNScrollEstado.shared.mirar($0) }.frame(height: 0)
                titulo.padding(.horizontal, 16).padding(.top, 2)
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

    private var titulo: some View {
        HStack(spacing: 10) {
            Text("Movimientos").font(.system(size: 28, weight: .heavy)).foregroundColor(CNC.ink)
            Spacer(minLength: 8)
            CNMenuVidrio(icono: "calendar", activo: periodo > 0) {
                Picker("", selection: $periodo) {
                    ForEach(CNMovs.periodos.indices, id: \.self) { i in Text(CNMovs.periodos[i]).tag(i) }
                }
            }
            CNCirculoAcento(icono: "plus") { datos.onNuevoMov() }
        }
    }

    /// El buscador se queda fijo arriba al rodar (`pinnedViews`), en vidrio, y
    /// el contenido pasa por detrás.
    private var busqueda: some View {
        HStack(spacing: 9) {
            HStack(spacing: 9) {
                Image(systemName: "magnifyingglass").font(.system(size: 15, weight: .semibold))
                    .foregroundColor(CNC.pmut)
                TextField("Buscar movimiento…", text: $q).font(.system(size: 15)).foregroundColor(CNC.ink)
                    .submitLabel(.search)
                if !q.isEmpty {
                    Button { q = "" } label: {
                        Image(systemName: "xmark.circle.fill").font(.system(size: 15)).foregroundColor(CNC.pmut)
                    }.buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14).frame(height: 46)
            .cnVidrio(Capsule())
            CNMenuVidrio(icono: "line.3.horizontal.decrease", activo: filtro > 0, lado: 46) {
                Picker("", selection: $filtro) {
                    ForEach(CNMovs.filtros.indices, id: \.self) { i in Text(CNMovs.filtros[i]).tag(i) }
                }
            }
        }
        .padding(.horizontal, 16).padding(.top, 10).padding(.bottom, 10)
        .background(CNC.scr.opacity(0.92))
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
        // El icono y el color los manda la web (la categoría puede no tener
        // icono propio y entonces manda su tabla por nombre): así la lista
        // nativa enseña exactamente los mismos que la PWA.
        let ic = datos.resumen?.catIconos[m.categoria]
        let tinte = entra ? CNC.pos : (m.esTransfer ? CNC.info
                                       : (ic.map { cnColor(hexString: $0.color) } ?? cnColor(0xe0a92e)))
        return Button { datos.onDetalleMov(m.id) } label: {
            HStack(spacing: 12) {
                Group {
                    if entra {
                        cnGlifo("banknote.fill", tam: 17)
                    } else if m.esTransfer {
                        cnGlifo("arrow.left.arrow.right", tam: 17)
                    } else if let p = ic?.path, !p.isEmpty {
                        CNSVGShape(d: p)
                            .stroke(style: StrokeStyle(lineWidth: 1.9, lineCap: .round, lineJoin: .round))
                            .frame(width: 18, height: 18)
                    } else {
                        cnGlifo("tag.fill", tam: 17)
                    }
                }
                .foregroundColor(tinte)
                .frame(width: 34, height: 34)
                .background(tinte.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
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
        // Mantener pulsado: las mismas acciones, en el menú del sistema.
        .contextMenu {
            Button { datos.onDetalleMov(m.id) } label: { Label("Ver detalle", systemImage: "doc.text.magnifyingglass") }
            Button { datos.onAccion("editarMov", m.id) } label: { Label("Editar", systemImage: "pencil") }
            Button(role: .destructive) { datos.onBorrarMov(m.id) } label: { Label("Eliminar", systemImage: "trash") }
        }
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

}

/// La franja de color de la cabecera: la misma en Movimientos, Cuentas y Plan,
/// para que las pantallas nativas y las de la web se lean como una sola app.
struct CNFranja<Acciones: View, Debajo: View>: View {
    let titulo: String
    @ViewBuilder var acciones: () -> Acciones
    @ViewBuilder var debajo: () -> Debajo
    var body: some View {
        VStack(spacing: 11) {
            HStack(alignment: .center, spacing: 10) {
                Text(titulo).font(.system(size: 26, weight: .heavy)).foregroundColor(.white)
                    .lineLimit(1).minimumScaleFactor(0.8)
                Spacer(minLength: 8)
                acciones()
            }
            debajo()
        }
        .padding(.horizontal, 16).padding(.top, 4).padding(.bottom, 14)
        .background(CNC.side.ignoresSafeArea(edges: .top))
    }
}

/// El botón redondo de acción principal («+»), en vidrio tintado con el acento.
struct CNCirculoAcento: View {
    let icono: String
    var accion: () -> Void
    var body: some View {
        Button(action: accion) {
            Image(systemName: icono).font(.system(size: 20, weight: .semibold))
                .foregroundColor(CNC.sobreAcc)
                .frame(width: 46, height: 46)
                .cnVidrio(Circle(), tinte: CNC.acc)
                .shadow(color: CNC.acc.opacity(0.35), radius: 10, y: 4)
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
    /// Lo pone el contenedor: repinta la barra de UIKit cuando la web avisa de
    /// un cambio (pestaña activa, títulos, tema).
    var alRepintar: () -> Void = {}
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

/// EL MENÚ, con un `UITabBar` de VERDAD.
///
/// En iOS 26 los controles de UIKit traen el Liquid Glass del sistema: la lente
/// que se desliza hasta la pestaña elegida, el brillo de los bordes y el
/// morfeo al hacer scroll. Una barra dibujada a mano (aunque se meta dentro de
/// un UIVisualEffectView) NO tiene nada de eso: se ve como cristal, pero está
/// quieta. Es la misma solución que en Batuta.
/// Quién manda si la barra de abajo va entera o encogida.
///
/// Todas las pantallas nativas le cuentan cuánto se ha rodado; al bajar se
/// encoge (los rótulos se van y queda solo el icono) y al subir vuelve a su
/// tamaño, como hacen las apps del teléfono.
final class CNScrollEstado {
    static let shared = CNScrollEstado()
    private var ultimo: CGFloat = 0
    private(set) var compacto = false
    var alCambiar: (Bool) -> Void = { _ in }

    func mirar(_ y: CGFloat) {
        // Arriba del todo, siempre entera.
        if y <= 4 { poner(false); ultimo = y; return }
        if y > ultimo + 6 { poner(true); ultimo = y }
        else if y < ultimo - 6 { poner(false); ultimo = y }
    }
    func reiniciar() { ultimo = 0; poner(false) }
    private func poner(_ v: Bool) {
        guard v != compacto else { return }
        compacto = v
        alCambiar(v)
    }
}

final class CNBarraNativa: NSObject, UITabBarDelegate {
    let barra = UITabBar()
    private var ids: [String] = []
    private var conTitulos = true
    /// Encogida: solo iconos, y más baja.
    private var compacto = false
    private var altoC: NSLayoutConstraint?
    private weak var anfitriona: UIView?
    var alTocar: (String) -> Void = { _ in }

    func montar(en vista: UIView) {
        barra.translatesAutoresizingMaskIntoConstraints = false
        barra.delegate = self
        vista.addSubview(barra)
        // El alto a mano. Una UITabBar SUELTA (fuera de un UITabBarController)
        // recibe el margen seguro de abajo pero NO lo suma a su alto: se queda
        // en 49 pt, le descuenta los 34 del indicador y deja 15 para el
        // contenido; ahí es donde el rótulo se subía encima del icono.
        let alto = barra.heightAnchor.constraint(equalToConstant: 49)
        altoC = alto
        anfitriona = vista
        NSLayoutConstraint.activate([
            barra.leadingAnchor.constraint(equalTo: vista.leadingAnchor),
            barra.trailingAnchor.constraint(equalTo: vista.trailingAnchor),
            barra.bottomAnchor.constraint(equalTo: vista.bottomAnchor),
            alto
        ])
        rehacer()
        ajustar()
    }

    /// Hay que llamarla cuando cambie el margen seguro (al girar, al aparecer).
    func ajustar() {
        let abajo = anfitriona?.safeAreaInsets.bottom ?? 0
        let nuevo = (compacto ? 50 : (conTitulos ? 58 : 52)) + abajo
        if altoC?.constant != nuevo { altoC?.constant = nuevo }
    }

    /// Encoger o devolver la barra a su tamaño, con su animación.
    func compactar(_ on: Bool) {
        guard on != compacto else { return }
        compacto = on
        rehacer()
        ajustar()
        UIView.animate(withDuration: 0.24, delay: 0, options: [.curveEaseOut, .allowUserInteraction]) {
            self.anfitriona?.layoutIfNeeded()
        }
    }

    private func rehacer() {
        var items: [UITabBarItem] = []
        ids = []
        for (i, t) in CNTabs.todas.enumerated() {
            // Más grandes y más gruesos: en una barra de cinco, un trazo fino se
            // pierde. Encogida no llevan rótulo, así que ahí caben aún mejor.
            let img = cnIconoUIImage(t.path, lado: compacto ? 26 : 23, grosor: 2.6)
                .withRenderingMode(.alwaysTemplate)
            let rotulo = (conTitulos && !compacto) ? t.titulo : nil
            let item = UITabBarItem(title: rotulo, image: img, tag: i)
            item.accessibilityLabel = t.titulo
            item.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 11, weight: .semibold)], for: .normal)
            item.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 11, weight: .bold)], for: .selected)
            items.append(item); ids.append(t.id)
        }
        let antes = barra.selectedItem?.tag
        barra.setItems(items, animated: false)
        if let t = antes, t < items.count { barra.selectedItem = items[t] }
    }

    /// Pestaña activa, títulos y colores del tema.
    func pintar(activa: String, titulos: Bool) {
        if titulos != conTitulos { conTitulos = titulos; rehacer(); ajustar() }
        barra.tintColor = UIColor(CNC.pos)
        barra.overrideUserInterfaceStyle = CNC.tema.oscuro ? .dark : .light
        if let i = ids.firstIndex(of: activa), let items = barra.items, i < items.count,
           barra.selectedItem !== items[i] {
            barra.selectedItem = items[i]
        }
    }

    var alto: CGFloat { max(barra.frame.height, altoC?.constant ?? 49) }

    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard item.tag >= 0, item.tag < ids.count else { return }
        UISelectionFeedbackGenerator().selectionChanged()
        alTocar(ids[item.tag])
    }
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

/// Liquid Glass de VERDAD: UIVisualEffectView con UIGlassEffect (iOS 26).
///
/// El .glassEffect() de SwiftUI, dentro de un UIHostingController aislado, se
/// queda en un gris plano: no refracta lo que pasa por detrás. El de UIKit sí,
/// y es el mismo que usa la barra del menú.
struct CNVidrioUIKit: UIViewRepresentable {
    var tinte: UIColor? = nil
    func makeUIView(context: Context) -> UIVisualEffectView {
        var efecto: UIVisualEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        if #available(iOS 26.0, *) {
            let e = UIGlassEffect()
            e.isInteractive = true
            if let t = tinte { e.tintColor = t }
            efecto = e
        }
        let v = UIVisualEffectView(effect: efecto)
        v.isUserInteractionEnabled = false
        v.backgroundColor = .clear
        return v
    }
    func updateUIView(_ v: UIVisualEffectView, context: Context) {}
}

/// Liquid Glass en CUALQUIER forma (círculos de «+», cerrar, búsqueda, botones
/// de las hojas…), recortado a esa forma.
struct CNVidrioForma<S: Shape>: ViewModifier {
    let forma: S
    var tinte: Color? = nil
    func body(content: Content) -> some View {
        content.background(fondo)
    }
    @ViewBuilder private var fondo: some View {
        if let t = tinte {
            // Con color de marca: el color va pintado y el vidrio encima le pone
            // el brillo. Así el botón nunca sale gris, refracte o no el aparato.
            ZStack {
                forma.fill(t)
                CNVidrioUIKit().clipShape(forma).opacity(0.35)
            }
            .overlay(forma.stroke(Color.white.opacity(0.35), lineWidth: 0.8))
            .shadow(color: t.opacity(0.35), radius: 10, y: 4)
        } else {
            CNVidrioUIKit()
                .clipShape(forma)
                .overlay(forma.stroke(Color.white.opacity(0.22), lineWidth: 0.8))
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
        // El último control de una curva: lo necesitan S/s y T/t, que lo
        // reflejan en vez de repetirlo.
        var ctrl = CGPoint.zero
        let pt = { (x: CGFloat, y: CGFloat) in CGPoint(x: ox + x * s, y: oy + y * s) }
        let toks = tokenize(d); var i = 0
        func num() -> CGFloat { let v = toks[i].num; i += 1; return v }
        while i < toks.count {
            let t = toks[i]; guard t.isCmd else { i += 1; continue }
            let c = t.cmd; i += 1
            switch c {
            case "M", "m":
                var x = num(); var y = num(); if c == "m" { x += cur.x; y += cur.y }
                cur = CGPoint(x: x, y: y); start = cur; ctrl = cur; p.move(to: pt(cur.x, cur.y))
                while i < toks.count, !toks[i].isCmd {
                    var lx = num(); var ly = num(); if c == "m" { lx += cur.x; ly += cur.y }
                    cur = CGPoint(x: lx, y: ly); ctrl = cur; p.addLine(to: pt(cur.x, cur.y)) }
            case "L", "l":
                while i < toks.count, !toks[i].isCmd {
                    var x = num(); var y = num(); if c == "l" { x += cur.x; y += cur.y }
                    cur = CGPoint(x: x, y: y); ctrl = cur; p.addLine(to: pt(cur.x, cur.y)) }
            case "H", "h":
                while i < toks.count, !toks[i].isCmd { var x = num(); if c == "h" { x += cur.x }; cur.x = x; p.addLine(to: pt(cur.x, cur.y)) }
            case "V", "v":
                while i < toks.count, !toks[i].isCmd { var y = num(); if c == "v" { y += cur.y }; cur.y = y; p.addLine(to: pt(cur.x, cur.y)) }
            case "A", "a":
                while i < toks.count, !toks[i].isCmd {
                    let rx = num(); _ = num(); _ = num(); let large = num() != 0; let sweep = num() != 0
                    var x = num(); var y = num(); if c == "a" { x += cur.x; y += cur.y }
                    arco(&p, from: cur, to: CGPoint(x: x, y: y), r: rx, large: large, sweep: sweep, pt: pt)
                    cur = CGPoint(x: x, y: y); ctrl = cur }
            case "C", "c":
                while i < toks.count, !toks[i].isCmd {
                    var x1 = num(); var y1 = num(); var x2 = num(); var y2 = num(); var x = num(); var y = num()
                    if c == "c" { x1 += cur.x; y1 += cur.y; x2 += cur.x; y2 += cur.y; x += cur.x; y += cur.y }
                    p.addCurve(to: pt(x, y), control1: pt(x1, y1), control2: pt(x2, y2))
                    ctrl = CGPoint(x: x2, y: y2); cur = CGPoint(x: x, y: y) }
            case "S", "s":
                while i < toks.count, !toks[i].isCmd {
                    var x2 = num(); var y2 = num(); var x = num(); var y = num()
                    if c == "s" { x2 += cur.x; y2 += cur.y; x += cur.x; y += cur.y }
                    let r1 = CGPoint(x: 2 * cur.x - ctrl.x, y: 2 * cur.y - ctrl.y)
                    p.addCurve(to: pt(x, y), control1: pt(r1.x, r1.y), control2: pt(x2, y2))
                    ctrl = CGPoint(x: x2, y: y2); cur = CGPoint(x: x, y: y) }
            case "Q", "q":
                while i < toks.count, !toks[i].isCmd {
                    var x1 = num(); var y1 = num(); var x = num(); var y = num()
                    if c == "q" { x1 += cur.x; y1 += cur.y; x += cur.x; y += cur.y }
                    p.addQuadCurve(to: pt(x, y), control: pt(x1, y1))
                    ctrl = CGPoint(x: x1, y: y1); cur = CGPoint(x: x, y: y) }
            case "T", "t":
                while i < toks.count, !toks[i].isCmd {
                    var x = num(); var y = num(); if c == "t" { x += cur.x; y += cur.y }
                    let r1 = CGPoint(x: 2 * cur.x - ctrl.x, y: 2 * cur.y - ctrl.y)
                    p.addQuadCurve(to: pt(x, y), control: pt(r1.x, r1.y))
                    ctrl = r1; cur = CGPoint(x: x, y: y) }
            case "Z", "z": p.closeSubpath(); cur = start
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
/// Una acción del menú ⋯ de una pantalla de detalle.
struct CNAccion: Identifiable {
    let id = UUID()
    let texto: String
    let icono: String
    var peligro: Bool = false
    let hacer: () -> Void
}

struct CNDetCabecera: View {
    let inicial: String; let nombre: String; let sub: String
    var fondo: Color = CNC.side; var cuadro: Color = CNC.info; var volverA: String = "Cuentas"
    /// Acciones de la pantalla (editar, eliminar…): salen en el menú ⋯.
    var acciones: [CNAccion] = []
    var onClose: () -> Void
    var body: some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: 14)
            HStack(spacing: 12) {
                // Atrás y ⋯ en vidrio, como el resto de botones de la app.
                Button(action: onClose) {
                    HStack(spacing: 3) {
                        Image(systemName: "chevron.left").font(.system(size: 15, weight: .bold))
                        Text(volverA).font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.leading, 10).padding(.trailing, 14).frame(height: 38)
                    .cnVidrio(Capsule())
                }.buttonStyle(.plain)
                Spacer(minLength: 0)
                if !acciones.isEmpty {
                    Menu {
                        ForEach(acciones) { a in
                            Button(role: a.peligro ? .destructive : nil, action: a.hacer) {
                                Label(a.texto, systemImage: a.icono)
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                            .frame(width: 38, height: 38).cnVidrio(Circle())
                    }
                }
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
                .foregroundColor(CNC.sobreAcc).frame(maxWidth: .infinity).padding(.vertical, 15)
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
            CNDetCabecera(inicial: cnInicial(c?.nombre ?? "?"), nombre: c?.nombre ?? "Cuenta", sub: ((c?.banco.isEmpty ?? true) ? "Sin banco" : c!.banco) + " · \(movs.count) mov.", cuadro: cnColor(hexString: c?.color ?? "#137d41"),
                          acciones: [CNAccion(texto: "Editar cuenta", icono: "pencil") { datos.onAccion("editarCuenta", "\(cuentaId)") },
                                     CNAccion(texto: "Transferir", icono: "arrow.left.arrow.right") { datos.onAccion("transferir", "\(cuentaId)") },
                                     CNAccion(texto: "Eliminar cuenta", icono: "trash", peligro: true) { datos.onAccion("borrarCuenta", "\(cuentaId)") }],
                          onClose: onClose)
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
            CNDetCabecera(inicial: cnInicial(p?.nombre ?? "?"), nombre: p?.nombre ?? "Préstamo", sub: meDeben ? "Te debe" : "Le debes", fondo: cnColor(0x5a3fa0), cuadro: cnColor(0x825eb9),
                          acciones: [CNAccion(texto: "Editar préstamo", icono: "pencil") { datos.onAccion("editarPrestamo", "\(prestamoId)") },
                                     CNAccion(texto: "Eliminar préstamo", icono: "trash", peligro: true) { datos.onAccion("borrarPrestamo", "\(prestamoId)") }],
                          onClose: onClose)
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
            CNDetCabecera(inicial: cnInicial(t?.nombre ?? "?"), nombre: t?.nombre ?? "Tarjeta", sub: "Corte \(t?.corte ?? 0)", fondo: cnColor(0x9a3f3f), cuadro: CNC.neg,
                          acciones: [CNAccion(texto: "Editar tarjeta", icono: "pencil") { datos.onAccion("editarTarjeta", "\(tarjetaId)") },
                                     CNAccion(texto: "Eliminar tarjeta", icono: "trash", peligro: true) { datos.onAccion("borrarTarjeta", "\(tarjetaId)") }],
                          onClose: onClose)
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
            CNDetCabecera(inicial: "◎", nombre: m?.nombre ?? "Meta", sub: "Meta de ahorro", fondo: cnColor(0x5a3fa0), cuadro: cnColor(0x825eb9), volverA: "Plan",
                          acciones: [CNAccion(texto: "Editar meta", icono: "pencil") { datos.onAccion("editarMeta", "\(metaId)") },
                                     CNAccion(texto: "Eliminar meta", icono: "trash", peligro: true) { datos.onAccion("borrarMeta", "\(metaId)") }],
                          onClose: onClose)
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

/// Un color más oscuro del mismo tono, para el fondo de las cabeceras.
func cnOscurecer(_ c: Color, _ cuanto: CGFloat = 0.5) -> Color {
    var h: CGFloat = 0, sa: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    guard UIColor(c).getHue(&h, saturation: &sa, brightness: &b, alpha: &a) else { return c }
    return Color(UIColor(hue: h, saturation: min(1, sa * 1.05), brightness: max(0.12, b * (1 - cuanto)), alpha: 1))
}

/// El detalle de un movimiento. El modelo lo arma la web (rótulo, monto, icono
/// de la categoría y la lista de datos), así que esta pantalla y la de la PWA
/// dicen exactamente lo mismo.
struct CNMovDetalle {
    struct Dato: Identifiable { var id: Int; var label = ""; var valor = "" }
    var nombre = ""; var rotulo = ""; var montoFmt = ""; var color = ""
    var iconoPath = ""; var iconoColor = ""; var iconoBg = ""
    var puedeEditar = false; var textoEditar = "Editar"; var textoDuplicar = "Duplicar"
    var datos: [Dato] = []

    static func desde(json: String) -> CNMovDetalle? {
        guard let d = json.data(using: .utf8),
              let r = (try? JSONSerialization.jsonObject(with: d)) as? [String: Any] else { return nil }
        func s(_ o: [String: Any]?, _ k: String) -> String { (o?[k] as? String) ?? "" }
        var m = CNMovDetalle()
        m.nombre = s(r, "nombre"); m.rotulo = s(r, "rotulo"); m.montoFmt = s(r, "montoFmt")
        m.color = s(r, "color"); m.iconoPath = s(r, "iconoPath")
        m.iconoColor = s(r, "iconoColor"); m.iconoBg = s(r, "iconoBg")
        m.puedeEditar = (r["puedeEditar"] as? Bool) ?? false
        m.textoEditar = s(r, "textoEditar").isEmpty ? "Editar" : s(r, "textoEditar")
        m.textoDuplicar = s(r, "textoDuplicar").isEmpty ? "Duplicar" : s(r, "textoDuplicar")
        m.datos = ((r["datos"] as? [[String: Any]]) ?? []).enumerated().map {
            Dato(id: $0.offset, label: s($0.element, "label"), valor: s($0.element, "valor"))
        }
        return m
    }
}

struct CNDetalleMov: View {
    @ObservedObject var datos: CNDatos
    let movId: String
    var onClose: () -> Void
    @State private var confirmarBorrar = false

    var body: some View {
        let m = datos.movDetalle ?? CNMovDetalle()
        return VStack(spacing: 0) {
            // Barra de arriba sencilla: atrás, el nombre y el menú. Sin franja
            // de color, como en la web.
            HStack(spacing: 10) {
                Button(action: onClose) {
                    Image(systemName: "chevron.left").font(.system(size: 16, weight: .bold))
                        .foregroundColor(CNC.ink).frame(width: 40, height: 40)
                        .background(CNC.soft, in: Circle())
                }.buttonStyle(CNPulsable())
                Spacer(minLength: 6)
                Text(m.nombre).font(.system(size: 17, weight: .bold)).foregroundColor(CNC.ink)
                    .lineLimit(1).truncationMode(.tail)
                Spacer(minLength: 6)
                Menu {
                    Button { datos.onAccion("editarMov", movId) } label: { Label(m.textoEditar, systemImage: "pencil") }
                    Button { datos.onMovAccion("duplicar") } label: { Label(m.textoDuplicar, systemImage: "plus.square.on.square") }
                    Button(role: .destructive) { confirmarBorrar = true } label: { Label("Eliminar", systemImage: "trash") }
                } label: {
                    Image(systemName: "ellipsis").font(.system(size: 16, weight: .bold))
                        .foregroundColor(CNC.ink).frame(width: 40, height: 40)
                        .background(CNC.soft, in: Circle())
                }
            }
            .padding(.horizontal, 16).padding(.top, 6).padding(.bottom, 10)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    // Cuánto y de qué es.
                    HStack(spacing: 14) {
                        if !m.iconoPath.isEmpty {
                            CNSVGShape(d: m.iconoPath)
                                .stroke(style: StrokeStyle(lineWidth: 1.9, lineCap: .round, lineJoin: .round))
                                .foregroundColor(m.iconoColor.isEmpty ? CNC.pmut : cnColor(hexString: m.iconoColor))
                                .frame(width: 22, height: 22).frame(width: 46, height: 46)
                                .background(m.iconoBg.isEmpty ? CNC.soft : cnColor(hexString: m.iconoBg))
                                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(m.rotulo.uppercased()).font(.system(size: 11.5, weight: .heavy)).tracking(0.8)
                                .foregroundColor(CNC.pmut)
                            Text(m.montoFmt).font(.system(size: 30, weight: .heavy))
                                .foregroundColor(m.color.isEmpty ? CNC.ink : cnColor(hexString: m.color))
                                .lineLimit(1).minimumScaleFactor(0.6)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(16).tarjetaCN()

                    if m.puedeEditar {
                        HStack(spacing: 12) {
                            Button { datos.onAccion("editarMov", movId) } label: {
                                Text(m.textoEditar).font(.system(size: 15, weight: .bold))
                                    .foregroundColor(CNC.sobreAcc)
                                    .frame(maxWidth: .infinity).padding(.vertical, 15)
                                    .background(CNC.acc, in: Capsule())
                            }.buttonStyle(CNPulsable())
                            Button { datos.onMovAccion("duplicar") } label: {
                                Text(m.textoDuplicar).font(.system(size: 15, weight: .bold))
                                    .foregroundColor(CNC.ink)
                                    .frame(maxWidth: .infinity).padding(.vertical, 15)
                                    .background(CNC.card, in: Capsule())
                                    .overlay(Capsule().stroke(CNC.line, lineWidth: 1))
                            }.buttonStyle(CNPulsable())
                        }
                    }

                    VStack(spacing: 0) {
                        ForEach(m.datos) { d in
                            HStack {
                                Text(d.label).font(.system(size: 15)).foregroundColor(CNC.pmut)
                                Spacer(minLength: 10)
                                Text(d.valor).font(.system(size: 15, weight: .bold)).foregroundColor(CNC.ink)
                                    .multilineTextAlignment(.trailing).lineLimit(2)
                            }
                            .padding(.horizontal, 16).padding(.vertical, 14)
                            .overlay(alignment: .bottom) {
                                if d.id < m.datos.count - 1 {
                                    Rectangle().fill(CNC.soft).frame(height: 0.5).padding(.horizontal, 16)
                                }
                            }
                        }
                    }
                    .background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(CNC.line, lineWidth: 1))
                    Color.clear.frame(height: 40)
                }
                .padding(.horizontal, 16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(CNC.scr.ignoresSafeArea())
        .alert("¿Eliminar movimiento?", isPresented: $confirmarBorrar) {
            Button("Cancelar", role: .cancel) {}
            Button("Eliminar", role: .destructive) { datos.onBorrarMov(movId); onClose() }
        } message: { Text("Esto revierte su efecto en los saldos. No se puede deshacer.") }
    }
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
        VStack(spacing: 0) {
                CNHojaCabecera(titulo: editar == nil ? "Nuevo movimiento" : "Editar movimiento",
                               guardarTexto: "Guardar", onClose: onClose, onGuardar: guardar)
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        pildoras
                        CNMontoCampo(monto: $monto)
                        grupo { TextField("Descripción o concepto", text: $concepto).font(.system(size: 16)).foregroundColor(CNC.ink).padding(.horizontal, 15).padding(.vertical, 13) }
                        VStack(spacing: 6) {
                            titulo("Cuándo y de dónde")
                            grupo {
                                HStack(spacing: 12) { cuadro("calendar", CNC.neg); Text("Fecha").font(.system(size: 16)).foregroundColor(CNC.ink); Spacer(); DatePicker("", selection: $fecha, displayedComponents: .date).labelsHidden() }.padding(.horizontal, 14).padding(.vertical, 7)
                                divi()
                                menuFila("banknote.fill", CNC.info, "Pagado con", cuentaNombre) { ForEach(datos.libreta.cuentas) { c in Button(c.nombre) { cuentaId = c.id } } }
                            }
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            titulo("Categoría")
                            CNChipsCategoria(datos: datos, categoria: $categoria)
                        }
                        grupo { HStack(spacing: 12) {
                            cuadro("repeat", cnColor(0x825eb9))
                            VStack(alignment: .leading, spacing: 1) {
                                Text("Repetir cada mes").font(.system(size: 16)).foregroundColor(CNC.ink)
                                Text("Para lo que pagas siempre: renta, luz, colegio")
                                    .font(.system(size: 12)).foregroundColor(CNC.pmut).lineLimit(2)
                            }
                            Spacer(minLength: 6)
                            Toggle("", isOn: $repetir).labelsHidden().tint(CNC.pos)
                        }.padding(.horizontal, 14).padding(.vertical, 9) }
                        Color.clear.frame(height: 20)
                    }.padding(.horizontal, 16)
                }
                .cnTeclado()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(CNC.scr.ignoresSafeArea())
        .environment(\.locale, Locale(identifier: "es_DO"))
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

    private var pildoras: some View {
        HStack(spacing: 4) { ForEach(tipos.indices, id: \.self) { i in
            Text(tipos[i]).font(.system(size: 13.5, weight: i == tipo ? .bold : .semibold))
                .foregroundColor(i == tipo ? CNC.sobreAcc : CNC.pmut)
                .frame(maxWidth: .infinity).padding(.vertical, 9)
                .background(i == tipo ? AnyView(Capsule().fill(CNC.acc)) : AnyView(Color.clear))
                .onTapGesture { UISelectionFeedbackGenerator().selectionChanged(); tipo = i }
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

// ── Pantalla «Cuentas» NATIVA ───────────────────────────────────────────────
// El mismo contenido y el mismo orden que la web: cuentas, tarjetas (con su
// plástico) y préstamos. Lo que cambia es que la navegación, las acciones y los
// menús son de iOS.
/// Lo que enseña la pantalla de Cuentas, ya decorado por la web.
struct CNCuentasModelo {
    struct Fila: Identifiable {
        var id: Int { indice }
        var indice = 0; var nombre = ""; var detalle = ""; var valor = ""; var pie = ""
        var uso: Double = 0; var usoColor = ""
        var iconoPath = ""; var color = ""; var fondo = ""; var tintaValor = ""
    }
    struct Patrimonio {
        var titulo = ""; var valor = ""
        var activosLabel = ""; var activos = ""
        var pasivosLabel = ""; var pasivos = ""
        var fondo = ""; var tinta = ""
    }
    var titulo = "Cuentas"; var oculto = false
    var patrimonio = Patrimonio()
    var rotuloCuentas = "Cuentas"; var rotuloTarjetas = "Tarjetas de crédito"; var rotuloPrestamos = "Préstamos"
    var cuentas: [Fila] = []; var tarjetas: [Fila] = []; var prestamos: [Fila] = []

    static func desde(json: String) -> CNCuentasModelo? {
        guard let d = json.data(using: .utf8),
              let r = (try? JSONSerialization.jsonObject(with: d)) as? [String: Any] else { return nil }
        func s(_ o: [String: Any]?, _ k: String) -> String { (o?[k] as? String) ?? "" }
        func n(_ o: [String: Any]?, _ k: String) -> Double { ((o?[k] as? NSNumber)?.doubleValue) ?? 0 }
        func l(_ o: [String: Any]?, _ k: String) -> [[String: Any]] { (o?[k] as? [[String: Any]]) ?? [] }
        func filas(_ k: String) -> [Fila] {
            l(r, k).map {
                Fila(indice: Int(n($0, "indice")), nombre: s($0, "nombre"), detalle: s($0, "detalle"),
                     valor: s($0, "valor"), pie: s($0, "pie"), uso: n($0, "uso"), usoColor: s($0, "usoColor"),
                     iconoPath: s($0, "iconoPath"), color: s($0, "color"), fondo: s($0, "fondo"),
                     tintaValor: s($0, "tintaValor"))
            }
        }
        var m = CNCuentasModelo()
        m.titulo = s(r, "titulo").isEmpty ? "Cuentas" : s(r, "titulo")
        m.oculto = (r["oculto"] as? Bool) ?? false
        let p = r["patrimonio"] as? [String: Any]
        m.patrimonio = Patrimonio(titulo: s(p, "titulo"), valor: s(p, "valor"),
                                  activosLabel: s(p, "activosLabel"), activos: s(p, "activos"),
                                  pasivosLabel: s(p, "pasivosLabel"), pasivos: s(p, "pasivos"),
                                  fondo: s(p, "fondo"), tinta: s(p, "tinta"))
        m.rotuloCuentas = s(r, "rotuloCuentas"); m.rotuloTarjetas = s(r, "rotuloTarjetas")
        m.rotuloPrestamos = s(r, "rotuloPrestamos")
        m.cuentas = filas("cuentas"); m.tarjetas = filas("tarjetas"); m.prestamos = filas("prestamos")
        return m
    }
}

struct CNCuentas: View {
    @ObservedObject var datos: CNDatos

    var body: some View {
        let m = datos.cuentas ?? CNCuentasModelo()
        return ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                CNEspiaScroll { CNScrollEstado.shared.mirar($0) }.frame(height: 0)
                titulo(m)
                patrimonio(m.patrimonio, oculto: m.oculto)
                if !m.cuentas.isEmpty {
                    rotulo(m.rotuloCuentas)
                    grupo(m.cuentas, tipo: "cuenta")
                }
                if !m.tarjetas.isEmpty {
                    rotulo(m.rotuloTarjetas)
                    grupo(m.tarjetas, tipo: "tarjeta")
                }
                if !m.prestamos.isEmpty {
                    rotulo(m.rotuloPrestamos)
                    grupo(m.prestamos, tipo: "prestamo")
                }
                Color.clear.frame(height: 110)
            }
            .padding(.horizontal, 16).padding(.top, 2)
        }
        .background(CNC.scr.ignoresSafeArea())
    }

    private func titulo(_ m: CNCuentasModelo) -> some View {
        HStack(spacing: 10) {
            Text(m.titulo).font(.system(size: 28, weight: .heavy)).foregroundColor(CNC.ink)
            Spacer(minLength: 8)
            CNMenuVidrio(icono: "line.3.horizontal.decrease") {
                Button { datos.onTendencia() } label: { Label("Ver la tendencia", systemImage: "chart.line.uptrend.xyaxis") }
                Button { datos.onCuentasAccion("ocultar", 0) } label: {
                    Label(m.oculto ? "Enseñar el dinero" : "Ocultar el dinero", systemImage: m.oculto ? "eye" : "eye.slash")
                }
            }
            CNCirculoAcento(icono: "plus") { datos.onAgregar() }
        }
    }

    private func rotulo(_ t: String) -> some View {
        Text(t.uppercased()).font(.system(size: 12, weight: .heavy)).tracking(0.8)
            .foregroundColor(CNC.pmut).padding(.leading, 4).padding(.top, 4)
    }

    /// La tarjeta oscura del patrimonio, con el ojo para tapar el dinero y el
    /// atajo a la tendencia.
    private func patrimonio(_ p: CNCuentasModelo.Patrimonio, oculto: Bool) -> some View {
        let tinta = p.tinta.isEmpty ? Color.white : cnColor(hexString: p.tinta)
        return VStack(spacing: 10) {
            HStack {
                Button { datos.onCuentasAccion("ocultar", 0) } label: {
                    Image(systemName: oculto ? "eye.slash" : "eye").font(.system(size: 15, weight: .semibold))
                        .foregroundColor(tinta).frame(width: 34, height: 34)
                        .background(Color.white.opacity(0.13), in: Circle())
                }.buttonStyle(CNPulsable())
                Spacer(minLength: 8)
                Text(p.titulo).font(.system(size: 14, weight: .semibold)).foregroundColor(tinta.opacity(0.9))
                Spacer(minLength: 8)
                Button { datos.onTendencia() } label: {
                    Image(systemName: "chart.line.uptrend.xyaxis").font(.system(size: 15, weight: .semibold))
                        .foregroundColor(tinta).frame(width: 34, height: 34)
                        .background(Color.white.opacity(0.13), in: Circle())
                }.buttonStyle(CNPulsable())
            }
            Text(p.valor).font(.system(size: 32, weight: .heavy)).foregroundColor(tinta)
                .lineLimit(1).minimumScaleFactor(0.5)
            HStack(spacing: 0) {
                VStack(spacing: 2) {
                    Text(p.activosLabel).font(.system(size: 12)).foregroundColor(tinta.opacity(0.75))
                    Text(p.activos).font(.system(size: 15, weight: .bold)).foregroundColor(tinta)
                        .lineLimit(1).minimumScaleFactor(0.7)
                }.frame(maxWidth: .infinity)
                VStack(spacing: 2) {
                    Text(p.pasivosLabel).font(.system(size: 12)).foregroundColor(tinta.opacity(0.75))
                    Text(p.pasivos).font(.system(size: 15, weight: .bold)).foregroundColor(tinta)
                        .lineLimit(1).minimumScaleFactor(0.7)
                }.frame(maxWidth: .infinity)
            }
            .padding(.top, 2)
        }
        .padding(16).frame(maxWidth: .infinity)
        .background(p.fondo.isEmpty ? CNC.side : cnColor(hexString: p.fondo))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func grupo(_ filas: [CNCuentasModelo.Fila], tipo: String) -> some View {
        VStack(spacing: 0) {
            ForEach(filas) { f in
                Button { datos.onCuentasAccion(tipo, f.indice) } label: {
                    HStack(spacing: 12) {
                        CNSVGShape(d: f.iconoPath)
                            .stroke(style: StrokeStyle(lineWidth: 1.9, lineCap: .round, lineJoin: .round))
                            .foregroundColor(f.color.isEmpty ? CNC.pmut : cnColor(hexString: f.color))
                            .frame(width: 19, height: 19).frame(width: 38, height: 38)
                            .background(f.fondo.isEmpty ? CNC.soft : cnColor(hexString: f.fondo))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        VStack(alignment: .leading, spacing: 3) {
                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Text(f.nombre).font(.system(size: 15.5, weight: .bold))
                                    .foregroundColor(CNC.ink).lineLimit(1)
                                Spacer(minLength: 6)
                                Text(f.valor).font(.system(size: 15.5, weight: .bold))
                                    .foregroundColor(f.tintaValor.isEmpty ? CNC.ink : cnColor(hexString: f.tintaValor))
                                    .lineLimit(1)
                            }
                            if !f.detalle.isEmpty {
                                Text(f.detalle).font(.system(size: 12)).foregroundColor(CNC.pmut).lineLimit(1)
                            }
                            if !f.pie.isEmpty {
                                CNBarraProgreso(parte: f.uso / 100,
                                                color: f.usoColor.isEmpty ? CNC.pos : cnColor(hexString: f.usoColor),
                                                alto: 5)
                                    .padding(.top, 1)
                                Text(f.pie).font(.system(size: 11.5)).foregroundColor(CNC.pmut).lineLimit(1)
                            }
                        }
                        Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold))
                            .foregroundColor(CNC.pmut.opacity(0.5))
                    }
                    .padding(.horizontal, 14).padding(.vertical, 12).contentShape(Rectangle())
                    .overlay(alignment: .bottom) {
                        if f.indice < filas.count - 1 {
                            Rectangle().fill(CNC.soft).frame(height: 0.5).padding(.leading, 64)
                        }
                    }
                }.buttonStyle(CNPulsable())
            }
        }
        .background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(CNC.line, lineWidth: 1))
    }
}

// ── Pantalla «Plan» NATIVA (presupuesto y metas) ────────────────────────────
struct CNPlan: View {
    @ObservedObject var datos: CNDatos
    @State private var pestana = 0
    @State private var editando: CNCatEnEdicion? = nil

    var body: some View {
        let lb = datos.libreta
        return VStack(spacing: 0) {
            CNCabeceraApp(c: datos.resumen?.cabecera ?? CNResumenModelo.Cabecera(),
                          onLibreta: { datos.onSelector() }, onMes: { datos.onMes($0) },
                          onCalendario: { datos.onCalendario() },
                          onMesTira: { datos.onMesTira($0) },
                          onPlegar: { datos.onPlegar() })
            ScrollView(showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 12) {
                    CNEspiaScroll { CNScrollEstado.shared.mirar($0) }.frame(height: 0)
                    HStack(spacing: 10) {
                        CNSegmentado(opciones: ["Presupuesto", "Metas"], elegida: $pestana)
                        CNCirculoAcento(icono: "plus") {
                            if pestana == 0 { datos.onNuevaCategoria() } else { datos.onNuevaMeta() }
                        }
                    }
                    if pestana == 0 { presupuesto(lb) } else { metas(lb) }
                    Color.clear.frame(height: 110)
                }
                .padding(.horizontal, 16).padding(.top, 14)
            }
        }
        .background(CNC.scr.ignoresSafeArea())
        // Cambiar el límite de una categoría, en una hoja pequeña del sistema.
        .sheet(item: $editando) { cat in
            CNLimiteHoja(nombre: cat.nombre, limite: cat.limite, onClose: { editando = nil }) { nuevo in
                datos.onLimiteCategoria(cat.nombre, nuevo)
                editando = nil
            }
        }
    }

    // MARK: presupuesto
    @ViewBuilder private func presupuesto(_ lb: CNLibreta) -> some View {
        let total = lb.presupuestoTotal
        let gastado = lb.gastosMes
        let parte = total > 0 ? min(1, gastado / total) : 0
        let color: Color = parte > 1 ? CNC.neg : (parte > 0.85 ? CNC.acc : CNC.pos)
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                Text("Gastado este mes").font(.system(size: 12)).foregroundColor(CNC.pmut)
                Spacer(minLength: 8)
                // Sin límites puestos, «de RD$0» no dice nada: se enseña solo lo
                // gastado.
                Text(total > 0 ? "\(cnDinero(gastado)) de \(cnDinero(total))" : cnDinero(gastado))
                    .font(.system(size: 12, weight: .bold)).foregroundColor(total > 0 ? color : CNC.ink)
                    .lineLimit(1).minimumScaleFactor(0.7)
            }
            if total > 0 { CNBarraProgreso(parte: parte, color: color, alto: 10) }
            Text(total <= 0 ? "Ponle un límite a tus categorías y aquí verás cómo vas."
                            : (gastado > total ? "Te pasaste por \(cnDinero(gastado - total))."
                                               : "Te quedan \(cnDinero(total - gastado)) para este mes."))
                .font(.system(size: 11.5)).foregroundColor(CNC.pmut).fixedSize(horizontal: false, vertical: true)
        }
        .tarjetaCN()

        let gastos = lb.categorias.filter { $0.tipo == "Gasto" }
        if gastos.isEmpty {
            cnVacioCard("Sin categorías", "Crea la primera para empezar a repartir el mes.")
        }
        ForEach(gastos, id: \.nombre) { c in filaCategoria(c, lb) }
    }

    private func filaCategoria(_ c: CNCategoria, _ lb: CNLibreta) -> some View {
        let gastado = lb.gastadoCategoria(c.nombre)
        let parte = c.limite > 0 ? min(1, gastado / c.limite) : 0
        let cc = cnColor(hexString: c.color)
        let color: Color = c.limite > 0 && gastado > c.limite ? CNC.neg : (parte > 0.85 ? CNC.acc : cc)
        return VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 10) {
                cnGlifo(c.icono, tam: 17, grosor: 1.9).foregroundColor(cc)
                    .frame(width: 32, height: 32).background(cc.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                Text(c.nombre).font(.system(size: 13.5, weight: .semibold)).foregroundColor(CNC.ink).lineLimit(1)
                Spacer(minLength: 8)
                Text(c.limite > 0 ? cnDinero(c.limite) : "Sin límite")
                    .font(.system(size: 13, weight: .bold)).foregroundColor(c.limite > 0 ? CNC.ink : CNC.pmut)
                Menu {
                    Button { editando = CNCatEnEdicion(nombre: c.nombre, limite: c.limite) } label: {
                        Label("Cambiar límite", systemImage: "slider.horizontal.3")
                    }
                    Button { datos.onAccion("categoria", c.nombre) } label: { Label("Ver la categoría", systemImage: "chart.bar") }
                } label: {
                    Image(systemName: "ellipsis").font(.system(size: 14, weight: .bold)).foregroundColor(CNC.pmut)
                        .frame(width: 30, height: 30).background(CNC.soft)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
            if c.limite > 0 { CNBarraProgreso(parte: parte, color: color, alto: 8) }
            HStack {
                Text("\(cnDinero(gastado)) gastado").font(.system(size: 11)).foregroundColor(CNC.pmut)
                Spacer(minLength: 8)
                if c.limite > 0 {
                    Text(gastado > c.limite ? "Te pasaste \(cnDinero(gastado - c.limite))" : "Quedan \(cnDinero(c.limite - gastado))")
                        .font(.system(size: 11, weight: .bold)).foregroundColor(color)
                }
            }
        }
        .tarjetaCN()
    }

    // MARK: metas
    @ViewBuilder private func metas(_ lb: CNLibreta) -> some View {
        if lb.metas.isEmpty {
            cnVacioCard("Sin metas", "Una meta es un ahorro con nombre y fecha. Toca + para crear la primera.")
        }
        ForEach(lb.metas) { g in
            let color = cnColor(hexString: g.color)
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 11) {
                    RoundedRectangle(cornerRadius: 4, style: .continuous).fill(color).frame(width: 7, height: 34)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(g.nombre).font(.system(size: 14, weight: .bold)).foregroundColor(CNC.ink).lineLimit(1)
                        Text("Meta \(cnDinero(g.meta))" + (g.mensual > 0 ? " · \(cnDinero(g.mensual))/mes" : ""))
                            .font(.system(size: 11)).foregroundColor(CNC.pmut)
                    }
                    Spacer(minLength: 6)
                    Text("\(Int(g.progreso * 100))%").font(.system(size: 13, weight: .heavy)).foregroundColor(color)
                }
                CNBarraProgreso(parte: g.progreso, color: color, alto: 9)
                HStack {
                    Text("Ahorrado \(cnDinero(g.ahorrado))").font(.system(size: 11)).foregroundColor(CNC.pmut)
                    Spacer(minLength: 8)
                    Text("Falta \(cnDinero(max(0, g.meta - g.ahorrado)))").font(.system(size: 11)).foregroundColor(CNC.pmut)
                }
                Button { datos.onAccion("aporte", "\(g.id)") } label: {
                    Text(g.mensual > 0 ? "Aportar \(cnDinero(g.mensual))" : "Aportar")
                        .font(.system(size: 13.5, weight: .bold)).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 12)
                        .background(color, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }.buttonStyle(CNPulsable())
            }
            .tarjetaCN()
            .contextMenu {
                Button { datos.onAbrirMeta(g.id) } label: { Label("Ver detalle", systemImage: "doc.text.magnifyingglass") }
                Button { datos.onAccion("aporte", "\(g.id)") } label: { Label("Aportar", systemImage: "plus.circle") }
            }
        }
    }
}

// ── Piezas compartidas de Cuentas y Plan ────────────────────────────────────
/// Barra de progreso con las esquinas del sistema y sin dependencias.
struct CNBarraProgreso: View {
    let parte: Double
    var color: Color = CNC.pos
    var alto: CGFloat = 8
    var body: some View {
        GeometryReader { g in
            ZStack(alignment: .leading) {
                Capsule().fill(CNC.soft)
                Capsule().fill(color).frame(width: max(0, min(1, parte)) * g.size.width)
            }
        }
        .frame(height: alto)
    }
}

/// Segmentado propio (no el de UIKit) para que viva sobre la franja de color.
struct CNSegmentado: View {
    let opciones: [String]
    @Binding var elegida: Int
    var body: some View {
        HStack(spacing: 4) {
            ForEach(opciones.indices, id: \.self) { i in
                let puesta = elegida == i
                Button {
                    UISelectionFeedbackGenerator().selectionChanged()
                    withAnimation(.easeOut(duration: 0.18)) { elegida = i }
                } label: {
                    Text(opciones[i]).font(.system(size: 13.5, weight: .bold))
                        .foregroundColor(puesta ? CNC.sobreAcc : CNC.pmut)
                        .frame(maxWidth: .infinity).padding(.vertical, 10)
                        .background(puesta ? AnyView(Capsule().fill(CNC.acc)) : AnyView(Color.clear))
                }.buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(CNC.soft, in: Capsule())
        .overlay(Capsule().stroke(CNC.line, lineWidth: 1))
    }
}

/// Dos iniciales, como en la web («Cuenta de la casa» → CD).
func cnIniciales(_ s: String) -> String {
    let p = s.split(separator: " ").prefix(2).compactMap { $0.first }
    return String(p).uppercased()
}

/// Tarjeta de «aquí no hay nada todavía», con su porqué.
func cnVacioCard(_ titulo: String, _ texto: String) -> some View {
    VStack(spacing: 5) {
        Text(titulo).font(.system(size: 14.5, weight: .bold)).foregroundColor(CNC.ink)
        Text(texto).font(.system(size: 12.5)).foregroundColor(CNC.pmut)
            .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
    }
    .frame(maxWidth: .infinity).padding(.vertical, 22).padding(.horizontal, 16)
    .background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    .overlay(RoundedRectangle(cornerRadius: 16).stroke(CNC.line, style: StrokeStyle(lineWidth: 1, dash: [5, 4])))
}

/// La categoría cuyo límite se está cambiando.
struct CNCatEnEdicion: Identifiable {
    var id: String { nombre }
    let nombre: String
    let limite: Double
}

/// Hoja pequeña para poner el límite mensual de una categoría.
struct CNLimiteHoja: View {
    let nombre: String
    let limite: Double
    var onClose: () -> Void
    var onGuardar: (Double) -> Void
    @State private var texto = ""
    var body: some View {
        CNHoja(titulo: "Límite de \(nombre)", onClose: onClose,
               onGuardar: { onGuardar(Double(texto.replacingOccurrences(of: ",", with: "")) ?? 0) }) {
            CNMontoCampo(monto: $texto, paso: 500)
            Text("Cuánto quieres gastar al mes en esta categoría. Déjalo en 0 para no ponerle tope.")
                .font(.system(size: 12.5)).foregroundColor(CNC.pmut)
                .fixedSize(horizontal: false, vertical: true).padding(.horizontal, 4)
        }
        .onAppear { if limite > 0 { texto = String(Int(limite)) } }
    }
}

// ── Pantalla «Resumen» NATIVA ───────────────────────────────────────────────
// El panel es configurable (tipos de tarjeta, tamaños, orden), así que el
// modelo lo calcula la WEB —la misma lógica de dinero de siempre— y aquí solo
// se DIBUJA, con las mismas medidas, colores y textos. Sin reimplementar nada.

struct CNResumenModelo {
    struct Parada { var color = ""; var pos: Double = 0 }
    struct Fondo { var tipo = "color"; var color = ""; var angulo: Double = 180; var paradas: [Parada] = [] }
    struct MesTira { var indice = 0; var label = ""; var puesto = false; var bg = ""; var fg = "" }
    struct Cabecera {
        var inicial = ""; var nombre = ""; var detalle = ""; var color = ""; var icono = ""
        var mesCorto = ""; var balanceRotulo = ""; var balanceFmt = ""; var balColor = ""
        var ingRotulo = ""; var ingFmt = ""; var gasRotulo = ""; var gasFmt = ""
        /// auto · fina · clara · minima · clasica · detallada
        var diseno = "auto"
        var tarjeta = false
        var fondo = Fondo(); var tinta = ""; var gris = ""; var pastilla = ""; var pastillaFuerte = ""
        var rotulo = ""; var mesLargo = ""; var periodoCorto = ""
        var grande = false
        var entraFmt = ""; var saleFmt = ""
        var hayUso = false; var usado: Double = 0; var usadoLabel = ""; var usadoColor = ""
        var abierta = true
        var positivo = ""; var negativo = ""
        var meses: [MesTira] = []
    }
    struct Punto { var x: Double = 0; var y: Double = 0; var color = "" }
    struct Barra { var x: Double = 0; var y: Double = 0; var w: Double = 0; var h: Double = 0; var color = "" }
    struct Guia { var y: Double = 0; var color = "" }
    struct Traza { var puntos = ""; var color = "" }
    struct Serie { var label = ""; var color = ""; var ultimo = "" }
    struct FilaBarra { var label = ""; var valor = ""; var pct: Double = 0; var color = ""; var iconoPath = ""; var iconoBg = "" }
    struct Columna { var label = ""; var a: Double = 0; var b: Double = 0; var peso: Double = 500; var color = "" }
    struct Tramo { var color = ""; var desde: Double = 0; var hasta: Double = 0 }
    struct FilaDona { var label = ""; var valor = ""; var color = "" }
    struct Item {
        var tieneIcono = false; var iconoPath = ""; var color = ""; var fondo = ""
        var sigla = ""; var siglaColor = ""; var titulo = ""; var detalle = ""
        var monto = ""; var montoColor = ""
    }
    struct Opcion { var id = ""; var label = "" }
    struct SerieCfg { var id = ""; var label = ""; var color = ""; var puesta = false }
    struct Widget: Identifiable {
        var id: Int { indice }
        var indice = 0; var titulo = ""; var periodo = ""; var chica = false; var oculta = false
        /// La entrada del panel a la que corresponde (para poder editarla).
        var wid = ""; var ancho = 2; var puedeChica = false
        var cfgGrafico = "linea"; var cfgRango = "12"; var series: [SerieCfg] = []
        var clase = "texto"
        var valor = ""; var nota = ""; var color = ""
        var texto = ""
        var leyenda: [Serie] = []; var guias: [Guia] = []; var areas: [Traza] = []
        var lineas: [Traza] = []; var barras: [Barra] = []; var puntos: [Punto] = []
        var etiquetas: [String] = []
        var filas: [FilaBarra] = []; var rotuloPresupuesto = ""; var vaAlPresupuesto = false
        var rotuloEntra = ""; var rotuloSale = ""; var hayMedia = false; var media: Double = 0
        var entraColor = ""; var saleColor = ""; var columnas: [Columna] = []
        var total = ""; var tramos: [Tramo] = []; var filasDona: [FilaDona] = []
        var items: [Item] = []
    }
    var cabecera = Cabecera()
    var vacio = false; var vacioTitulo = ""; var vacioTexto = ""; var vacioBoton = ""
    var widgets: [Widget] = []
    var tiposGrafico: [Opcion] = []; var rangosGrafico: [Opcion] = []; var catalogo: [Opcion] = []
    /// nombre de categoría → (trazo del icono, color). Los mismos que la web.
    struct IconoCat { var path = ""; var color = "" }
    var catIconos: [String: IconoCat] = [:]

    // Se lee a mano (no con Decodable): así un campo que falte o que cambie de
    // forma —la dona reusa «filas» con otra— no tira toda la pantalla abajo.
    static func desde(json: String) -> CNResumenModelo? {
        guard let d = json.data(using: .utf8),
              let raiz = (try? JSONSerialization.jsonObject(with: d)) as? [String: Any] else { return nil }
        func s(_ o: [String: Any]?, _ k: String) -> String { (o?[k] as? String) ?? "" }
        func n(_ o: [String: Any]?, _ k: String) -> Double { ((o?[k] as? NSNumber)?.doubleValue) ?? 0 }
        func b(_ o: [String: Any]?, _ k: String) -> Bool { (o?[k] as? Bool) ?? false }
        func lista(_ o: [String: Any]?, _ k: String) -> [[String: Any]] { (o?[k] as? [[String: Any]]) ?? [] }

        var m = CNResumenModelo()
        let c = raiz["cabecera"] as? [String: Any]
        var cab = Cabecera()
        cab.inicial = s(c, "inicial"); cab.nombre = s(c, "nombre"); cab.detalle = s(c, "detalle")
        cab.color = s(c, "color"); cab.icono = s(c, "icono"); cab.mesCorto = s(c, "mesCorto")
        cab.balanceRotulo = s(c, "balanceRotulo"); cab.balanceFmt = s(c, "balanceFmt"); cab.balColor = s(c, "balColor")
        cab.ingRotulo = s(c, "ingRotulo"); cab.ingFmt = s(c, "ingFmt")
        cab.gasRotulo = s(c, "gasRotulo"); cab.gasFmt = s(c, "gasFmt")
        cab.diseno = s(c, "diseno").isEmpty ? "auto" : s(c, "diseno")
        cab.tarjeta = b(c, "tarjeta"); cab.tinta = s(c, "tinta"); cab.gris = s(c, "gris")
        cab.pastilla = s(c, "pastilla"); cab.pastillaFuerte = s(c, "pastillaFuerte")
        cab.rotulo = s(c, "rotulo"); cab.mesLargo = s(c, "mesLargo"); cab.periodoCorto = s(c, "periodoCorto")
        cab.grande = b(c, "grande"); cab.entraFmt = s(c, "entraFmt"); cab.saleFmt = s(c, "saleFmt")
        cab.hayUso = b(c, "hayUso"); cab.usado = n(c, "usado"); cab.usadoLabel = s(c, "usadoLabel")
        cab.usadoColor = s(c, "usadoColor"); cab.abierta = (c?["abierta"] as? Bool) ?? true
        cab.positivo = s(c, "positivo"); cab.negativo = s(c, "negativo")
        if let f = c?["fondo"] as? [String: Any] {
            cab.fondo = Fondo(tipo: s(f, "tipo"), color: s(f, "color"), angulo: n(f, "angulo"),
                              paradas: ((f["paradas"] as? [[String: Any]]) ?? []).map {
                                  Parada(color: s($0, "color"), pos: n($0, "pos")) })
        }
        cab.meses = ((c?["meses"] as? [[String: Any]]) ?? []).map {
            MesTira(indice: Int(n($0, "indice")), label: s($0, "label"), puesto: b($0, "puesto"),
                    bg: s($0, "bg"), fg: s($0, "fg"))
        }
        m.cabecera = cab
        m.vacio = b(raiz, "vacio"); m.vacioTitulo = s(raiz, "vacioTitulo")
        m.vacioTexto = s(raiz, "vacioTexto"); m.vacioBoton = s(raiz, "vacioBoton")

        if let ic = raiz["catIconos"] as? [String: [String: Any]] {
            for (k, v) in ic { m.catIconos[k] = IconoCat(path: s(v, "path"), color: s(v, "color")) }
        }
        m.tiposGrafico = lista(raiz, "tiposGrafico").map { Opcion(id: s($0, "id"), label: s($0, "label")) }
        m.rangosGrafico = lista(raiz, "rangosGrafico").map { Opcion(id: s($0, "id"), label: s($0, "label")) }
        m.catalogo = lista(raiz, "catalogo").map { Opcion(id: s($0, "id"), label: s($0, "label")) }
        m.widgets = lista(raiz, "widgets").map { w in
            var x = Widget()
            x.indice = Int(n(w, "indice")); x.titulo = s(w, "titulo"); x.periodo = s(w, "periodo")
            x.chica = b(w, "chica"); x.oculta = b(w, "oculta"); x.clase = s(w, "clase")
            x.wid = s(w, "wid"); x.ancho = Int(n(w, "ancho")); x.puedeChica = b(w, "puedeChica")
            x.cfgGrafico = s(w, "cfgGrafico"); x.cfgRango = s(w, "cfgRango")
            x.series = lista(w, "series").map { SerieCfg(id: s($0, "id"), label: s($0, "label"),
                                                        color: s($0, "color"), puesta: b($0, "puesta")) }
            x.valor = s(w, "valor"); x.nota = s(w, "nota"); x.color = s(w, "color"); x.texto = s(w, "texto")
            x.leyenda = lista(w, "leyenda").map { Serie(label: s($0, "label"), color: s($0, "color"), ultimo: s($0, "ultimo")) }
            x.guias = lista(w, "guias").map { Guia(y: n($0, "y"), color: s($0, "color")) }
            x.areas = lista(w, "areas").map { Traza(puntos: s($0, "puntos"), color: s($0, "color")) }
            x.lineas = lista(w, "lineas").map { Traza(puntos: s($0, "puntos"), color: s($0, "color")) }
            x.barras = lista(w, "barras").map { Barra(x: n($0, "x"), y: n($0, "y"), w: n($0, "w"), h: n($0, "h"), color: s($0, "color")) }
            x.puntos = lista(w, "puntos").map { Punto(x: n($0, "x"), y: n($0, "y"), color: s($0, "color")) }
            x.etiquetas = (w["etiquetas"] as? [String]) ?? []
            x.rotuloPresupuesto = s(w, "rotuloPresupuesto"); x.vaAlPresupuesto = b(w, "vaAlPresupuesto")
            x.rotuloEntra = s(w, "rotuloEntra"); x.rotuloSale = s(w, "rotuloSale")
            x.hayMedia = b(w, "hayMedia"); x.media = n(w, "media")
            x.entraColor = s(w, "entraColor"); x.saleColor = s(w, "saleColor")
            x.columnas = lista(w, "columnas").map { Columna(label: s($0, "label"), a: n($0, "a"), b: n($0, "b"), peso: n($0, "peso"), color: s($0, "color")) }
            x.total = s(w, "total")
            x.tramos = lista(w, "tramos").map { Tramo(color: s($0, "color"), desde: n($0, "desde"), hasta: n($0, "hasta")) }
            if x.clase == "dona" {
                x.filasDona = lista(w, "filas").map { FilaDona(label: s($0, "label"), valor: s($0, "valor"), color: s($0, "color")) }
            } else {
                x.filas = lista(w, "filas").map { FilaBarra(label: s($0, "label"), valor: s($0, "valor"), pct: n($0, "pct"), color: s($0, "color"), iconoPath: s($0, "iconoPath"), iconoBg: s($0, "iconoBg")) }
            }
            x.items = lista(w, "items").map {
                Item(tieneIcono: b($0, "tieneIcono"), iconoPath: s($0, "iconoPath"), color: s($0, "color"),
                     fondo: s($0, "fondo"), sigla: s($0, "sigla"), siglaColor: s($0, "siglaColor"),
                     titulo: s($0, "titulo"), detalle: s($0, "detalle"), monto: s($0, "monto"),
                     montoColor: s($0, "montoColor"))
            }
            return x
        }
        return m
    }
}

/// La cabecera de la app. Es la MISMA de la web: sus seis diseños, su paleta
/// (color o degradado), su modo tarjeta y, en la automática, el plegado al
/// rodar. El modelo lo manda la web ya resuelto; lo único que se calcula aquí
/// es lo que depende del scroll, porque el scroll es de esta pantalla.
struct CNCabeceraApp: View {
    let c: CNResumenModelo.Cabecera
    /// 0 = arriba del todo · 1 = plegada. Solo la automática lo usa.
    var progreso: Double = 1
    var onLibreta: () -> Void
    var onMes: (Int) -> Void
    var onCalendario: () -> Void = {}
    var onMesTira: (Int) -> Void = { _ in }
    var onPlegar: () -> Void = {}

    static let bloqueMeses: CGFloat = 114
    /// Lo que se deja por encima del contenido, ADEMÁS del margen seguro.
    ///
    /// El margen seguro de un iPhone con isla es más alto que la isla: hay unos
    /// diez puntos por debajo de ella que el sistema reserva y nadie usa. Ahí
    /// se veía una franja de color vacía entre la isla y la cápsula. Esto sube
    /// el contenido justo esos puntos —y solo en los aparatos que los tienen,
    /// porque en los de muesca el margen acaba donde acaba la muesca—, dejando
    /// unos pocos de aire para no pegarse a ella.
    private var padArriba: CGFloat {
        if c.tarjeta { return 10 }
        return 2 - max(0, cnMargenArriba() - 56)
    }
    private var tinta: Color { c.tinta.isEmpty ? .white : cnColor(hexString: c.tinta) }
    private var gris: Color { c.gris.isEmpty ? tinta.opacity(0.8) : cnColor(hexString: c.gris) }
    private var pastilla: Color { c.pastilla.isEmpty ? Color.white.opacity(0.13) : cnColor(hexString: c.pastilla) }
    private var pastillaFuerte: Color { c.pastillaFuerte.isEmpty ? Color.white.opacity(0.22) : cnColor(hexString: c.pastillaFuerte) }
    private var balColor: Color { c.balColor.isEmpty ? tinta : cnColor(hexString: c.balColor) }

    var body: some View {
        if c.tarjeta {
            // Modo tarjeta: flota con márgenes y esquinas muy redondeadas, y
            // sube a cubrir la isla dinámica.
            contenido
                .background(CNFondoCabecera(f: c.fondo, respaldo: CNC.side))
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .padding(.horizontal, 7).padding(.bottom, 6)
                .shadow(color: Color.black.opacity(0.28), radius: 13, y: 6)
        } else {
            // Pegada: el fondo sube por debajo de la barra de estado. Recortarlo
            // (aunque fuera con radio 0) le devolvía el margen seguro y dejaba
            // una franja del color de la pantalla encima.
            contenido
                .background(CNFondoCabecera(f: c.fondo, respaldo: CNC.side).ignoresSafeArea(edges: .top))
        }
    }

    @ViewBuilder private var contenido: some View {
        switch c.diseno {
        case "detallada": detallada
        case "clasica": clasica
        case "fina": fina
        case "clara": clara
        case "minima": minima
        default: automatica
        }
    }

    // MARK: piezas comunes
    private var cuadroLibreta: some View {
        Group {
            if !c.icono.isEmpty {
                CNSVGShape(d: c.icono)
                    .stroke(style: StrokeStyle(lineWidth: 2.1, lineCap: .round, lineJoin: .round))
                    .foregroundColor(.white).padding(5)
            } else {
                Text(c.inicial).font(.system(size: 11, weight: .bold)).foregroundColor(.white)
            }
        }
    }
    private func capsula<C: View>(alto: CGFloat = 40, @ViewBuilder _ dentro: () -> C) -> some View {
        dentro().padding(.horizontal, 12).frame(height: alto)
            .background(pastilla, in: Capsule())
    }
    private var chevron: some View {
        Image(systemName: "chevron.down").font(.system(size: 12, weight: .bold))
            .foregroundColor(tinta.opacity(0.8))
    }
    private func flechaMes(_ ic: String, _ lado: CGFloat = 36, _ tap: @escaping () -> Void) -> some View {
        Button(action: tap) {
            Image(systemName: ic).font(.system(size: 15, weight: .bold)).foregroundColor(tinta)
                .frame(width: lado, height: lado)
                .background(pastilla, in: Circle())
        }.buttonStyle(CNPulsable())
    }
    private var iconoCalendario: some View {
        Image(systemName: "calendar").font(.system(size: 17, weight: .medium))
            .foregroundColor(tinta.opacity(0.85))
    }

    // MARK: automática (la que se pliega al rodar)
    private var automatica: some View {
        GeometryReader { g in
            // Todo en CGFloat: mezclar Double y CGFloat aquí deja al compilador
            // sin saber qué operador usar.
            let p: CGFloat = CGFloat(max(0.0, min(1.0, progreso)))
            let ancho: CGFloat = g.size.width
            let anchoCap: CGFloat = min(240, 78 + CGFloat(c.nombre.count) * 8)
            let centro: CGFloat = (ancho - anchoCap) / 2
            let capX: CGFloat = centro + (14 - centro) * p
            let capMax: CGFloat = max(110, (ancho - 28) + ((ancho - 164) - (ancho - 28)) * min(1, p * 2))
            let blqAlto: CGFloat = CNCabeceraApp.bloqueMeses * (1 - p)
            let blqOpaco: Double = Double(max(0, 1 - p * 1.5))
            let blqEsc: CGFloat = 1 - 0.18 * p
            let chicoOpaco: Double = Double(max(0, (p - 0.5) / 0.5))
            VStack(spacing: 0) {
                ZStack(alignment: .topLeading) {
                    Color.clear.frame(height: 50)
                    HStack(spacing: 0) {
                        Spacer(minLength: 0)
                        Button(action: onCalendario) {
                            HStack(spacing: 10) {
                                VStack(alignment: .trailing, spacing: 0) {
                                    Text(c.balanceFmt).font(.system(size: 16, weight: .bold)).foregroundColor(balColor)
                                    Text(c.periodoCorto).font(.system(size: 10)).foregroundColor(tinta.opacity(0.75))
                                }
                                iconoCalendario
                            }
                        }
                        .buttonStyle(CNPulsable())
                        .opacity(chicoOpaco).allowsHitTesting(chicoOpaco > 0.6)
                    }
                    .padding(.trailing, 14).frame(height: 56)
                    Button(action: onLibreta) {
                        HStack(spacing: 8) {
                            cuadroLibreta.frame(width: 24, height: 24)
                                .background(pastillaFuerte, in: Circle())
                            Text(c.nombre).font(.system(size: 14, weight: .semibold)).foregroundColor(tinta)
                                .lineLimit(1)
                            chevron
                        }
                        .padding(.leading, 6).padding(.trailing, 14).padding(.vertical, 8)
                        .background(pastilla, in: Capsule())
                    }
                    .buttonStyle(CNPulsable())
                    .frame(maxWidth: capMax, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .offset(x: capX, y: 1)
                }
                VStack(spacing: 8) {
                    VStack(spacing: 2) {
                        Text(c.balanceFmt).font(.system(size: 36, weight: .bold)).foregroundColor(balColor)
                            .lineLimit(1).minimumScaleFactor(0.5)
                        Text(c.rotulo).font(.system(size: 12)).foregroundColor(tinta.opacity(0.8))
                    }
                    .scaleEffect(blqEsc, anchor: .top)
                    tiraMeses(ancho)
                }
                .frame(maxWidth: .infinity)
                .frame(height: max(0, blqAlto), alignment: .top)
                .opacity(blqOpaco)
                .clipped()
            }
            .padding(.bottom, 10).padding(.top, padArriba)
            .animation(.easeOut(duration: 0.2), value: progreso)
        }
        .frame(height: 50 + 10 + padArriba
               + CNCabeceraApp.bloqueMeses * CGFloat(1 - max(0.0, min(1.0, progreso))))
    }

    /// La tira de meses. Va centrada mientras quepa, y solo rueda si no cabe;
    /// dentro de un ScrollView horizontal hay que decirle el ancho a mano,
    /// porque ahí `maxWidth: .infinity` no significa «el de la pantalla».
    private func tiraMeses(_ ancho: CGFloat) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(c.meses, id: \.indice) { m in
                    Button { onMesTira(m.indice) } label: {
                        Text(m.label).font(.system(size: 13, weight: m.puesto ? .bold : .semibold))
                            .foregroundColor(m.fg.isEmpty ? tinta : cnColor(hexString: m.fg))
                            .padding(.horizontal, 13).padding(.vertical, 8)
                            .background(m.bg.isEmpty ? pastilla : cnColor(hexString: m.bg), in: Capsule())
                    }.buttonStyle(CNPulsable())
                }
            }
            .padding(.horizontal, 14)
            .frame(minWidth: max(0, ancho), alignment: .center)
        }
    }

    // MARK: detallada (no se pliega; entera en el resumen, corta en el resto)
    @ViewBuilder private var detallada: some View {
        VStack(alignment: .leading, spacing: 12) {
            if c.grande {
                HStack(spacing: 10) {
                    Button(action: onLibreta) {
                        HStack(spacing: 7) {
                            cuadroLibreta.frame(width: 26, height: 26)
                                .background(cnColor(hexString: c.color), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                            Text(c.nombre).font(.system(size: 15, weight: .bold)).foregroundColor(tinta).lineLimit(1)
                            chevron
                        }
                        .padding(.leading, 7).padding(.trailing, 11).padding(.vertical, 7)
                        .background(pastilla, in: Capsule())
                    }
                    .buttonStyle(CNPulsable())
                    .fixedSize(horizontal: true, vertical: false)
                    .layoutPriority(1)
                    flechaMes("chevron.left") { onMes(-1) }
                    Button(action: onCalendario) {
                        HStack(spacing: 6) {
                            Text(c.mesLargo).font(.system(size: 14, weight: .semibold)).foregroundColor(tinta).lineLimit(1)
                            chevron
                        }
                        .frame(maxWidth: .infinity).padding(.vertical, 8)
                        .background(pastilla, in: Capsule())
                    }.buttonStyle(CNPulsable())
                    flechaMes("chevron.right") { onMes(1) }
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(c.rotulo.uppercased()).font(.system(size: 11, weight: .bold)).tracking(1.1)
                        .foregroundColor(tinta.opacity(0.72))
                    Text(c.balanceFmt).font(.system(size: 34, weight: .bold)).foregroundColor(balColor)
                        .lineLimit(1).minimumScaleFactor(0.5)
                }
                if c.hayUso {
                    HStack(spacing: 10) {
                        GeometryReader { g in
                            ZStack(alignment: .leading) {
                                Capsule().fill(pastilla)
                                Capsule().fill(c.usadoColor.isEmpty ? CNC.acc : cnColor(hexString: c.usadoColor))
                                    .frame(width: g.size.width * CGFloat(min(100, c.usado) / 100))
                            }
                        }.frame(height: 7)
                        Text(c.usadoLabel).font(.system(size: 12, weight: .semibold))
                            .foregroundColor(tinta.opacity(0.85)).lineLimit(1)
                    }
                }
                HStack(spacing: 18) {
                    flecha("arrow.up", c.positivo, c.entraFmt)
                    flecha("arrow.down", c.negativo, c.saleFmt)
                    Spacer(minLength: 0)
                }
            } else {
                HStack(spacing: 10) {
                    Button(action: onLibreta) {
                        HStack(spacing: 8) {
                            cuadroLibreta.frame(width: 26, height: 26)
                                .background(cnColor(hexString: c.color), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                            Text(c.nombre).font(.system(size: 15, weight: .bold)).foregroundColor(tinta).lineLimit(1)
                        }
                        .padding(.leading, 7).padding(.trailing, 13).padding(.vertical, 7)
                        .background(pastilla, in: Capsule())
                    }.buttonStyle(CNPulsable())
                    Spacer(minLength: 6)
                    VStack(alignment: .trailing, spacing: 1) {
                        Text(c.balanceFmt).font(.system(size: 19, weight: .bold)).foregroundColor(balColor).lineLimit(1)
                        Text(c.rotulo).font(.system(size: 11)).foregroundColor(tinta.opacity(0.72)).lineLimit(1)
                    }
                }
                HStack(spacing: 8) {
                    flechaMes("chevron.left") { onMes(-1) }
                    Button(action: onCalendario) {
                        HStack(spacing: 8) {
                            Image(systemName: "calendar").font(.system(size: 16, weight: .medium))
                            Text(c.mesLargo).font(.system(size: 14, weight: .bold)).lineLimit(1)
                        }
                        .foregroundColor(tinta)
                        .frame(maxWidth: .infinity).padding(.vertical, 9)
                        .background(pastilla, in: Capsule())
                    }.buttonStyle(CNPulsable())
                    flechaMes("chevron.right") { onMes(1) }
                }
            }
        }
        .padding(.horizontal, 14).padding(.top, padArriba).padding(.bottom, 14)
    }
    private func flecha(_ ic: String, _ color: String, _ texto: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: ic).font(.system(size: 13, weight: .heavy))
                .foregroundColor(color.isEmpty ? tinta : cnColor(hexString: color))
            Text(texto).font(.system(size: 13, weight: .semibold)).foregroundColor(tinta).lineLimit(1)
        }
    }

    // MARK: clásica (se pliega con su flecha)
    private var clasica: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Button(action: onLibreta) {
                    HStack(spacing: 10) {
                        cuadroLibreta.frame(width: 34, height: 34)
                            .background(cnColor(hexString: c.color), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                        Text(c.nombre).font(.system(size: 19, weight: .heavy)).foregroundColor(tinta).lineLimit(1)
                        chevron
                        Spacer(minLength: 0)
                    }
                }.buttonStyle(CNPulsable())
                HStack(spacing: 0) {
                    flechaMesPlano("chevron.left") { onMes(-1) }
                    Button(action: onCalendario) {
                        Text(c.periodoCorto).font(.system(size: 12, weight: .bold)).foregroundColor(tinta)
                            .frame(minWidth: 66).padding(.vertical, 6)
                    }.buttonStyle(CNPulsable())
                    flechaMesPlano("chevron.right") { onMes(1) }
                }
                .padding(2)
                .background(pastilla, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
            }
            if c.abierta {
                HStack(alignment: .bottom, spacing: 12) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(c.balanceRotulo).font(.system(size: 11)).foregroundColor(gris).lineLimit(1)
                        Text(c.balanceFmt).font(.system(size: 29, weight: .heavy)).foregroundColor(balColor)
                            .lineLimit(1).minimumScaleFactor(0.6)
                    }
                    Spacer(minLength: 8)
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(c.ingRotulo) \(c.ingFmt)").font(.system(size: 10))
                        Text("\(c.gasRotulo) \(c.gasFmt)").font(.system(size: 10))
                    }.foregroundColor(gris).lineLimit(1)
                }
                .padding(.top, 14)
            }
            Button(action: onPlegar) {
                Image(systemName: "chevron.down").font(.system(size: 14, weight: .bold))
                    .foregroundColor(gris)
                    .rotationEffect(.degrees(c.abierta ? 0 : 180))
                    .frame(width: 64, height: 20)
            }.buttonStyle(.plain).padding(.top, 2)
        }
        .padding(.horizontal, 18).padding(.top, padArriba).padding(.bottom, 4)
        .animation(.easeOut(duration: 0.22), value: c.abierta)
    }
    private func flechaMesPlano(_ ic: String, _ tap: @escaping () -> Void) -> some View {
        Button(action: tap) {
            Image(systemName: ic).font(.system(size: 13, weight: .bold)).foregroundColor(tinta)
                .frame(width: 28, height: 34)
        }.buttonStyle(CNPulsable())
    }

    // MARK: fina
    private var fina: some View {
        HStack(spacing: 10) {
            Button(action: onLibreta) {
                HStack(spacing: 9) {
                    cuadroLibreta.frame(width: 26, height: 26)
                        .background(pastillaFuerte, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    Text(c.nombre).font(.system(size: 17, weight: .bold)).foregroundColor(tinta).lineLimit(1)
                    chevron
                }
            }.buttonStyle(CNPulsable())
            Spacer(minLength: 8)
            Button(action: onCalendario) {
                HStack(spacing: 12) {
                    VStack(alignment: .trailing, spacing: 0) {
                        Text(c.balanceFmt).font(.system(size: 16, weight: .bold)).foregroundColor(balColor)
                        Text(c.periodoCorto).font(.system(size: 10)).foregroundColor(tinta.opacity(0.75))
                    }
                    iconoCalendario
                }
            }.buttonStyle(CNPulsable())
        }
        .padding(.horizontal, 16).frame(height: 56).padding(.top, c.tarjeta ? 8 : 0)
    }

    // MARK: clara
    private var clara: some View {
        HStack(spacing: 10) {
            Button(action: onLibreta) {
                HStack(spacing: 10) {
                    cuadroLibreta.frame(width: 30, height: 30)
                        .background(cnColor(hexString: c.color), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                    Text(c.nombre).font(.system(size: 19, weight: .bold)).foregroundColor(tinta).lineLimit(1)
                    chevron
                    Spacer(minLength: 0)
                }
            }.buttonStyle(CNPulsable())
            Button(action: onCalendario) {
                Text("\(c.periodoCorto) ›").font(.system(size: 15, weight: .semibold)).foregroundColor(CNC.pos)
            }.buttonStyle(CNPulsable())
        }
        .padding(.horizontal, 16).padding(.vertical, 10).frame(minHeight: 54)
        .padding(.top, c.tarjeta ? 8 : 0)
        .overlay(Rectangle().fill(CNC.line).frame(height: c.tarjeta ? 0 : 1), alignment: .bottom)
    }

    // MARK: mínima
    private var minima: some View {
        HStack(spacing: 10) {
            Button(action: onLibreta) {
                HStack(spacing: 9) {
                    cuadroLibreta.frame(width: 26, height: 26)
                        .background(cnColor(hexString: c.color), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    Text(c.nombre).font(.system(size: 17, weight: .bold)).foregroundColor(tinta).lineLimit(1)
                    chevron
                    Spacer(minLength: 0)
                }
            }.buttonStyle(CNPulsable())
            HStack(spacing: 2) {
                Button { onMes(-1) } label: {
                    Image(systemName: "chevron.left").font(.system(size: 12, weight: .bold)).frame(width: 26, height: 30)
                }
                Button(action: onCalendario) {
                    Text(c.periodoCorto).font(.system(size: 13, weight: .semibold)).frame(minWidth: 66)
                }
                Button { onMes(1) } label: {
                    Image(systemName: "chevron.right").font(.system(size: 12, weight: .bold)).frame(width: 26, height: 30)
                }
            }
            .foregroundColor(CNC.pos).buttonStyle(CNPulsable())
        }
        .padding(.horizontal, 16).frame(height: 50).padding(.top, c.tarjeta ? 8 : 0)
        .overlay(Rectangle().fill(CNC.line).frame(height: c.tarjeta ? 0 : 1), alignment: .bottom)
    }
}

/// El fondo de la cabecera: color plano o el MISMO degradado de la web (sus
/// paradas vienen ya resueltas, no un color parecido).
struct CNFondoCabecera: View {
    let f: CNResumenModelo.Fondo
    var respaldo: Color = CNC.side
    var body: some View {
        if f.tipo == "grad" && f.paradas.count > 1 {
            // El ángulo de CSS se mide en el sentido del reloj desde «hacia
            // arriba»; SwiftUI quiere los dos extremos.
            let r = (f.angulo - 90) * .pi / 180
            let dx = cos(r) / 2, dy = sin(r) / 2
            LinearGradient(
                stops: f.paradas.map { .init(color: cnColor(hexString: $0.color), location: CGFloat($0.pos)) },
                startPoint: UnitPoint(x: 0.5 - dx, y: 0.5 - dy),
                endPoint: UnitPoint(x: 0.5 + dx, y: 0.5 + dy))
        } else if !f.color.isEmpty {
            cnColor(hexString: f.color)
        } else {
            respaldo
        }
    }
}

/// Cuánto se ha rodado la lista: es lo que pliega la cabecera automática.
/// Mira cuánto se ha rodado, de verdad.
///
/// Medirlo con GeometryReader + preferencias NO funcionaba aquí: la lista se
/// movía y el valor no llegaba nunca a la vista. Esto sube por las vistas hasta
/// dar con el `UIScrollView` que SwiftUI crea por debajo y se apunta a sus
/// cambios de posición, que es el dato que de verdad manda.
struct CNEspiaScroll: UIViewRepresentable {
    var alRodar: (CGFloat) -> Void
    func makeUIView(context: Context) -> UIView {
        let v = UIView(frame: .zero)
        v.isUserInteractionEnabled = false
        v.backgroundColor = .clear
        DispatchQueue.main.async { context.coordinator.enganchar(desde: v) }
        return v
    }
    func updateUIView(_ v: UIView, context: Context) {
        context.coordinator.alRodar = alRodar
        if context.coordinator.scroll == nil {
            DispatchQueue.main.async { context.coordinator.enganchar(desde: v) }
        }
    }
    func makeCoordinator() -> Coordinador { Coordinador(alRodar) }

    final class Coordinador: NSObject {
        var alRodar: (CGFloat) -> Void
        weak var scroll: UIScrollView?
        private var obs: NSKeyValueObservation?
        init(_ f: @escaping (CGFloat) -> Void) { alRodar = f }
        func enganchar(desde v: UIView) {
            var p: UIView? = v.superview
            while let actual = p, !(actual is UIScrollView) { p = actual.superview }
            guard let sc = p as? UIScrollView else { return }
            scroll = sc
            obs = sc.observe(\.contentOffset, options: [.new, .initial]) { [weak self] s, _ in
                let y = s.contentOffset.y + s.adjustedContentInset.top
                // Fuera del ciclo de dibujo: tocar el estado desde aquí dentro
                // saca el aviso de «modifying state during view update».
                DispatchQueue.main.async { self?.alRodar(y) }
            }
        }
        deinit { obs?.invalidate() }
    }
}

struct CNResumen: View {
    @ObservedObject var datos: CNDatos
    /// El mismo recorrido que la web (RECORRIDO = 90 px).
    @State private var rodado: CGFloat = 0
    /// Modo «organizar»: cada tarjeta enseña su ⋯ y se puede agregar.
    @State private var organiza = false
    /// Solo para el banco de pruebas: arrancar ya organizando.
    var organizaAlEmpezar = false
    /// Solo para el banco de pruebas: rodar la lista sola para ver el plegado.
    var rodarAlEmpezar = false
    private var progreso: Double { Double(max(0, min(1, rodado / 90))) }

    var body: some View {
        let m = datos.resumen ?? CNResumenModelo()
        let auto = m.cabecera.diseno == "auto"
        // Primero se pliega la cabecera y DESPUÉS sube el contenido, como en la
        // web: mientras se pliega, el contenido se queda pegado a su borde de
        // abajo. Se consigue devolviéndole como relleno lo que se ha rodado
        // (el `empuja` de allá); si no, el contenido sube dos veces —lo que
        // rueda y lo que encoge la cabecera— y a la primera se pierden dos
        // tarjetas.
        //
        // Medir la cabecera no hace falta: al ir en la pila vertical se
        // encoge sola, y como el scroll se lee del UIScrollView (y no de dónde
        // ha quedado el contenido), encogerse ya no se muerde la cola.
        return VStack(spacing: 0) {
            CNCabeceraApp(c: m.cabecera, progreso: auto ? progreso : 1,
                          onLibreta: { datos.onSelector() }, onMes: { datos.onMes($0) },
                          onCalendario: { datos.onCalendario() },
                          onMesTira: { datos.onMesTira($0) },
                          onPlegar: { datos.onPlegar() })
            ScrollView(showsIndicators: false) {
                ScrollViewReader { lector in
                    VStack(spacing: 0) {
                        CNEspiaScroll { y in
                            if abs(y - rodado) > 0.5 { rodado = max(0, y) }
                            CNScrollEstado.shared.mirar(y)
                        }
                        .frame(height: 0).id("cnArriba")
                        contenido(m)
                            .padding(.horizontal, 16)
                            .padding(.top, 16 + (auto ? min(rodado, 90) : 0))
                            .onAppear {
                                guard rodarAlEmpezar else { return }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                                    withAnimation(.easeOut(duration: 0.4)) { lector.scrollTo("cnAbajo", anchor: .bottom) }
                                }
                            }
                    }
                }
            }
        }
        .background(CNC.scr.ignoresSafeArea())
    }

    @ViewBuilder private func contenido(_ m: CNResumenModelo) -> some View {
        VStack(spacing: 13) {
            if m.vacio { tarjetaVacia(m) }
            // Organizando se ven TODAS (las ocultas atenuadas), para poder
            // traerlas de vuelta; fuera de ahí, solo las visibles.
            let vistas = organiza ? m.widgets : m.widgets.filter { !$0.oculta }
            CNRejilla(widgets: vistas) { w in
                CNTarjetaWidget(w: w, modelo: m, organiza: organiza,
                                primera: w.indice == 0,
                                ultima: w.indice == m.widgets.count - 1,
                                datos: datos)
            }
            if organiza && !m.catalogo.isEmpty {
                Menu {
                    ForEach(m.catalogo, id: \.id) { o in
                        Button(o.label) { datos.onPanel("agregar", o.id, "") }
                    }
                } label: {
                    HStack(spacing: 7) {
                        Image(systemName: "plus").font(.system(size: 14, weight: .bold))
                        Text("Agregar tarjeta").font(.system(size: 13.5, weight: .bold))
                    }
                    .foregroundColor(CNC.sobreAcc).frame(maxWidth: .infinity).padding(.vertical, 13)
                    .background(CNC.acc, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                }
            }
            Button {
                UISelectionFeedbackGenerator().selectionChanged()
                withAnimation(.easeOut(duration: 0.2)) { organiza.toggle() }
            } label: {
                HStack(spacing: 7) {
                    Image(systemName: organiza ? "checkmark" : "square.grid.2x2")
                        .font(.system(size: 13, weight: .bold))
                    Text(organiza ? "Listo" : "Organizar el panel").font(.system(size: 13.5, weight: .bold))
                }
                .foregroundColor(CNC.ink).frame(maxWidth: .infinity).padding(.vertical, 12)
                .background(CNC.soft, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
            }.buttonStyle(CNPulsable())
            Color.clear.frame(height: 104).id("cnAbajo")
        }
        .onAppear { if organizaAlEmpezar { organiza = true } }
    }

    private func tarjetaVacia(_ m: CNResumenModelo) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(m.vacioTitulo).font(.system(size: 17, weight: .heavy)).foregroundColor(CNC.ink)
            Text(m.vacioTexto).font(.system(size: 13)).foregroundColor(CNC.pmut)
                .fixedSize(horizontal: false, vertical: true)
            Button { datos.onEmpezar() } label: {
                Text(m.vacioBoton).font(.system(size: 15, weight: .heavy)).foregroundColor(CNC.sobreAcc)
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                    .background(CNC.acc, in: Capsule())
            }.buttonStyle(CNPulsable()).padding(.top, 12)
        }
        .padding(.horizontal, 16).padding(.vertical, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(CNC.line, lineWidth: 1))
    }
}

/// Coloca las tarjetas como la web: las anchas ocupan la fila entera y las
/// chicas van de dos en dos, en el orden en que vienen.
struct CNRejilla<C: View>: View {
    let widgets: [CNResumenModelo.Widget]
    @ViewBuilder var celda: (CNResumenModelo.Widget) -> C
    private var filas: [[CNResumenModelo.Widget]] {
        var out: [[CNResumenModelo.Widget]] = []
        for w in widgets {
            if w.chica, var ultima = out.last, ultima.count == 1, ultima[0].chica {
                ultima.append(w); out[out.count - 1] = ultima
            } else {
                out.append([w])
            }
        }
        return out
    }
    var body: some View {
        VStack(spacing: 13) {
            ForEach(filas.indices, id: \.self) { i in
                HStack(alignment: .top, spacing: 13) {
                    ForEach(filas[i]) { w in celda(w).frame(maxWidth: .infinity) }
                    if filas[i].count == 1 && filas[i][0].chica { Color.clear.frame(maxWidth: .infinity) }
                }
            }
        }
    }
}

/// Una tarjeta del panel. Cada clase se dibuja con las medidas de la web.
struct CNTarjetaWidget: View {
    let w: CNResumenModelo.Widget
    let modelo: CNResumenModelo
    var organiza: Bool = false
    var primera: Bool = false
    var ultima: Bool = false
    @ObservedObject var datos: CNDatos
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(w.titulo).font(.system(size: 13)).foregroundColor(CNC.pmut).lineLimit(1)
                Spacer(minLength: 0)
                if !w.periodo.isEmpty {
                    Text(w.periodo).font(.system(size: 12, weight: .semibold)).foregroundColor(CNC.pmut)
                }
                if organiza {
                    Menu { acciones } label: {
                        Image(systemName: "ellipsis").font(.system(size: 13, weight: .bold))
                            .foregroundColor(CNC.pmut).frame(width: 28, height: 24)
                            .background(CNC.soft, in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                    }
                }
            }
            .padding(.bottom, 8)
            cuerpo
        }
        .padding(16).frame(maxWidth: .infinity, alignment: .leading)
        .background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(CNC.line, lineWidth: 1))
        .opacity(w.oculta ? 0.42 : 1)
        // Mantener pulsado: lo mismo, sin tener que entrar en «organizar».
        .contextMenu { acciones }
    }

    /// Todo lo que se puede hacer con una tarjeta, en el menú del sistema: lo
    /// mismo que la web deja hacer arrastrando y estirando.
    @ViewBuilder private var acciones: some View {
        if w.clase == "serie" {
            Menu("Tipo de gráfica") {
                Picker("", selection: Binding(get: { w.cfgGrafico },
                                              set: { datos.onPanel("grafico", w.wid, $0) })) {
                    ForEach(modelo.tiposGrafico, id: \.id) { g in Text(g.label).tag(g.id) }
                }
            }
            Menu("Cuánto tiempo") {
                Picker("", selection: Binding(get: { w.cfgRango },
                                              set: { datos.onPanel("rango", w.wid, $0) })) {
                    ForEach(modelo.rangosGrafico, id: \.id) { r in Text(r.label).tag(r.id) }
                }
            }
            Menu("Qué se compara") {
                ForEach(w.series, id: \.id) { sr in
                    Button { datos.onPanel("serie", w.wid, sr.id) } label: {
                        Label(sr.label, systemImage: sr.puesta ? "checkmark.circle.fill" : "circle")
                    }
                }
            }
            Divider()
        }
        if w.puedeChica {
            Button { datos.onPanel("ancho", w.wid, w.ancho == 1 ? "2" : "1") } label: {
                Label(w.ancho == 1 ? "Hacerla ancha" : "Hacerla media",
                      systemImage: w.ancho == 1 ? "rectangle" : "rectangle.split.2x1")
            }
        }
        if !primera {
            Button { datos.onPanel("mover", w.wid, String(w.indice - 1)) } label: {
                Label("Subir", systemImage: "arrow.up")
            }
        }
        if !ultima {
            Button { datos.onPanel("mover", w.wid, String(w.indice + 1)) } label: {
                Label("Bajar", systemImage: "arrow.down")
            }
        }
        Button { datos.onPanel("ocultar", w.wid, "") } label: {
            Label(w.oculta ? "Mostrar aquí" : "Ocultar aquí", systemImage: w.oculta ? "eye" : "eye.slash")
        }
        Button(role: .destructive) { datos.onPanel("quitar", w.wid, "") } label: {
            Label("Quitar del panel", systemImage: "trash")
        }
    }

    @ViewBuilder private var cuerpo: some View {
        switch w.clase {
        case "cifra":
            VStack(alignment: .leading, spacing: 3) {
                Text(w.valor).font(.system(size: w.chica ? 21 : 26, weight: .heavy))
                    .foregroundColor(w.color.isEmpty ? CNC.ink : cnColor(hexString: w.color))
                    .lineLimit(1).minimumScaleFactor(0.5)
                Text(w.nota).font(.system(size: 11)).foregroundColor(CNC.pmut)
                    .fixedSize(horizontal: false, vertical: true)
            }
        case "texto":
            Text(w.texto).font(.system(size: 13)).foregroundColor(CNC.ink)
                .fixedSize(horizontal: false, vertical: true)
        case "serie": serie
        case "barras": barras
        case "columnas": columnas
        case "dona": dona
        default: lista
        }
    }

    // MARK: gráfica de series (mismo lienzo 100×42 de la web)
    private var serie: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !w.leyenda.isEmpty {
                HStack(spacing: 14) {
                    ForEach(w.leyenda.indices, id: \.self) { i in
                        let s = w.leyenda[i]
                        HStack(spacing: 7) {
                            RoundedRectangle(cornerRadius: 4).fill(cnColor(hexString: s.color))
                                .frame(width: 10, height: 10)
                            Text(s.label).font(.system(size: 12)).foregroundColor(CNC.pmut)
                            Text(s.ultimo).font(.system(size: 12, weight: .bold)).foregroundColor(CNC.ink)
                        }
                    }
                    Spacer(minLength: 0)
                }
            }
            CNLienzoSerie(w: w).frame(height: 170)
            if !w.etiquetas.isEmpty {
                HStack(spacing: 0) {
                    ForEach(w.etiquetas.indices, id: \.self) { i in
                        Text(w.etiquetas[i]).font(.system(size: 10)).foregroundColor(CNC.pmut)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }

    // MARK: barras por categoría
    private var barras: some View {
        VStack(spacing: 10) {
            ForEach(w.filas.indices, id: \.self) { i in
                let r = w.filas[i]
                HStack(spacing: 11) {
                    if !r.iconoPath.isEmpty {
                        CNSVGShape(d: r.iconoPath)
                            .stroke(style: StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round))
                            .foregroundColor(cnColor(hexString: r.color))
                            .frame(width: 19, height: 19)
                            .frame(width: 34, height: 34)
                            .background(cnColor(hexString: r.iconoBg))
                            .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                    }
                    VStack(spacing: 5) {
                        HStack {
                            Text(r.label).font(.system(size: 12, weight: .semibold)).foregroundColor(CNC.ink).lineLimit(1)
                            Spacer(minLength: 8)
                            Text(r.valor).font(.system(size: 12)).foregroundColor(CNC.pmut)
                        }
                        CNBarraProgreso(parte: r.pct / 100, color: cnColor(hexString: r.color), alto: 8)
                    }
                }
            }
            if w.vaAlPresupuesto {
                Button { datos.onVerPresupuesto() } label: {
                    Text(w.rotuloPresupuesto).font(.system(size: 13, weight: .bold)).foregroundColor(CNC.ink)
                        .frame(maxWidth: .infinity).padding(.vertical, 11)
                        .background(CNC.soft, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                }.buttonStyle(CNPulsable()).padding(.top, 4)
            }
        }
    }

    // MARK: columnas de tendencia
    private var columnas: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 14) {
                punto(w.rotuloEntra, w.entraColor)
                punto(w.rotuloSale, w.saleColor)
                Spacer(minLength: 0)
            }
            .padding(.bottom, 12)
            ZStack(alignment: .bottom) {
                HStack(alignment: .bottom, spacing: 9) {
                    ForEach(w.columnas.indices, id: \.self) { i in
                        let t = w.columnas[i]
                        VStack(spacing: 6) {
                            HStack(alignment: .bottom, spacing: 2) {
                                columna(t.a, w.entraColor)
                                columna(t.b, w.saleColor)
                            }
                            .frame(maxHeight: .infinity, alignment: .bottom)
                            Text(t.label).font(.system(size: 10, weight: t.peso >= 700 ? .bold : .regular))
                                .foregroundColor(cnColor(hexString: t.color)).lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 118)
                if w.hayMedia {
                    GeometryReader { g in
                        let alto = max(0, g.size.height - 22)
                        Path { p in
                            let y = g.size.height - 22 - alto * CGFloat(w.media / 100)
                            p.move(to: CGPoint(x: 0, y: y)); p.addLine(to: CGPoint(x: g.size.width, y: y))
                        }
                        .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                        .foregroundColor(CNC.pmut.opacity(0.5))
                    }
                    .frame(height: 118)
                    .allowsHitTesting(false)
                }
            }
        }
    }
    private func columna(_ pct: Double, _ color: String) -> some View {
        GeometryReader { g in
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                CNColumnaForma(radio: 4)
                    .fill(cnColor(hexString: color))
                    .frame(height: max(3, g.size.height * CGFloat(pct / 100)))
            }
        }
    }
    private func punto(_ t: String, _ c: String) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 4).fill(cnColor(hexString: c)).frame(width: 9, height: 9)
            Text(t).font(.system(size: 12, weight: .semibold)).foregroundColor(CNC.pmut)
        }
    }

    // MARK: dona
    private var dona: some View {
        HStack(spacing: 16) {
            ZStack {
                ForEach(w.tramos.indices, id: \.self) { i in
                    let t = w.tramos[i]
                    Circle().trim(from: t.desde / 100, to: max(t.desde, t.hasta) / 100)
                        .stroke(cnColor(hexString: t.color), lineWidth: 20)
                        .rotationEffect(.degrees(-90))
                        .frame(width: 84, height: 84)
                }
                VStack(spacing: 0) {
                    Text("Total").font(.system(size: 9)).foregroundColor(CNC.pmut)
                    Text(w.total).font(.system(size: 12, weight: .heavy)).foregroundColor(CNC.ink)
                        .lineLimit(1).minimumScaleFactor(0.6).padding(.horizontal, 4)
                }
                .frame(width: 64, height: 64)
            }
            .frame(width: 104, height: 104)
            VStack(spacing: 7) {
                ForEach(w.filasDona.indices, id: \.self) { i in
                    let r = w.filasDona[i]
                    HStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 3).fill(cnColor(hexString: r.color)).frame(width: 9, height: 9)
                        Text(r.label).font(.system(size: 12)).foregroundColor(CNC.ink)
                        Spacer(minLength: 6)
                        Text(r.valor).font(.system(size: 12, weight: .bold)).foregroundColor(CNC.ink)
                    }
                }
            }
        }
    }

    // MARK: listas (recientes, recordatorios, metas)
    private var lista: some View {
        VStack(spacing: 0) {
            ForEach(w.items.indices, id: \.self) { i in
                let it = w.items[i]
                HStack(spacing: 10) {
                    if it.tieneIcono && !it.iconoPath.isEmpty {
                        CNSVGShape(d: it.iconoPath)
                            .stroke(style: StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round))
                            .foregroundColor(cnColor(hexString: it.color))
                            .frame(width: 18, height: 18)
                            .frame(width: 34, height: 34)
                            .background(cnColor(hexString: it.fondo))
                            .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                    } else {
                        Text(it.sigla).font(.system(size: 11, weight: .heavy))
                            .foregroundColor(cnColor(hexString: it.siglaColor))
                            .frame(width: 34, height: 34)
                            .background(cnColor(hexString: it.fondo))
                            .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(it.titulo).font(.system(size: 13, weight: .semibold)).foregroundColor(CNC.ink).lineLimit(1)
                        Text(it.detalle).font(.system(size: 11)).foregroundColor(CNC.pmut).lineLimit(1)
                    }
                    Spacer(minLength: 6)
                    Text(it.monto).font(.system(size: 13, weight: .bold))
                        .foregroundColor(cnColor(hexString: it.montoColor))
                }
                .padding(.vertical, 11)
                if i < w.items.count - 1 { Rectangle().fill(CNC.soft).frame(height: 1) }
            }
        }
    }
}

/// Esquinas superiores redondeadas (las columnas de la tendencia).
struct CNColumnaForma: Shape {
    var radio: CGFloat = 4
    func path(in r: CGRect) -> Path {
        var p = Path()
        let rr = min(radio, r.height / 2, r.width / 2)
        p.move(to: CGPoint(x: r.minX, y: r.maxY))
        p.addLine(to: CGPoint(x: r.minX, y: r.minY + rr))
        p.addQuadCurve(to: CGPoint(x: r.minX + rr, y: r.minY), control: CGPoint(x: r.minX, y: r.minY))
        p.addLine(to: CGPoint(x: r.maxX - rr, y: r.minY))
        p.addQuadCurve(to: CGPoint(x: r.maxX, y: r.minY + rr), control: CGPoint(x: r.maxX, y: r.minY))
        p.addLine(to: CGPoint(x: r.maxX, y: r.maxY))
        p.closeSubpath()
        return p
    }
}

/// El lienzo de la gráfica de series: el mismo viewBox 0 0 100 42 de la web,
/// con sus guías, áreas, líneas, barras y puntos ya calculados allí.
struct CNLienzoSerie: View {
    let w: CNResumenModelo.Widget
    private func pares(_ s: String) -> [CGPoint] {
        s.split(separator: " ").compactMap { par in
            let xy = par.split(separator: ",")
            guard xy.count == 2, let x = Double(xy[0]), let y = Double(xy[1]) else { return nil }
            return CGPoint(x: x, y: y)
        }
    }
    var body: some View {
        GeometryReader { g in
            let ex = g.size.width / 100, ey = g.size.height / 42
            ZStack {
                ForEach(w.guias.indices, id: \.self) { i in
                    Path { p in
                        let y = w.guias[i].y * ey
                        p.move(to: CGPoint(x: 0, y: y)); p.addLine(to: CGPoint(x: g.size.width, y: y))
                    }.stroke(cnColor(hexString: w.guias[i].color), lineWidth: 1)
                }
                ForEach(w.areas.indices, id: \.self) { i in
                    forma(pares(w.areas[i].puntos), ex, ey, cerrada: true)
                        .fill(cnColor(hexString: w.areas[i].color).opacity(0.18))
                }
                ForEach(w.barras.indices, id: \.self) { i in
                    let b = w.barras[i]
                    RoundedRectangle(cornerRadius: 1, style: .continuous)
                        .fill(cnColor(hexString: b.color))
                        .frame(width: max(1, b.w * ex), height: max(1, b.h * ey))
                        .position(x: (b.x + b.w / 2) * ex, y: (b.y + b.h / 2) * ey)
                }
                ForEach(w.lineas.indices, id: \.self) { i in
                    forma(pares(w.lineas[i].puntos), ex, ey, cerrada: false)
                        .stroke(cnColor(hexString: w.lineas[i].color),
                                style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                }
                ForEach(w.puntos.indices, id: \.self) { i in
                    let p = w.puntos[i]
                    Circle().fill(cnColor(hexString: p.color)).frame(width: 4.8, height: 4.8)
                        .position(x: p.x * ex, y: p.y * ey)
                }
            }
        }
    }
    private func forma(_ pts: [CGPoint], _ ex: CGFloat, _ ey: CGFloat, cerrada: Bool) -> Path {
        var p = Path()
        guard let primero = pts.first else { return p }
        p.move(to: CGPoint(x: primero.x * ex, y: primero.y * ey))
        for q in pts.dropFirst() { p.addLine(to: CGPoint(x: q.x * ex, y: q.y * ey)) }
        if cerrada { p.closeSubpath() }
        return p
    }
}

// ── Pantalla «Perfil» NATIVA ────────────────────────────────────────────────
// Lista agrupada, como los Ajustes del teléfono: icono en su cuadro de color,
// título, una línea que dice qué hay dentro y el valor a la derecha. Los grupos
// y sus filas los arma la web (los mismos que ve la PWA); aquí solo se dibujan
// y se disparan por su sitio en la lista.

struct CNAjustes {
    struct Opcion { var id = ""; var label = "" }
    struct Fila {
        var label = ""; var sub = ""; var valor = ""
        var icono = ""; var bg = ""; var fg = ""; var tinta = ""
        var entra = false
        /// Si lleva id de sección, se abre NATIVA en vez de rebotar a la web.
        var sec = ""
        var lista: [Opcion] = []; var listaValor = ""
    }
    struct Grupo { var titulo = ""; var pie = ""; var filas: [Fila] = [] }
    struct Usuario {
        var inicial = ""; var nombre = ""; var correo = ""
        var plan = ""; var planColor = ""
        var modoLabel = ""; var modoBg = ""; var modoFg = ""; var modoPie = ""
        var acento = ""; var sobreAcento = ""
    }
    var usuario = Usuario()
    var grupos: [Grupo] = []

    static func desde(json: String) -> CNAjustes? {
        guard let d = json.data(using: .utf8),
              let raiz = (try? JSONSerialization.jsonObject(with: d)) as? [String: Any] else { return nil }
        func s(_ o: [String: Any]?, _ k: String) -> String { (o?[k] as? String) ?? "" }
        func b(_ o: [String: Any]?, _ k: String) -> Bool { (o?[k] as? Bool) ?? false }
        func lista(_ o: [String: Any]?, _ k: String) -> [[String: Any]] { (o?[k] as? [[String: Any]]) ?? [] }
        var a = CNAjustes()
        let u = raiz["usuario"] as? [String: Any]
        a.usuario = Usuario(inicial: s(u, "inicial"), nombre: s(u, "nombre"), correo: s(u, "correo"),
                            plan: s(u, "plan"), planColor: s(u, "planColor"),
                            modoLabel: s(u, "modoLabel"), modoBg: s(u, "modoBg"), modoFg: s(u, "modoFg"),
                            modoPie: s(u, "modoPie"), acento: s(u, "acento"), sobreAcento: s(u, "sobreAcento"))
        a.grupos = lista(raiz, "grupos").map { g in
            Grupo(titulo: s(g, "titulo"), pie: s(g, "pie"),
                  filas: lista(g, "filas").map { f in
                      Fila(label: s(f, "label"), sub: s(f, "sub"), valor: s(f, "valor"),
                           icono: s(f, "icono"), bg: s(f, "bg"), fg: s(f, "fg"), tinta: s(f, "tinta"),
                           entra: b(f, "entra"), sec: s(f, "sec"),
                           lista: lista(f, "lista").map { Opcion(id: s($0, "id"), label: s($0, "label")) },
                           listaValor: s(f, "listaValor"))
                  })
        }
        return a
    }
}

struct CNPerfil: View {
    @ObservedObject var datos: CNDatos
    var body: some View {
        ZStack {
            raiz
            // La subpantalla entra desde la derecha, como en el teléfono.
            if let sec = datos.seccion {
                CNSeccionVista(sec: sec, datos: datos, onVolver: { cerrar() })
                    .transition(.move(edge: .trailing))
                    .zIndex(1)
            }
        }
        .animation(.easeOut(duration: 0.26), value: datos.seccion?.id)
    }

    private func cerrar() {
        UISelectionFeedbackGenerator().selectionChanged()
        datos.seccion = nil
    }

    private var raiz: some View {
        let a = datos.ajustes ?? CNAjustes()
        return VStack(spacing: 0) {
            cabecera
            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    CNEspiaScroll { CNScrollEstado.shared.mirar($0) }.frame(height: 0)
                    tarjetaUsuario(a.usuario)
                    ForEach(a.grupos.indices, id: \.self) { gi in
                        grupo(a.grupos[gi], gi)
                    }
                    Color.clear.frame(height: 104)
                }
                .padding(.horizontal, 16).padding(.top, 14)
            }
        }
        .background(CNC.scr.ignoresSafeArea())
    }

    /// Perfil no lleva la cabecera de la libreta: aquí no hay mes ni balance
    /// que mirar. Lleva el nombre de la app, como en la web.
    private var cabecera: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle().fill(CNC.side).frame(width: 29, height: 29)
                Circle().fill(CNC.acc).frame(width: 11, height: 11)
            }
            Text("Chinola").font(.system(size: 20, weight: .heavy)).foregroundColor(CNC.ink)
            Spacer(minLength: 0)
        }
        // Pegado a la isla: el margen seguro ya la esquiva, así que dejar más
        // aire aquí solo es pantalla desperdiciada.
        .padding(.horizontal, 16).padding(.top, 2 - max(0, cnMargenArriba() - 56))
        .padding(.bottom, 8).frame(minHeight: 44)
        .background(CNC.scr.ignoresSafeArea(edges: .top))
    }

    private func tarjetaUsuario(_ u: CNAjustes.Usuario) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 12) {
                Text(u.inicial).font(.system(size: 17, weight: .heavy))
                    .foregroundColor(u.sobreAcento.isEmpty ? CNC.sobreAcc : cnColor(hexString: u.sobreAcento))
                    .frame(width: 50, height: 50)
                    .background(u.acento.isEmpty ? CNC.acc : cnColor(hexString: u.acento), in: Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text(u.nombre).font(.system(size: 15, weight: .bold)).foregroundColor(CNC.ink).lineLimit(1)
                    if !u.correo.isEmpty {
                        Text(u.correo).font(.system(size: 12)).foregroundColor(CNC.pmut).lineLimit(1)
                    }
                    if !u.plan.isEmpty {
                        Button { datos.onPlan() } label: {
                            HStack(spacing: 5) {
                                Image(systemName: "star.fill").font(.system(size: 10))
                                Text(u.plan).font(.system(size: 11, weight: .heavy))
                                Image(systemName: "chevron.right").font(.system(size: 9, weight: .bold)).opacity(0.6)
                            }
                            .foregroundColor(u.planColor.isEmpty ? CNC.pos : cnColor(hexString: u.planColor))
                        }.buttonStyle(CNPulsable()).padding(.top, 3)
                    }
                }
                Spacer(minLength: 6)
                if !u.modoLabel.isEmpty {
                    Text(u.modoLabel).font(.system(size: 10, weight: .bold))
                        .foregroundColor(u.modoFg.isEmpty ? CNC.pmut : cnColor(hexString: u.modoFg))
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .background(u.modoBg.isEmpty ? CNC.soft : cnColor(hexString: u.modoBg), in: Capsule())
                }
            }
            .padding(15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(CNC.line, lineWidth: 1))
            if !u.modoPie.isEmpty {
                Text(u.modoPie).font(.system(size: 12)).foregroundColor(CNC.pmut)
                    .fixedSize(horizontal: false, vertical: true).padding(.horizontal, 4)
            }
        }
    }

    private func grupo(_ g: CNAjustes.Grupo, _ gi: Int) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            if !g.titulo.isEmpty {
                Text(g.titulo).font(.system(size: 13)).foregroundColor(CNC.pmut)
                    .padding(.horizontal, 6)
            }
            VStack(spacing: 0) {
                ForEach(g.filas.indices, id: \.self) { fi in
                    fila(g.filas[fi], gi, fi, ultima: fi == g.filas.count - 1)
                }
            }
            .background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(CNC.line, lineWidth: 1))
            if !g.pie.isEmpty {
                Text(g.pie).font(.system(size: 12)).foregroundColor(CNC.pmut)
                    .fixedSize(horizontal: false, vertical: true).padding(.horizontal, 6)
            }
        }
    }

    @ViewBuilder private func fila(_ f: CNAjustes.Fila, _ gi: Int, _ fi: Int, ultima: Bool) -> some View {
        if f.lista.isEmpty {
            Button {
                // Si la fila tiene su pantalla nativa, se abre aquí; si no, se
                // deja que la web haga lo suyo.
                if f.sec.isEmpty { datos.onAjuste(gi, fi, nil) } else { datos.onAbrirSeccion(f.sec) }
            } label: { cuerpoFila(f, ultima: ultima) }
                .buttonStyle(CNPulsable())
        } else {
            // Una lista (el idioma) se elige en el menú del sistema, no en un
            // desplegable escondido detrás de la fila.
            Menu {
                Picker("", selection: Binding(get: { f.listaValor },
                                              set: { datos.onAjuste(gi, fi, $0) })) {
                    ForEach(f.lista, id: \.id) { o in Text(o.label).tag(o.id) }
                }
            } label: { cuerpoFila(f, ultima: ultima) }
        }
    }

    private func cuerpoFila(_ f: CNAjustes.Fila, ultima: Bool) -> some View {
        let tinta = f.tinta.isEmpty ? CNC.ink : cnColor(hexString: f.tinta)
        return HStack(spacing: 13) {
            // El icono en su cuadro de color, como en los Ajustes del teléfono:
            // la fila se encuentra por el color antes que por el texto. Viene
            // como trazo SVG (el mismo que dibuja la web), no como nombre.
            CNSVGShape(d: f.icono)
                .stroke(style: StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round))
                .foregroundColor(f.fg.isEmpty ? tinta : cnColor(hexString: f.fg))
                .frame(width: 18, height: 18)
                .frame(width: 30, height: 30)
                .background(f.bg.isEmpty ? CNC.soft : cnColor(hexString: f.bg),
                            in: RoundedRectangle(cornerRadius: 9, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(f.label).font(.system(size: 16)).foregroundColor(tinta).lineLimit(1)
                if !f.sub.isEmpty {
                    Text(f.sub).font(.system(size: 12)).foregroundColor(CNC.pmut)
                        .lineLimit(1).truncationMode(.tail)
                }
            }
            .layoutPriority(1)
            Spacer(minLength: 8)
            if !f.valor.isEmpty {
                Text(f.valor).font(.system(size: 14)).foregroundColor(CNC.pmut)
                    .lineLimit(1).truncationMode(.tail).layoutPriority(0)
            }
            if f.entra || !f.lista.isEmpty {
                Image(systemName: f.lista.isEmpty ? "chevron.right" : "chevron.up.chevron.down")
                    .font(.system(size: 12, weight: .semibold)).foregroundColor(CNC.pmut.opacity(0.5))
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 11)
        .contentShape(Rectangle())
        .overlay(alignment: .bottom) {
            if !ultima { Rectangle().fill(CNC.soft).frame(height: 0.5).padding(.leading, 57) }
        }
    }
}

// ── Subpantallas del Perfil, NATIVAS ────────────────────────────────────────
// Cada sección (Mi cuenta, Seguridad, Libretas, Integraciones y los seis
// apartados de Apariencia) llega como una lista de BLOQUES que esta pantalla
// sabe dibujar. Las acciones se disparan por su número: son las mismas
// funciones que ejecuta la web.

struct CNSeccion {
    struct Fila {
        var label = ""; var sub = ""; var valor = ""
        var icono = ""; var bg = ""; var fg = ""; var tinta = ""
        var entra = false; var accion = -1
    }
    struct Opcion {
        var label = ""; var sub = ""; var puesta = false
        var color = ""; var fondo = ""; var muestra = ""; var imagen = ""
        var accion = -1
    }
    struct Muestra { var nombre = ""; var css = ""; var puesta = false; var accion = -1 }
    struct AccionItem { var label = ""; var peligro = false; var accion = -1 }
    struct Item {
        var titulo = ""; var detalle = ""; var icono = ""; var color = ""; var fondo = ""
        var chip = ""; var chipFondo = ""; var accion = -1
        var acciones: [AccionItem] = []
    }
    struct Bloque {
        var tipo = "grupo"
        var titulo = ""; var pie = ""; var texto = ""; var label = ""; var estilo = "suave"
        var columnas = 2
        var puesto = false; var accion = -1
        var filas: [Fila] = []; var opciones: [Opcion] = []
        var colores: [Muestra] = []; var items: [Item] = []
    }
    var id = ""; var titulo = ""; var bloques: [Bloque] = []

    static func desde(json: String) -> CNSeccion? {
        guard let d = json.data(using: .utf8),
              let raiz = (try? JSONSerialization.jsonObject(with: d)) as? [String: Any] else { return nil }
        func s(_ o: [String: Any]?, _ k: String) -> String { (o?[k] as? String) ?? "" }
        func n(_ o: [String: Any]?, _ k: String) -> Int { ((o?[k] as? NSNumber)?.intValue) ?? -1 }
        func b(_ o: [String: Any]?, _ k: String) -> Bool { (o?[k] as? Bool) ?? false }
        func l(_ o: [String: Any]?, _ k: String) -> [[String: Any]] { (o?[k] as? [[String: Any]]) ?? [] }
        var x = CNSeccion()
        x.id = s(raiz, "id"); x.titulo = s(raiz, "titulo")
        x.bloques = l(raiz, "bloques").map { bq in
            var q = Bloque()
            q.tipo = s(bq, "tipo"); q.titulo = s(bq, "titulo"); q.pie = s(bq, "pie")
            q.texto = s(bq, "texto"); q.label = s(bq, "label"); q.estilo = s(bq, "estilo")
            q.columnas = max(1, n(bq, "columnas")); q.puesto = b(bq, "puesto"); q.accion = n(bq, "accion")
            q.filas = l(bq, "filas").map {
                Fila(label: s($0, "label"), sub: s($0, "sub"), valor: s($0, "valor"), icono: s($0, "icono"),
                     bg: s($0, "bg"), fg: s($0, "fg"), tinta: s($0, "tinta"), entra: b($0, "entra"),
                     accion: n($0, "accion"))
            }
            q.opciones = l(bq, "opciones").map {
                Opcion(label: s($0, "label"), sub: s($0, "sub"), puesta: b($0, "puesta"),
                       color: s($0, "color"), fondo: s($0, "fondo"), muestra: s($0, "muestra"),
                       imagen: s($0, "imagen"), accion: n($0, "accion"))
            }
            q.colores = l(bq, "colores").map {
                Muestra(nombre: s($0, "nombre"), css: s($0, "css"), puesta: b($0, "puesta"), accion: n($0, "accion"))
            }
            q.items = l(bq, "items").map { it in
                Item(titulo: s(it, "titulo"), detalle: s(it, "detalle"), icono: s(it, "icono"),
                     color: s(it, "color"), fondo: s(it, "fondo"), chip: s(it, "chip"),
                     chipFondo: s(it, "chipFondo"), accion: n(it, "accion"),
                     acciones: l(it, "acciones").map {
                         AccionItem(label: s($0, "label"), peligro: b($0, "peligro"), accion: n($0, "accion"))
                     })
            }
            return q
        }
        return x
    }
}

struct CNSeccionVista: View {
    let sec: CNSeccion
    @ObservedObject var datos: CNDatos
    var onVolver: () -> Void
    var body: some View {
        VStack(spacing: 0) {
            cabecera
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(sec.bloques.indices, id: \.self) { i in bloque(sec.bloques[i]) }
                    Color.clear.frame(height: 104)
                }
                .padding(.horizontal, 16).padding(.top, 14)
            }
        }
        .background(CNC.scr.ignoresSafeArea())
    }

    private var cabecera: some View {
        HStack(spacing: 6) {
            Button(action: onVolver) {
                Image(systemName: "chevron.left").font(.system(size: 17, weight: .bold))
                    .foregroundColor(CNC.ink).frame(width: 40, height: 40)
                    .background(CNC.soft, in: Circle())
            }.buttonStyle(CNPulsable())
            Spacer(minLength: 0)
            Text(sec.titulo).font(.system(size: 17, weight: .heavy)).foregroundColor(CNC.ink).lineLimit(1)
            Spacer(minLength: 0)
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 16).padding(.top, 2 - max(0, cnMargenArriba() - 56))
        .padding(.bottom, 6).frame(minHeight: 46)
        .background(CNC.scr.ignoresSafeArea(edges: .top))
    }

    @ViewBuilder private func bloque(_ q: CNSeccion.Bloque) -> some View {
        switch q.tipo {
        case "texto":
            Text(q.texto).font(.system(size: 14)).foregroundColor(CNC.pmut)
                .fixedSize(horizontal: false, vertical: true).padding(.horizontal, 4)
        case "boton":
            Button { datos.onSeccionAccion(q.accion, nil) } label: {
                Text(q.label).font(.system(size: 15, weight: .bold))
                    .foregroundColor(q.estilo == "acento" ? CNC.sobreAcc : CNC.ink)
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                    .background(q.estilo == "acento" ? CNC.acc : CNC.soft,
                                in: RoundedRectangle(cornerRadius: 13, style: .continuous))
            }.buttonStyle(CNPulsable())
        case "codigo":
            VStack(alignment: .leading, spacing: 9) {
                if !q.titulo.isEmpty { rotulo(q.titulo) }
                Text(q.texto).font(.system(size: 13, design: .monospaced)).foregroundColor(CNC.ink)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading).padding(13)
                    .background(CNC.soft, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                Button { datos.onSeccionAccion(q.accion, nil) } label: {
                    Label(q.label, systemImage: "doc.on.doc").font(.system(size: 14, weight: .semibold))
                        .foregroundColor(CNC.ink)
                }.buttonStyle(CNPulsable())
            }
        case "interruptor":
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(q.label).font(.system(size: 16)).foregroundColor(CNC.ink)
                    if !q.titulo.isEmpty || !q.texto.isEmpty || !q.pie.isEmpty {
                        Text(q.pie.isEmpty ? q.texto : q.pie).font(.system(size: 12)).foregroundColor(CNC.pmut)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer(minLength: 8)
                Toggle("", isOn: Binding(get: { q.puesto },
                                         set: { _ in datos.onSeccionAccion(q.accion, nil) }))
                    .labelsHidden().tint(CNC.acc)
            }
            .padding(14).tarjetaCN()
        case "opciones": opcionesVista(q)
        case "muestras": muestrasVista(q)
        case "lista": listaVista(q)
        default: grupoVista(q)
        }
    }

    private func rotulo(_ t: String) -> some View {
        Text(t).font(.system(size: 13)).foregroundColor(CNC.pmut).padding(.horizontal, 6)
    }

    private func grupoVista(_ q: CNSeccion.Bloque) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            if !q.titulo.isEmpty { rotulo(q.titulo) }
            VStack(spacing: 0) {
                ForEach(q.filas.indices, id: \.self) { i in
                    let f = q.filas[i]
                    Button { datos.onSeccionAccion(f.accion, nil) } label: {
                        HStack(spacing: 13) {
                            if !f.icono.isEmpty {
                                CNSVGShape(d: f.icono)
                                    .stroke(style: StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round))
                                    .foregroundColor(f.fg.isEmpty ? CNC.ink : cnColor(hexString: f.fg))
                                    .frame(width: 18, height: 18).frame(width: 30, height: 30)
                                    .background(f.bg.isEmpty ? CNC.soft : cnColor(hexString: f.bg),
                                                in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(f.label).font(.system(size: 16)).foregroundColor(CNC.ink).lineLimit(1)
                                if !f.sub.isEmpty {
                                    Text(f.sub).font(.system(size: 12)).foregroundColor(CNC.pmut).lineLimit(1)
                                }
                            }.layoutPriority(1)
                            Spacer(minLength: 8)
                            if !f.valor.isEmpty {
                                Text(f.valor).font(.system(size: 14))
                                    .foregroundColor(f.tinta.isEmpty ? CNC.pmut : cnColor(hexString: f.tinta))
                                    .lineLimit(1)
                            }
                            if f.entra {
                                Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(CNC.pmut.opacity(0.5))
                            }
                        }
                        .padding(.horizontal, 14).padding(.vertical, 11).contentShape(Rectangle())
                        .overlay(alignment: .bottom) {
                            if i < q.filas.count - 1 {
                                Rectangle().fill(CNC.soft).frame(height: 0.5).padding(.leading, 57)
                            }
                        }
                    }.buttonStyle(CNPulsable())
                }
            }
            .background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(CNC.line, lineWidth: 1))
            if !q.pie.isEmpty { rotulo(q.pie) }
        }
    }

    /// Elegir entre varias: tarjetas en rejilla, con la puesta marcada en el
    /// color de la marca. Es lo que hace la web, no un menú desplegable.
    private func opcionesVista(_ q: CNSeccion.Bloque) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if !q.titulo.isEmpty { rotulo(q.titulo) }
            CNRejillaFija(columnas: q.columnas, total: q.opciones.count) { i in
                let o = q.opciones[i]
                Button { datos.onSeccionAccion(o.accion, nil) } label: {
                    VStack(spacing: 6) {
                        if !o.imagen.isEmpty, let img = cnImagenBase64(o.imagen) {
                            Image(uiImage: img).resizable().scaledToFit().frame(height: 52)
                        } else if !o.muestra.isEmpty {
                            Text(o.muestra).font(.system(size: 22, weight: .bold)).foregroundColor(CNC.ink)
                        } else if !o.color.isEmpty {
                            Circle().fill(cnColor(hexString: o.color)).frame(width: 22, height: 22)
                        }
                        Text(o.label).font(.system(size: 13.5, weight: .semibold)).foregroundColor(CNC.ink)
                            .lineLimit(1).minimumScaleFactor(0.8)
                        if !o.sub.isEmpty {
                            Text(o.sub).font(.system(size: 11)).foregroundColor(CNC.pmut).lineLimit(1)
                        }
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 13).padding(.horizontal, 8)
                    .background(o.puesta ? CNC.soft : CNC.card,
                                in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 14)
                        .stroke(o.puesta ? CNC.acc : CNC.line, lineWidth: o.puesta ? 2 : 1))
                }.buttonStyle(CNPulsable())
            }
        }
    }

    private func muestrasVista(_ q: CNSeccion.Bloque) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if !q.titulo.isEmpty { rotulo(q.titulo) }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(q.colores.indices, id: \.self) { i in
                        let c = q.colores[i]
                        Button { datos.onSeccionAccion(c.accion, nil) } label: {
                            CNFondoCabecera(f: cnFondoDeCss(c.css), respaldo: CNC.side)
                                .frame(width: 44, height: 44)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(CNC.acc, lineWidth: c.puesta ? 3 : 0))
                                .overlay(Circle().stroke(CNC.line, lineWidth: 0.5))
                        }.buttonStyle(CNPulsable())
                    }
                }
                .padding(.horizontal, 4).padding(.vertical, 3)
            }
        }
    }

    private func listaVista(_ q: CNSeccion.Bloque) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            if !q.titulo.isEmpty { rotulo(q.titulo) }
            VStack(spacing: 0) {
                ForEach(q.items.indices, id: \.self) { i in
                    let it = q.items[i]
                    HStack(spacing: 12) {
                        if !it.icono.isEmpty {
                            CNSVGShape(d: it.icono)
                                .stroke(style: StrokeStyle(lineWidth: 1.7, lineCap: .round, lineJoin: .round))
                                .foregroundColor(it.color.isEmpty ? CNC.ink : cnColor(hexString: it.color))
                                .frame(width: 18, height: 18).frame(width: 32, height: 32)
                                .background(it.fondo.isEmpty ? CNC.soft : cnColor(hexString: it.fondo),
                                            in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                        } else if !it.fondo.isEmpty {
                            Text(String(it.titulo.prefix(1)).uppercased())
                                .font(.system(size: 12, weight: .heavy)).foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(cnColor(hexString: it.fondo),
                                            in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(it.titulo).font(.system(size: 15, weight: .semibold)).foregroundColor(CNC.ink).lineLimit(1)
                            if !it.detalle.isEmpty {
                                Text(it.detalle).font(.system(size: 12)).foregroundColor(CNC.pmut).lineLimit(2)
                            }
                        }
                        Spacer(minLength: 8)
                        if !it.chip.isEmpty {
                            Text(it.chip).font(.system(size: 10.5, weight: .bold)).foregroundColor(CNC.pmut)
                                .padding(.horizontal, 9).padding(.vertical, 5)
                                .background(it.chipFondo.isEmpty ? CNC.soft : cnColor(hexString: it.chipFondo), in: Capsule())
                        }
                        if !it.acciones.isEmpty {
                            Menu {
                                ForEach(it.acciones.indices, id: \.self) { k in
                                    let a = it.acciones[k]
                                    Button(role: a.peligro ? .destructive : nil) {
                                        datos.onSeccionAccion(a.accion, nil)
                                    } label: { Text(a.label) }
                                }
                            } label: {
                                Image(systemName: "ellipsis").font(.system(size: 14, weight: .bold))
                                    .foregroundColor(CNC.pmut).frame(width: 30, height: 30)
                                    .background(CNC.soft, in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                            }
                        }
                    }
                    .padding(.horizontal, 14).padding(.vertical, 11).contentShape(Rectangle())
                    .onTapGesture { if it.accion >= 0 { datos.onSeccionAccion(it.accion, nil) } }
                    .overlay(alignment: .bottom) {
                        if i < q.items.count - 1 {
                            Rectangle().fill(CNC.soft).frame(height: 0.5).padding(.leading, 58)
                        }
                    }
                }
            }
            .background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(CNC.line, lineWidth: 1))
            if !q.pie.isEmpty { rotulo(q.pie) }
        }
    }
}

/// Rejilla de N columnas sin LazyVGrid (que en iOS 15 no reparte igual las
/// alturas cuando las celdas crecen).
struct CNRejillaFija<C: View>: View {
    let columnas: Int
    let total: Int
    @ViewBuilder var celda: (Int) -> C
    var body: some View {
        let cols = max(1, columnas)
        let filas = (total + cols - 1) / cols
        VStack(spacing: 10) {
            ForEach(0..<max(0, filas), id: \.self) { f in
                HStack(alignment: .top, spacing: 10) {
                    ForEach(0..<cols, id: \.self) { c in
                        let i = f * cols + c
                        if i < total { celda(i).frame(maxWidth: .infinity) }
                        else { Color.clear.frame(maxWidth: .infinity) }
                    }
                }
            }
        }
    }
}

/// Un PNG en base64 (los dibujos del personaje, que la web rinde por nosotros).
func cnImagenBase64(_ b64: String) -> UIImage? {
    guard let d = Data(base64Encoded: b64, options: .ignoreUnknownCharacters) else { return nil }
    return UIImage(data: d)
}

/// Un color CSS suelto (o un degradado) convertido al fondo que pinta la app.
func cnFondoDeCss(_ css: String) -> CNResumenModelo.Fondo {
    let t = css.trimmingCharacters(in: .whitespaces)
    guard t.contains("gradient") else { return CNResumenModelo.Fondo(tipo: "color", color: t) }
    let dentro = t.drop(while: { $0 != "(" }).dropFirst().prefix(while: { $0 != ")" })
    var trozos = dentro.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    var angulo: Double = 180
    if let primero = trozos.first, primero.hasSuffix("deg") {
        angulo = Double(primero.replacingOccurrences(of: "deg", with: "")) ?? 180
        trozos.removeFirst()
    }
    let paradas = trozos.enumerated().map { (i, x) -> CNResumenModelo.Parada in
        let partes = x.split(separator: " ")
        let color = String(partes.first ?? "")
        var pos = trozos.count > 1 ? Double(i) / Double(trozos.count - 1) : 0
        if partes.count > 1, let p = Double(partes[1].replacingOccurrences(of: "%", with: "")) { pos = p / 100 }
        return CNResumenModelo.Parada(color: color, pos: pos)
    }
    return CNResumenModelo.Fondo(tipo: "grad", color: "", angulo: angulo, paradas: paradas)
}
