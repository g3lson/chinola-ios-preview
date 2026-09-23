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
    /// Un «+» a la derecha (crear algo desde la hoja), en vez del ✓.
    var onMas: (() -> Void)? = nil
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
                } else if let mas = onMas {
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        mas()
                    } label: {
                        Image(systemName: "plus").font(cnLetra(18, .bold))
                            .foregroundColor(CNC.sobreAcc)
                            .frame(width: 44, height: 44).cnVidrio(Circle(), tinte: CNC.acc)
                    }.buttonStyle(CNPulsable())
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
        /// Para los campos que no se escriben: el texto del botón de un enlace.
        var textoEnlace = ""
        /// Si el campo se puede bajar como archivo: su nombre y su contenido.
        var descarga = ""; var archivo = ""
        /// Una casilla que se marca (exportar/importar: qué partes van).
        var casilla = false; var marcada = false; var pista = ""
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
        if c.casilla {
            // La casilla: una fila que se marca y se desmarca, con lo que trae
            // a la derecha («128 movimientos»).
            Button {
                UISelectionFeedbackGenerator().selectionChanged()
                datos.onHojaCampo(c.id, "", "casilla")
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .fill(c.marcada ? CNC.acc : Color.clear)
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .stroke(c.marcada ? CNC.acc : CNC.line, lineWidth: 1.5)
                        if c.marcada {
                            Image(systemName: "checkmark").font(cnLetra(12, .heavy)).foregroundColor(CNC.sobreAcc)
                        }
                    }
                    .frame(width: 22, height: 22)
                    Text(c.label).font(cnLetra(15, .semibold)).foregroundColor(CNC.ink)
                    Spacer(minLength: 8)
                    if !c.pista.isEmpty {
                        Text(c.pista).font(cnLetra(13)).foregroundColor(CNC.pmut)
                    }
                }
                .padding(.horizontal, 14).padding(.vertical, 13)
                .background(CNC.card, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(CNC.line, lineWidth: 1))
                .contentShape(Rectangle())
            }.buttonStyle(CNPulsable())
        } else {
        VStack(alignment: .leading, spacing: 8) {
            cnHojaTitulo(c.label)
            if c.tipo == "qr" {
                // Un QR para escanear (la app de autenticación): siempre sobre
                // blanco, que un lector no lee bien un QR sobre papel oscuro.
                if let img = cnImagenBase64(c.valor) {
                    Image(uiImage: img).resizable().interpolation(.none).scaledToFit()
                        .frame(width: 200, height: 200).padding(6)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(CNC.line, lineWidth: 1))
                        .frame(maxWidth: .infinity)
                }
            } else if c.tipo == "nota" {
                // Texto para copiar (la clave de la app, los códigos de respaldo).
                VStack(alignment: .leading, spacing: 8) {
                    Text(c.valor).font(.system(size: 15, weight: .semibold, design: .monospaced))
                        .foregroundColor(CNC.ink).lineSpacing(5).textSelection(.enabled)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: 18) {
                        if !c.descarga.isEmpty {
                            // Como archivo: la hoja de compartir del sistema, que
                            // deja guardarlo en Archivos, en iCloud o mandarlo.
                            Button {
                                UISelectionFeedbackGenerator().selectionChanged()
                                cnCompartirTexto(nombre: c.descarga, texto: c.archivo.isEmpty ? c.valor : c.archivo)
                            } label: {
                                Text(cnT("Guardar archivo")).font(cnLetra(14, .semibold)).foregroundColor(CNC.pos)
                            }.buttonStyle(CNPulsable())
                        }
                        Button {
                            UIPasteboard.general.string = c.valor
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            CNMenuEstado.shared.alAviso(cnT("Copiado"), "")
                        } label: {
                            Text(cnT("Copiar")).font(cnLetra(14, .semibold)).foregroundColor(CNC.pos)
                        }.buttonStyle(CNPulsable())
                    }
                }
                .padding(14).frame(maxWidth: .infinity, alignment: .leading)
                .background(CNC.card, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(CNC.line, lineWidth: 1))
            } else if c.tipo == "enlace" {
                Button {
                    if let u = URL(string: c.valor) { UIApplication.shared.open(u) }
                } label: {
                    Text(c.textoEnlace.isEmpty ? cnT("Abrir") : c.textoEnlace).font(cnLetra(16, .bold))
                        .foregroundColor(CNC.sobreAcc)
                        .frame(maxWidth: .infinity).padding(.vertical, 15)
                        .background(CNC.acc, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }.buttonStyle(CNPulsable())
            } else if !c.colores.isEmpty {
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
                            iconos: l(c, "iconos").map { CNHojaWeb.Icono(id: n($0, "indice"), clave: s($0, "clave"), label: s($0, "label"), path: s($0, "path"), puesta: b($0, "puesta")) },
                            textoEnlace: s(c, "textoEnlace"), descarga: s(c, "descarga"), archivo: s(c, "archivo"),
                            casilla: b(c, "casilla"), marcada: b(c, "marcada"), pista: s(c, "pista"))
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
        .frame(maxWidth: .infinity, alignment: .top)
        .padding(.top, 8)
        .padding(.bottom, cnMargenAbajo())
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


// ── Una hoja de abajo, dibujada por nosotros ────────────────────────────────
//
// La del sistema (`pageSheet`) sale con márgenes a los lados y por abajo en
// iOS 26, como flotando. Esta va de orilla a orilla, pegada al pie, con las
// esquinas de arriba redondeadas y se cierra tirando de ella o tocando fuera.
struct CNEsquinasArriba: Shape {
    var radio: CGFloat = 30
    func path(in r: CGRect) -> Path {
        Path(UIBezierPath(roundedRect: r, byRoundingCorners: [.topLeft, .topRight],
                          cornerRadii: CGSize(width: radio, height: radio)).cgPath)
    }
}

struct CNHojaAbajo<C: View>: View {
    var onClose: () -> Void
    @ViewBuilder var contenido: () -> C
    @State private var y: CGFloat = 0
    @State private var aparecio = false

    var body: some View {
        // La pila entera fuera del margen seguro: con el margen puesto, la hoja
        // —que mide lo que mide su contenido— se alineaba al borde del margen y
        // por debajo asomaba una franja de la pantalla de detrás. El hueco del
        // indicador de inicio lo pone el contenido por dentro (cnMargenAbajo).
        ZStack(alignment: .bottom) {
            Color.black.opacity(aparecio ? 0.42 : 0)
                .onTapGesture { cerrar() }
            contenido()
                .frame(maxWidth: .infinity)
                .background(CNC.scr)
                .clipShape(CNEsquinasArriba(radio: 30))
                .shadow(color: .black.opacity(0.18), radius: 24, y: -4)
                .offset(y: aparecio ? max(0, y) : 900)
                .gesture(
                    DragGesture(minimumDistance: 10)
                        .onChanged { g in if g.translation.height > 0 { y = g.translation.height } }
                        .onEnded { g in
                            if g.translation.height > 110 || g.predictedEndTranslation.height > 260 { cerrar() }
                            else { withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) { y = 0 } }
                        }
                )
        }
        .ignoresSafeArea()
        .onAppear { withAnimation(.spring(response: 0.4, dampingFraction: 0.88)) { aparecio = true } }
    }

    private func cerrar() {
        withAnimation(.easeIn(duration: 0.2)) { aparecio = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { onClose() }
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
        /// Lo que hay dentro: el balance del mes y cuántos movimientos lleva.
        var cifra = ""; var cifraTinta = ""; var pie = ""
    }
    var titulo = "Libretas"
    var textoGestionar = ""
    var textoNueva = ""
    var rotuloOtras = ""
    var filas: [Fila] = []

    static func desde(json: String) -> CNLibretas? {
        guard let d = json.data(using: .utf8),
              let r = (try? JSONSerialization.jsonObject(with: d)) as? [String: Any] else { return nil }
        func s(_ o: [String: Any], _ k: String) -> String { (o[k] as? String) ?? "" }
        var m = CNLibretas()
        if !s(r, "titulo").isEmpty { m.titulo = s(r, "titulo") }
        m.textoGestionar = s(r, "textoGestionar")
        m.textoNueva = s(r, "textoNueva")
        m.rotuloOtras = s(r, "rotuloOtras")
        m.filas = ((r["filas"] as? [[String: Any]]) ?? []).map { f in
            Fila(indice: (f["indice"] as? NSNumber)?.intValue ?? 0,
                 nombre: s(f, "nombre"), detalle: s(f, "detalle"), iconoPath: s(f, "iconoPath"),
                 color: s(f, "color"), enUso: (f["enUso"] as? Bool) ?? false,
                 rotuloEnUso: s(f, "rotuloEnUso"),
                 cifra: s(f, "cifra"), cifraTinta: s(f, "cifraTinta"), pie: s(f, "pie"))
        }
        return m
    }
}

struct CNLibretasHoja: View {
    @ObservedObject var datos: CNDatos
    var onClose: () -> Void
    var body: some View {
        let m = datos.libretas ?? CNLibretas()
        let puesta = m.filas.first(where: { $0.enUso })
        let otras = m.filas.filter { !$0.enUso }
        let altoMax = UIScreen.main.bounds.height * 0.82
        return VStack(spacing: 0) {
            // La misma cabecera que el periodo y los formularios: cerrar a la
            // izquierda, el título en medio y el «+» en la esquina derecha.
            CNHojaCabecera(titulo: m.titulo, onClose: onClose, onMas: { datos.onLibreta("nueva", 0) })
                .padding(.top, 8)

            // Con pocas libretas la hoja mide lo que mide su contenido; solo si
            // son muchas se convierte en una lista que rueda.
            if m.filas.count > 5 {
                ScrollView(showsIndicators: false) { cuerpo(m, puesta: puesta, otras: otras) }
                    .frame(maxHeight: altoMax)
            } else {
                cuerpo(m, puesta: puesta, otras: otras)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func cuerpo(_ m: CNLibretas, puesta: CNLibretas.Fila?, otras: [CNLibretas.Fila]) -> some View {
                VStack(spacing: 14) {
                    // La que está puesta, en grande y arriba: es la que
                    // contesta «¿dónde estoy anotando?».
                    if let p = puesta { destacada(p) }
                    if !otras.isEmpty {
                        VStack(alignment: .leading, spacing: 7) {
                            if !m.rotuloOtras.isEmpty {
                                Text(m.rotuloOtras.uppercased()).font(cnLetra(11.5, .heavy)).tracking(0.8)
                                    .foregroundColor(CNC.pmut).padding(.leading, 4)
                            }
                            VStack(spacing: 0) {
                                ForEach(otras) { f in
                                    fila(f)
                                    if f.indice != otras.last?.indice {
                                        Rectangle().fill(CNC.line).frame(height: 0.5).padding(.leading, 62)
                                    }
                                }
                            }
                            .background(CNC.card)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 18).stroke(CNC.line, lineWidth: 1))
                        }
                    }
                    // Gestionar las que hay (crear va en el «+» de arriba).
                    if !m.textoGestionar.isEmpty {
                        accion("person.2", m.textoGestionar, tinte: nil) {
                            UISelectionFeedbackGenerator().selectionChanged()
                            datos.onLibreta("gestionar", 0)
                        }
                        .background(CNC.card)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(CNC.line, lineWidth: 1))
                    }
                    // Hasta debajo del indicador de inicio: la hoja llega al pie.
                    Color.clear.frame(height: 6 + cnMargenAbajo())
                }
                .padding(.horizontal, 16)
    }

    /// Una fila de acción: icono en su cuadro (del color de la marca si es la
    /// de crear), el texto y la flecha. Mide igual que las filas de libreta.
    private func accion(_ simbolo: String, _ texto: String, tinte: Color?, _ al: @escaping () -> Void) -> some View {
        Button(action: al) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .fill(tinte.map { $0.opacity(0.16) } ?? CNC.ink.opacity(0.06))
                    Image(systemName: simbolo).font(cnLetra(16, .bold))
                        .foregroundColor(tinte ?? CNC.pmut)
                }
                .frame(width: 42, height: 42)
                Text(texto).font(cnLetra(16, .bold)).foregroundColor(CNC.ink).lineLimit(1)
                Spacer(minLength: 8)
                Image(systemName: "chevron.right").font(cnLetra(11.5, .bold))
                    .foregroundColor(CNC.pmut.opacity(0.6))
            }
            .padding(.horizontal, 13).padding(.vertical, 11)
            .contentShape(Rectangle())
        }.buttonStyle(CNPulsable())
    }

    /// La libreta en uso: su color de fondo, su cifra del mes y su gente.
    private func destacada(_ f: CNLibretas.Fila) -> some View {
        let tinte = cnColor(hexString: f.color)
        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 15, style: .continuous).fill(tinte.opacity(0.18))
                    CNSVGShape(d: f.iconoPath)
                        .stroke(tinte, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                        .frame(width: 23, height: 23)
                }
                .frame(width: 48, height: 48)
                VStack(alignment: .leading, spacing: 2) {
                    Text(f.nombre).font(cnLetra(19, .heavy)).foregroundColor(CNC.ink).lineLimit(1)
                    Text(f.detalle).font(cnLetra(13)).foregroundColor(CNC.pmut).lineLimit(1)
                }
                Spacer(minLength: 8)
                Text(f.rotuloEnUso.uppercased()).font(cnLetra(10, .heavy)).tracking(0.5)
                    .foregroundColor(CNC.pos)
                    .padding(.horizontal, 9).padding(.vertical, 5)
                    .background(CNC.pos.opacity(0.14), in: Capsule())
            }
            if !f.cifra.isEmpty {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(f.cifra).font(cnLetra(24, .heavy))
                        .foregroundColor(f.cifraTinta.isEmpty ? CNC.ink : cnColor(hexString: f.cifraTinta))
                    Spacer(minLength: 8)
                    Text(f.pie).font(cnLetra(12.5)).foregroundColor(CNC.pmut)
                }
            }
        }
        .padding(16)
        .background(
            LinearGradient(colors: [tinte.opacity(0.16), tinte.opacity(0.06)],
                           startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func fila(_ f: CNLibretas.Fila) -> some View {
        Button {
            UISelectionFeedbackGenerator().selectionChanged()
            datos.onLibreta("elegir", f.indice)
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 13, style: .continuous).fill(cnColor(hexString: f.color))
                    CNSVGShape(d: f.iconoPath)
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 1.9, lineCap: .round, lineJoin: .round))
                        .frame(width: 20, height: 20)
                }
                .frame(width: 42, height: 42)
                VStack(alignment: .leading, spacing: 1) {
                    Text(f.nombre).font(cnLetra(16, .bold)).foregroundColor(CNC.ink).lineLimit(1)
                    Text(f.detalle).font(cnLetra(12.5)).foregroundColor(CNC.pmut).lineLimit(1)
                }
                Spacer(minLength: 8)
                if !f.cifra.isEmpty {
                    Text(f.cifra).font(cnLetra(14.5, .bold))
                        .foregroundColor(f.cifraTinta.isEmpty ? CNC.pmut : cnColor(hexString: f.cifraTinta))
                }
                Image(systemName: "chevron.right").font(cnLetra(11.5, .bold))
                    .foregroundColor(CNC.pmut.opacity(0.6))
            }
            .padding(.horizontal, 13).padding(.vertical, 11)
            .contentShape(Rectangle())
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
    /// Editando: lo que tiene puesto (color = índice en `coloresId`, -1 si es nueva).
    var nombre = ""; var tipo = ""; var icono = ""; var color = -1
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
        m.nombre = s(r, "nombre"); m.tipo = s(r, "tipo"); m.icono = s(r, "icono")
        m.color = ((r["color"] as? NSNumber)?.intValue) ?? -1
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
            // Editando, se empieza con lo que tiene la libreta.
            if nombre.isEmpty && !m.nombre.isEmpty { nombre = m.nombre }
            if tipo.isEmpty { tipo = m.tipo.isEmpty ? (m.tipos.first?.id ?? "Personal") : m.tipo }
            if icono.isEmpty { icono = m.icono.isEmpty ? (m.iconos.first?.id ?? "casa") : m.icono }
            if m.color >= 0 && m.color < m.colores.count { color = m.color }
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
    /// Qué señala el paso («tab-perfil», «libreta», «meses»…); vacío = nada.
    var ancla = ""
    var textoSiguiente = "Siguiente"; var textoSaltar = "Saltar"

    static func desde(json: String) -> CNTour? {
        guard let d = json.data(using: .utf8),
              let r = (try? JSONSerialization.jsonObject(with: d)) as? [String: Any] else { return nil }
        func s(_ o: [String: Any], _ k: String) -> String { (o[k] as? String) ?? "" }
        func n(_ o: [String: Any], _ k: String) -> Int { ((o[k] as? NSNumber)?.intValue) ?? 0 }
        var m = CNTour()
        m.paso = n(r, "paso"); m.total = max(1, n(r, "total")); m.vista = s(r, "vista")
        m.titulo = s(r, "titulo"); m.texto = s(r, "texto"); m.chinolo = s(r, "chinolo")
        m.ancla = s(r, "ancla")
        if !s(r, "textoSiguiente").isEmpty { m.textoSiguiente = s(r, "textoSiguiente") }
        if !s(r, "textoSaltar").isEmpty { m.textoSaltar = s(r, "textoSaltar") }
        return m
    }
}

struct CNTourVista: View {
    @ObservedObject var datos: CNDatos
    var onPaso: (String) -> Void
    /// Chino sube y baja mientras habla; el globo entra con un brinco.
    @State private var flota = false
    @State private var brinco = false
    @State private var altoGlobo: CGFloat = 220

    var body: some View {
        let m = datos.tour ?? CNTour()
        return GeometryReader { g in
            let W = g.size.width, H = g.size.height
            let origen = g.frame(in: .global).origin
            // El foco: lo que señala el paso, con un poco de aire alrededor.
            let caja: CGRect? = datos.anclas[m.ancla].map { r in
                r.offsetBy(dx: -origen.x, dy: -origen.y).insetBy(dx: -8, dy: -6)
            }
            let anchoG = min(330, W - 28)
            let geo = sitio(caja: caja, W: W, H: H, anchoG: anchoG)
            ZStack(alignment: .topLeading) {
                // El telón, con el hueco del foco: lo que se explica se ve
                // tal cual, y todo lo demás se apaga.
                Color.black.opacity(0.55)
                    .mask(
                        ZStack {
                            Rectangle()
                            if let c = caja {
                                RoundedRectangle(cornerRadius: min(22, c.height / 2), style: .continuous)
                                    .frame(width: c.width, height: c.height)
                                    .position(x: c.midX, y: c.midY)
                                    .blendMode(.destinationOut)
                            }
                        }
                        .compositingGroup()
                    )
                    .ignoresSafeArea()
                    .onTapGesture { onPaso("saltar") }
                if let c = caja {
                    // Un aro del color de la marca alrededor del foco.
                    RoundedRectangle(cornerRadius: min(22, c.height / 2), style: .continuous)
                        .stroke(CNC.acc, lineWidth: 2.5)
                        .frame(width: c.width, height: c.height)
                        .position(x: c.midX, y: c.midY)
                        .shadow(color: CNC.acc.opacity(0.6), radius: 10)
                }
                globo(m, anchoG: anchoG, picoX: geo.picoX, picoArriba: geo.picoArriba, picoAbajo: geo.picoAbajo)
                    .frame(width: anchoG)
                    .background(GeometryReader { gg in
                        Color.clear.preference(key: CNAltoGlobo.self, value: gg.size.height)
                    })
                    .offset(x: geo.gx, y: geo.gy)
                    .scaleEffect(brinco ? 1 : 0.96, anchor: geo.picoArriba ? .top : .bottom)
                    .opacity(brinco ? 1 : 0)
            }
            .onPreferenceChange(CNAltoGlobo.self) { altoGlobo = $0 }
            // Al cambiar de paso, el foco y el globo se van al sitio nuevo
            // con un muelle; no aparecen de golpe.
            .animation(.spring(response: 0.5, dampingFraction: 0.82), value: caja)
            .animation(.spring(response: 0.5, dampingFraction: 0.82), value: m.paso)
            .animation(.spring(response: 0.5, dampingFraction: 0.82), value: altoGlobo)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.7).delay(0.05)) { brinco = true }
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) { flota = true }
        }
        .onChange(of: m.paso) { _ in
            brinco = false
            withAnimation(.spring(response: 0.45, dampingFraction: 0.7).delay(0.12)) { brinco = true }
        }
    }

    private struct Sitio { var gx: CGFloat; var gy: CGFloat; var picoX: CGFloat; var picoArriba: Bool; var picoAbajo: Bool }

    /// Dónde va el globo: debajo del foco si cabe, si no encima; sin foco, en
    /// medio. Nunca tapa lo que señala.
    private func sitio(caja: CGRect?, W: CGFloat, H: CGFloat, anchoG: CGFloat) -> Sitio {
        let margen: CGFloat = 14
        let alto = altoGlobo
        guard let c = caja else {
            return Sitio(gx: (W - anchoG) / 2, gy: max(margen, H / 2 - alto / 2 - 40), picoX: 0, picoArriba: false, picoAbajo: false)
        }
        let debajo = c.maxY + 14 + alto < H - 40
        let gy = debajo ? c.maxY + 14 : max(margen, c.minY - 14 - alto)
        let gx = max(margen, min(W - margen - anchoG, c.midX - anchoG / 2))
        let picoX = max(18, min(anchoG - 34, c.midX - gx - 8))
        return Sitio(gx: gx, gy: gy, picoX: picoX, picoArriba: debajo, picoAbajo: !debajo)
    }

    private func globo(_ m: CNTour, anchoG: CGFloat, picoX: CGFloat, picoArriba: Bool, picoAbajo: Bool) -> some View {
        VStack(spacing: 0) {
            if picoArriba { pico(x: picoX).rotationEffect(.degrees(180)) }
            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: 12) {
                    if let img = cnImagenBase64(m.chinolo) {
                        Image(uiImage: img).resizable().scaledToFit().frame(width: 58, height: 58)
                            .offset(y: flota ? -4 : 3)
                            .rotationEffect(.degrees(flota ? -3 : 3))
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
                            Capsule().fill(i == m.paso ? CNC.acc : CNC.line)
                                .frame(width: i == m.paso ? 16 : 5, height: 5)
                        }
                    }
                    Spacer(minLength: 8)
                    Button { onPaso("saltar") } label: {
                        Text(m.textoSaltar).font(cnLetra(14.5, .semibold)).foregroundColor(CNC.pmut)
                            .padding(.horizontal, 12).padding(.vertical, 9)
                    }.buttonStyle(CNPulsable())
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        onPaso("siguiente")
                    } label: {
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
            .shadow(color: .black.opacity(0.22), radius: 18, y: 6)
            if picoAbajo { pico(x: picoX) }
        }
    }

    /// La puntita del globo, mirando al foco.
    private func pico(x: CGFloat) -> some View {
        HStack(spacing: 0) {
            Color.clear.frame(width: x, height: 1)
            Triangulo().fill(CNC.card).frame(width: 18, height: 9)
                .overlay(Triangulo().stroke(CNC.line, lineWidth: 1))
            Spacer(minLength: 0)
        }
        .frame(height: 9)
    }

    private struct Triangulo: Shape {
        func path(in r: CGRect) -> Path {
            var p = Path()
            p.move(to: CGPoint(x: r.minX, y: r.minY))
            p.addLine(to: CGPoint(x: r.midX, y: r.maxY))
            p.addLine(to: CGPoint(x: r.maxX, y: r.minY))
            p.closeSubpath()
            return p
        }
    }
}

private struct CNAltoGlobo: PreferenceKey {
    static var defaultValue: CGFloat = 220
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
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
        VStack(spacing: 14) {
            if let img = cnImagenBase64(m.chinolo) {
                Image(uiImage: img).resizable().scaledToFit().frame(width: 150, height: 150)
                    // Vivo, como en la web: respira despacio.
                    .scaleEffect(salto ? 1.045 : 0.985)
                    .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: salto)
                    .onAppear { salto = true }
            }
            // Lo que viene, a la vista, como en la PWA: no hay que voltear
            // nada para saber qué toca pagar.
            VStack(alignment: .leading, spacing: 8) {
                Text(m.tituloAvisos).font(cnLetra(13, .heavy)).foregroundColor(CNC.pmut).tracking(0.6)
                if m.avisos.isEmpty {
                    Text(m.nadaTexto).font(cnLetra(14)).foregroundColor(CNC.pmut)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    VStack(spacing: 0) {
                        ForEach(m.avisos.prefix(4)) { a in
                            HStack(spacing: 10) {
                                Circle().fill(cnColor(hexString: a.color)).frame(width: 8, height: 8)
                                Text(a.titulo).font(cnLetra(14.5, .semibold)).foregroundColor(CNC.ink).lineLimit(1)
                                Spacer(minLength: 8)
                                Text(a.detalle).font(cnLetra(13)).foregroundColor(CNC.pmut).lineLimit(1)
                            }
                            .padding(.vertical, 8)
                            if a.id < min(4, m.avisos.count) - 1 {
                                Rectangle().fill(CNC.line).frame(height: 0.5)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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

// ── La puerta: bienvenida, acceso, nombre y plan ────────────────────────────
//
// Todo lo de antes de entrar. La lógica —crear la cuenta, entrar, el correo de
// confirmación, el plan— sigue siendo la de la web, la misma que en el
// navegador; aquí solo se dibuja lo que toca y se le dice qué han tocado.
struct CNPuerta {
    struct Punto: Identifiable { var id: Int; var titulo = ""; var pie = ""; var iconoPath = ""; var color = ""; var fondo = "" }
    struct Plan: Identifiable { var id: Int; var clave = ""; var nombre = ""; var para = ""; var precio = ""; var cada = ""; var items: [String] = []; var puesto = false }
    var paso = ""
    var rotulo = ""; var titulo = ""; var texto = ""; var boton = ""; var segundo = ""; var atras = ""
    var chinolo = ""; var error = ""; var cargando = false; var pie = ""
    var indice = 0; var total = 1
    /// La acción de «atrás» de este paso (vacía si no hay): la flecha de arriba
    /// y el deslizar desde la orilla hacen las dos lo mismo.
    var volver = ""
    var lista: [Punto] = []
    // Acceso
    var registro = false
    /// Verificación en dos pasos: en vez de correo y contraseña se pide el
    /// código que llegó al correo.
    var codigo = false; var labelCodigo = ""; var valorCodigo = ""
    struct Metodo: Identifiable { var id: Int; var label = "" }
    var metodos: [Metodo] = []; var otrosRotulo = ""; var respaldoNota = ""
    var labelNombre = ""; var labelCorreo = ""; var labelClave = ""; var labelClave2 = ""
    var phCorreo = ""; var phClave2 = ""
    var nombre = ""; var email = ""; var clave = ""; var clave2 = ""
    var oDirecto = ""; var google = ""; var apple = ""
    var conApple = false; var conGoogle = false
    var olvide = ""; var cambiar = ""; var sinCuenta = ""
    // Nombre y plan
    var ph = ""; var valor = ""
    var salida = ""
    var planes: [Plan] = []

    static func desde(json: String) -> CNPuerta? {
        guard let d = json.data(using: .utf8),
              let r = (try? JSONSerialization.jsonObject(with: d)) as? [String: Any] else { return nil }
        func s(_ o: [String: Any], _ k: String) -> String { (o[k] as? String) ?? "" }
        func b(_ o: [String: Any], _ k: String) -> Bool { (o[k] as? Bool) ?? false }
        func n(_ o: [String: Any], _ k: String) -> Int { ((o[k] as? NSNumber)?.intValue) ?? 0 }
        var m = CNPuerta()
        m.paso = s(r, "paso")
        m.rotulo = s(r, "rotulo"); m.titulo = s(r, "titulo"); m.texto = s(r, "texto")
        m.boton = s(r, "boton"); m.segundo = s(r, "segundo"); m.atras = s(r, "atras")
        m.chinolo = s(r, "chinolo"); m.error = s(r, "error"); m.cargando = b(r, "cargando"); m.pie = s(r, "pie")
        m.indice = n(r, "indice"); m.total = max(1, n(r, "total"))
        m.volver = s(r, "volver")
        m.lista = ((r["lista"] as? [[String: Any]]) ?? []).enumerated().map { i, x in
            Punto(id: i, titulo: s(x, "titulo"), pie: s(x, "pie"), iconoPath: s(x, "iconoPath"),
                  color: s(x, "color"), fondo: s(x, "fondo"))
        }
        m.registro = b(r, "registro")
        m.codigo = b(r, "codigo"); m.labelCodigo = s(r, "labelCodigo"); m.valorCodigo = s(r, "valorCodigo")
        m.metodos = ((r["metodos"] as? [[String: Any]]) ?? []).enumerated().map { i, x in Metodo(id: i, label: s(x, "label")) }
        m.otrosRotulo = s(r, "otrosRotulo"); m.respaldoNota = s(r, "respaldoNota")
        m.labelNombre = s(r, "labelNombre"); m.labelCorreo = s(r, "labelCorreo")
        m.labelClave = s(r, "labelClave"); m.labelClave2 = s(r, "labelClave2")
        m.phCorreo = s(r, "phCorreo"); m.phClave2 = s(r, "phClave2")
        m.nombre = s(r, "nombre"); m.email = s(r, "email"); m.clave = s(r, "clave"); m.clave2 = s(r, "clave2")
        m.oDirecto = s(r, "oDirecto"); m.google = s(r, "google"); m.apple = s(r, "apple")
        m.conApple = b(r, "conApple"); m.conGoogle = b(r, "conGoogle")
        m.olvide = s(r, "olvide"); m.cambiar = s(r, "cambiar"); m.sinCuenta = s(r, "sinCuenta")
        m.ph = s(r, "ph"); m.valor = s(r, "valor"); m.salida = s(r, "salida")
        m.planes = ((r["planes"] as? [[String: Any]]) ?? []).enumerated().map { i, x in
            Plan(id: i, clave: s(x, "id"), nombre: s(x, "nombre"), para: s(x, "para"),
                 precio: s(x, "precio"), cada: s(x, "cada"),
                 items: (x["items"] as? [String]) ?? [], puesto: b(x, "puesto"))
        }
        return m
    }
}

struct CNPuertaVista: View {
    @ObservedObject var datos: CNDatos
    var onAccion: (String, String) -> Void
    @State private var nombre = ""
    @State private var email = ""
    @State private var clave = ""
    @State private var clave2 = ""
    @State private var quien = ""
    @State private var codigo = ""

    var body: some View {
        let m = datos.puerta ?? CNPuerta()
        return ZStack {
            CNC.scr.ignoresSafeArea()
            VStack(spacing: 0) {
            // La flecha de atrás, la misma de los detalles, en todos los pasos
            // que tienen un «antes». Deslizar desde la orilla hace lo mismo.
            if !m.volver.isEmpty {
                HStack {
                    Button {
                        UISelectionFeedbackGenerator().selectionChanged()
                        onAccion(m.volver, "")
                    } label: {
                        Image(systemName: "chevron.left").font(cnLetra(16, .bold))
                            .foregroundColor(CNC.ink).frame(width: 40, height: 40)
                            .background(CNC.soft, in: Circle())
                    }.buttonStyle(CNPulsable())
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 16).padding(.top, 6)
            }
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    switch m.paso {
                    case "portada", "lamina", "verifica", "listo", "nombre": contarUna(m)
                    case "auth": acceso(m)
                    case "plan": planes(m)
                    default: EmptyView()
                    }
                }
                .padding(.horizontal, 22).padding(.top, m.volver.isEmpty ? 26 : 10).padding(.bottom, 40)
                // La puerta de siempre, la de la web, a un toque. Si algo de
                // aquí fallara, nadie se queda fuera de su propia app.
                Button { onAccion("web", "") } label: {
                    Text(cnT("Seguir en la web")).font(cnLetra(13)).foregroundColor(CNC.pmut)
                        .frame(maxWidth: .infinity).padding(.bottom, 26)
                }.buttonStyle(.plain)
            }
            .cnTeclado()
            }
        }
        .onAppear { nombre = m.nombre; email = m.email; clave = m.clave; clave2 = m.clave2; quien = m.valor }
    }

    // Las pantallas que solo cuentan algo y tienen uno o dos botones.
    private func contarUna(_ m: CNPuerta) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            if let img = cnImagenBase64(m.chinolo) {
                Image(uiImage: img).resizable().scaledToFit().frame(width: 132, height: 132)
                    .frame(maxWidth: .infinity, alignment: .center).padding(.top, 10)
            }
            if !m.rotulo.isEmpty {
                Text(m.rotulo.uppercased()).font(cnLetra(12, .heavy)).tracking(0.8).foregroundColor(CNC.pmut)
            }
            Text(m.titulo).font(cnLetra(29, .bold)).foregroundColor(CNC.ink)
                .fixedSize(horizontal: false, vertical: true)
            if !m.texto.isEmpty {
                Text(m.texto).font(cnLetra(15.5)).foregroundColor(CNC.pmut)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if m.paso == "nombre" {
                CNCampoTexto(placeholder: m.ph, texto: $quien)
                    .onChange(of: quien) { v in onAccion("nombre", v) }
            }
            if !m.lista.isEmpty {
                VStack(spacing: 0) {
                    ForEach(m.lista) { p in
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(cnColor(hexString: p.fondo)).frame(width: 40, height: 40)
                                CNSVGShape(d: p.iconoPath)
                                    .stroke(cnColor(hexString: p.color),
                                            style: StrokeStyle(lineWidth: 1.9, lineCap: .round, lineJoin: .round))
                                    .frame(width: 20, height: 20)
                            }
                            VStack(alignment: .leading, spacing: 1) {
                                Text(p.titulo).font(cnLetra(15, .bold)).foregroundColor(CNC.ink)
                                Text(p.pie).font(cnLetra(12.5)).foregroundColor(CNC.pmut)
                            }
                            Spacer(minLength: 0)
                        }
                        .padding(.vertical, 9)
                    }
                }
            }
            if !m.error.isEmpty { aviso(m.error) }
            if m.total > 1 && m.paso == "lamina" {
                HStack(spacing: 6) {
                    ForEach(0..<m.total, id: \.self) { i in
                        Capsule().fill(i <= m.indice ? CNC.pos : CNC.line)
                            .frame(width: i == m.indice ? 18 : 7, height: 7)
                    }
                }.padding(.top, 2)
            }
            botonGrande(m.boton) {
                switch m.paso {
                case "portada": onAccion("portada", "")
                case "lamina": onAccion("lamina", "")
                case "nombre": onAccion("nombre-seguir", "")
                case "verifica": onAccion("verifica-reenviar", "")
                default: onAccion("listo", "")
                }
            }
            if !m.segundo.isEmpty {
                botonSuave(m.segundo) {
                    switch m.paso {
                    case "portada": onAccion("ya-tengo", "")
                    case "lamina": onAccion("lamina-2", "")
                    default: onAccion("verifica-volver", "")
                    }
                }
            }
        }
    }

    private func acceso(_ m: CNPuerta) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            if !m.rotulo.isEmpty {
                Text(m.rotulo.uppercased()).font(cnLetra(12, .heavy)).tracking(0.8).foregroundColor(CNC.pmut)
                    .padding(.top, 8)
            }
            Text(m.titulo).font(cnLetra(29, .bold)).foregroundColor(CNC.ink)
            if !m.texto.isEmpty {
                Text(m.texto).font(cnLetra(15.5)).foregroundColor(CNC.pmut)
                    .fixedSize(horizontal: false, vertical: true)
            }
            VStack(spacing: 10) {
                if m.codigo {
                    // El código de dos pasos, y nada más: correo y contraseña
                    // ya se dieron. El teclado normal: un código de respaldo
                    // lleva letras.
                    CNCampoTexto(placeholder: m.labelCodigo, texto: $codigo, teclado: .asciiCapable)
                        .onChange(of: codigo) { v in onAccion("campo", "codigo|" + v) }
                    if !m.metodos.isEmpty {
                        // Los otros métodos que tiene: pedir el código por otro lado.
                        VStack(alignment: .leading, spacing: 8) {
                            Text(m.otrosRotulo).font(cnLetra(12.5)).foregroundColor(CNC.pmut)
                            HStack(spacing: 8) {
                                ForEach(m.metodos) { x in
                                    Button {
                                        UISelectionFeedbackGenerator().selectionChanged()
                                        onAccion("metodo", String(x.id))
                                    } label: {
                                        Text(x.label).font(cnLetra(12.5, .bold)).foregroundColor(CNC.ink)
                                            .padding(.horizontal, 12).padding(.vertical, 8)
                                            .background(CNC.card, in: Capsule())
                                            .overlay(Capsule().stroke(CNC.line, lineWidth: 1))
                                    }.buttonStyle(CNPulsable())
                                }
                                Spacer(minLength: 0)
                            }
                        }.padding(.top, 2)
                    }
                    if !m.respaldoNota.isEmpty {
                        Text(m.respaldoNota).font(cnLetra(12)).foregroundColor(CNC.pmut)
                    }
                } else {
                if m.registro {
                    CNCampoTexto(placeholder: m.labelNombre, texto: $nombre)
                        .onChange(of: nombre) { v in onAccion("campo", "nombre|" + v) }
                }
                CNCampoTexto(placeholder: m.phCorreo.isEmpty ? m.labelCorreo : m.phCorreo, texto: $email, teclado: .emailAddress)
                    .onChange(of: email) { v in onAccion("campo", "correo|" + v) }
                CNCampoClave(placeholder: m.labelClave, texto: $clave)
                    .onChange(of: clave) { v in onAccion("campo", "clave|" + v) }
                if m.registro {
                    CNCampoClave(placeholder: m.phClave2.isEmpty ? m.labelClave2 : m.phClave2, texto: $clave2)
                        .onChange(of: clave2) { v in onAccion("campo", "clave2|" + v) }
                }
                }
            }
            if !m.error.isEmpty { aviso(m.error) }
            botonGrande(m.boton, cargando: m.cargando) { cnCerrarTeclado(); onAccion("entrar", "") }
            if !m.olvide.isEmpty && !m.codigo {
                Button { onAccion("olvide", "") } label: {
                    Text(m.olvide).font(cnLetra(14, .semibold)).foregroundColor(CNC.pmut)
                        .frame(maxWidth: .infinity)
                }.buttonStyle(CNPulsable())
            }
            if (m.conApple || m.conGoogle) && !m.codigo {
                HStack(spacing: 10) {
                    Rectangle().fill(CNC.line).frame(height: 0.5)
                    Text(m.oDirecto).font(cnLetra(12)).foregroundColor(CNC.pmut).fixedSize()
                    Rectangle().fill(CNC.line).frame(height: 0.5)
                }.padding(.vertical, 2)
                HStack(spacing: 10) {
                    if m.conApple {
                        proveedor("apple.logo", m.apple) { onAccion("apple", "") }
                    }
                    if m.conGoogle {
                        proveedor("g.circle", m.google) { onAccion("google", "") }
                    }
                }
            }
            if !m.codigo {
            HStack(spacing: 6) {
                Spacer(minLength: 0)
                Button { onAccion("modo", m.registro ? "login" : "registro") } label: {
                    Text(m.cambiar).font(cnLetra(14.5, .bold)).foregroundColor(CNC.pos)
                }.buttonStyle(CNPulsable())
                Spacer(minLength: 0)
            }.padding(.top, 4)
            }
            if !m.sinCuenta.isEmpty && !m.codigo {
                botonSuave(m.sinCuenta) { onAccion("sin-cuenta", "") }
            }
        }
    }

    private func planes(_ m: CNPuerta) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            if !m.rotulo.isEmpty {
                Text(m.rotulo.uppercased()).font(cnLetra(12, .heavy)).tracking(0.8).foregroundColor(CNC.pmut)
                    .padding(.top, 8)
            }
            Text(m.titulo).font(cnLetra(27, .bold)).foregroundColor(CNC.ink)
            if !m.texto.isEmpty {
                Text(m.texto).font(cnLetra(15)).foregroundColor(CNC.pmut)
                    .fixedSize(horizontal: false, vertical: true)
            }
            ForEach(m.planes) { p in
                Button {
                    UISelectionFeedbackGenerator().selectionChanged()
                    onAccion("plan-elegir", String(p.id))
                } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .center, spacing: 10) {
                            // La marca de elegido, como una opción de iOS: se ve
                            // cuál está puesto sin leer el borde.
                            ZStack {
                                Circle().stroke(p.puesto ? CNC.acc : CNC.line, lineWidth: p.puesto ? 0 : 1.5)
                                if p.puesto {
                                    Circle().fill(CNC.acc)
                                    Image(systemName: "checkmark").font(cnLetra(11, .heavy)).foregroundColor(CNC.sobreAcc)
                                }
                            }
                            .frame(width: 22, height: 22)
                            Text(p.nombre).font(cnLetra(17, .heavy)).foregroundColor(CNC.ink)
                            Spacer(minLength: 8)
                            VStack(alignment: .trailing, spacing: 0) {
                                Text(p.precio).font(cnLetra(16, .heavy)).foregroundColor(CNC.ink)
                                if !p.cada.isEmpty {
                                    Text(p.cada).font(cnLetra(11.5)).foregroundColor(CNC.pmut)
                                }
                            }
                        }
                        if !p.para.isEmpty {
                            Text(p.para).font(cnLetra(13)).foregroundColor(CNC.pmut).padding(.leading, 32)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(p.items.indices, id: \.self) { k in
                                HStack(alignment: .top, spacing: 7) {
                                    Image(systemName: "checkmark").font(cnLetra(10.5, .bold)).foregroundColor(CNC.pos)
                                        .padding(.top, 3)
                                    Text(p.items[k]).font(cnLetra(13)).foregroundColor(CNC.pmut)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                        .padding(.leading, 32)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(p.puesto ? CNC.soft : CNC.card,
                                in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 18)
                        .stroke(p.puesto ? CNC.acc : CNC.line, lineWidth: p.puesto ? 2 : 1))
                }.buttonStyle(CNPulsable())
            }
            if !m.error.isEmpty { aviso(m.error) }
            if !m.pie.isEmpty {
                Text(m.pie).font(cnLetra(12.5)).foregroundColor(CNC.pmut)
                    .fixedSize(horizontal: false, vertical: true)
            }
            botonGrande(m.boton, cargando: m.cargando) { onAccion("plan-seguir", "") }
            if !m.salida.isEmpty { botonSuave(m.salida) { onAccion("plan-salir", "") } }
        }
    }

    private func aviso(_ t: String) -> some View {
        Text(t).font(cnLetra(13.5)).foregroundColor(CNC.neg)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(CNC.neg.opacity(0.10), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    /// Mientras `cargando` (la caja de Apple, el servidor) el botón da vueltas
    /// y no responde: dos toques no compran dos veces.
    private func botonGrande(_ t: String, cargando: Bool = false, _ go: @escaping () -> Void) -> some View {
        Button { UIImpactFeedbackGenerator(style: .medium).impactOccurred(); go() } label: {
            HStack(spacing: 8) {
                if cargando {
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: CNC.sobreAcc))
                }
                Text(t).font(cnLetra(16, .bold)).foregroundColor(CNC.sobreAcc)
            }
            .frame(maxWidth: .infinity).padding(.vertical, 16)
            .background(CNC.acc, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(CNPulsable()).padding(.top, 2)
        .disabled(cargando).opacity(cargando ? 0.75 : 1)
    }

    private func botonSuave(_ t: String, _ go: @escaping () -> Void) -> some View {
        Button { UISelectionFeedbackGenerator().selectionChanged(); go() } label: {
            Text(t).font(cnLetra(15, .semibold)).foregroundColor(CNC.ink)
                .frame(maxWidth: .infinity).padding(.vertical, 14)
                .background(CNC.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(CNC.line, lineWidth: 1))
        }.buttonStyle(CNPulsable())
    }

    private func proveedor(_ icono: String, _ t: String, _ go: @escaping () -> Void) -> some View {
        Button { UISelectionFeedbackGenerator().selectionChanged(); go() } label: {
            HStack(spacing: 7) {
                Image(systemName: icono).font(cnLetra(16, .semibold))
                Text(t).font(cnLetra(15, .semibold))
            }
            .foregroundColor(CNC.ink)
            .frame(maxWidth: .infinity).padding(.vertical, 13)
            .background(CNC.card, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(CNC.line, lineWidth: 1))
        }.buttonStyle(CNPulsable())
    }
}

/// Campo de contraseña, con el ojo para verla.
struct CNCampoClave: View {
    let placeholder: String
    @Binding var texto: String
    @State private var visible = false
    var body: some View {
        HStack(spacing: 8) {
            Group {
                if visible { TextField(placeholder, text: $texto) }
                else { SecureField(placeholder, text: $texto) }
            }
            .font(cnLetra(16)).foregroundColor(CNC.ink)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            Button { visible.toggle() } label: {
                Image(systemName: visible ? "eye.slash" : "eye").font(cnLetra(15))
                    .foregroundColor(CNC.pmut)
            }.buttonStyle(.plain)
        }
        .padding(.horizontal, 14).padding(.vertical, 14)
        .background(CNC.card, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(CNC.line, lineWidth: 1))
    }
}

// ── La categoría: crear o editar, en nativo ─────────────────────────────────
//
// Era lo último que obligaba a enseñar la web desde una pantalla nativa: tocar
// «Editar» en una categoría abría su ventana de la web. Los iconos, los colores
// y el guardado siguen siendo los de siempre.
struct CNHojaCategoria {
    struct Icono: Identifiable { var id: Int; var label = ""; var path = ""; var puesto = false }
    struct Color2: Identifiable { var id: Int; var css = ""; var puesta = false }
    struct Tipo: Identifiable { var id: Int; var label = ""; var puesto = false }
    var titulo = ""; var phNombre = ""; var nombre = ""
    var rotuloTipo = ""; var rotuloIcono = ""; var rotuloColor = ""
    var rotuloLimite = ""; var phLimite = ""; var limite = ""; var boton = "Guardar"
    var tipos: [Tipo] = []; var iconos: [Icono] = []; var colores: [Color2] = []

    static func desde(json: String) -> CNHojaCategoria? {
        guard let d = json.data(using: .utf8),
              let r = (try? JSONSerialization.jsonObject(with: d)) as? [String: Any] else { return nil }
        func s(_ o: [String: Any], _ k: String) -> String { (o[k] as? String) ?? "" }
        func b(_ o: [String: Any], _ k: String) -> Bool { (o[k] as? Bool) ?? false }
        func n(_ o: [String: Any], _ k: String) -> Int { ((o[k] as? NSNumber)?.intValue) ?? 0 }
        var m = CNHojaCategoria()
        m.titulo = s(r, "titulo"); m.phNombre = s(r, "phNombre"); m.nombre = s(r, "nombre")
        m.rotuloTipo = s(r, "rotuloTipo"); m.rotuloIcono = s(r, "rotuloIcono")
        m.rotuloColor = s(r, "rotuloColor"); m.rotuloLimite = s(r, "rotuloLimite")
        m.phLimite = s(r, "phLimite"); m.limite = s(r, "limite")
        if !s(r, "boton").isEmpty { m.boton = s(r, "boton") }
        m.tipos = ((r["tipos"] as? [[String: Any]]) ?? []).map { Tipo(id: n($0, "indice"), label: s($0, "label"), puesto: b($0, "puesto")) }
        m.iconos = ((r["iconos"] as? [[String: Any]]) ?? []).map { Icono(id: n($0, "indice"), label: s($0, "label"), path: s($0, "path"), puesto: b($0, "puesto")) }
        m.colores = ((r["colores"] as? [[String: Any]]) ?? []).map { Color2(id: n($0, "indice"), css: s($0, "css"), puesta: b($0, "puesta")) }
        return m
    }
}

struct CNFormCategoria: View {
    @ObservedObject var datos: CNDatos
    var onClose: () -> Void
    @State private var nombre = ""
    @State private var limite = ""
    @State private var puesto = false

    var body: some View {
        let m = datos.categoria ?? CNHojaCategoria()
        let tinte = m.colores.first(where: { $0.puesta }).map { cnColor(hexString: $0.css) } ?? CNC.acc
        return CNHoja(titulo: m.titulo, guardarTexto: m.boton,
                      guardarActivo: !nombre.trimmingCharacters(in: .whitespaces).isEmpty,
                      onClose: onClose, onGuardar: { datos.onCategoria("guardar", ""); onClose() }) {
            CNCampoTexto(placeholder: m.phNombre, texto: $nombre)
                .onChange(of: nombre) { v in datos.onCategoria("nombre", v) }
            if !m.tipos.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    cnHojaTitulo(m.rotuloTipo)
                    HStack(spacing: 8) {
                        ForEach(m.tipos) { t in
                            Button {
                                UISelectionFeedbackGenerator().selectionChanged()
                                datos.onCategoria("tipo", String(t.id))
                            } label: {
                                Text(t.label).font(cnLetra(14.5, t.puesto ? .bold : .semibold))
                                    .foregroundColor(t.puesto ? cnSobre(CNC.side) : CNC.ink)
                                    .frame(maxWidth: .infinity).padding(.vertical, 12)
                                    .background(t.puesto ? CNC.side : CNC.card,
                                                in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                                    .overlay(RoundedRectangle(cornerRadius: 13)
                                        .stroke(CNC.line, lineWidth: t.puesto ? 0 : 1))
                            }.buttonStyle(CNPulsable())
                        }
                    }
                }
            }
            VStack(alignment: .leading, spacing: 6) {
                cnHojaTitulo(m.rotuloLimite)
                CNMontoCampo(monto: $limite, paso: 500, rotulo: nil)
                    .onChange(of: limite) { v in datos.onCategoria("limite", v) }
                Text(m.phLimite).font(cnLetra(12)).foregroundColor(CNC.pmut).padding(.leading, 4)
            }
            if !m.iconos.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    cnHojaTitulo(m.rotuloIcono)
                    CNRejillaFija(columnas: 6, total: m.iconos.count) { i in
                        let ic = m.iconos[i]
                        Button {
                            UISelectionFeedbackGenerator().selectionChanged()
                            datos.onCategoria("icono", String(ic.id))
                        } label: {
                            CNSVGShape(d: ic.path)
                                .stroke(ic.puesto ? tinte : CNC.pmut,
                                        style: StrokeStyle(lineWidth: 1.9, lineCap: .round, lineJoin: .round))
                                .frame(width: 19, height: 19)
                                .frame(height: 44).frame(maxWidth: .infinity)
                                .background(ic.puesto ? tinte.opacity(0.16) : CNC.card,
                                            in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 13)
                                    .stroke(ic.puesto ? tinte : CNC.line, lineWidth: ic.puesto ? 1.6 : 0.5))
                        }.buttonStyle(CNPulsable())
                    }
                }
            }
            if !m.colores.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    cnHojaTitulo(m.rotuloColor)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(m.colores) { c in
                                Circle().fill(cnColor(hexString: c.css))
                                    .frame(width: 30, height: 30)
                                    .overlay(Circle().stroke(CNC.ink, lineWidth: c.puesta ? 2.5 : 0))
                                    .onTapGesture {
                                        UISelectionFeedbackGenerator().selectionChanged()
                                        datos.onCategoria("color", String(c.id))
                                    }
                            }
                        }.padding(.horizontal, 2).padding(.vertical, 2)
                    }
                }
            }
        }
        .onAppear {
            guard !puesto else { return }
            puesto = true
            nombre = m.nombre; limite = m.limite
        }
    }
}

/// Escribe un texto en un archivo temporal y abre la hoja de compartir del
/// sistema con él: «Guardar en Archivos», AirDrop, correo… lo que la persona
/// quiera hacer con sus códigos.
func cnCompartirTexto(nombre: String, texto: String) {
    let url = FileManager.default.temporaryDirectory.appendingPathComponent(nombre)
    do { try texto.write(to: url, atomically: true, encoding: .utf8) } catch { return }
    let hoja = UIActivityViewController(activityItems: [url], applicationActivities: nil)
    let escenas = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    let ventana = escenas.flatMap { $0.windows }.first { $0.isKeyWindow }
    var arriba = ventana?.rootViewController
    while let p = arriba?.presentedViewController { arriba = p }
    hoja.popoverPresentationController?.sourceView = arriba?.view
    hoja.popoverPresentationController?.sourceRect = CGRect(x: (arriba?.view.bounds.midX ?? 0), y: (arriba?.view.bounds.midY ?? 0), width: 1, height: 1)
    arriba?.present(hoja, animated: true)
}

// ── Hablar con Chino ────────────────────────────────────────────────────────
//
// Una charla: burbujas, la caja de texto y el micrófono (el reconocimiento
// de voz del teléfono, sin mandar audio a nadie). Lo que se escribe va a la
// web, que habla con el servidor; aquí se dibuja lo que vuelve.
import Speech
import AVFoundation

struct CNCharla {
    struct Mensaje: Identifiable { var id: Int; var de = ""; var texto = ""; var error = false }
    var titulo = "Chino"; var ph = ""; var iaOn = false; var pensando = false
    var chinolo = ""; var vacioTexto = ""
    var mensajes: [Mensaje] = []
    static func desde(json: String) -> CNCharla? {
        guard let d = json.data(using: .utf8),
              let r = (try? JSONSerialization.jsonObject(with: d)) as? [String: Any] else { return nil }
        func s(_ o: [String: Any], _ k: String) -> String { (o[k] as? String) ?? "" }
        func b(_ o: [String: Any], _ k: String) -> Bool { (o[k] as? Bool) ?? false }
        var m = CNCharla()
        if !s(r, "titulo").isEmpty { m.titulo = s(r, "titulo") }
        m.ph = s(r, "ph"); m.iaOn = b(r, "iaOn"); m.pensando = b(r, "pensando")
        m.chinolo = s(r, "chinolo"); m.vacioTexto = s(r, "vacioTexto")
        m.mensajes = ((r["mensajes"] as? [[String: Any]]) ?? []).map {
            Mensaje(id: (($0["indice"] as? NSNumber)?.intValue) ?? 0, de: s($0, "de"), texto: s($0, "texto"), error: b($0, "error"))
        }
        return m
    }
}

/// El dictado: el reconocedor del sistema, en el idioma de la app.
final class CNDictado: ObservableObject {
    @Published var texto = ""
    @Published var grabando = false
    private let motor = AVAudioEngine()
    private var tarea: SFSpeechRecognitionTask?
    private var peticion: SFSpeechAudioBufferRecognitionRequest?

    func alternar() { if grabando { parar() } else { empezar() } }

    func empezar() {
        SFSpeechRecognizer.requestAuthorization { estado in
            DispatchQueue.main.async {
                guard estado == .authorized else { return }
                AVAudioSession.sharedInstance().requestRecordPermission { ok in
                    DispatchQueue.main.async { if ok { self.arranca() } }
                }
            }
        }
    }
    private func arranca() {
        guard let rec = SFSpeechRecognizer(locale: Locale(identifier: CNC.fmt.loc)) ?? SFSpeechRecognizer(), rec.isAvailable else { return }
        let sesion = AVAudioSession.sharedInstance()
        try? sesion.setCategory(.record, mode: .measurement, options: .duckOthers)
        try? sesion.setActive(true, options: .notifyOthersOnDeactivation)
        let p = SFSpeechAudioBufferRecognitionRequest()
        p.shouldReportPartialResults = true
        peticion = p
        let entrada = motor.inputNode
        let formato = entrada.outputFormat(forBus: 0)
        entrada.removeTap(onBus: 0)
        entrada.installTap(onBus: 0, bufferSize: 1024, format: formato) { buffer, _ in p.append(buffer) }
        motor.prepare()
        do { try motor.start() } catch { return }
        grabando = true
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        tarea = rec.recognitionTask(with: p) { [weak self] res, err in
            DispatchQueue.main.async {
                guard let s = self else { return }
                if let r = res { s.texto = r.bestTranscription.formattedString }
                if err != nil || (res?.isFinal ?? false) { s.parar() }
            }
        }
    }
    func parar() {
        guard grabando else { return }
        motor.stop(); motor.inputNode.removeTap(onBus: 0)
        peticion?.endAudio(); tarea?.cancel(); tarea = nil; peticion = nil
        grabando = false
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}

struct CNCharlaVista: View {
    @ObservedObject var datos: CNDatos
    var onClose: () -> Void
    @State private var texto = ""
    @StateObject private var dictado = CNDictado()
    @State private var flota = false

    var body: some View {
        let m = datos.charla ?? CNCharla()
        return VStack(spacing: 0) {
            CNHojaCabecera(titulo: m.titulo, onClose: onClose)
            ScrollViewReader { lector in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 8) {
                        if m.mensajes.isEmpty {
                            VStack(spacing: 12) {
                                if let img = cnImagenBase64(m.chinolo) {
                                    Image(uiImage: img).resizable().scaledToFit().frame(width: 120, height: 120)
                                        .offset(y: flota ? -4 : 3)
                                        .animation(.easeInOut(duration: 1.3).repeatForever(autoreverses: true), value: flota)
                                        .onAppear { flota = true }
                                }
                                Text(m.vacioTexto).font(cnLetra(14)).foregroundColor(CNC.pmut)
                                    .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
                                    .padding(.horizontal, 24)
                            }
                            .padding(.top, 30)
                        }
                        ForEach(m.mensajes) { x in
                            HStack {
                                if x.de == "yo" { Spacer(minLength: 50) }
                                Text(x.texto).font(cnLetra(15))
                                    .foregroundColor(x.de == "yo" ? CNC.sobreAcc : (x.error ? CNC.neg : CNC.ink))
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.horizontal, 14).padding(.vertical, 10)
                                    .background(x.de == "yo" ? CNC.acc : (x.error ? CNC.neg.opacity(0.10) : CNC.card),
                                                in: CNBurbuja(mia: x.de == "yo"))
                                if x.de != "yo" { Spacer(minLength: 50) }
                            }
                            .id(x.id)
                        }
                        if m.pensando {
                            HStack {
                                Text("…").font(cnLetra(15)).foregroundColor(CNC.pmut)
                                    .padding(.horizontal, 14).padding(.vertical, 10)
                                    .background(CNC.card, in: CNBurbuja(mia: false))
                                Spacer(minLength: 50)
                            }
                            .id(-1)
                        }
                        if !m.mensajes.isEmpty && !m.pensando {
                            Button { datos.onCharlaLimpiar() } label: {
                                Text(cnT("Empezar de nuevo")).font(cnLetra(13)).foregroundColor(CNC.pmut).padding(6)
                            }.buttonStyle(CNPulsable())
                        }
                        Color.clear.frame(height: 6).id("fin")
                    }
                    .padding(.horizontal, 16).padding(.top, 6)
                }
                .onChange(of: m.mensajes.count) { _ in withAnimation { lector.scrollTo("fin", anchor: .bottom) } }
                .onChange(of: m.pensando) { _ in withAnimation { lector.scrollTo("fin", anchor: .bottom) } }
            }
            // La caja: micrófono, texto y enviar.
            HStack(alignment: .bottom, spacing: 8) {
                Button {
                    dictado.alternar()
                } label: {
                    Image(systemName: dictado.grabando ? "stop.fill" : "mic.fill").font(cnLetra(18, .semibold))
                        .foregroundColor(dictado.grabando ? .white : CNC.ink)
                        .frame(width: 46, height: 46)
                        .background(dictado.grabando ? CNC.neg : CNC.soft, in: Circle())
                }.buttonStyle(CNPulsable())
                TextField(m.ph, text: $texto, axis: .vertical)
                    .lineLimit(1...4)
                    .font(cnLetra(16)).foregroundColor(CNC.ink)
                    .padding(.horizontal, 15).padding(.vertical, 12)
                    .background(CNC.card, in: RoundedRectangle(cornerRadius: 23, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 23).stroke(CNC.line, lineWidth: 1))
                    .onSubmit { mandar() }
                Button { mandar() } label: {
                    Image(systemName: "arrow.up").font(cnLetra(18, .bold)).foregroundColor(CNC.sobreAcc)
                        .frame(width: 46, height: 46).background(CNC.acc, in: Circle())
                }
                .buttonStyle(CNPulsable())
                .disabled(texto.trimmingCharacters(in: .whitespaces).isEmpty || m.pensando)
                .opacity(texto.trimmingCharacters(in: .whitespaces).isEmpty || m.pensando ? 0.5 : 1)
            }
            .padding(.horizontal, 14).padding(.top, 8).padding(.bottom, 10)
            .background(CNC.scr)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(CNC.scr.ignoresSafeArea())
        .environment(\.locale, Locale(identifier: CNC.fmt.loc))
        .onReceive(dictado.$texto) { t in if !t.isEmpty { texto = t } }
        .onChange(of: dictado.grabando) { on in
            // Al soltar el micrófono se manda solo lo dictado.
            if !on, !texto.trimmingCharacters(in: .whitespaces).isEmpty, !dictado.texto.isEmpty { mandar() }
        }
        .onDisappear { dictado.parar() }
    }

    private func mandar() {
        let t = texto.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        datos.onCharla(t)
        texto = ""; dictado.texto = ""
    }
}

/// La burbuja: redonda salvo la esquina de quien habla, que va casi recta.
struct CNBurbuja: Shape {
    var mia: Bool
    func path(in r: CGRect) -> Path {
        let g: CGFloat = 18, ch: CGFloat = 5
        // Radios por esquina: arriba-izq, arriba-der, abajo-der, abajo-izq.
        let (ai, ad, bd, bi): (CGFloat, CGFloat, CGFloat, CGFloat) = mia ? (g, g, ch, g) : (g, g, g, ch)
        var p = Path()
        p.move(to: CGPoint(x: r.minX + ai, y: r.minY))
        p.addLine(to: CGPoint(x: r.maxX - ad, y: r.minY))
        p.addArc(center: CGPoint(x: r.maxX - ad, y: r.minY + ad), radius: ad, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
        p.addLine(to: CGPoint(x: r.maxX, y: r.maxY - bd))
        p.addArc(center: CGPoint(x: r.maxX - bd, y: r.maxY - bd), radius: bd, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        p.addLine(to: CGPoint(x: r.minX + bi, y: r.maxY))
        p.addArc(center: CGPoint(x: r.minX + bi, y: r.maxY - bi), radius: bi, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        p.addLine(to: CGPoint(x: r.minX, y: r.minY + ai))
        p.addArc(center: CGPoint(x: r.minX + ai, y: r.minY + ai), radius: ai, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        p.closeSubpath()
        return p
    }
}
