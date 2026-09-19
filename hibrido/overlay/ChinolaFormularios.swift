import SwiftUI
import UIKit

// Hojas (formularios) NATIVAS. Recogen los datos en SwiftUI y guardan reusando
// TODA la lógica de la web (`enviarHoja`) a través de `datos.onGuardarHoja`, así
// no se reimplementa nada del dinero. Todo con el mismo vidrio del resto.

// ── Contenedor común (mismo vidrio que «Nuevo movimiento») ──────────────────
struct CNHoja<Content: View>: View {
    let titulo: String
    var guardarTexto: String = "Guardar"
    var onClose: () -> Void
    var onGuardar: () -> Void
    @ViewBuilder var content: () -> Content

    var body: some View {
        // Sin fondo ni esquinas propias: la hoja es del sistema (detents,
        // tirador, arrastre elástico y atenuado), como en cualquier app de Apple.
        VStack(spacing: 0) {
                cabecera
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) { content(); Color.clear.frame(height: 24) }
                        .padding(.horizontal, 16).padding(.top, 4)
                }
                // El botón principal, grande y abajo: donde llega el pulgar.
                CNBotonGuardar(texto: guardarTexto, accion: onGuardar)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(CNC.scr.ignoresSafeArea())
        .environment(\.locale, Locale(identifier: "es_DO"))
    }

    private var cabecera: some View { CNHojaCabecera(titulo: titulo, onClose: onClose) }
}

/// Cabecera de hoja: tirador, cerrar en vidrio y el título. Sin más ruido: la
/// acción de guardar vive abajo, en un botón grande.
struct CNHojaCabecera: View {
    let titulo: String
    var onClose: () -> Void
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text(titulo).font(.system(size: 17, weight: .bold)).foregroundColor(CNC.ink)
                HStack {
                    Button {
                        UISelectionFeedbackGenerator().selectionChanged()
                        onClose()
                    } label: {
                        Image(systemName: "xmark").font(.system(size: 15, weight: .bold)).foregroundColor(CNC.pmut)
                            .frame(width: 36, height: 36).cnVidrio(Circle())
                    }.buttonStyle(.plain)
                    Spacer()
                }
            }.padding(.horizontal, 16).padding(.top, 14).padding(.bottom, 14)
        }
    }
}

/// Botón grande de guardar, fijo al pie de la hoja y en vidrio del color de la
/// marca, sobre una franja translúcida para que el contenido pase por detrás.
struct CNBotonGuardar: View {
    let texto: String
    var accion: () -> Void
    var body: some View {
        VStack(spacing: 0) {
            Rectangle().fill(CNC.line).frame(height: 0.5)
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                accion()
            } label: {
                Text(texto).font(.system(size: 17, weight: .bold)).foregroundColor(Color(cnHex: 0x20180a))
                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(CNC.acc, in: Capsule())
            }
            .buttonStyle(CNPulsable())
            .padding(.horizontal, 16).padding(.top, 10).padding(.bottom, 8)
        }
        .background(CNC.scr)
    }
}

/// Se hunde un poco al pulsar, como los botones del sistema.
struct CNPulsable: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.14), value: configuration.isPressed)
    }
}

// ── Piezas compartidas de las hojas ─────────────────────────────────────────
enum CNPaleta { static let colores = ["#137d41", "#2f6fd6", "#3b4fd0", "#7a4fd0", "#c65f9c", "#e0822e", "#e0a92e", "#5a7a2e"] }

func cnHojaTitulo(_ t: String) -> some View {
    Text(t.uppercased()).font(.system(size: 12.5, weight: .semibold)).tracking(0.3).foregroundColor(CNC.pmut).padding(.leading, 16).frame(maxWidth: .infinity, alignment: .leading)
}
func cnGrupoHoja<C: View>(@ViewBuilder _ c: () -> C) -> some View {
    VStack(spacing: 0) { c() }.background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous)).overlay(RoundedRectangle(cornerRadius: 16).stroke(CNC.line, lineWidth: 0.5))
}
func cnDiviHoja() -> some View { Rectangle().fill(CNC.line).frame(height: 0.5).padding(.leading, 16) }
func cnCuadroHoja(_ ic: String, _ tinte: Color) -> some View {
    Image(systemName: ic).font(.system(size: 14, weight: .semibold)).foregroundColor(.white).frame(width: 29, height: 29).background(tinte).clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
}

struct CNMontoCampo: View {
    @Binding var monto: String
    var paso: Double = 100
    private var valor: Double { Double(monto.replacingOccurrences(of: ",", with: "")) ?? 0 }
    private func fijar(_ n: Double) {
        let v = max(0, n)
        monto = v == v.rounded() ? String(Int(v)) : String(format: "%.2f", v)
    }
    var body: some View {
        cnGrupoHoja {
            VStack(spacing: 6) {
                Text("MONTO").font(.system(size: 11, weight: .semibold)).tracking(0.4).foregroundColor(CNC.pmut)
                ZStack {
                    // El número, centrado en la tarjeta pase lo que pase.
                    HStack(alignment: .firstTextBaseline, spacing: 5) {
                        Text("RD$").font(.system(size: 18, weight: .heavy)).foregroundColor(CNC.pmut)
                        TextField("0", text: $monto)
                            .font(.system(size: 38, weight: .heavy)).foregroundColor(CNC.ink)
                            .keyboardType(.decimalPad).multilineTextAlignment(.center)
                            .fixedSize()
                    }
                    HStack {
                        CNPasoBoton(icono: "minus") { fijar(valor - paso) }
                        Spacer()
                        CNPasoBoton(icono: "plus") { fijar(valor + paso) }
                    }
                }
                .padding(.horizontal, 14)
            }
            .frame(maxWidth: .infinity).padding(.vertical, 18)
        }
    }
}

/// Los botones − y + del monto, en vidrio.
struct CNPasoBoton: View {
    let icono: String
    var accion: () -> Void
    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            accion()
        } label: {
            Image(systemName: icono).font(.system(size: 16, weight: .bold)).foregroundColor(CNC.ink)
                .frame(width: 40, height: 40).cnVidrio(Circle())
        }.buttonStyle(.plain)
    }
}

/// Categorías como fichas, con su icono y su color: se elige de un vistazo,
/// sin abrir un menú.
struct CNChipsCategoria: View {
    @ObservedObject var datos: CNDatos
    @Binding var categoria: String
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(datos.libreta.categorias, id: \.nombre) { c in
                    ficha(c.nombre, cnColor(hexString: c.color), c.icono)
                }
                ficha("Otros", cnColor(0x9a9a8e), "tag")
            }
            .padding(.leading, 2).padding(.trailing, 16).padding(.vertical, 2)
        }
        .mask(
            LinearGradient(stops: [.init(color: .black, location: 0),
                                   .init(color: .black, location: 0.92),
                                   .init(color: .clear, location: 1)],
                           startPoint: .leading, endPoint: .trailing)
        )
    }
    private func ficha(_ nombre: String, _ color: Color, _ icono: String) -> some View {
        let puesta = categoria == nombre || (categoria.isEmpty && nombre == "Otros")
        return Button {
            UISelectionFeedbackGenerator().selectionChanged()
            categoria = nombre
        } label: {
            HStack(spacing: 7) {
                cnGlifo(icono, tam: 14, grosor: 2.2)
                    .foregroundColor(puesta ? .white : color)
                Text(nombre).font(.system(size: 14, weight: .semibold))
                    .foregroundColor(puesta ? .white : CNC.ink)
            }
            .padding(.horizontal, 13).padding(.vertical, 9)
            .background(
                Capsule().fill(puesta ? color : CNC.card)
                    .overlay(Capsule().stroke(puesta ? Color.clear : CNC.line, lineWidth: 0.8))
            )
        }.buttonStyle(.plain)
    }
}

struct CNCampoTexto: View {
    let placeholder: String
    @Binding var texto: String
    var teclado: UIKeyboardType = .default
    var body: some View {
        cnGrupoHoja { TextField(placeholder, text: $texto).font(.system(size: 16)).foregroundColor(CNC.ink).keyboardType(teclado).padding(.horizontal, 15).padding(.vertical, 13) }
    }
}

struct CNMedioFila: View {
    @ObservedObject var datos: CNDatos
    @Binding var medio: String
    private var nombre: String {
        if medio.hasPrefix("cuenta:"), let id = Int(medio.dropFirst(7)), let c = datos.libreta.cuentas.first(where: { $0.id == id }) { return c.nombre }
        return "Efectivo"
    }
    var body: some View {
        Menu {
            ForEach(datos.libreta.cuentas) { c in Button(c.nombre) { medio = "cuenta:\(c.id)" } }
            Button("Efectivo") { medio = "efectivo" }
        } label: {
            HStack(spacing: 12) { cnCuadroHoja("banknote.fill", CNC.info); Text("De dónde sale").font(.system(size: 16)).foregroundColor(CNC.ink); Spacer(minLength: 8); Text(nombre).font(.system(size: 15)).foregroundColor(CNC.pmut); Image(systemName: "chevron.up.chevron.down").font(.system(size: 11, weight: .semibold)).foregroundColor(CNC.pmut.opacity(0.6)) }.padding(.horizontal, 14).padding(.vertical, 11)
        }
    }
}

struct CNColorFila: View {
    @Binding var color: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            cnHojaTitulo("Color")
            HStack(spacing: 10) {
                ForEach(CNPaleta.colores, id: \.self) { hx in
                    Circle().fill(cnColor(hexString: hx)).frame(width: 30, height: 30)
                        .overlay(Circle().stroke(Color.white, lineWidth: color == hx ? 3 : 0))
                        .overlay(Circle().stroke(CNC.line, lineWidth: 0.5))
                        .onTapGesture { color = hx }
                }
                Spacer(minLength: 0)
            }.padding(.horizontal, 4)
        }
    }
}

// ── Monto: abono / aporte / pago de tarjeta ─────────────────────────────────
struct CNMontoHoja: View {
    @ObservedObject var datos: CNDatos
    let tipo: String                 // "abono" | "aporte" | "pagoTarjeta"
    let extra: [String: Any]         // { id, nombre, saldo?… }
    var onClose: () -> Void
    @State private var monto = ""
    @State private var medio = "efectivo"

    private var titulo: String { tipo == "abono" ? "Registrar abono" : (tipo == "aporte" ? "Aportar a la meta" : "Pagar la tarjeta") }

    var body: some View {
        CNHoja(titulo: titulo, onClose: onClose, onGuardar: guardar) {
            CNMontoCampo(monto: $monto)
            if tipo != "pagoTarjeta" {
                cnGrupoHoja { CNMedioFila(datos: datos, medio: $medio) }
            }
        }
        .onAppear { if medio == "efectivo", let c = datos.libreta.cuentas.first { medio = "cuenta:\(c.id)" } }
    }

    private func guardar() {
        let n = Double(monto.replacingOccurrences(of: ",", with: "")) ?? 0
        guard n > 0 else { onClose(); return }
        var form: [String: Any] = ["monto": n]
        if tipo != "pagoTarjeta" { form["medio"] = medio }
        datos.onGuardarHoja(tipo, form, extra)
        onClose()
    }
}

// ── Nueva cuenta ────────────────────────────────────────────────────────────
struct CNFormCuenta: View {
    @ObservedObject var datos: CNDatos
    var onClose: () -> Void
    @State private var nombre = ""
    @State private var banco = ""
    @State private var saldo = ""
    @State private var clase = "banco"
    @State private var color = CNPaleta.colores[0]
    private let clases: [(String, String, String)] = [("banco", "Banco", "banco"), ("efectivo", "Efectivo", "billete"), ("billetera", "Billetera", "telefono"), ("inversion", "Inversión", "grafico"), ("ahorro", "Ahorro", "hucha")]

    var body: some View {
        CNHoja(titulo: "Nueva cuenta", onClose: onClose, onGuardar: guardar) {
            CNCampoTexto(placeholder: "Nombre (ej. Cuenta principal)", texto: $nombre)
            CNCampoTexto(placeholder: "Banco (opcional)", texto: $banco)
            VStack(spacing: 6) { cnHojaTitulo("Saldo actual"); CNMontoCampo(monto: $saldo) }
            VStack(alignment: .leading, spacing: 8) {
                cnHojaTitulo("Tipo")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) { ForEach(clases, id: \.0) { c in
                        HStack(spacing: 6) { cnGlifo(c.2, tam: 15); Text(c.1).font(.system(size: 13.5, weight: .semibold)) }
                            .foregroundColor(clase == c.0 ? .white : CNC.ink).padding(.horizontal, 13).padding(.vertical, 9)
                            .background(clase == c.0 ? cnColor(0x093a20) : CNC.card).clipShape(Capsule())
                            .overlay(Capsule().stroke(CNC.line, lineWidth: clase == c.0 ? 0 : 0.5)).onTapGesture { clase = c.0 }
                    } }.padding(.horizontal, 2)
                }
            }
            CNColorFila(color: $color)
        }
    }

    private func guardar() {
        let nm = nombre.trimmingCharacters(in: .whitespaces); guard !nm.isEmpty else { return }
        let ic = clases.first { $0.0 == clase }?.2 ?? "banco"
        datos.onGuardarHoja("cuenta", ["nombre": nm, "banco": banco, "saldo": Double(saldo) ?? 0, "clase": clase, "icono": ic, "color": color], nil)
        onClose()
    }
}

// ── Nueva tarjeta ───────────────────────────────────────────────────────────
struct CNFormTarjeta: View {
    @ObservedObject var datos: CNDatos
    var onClose: () -> Void
    @State private var nombre = ""
    @State private var banco = ""
    @State private var limite = ""
    @State private var saldo = ""
    @State private var corte = "20"
    @State private var pago = "5"
    @State private var color = CNPaleta.colores[3]

    var body: some View {
        CNHoja(titulo: "Nueva tarjeta", onClose: onClose, onGuardar: guardar) {
            CNCampoTexto(placeholder: "Nombre (ej. Visa Popular)", texto: $nombre)
            CNCampoTexto(placeholder: "Banco (opcional)", texto: $banco)
            VStack(spacing: 6) { cnHojaTitulo("Límite"); CNMontoCampo(monto: $limite) }
            VStack(spacing: 6) { cnHojaTitulo("Deuda actual"); CNMontoCampo(monto: $saldo) }
            VStack(spacing: 6) {
                cnHojaTitulo("Días de corte y de pago")
                cnGrupoHoja {
                    HStack(spacing: 12) { cnCuadroHoja("calendar", CNC.neg); Text("Día de corte").font(.system(size: 16)).foregroundColor(CNC.ink); Spacer(); TextField("20", text: $corte).keyboardType(.numberPad).multilineTextAlignment(.trailing).frame(width: 54).foregroundColor(CNC.pmut) }.padding(.horizontal, 14).padding(.vertical, 9)
                    cnDiviHoja()
                    HStack(spacing: 12) { cnCuadroHoja("creditcard.fill", CNC.info); Text("Día de pago").font(.system(size: 16)).foregroundColor(CNC.ink); Spacer(); TextField("5", text: $pago).keyboardType(.numberPad).multilineTextAlignment(.trailing).frame(width: 54).foregroundColor(CNC.pmut) }.padding(.horizontal, 14).padding(.vertical, 9)
                }
            }
            CNColorFila(color: $color)
        }
    }

    private func guardar() {
        let nm = nombre.trimmingCharacters(in: .whitespaces); guard !nm.isEmpty else { return }
        datos.onGuardarHoja("tarjeta", ["nombre": nm, "banco": banco, "limite": Double(limite) ?? 0, "saldo": Double(saldo) ?? 0, "corte": Int(corte) ?? 20, "pago": Int(pago) ?? 5, "color": color], nil)
        onClose()
    }
}

// ── Nuevo préstamo o fiado ──────────────────────────────────────────────────
struct CNFormPrestamo: View {
    @ObservedObject var datos: CNDatos
    var onClose: () -> Void
    @State private var nombre = ""
    @State private var entidad = ""
    @State private var total = ""
    @State private var pagado = ""
    @State private var sentido = "debo"
    @State private var color = CNPaleta.colores[2]

    var body: some View {
        CNHoja(titulo: "Nuevo préstamo", onClose: onClose, onGuardar: guardar) {
            VStack(alignment: .leading, spacing: 8) {
                cnHojaTitulo("¿Cómo es?")
                HStack(spacing: 6) { ForEach([("debo", "Yo debo"), ("meDeben", "Me deben")], id: \.0) { s in
                    Text(s.1).font(.system(size: 14, weight: sentido == s.0 ? .bold : .semibold)).foregroundColor(sentido == s.0 ? .white : CNC.pmut).frame(maxWidth: .infinity).padding(.vertical, 10).background(sentido == s.0 ? cnColor(0x093a20) : Color.clear).clipShape(Capsule()).onTapGesture { sentido = s.0 }
                } }.padding(4).background(CNC.soft).clipShape(Capsule())
            }
            CNCampoTexto(placeholder: "Nombre (ej. Préstamo del carro)", texto: $nombre)
            CNCampoTexto(placeholder: "Entidad o persona (opcional)", texto: $entidad)
            VStack(spacing: 6) { cnHojaTitulo("Monto total"); CNMontoCampo(monto: $total) }
            VStack(spacing: 6) { cnHojaTitulo("Ya pagado (opcional)"); CNMontoCampo(monto: $pagado) }
            CNColorFila(color: $color)
        }
    }

    private func guardar() {
        let nm = nombre.trimmingCharacters(in: .whitespaces); guard !nm.isEmpty else { return }
        datos.onGuardarHoja("prestamo", ["nombre": nm, "entidad": entidad, "total": Double(total) ?? 0, "pagado": Double(pagado) ?? 0, "sentido": sentido, "color": color], nil)
        onClose()
    }
}

// ── Nueva meta de ahorro ────────────────────────────────────────────────────
struct CNFormMeta: View {
    @ObservedObject var datos: CNDatos
    var onClose: () -> Void
    @State private var nombre = ""
    @State private var objetivo = ""
    @State private var mensual = ""
    @State private var icono = "hucha"
    @State private var color = CNPaleta.colores[3]
    private let iconos = ["hucha", "premio", "casa", "auto", "avion", "maleta", "birrete", "regalo", "corazon", "estrella"]

    var body: some View {
        CNHoja(titulo: "Nueva meta", onClose: onClose, onGuardar: guardar) {
            CNCampoTexto(placeholder: "Nombre (ej. Fondo de emergencia)", texto: $nombre)
            VStack(spacing: 6) { cnHojaTitulo("Objetivo"); CNMontoCampo(monto: $objetivo) }
            VStack(spacing: 6) { cnHojaTitulo("Aporte mensual (opcional)"); CNMontoCampo(monto: $mensual) }
            VStack(alignment: .leading, spacing: 8) {
                cnHojaTitulo("Icono")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) { ForEach(iconos, id: \.self) { ic in
                        cnGlifo(ic, tam: 18).foregroundColor(icono == ic ? .white : CNC.ink).frame(width: 42, height: 42).background(icono == ic ? cnColor(hexString: color) : CNC.card).clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous)).overlay(RoundedRectangle(cornerRadius: 12).stroke(CNC.line, lineWidth: icono == ic ? 0 : 0.5)).onTapGesture { icono = ic }
                    } }.padding(.horizontal, 2)
                }
            }
            CNColorFila(color: $color)
        }
    }

    private func guardar() {
        let nm = nombre.trimmingCharacters(in: .whitespaces); guard !nm.isEmpty else { return }
        datos.onGuardarHoja("meta", ["nombre": nm, "objetivo": Double(objetivo) ?? 0, "mensual": Double(mensual) ?? 0, "icono": icono, "color": color], nil)
        onClose()
    }
}

// ── Transferencia entre cuentas/tarjetas ────────────────────────────────────
struct CNFormTransferencia: View {
    @ObservedObject var datos: CNDatos
    var origen: String = "efectivo"
    var onClose: () -> Void
    @State private var monto = ""
    @State private var medio = ""
    @State private var destino = ""
    @State private var concepto = ""

    private func nombreDe(_ v: String) -> String {
        if v == "efectivo" { return "Efectivo" }
        if v.hasPrefix("cuenta:"), let id = Int(v.dropFirst(7)), let c = datos.libreta.cuentas.first(where: { $0.id == id }) { return c.nombre }
        if v.hasPrefix("tarjeta:"), let id = Int(v.dropFirst(8)), let t = datos.libreta.tarjetas.first(where: { $0.id == id }) { return t.nombre }
        return "—"
    }

    var body: some View {
        CNHoja(titulo: "Transferencia", onClose: onClose, onGuardar: guardar) {
            CNMontoCampo(monto: $monto)
            cnGrupoHoja {
                Menu {
                    ForEach(datos.libreta.cuentas) { c in Button(c.nombre) { medio = "cuenta:\(c.id)" } }
                    Button("Efectivo") { medio = "efectivo" }
                } label: { fila("De dónde sale", "arrow.up.right", CNC.neg, nombreDe(medio)) }
                cnDiviHoja()
                Menu {
                    ForEach(datos.libreta.cuentas) { c in Button(c.nombre) { destino = "cuenta:\(c.id)" } }
                    ForEach(datos.libreta.tarjetas) { t in Button("Tarjeta · \(t.nombre)") { destino = "tarjeta:\(t.id)" } }
                } label: { fila("A dónde va", "arrow.down.left", CNC.pos, destino.isEmpty ? "Elegir" : nombreDe(destino)) }
            }
            CNCampoTexto(placeholder: "Concepto (opcional)", texto: $concepto)
        }
        .onAppear {
            if medio.isEmpty { medio = origen }
            if destino.isEmpty {
                destino = datos.libreta.cuentas.map { "cuenta:\($0.id)" }.first { $0 != medio }
                    ?? datos.libreta.tarjetas.first.map { "tarjeta:\($0.id)" } ?? ""
            }
        }
    }

    private func fila(_ t: String, _ ic: String, _ tinte: Color, _ val: String) -> some View {
        HStack(spacing: 12) { cnCuadroHoja(ic, tinte); Text(t).font(.system(size: 16)).foregroundColor(CNC.ink); Spacer(minLength: 8); Text(val).font(.system(size: 15)).foregroundColor(CNC.pmut); Image(systemName: "chevron.up.chevron.down").font(.system(size: 11, weight: .semibold)).foregroundColor(CNC.pmut.opacity(0.6)) }.padding(.horizontal, 14).padding(.vertical, 11)
    }
    private func guardar() {
        let n = Double(monto.replacingOccurrences(of: ",", with: "")) ?? 0
        guard n > 0, !destino.isEmpty, destino != medio else { onClose(); return }
        datos.onGuardarHoja("transferencia", ["monto": n, "medio": medio, "destino": destino, "concepto": concepto], nil)
        onClose()
    }
}

// ── Chooser «Agregar» (cuenta / tarjeta / préstamo) ─────────────────────────
struct CNAgregar: View {
    @ObservedObject var datos: CNDatos
    var onClose: () -> Void
    @State private var cual: String? = nil

    var body: some View {
        switch cual {
        case "cuenta": CNFormCuenta(datos: datos, onClose: onClose)
        case "tarjeta": CNFormTarjeta(datos: datos, onClose: onClose)
        case "prestamo": CNFormPrestamo(datos: datos, onClose: onClose)
        default: chooser
        }
    }

    private var chooser: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.4).ignoresSafeArea().onTapGesture { onClose() }
            VStack(spacing: 0) {
                Capsule().fill(CNC.line).frame(width: 40, height: 5).padding(.top, 8).padding(.bottom, 6)
                Text("¿Qué quieres agregar?").font(.system(size: 17, weight: .bold)).foregroundColor(CNC.ink).padding(.vertical, 10)
                VStack(spacing: 10) {
                    opcion("banco", CNC.pos, "Una cuenta", "Efectivo, banco, ahorros") { cual = "cuenta" }
                    opcion("tarjeta", CNC.neg, "Una tarjeta de crédito", "Con su deuda y sus fechas") { cual = "tarjeta" }
                    opcion("mano", cnColor(0x825eb9), "Un préstamo o fiado", "Lo que debes o te deben") { cual = "prestamo" }
                }.padding(.horizontal, 16)
                Button(action: onClose) { Text("Cancelar").font(.system(size: 16, weight: .semibold)).foregroundColor(CNC.pmut).frame(maxWidth: .infinity).padding(.vertical, 14) }.buttonStyle(.plain).padding(.top, 6)
                Color.clear.frame(height: 12)
            }
            .frame(maxWidth: .infinity)
            .background(CNC.scr.clipShape(CNRedondo(radio: 28, esquinas: [.topLeft, .topRight])))
            .ignoresSafeArea(edges: .bottom)
        }
    }

    private func opcion(_ ic: String, _ tinte: Color, _ t: String, _ s: String, _ tap: @escaping () -> Void) -> some View {
        Button(action: tap) {
            HStack(spacing: 12) {
                cnGlifo(ic, tam: 20).foregroundColor(.white).frame(width: 42, height: 42).background(tinte).clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                VStack(alignment: .leading, spacing: 2) { Text(t).font(.system(size: 16, weight: .semibold)).foregroundColor(CNC.ink); Text(s).font(.system(size: 12.5)).foregroundColor(CNC.pmut) }
                Spacer(minLength: 6); Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundColor(CNC.pmut.opacity(0.6))
            }.padding(14).background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous)).overlay(RoundedRectangle(cornerRadius: 16).stroke(CNC.line, lineWidth: 0.5))
        }.buttonStyle(.plain)
    }
}
