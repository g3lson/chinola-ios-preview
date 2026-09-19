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
struct CNCuenta: Decodable { var id: Int = 0; var nombre: String = ""; var saldo: Double = 0; var color: String = "#137d41"; var icono: String = "banknote.fill"
    init(from d: Decoder) throws { let c = try d.container(keyedBy: K.self)
        id = (try? c.decodeIfPresent(Int.self, forKey: .id)) ?? 0
        nombre = (try? c.decodeIfPresent(String.self, forKey: .nombre)) ?? ""
        saldo = (try? c.decodeIfPresent(Double.self, forKey: .saldo)) ?? 0
        color = (try? c.decodeIfPresent(String.self, forKey: .color)) ?? "#137d41"
        icono = (try? c.decodeIfPresent(String.self, forKey: .icono)) ?? "banknote.fill" }
    enum K: String, CodingKey { case id, nombre, saldo, color, icono } }

struct CNCategoria: Decodable { var nombre: String = ""; var color: String = "#e0a92e"; var icono: String = "tag.fill"
    init(from d: Decoder) throws { let c = try d.container(keyedBy: K.self)
        nombre = (try? c.decodeIfPresent(String.self, forKey: .nombre)) ?? ""
        color = (try? c.decodeIfPresent(String.self, forKey: .color)) ?? "#e0a92e"
        icono = (try? c.decodeIfPresent(String.self, forKey: .icono)) ?? "tag.fill" }
    enum K: String, CodingKey { case nombre, color, icono } }

struct CNTarjeta: Decodable { var id: Int = 0; var nombre: String = ""; var saldo: Double = 0
    init(from d: Decoder) throws { let c = try d.container(keyedBy: K.self)
        id = (try? c.decodeIfPresent(Int.self, forKey: .id)) ?? 0
        nombre = (try? c.decodeIfPresent(String.self, forKey: .nombre)) ?? ""
        saldo = (try? c.decodeIfPresent(Double.self, forKey: .saldo)) ?? 0 }
    enum K: String, CodingKey { case id, nombre, saldo } }

struct CNPrestamo: Decodable { var total: Double = 0; var pagado: Double = 0; var sentido: String = "meDeben"
    init(from d: Decoder) throws { let c = try d.container(keyedBy: K.self)
        total = (try? c.decodeIfPresent(Double.self, forKey: .total)) ?? 0
        pagado = (try? c.decodeIfPresent(Double.self, forKey: .pagado)) ?? 0
        sentido = (try? c.decodeIfPresent(String.self, forKey: .sentido)) ?? "meDeben" }
    enum K: String, CodingKey { case total, pagado, sentido }
    var pendiente: Double { max(0, total - pagado) } }

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
    var tx: [CNMov] = []
    init() {}
    init(from d: Decoder) throws { let c = try d.container(keyedBy: K.self)
        nombre = (try? c.decodeIfPresent(String.self, forKey: .nombre)) ?? "Personal"
        cuentas = (try? c.decodeIfPresent([CNCuenta].self, forKey: .cuentas)) ?? []
        tarjetas = (try? c.decodeIfPresent([CNTarjeta].self, forKey: .tarjetas)) ?? []
        prestamos = (try? c.decodeIfPresent([CNPrestamo].self, forKey: .prestamos)) ?? []
        categorias = (try? c.decodeIfPresent([CNCategoria].self, forKey: .categorias)) ?? []
        tx = (try? c.decodeIfPresent([CNMov].self, forKey: .tx)) ?? [] }
    enum K: String, CodingKey { case nombre, cuentas, tarjetas, prestamos, categorias, tx }

    func categoria(_ nombre: String) -> CNCategoria? { categorias.first { $0.nombre == nombre } }

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
            .background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(CNC.line, lineWidth: 1))
            Image(systemName: "line.3.horizontal.decrease").font(.system(size: 17, weight: .semibold)).foregroundColor(CNC.ink)
                .frame(width: 46, height: 46).background(CNC.card).clipShape(Circle())
                .overlay(Circle().stroke(CNC.line, lineWidth: 1))
        }
        .padding(.horizontal, 14).padding(.top, 6).padding(.bottom, 10)
        .background(.regularMaterial)   // liquid glass real: el contenido pasa por detrás
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

    private func circulo(_ icono: String, acento: Bool, _ tap: @escaping () -> Void) -> some View {
        Button(action: tap) {
            Image(systemName: icono).font(.system(size: acento ? 20 : 18, weight: .semibold))
                .foregroundColor(acento ? Color(cnHex: 0x20180a) : CNC.ink)
                .frame(width: acento ? 46 : 44, height: acento ? 46 : 44)
                .background(acento ? CNC.acc : CNC.card).clipShape(Circle())
                .overlay(acento ? nil : Circle().stroke(CNC.line, lineWidth: 1))
                .shadow(color: acento ? CNC.acc.opacity(0.4) : .clear, radius: 8, y: 3)
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
    struct Item { let id: String; let label: String; let icono: String }
    let items: [Item] = [
        .init(id: "resumen", label: "Resumen", icono: "square.grid.2x2.fill"),
        .init(id: "movs", label: "Movs.", icono: "arrow.up.arrow.down"),
        .init(id: "cuentas", label: "Cuentas", icono: "creditcard.fill"),
        .init(id: "plan", label: "Plan", icono: "chart.pie.fill"),
        .init(id: "perfil", label: "Perfil", icono: "person.crop.circle.fill")
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
                            Image(systemName: it.icono).font(.system(size: 19, weight: .semibold))
                                .frame(height: 26)
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
        .padding(.horizontal, 6)
        .padding(.top, estado.titulos ? 9 : 12)
        .padding(.bottom, 8)
        .background(
            ZStack {
                // Material más frosteado + un velo claro para que el vidrio se
                // note también sobre el fondo crema de Chinola.
                RoundedRectangle(cornerRadius: 28, style: .continuous).fill(.regularMaterial)
                RoundedRectangle(cornerRadius: 28, style: .continuous).fill(Color.white.opacity(0.28))
            }
            .shadow(color: .black.opacity(0.18), radius: 22, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.55), lineWidth: 1)
        )
        .padding(.horizontal, 14)
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
