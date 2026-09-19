import SwiftUI

// Pantallas NATIVAS incrustadas en la app Capacitor. La web le pasa el JSON de
// la libreta (el de localStorage) y aquí se decodifica y se dibuja en SwiftUI.
// Todo autocontenido para no chocar con el resto del proyecto (prefijos CN…).

// ── Colores del tema Chinola (mismos valores del diseño) ────────────────────
func cnColor(_ hex: UInt) -> Color {
    Color(.sRGB, red: Double((hex >> 16) & 0xff) / 255, green: Double((hex >> 8) & 0xff) / 255, blue: Double(hex & 0xff) / 255, opacity: 1)
}
func cnColor(hexString s: String) -> Color {
    var h = s.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
    if h.count == 3 { h = h.map { "\($0)\($0)" }.joined() }
    let v = UInt64(h, radix: 16) ?? 0
    return Color(.sRGB, red: Double((v >> 16) & 0xff) / 255, green: Double((v >> 8) & 0xff) / 255, blue: Double(v & 0xff) / 255, opacity: 1)
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
    var tipo: String = ""; var monto: Double = 0; var fecha: String = ""; var medio: String = ""; var recurrente: Bool = false
    init(from d: Decoder) throws { let c = try d.container(keyedBy: K.self)
        // id puede venir como número o texto.
        if let s = try? c.decodeIfPresent(String.self, forKey: .id) { id = s ?? "" }
        else if let n = try? c.decodeIfPresent(Int.self, forKey: .id) { id = String(n ?? 0) }
        concepto = (try? c.decodeIfPresent(String.self, forKey: .concepto)) ?? ""
        categoria = (try? c.decodeIfPresent(String.self, forKey: .categoria)) ?? ""
        tipo = (try? c.decodeIfPresent(String.self, forKey: .tipo)) ?? ""
        monto = (try? c.decodeIfPresent(Double.self, forKey: .monto)) ?? 0
        fecha = (try? c.decodeIfPresent(String.self, forKey: .fecha)) ?? ""
        medio = (try? c.decodeIfPresent(String.self, forKey: .medio)) ?? ""
        recurrente = (try? c.decodeIfPresent(Bool.self, forKey: .recurrente)) ?? false }
    enum K: String, CodingKey { case id, concepto, categoria, tipo, monto, fecha, medio, recurrente }
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
func cnDiaLargo(_ iso: String) -> String {
    let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; f.locale = Locale(identifier: "en_US_POSIX")
    guard let d = f.date(from: iso) else { return iso }
    let o = DateFormatter(); o.locale = Locale(identifier: "es"); o.dateFormat = "EEEE d 'de' MMMM"
    return o.string(from: d).capitalized
}

// Estado compartido: la libreta que la web empuja + las acciones que rebotan a
// la web (abrir "nuevo movimiento", abrir el detalle).
final class CNDatos: ObservableObject {
    @Published var libreta = CNLibreta()
    var onNuevoMov: () -> Void = {}
    var onDetalleMov: (String) -> Void = { _ in }
    var onTendencia: () -> Void = {}
    var onAgregar: () -> Void = {}
    var onNuevaCategoria: () -> Void = {}
    var onNuevaMeta: () -> Void = {}
    var onAbrirCuenta: (Int) -> Void = { _ in }
    var onAbrirTarjeta: (Int) -> Void = { _ in }
    var onAbrirPrestamo: (Int) -> Void = { _ in }
    var onAbrirMeta: (Int) -> Void = { _ in }
    func cargar(json: String) { if let l = CNLibreta.desde(json: json) { libreta = l } }
}

// ── Pantalla «Movimientos» NATIVA ──────────────────────────────────────────
// Título arriba (se va con el scroll), búsqueda sticky en liquid glass real
// (material) y la lista agrupada por día. Los datos vienen del web.
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
            LazyVStack(spacing: 14, pinnedViews: [.sectionHeaders]) {
                // Título + calendario + «+» (se van con el scroll).
                HStack(alignment: .center, spacing: 10) {
                    Text("Movimientos").font(.system(size: 28, weight: .heavy)).foregroundColor(CNC.ink)
                    Spacer(minLength: 8)
                    circulo("calendar", acento: false) {}
                    circulo("plus", acento: true) { datos.onNuevoMov() }
                }
                .padding(.horizontal, 16).padding(.top, 8)

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
            .padding(.horizontal, 14).padding(.vertical, 12)
            // Búsqueda en liquid glass real (material translúcido).
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.5), lineWidth: 0.8))
            Image(systemName: "line.3.horizontal.decrease").font(.system(size: 17, weight: .semibold)).foregroundColor(CNC.ink)
                .frame(width: 46, height: 46)
                .background(.ultraThinMaterial, in: Circle())
                .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 0.8))
        }
        .padding(.horizontal, 14).padding(.top, 6).padding(.bottom, 10)
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
                Image(systemName: icono).font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
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
                Image(systemName: icono).font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(cnHex: 0x20180a))
                    .frame(width: 46, height: 46).background(CNC.acc).clipShape(Circle())
                    .shadow(color: CNC.acc.opacity(0.4), radius: 8, y: 3)
            } else {
                Image(systemName: icono).font(.system(size: 18, weight: .semibold)).foregroundColor(CNC.ink)
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial, in: Circle())   // glass
                    .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 0.8))
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
    @Published var activa: String = "resumen"
    @Published var titulos: Bool = true
    var alTocar: (String) -> Void = { _ in }
}

struct CNBarraMenu: View {
    @ObservedObject var estado: CNMenuEstado
    struct Item { let id: String; let label: String; let path: String }
    let items: [Item] = [
        .init(id: "resumen", label: "Resumen", path: CNTabIcono.resumen),
        .init(id: "movs", label: "Movs.", path: CNTabIcono.movs),
        .init(id: "cuentas", label: "Cuentas", path: CNTabIcono.cuentas),
        .init(id: "plan", label: "Plan", path: CNTabIcono.plan),
        .init(id: "perfil", label: "Perfil", path: "")
    ]
    var body: some View {
        HStack(spacing: 0) {
            ForEach(items, id: \.id) { it in
                Button { estado.alTocar(it.id) } label: {
                    VStack(spacing: 4) {
                        if it.id == "perfil" {
                            Text("🍊").font(.system(size: 19))
                                .frame(width: 26, height: 26)
                                .background(CNC.acc.opacity(estado.activa == it.id ? 1 : 0.85))
                                .clipShape(Circle())
                        } else {
                            CNIconoTab(d: it.path).frame(height: 26)   // los iconos EXACTOS de la app
                        }
                        if estado.titulos {
                            Text(it.label).font(.system(size: 11, weight: .heavy)).tracking(-0.1)
                        }
                    }
                    .foregroundColor(estado.activa == it.id ? CNC.ink : CNC.pmut)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, estado.titulos ? 9 : 12)
        .padding(.bottom, 9)
        // Liquid glass de verdad: material translúcido (deja ver los movimientos
        // pasar por detrás al hacer scroll), píldora flotante con brillo y sombra.
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.16), radius: 24, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.white.opacity(0.6), lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 2)
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
                            .frame(width: 44, height: 44)
                            .background(.ultraThinMaterial, in: Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 0.6))
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
}

struct CNIconoTab: View {
    let d: String
    var body: some View {
        CNSVGShape(d: d).stroke(style: StrokeStyle(lineWidth: 2.3, lineCap: .round, lineJoin: .round)).frame(width: 24, height: 24)
    }
}

// ── Pantalla «Cuentas» NATIVA ───────────────────────────────────────────────
struct CNCuentas: View {
    @ObservedObject var datos: CNDatos
    @State private var oculto = false
    private func dinero(_ n: Double) -> String { oculto ? "RD$••••" : cnDinero(n) }

    var body: some View {
        let lb = datos.libreta
        return ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center, spacing: 10) {
                    Text("Cuentas").font(.system(size: 28, weight: .heavy)).foregroundColor(CNC.ink)
                    Spacer(minLength: 8)
                    circuloGlass("line.3.horizontal.decrease") {}
                    circuloAcc("plus") { datos.onAgregar() }
                }
                .padding(.horizontal, 4).padding(.top, 8)

                patrimonio(lb)

                seccion("Cuentas") {
                    if lb.cuentas.isEmpty { vacio("Aquí saldrán tus cuentas: efectivo, banco, ahorros.") }
                    else { tarjetaLista { ForEach(lb.cuentas.indices, id: \.self) { i in
                        if i > 0 { div(62) }
                        let c = lb.cuentas[i]
                        fila(icono: c.icono, color: cnColor(hexString: c.color), nombre: c.nombre,
                             sub: (c.clase == "efectivo" ? "En mano" : (c.banco.isEmpty ? "Sin banco" : c.banco)),
                             monto: dinero(c.saldo), montoColor: CNC.ink) { datos.onAbrirCuenta(c.id) }
                    } } }
                }
                seccion("Tarjetas de crédito") {
                    if lb.tarjetas.isEmpty { vacio("Aquí saldrán tus tarjetas de crédito, con su deuda y sus fechas.") }
                    else { tarjetaLista { ForEach(lb.tarjetas.indices, id: \.self) { i in
                        if i > 0 { div(62) }
                        let t = lb.tarjetas[i]
                        fila(icono: "creditcard.fill", color: cnColor(hexString: t.color), nombre: t.nombre,
                             sub: "Disp. \(dinero(t.disponible)) · corte \(t.corte)", monto: dinero(t.saldo), montoColor: CNC.neg) { datos.onAbrirTarjeta(t.id) }
                    } } }
                }
                seccion("Préstamos y fiados") {
                    if lb.prestamos.isEmpty { vacio("Aquí saldrán tus préstamos y lo que llevas pagado.") }
                    else { tarjetaLista { ForEach(lb.prestamos.indices, id: \.self) { i in
                        if i > 0 { div(62) }
                        let p = lb.prestamos[i]
                        fila(icono: "hand.raised.fill", color: cnColor(hexString: p.color), nombre: p.nombre,
                             sub: p.sentido == "meDeben" ? "Te debe" : "Le debes", monto: dinero(p.pendiente),
                             montoColor: p.sentido == "meDeben" ? CNC.pos : CNC.neg) { datos.onAbrirPrestamo(p.id) }
                    } } }
                }
                Color.clear.frame(height: 120)
            }
            .padding(.horizontal, 14).padding(.top, 6)
        }
        .background(CNC.scr.ignoresSafeArea())
    }

    private func patrimonio(_ lb: CNLibreta) -> some View {
        VStack(spacing: 14) {
            HStack {
                Button { oculto.toggle() } label: { chip(oculto ? "eye.slash" : "eye") }.buttonStyle(.plain)
                Spacer()
                Text("Patrimonio").font(.system(size: 15, weight: .semibold)).foregroundColor(.white.opacity(0.92))
                Spacer()
                Button { datos.onTendencia() } label: { chip("chart.line.uptrend.xyaxis") }.buttonStyle(.plain)
            }
            Text(dinero(lb.patrimonio)).font(.system(size: 34, weight: .heavy)).foregroundColor(.white)
            HStack(spacing: 0) {
                col("Activos", dinero(lb.totalCuentas + lb.porCobrar))
                col("Pasivos", dinero(lb.deudaTotal))
            }
        }
        .padding(.horizontal, 18).padding(.vertical, 18).frame(maxWidth: .infinity)
        .background(LinearGradient(colors: [cnColor(0x0e4a29), cnColor(0x093a20)], startPoint: .top, endPoint: .bottom))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: cnColor(0x093a20).opacity(0.28), radius: 16, y: 8)
    }
    private func chip(_ ic: String) -> some View {
        Image(systemName: ic).font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
            .frame(width: 36, height: 36).background(Color.white.opacity(0.16)).clipShape(Circle())
    }
    private func col(_ t: String, _ v: String) -> some View {
        VStack(spacing: 3) { Text(t).font(.system(size: 12.5)).foregroundColor(.white.opacity(0.72)); Text(v).font(.system(size: 15, weight: .bold)).foregroundColor(.white) }.frame(maxWidth: .infinity)
    }
    private func seccion<C: View>(_ t: String, @ViewBuilder _ c: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(t.uppercased()).font(.system(size: 12.5, weight: .semibold)).tracking(0.3).foregroundColor(CNC.pmut).padding(.leading, 4)
            c()
        }
    }
    private func tarjetaLista<C: View>(@ViewBuilder _ c: () -> C) -> some View {
        VStack(spacing: 0) { c() }
            .background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(CNC.line, lineWidth: 0.5))
    }
    private func div(_ s: CGFloat) -> some View { Rectangle().fill(CNC.line).frame(height: 0.5).padding(.leading, s) }
    private func vacio(_ t: String) -> some View {
        Text(t).font(.system(size: 13.5)).foregroundColor(CNC.pmut).frame(maxWidth: .infinity, alignment: .leading).fixedSize(horizontal: false, vertical: true)
            .padding(16).background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(CNC.line, lineWidth: 1))
    }
    private func fila(icono: String, color: Color, nombre: String, sub: String, monto: String, montoColor: Color, tap: @escaping () -> Void) -> some View {
        Button(action: tap) {
            HStack(spacing: 12) {
                Image(systemName: icono).font(.system(size: 16, weight: .semibold)).foregroundColor(color)
                    .frame(width: 40, height: 40).background(color.opacity(0.15)).clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                VStack(alignment: .leading, spacing: 2) {
                    Text(nombre).font(.system(size: 15.5, weight: .semibold)).foregroundColor(CNC.ink)
                    Text(sub).font(.system(size: 12.5)).foregroundColor(CNC.pmut)
                }
                Spacer(minLength: 8)
                Text(monto).font(.system(size: 15, weight: .heavy)).foregroundColor(montoColor)
                Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundColor(CNC.pmut.opacity(0.6))
            }.padding(.horizontal, 14).padding(.vertical, 11)
        }.buttonStyle(.plain)
    }
    private func circuloGlass(_ ic: String, _ tap: @escaping () -> Void) -> some View {
        Button(action: tap) { Image(systemName: ic).font(.system(size: 17, weight: .semibold)).foregroundColor(CNC.ink)
            .frame(width: 44, height: 44).background(.ultraThinMaterial, in: Circle()).overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 0.8)) }.buttonStyle(.plain)
    }
    private func circuloAcc(_ ic: String, _ tap: @escaping () -> Void) -> some View {
        Button(action: tap) { Image(systemName: ic).font(.system(size: 20, weight: .semibold)).foregroundColor(Color(cnHex: 0x20180a))
            .frame(width: 46, height: 46).background(CNC.acc).clipShape(Circle()).shadow(color: CNC.acc.opacity(0.4), radius: 8, y: 3) }.buttonStyle(.plain)
    }
}

// ── Pantalla «Plan» NATIVA ──────────────────────────────────────────────────
struct CNPlan: View {
    @ObservedObject var datos: CNDatos
    @State private var seg = 0

    var body: some View {
        let lb = datos.libreta
        return ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center, spacing: 10) {
                    Text("Plan").font(.system(size: 28, weight: .heavy)).foregroundColor(CNC.ink)
                    Spacer(minLength: 8)
                    circuloGlass("calendar") {}
                    circuloAcc("plus") { seg == 0 ? datos.onNuevaCategoria() : datos.onNuevaMeta() }
                }
                .padding(.horizontal, 4).padding(.top, 8)

                segmentos

                if seg == 0 { presupuesto(lb) } else { metas(lb) }
                Color.clear.frame(height: 120)
            }
            .padding(.horizontal, 14).padding(.top, 6)
        }
        .background(CNC.scr.ignoresSafeArea())
    }

    private var segmentos: some View {
        HStack(spacing: 6) {
            ForEach(["Presupuesto", "Metas"].indices, id: \.self) { i in
                Text(["Presupuesto", "Metas"][i])
                    .font(.system(size: 14, weight: i == seg ? .bold : .semibold)).foregroundColor(i == seg ? .white : CNC.pmut)
                    .frame(maxWidth: .infinity).padding(.vertical, 10)
                    .background(i == seg ? cnColor(0x093a20) : Color.clear).clipShape(Capsule())
                    .onTapGesture { seg = i }
            }
        }.padding(4).background(CNC.soft).clipShape(Capsule())
    }

    private func presupuesto(_ lb: CNLibreta) -> some View {
        let cats = lb.categorias.filter { $0.tipo == "Gasto" }
        let gastado = cats.reduce(0.0) { $0 + lb.gastadoCategoria($1.nombre) }
        return VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                HStack { Text(cnDinero(gastado)).font(.system(size: 26, weight: .heavy)).foregroundColor(CNC.pos)
                    Spacer(); Text("de \(cnDinero(lb.presupuestoTotal))").font(.system(size: 14)).foregroundColor(CNC.pmut) }
                barra(gastado, lb.presupuestoTotal, CNC.pos)
            }.padding(16).background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 20)).overlay(RoundedRectangle(cornerRadius: 20).stroke(CNC.line, lineWidth: 1))
            if cats.isEmpty { vacio("Crea categorías para organizar tus gastos.") }
            else { VStack(spacing: 0) { ForEach(cats.indices, id: \.self) { i in
                filaCat(cats[i], lb); if i < cats.count - 1 { Rectangle().fill(CNC.line).frame(height: 0.5).padding(.leading, 52) }
            } }.padding(.vertical, 4).background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 20)).overlay(RoundedRectangle(cornerRadius: 20).stroke(CNC.line, lineWidth: 1)) }
        }
    }
    private func filaCat(_ c: CNCategoria, _ lb: CNLibreta) -> some View {
        let g = lb.gastadoCategoria(c.nombre); let pas = c.limite > 0 && g > c.limite
        return HStack(spacing: 12) {
            Image(systemName: c.icono).font(.system(size: 15, weight: .semibold)).foregroundColor(cnColor(hexString: c.color))
                .frame(width: 40, height: 40).background(cnColor(hexString: c.color).opacity(0.15)).clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            VStack(alignment: .leading, spacing: 5) {
                HStack { Text(c.nombre).font(.system(size: 15.5, weight: .semibold)).foregroundColor(CNC.ink)
                    Spacer(); Text(cnDinero(g)).font(.system(size: 14.5, weight: .heavy)).foregroundColor(pas ? CNC.neg : CNC.pos) }
                barra(g, c.limite, pas ? CNC.neg : CNC.pos)
                Text(c.limite > 0 ? "\(cnDinero(g)) de \(cnDinero(c.limite))" : "\(cnDinero(g)) · sin tope").font(.system(size: 12)).foregroundColor(CNC.pmut)
            }
        }.padding(.horizontal, 12).padding(.vertical, 11)
    }
    private func metas(_ lb: CNLibreta) -> some View {
        VStack(spacing: 12) {
            if lb.metas.isEmpty { vacio("Ponte una meta de ahorro y ve cuánto te falta cada mes.") }
            else { ForEach(lb.metas.indices, id: \.self) { i in filaMeta(lb.metas[i]) } }
        }
    }
    private func filaMeta(_ m: CNMeta) -> some View {
        Button { datos.onAbrirMeta(m.id) } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    Image(systemName: m.icono).font(.system(size: 15, weight: .semibold)).foregroundColor(cnColor(hexString: m.color))
                        .frame(width: 40, height: 40).background(cnColor(hexString: m.color).opacity(0.15)).clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    VStack(alignment: .leading, spacing: 1) {
                        Text(m.nombre).font(.system(size: 15.5, weight: .semibold)).foregroundColor(CNC.ink)
                        Text("\(Int(m.progreso * 100))% · faltan \(cnDinero(max(0, m.meta - m.ahorrado)))").font(.system(size: 12)).foregroundColor(CNC.pmut)
                    }
                    Spacer(minLength: 6)
                    Text(cnDinero(m.ahorrado)).font(.system(size: 15, weight: .heavy)).foregroundColor(cnColor(hexString: m.color))
                }
                barra(m.ahorrado, m.meta, cnColor(hexString: m.color))
            }.padding(16).background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 20)).overlay(RoundedRectangle(cornerRadius: 20).stroke(CNC.line, lineWidth: 1))
        }.buttonStyle(.plain)
    }
    private func barra(_ v: Double, _ total: Double, _ color: Color) -> some View {
        GeometryReader { g in ZStack(alignment: .leading) {
            Capsule().fill(CNC.line)
            Capsule().fill(color).frame(width: total > 0 ? min(g.size.width, g.size.width * CGFloat(v / total)) : 0)
        } }.frame(height: 7)
    }
    private func vacio(_ t: String) -> some View {
        Text(t).font(.system(size: 13.5)).foregroundColor(CNC.pmut).frame(maxWidth: .infinity).multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
            .padding(.vertical, 24).padding(.horizontal, 16).background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(CNC.line, style: StrokeStyle(lineWidth: 1, dash: [5, 4])))
    }
    private func circuloGlass(_ ic: String, _ tap: @escaping () -> Void) -> some View {
        Button(action: tap) { Image(systemName: ic).font(.system(size: 17, weight: .semibold)).foregroundColor(CNC.ink)
            .frame(width: 44, height: 44).background(.ultraThinMaterial, in: Circle()).overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 0.8)) }.buttonStyle(.plain)
    }
    private func circuloAcc(_ ic: String, _ tap: @escaping () -> Void) -> some View {
        Button(action: tap) { Image(systemName: ic).font(.system(size: 20, weight: .semibold)).foregroundColor(Color(cnHex: 0x20180a))
            .frame(width: 46, height: 46).background(CNC.acc).clipShape(Circle()).shadow(color: CNC.acc.opacity(0.4), radius: 8, y: 3) }.buttonStyle(.plain)
    }
}
