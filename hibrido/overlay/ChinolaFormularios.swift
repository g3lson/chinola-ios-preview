import SwiftUI
import UIKit

// Hojas (formularios) NATIVAS. Recogen los datos en SwiftUI y guardan reusando
// TODA la lógica de la web (`enviarHoja`) a través de `datos.onGuardarHoja`, así
// no se reimplementa nada del dinero. Todo con el mismo vidrio del resto.

// ── Contenedor común (mismo vidrio que «Nuevo movimiento») ──────────────────
struct CNHoja<Content: View>: View {
    let titulo: String
    var guardarTexto: String = "Guardar"
    /// Cuando falta algo imprescindible, el botón se ve apagado y no responde.
    var guardarActivo: Bool = true
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
                .cnTeclado()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(CNC.scr.ignoresSafeArea())
        .environment(\.locale, Locale(identifier: CNC.fmt.loc))
    }

    private var cabecera: some View {
        CNHojaCabecera(titulo: titulo, guardarTexto: guardarTexto, guardarActivo: guardarActivo,
                       onClose: onClose, onGuardar: onGuardar)
    }
}

func cnCerrarTeclado() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}

extension View {
    /// Teclado como en las apps de Apple: se va al arrastrar la lista y trae
    /// su botón «Listo» encima.
    @ViewBuilder func cnTeclado() -> some View {
        if #available(iOS 16.0, *) {
            self.scrollDismissesKeyboard(.interactively).modifier(CNBarraTeclado())
        } else {
            self.modifier(CNBarraTeclado())
        }
    }
}

/// El botón «Listo» encima del teclado.
struct CNBarraTeclado: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(cnT("Listo")) { cnCerrarTeclado() }.font(cnLetra(16, .semibold))
                }
            }
    }
}

/// Cabecera de hoja: tirador, cerrar en vidrio y el título. Sin más ruido: la
/// acción de guardar vive abajo, en un botón grande.
struct CNHojaCabecera: View {
    let titulo: String
    var guardarTexto: String = "Guardar"
    var guardarActivo: Bool = true
    /// `true` = un ✓ redondo (guardar sin más). `false` = botón con palabras
    /// abajo, porque un ✓ no dice qué va a pasar (borrar, mandar un enlace…).
    var conCheck: Bool = true
    var onClose: () -> Void
    var onGuardar: (() -> Void)? = nil
    var body: some View {
        ZStack {
            Text(titulo).font(cnLetra(17, .bold)).foregroundColor(CNC.ink)
                .lineLimit(1).padding(.horizontal, 56)
            HStack {
                // Los dos, redondos y del tamaño de siempre del teléfono (44),
                // en vidrio: así se tocan igual de bien en todas las hojas.
                Button {
                    UISelectionFeedbackGenerator().selectionChanged()
                    onClose()
                } label: {
                    Image(systemName: "xmark").font(cnLetra(16, .bold))
                        .foregroundColor(CNC.ink)
                        .frame(width: 44, height: 44).cnVidrio(Circle())
                }.buttonStyle(CNPulsable())
                Spacer(minLength: 8)
                if let guardar = onGuardar, conCheck {
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        guardar()
                    } label: {
                        Image(systemName: "checkmark").font(cnLetra(17, .bold))
                            .foregroundColor(guardarActivo ? CNC.sobreAcc : CNC.pmut)
                            .frame(width: 44, height: 44)
                            .cnVidrio(Circle(), tinte: guardarActivo ? CNC.acc : nil)
                    }
                    .buttonStyle(CNPulsable())
                    .disabled(!guardarActivo)
                    .opacity(guardarActivo ? 1 : 0.6)
                    .accessibilityLabel(guardarTexto)
                } else {
                    Color.clear.frame(width: 44, height: 44)
                }
            }
        }
        .padding(.horizontal, 14).padding(.top, 8).padding(.bottom, 12)
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
                Text(texto).font(cnLetra(17, .bold)).foregroundColor(CNC.sobreAcc)
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
    Text(t.uppercased()).font(cnLetra(12.5, .semibold)).tracking(0.3).foregroundColor(CNC.pmut).padding(.leading, 16).frame(maxWidth: .infinity, alignment: .leading)
}
func cnGrupoHoja<C: View>(@ViewBuilder _ c: () -> C) -> some View {
    VStack(spacing: 0) { c() }.background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous)).overlay(RoundedRectangle(cornerRadius: 16).stroke(CNC.line, lineWidth: 0.5))
}
func cnDiviHoja() -> some View { Rectangle().fill(CNC.line).frame(height: 0.5).padding(.leading, 16) }
func cnCuadroHoja(_ ic: String, _ tinte: Color) -> some View {
    Image(systemName: ic).font(cnLetra(14, .semibold)).foregroundColor(.white).frame(width: 29, height: 29).background(tinte).clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
}

struct CNMontoCampo: View {
    @Binding var monto: String
    var paso: Double = 100
    /// Si el grupo ya lleva su título encima, poner «MONTO» otra vez sobra.
    var rotulo: String? = "MONTO"
    private var valor: Double { Double(monto.replacingOccurrences(of: ",", with: "")) ?? 0 }
    private func fijar(_ n: Double) {
        let v = max(0, n)
        monto = v == v.rounded() ? String(Int(v)) : String(format: "%.2f", v)
    }
    var body: some View {
        cnGrupoHoja {
            VStack(spacing: 6) {
                if let r = rotulo {
                    Text(r).font(cnLetra(11, .semibold)).tracking(0.4).foregroundColor(CNC.pmut)
                }
                ZStack {
                    // El número, centrado en la tarjeta pase lo que pase.
                    HStack(alignment: .firstTextBaseline, spacing: 5) {
                        Text(cnSimboloMoneda).font(cnLetra(18, .heavy)).foregroundColor(CNC.pmut)
                        TextField("0", text: $monto)
                            .font(cnLetra(38, .heavy)).foregroundColor(CNC.ink)
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
            Image(systemName: icono).font(cnLetra(16, .bold)).foregroundColor(CNC.ink)
                .frame(width: 40, height: 40).cnVidrio(Circle())
        }.buttonStyle(.plain)
    }
}

/// Fichas de una fila: tipo de cuenta, sentido de un préstamo… Mismo aspecto
/// que las de categoría, con háptica y borde que se desvanece.
struct CNFichas: View {
    let opciones: [(String, String, String)]     // (id, texto, icono)
    @Binding var elegida: String
    var color: Color = CNC.pos
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(opciones, id: \.0) { o in
                    let puesta = elegida == o.0
                    Button {
                        UISelectionFeedbackGenerator().selectionChanged()
                        elegida = o.0
                    } label: {
                        HStack(spacing: 7) {
                            cnGlifo(o.2, tam: 14, grosor: 2.2).foregroundColor(puesta ? cnSobre(color) : color)
                            Text(o.1).font(cnLetra(14, .semibold)).foregroundColor(puesta ? cnSobre(color) : CNC.ink)
                        }
                        .padding(.horizontal, 13).padding(.vertical, 9)
                        .background(
                            Capsule().fill(puesta ? color : CNC.card)
                                .overlay(Capsule().stroke(puesta ? Color.clear : CNC.line, lineWidth: 0.8))
                        )
                    }.buttonStyle(CNPulsable())
                }
            }
            .padding(.leading, 2).padding(.trailing, 16).padding(.vertical, 2)
        }
        .mask(LinearGradient(stops: [.init(color: .black, location: 0), .init(color: .black, location: 0.92),
                                     .init(color: .clear, location: 1)], startPoint: .leading, endPoint: .trailing))
    }
}

/// Varios campos de texto en una sola tarjeta, separados por una línea fina,
/// como los formularios del sistema.
struct CNGrupoCampos: View {
    let campos: [(String, Binding<String>, UIKeyboardType)]
    var body: some View {
        cnGrupoHoja {
            ForEach(campos.indices, id: \.self) { i in
                if i > 0 { cnDiviHoja() }
                TextField(campos[i].0, text: campos[i].1)
                    .font(cnLetra(16)).foregroundColor(CNC.ink)
                    .keyboardType(campos[i].2)
                    .padding(.horizontal, 15).padding(.vertical, 14)
            }
        }
    }
}

/// Un importe SECUNDARIO (deuda actual, ya pagado, aporte mensual) como una
/// fila más del grupo: solo el principal se lleva la tarjeta grande, si no la
/// hoja se vuelve una torre de cifras enormes.
struct CNFilaMonto: View {
    let icono: String
    let tinte: Color
    let titulo: String
    @Binding var monto: String
    var body: some View {
        HStack(spacing: 12) {
            cnCuadroHoja(icono, tinte)
            Text(titulo).font(cnLetra(16)).foregroundColor(CNC.ink)
            Spacer(minLength: 8)
            HStack(spacing: 4) {
                Spacer(minLength: 0)
                Text(cnSimboloMoneda).font(cnLetra(13, .bold)).foregroundColor(CNC.pmut)
                TextField("0", text: $monto)
                    .font(cnLetra(16, .semibold)).foregroundColor(CNC.ink)
                    .keyboardType(.decimalPad).fixedSize()
            }
            .frame(width: 130)
        }
        .padding(.horizontal, 14).padding(.vertical, 11)
    }
}

/// Un número corto (día del mes) como fila.
struct CNFilaNumero: View {
    let icono: String
    let tinte: Color
    let titulo: String
    let marca: String
    @Binding var texto: String
    var body: some View {
        HStack(spacing: 12) {
            cnCuadroHoja(icono, tinte)
            Text(titulo).font(cnLetra(16)).foregroundColor(CNC.ink)
            Spacer(minLength: 8)
            TextField(marca, text: $texto)
                .font(cnLetra(16, .semibold)).foregroundColor(CNC.ink)
                .keyboardType(.numberPad).multilineTextAlignment(.trailing).frame(width: 54)
        }
        .padding(.horizontal, 14).padding(.vertical, 11)
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
                    .foregroundColor(puesta ? cnSobre(color) : color)
                Text(nombre).font(cnLetra(14, .semibold))
                    .foregroundColor(puesta ? cnSobre(color) : CNC.ink)
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
        cnGrupoHoja { TextField(placeholder, text: $texto).font(cnLetra(16)).foregroundColor(CNC.ink).keyboardType(teclado).padding(.horizontal, 15).padding(.vertical, 13) }
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
            Button(cnT("Efectivo")) { medio = "efectivo" }
        } label: {
            HStack(spacing: 12) { cnCuadroHoja("banknote.fill", CNC.info); Text(cnT("De dónde sale")).font(cnLetra(16)).foregroundColor(CNC.ink); Spacer(minLength: 8); Text(nombre).font(cnLetra(15)).foregroundColor(CNC.pmut); Image(systemName: "chevron.up.chevron.down").font(cnLetra(11, .semibold)).foregroundColor(CNC.pmut.opacity(0.6)) }.padding(.horizontal, 14).padding(.vertical, 11)
        }
    }
}

struct CNColorFila: View {
    @Binding var color: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            cnHojaTitulo(cnT("Color"))
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

    private var titulo: String { cnT(tipo == "abono" ? "Registrar abono" : (tipo == "aporte" ? "Aportar a la meta" : "Pagar la tarjeta")) }

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
    private var clases: [(String, String, String)] { [("banco", cnT("Banco"), "banco"), ("efectivo", cnT("Efectivo"), "billete"), ("billetera", cnT("Billetera"), "telefono"), ("inversion", cnT("Inversión"), "grafico"), ("ahorro", cnT("Ahorro"), "hucha")] }

    var body: some View {
        CNHoja(titulo: cnT("Nueva cuenta"), guardarActivo: !nombre.trimmingCharacters(in: .whitespaces).isEmpty,
               onClose: onClose, onGuardar: guardar) {
            CNGrupoCampos(campos: [(cnT("Nombre (ej. Cuenta principal)"), $nombre, .default),
                                   (cnT("Banco (opcional)"), $banco, .default)])
            VStack(alignment: .leading, spacing: 6) { cnHojaTitulo(cnT("Saldo actual")); CNMontoCampo(monto: $saldo, rotulo: nil) }
            VStack(alignment: .leading, spacing: 8) { cnHojaTitulo(cnT("Tipo")); CNFichas(opciones: clases, elegida: $clase) }
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
        CNHoja(titulo: cnT("Nueva tarjeta"), guardarActivo: !nombre.trimmingCharacters(in: .whitespaces).isEmpty,
               onClose: onClose, onGuardar: guardar) {
            CNGrupoCampos(campos: [(cnT("Nombre (ej. Visa Popular)"), $nombre, .default),
                                   (cnT("Banco (opcional)"), $banco, .default)])
            VStack(alignment: .leading, spacing: 6) { cnHojaTitulo(cnT("Límite")); CNMontoCampo(monto: $limite, paso: 5000, rotulo: nil) }
            VStack(alignment: .leading, spacing: 8) {
                cnHojaTitulo(cnT("Deuda y fechas"))
                cnGrupoHoja {
                    CNFilaMonto(icono: "creditcard.fill", tinte: CNC.neg, titulo: cnT("Deuda actual"), monto: $saldo)
                    cnDiviHoja()
                    CNFilaNumero(icono: "calendar", tinte: CNC.info, titulo: cnT("Día de corte"), marca: "20", texto: $corte)
                    cnDiviHoja()
                    CNFilaNumero(icono: "calendar.badge.clock", tinte: cnColor(0x825eb9), titulo: cnT("Día de pago"), marca: "5", texto: $pago)
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
        CNHoja(titulo: cnT("Nuevo préstamo"), guardarActivo: !nombre.trimmingCharacters(in: .whitespaces).isEmpty,
               onClose: onClose, onGuardar: guardar) {
            VStack(alignment: .leading, spacing: 8) {
                cnHojaTitulo(cnT("¿Cómo es?"))
                CNFichas(opciones: [("debo", "Yo debo", "mano"), ("meDeben", "Me deben", "billete")], elegida: $sentido)
            }
            CNGrupoCampos(campos: [(cnT("Nombre (ej. Préstamo del carro)"), $nombre, .default),
                                   (cnT("Entidad o persona (opcional)"), $entidad, .default)])
            VStack(alignment: .leading, spacing: 6) { cnHojaTitulo(cnT("Monto total")); CNMontoCampo(monto: $total, paso: 1000, rotulo: nil) }
            cnGrupoHoja {
                CNFilaMonto(icono: "checkmark.circle.fill", tinte: CNC.pos, titulo: cnT("Ya pagado"), monto: $pagado)
            }
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
        CNHoja(titulo: cnT("Nueva meta"), guardarActivo: !nombre.trimmingCharacters(in: .whitespaces).isEmpty,
               onClose: onClose, onGuardar: guardar) {
            CNCampoTexto(placeholder: "Nombre (ej. Fondo de emergencia)", texto: $nombre)
            VStack(alignment: .leading, spacing: 6) { cnHojaTitulo(cnT("Objetivo")); CNMontoCampo(monto: $objetivo, paso: 5000, rotulo: nil) }
            cnGrupoHoja {
                CNFilaMonto(icono: "arrow.down.circle.fill", tinte: cnColor(hexString: color), titulo: cnT("Aporte mensual"), monto: $mensual)
            }
            VStack(alignment: .leading, spacing: 8) {
                cnHojaTitulo(cnT("Icono"))
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) { ForEach(iconos, id: \.self) { ic in
                        cnGlifo(ic, tam: 18).foregroundColor(icono == ic ? cnSobre(cnColor(hexString: color)) : CNC.ink)
                            .frame(width: 42, height: 42)
                            .background(icono == ic ? cnColor(hexString: color) : CNC.card)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(CNC.line, lineWidth: icono == ic ? 0 : 0.5))
                            .onTapGesture { UISelectionFeedbackGenerator().selectionChanged(); icono = ic }
                    } }.padding(.horizontal, 2).padding(.vertical, 2)
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
        CNHoja(titulo: cnT("Transferencia"), onClose: onClose, onGuardar: guardar) {
            CNMontoCampo(monto: $monto)
            cnGrupoHoja {
                Menu {
                    ForEach(datos.libreta.cuentas) { c in Button(c.nombre) { medio = "cuenta:\(c.id)" } }
                    Button(cnT("Efectivo")) { medio = "efectivo" }
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
        HStack(spacing: 12) { cnCuadroHoja(ic, tinte); Text(t).font(cnLetra(16)).foregroundColor(CNC.ink); Spacer(minLength: 8); Text(val).font(cnLetra(15)).foregroundColor(CNC.pmut); Image(systemName: "chevron.up.chevron.down").font(cnLetra(11, .semibold)).foregroundColor(CNC.pmut.opacity(0.6)) }.padding(.horizontal, 14).padding(.vertical, 11)
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

    /// Sin atenuado ni esquinas propias: ya vamos DENTRO de una hoja del
    /// sistema, y ponerle otra encima se veía como dos hojas.
    private var chooser: some View {
        VStack(spacing: 0) {
            CNHojaCabecera(titulo: cnT("¿Qué quieres agregar?"), onClose: onClose)
            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    opcion("banco", CNC.pos, "Una cuenta", "Efectivo, banco, ahorros") { cual = "cuenta" }
                    opcion("tarjeta", CNC.neg, "Una tarjeta de crédito", "Con su deuda y sus fechas") { cual = "tarjeta" }
                    opcion("mano", cnColor(0x825eb9), "Un préstamo o fiado", "Lo que debes o te deben") { cual = "prestamo" }
                }
                .padding(.horizontal, 16).padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(CNC.scr.ignoresSafeArea())
    }

    private func opcion(_ ic: String, _ tinte: Color, _ t: String, _ s: String, _ tap: @escaping () -> Void) -> some View {
        Button(action: tap) {
            HStack(spacing: 12) {
                cnGlifo(ic, tam: 20).foregroundColor(.white).frame(width: 42, height: 42).background(tinte).clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                VStack(alignment: .leading, spacing: 2) { Text(t).font(cnLetra(16, .semibold)).foregroundColor(CNC.ink); Text(s).font(cnLetra(12.5)).foregroundColor(CNC.pmut) }
                Spacer(minLength: 6); Image(systemName: "chevron.right").font(cnLetra(13, .semibold)).foregroundColor(CNC.pmut.opacity(0.6))
            }.padding(14).background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous)).overlay(RoundedRectangle(cornerRadius: 16).stroke(CNC.line, lineWidth: 0.5))
        }.buttonStyle(CNPulsable())
    }
}

// ── Las hojas de la WEB, dibujadas en nativo ────────────────────────────────
// Cambiar la contraseña, el correo, una libreta, una clave de API… La web ya
// sabe qué campos lleva cada una (y qué teclado sacar, qué opciones ofrecer,
// qué colores). Aquí solo se dibujan y se devuelve lo escrito: guardar sigue
// siendo `enviarHoja`, con toda su validación.

struct CNHojaWeb: View {
    struct Opcion: Identifiable { var id: String; var label: String }
    struct Color2: Identifiable { var id: Int; var color: String; var puesta: Bool }
    struct Icono: Identifiable { var id: Int; var clave: String; var label: String; var path: String; var puesta: Bool }
    struct Campo: Identifiable {
        var id: Int
        var label = ""; var tipo = "text"; var ph = ""; var valor = ""
        var teclado = "text"; var seguro = false
        var opciones: [Opcion] = []; var colores: [Color2] = []; var iconos: [Icono] = []
    }
    struct Modelo {
        var tipo = ""; var titulo = ""; var texto = ""; var boton = ""
        var error = ""; var ok = ""; var cargando = false; var destruye = false
        /// ✓ arriba (guardar sin más) o botón con palabras abajo.
        var conCheck = true
        var campos: [Campo] = []
    }

    let m: Modelo
    @ObservedObject var datos: CNDatos
    var onClose: () -> Void
    /// Lo que se va escribiendo, para que el campo no dé saltos mientras la web
    /// responde con su propio valor.
    @State private var texto: [Int: String] = [:]

    var body: some View {
        VStack(spacing: 0) {
            CNHojaCabecera(titulo: m.titulo, guardarTexto: m.boton.isEmpty ? "Guardar" : m.boton,
                           guardarActivo: !m.cargando, conCheck: m.conCheck,
                           onClose: onClose, onGuardar: { datos.onHojaEnviar() })
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    if !m.texto.isEmpty {
                        Text(m.texto).font(cnLetra(13.5)).foregroundColor(CNC.pmut)
                            .fixedSize(horizontal: false, vertical: true).padding(.horizontal, 4)
                    }
                    ForEach(m.campos) { c in campo(c) }
                    if !m.error.isEmpty { aviso(m.error, CNC.neg) }
                    if !m.ok.isEmpty { aviso(m.ok, CNC.pos) }
                    // Lo que no es «guardar sin más» lleva su botón con
                    // palabras: un ✓ no dice si va a borrar o a mandar un correo.
                    if !m.conCheck {
                        Button { datos.onHojaEnviar() } label: {
                            Text(m.boton).font(cnLetra(16, .bold))
                                .foregroundColor(m.destruye ? .white : CNC.sobreAcc)
                                .frame(maxWidth: .infinity).padding(.vertical, 16)
                                .background(m.destruye ? CNC.neg : CNC.acc, in: Capsule())
                        }.buttonStyle(CNPulsable()).padding(.top, 4)
                    }
                    Color.clear.frame(height: 24)
                }
                .padding(.horizontal, 16).padding(.top, 4)
            }
            .cnTeclado()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(CNC.scr.ignoresSafeArea())
        .environment(\.locale, Locale(identifier: CNC.fmt.loc))
    }

    private func aviso(_ t: String, _ color: Color) -> some View {
        Text(t).font(cnLetra(13)).foregroundColor(color)
            .fixedSize(horizontal: false, vertical: true)
            .padding(12).frame(maxWidth: .infinity, alignment: .leading)
            .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    @ViewBuilder private func campo(_ c: Campo) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            cnHojaTitulo(c.label)
            if !c.colores.isEmpty {
                HStack(spacing: 10) {
                    ForEach(c.colores) { x in
                        Button { datos.onHojaCampo(c.id, String(x.id), "color") } label: {
                            Circle().fill(cnColor(hexString: x.color)).frame(width: 32, height: 32)
                                .overlay(Circle().stroke(CNC.ink, lineWidth: x.puesta ? 3 : 0))
                                .overlay(Circle().stroke(CNC.line, lineWidth: 0.5))
                        }.buttonStyle(CNPulsable())
                    }
                    Spacer(minLength: 0)
                }.padding(.horizontal, 4)
            } else if !c.iconos.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(c.iconos) { x in
                            Button { datos.onHojaCampo(c.id, String(x.id), "icono") } label: {
                                CNSVGShape(d: x.path)
                                    .stroke(style: StrokeStyle(lineWidth: 1.9, lineCap: .round, lineJoin: .round))
                                    .foregroundColor(x.puesta ? CNC.ink : CNC.pmut)
                                    .frame(width: 20, height: 20).frame(width: 44, height: 44)
                                    .background(x.puesta ? CNC.soft : CNC.card,
                                                in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                                    .overlay(RoundedRectangle(cornerRadius: 13)
                                        .stroke(x.puesta ? CNC.acc : CNC.line, lineWidth: x.puesta ? 2 : 1))
                            }.buttonStyle(CNPulsable())
                        }
                    }.padding(.horizontal, 2).padding(.vertical, 2)
                }
            } else if !c.opciones.isEmpty {
                cnGrupoHoja {
                    Menu {
                        Picker("", selection: Binding(get: { c.valor },
                                                      set: { datos.onHojaCampo(c.id, $0, "") })) {
                            ForEach(c.opciones) { o in Text(o.label).tag(o.id) }
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Text(etiqueta(c)).font(cnLetra(16)).foregroundColor(CNC.ink).lineLimit(1)
                            Spacer(minLength: 8)
                            Image(systemName: "chevron.up.chevron.down").font(cnLetra(11, .semibold))
                                .foregroundColor(CNC.pmut.opacity(0.6))
                        }
                        .padding(.horizontal, 15).padding(.vertical, 14)
                    }
                }
            } else {
                cnGrupoHoja {
                    Group {
                        if c.seguro {
                            SecureField(c.ph, text: enlace(c))
                        } else {
                            TextField(c.ph, text: enlace(c))
                                .keyboardType(cnTecladoDe(c.teclado))
                                .textInputAutocapitalization(c.teclado == "email" ? .never : .sentences)
                                .disableAutocorrection(c.teclado == "email")
                        }
                    }
                    .font(cnLetra(16)).foregroundColor(CNC.ink)
                    .padding(.horizontal, 15).padding(.vertical, 14)
                }
            }
        }
    }

    private func etiqueta(_ c: Campo) -> String {
        c.opciones.first { $0.id == c.valor }?.label ?? (c.ph.isEmpty ? "Elegir" : c.ph)
    }
    private func enlace(_ c: Campo) -> Binding<String> {
        Binding(get: { texto[c.id] ?? c.valor },
                set: { texto[c.id] = $0; datos.onHojaCampo(c.id, $0, "") })
    }
}

/// El teclado que pide cada campo (lo dice la web).
func cnTecladoDe(_ nombre: String) -> UIKeyboardType {
    switch nombre {
    case "email": return .emailAddress
    case "decimal": return .decimalPad
    case "tel": return .phonePad
    case "number": return .numberPad
    default: return .default
    }
}

extension CNHojaWeb.Modelo {
    static func desde(json: String) -> CNHojaWeb.Modelo? {
        guard let d = json.data(using: .utf8),
              let raiz = (try? JSONSerialization.jsonObject(with: d)) as? [String: Any] else { return nil }
        func s(_ o: [String: Any]?, _ k: String) -> String { (o?[k] as? String) ?? "" }
        func b(_ o: [String: Any]?, _ k: String) -> Bool { (o?[k] as? Bool) ?? false }
        func n(_ o: [String: Any]?, _ k: String) -> Int { ((o?[k] as? NSNumber)?.intValue) ?? 0 }
        func l(_ o: [String: Any]?, _ k: String) -> [[String: Any]] { (o?[k] as? [[String: Any]]) ?? [] }
        var m = CNHojaWeb.Modelo()
        m.tipo = s(raiz, "tipo"); m.titulo = s(raiz, "titulo"); m.texto = s(raiz, "texto")
        m.boton = s(raiz, "boton"); m.error = s(raiz, "error"); m.ok = s(raiz, "ok")
        m.cargando = b(raiz, "cargando"); m.destruye = b(raiz, "destruye")
        m.conCheck = (raiz["conCheck"] as? Bool) ?? true
        m.campos = l(raiz, "campos").map { c in
            CNHojaWeb.Campo(id: n(c, "indice"), label: s(c, "label"), tipo: s(c, "tipo"), ph: s(c, "ph"),
                            valor: s(c, "valor"), teclado: s(c, "teclado"), seguro: b(c, "seguro"),
                            opciones: l(c, "opciones").map { CNHojaWeb.Opcion(id: s($0, "id"), label: s($0, "label")) },
                            colores: l(c, "colores").map { CNHojaWeb.Color2(id: n($0, "indice"), color: s($0, "color"), puesta: b($0, "puesta")) },
                            iconos: l(c, "iconos").map { CNHojaWeb.Icono(id: n($0, "indice"), clave: s($0, "clave"), label: s($0, "label"), path: s($0, "path"), puesta: b($0, "puesta")) })
        }
        return m
    }
}

/// La hoja de la web, siguiendo su modelo: al escribir o al guardar, la web
/// contesta con el modelo nuevo (con su error, si lo hay) y esto se repinta.
struct CNHojaWebViva: View {
    @ObservedObject var datos: CNDatos
    var onClose: () -> Void
    var body: some View {
        if let m = datos.hojaWeb {
            CNHojaWeb(m: m, datos: datos, onClose: onClose)
        } else {
            Color.clear.onAppear { onClose() }
        }
    }
}

// ── El periodo: atajos y calendario, en nativo ──────────────────────────────
struct CNPeriodo {
    struct Opcion: Identifiable { var id: Int; var label = ""; var puesta = false; var fondo = ""; var tinta = ""; var borde = "" }
    struct Dia: Identifiable {
        var id: Int; var n = 0
        var banda = ""; var bandaRadio = ""; var circulo = ""; var tinta = ""
        var fuerte = false; var opacidad: Double = 1
    }
    var abierto = false; var calendario = false; var resumen = ""
    var opciones: [Opcion] = []
    var calTitulo = ""; var diasSemana: [String] = []; var dias: [Dia] = []
    var seleccion = ""; var textoAplicar = ""; var puedeAplicar = false

    static func desde(json: String) -> CNPeriodo? {
        guard let d = json.data(using: .utf8),
              let r = (try? JSONSerialization.jsonObject(with: d)) as? [String: Any] else { return nil }
        func s(_ o: [String: Any]?, _ k: String) -> String { (o?[k] as? String) ?? "" }
        func b(_ o: [String: Any]?, _ k: String) -> Bool { (o?[k] as? Bool) ?? false }
        func n(_ o: [String: Any]?, _ k: String) -> Double { ((o?[k] as? NSNumber)?.doubleValue) ?? 0 }
        func l(_ o: [String: Any]?, _ k: String) -> [[String: Any]] { (o?[k] as? [[String: Any]]) ?? [] }
        var p = CNPeriodo()
        p.abierto = b(r, "abierto"); p.calendario = b(r, "calendario"); p.resumen = s(r, "resumen")
        p.calTitulo = s(r, "calTitulo"); p.diasSemana = (r["diasSemana"] as? [String]) ?? []
        p.seleccion = s(r, "seleccion"); p.textoAplicar = s(r, "textoAplicar"); p.puedeAplicar = b(r, "puedeAplicar")
        p.opciones = l(r, "opciones").map {
            Opcion(id: Int(n($0, "indice")), label: s($0, "label"), puesta: b($0, "puesta"),
                   fondo: s($0, "fondo"), tinta: s($0, "tinta"), borde: s($0, "borde"))
        }
        p.dias = l(r, "dias").map {
            Dia(id: Int(n($0, "indice")), n: Int(n($0, "n")), banda: s($0, "banda"),
                bandaRadio: s($0, "bandaRadio"), circulo: s($0, "circulo"), tinta: s($0, "tinta"),
                fuerte: b($0, "fuerte"), opacidad: n($0, "opacidad"))
        }
        return p
    }
}

struct CNPeriodoHoja: View {
    @ObservedObject var datos: CNDatos
    var onClose: () -> Void
    var body: some View {
        let p = datos.periodo ?? CNPeriodo()
        return VStack(spacing: 0) {
            CNHojaCabecera(titulo: cnT("Periodo"), onClose: onClose)
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    // Los atajos: este mes, el pasado, el año… y «Personalizado»,
                    // que es el que saca el calendario.
                    CNRejillaFija(columnas: 2, total: p.opciones.count) { i in
                        let o = p.opciones[i]
                        Button { datos.onPeriodo("opcion", o.id) } label: {
                            Text(o.label).font(cnLetra(14.5, o.puesta ? .bold : .semibold))
                                .foregroundColor(o.tinta.isEmpty ? CNC.ink : cnColor(hexString: o.tinta))
                                .frame(maxWidth: .infinity).padding(.vertical, 13)
                                .background(o.puesta ? cnColor(hexString: o.fondo) : CNC.card,
                                            in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 13)
                                    .stroke(o.puesta ? Color.clear : CNC.line, lineWidth: 1))
                        }.buttonStyle(CNPulsable())
                    }
                    if !p.resumen.isEmpty {
                        Text(p.resumen).font(cnLetra(13)).foregroundColor(CNC.pmut).padding(.horizontal, 4)
                    }
                    if p.calendario { calendario(p) }
                    Color.clear.frame(height: 24)
                }
                .padding(.horizontal, 16).padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(CNC.scr.ignoresSafeArea())
        .environment(\.locale, Locale(identifier: CNC.fmt.loc))
    }

    @ViewBuilder private func calendario(_ p: CNPeriodo) -> some View {
        VStack(spacing: 12) {
            HStack {
                boton("chevron.left") { datos.onPeriodo("antes", 0) }
                Spacer(minLength: 8)
                Text(p.calTitulo).font(cnLetra(16, .bold)).foregroundColor(CNC.ink).lineLimit(1)
                Spacer(minLength: 8)
                boton("chevron.right") { datos.onPeriodo("despues", 0) }
            }
            HStack(spacing: 0) {
                ForEach(p.diasSemana.indices, id: \.self) { i in
                    Text(p.diasSemana[i]).font(cnLetra(11, .semibold))
                        .foregroundColor(CNC.pmut).frame(maxWidth: .infinity)
                }
            }
            // La franja del rango pasa por detrás, de borde a borde de la
            // casilla, para que los días de en medio se unan en una sola barra.
            let filas = (p.dias.count + 6) / 7
            VStack(spacing: 2) {
                ForEach(0..<max(0, filas), id: \.self) { f in
                    HStack(spacing: 0) {
                        ForEach(0..<7, id: \.self) { c in
                            let i = f * 7 + c
                            if i < p.dias.count { celda(p.dias[i]) } else { Color.clear.frame(maxWidth: .infinity) }
                        }
                    }
                }
            }
            HStack {
                Text(p.seleccion).font(cnLetra(13.5, .semibold)).foregroundColor(CNC.pmut)
                Spacer(minLength: 8)
            }
            Button { if p.puedeAplicar { datos.onPeriodo("aplicar", 0) } } label: {
                Text(p.textoAplicar.isEmpty ? "Aplicar" : p.textoAplicar)
                    .font(cnLetra(16, .bold))
                    .foregroundColor(p.puedeAplicar ? CNC.sobreAcc : CNC.pmut)
                    .frame(maxWidth: .infinity).padding(.vertical, 15)
                    .background(p.puedeAplicar ? CNC.acc : CNC.soft, in: Capsule())
            }
            .buttonStyle(CNPulsable()).disabled(!p.puedeAplicar)
        }
        .padding(14).tarjetaCN()
    }

    private func celda(_ d: CNPeriodo.Dia) -> some View {
        ZStack {
            CNFranjaRango(radio: d.bandaRadio).fill(cnColor(hexString: d.banda))
            if !d.circulo.isEmpty && d.circulo != "rgba(0,0,0,0)" {
                Circle().fill(cnColor(hexString: d.circulo)).frame(width: 34, height: 34)
            }
            Text("\(d.n)").font(cnLetra(14.5, d.fuerte ? .semibold : .regular))
                .foregroundColor(d.tinta.isEmpty ? CNC.ink : cnColor(hexString: d.tinta))
        }
        .frame(height: 40).frame(maxWidth: .infinity)
        .opacity(d.opacidad)
        .contentShape(Rectangle())
        .onTapGesture { datos.onPeriodo("dia", d.id) }
    }

    private func boton(_ ic: String, _ tap: @escaping () -> Void) -> some View {
        Button(action: tap) {
            Image(systemName: ic).font(cnLetra(14, .bold)).foregroundColor(CNC.ink)
                .frame(width: 36, height: 36).background(CNC.soft, in: Circle())
        }.buttonStyle(CNPulsable())
    }
}

/// La franja del rango: redonda por fuera y recta por dentro, como en la web.
/// El radio viene escrito como en CSS: «999px 0 0 999px» redondea la izquierda,
/// «0 999px 999px 0» la derecha, y «0» ninguna.
struct CNFranjaRango: Shape {
    let radio: String
    func path(in r: CGRect) -> Path {
        let izq = radio.hasPrefix("999")
        let der = radio.hasPrefix("0 999")
        let rr = min(r.height / 2, r.width / 2)
        let ri: CGFloat = izq ? rr : 0
        let rd: CGFloat = der ? rr : 0
        var p = Path()
        p.move(to: CGPoint(x: r.minX + ri, y: r.minY))
        p.addLine(to: CGPoint(x: r.maxX - rd, y: r.minY))
        if rd > 0 {
            p.addArc(center: CGPoint(x: r.maxX - rd, y: r.midY), radius: rd,
                     startAngle: .degrees(-90), endAngle: .degrees(90), clockwise: false)
        } else {
            p.addLine(to: CGPoint(x: r.maxX, y: r.maxY))
        }
        p.addLine(to: CGPoint(x: r.minX + ri, y: r.maxY))
        if ri > 0 {
            p.addArc(center: CGPoint(x: r.minX + ri, y: r.midY), radius: ri,
                     startAngle: .degrees(90), endAngle: .degrees(270), clockwise: false)
        } else {
            p.addLine(to: CGPoint(x: r.minX, y: r.minY))
        }
        p.closeSubpath()
        return p
    }
}

// ── El selector de libretas, en nativo ──────────────────────────────────────
//
// Antes era la hoja de la WEB, y para enseñarla había que enseñar la pantalla
// web de debajo: al tocar la libreta en la cabecera, el Resumen cambiaba de
// cara por un momento y volvía al cerrar. Ahora la lista la calcula la web
// —los nombres, el tipo, cuánta gente y cuál está en uso— y aquí solo se
// dibuja, encima de la pantalla nativa que ya estaba.
struct CNLibretas {
    struct Fila: Identifiable {
        var id: Int { indice }
        var indice = 0; var nombre = ""; var detalle = ""; var iconoPath = ""
        var color = ""; var enUso = false; var rotuloEnUso = ""
    }
    var titulo = "Libretas"
    var textoGestionar = ""
    var filas: [Fila] = []

    static func desde(json: String) -> CNLibretas? {
        guard let d = json.data(using: .utf8),
              let r = (try? JSONSerialization.jsonObject(with: d)) as? [String: Any] else { return nil }
        func s(_ o: [String: Any], _ k: String) -> String { (o[k] as? String) ?? "" }
        var m = CNLibretas()
        if !s(r, "titulo").isEmpty { m.titulo = s(r, "titulo") }
        m.textoGestionar = s(r, "textoGestionar")
        m.filas = ((r["filas"] as? [[String: Any]]) ?? []).map { f in
            Fila(indice: (f["indice"] as? NSNumber)?.intValue ?? 0,
                 nombre: s(f, "nombre"), detalle: s(f, "detalle"), iconoPath: s(f, "iconoPath"),
                 color: s(f, "color"), enUso: (f["enUso"] as? Bool) ?? false,
                 rotuloEnUso: s(f, "rotuloEnUso"))
        }
        return m
    }
}

struct CNLibretasHoja: View {
    @ObservedObject var datos: CNDatos
    var onClose: () -> Void
    var body: some View {
        let m = datos.libretas ?? CNLibretas()
        return VStack(spacing: 0) {
            ZStack {
                Text(m.titulo).font(cnLetra(17, .bold)).foregroundColor(CNC.ink)
                HStack {
                    Button {
                        UISelectionFeedbackGenerator().selectionChanged()
                        onClose()
                    } label: {
                        Image(systemName: "xmark").font(cnLetra(16, .bold))
                            .foregroundColor(CNC.ink).frame(width: 44, height: 44).cnVidrio(Circle())
                    }.buttonStyle(CNPulsable())
                    Spacer(minLength: 8)
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        datos.onLibreta("nueva", 0)
                    } label: {
                        Image(systemName: "plus").font(cnLetra(17, .bold))
                            .foregroundColor(CNC.sobreAcc)
                            .frame(width: 44, height: 44).cnVidrio(Circle(), tinte: CNC.acc)
                    }.buttonStyle(CNPulsable())
                }
            }
            .padding(.horizontal, 14).padding(.top, 8).padding(.bottom, 12)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    ForEach(m.filas) { f in fila(f) }
                    if !m.textoGestionar.isEmpty {
                        Button {
                            UISelectionFeedbackGenerator().selectionChanged()
                            datos.onLibreta("gestionar", 0)
                        } label: {
                            Text(m.textoGestionar).font(cnLetra(15, .semibold))
                                .foregroundColor(CNC.ink).frame(maxWidth: .infinity).padding(.vertical, 15)
                                .background(CNC.card, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous)
                                    .stroke(CNC.line, lineWidth: 1))
                        }.buttonStyle(CNPulsable()).padding(.top, 6)
                    }
                    Color.clear.frame(height: 20)
                }
                .padding(.horizontal, 16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(CNC.scr.ignoresSafeArea())
    }

    private func fila(_ f: CNLibretas.Fila) -> some View {
        Button {
            UISelectionFeedbackGenerator().selectionChanged()
            datos.onLibreta("elegir", f.indice)
        } label: {
            HStack(spacing: 13) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous).fill(cnColor(hexString: f.color))
                    CNSVGShape(d: f.iconoPath)
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 1.9, lineCap: .round, lineJoin: .round))
                        .frame(width: 22, height: 22)
                }
                .frame(width: 46, height: 46)
                VStack(alignment: .leading, spacing: 2) {
                    Text(f.nombre).font(cnLetra(16, .bold)).foregroundColor(CNC.ink).lineLimit(1)
                    Text(f.detalle).font(cnLetra(13)).foregroundColor(CNC.pmut).lineLimit(1)
                }
                Spacer(minLength: 8)
                if f.enUso {
                    Text(f.rotuloEnUso.uppercased()).font(cnLetra(10.5, .heavy)).tracking(0.5)
                        .foregroundColor(CNC.pos)
                        .padding(.horizontal, 9).padding(.vertical, 5)
                        .background(CNC.pos.opacity(0.14), in: Capsule())
                }
            }
            .padding(12)
            .background(f.enUso ? CNC.soft : CNC.card,
                        in: RoundedRectangle(cornerRadius: 17, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 17, style: .continuous)
                .stroke(f.enUso ? CNC.acc.opacity(0.55) : CNC.line, lineWidth: f.enUso ? 1.6 : 1))
        }.buttonStyle(CNPulsable())
    }
}

// ── Nueva libreta, en nativo ────────────────────────────────────────────────
//
// Era de las últimas pantallas que obligaban a enseñar la web. Los tipos, los
// colores y los iconos los manda la web (son los suyos), y al guardar se llama
// a SU función: los avisos de nombre repetido y de límite del plan siguen
// siendo los de siempre, sin copiarlos aquí.
struct CNLibretaNueva {
    struct Tipo: Identifiable { var id: String; var label: String }
    struct Icono: Identifiable { var id: String; var label: String; var path: String }
    var titulo = "Nueva libreta"
    var rotuloNombre = "Nombre"; var phNombre = ""
    var rotuloTipo = "Tipo"; var rotuloIcono = "Icono"
    var tipos: [Tipo] = []
    var colores: [String] = []
    var coloresId: [String] = []
    var iconos: [Icono] = []

    static func desde(json: String) -> CNLibretaNueva? {
        guard let d = json.data(using: .utf8),
              let r = (try? JSONSerialization.jsonObject(with: d)) as? [String: Any] else { return nil }
        func s(_ o: [String: Any], _ k: String) -> String { (o[k] as? String) ?? "" }
        var m = CNLibretaNueva()
        if !s(r, "titulo").isEmpty { m.titulo = s(r, "titulo") }
        m.rotuloNombre = s(r, "rotuloNombre"); m.phNombre = s(r, "phNombre")
        m.rotuloTipo = s(r, "rotuloTipo"); m.rotuloIcono = s(r, "rotuloIcono")
        m.tipos = ((r["tipos"] as? [[String: Any]]) ?? []).map { Tipo(id: s($0, "id"), label: s($0, "label")) }
        m.colores = (r["colores"] as? [String]) ?? []
        m.coloresId = (r["coloresId"] as? [String]) ?? []
        m.iconos = ((r["iconos"] as? [[String: Any]]) ?? []).map {
            Icono(id: s($0, "id"), label: s($0, "label"), path: s($0, "path"))
        }
        return m
    }
}

struct CNFormLibreta: View {
    @ObservedObject var datos: CNDatos
    var onClose: () -> Void
    @State private var nombre = ""
    @State private var tipo = ""
    @State private var icono = ""
    @State private var color = 0

    var body: some View {
        let m = datos.libretaNueva ?? CNLibretaNueva()
        return CNHoja(titulo: m.titulo,
                      guardarActivo: !nombre.trimmingCharacters(in: .whitespaces).isEmpty,
                      onClose: onClose, onGuardar: { guardar(m) }) {
            CNCampoTexto(placeholder: m.phNombre.isEmpty ? cnT("Nombre") : m.phNombre, texto: $nombre)
            if !m.tipos.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    cnHojaTitulo(m.rotuloTipo)
                    CNRejillaFija(columnas: 2, total: m.tipos.count) { i in
                        let t = m.tipos[i]
                        Button {
                            UISelectionFeedbackGenerator().selectionChanged(); tipo = t.id
                        } label: {
                            Text(t.label).font(cnLetra(14.5, tipo == t.id ? .bold : .semibold))
                                .foregroundColor(tipo == t.id ? CNC.sobreAcc : CNC.ink)
                                .frame(maxWidth: .infinity).padding(.vertical, 12)
                                .background(tipo == t.id ? CNC.acc : CNC.card,
                                            in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 13).stroke(CNC.line, lineWidth: tipo == t.id ? 0 : 1))
                        }.buttonStyle(CNPulsable())
                    }
                }
            }
            if !m.iconos.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    cnHojaTitulo(m.rotuloIcono)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(m.iconos) { ic in
                                CNSVGShape(d: ic.path)
                                    .stroke(icono == ic.id ? Color.white : CNC.ink,
                                            style: StrokeStyle(lineWidth: 1.9, lineCap: .round, lineJoin: .round))
                                    .frame(width: 20, height: 20)
                                    .frame(width: 44, height: 44)
                                    .background(icono == ic.id ? cnColor(hexString: colorPuesto(m)) : CNC.card)
                                    .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                                    .overlay(RoundedRectangle(cornerRadius: 13)
                                        .stroke(CNC.line, lineWidth: icono == ic.id ? 0 : 0.5))
                                    .onTapGesture { UISelectionFeedbackGenerator().selectionChanged(); icono = ic.id }
                            }
                        }.padding(.horizontal, 2).padding(.vertical, 2)
                    }
                }
            }
            if !m.colores.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    cnHojaTitulo(cnT("Color"))
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(m.colores.indices, id: \.self) { i in
                                Circle().fill(cnColor(hexString: m.colores[i]))
                                    .frame(width: 30, height: 30)
                                    .overlay(Circle().stroke(CNC.ink, lineWidth: color == i ? 2.5 : 0))
                                    .onTapGesture { UISelectionFeedbackGenerator().selectionChanged(); color = i }
                            }
                        }.padding(.horizontal, 2).padding(.vertical, 2)
                    }
                }
            }
        }
        .onAppear {
            if tipo.isEmpty { tipo = m.tipos.first?.id ?? "Personal" }
            if icono.isEmpty { icono = m.iconos.first?.id ?? "casa" }
        }
    }

    private func colorPuesto(_ m: CNLibretaNueva) -> String {
        color < m.colores.count ? m.colores[color] : (m.colores.first ?? "")
    }

    private func guardar(_ m: CNLibretaNueva) {
        let nm = nombre.trimmingCharacters(in: .whitespaces)
        guard !nm.isEmpty else { return }
        let id = color < m.coloresId.count ? m.coloresId[color] : (m.coloresId.first ?? "")
        datos.onCrearLibreta(["nombre": nm, "tipo": tipo, "icono": icono, "color": id])
        onClose()
    }
}

// ── Invitar a alguien a una libreta, en nativo ──────────────────────────────
struct CNInvitar {
    struct Rol: Identifiable { var id: String; var label: String; var sub: String }
    var titulo = "Invitar a alguien"
    var phEmail = ""; var phNombre = ""; var rotuloRol = ""; var pie = ""; var boton = "Invitar"
    var roles: [Rol] = []

    static func desde(json: String) -> CNInvitar? {
        guard let d = json.data(using: .utf8),
              let r = (try? JSONSerialization.jsonObject(with: d)) as? [String: Any] else { return nil }
        func s(_ o: [String: Any], _ k: String) -> String { (o[k] as? String) ?? "" }
        var m = CNInvitar()
        if !s(r, "titulo").isEmpty { m.titulo = s(r, "titulo") }
        m.phEmail = s(r, "phEmail"); m.phNombre = s(r, "phNombre")
        m.rotuloRol = s(r, "rotuloRol"); m.pie = s(r, "pie")
        if !s(r, "boton").isEmpty { m.boton = s(r, "boton") }
        m.roles = ((r["roles"] as? [[String: Any]]) ?? []).map {
            Rol(id: s($0, "id"), label: s($0, "label"), sub: s($0, "sub"))
        }
        return m
    }
}

struct CNFormInvitar: View {
    @ObservedObject var datos: CNDatos
    let libreta: String
    var onClose: () -> Void
    @State private var email = ""
    @State private var nombre = ""
    @State private var rol = ""

    var body: some View {
        let m = datos.invitar ?? CNInvitar()
        return CNHoja(titulo: m.titulo, guardarTexto: m.boton,
                      guardarActivo: email.contains("@"),
                      onClose: onClose, onGuardar: { mandar(m) }) {
            CNGrupoCampos(campos: [(m.phEmail, $email, .emailAddress), (m.phNombre, $nombre, .default)])
            if !m.roles.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    cnHojaTitulo(m.rotuloRol)
                    VStack(spacing: 0) {
                        ForEach(m.roles.indices, id: \.self) { i in
                            let r = m.roles[i]
                            Button {
                                UISelectionFeedbackGenerator().selectionChanged(); rol = r.id
                            } label: {
                                HStack(spacing: 10) {
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(r.label).font(cnLetra(15.5, .semibold)).foregroundColor(CNC.ink)
                                        if !r.sub.isEmpty {
                                            Text(r.sub).font(cnLetra(12)).foregroundColor(CNC.pmut)
                                        }
                                    }
                                    Spacer(minLength: 8)
                                    Image(systemName: rol == r.id ? "checkmark.circle.fill" : "circle")
                                        .font(cnLetra(18)).foregroundColor(rol == r.id ? CNC.acc : CNC.line)
                                }
                                .padding(.horizontal, 14).padding(.vertical, 11).contentShape(Rectangle())
                            }.buttonStyle(CNPulsable())
                            if i < m.roles.count - 1 {
                                Rectangle().fill(CNC.line).frame(height: 0.5).padding(.leading, 14)
                            }
                        }
                    }
                    .background(CNC.card)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(CNC.line, lineWidth: 0.5))
                }
            }
            if !m.pie.isEmpty {
                Text(m.pie).font(cnLetra(12.5)).foregroundColor(CNC.pmut)
                    .fixedSize(horizontal: false, vertical: true).padding(.horizontal, 4)
            }
        }
        .onAppear { if rol.isEmpty { rol = m.roles.last?.id ?? "Lector" } }
    }

    private func mandar(_ m: CNInvitar) {
        let e = email.trimmingCharacters(in: .whitespaces)
        guard e.contains("@") else { return }
        datos.onInvitar(["libreta": libreta, "email": e,
                         "nombre": nombre.trimmingCharacters(in: .whitespaces), "rol": rol])
        onClose()
    }
}

// ── El recorrido de bienvenida, en nativo ───────────────────────────────────
//
// Cinco pasos que la web lleva contados; aquí solo se dibuja el que toca, sobre
// la pantalla de verdad y encima del menú, para que se vea de qué se habla.
struct CNTour {
    var paso = 0; var total = 1; var vista = "resumen"
    var titulo = ""; var texto = ""; var chinolo = ""
    var textoSiguiente = "Siguiente"; var textoSaltar = "Saltar"

    static func desde(json: String) -> CNTour? {
        guard let d = json.data(using: .utf8),
              let r = (try? JSONSerialization.jsonObject(with: d)) as? [String: Any] else { return nil }
        func s(_ o: [String: Any], _ k: String) -> String { (o[k] as? String) ?? "" }
        func n(_ o: [String: Any], _ k: String) -> Int { ((o[k] as? NSNumber)?.intValue) ?? 0 }
        var m = CNTour()
        m.paso = n(r, "paso"); m.total = max(1, n(r, "total")); m.vista = s(r, "vista")
        m.titulo = s(r, "titulo"); m.texto = s(r, "texto"); m.chinolo = s(r, "chinolo")
        if !s(r, "textoSiguiente").isEmpty { m.textoSiguiente = s(r, "textoSiguiente") }
        if !s(r, "textoSaltar").isEmpty { m.textoSaltar = s(r, "textoSaltar") }
        return m
    }
}

struct CNTourVista: View {
    @ObservedObject var datos: CNDatos
    var onPaso: (String) -> Void
    var body: some View {
        let m = datos.tour ?? CNTour()
        return ZStack(alignment: .bottom) {
            // El telón apaga la pantalla pero la deja ver: lo que se explica
            // está detrás.
            Color.black.opacity(0.45).ignoresSafeArea()
                .onTapGesture { onPaso("saltar") }
            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: 12) {
                    if let img = cnImagenBase64(m.chinolo) {
                        Image(uiImage: img).resizable().scaledToFit().frame(width: 54, height: 54)
                    }
                    VStack(alignment: .leading, spacing: 5) {
                        Text(m.titulo).font(cnLetra(17, .heavy)).foregroundColor(CNC.ink)
                        Text(m.texto).font(cnLetra(14)).foregroundColor(CNC.pmut)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                HStack(spacing: 10) {
                    HStack(spacing: 5) {
                        ForEach(0..<m.total, id: \.self) { i in
                            Circle().fill(i == m.paso ? CNC.acc : CNC.line)
                                .frame(width: i == m.paso ? 7 : 5, height: i == m.paso ? 7 : 5)
                        }
                    }
                    Spacer(minLength: 8)
                    Button { onPaso("saltar") } label: {
                        Text(m.textoSaltar).font(cnLetra(14.5, .semibold)).foregroundColor(CNC.pmut)
                            .padding(.horizontal, 12).padding(.vertical, 9)
                    }.buttonStyle(CNPulsable())
                    Button { onPaso("siguiente") } label: {
                        Text(m.textoSiguiente).font(cnLetra(14.5, .bold)).foregroundColor(CNC.sobreAcc)
                            .padding(.horizontal, 18).padding(.vertical, 10)
                            .background(CNC.acc, in: Capsule())
                    }.buttonStyle(CNPulsable())
                }
                .padding(.top, 14)
            }
            .padding(16)
            .background(CNC.card, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(CNC.line, lineWidth: 1))
            .shadow(color: .black.opacity(0.18), radius: 18, y: 6)
            .padding(.horizontal, 14)
            .padding(.bottom, 104)
        }
    }
}

// ── Chino, en grande ────────────────────────────────────────────────────────
//
// El icono del perfil es su dibujo, y se mantiene pulsado para verlo en grande;
// por detrás, los pagos que vienen. Es la misma tarjeta de siempre: delante el
// personaje, detrás lo que hay que pagar, y se voltea al tocarla.
struct CNMascota {
    struct Aviso: Identifiable { var id: Int; var titulo = ""; var detalle = ""; var color = "" }
    var chinolo = ""
    var tituloAvisos = ""; var verAvisos = ""; var volver = ""; var nadaTexto = ""
    var avisos: [Aviso] = []

    static func desde(json: String) -> CNMascota? {
        guard let d = json.data(using: .utf8),
              let r = (try? JSONSerialization.jsonObject(with: d)) as? [String: Any] else { return nil }
        func s(_ o: [String: Any], _ k: String) -> String { (o[k] as? String) ?? "" }
        var m = CNMascota()
        m.chinolo = s(r, "chinolo"); m.tituloAvisos = s(r, "tituloAvisos")
        m.verAvisos = s(r, "verAvisos"); m.volver = s(r, "volver"); m.nadaTexto = s(r, "nadaTexto")
        m.avisos = ((r["avisos"] as? [[String: Any]]) ?? []).enumerated().map { i, a in
            Aviso(id: i, titulo: s(a, "titulo"), detalle: s(a, "detalle"), color: s(a, "color"))
        }
        return m
    }
}

struct CNMascotaVista: View {
    @ObservedObject var datos: CNDatos
    var onClose: () -> Void
    @State private var vuelta = false
    @State private var salto = false

    var body: some View {
        let m = datos.mascota ?? CNMascota()
        return ZStack {
            Color.black.opacity(0.42).ignoresSafeArea().onTapGesture { onClose() }
            VStack(spacing: 0) {
                if vuelta { detras(m) } else { delante(m) }
            }
            .frame(maxWidth: 330)
            .padding(18)
            .background(CNC.card, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 26).stroke(CNC.line, lineWidth: 1))
            .shadow(color: .black.opacity(0.22), radius: 22, y: 8)
            .rotation3DEffect(.degrees(vuelta ? 180 : 0), axis: (x: 0, y: 1, z: 0))
            .scaleEffect(x: vuelta ? -1 : 1, y: 1)
            .padding(.horizontal, 20)
            .onTapGesture {
                UISelectionFeedbackGenerator().selectionChanged()
                withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) { vuelta.toggle() }
            }
        }
    }

    private func delante(_ m: CNMascota) -> some View {
        VStack(spacing: 12) {
            if let img = cnImagenBase64(m.chinolo) {
                Image(uiImage: img).resizable().scaledToFit().frame(width: 168, height: 168)
                    // Vivo, como en la web: respira despacio.
                    .scaleEffect(salto ? 1.045 : 0.985)
                    .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: salto)
                    .onAppear { salto = true }
            }
            if !m.verAvisos.isEmpty {
                Text(m.verAvisos).font(cnLetra(13.5, .semibold)).foregroundColor(CNC.pmut)
            }
        }
    }

    private func detras(_ m: CNMascota) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(m.tituloAvisos).font(cnLetra(16, .heavy)).foregroundColor(CNC.ink)
            if m.avisos.isEmpty {
                Text(m.nadaTexto).font(cnLetra(14)).foregroundColor(CNC.pmut)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                VStack(spacing: 0) {
                    ForEach(m.avisos) { a in
                        HStack(spacing: 10) {
                            Circle().fill(cnColor(hexString: a.color)).frame(width: 8, height: 8)
                            Text(a.titulo).font(cnLetra(14.5, .semibold)).foregroundColor(CNC.ink).lineLimit(1)
                            Spacer(minLength: 8)
                            Text(a.detalle).font(cnLetra(13)).foregroundColor(CNC.pmut).lineLimit(1)
                        }
                        .padding(.vertical, 9)
                        if a.id < m.avisos.count - 1 {
                            Rectangle().fill(CNC.line).frame(height: 0.5)
                        }
                    }
                }
            }
            if !m.volver.isEmpty {
                Text(m.volver).font(cnLetra(12.5)).foregroundColor(CNC.pmut)
                    .frame(maxWidth: .infinity, alignment: .center).padding(.top, 2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
