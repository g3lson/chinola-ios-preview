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
        // LA BARRA DE LA HOJA ES DEL SISTEMA.
        //
        // Por aquí pasan NUEVE formularios (cuenta, tarjeta, préstamo, meta,
        // transferencia, libreta, invitar…), así que esto se arregla una vez y
        // valen todos. Llevaban la misma imitación que tenía «Nuevo
        // movimiento» antes de cambiarlo: una X en un círculo gris y un ✓ en
        // un círculo amarillo. Ahora son «Cancelar» y «Guardar» de verdad, con
        // su cápsula de vidrio en iOS 26.
        //
        // Sin fondo ni esquinas propias: la hoja es del sistema (detents,
        // tirador, arrastre elástico y atenuado), como en cualquier app de Apple.
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) { content(); Color.clear.frame(height: 24) }
                    .padding(.horizontal, 16).padding(.top, 8)
            }
            .cnTeclado()
            .background(CNC.scr.ignoresSafeArea())
            .navigationTitle(titulo)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(cnT("Cancelar")) { onClose() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button { onGuardar() } label: {
                        Text(guardarTexto).font(cnLetra(17, .semibold))
                    }
                    .disabled(!guardarActivo)
                }
            }
        }
        .navigationViewStyle(.stack)
        .tint(CNC.pos)
        .environment(\.locale, Locale(identifier: CNC.fmt.loc))
    }
}

func cnCerrarTeclado() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}

extension View {
    /// Teclado como en las apps de Apple: se va al arrastrar la lista y trae
    /// su botón «Listo» encima.
    ///
    /// `conListo: false` para las pantallas que ya tienen su barra de escribir
    /// pegada al teclado —la charla—. Ahí el «Listo» es una franja de más
    /// entre lo que escribes y las teclas, y ninguna app de mensajes la trae:
    /// el teclado se baja tocando fuera o arrastrando la conversación, que es
    /// lo que la gente hace de todas formas.
    @ViewBuilder func cnTeclado(conListo: Bool = true) -> some View {
        if #available(iOS 16.0, *) {
            self.scrollDismissesKeyboard(.interactively)
                .modifier(CNBarraTeclado(puesta: conListo))
                .modifier(CNTocaYSeVa())
        } else {
            self.modifier(CNBarraTeclado(puesta: conListo)).modifier(CNTocaYSeVa())
        }
    }
}

/**
 * TOCAR EN UN HUECO BAJA EL TECLADO.
 *
 * Solo se iba arrastrando la lista o con el «Listo» de su barra, y nadie busca
 * un «Listo»: lo primero que hace cualquiera es tocar fuera del campo. Al no
 * pasar nada, el teclado se queda tapando media pantalla y parece que la app
 * se ha quedado colgada.
 *
 * `onTapGesture` y no `simultaneousGesture`: los toques que caen en algo —un
 * botón, el propio campo— los consume ese algo y aquí no llegan. Con el
 * simultáneo, tocar el campo para escribir cerraría el teclado que se acaba de
 * abrir.
 */
struct CNTocaYSeVa: ViewModifier {
    func body(content: Content) -> some View {
        content.onTapGesture { cnCerrarTeclado() }
    }
}

/// El botón «Listo» encima del teclado.
struct CNBarraTeclado: ViewModifier {
    /// `false` = sin barra ninguna. No vale poner la barra con el botón
    /// escondido dentro: la barra ocupa su alto igual y el teclado sigue
    /// empujando esos puntos de más.
    var puesta: Bool = true
    @ViewBuilder func body(content: Content) -> some View {
        if puesta {
            content
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button(cnT("Listo")) { cnCerrarTeclado() }.font(cnLetra(16, .semibold))
                    }
                }
        } else {
            content
        }
    }
}

/// ¿ESTÁ EL TECLADO EN PANTALLA?
///
/// Para pegarle la barra de escribir cuando sí. Con el teclado fuera, la barra
/// necesita su hueco por abajo —el del indicador de inicio—; con el teclado
/// puesto ese hueco lo pone el propio teclado, así que el mismo relleno se
/// convierte en una franja de nada entre lo que escribes y las teclas.
final class CNTecladoAbierto: ObservableObject {
    @Published var abierto = false
    private var vigilan: [NSObjectProtocol] = []
    init() {
        let c = NotificationCenter.default
        vigilan.append(c.addObserver(forName: UIResponder.keyboardWillShowNotification,
                                     object: nil, queue: .main) { [weak self] _ in
            self?.abierto = true
        })
        vigilan.append(c.addObserver(forName: UIResponder.keyboardWillHideNotification,
                                     object: nil, queue: .main) { [weak self] _ in
            self?.abierto = false
        })
    }
    deinit { vigilan.forEach { NotificationCenter.default.removeObserver($0) } }
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
    VStack(spacing: 0) { c() }.background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
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
    private var valor: Double { cnMonto(monto) }
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
                    // Por la regla, no por el campo a pelo: una categoría sin
                    // icono propio lleva el de su nombre, y sin color propio el
                    // gris apagado. Leyendo el campo salía lo que trajera el
                    // modelo, que no es lo mismo.
                    ficha(c.nombre,
                          cnColor(hexString: CNCategorias.color(c.nombre, en: datos.libreta)),
                          CNCategorias.icono(c.nombre, en: datos.libreta))
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
                Text(cnT(nombre)).font(cnLetra(14, .semibold))
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
    /// Lo que viene puesto: la cuota del préstamo o el aporte mensual de la
    /// meta. Así «Registrar cuota» es confirmar, no teclear. 0 = en blanco.
    var montoInicial: Double = 0
    @State private var monto = ""
    @State private var medio = "efectivo"
    /// Por qué no se pudo. Vacío mientras no haya nada que decir.
    @State private var porQueNo = ""

    private var titulo: String { cnT(tipo == "abono" ? "Registrar abono" : (tipo == "aporte" ? "Aportar a la meta" : "Pagar la tarjeta")) }
    private var cual: Int? { (extra["id"] as? Int) ?? (extra["id"] as? NSNumber)?.intValue }

    var body: some View {
        CNHoja(titulo: titulo, onClose: onClose, onGuardar: guardar) {
            CNMontoCampo(monto: $monto)
            if tipo != "pagoTarjeta" {
                cnGrupoHoja { CNMedioFila(datos: datos, medio: $medio) }
            }
            // EL PORQUÉ, CUANDO NO SE PUEDE.
            //
            // Sin esto la hoja se cerraba igual y no pasaba nada: ni cartel ni
            // movimiento. Así estuvo roto «abonar a un préstamo» sin que se
            // viera — la app decía que sí con el gesto y que no con los hechos.
            if !porQueNo.isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 15)).foregroundColor(CNC.neg)
                    Text(porQueNo).font(cnLetra(13.5)).foregroundColor(CNC.neg)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 2)
            }
        }
        .onAppear {
            if medio == "efectivo" { medio = cnMedioPorDefecto(datos.libreta) }
            // Como lo escribe el propio campo al tocar sus botones: entero si
            // es entero. Con el símbolo o con comas, `cnMonto` lo lee igual,
            // pero se ve raro en un campo donde la moneda va aparte.
            if monto.isEmpty, montoInicial > 0 {
                monto = montoInicial == montoInicial.rounded()
                    ? String(Int(montoInicial)) : String(format: "%.2f", montoInicial)
            }
        }
        // Al cambiar el monto o la cuenta se borra el cartel: sigue en pantalla
        // hablando de lo de antes y parece que no se puede arreglar.
        .onChange(of: monto) { _ in porQueNo = "" }
        .onChange(of: medio) { _ in porQueNo = "" }
    }

    private func guardar() {
        let n = cnMonto(monto)
        // El pago de tarjeta sin monto paga el saldo entero, que es lo que dice
        // el propio rótulo del campo: ahí un monto vacío no es un error.
        let cuanto = (tipo == "pagoTarjeta" && n <= 0)
            ? (datos.libreta.tarjetas.first { $0.id == cual }?.saldo ?? 0) : n
        if let mal = CNEscribir.porQueNo(datos.libreta, tipo, monto: cuanto,
                                         medio: tipo == "pagoTarjeta" ? "" : medio, id: cual) {
            porQueNo = mal
            return
        }
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
    /// Lo que ya se eligió en el catálogo: la clase y un nombre de partida.
    /// Así no hay que volver a decirlo aquí.
    var claseInicial: String = ""
    var nombreSugerido: String = ""
    /// Cómo se pregunta en ESTE tipo. Vienen del catálogo; vacío = no se
    /// pregunta. A una membresía de gimnasio no se le pide el «Banco», y al
    /// efectivo no se le pregunta dónde está: está en tu bolsillo.
    var rotuloDonde: String = "Banco (opcional)"
    var rotuloCuanto: String = "Saldo actual"
    @State private var nombre = ""
    @State private var banco = ""
    @State private var saldo = ""
    @State private var clase = "banco"
    @State private var color = CNPaleta.colores[0]
    private var clases: [(String, String, String)] { [("banco", cnT("Banco"), "banco"), ("efectivo", cnT("Efectivo"), "billete"), ("billetera", cnT("Billetera"), "telefono"), ("inversion", cnT("Inversión"), "grafico"), ("ahorro", cnT("Ahorro"), "hucha")] }

    var body: some View {
        CNHoja(titulo: cnT("Nueva cuenta"), guardarActivo: !nombre.trimmingCharacters(in: .whitespaces).isEmpty,
               onClose: onClose, onGuardar: guardar) {
            CNGrupoCampos(campos: [(cnT("Nombre (ej. Cuenta principal)"), $nombre, .default)]
                + (rotuloDonde.isEmpty ? [] : [(cnT(rotuloDonde), $banco, UIKeyboardType.default)]))
            VStack(alignment: .leading, spacing: 6) { cnHojaTitulo(cnT(rotuloCuanto)); CNMontoCampo(monto: $saldo, rotulo: nil) }
            // EL SELECTOR DE TIPO, SOLO SI NO LO DIJISTE YA. Viniendo del
            // catálogo ya elegiste qué es, y volver a enseñarlo no solo sobra:
            // deja cambiarlo, así que podías elegir «Membresía» y guardarla
            // como cuenta de banco sin enterarte.
            if claseInicial.isEmpty {
                VStack(alignment: .leading, spacing: 8) { cnHojaTitulo(cnT("Tipo")); CNFichas(opciones: clases, elegida: $clase) }
            }
            CNColorFila(color: $color)
        }
        // Lo que ya se dijo en el catálogo, puesto de partida.
        .onAppear {
            if !claseInicial.isEmpty, clases.contains(where: { $0.0 == claseInicial }) { clase = claseInicial }
            if nombre.isEmpty { nombre = cnT(nombreSugerido) }
        }
    }

    private func guardar() {
        let nm = nombre.trimmingCharacters(in: .whitespaces); guard !nm.isEmpty else { return }
        let ic = clases.first { $0.0 == clase }?.2 ?? "banco"
        datos.onGuardarHoja("cuenta", ["nombre": nm, "banco": banco, "saldo": cnMonto(saldo), "clase": clase, "icono": ic, "color": color], nil)
        onClose()
    }
}

// ── Nueva tarjeta ───────────────────────────────────────────────────────────
struct CNFormTarjeta: View {
    @ObservedObject var datos: CNDatos
    var onClose: () -> Void
    var nombreSugerido: String = ""
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
        .onAppear { if nombre.isEmpty { nombre = cnT(nombreSugerido) } }
    }

    private func guardar() {
        let nm = nombre.trimmingCharacters(in: .whitespaces); guard !nm.isEmpty else { return }
        datos.onGuardarHoja("tarjeta", ["nombre": nm, "banco": banco, "limite": cnMonto(limite), "saldo": cnMonto(saldo), "corte": Int(corte) ?? 20, "pago": Int(pago) ?? 5, "color": color], nil)
        onClose()
    }
}

// ── Nuevo préstamo o fiado ──────────────────────────────────────────────────
struct CNFormPrestamo: View {
    @ObservedObject var datos: CNDatos
    var onClose: () -> Void
    var sentidoInicial: String = ""
    var nombreSugerido: String = ""
    @State private var nombre = ""
    @State private var entidad = ""
    @State private var total = ""
    @State private var pagado = ""
    @State private var sentido = "debo"
    @State private var color = CNPaleta.colores[2]

    var body: some View {
        CNHoja(titulo: cnT("Nuevo préstamo"), guardarActivo: !nombre.trimmingCharacters(in: .whitespaces).isEmpty,
               onClose: onClose, onGuardar: guardar) {
            // Igual que el tipo de cuenta: viniendo del catálogo ya dijiste si
            // lo debes tú o te lo deben, y volver a preguntarlo deja cambiarlo
            // sin querer.
            if sentidoInicial.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    cnHojaTitulo(cnT("¿Cómo es?"))
                    CNFichas(opciones: [("debo", "Yo debo", "mano"), ("meDeben", "Me deben", "billete")], elegida: $sentido)
                }
            }
            CNGrupoCampos(campos: [(cnT("Nombre (ej. Préstamo del carro)"), $nombre, .default),
                                   (cnT("Entidad o persona (opcional)"), $entidad, .default)])
            VStack(alignment: .leading, spacing: 6) { cnHojaTitulo(cnT("Monto total")); CNMontoCampo(monto: $total, paso: 1000, rotulo: nil) }
            cnGrupoHoja {
                CNFilaMonto(icono: "checkmark.circle.fill", tinte: CNC.pos, titulo: cnT("Ya pagado"), monto: $pagado)
            }
            CNColorFila(color: $color)
        }
        .onAppear {
            if !sentidoInicial.isEmpty { sentido = sentidoInicial }
            if nombre.isEmpty { nombre = cnT(nombreSugerido) }
        }
    }

    private func guardar() {
        let nm = nombre.trimmingCharacters(in: .whitespaces); guard !nm.isEmpty else { return }
        datos.onGuardarHoja("prestamo", ["nombre": nm, "entidad": entidad, "total": cnMonto(total), "pagado": cnMonto(pagado), "sentido": sentido, "color": color], nil)
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
                            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(CNC.line, lineWidth: icono == ic ? 0 : 0.5))
                            .onTapGesture { UISelectionFeedbackGenerator().selectionChanged(); icono = ic }
                    } }.padding(.horizontal, 2).padding(.vertical, 2)
                }
            }
            CNColorFila(color: $color)
        }
    }

    private func guardar() {
        let nm = nombre.trimmingCharacters(in: .whitespaces); guard !nm.isEmpty else { return }
        datos.onGuardarHoja("meta", ["nombre": nm, "objetivo": cnMonto(objetivo), "mensual": cnMonto(mensual), "icono": icono, "color": color], nil)
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
        let n = cnMonto(monto)
        guard n > 0, !destino.isEmpty, destino != medio else { onClose(); return }
        datos.onGuardarHoja("transferencia", ["monto": n, "medio": medio, "destino": destino, "concepto": concepto], nil)
        onClose()
    }
}

// ── Chooser «Agregar» (cuenta / tarjeta / préstamo) ─────────────────────────
struct CNAgregar: View {
    @ObservedObject var datos: CNDatos
    var onClose: () -> Void
    @State private var elegido: CNTipoAgregar? = nil
    @State private var busca = ""

    var body: some View {
        if let t = elegido {
            switch t.forma {
            case "tarjeta": CNFormTarjeta(datos: datos, onClose: onClose, nombreSugerido: t.titulo)
            case "prestamo": CNFormPrestamo(datos: datos, onClose: onClose,
                                            sentidoInicial: t.sentido, nombreSugerido: t.titulo)
            default: CNFormCuenta(datos: datos, onClose: onClose,
                                  claseInicial: t.clase, nombreSugerido: t.titulo,
                                  rotuloDonde: t.donde, rotuloCuanto: t.cuanto)
            }
        } else {
            chooser
        }
    }

    /// Lo que encaja con lo que se está buscando. Se mira el nombre, la frase
    /// de debajo y unas palabras más que no se enseñan («PayPal», «USDT»…):
    /// la gente busca por la marca, no por cómo lo llamamos nosotros.
    private var encontrados: [CNTipoAgregar] {
        let q = busca.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return CNTipoAgregar.todos }
        return CNTipoAgregar.todos.filter {
            (cnT($0.titulo) + " " + cnT($0.sub) + " " + $0.busca).lowercased().contains(q)
        }
    }

    /// Sin atenuado ni esquinas propias: ya vamos DENTRO de una hoja del
    /// sistema, y ponerle otra encima se veía como dos hojas.
    /// EL CATÁLOGO, AGRUPADO POR LO QUE HACE CADA COSA.
    ///
    /// Antes eran tres filas con los nombres de dentro de la app —cuenta,
    /// tarjeta, préstamo—, que obligan a traducir: «una membresía del gimnasio,
    /// ¿eso qué es?». Agrupado por para qué sirve —gastar, invertir, deber,
    /// prestar, prepagado— no hay que traducir nada, y con el buscador da
    /// igual que sean dieciocho.
    private var chooser: some View {
        NavigationView {
            List {
                ForEach(CNTipoAgregar.grupos, id: \.id) { g in
                    let suyos = encontrados.filter { $0.grupo == g.id }
                    if !suyos.isEmpty {
                        Section {
                            ForEach(suyos) { t in fila(t) }
                        } header: {
                            cabeceraGrupo(g)
                        }
                    }
                }
                if encontrados.isEmpty {
                    Section {
                        Text(cnT("Nada con ese nombre"))
                            .font(cnLetra(15)).foregroundColor(CNC.pmut)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .modifier(CNFondoLista())
            .background(CNC.scr.ignoresSafeArea())
            .searchable(text: $busca,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: Text(cnT("Buscar: tarjeta, PayPal, cripto…")))
            .navigationTitle(cnT("¿Qué quieres agregar?"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(cnT("Cancelar")) { onClose() }
                }
            }
        }
        .navigationViewStyle(.stack)
        .tint(CNC.pos)
    }

    private func cabeceraGrupo(_ g: CNTipoAgregar.Grupo) -> some View {
        HStack(spacing: 7) {
            Circle().fill(g.color).frame(width: 7, height: 7)
            Text(cnT(g.titulo)).font(cnLetra(13, .semibold)).foregroundColor(CNC.ink)
            Text(cnT(g.pista)).font(cnLetra(12)).foregroundColor(CNC.pmut)
            Spacer(minLength: 0)
        }
        .textCase(nil)
    }

    private func fila(_ t: CNTipoAgregar) -> some View {
        let grupo = CNTipoAgregar.grupo(t.grupo)
        return Button { elegido = t } label: {
            HStack(spacing: 12) {
                cnGlifo(t.icono, tam: 18)
                    .foregroundColor(grupo.color)
                    .frame(width: 34, height: 34)
                    .background(grupo.color.opacity(0.13),
                                in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                VStack(alignment: .leading, spacing: 2) {
                    Text(cnT(t.titulo)).font(cnLetra(15.5, .semibold)).foregroundColor(CNC.ink)
                    Text(cnT(t.sub)).font(cnLetra(12)).foregroundColor(CNC.pmut)
                        .lineLimit(2).fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 6)
            }
            .padding(.vertical, 5).contentShape(Rectangle())
        }.buttonStyle(.plain)
    }
}

/// UNA COSA QUE SE PUEDE AGREGAR.
///
/// Por dentro la app solo sabe de tres: una CUENTA (con su clase), una TARJETA
/// y un PRÉSTAMO. Todo esto son esas tres con el nombre y el icono que le pone
/// la gente, no tres modelos nuevos: así el catálogo puede crecer sin tocar ni
/// los saldos ni los cálculos.
struct CNTipoAgregar: Identifiable {
    struct Grupo { var id: String; var titulo: String; var pista: String; var color: Color }

    var id: String
    var titulo: String
    var sub: String
    var icono: String
    var grupo: String
    /// «cuenta», «tarjeta» o «prestamo».
    var forma: String
    /// Para las cuentas: banco, efectivo, billetera, ahorro, inversion.
    var clase: String = ""
    /// Para los préstamos: «debo» o «medeben».
    var sentido: String = ""
    /// Palabras que NO se enseñan pero por las que se busca: la gente escribe
    /// la marca («PayPal», «USDT»), no nuestra palabra.
    var busca: String = ""
    /**
     * CÓMO SE LE PREGUNTA A ESTE, que no es igual para los dieciocho.
     *
     * El catálogo ofrece dieciocho cosas distintas y detrás había TRES
     * formularios, así que eligieras lo que eligieras te preguntaban lo mismo:
     * a una membresía de gimnasio le pedía el «Banco», a una tarjeta del metro
     * también, y encima enseñaba un selector de «Tipo» con el que podías
     * deshacer lo que acababas de elegir en el catálogo.
     *
     * `donde` vacío = esa pregunta no se hace. Al efectivo no se le pregunta
     * dónde está: está en tu bolsillo.
     */
    var donde: String = "Banco (opcional)"
    var cuanto: String = "Saldo actual"

    static let grupos: [Grupo] = [
        .init(id: "gastar", titulo: "Para gastar", pista: "débito", color: cnColor(0x2f9e5c)),
        .init(id: "invertir", titulo: "Ahorro e inversión", pista: "invierte", color: cnColor(0x3a66c8)),
        .init(id: "credito", titulo: "Tarjetas y crédito", pista: "crédito", color: cnColor(0xd55948)),
        .init(id: "deudas", titulo: "Préstamos y fiados", pista: "pedir prestado / prestar", color: cnColor(0xb08420)),
        .init(id: "prepago", titulo: "Prepago y membresías", pista: "cuenta de miembro", color: cnColor(0x7a4fd0))
    ]
    static func grupo(_ id: String) -> Grupo {
        grupos.first { $0.id == id } ?? grupos[0]
    }

    static let todos: [CNTipoAgregar] = [
        .init(id: "banco", titulo: "Cuenta de banco", sub: "Corriente o nómina, con tarjeta de débito",
              icono: "building.columns.fill", grupo: "gastar", forma: "cuenta", clase: "banco",
              busca: "nomina corriente debito banreservas popular bhd scotiabank"),
        .init(id: "efectivo", titulo: "Efectivo", sub: "Lo que cargas en la cartera",
              icono: "banknote.fill", grupo: "gastar", forma: "cuenta", clase: "efectivo",
              busca: "cash dinero cartera bolsillo", donde: "", cuanto: "Cuánto cargas"),
        .init(id: "billetera", titulo: "Billetera digital", sub: "PayPal, tPago, Qik…",
              icono: "wallet.pass.fill", grupo: "gastar", forma: "cuenta", clase: "billetera",
              busca: "paypal tpago qik wally azul app movil wallet", donde: "Servicio (ej. PayPal)"),

        .init(id: "ahorro", titulo: "Ahorro o certificado", sub: "Dinero guardado que no tocas",
              icono: "lock.fill", grupo: "invertir", forma: "cuenta", clase: "ahorro",
              busca: "certificado plazo fijo cdt ahorros", cuanto: "Cuánto tienes guardado"),
        .init(id: "acciones", titulo: "Acciones", sub: "En una casa de bolsa o app",
              icono: "chart.line.uptrend.xyaxis", grupo: "invertir", forma: "cuenta", clase: "inversion",
              busca: "bolsa broker etf stocks acciones", donde: "Casa de bolsa o app", cuanto: "Cuánto vale hoy"),
        .init(id: "fondo", titulo: "Fondo de inversión", sub: "Fondos mutuos o de pensión voluntaria",
              icono: "chart.bar.fill", grupo: "invertir", forma: "cuenta", clase: "inversion",
              busca: "mutuo pension afp fondo", donde: "Administradora (opcional)", cuanto: "Cuánto vale hoy"),
        .init(id: "cripto", titulo: "Criptomonedas", sub: "Bitcoin, USDT y otras",
              icono: "bitcoinsign.circle", grupo: "invertir", forma: "cuenta", clase: "inversion",
              busca: "bitcoin btc usdt ethereum binance cripto crypto", donde: "Dónde la tienes (ej. Binance)", cuanto: "Cuánto vale hoy"),
        .init(id: "inmueble", titulo: "Bienes raíces", sub: "Casa, solar o apartamento",
              icono: "house.fill", grupo: "invertir", forma: "cuenta", clase: "inversion",
              busca: "casa apartamento solar terreno inmueble propiedad", donde: "Dónde está (opcional)", cuanto: "Cuánto vale hoy"),
        .init(id: "metales", titulo: "Metales", sub: "Oro o plata",
              icono: "circle.hexagongrid.fill", grupo: "invertir", forma: "cuenta", clase: "inversion",
              busca: "oro plata metal lingote", donde: "Dónde lo guardas (opcional)", cuanto: "Cuánto vale hoy"),

        .init(id: "tarjeta", titulo: "Tarjeta de crédito", sub: "Con límite, día de corte y día de pago",
              icono: "creditcard.fill", grupo: "credito", forma: "tarjeta",
              busca: "visa mastercard amex credito limite corte"),
        .init(id: "linea", titulo: "Línea de crédito", sub: "Dinero del banco que usas y repones",
              icono: "arrow.left.arrow.right", grupo: "credito", forma: "tarjeta",
              busca: "linea sobregiro revolvente credito"),

        .init(id: "debo", titulo: "Yo debo", sub: "Préstamo del banco, del carro o de alguien",
              icono: "arrow.down.circle.fill", grupo: "deudas", forma: "prestamo", sentido: "debo",
              busca: "prestamo hipoteca carro vehiculo debo deuda fiado"),
        .init(id: "medeben", titulo: "Me deben", sub: "Lo que le prestaste a un amigo o familiar",
              icono: "arrow.up.circle.fill", grupo: "deudas", forma: "prestamo", sentido: "meDeben",
              busca: "me deben prestado fiado cobrar"),

        .init(id: "membresia", titulo: "Membresía", sub: "Gimnasio, club, supermercado",
              icono: "star.fill", grupo: "prepago", forma: "cuenta", clase: "billetera",
              busca: "gimnasio gym club socio supermercado puntos", donde: "Dónde es (ej. el gimnasio)", cuanto: "Saldo o puntos"),
        .init(id: "transporte", titulo: "Tarjeta de transporte", sub: "Metro, OMSA, peaje",
              icono: "tram.fill", grupo: "prepago", forma: "cuenta", clase: "billetera",
              busca: "metro omsa peaje paso rapido transporte", donde: "Operador (ej. Metro)", cuanto: "Saldo de la tarjeta"),
        .init(id: "escolar", titulo: "Tarjeta escolar", sub: "Comedor o cafetería",
              icono: "graduationcap.fill", grupo: "prepago", forma: "cuenta", clase: "billetera",
              busca: "colegio escuela comedor cafeteria", donde: "Centro (opcional)", cuanto: "Saldo de la tarjeta"),
        .init(id: "otra", titulo: "Otra con saldo", sub: "Cualquier tarjeta que recargas",
              icono: "tag.fill", grupo: "prepago", forma: "cuenta", clase: "billetera",
              busca: "regalo gift recarga saldo prepago", donde: "Dónde se usa (opcional)", cuanto: "Saldo de la tarjeta")
    ]
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
        // Barra del sistema, igual que los nueve formularios nativos: esta la
        // arma la web, pero se enseña dentro de la app y tiene que hablar el
        // mismo idioma.
        NavigationView {
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
                        // Con el estilo del sistema: relleno, y en rojo cuando
                        // lo que hace es destruir algo.
                        Button(role: m.destruye ? .destructive : nil) { datos.onHojaEnviar() } label: {
                            Text(m.boton).font(cnLetra(16, .semibold))
                                .frame(maxWidth: .infinity).padding(.vertical, 6)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(m.destruye ? .red : CNC.pos)
                        .controlSize(.large).clipShape(Capsule())
                        .padding(.top, 4)
                    }
                    Color.clear.frame(height: 24)
                }
                .padding(.horizontal, 16).padding(.top, 8)
            }
            .cnTeclado()
            .background(CNC.scr.ignoresSafeArea())
            .navigationTitle(m.titulo)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(cnT("Cancelar")) { onClose() }
                }
                // El botón de confirmar solo cuando la hoja es un «guardar sin
                // más»; lo que borra o manda un correo lleva su botón con
                // palabras dentro, que un ✓ no dice qué va a hacer.
                ToolbarItemGroup(placement: .confirmationAction) {
                    if m.conCheck {
                        Button { datos.onHojaEnviar() } label: {
                            Text(m.boton.isEmpty ? cnT("Guardar") : m.boton).font(cnLetra(17, .semibold))
                        }
                        .disabled(m.cargando)
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .tint(CNC.pos)
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
                            .fill(c.marcada ? CNC.pos : Color.clear)
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .stroke(c.marcada ? CNC.pos : CNC.line, lineWidth: 1.5)
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
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(CNC.line, lineWidth: 1))
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
                        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(CNC.line, lineWidth: 1))
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
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(CNC.line, lineWidth: 1))
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
                                    .overlay(RoundedRectangle(cornerRadius: 13, style: .continuous)
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

private struct CNAltoDelPeriodo: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = max(value, nextValue()) }
}

struct CNPeriodoHoja: View {
    @ObservedObject var datos: CNDatos
    var onClose: () -> Void
    /// Lo que mide lo que hay dentro. La hoja se queda de ese alto.
    @State private var alto: CGFloat = 0

    var body: some View {
        let p = datos.periodo ?? CNPeriodo()
        // LA HOJA MIDE LO QUE HAY DENTRO.
        //
        // Antes era `maxHeight: 0.86` de la pantalla, y un `List` dentro de un
        // `NavigationView` se come todo lo que le ofrezcan: siete opciones y
        // media pantalla de gris debajo. Una hoja de abajo se queda del alto de
        // su contenido —eso es lo que la distingue de una pantalla— y por eso
        // el sistema las hace así.
        //
        // El `List` no se puede medir: es perezoso y crece hasta llenar. Así
        // que las filas van a mano, con la misma cara que las de ajustes
        // —tarjeta blanca, raya metida y palomita—, y un `GeometryReader` dice
        // cuánto ocupan. El tope sigue estando por si el calendario viene
        // abierto con la letra muy grande.
        let tope = UIScreen.main.bounds.height * 0.82
        return NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    VStack(spacing: 0) {
                        ForEach(p.opciones.indices, id: \.self) { i in
                            let o = p.opciones[i]
                            Button { datos.onPeriodo("opcion", o.id) } label: {
                                HStack(spacing: 8) {
                                    Text(o.label).font(cnLetra(17)).foregroundColor(CNC.ink)
                                    Spacer(minLength: 8)
                                    if o.puesta {
                                        Image(systemName: "checkmark")
                                            .font(cnLetra(15, .semibold)).foregroundColor(CNC.pos)
                                    }
                                }
                                .padding(.horizontal, 16).padding(.vertical, 14)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            if i < p.opciones.count - 1 {
                                Divider().padding(.leading, 16)
                            }
                        }
                    }
                    .background(CNC.card, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    if !p.resumen.isEmpty {
                        HStack {
                            Text(p.resumen).font(cnLetra(13)).foregroundColor(CNC.pmut)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 16).padding(.top, -6)
                    }
                    if p.calendario {
                        calendario(p)
                            .padding(.horizontal, 12).padding(.vertical, 8)
                            .background(CNC.card, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
                .padding(.horizontal, 16).padding(.top, 12).padding(.bottom, cnMargenAbajo() + 10)
                .background(GeometryReader { g in
                    Color.clear.preference(key: CNAltoDelPeriodo.self, value: g.size.height)
                })
            }
            .onPreferenceChange(CNAltoDelPeriodo.self) { alto = $0 }
            .background(CNC.scr.ignoresSafeArea())
            .navigationTitle(cnT("Periodo"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button { onClose() } label: {
                        Text(cnT("Listo")).font(cnLetra(17, .semibold))
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        // El 56 es la barra del título, que va fuera de lo medido.
        .frame(height: min(max(alto + 56, 180), tope))
        .tint(CNC.pos)
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
                    .font(cnLetra(16, .semibold))
                    .frame(maxWidth: .infinity).padding(.vertical, 5)
            }
            .buttonStyle(.borderedProminent)
            .tint(CNC.pos)
            .controlSize(.large)
            .clipShape(Capsule())
            .disabled(!p.puedeAplicar)
        }
        .padding(.vertical, 4)
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
        Button(action: tap) { Image(systemName: ic).font(cnLetra(15, .semibold)) }
            .buttonStyle(.plain)
            .foregroundColor(CNC.pos)
            .frame(width: 40, height: 36)
            .contentShape(Rectangle())
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
            VStack(spacing: 0) {
                // EL TIRADOR. La hoja ya se arrastraba para cerrarse y no había
                // forma de saberlo: es la pastilla que lleva cualquier hoja del
                // sistema, y dice «esto se mueve» sin tener que explicarlo.
                Capsule().fill(CNC.ink.opacity(0.18))
                    .frame(width: 36, height: 5)
                    .padding(.top, 8)
                contenido()
            }
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
        /// Quién está dentro y con qué papel, para «Libretas y permisos».
        ///
        /// Viene por AQUÍ y no de la API, aunque el servidor también los tenga:
        /// los miembros viven DENTRO de la libreta y la web los cambia en local,
        /// y la sincronización los sube. Un segundo lector con su propio camino
        /// acabaría enseñando una cosa mientras la copia que se sincroniza dice
        /// otra, y quien manda es la que se sincroniza.
        var lid = ""; var tipo = ""; var rol = ""
        var esDueno = false; var compartida = false
        var miembros: [Miembro] = []
    }
    struct Miembro: Identifiable {
        var id: String { email.isEmpty ? nombre : email }
        var nombre = ""; var email = ""; var rol = ""; var rolId = ""
        /// Al dueño no se le cambia el papel ni se le quita, y a uno mismo
        /// tampoco: ese es el botón con el que alguien se saca de su propia
        /// libreta sin querer.
        var editable = false; var yo = false
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
                 cifra: s(f, "cifra"), cifraTinta: s(f, "cifraTinta"), pie: s(f, "pie"),
                 lid: s(f, "id"), tipo: s(f, "tipo"), rol: s(f, "rol"),
                 esDueno: (f["esDueno"] as? Bool) ?? false,
                 compartida: (f["compartida"] as? Bool) ?? false,
                 miembros: ((f["miembros"] as? [[String: Any]]) ?? []).map { m in
                     Miembro(nombre: s(m, "nombre"), email: s(m, "email"),
                             rol: s(m, "rol"), rolId: s(m, "rolId"),
                             editable: (m["editable"] as? Bool) ?? false,
                             yo: (m["yo"] as? Bool) ?? false)
                 })
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
        let altoMax = UIScreen.main.bounds.height * 0.72
        /*
         SIN `NavigationView`, Y POR ESO YA NO TAPA LA PANTALLA.

         Esto es una hoja que crece con lo que lleva dentro: con tres libretas
         debe ocupar un tercio. Pero llevaba un `NavigationView` —por su barra,
         con el título y los botones— y un `NavigationView` SIEMPRE se queda
         toda la altura que le dejen. Así que la hoja medía la pantalla entera y
         debajo de la última fila quedaba medio teléfono vacío.

         La barra se hace a mano, que son tres cosas en fila: la × para cerrar,
         el título y el + para crear. Y así, de paso, es la misma barra que
         llevan las otras hojas de la app.

         UNA × EN VEZ DE «CANCELAR». Esto no cancela nada: no has empezado a
         hacer nada que se pueda deshacer, solo estás mirando dónde anotas. Una
         × dice «cierro esto» sin prometer lo que no hay.
         */
        return VStack(spacing: 0) {
            HStack(spacing: 10) {
                Button { onClose() } label: {
                    Image(systemName: "xmark").font(cnLetra(15, .bold)).foregroundColor(CNC.ink)
                        .frame(width: 34, height: 34).background(CNC.soft, in: Circle())
                }.buttonStyle(CNPulsable()).accessibilityLabel(cnT("Cerrar"))
                Spacer(minLength: 6)
                Text(m.titulo).font(cnLetra(16, .heavy)).foregroundColor(CNC.ink).lineLimit(1)
                Spacer(minLength: 6)
                Button { datos.onLibreta("nueva", 0) } label: {
                    Image(systemName: "plus").font(cnLetra(16, .bold)).foregroundColor(CNC.ink)
                        .frame(width: 34, height: 34).background(CNC.soft, in: Circle())
                }.buttonStyle(CNPulsable()).accessibilityLabel(cnT("Nueva libreta"))
            }
            .padding(.horizontal, 16).padding(.top, 14).padding(.bottom, 10)
            // Con pocas libretas la hoja mide lo que mide su contenido; solo si
            // son muchas se convierte en una lista que rueda.
            if m.filas.count > 5 {
                ScrollView(showsIndicators: false) { cuerpo(m, puesta: puesta, otras: otras) }
                    .frame(maxHeight: altoMax)
            } else {
                cuerpo(m, puesta: puesta, otras: otras)
            }
        }
        .background(CNC.scr)
        .tint(CNC.pos)
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
                // UN GLIFO, NO UN CUADRO DE COLOR. Con el mismo tile que las
                // libretas, «Libretas y permisos» se leía como una libreta más
                // —y no lo es: es una puerta a otra pantalla—. Del tamaño de
                // una fila, pero sin el peso de una.
                Image(systemName: simbolo).font(cnLetra(16, .semibold))
                    .foregroundColor(tinte ?? CNC.pmut)
                    .frame(width: 42, height: 42)
                Text(texto).font(cnLetra(15.5, .semibold)).foregroundColor(CNC.ink).lineLimit(1)
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
                                .overlay(RoundedRectangle(cornerRadius: 13, style: .continuous).stroke(CNC.line, lineWidth: tipo == t.id ? 0 : 1))
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
                                    .overlay(RoundedRectangle(cornerRadius: 13, style: .continuous)
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
            .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(CNC.line, lineWidth: 1))
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
/// CHINO ESTÁ ESCRIBIENDO.
///
/// Eran unos puntos suspensivos quietos, y quieto no se lee como «está
/// pensando»: se lee como un mensaje vacío. Tres puntos que laten por turnos,
/// como en cualquier chat. Con «Reducir movimiento» puesto se quedan quietos,
/// que para eso está el ajuste.
struct CNLatido: View {
    @Environment(\.accessibilityReduceMotion) private var quieto
    @State private var late = false
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(CNC.pmut)
                    .frame(width: 6, height: 6)
                    .opacity(late ? 1 : 0.3)
                    .offset(y: late ? -3 : 0)
                    .animation(quieto ? nil : .easeInOut(duration: 0.6)
                        .repeatForever().delay(Double(i) * 0.18), value: late)
            }
        }
        .frame(height: 14)
        .onAppear { if !quieto { late = true } }
        .accessibilityLabel(Text("Chino está escribiendo"))
    }
}

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
            .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous).stroke(CNC.line, lineWidth: 1))
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
    struct Linea: Identifiable { var id: Int; var t = ""; var pie = ""; var icono = ""; var ia = false }
    struct Plan: Identifiable {
        var id: Int; var clave = ""; var nombre = ""; var para = ""
        var precio = ""; var cada = ""; var prefijo = ""
        var acento = ""; var tinta = ""; var banda = ""
        var items: [Linea] = []
        var puesto = false
        /// El que tiene puesto hoy, que no es lo mismo que el que está mirando.
        var actual = false
    }
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
                 precio: s(x, "precio"), cada: s(x, "cada"), prefijo: s(x, "prefijo"),
                 acento: s(x, "acento"), tinta: s(x, "tinta"), banda: s(x, "banda"),
                 items: ((x["items"] as? [[String: Any]]) ?? []).enumerated().map { k, it in
                     Linea(id: k, t: s(it, "t"), pie: s(it, "s"), icono: s(it, "icono"), ia: b(it, "ia"))
                 },
                 puesto: b(x, "puesto"), actual: b(x, "actual"))
        }
        return m
    }
}

/// Los campos de la puerta, para encadenar el cursor con la tecla de la
/// esquina del teclado en vez de tener que apuntar con el dedo.
enum CNPuertaCampo: Hashable { case quien, nombre, correo, clave, clave2, codigo }

/**
 * LO QUE ENTRA, ENTRA EN ORDEN.
 *
 * Todo aparecía de golpe, ya puesto. Escalonado —el dibujo, luego el rótulo,
 * luego el título, luego el texto— la pantalla se lee en el orden en que está
 * escrita, que es lo que hace que una bienvenida se sienta contada y no
 * volcada. Son fracciones de segundo: no se espera a nada, solo se ordena.
 *
 * Y sube quince puntos al entrar, no cae: lo que sube se lee como que llega;
 * lo que cae, como que se descuelga.
 */
struct CNEntraEnOrden: ViewModifier {
    var listo: Bool
    var orden: Double
    func body(content: Content) -> some View {
        content
            .opacity(listo ? 1 : 0)
            .offset(y: listo ? 0 : 15)
            .animation(.spring(response: 0.52, dampingFraction: 0.86).delay(0.04 + orden * 0.055),
                       value: listo)
    }
}

extension View {
    func cnEntra(_ listo: Bool, _ orden: Double) -> some View {
        modifier(CNEntraEnOrden(listo: listo, orden: orden))
    }
}

/**
 * LA PUERTA, COMO LA TENÍA LA WEB.
 *
 * Esto era un re-dibujo a ojo de las pantallas de bienvenida de la web, y
 * salía peor que el original: todo alineado a la izquierda sobre el gris de
 * fondo, la portada sin su verde ni la marca, los puntitos en vez de la barra
 * de progreso, las listas sin tarjeta, «Saltar» del mismo tamaño que
 * «Siguiente» y los botones con esquinas de formulario en vez de pastilla.
 *
 * La web ya lo tenía resuelto —y mejor—, así que esto se guía de ella:
 * `src/movil/plantilla.html`, los bloques `esPortada`, `esLamina`, `esAuth`,
 * `esNombre`, `esPlanSetup`, `esVerifica` y `esListo`. Mismas medidas, mismos
 * colores, mismo reparto: lo que cuenta la pantalla centrado en el hueco de en
 * medio, y las acciones abajo del todo.
 */
struct CNPuertaVista: View {
    @ObservedObject var datos: CNDatos
    var onAccion: (String, String) -> Void
    @State private var nombre = ""
    @State private var email = ""
    @State private var clave = ""
    @State private var clave2 = ""
    @State private var quien = ""
    @State private var codigo = ""
    @State private var verClave = false
    @State private var verClave2 = false
    /// Qué campo tiene el cursor. Permite encadenar: del correo al siguiente
    /// con la tecla de la esquina, sin tener que apuntar con el dedo.
    @FocusState private var foco: CNPuertaCampo?
    /// La entrada escalonada: se apaga al cambiar de paso y se enciende en el
    /// fotograma siguiente, así cada paso entra como el primero.
    @State private var entro = false
    /// Chino respirando en la portada.
    @State private var flota = false
    /// Con el teclado puesto se guarda lo secundario: en el acceso, Apple,
    /// Google y el cambio de modo se comen la pantalla justo cuando estás
    /// escribiendo.
    @StateObject private var teclado = CNTecladoAbierto()
    /// La hoja con las otras maneras de recibir el código de dos pasos.
    @State private var abiertoOtras = false

    /// La tinta de la web sobre el verde oscuro (`SOBRE_OSCURO`).
    private let sobreOscuro = cnColor(0xF7F2E4)

    var body: some View {
        let m = datos.puerta ?? CNPuerta()
        // Portada y «listo» van sobre el VERDE de la marca y con el texto
        // centrado: son las dos que dan la cara, la primera y la última. Las
        // demás, sobre el fondo de la app.
        let oscura = m.paso == "portada" || m.paso == "listo"
        // Acceso y plan llenan la pantalla: su contenido empieza arriba. Las
        // de contar algo se centran en el hueco, como en la web.
        let apretada = m.paso == "auth" || m.paso == "plan"
        // Y el paso en una sola cadena: es lo que dispara que todo vuelva a
        // entrar. Cambiar de lámina es cambiar de pantalla, aunque la lámina
        // sea «la misma vista con otro texto».
        let cual = m.paso + "/" + String(m.indice) + "/" + (m.registro ? "r" : "l") + (m.codigo ? "c" : "")
        return ZStack {
            fondo(oscura: oscura)
            VStack(spacing: 0) {
                if !oscura { cabecera(m) }
                GeometryReader { g in
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: oscura ? .center : .leading, spacing: 13) {
                            switch m.paso {
                            case "portada", "listo": laCara(m)
                            case "auth": acceso(m)
                            case "plan": planes(m)
                            default: contarUna(m)
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: g.size.height,
                               alignment: apretada ? .top : .center)
                        .padding(.horizontal, 24).padding(.vertical, 14)
                    }
                    .cnTeclado()
                }
                botonera(m, oscura: oscura)
            }
        }
        .onAppear {
            nombre = m.nombre; email = m.email; clave = m.clave; clave2 = m.clave2; quien = m.valor
            arranca(m)
        }
        // CADA PASO ENTRA COMO EL PRIMERO.
        //
        // Sin esto, pasar de lámina era cambiar el texto de sitio: la pantalla
        // ya estaba puesta y SwiftUI solo reemplazaba las palabras. Apagando y
        // encendiendo `entro` vuelve a correr la entrada escalonada, que es lo
        // que hace que se sienta que has AVANZADO y no que te han editado la
        // pantalla delante.
        .onChange(of: cual) { _ in
            entro = false
            DispatchQueue.main.async { arranca(m) }
        }
    }

    /// Arranca la entrada de un paso: lo escalonado y, donde toca, el cursor.
    private func arranca(_ m: CNPuerta) {
        entro = true
        if m.paso == "nombre" {
            // El nombre es UN campo y nada más: abrir el teclado solo ahorra un
            // toque a todo el mundo. En el acceso no, que ahí se mira primero.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { foco = .quien }
        }
        if m.paso == "auth" && m.codigo {
            // Al código se llega a escribirlo. Lo de dos pasos ya es un paso de
            // más; que encima haya que apuntar al campo con el dedo, no.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { foco = .codigo }
        }
    }

    /**
     * EL FONDO.
     *
     * En las dos de la marca —portada y «listo»— no es un verde plano: lleva
     * un halo por detrás de Chino y un oscurecido hacia abajo. Un color plano
     * a pantalla completa se ve barato en un teléfono; esto le da el mismo
     * cuerpo que tienen las pantallas de bienvenida del sistema, y de paso
     * separa a Chino del fondo sin ponerle un marco.
     */
    private func fondo(oscura: Bool) -> some View {
        ZStack {
            (oscura ? CNC.side : CNC.scr)
            if oscura {
                RadialGradient(colors: [Color.white.opacity(0.13), .clear],
                               center: UnitPoint(x: 0.5, y: 0.34),
                               startRadius: 8, endRadius: 330)
                LinearGradient(colors: [.clear, Color.black.opacity(0.18)],
                               startPoint: .center, endPoint: .bottom)
            }
        }
        .ignoresSafeArea()
    }

    // MARK: arriba

    /**
     * LA FLECHA Y LA BARRA DE PROGRESO.
     *
     * En la web el avance son barras que ocupan el ancho, una por lámina, al
     * lado de la flecha. Aquí eran tres puntitos sueltos abajo, pegados al
     * botón: no se leen como «vas por la segunda de tres».
     *
     * Y el hueco se reserva siempre, aunque no haya flecha: si la fila
     * aparece y desaparece, todo lo de debajo da un salto al cambiar de paso.
     */
    private func cabecera(_ m: CNPuerta) -> some View {
        HStack(spacing: 12) {
            if !m.volver.isEmpty {
                Button {
                    UISelectionFeedbackGenerator().selectionChanged()
                    onAccion(m.volver, "")
                } label: {
                    Image(systemName: "chevron.left").font(cnLetra(17, .bold))
                        .foregroundColor(CNC.ink).frame(width: 40, height: 40)
                        .background(CNC.soft, in: Circle())
                }.buttonStyle(CNPulsable())
            }
            if m.paso == "lamina" && m.total > 1 {
                HStack(spacing: 7) {
                    ForEach(0..<m.total, id: \.self) { i in
                        Capsule().fill(i <= m.indice ? CNC.pos : CNC.line)
                            .frame(maxWidth: .infinity).frame(height: 5)
                    }
                }
                // El tramo se PINTA al pasar de lámina, no aparece pintado:
                // así se ve que acabas de avanzar uno.
                .animation(.easeOut(duration: 0.3), value: m.indice)
            } else if m.paso == "auth" {
                // Entrar es el final del camino: la barra, entera.
                Capsule().fill(CNC.pos).frame(maxWidth: .infinity).frame(height: 5)
            } else {
                Spacer(minLength: 0)
            }
        }
        .frame(height: 40)
        .padding(.horizontal, 24).padding(.top, 10)
    }

    // MARK: las que dan la cara (portada y listo)

    private func laCara(_ m: CNPuerta) -> some View {
        VStack(spacing: 12) {
            if let img = cnImagenBase64(m.chinolo) {
                let lado: CGFloat = m.paso == "portada" ? 212 : 168
                // RESPIRANDO. Quieta, una ilustración grande en medio de la
                // pantalla se ve pegada; subiendo y bajando dos puntos cada dos
                // segundos y medio parece que está ahí contigo. Es el mismo
                // gesto que ya hace en la charla.
                Image(uiImage: img).resizable().scaledToFit().frame(width: lado, height: lado)
                    .offset(y: flota ? -5 : 5)
                    .animation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true), value: flota)
                    .onAppear { flota = true }
                    .cnEntra(entro, 0)
            }
            if m.paso == "portada" {
                // LA MARCA. El punto amarillo y el nombre, como en la web: es
                // la única pantalla donde la app se presenta.
                HStack(spacing: 9) {
                    Circle().fill(CNC.acc).frame(width: 22, height: 22)
                    Text("Chinola").font(cnLetra(19, .heavy)).foregroundColor(sobreOscuro)
                }
                .padding(.top, 6)
                .cnEntra(entro, 1)
            }
            Text(m.titulo).font(cnLetra(m.paso == "portada" ? 30 : 29, .heavy))
                .foregroundColor(sobreOscuro)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 2)
                .cnEntra(entro, 2)
            if !m.texto.isEmpty {
                Text(m.texto).font(cnLetra(14)).foregroundColor(sobreOscuro.opacity(0.72))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 300)
                    .cnEntra(entro, 3)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: las que cuentan algo (láminas, nombre, verifica)

    private func contarUna(_ m: CNPuerta) -> some View {
        VStack(alignment: .leading, spacing: 13) {
            if let img = cnImagenBase64(m.chinolo) {
                let lado: CGFloat = m.paso == "lamina" ? 148 : 132
                Image(uiImage: img).resizable().scaledToFit().frame(width: lado, height: lado)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 4)
                    .cnEntra(entro, 0)
            }
            if !m.rotulo.isEmpty { rotulo(m.rotulo).cnEntra(entro, 1) }
            Text(m.titulo).font(cnLetra(28, .heavy)).foregroundColor(CNC.ink)
                .fixedSize(horizontal: false, vertical: true)
                .cnEntra(entro, 2)
            if !m.texto.isEmpty {
                Text(m.texto).font(cnLetra(15)).foregroundColor(CNC.pmut)
                    .lineSpacing(3.5)
                    .fixedSize(horizontal: false, vertical: true)
                    .cnEntra(entro, 3)
            }
            if m.paso == "nombre" {
                campo("", m.ph, $quien, cual: .quien, siguiente: nil)
                    .onChange(of: quien) { v in onAccion("nombre", v) }
                    .padding(.top, 4)
                    .cnEntra(entro, 4)
            }
            if !m.lista.isEmpty {
                // Cada cosa en su TARJETA, como en la web. Sueltas sobre el
                // fondo se leían como un párrafo con dibujitos al lado.
                VStack(spacing: 9) {
                    ForEach(Array(m.lista.enumerated()), id: \.element.id) { k, p in
                        HStack(spacing: 13) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 13, style: .continuous)
                                    .fill(cnColor(hexString: p.fondo)).frame(width: 38, height: 38)
                                CNSVGShape(d: p.iconoPath)
                                    .stroke(cnColor(hexString: p.color),
                                            style: StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round))
                                    .frame(width: 20, height: 20)
                            }
                            VStack(alignment: .leading, spacing: 1) {
                                Text(p.titulo).font(cnLetra(15, .bold)).foregroundColor(CNC.ink)
                                Text(p.pie).font(cnLetra(12)).foregroundColor(CNC.pmut)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 14).padding(.vertical, 13)
                        .background(CNC.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(CNC.line, lineWidth: 1))
                        .cnEntra(entro, 4 + Double(k))
                    }
                }
                .padding(.top, 4)
            }
            if !m.error.isEmpty { aviso(m.error) }
        }
    }

    // MARK: entrar y crear cuenta

    private func acceso(_ m: CNPuerta) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if !m.rotulo.isEmpty { rotulo(m.rotulo).cnEntra(entro, 0) }
            Text(m.titulo).font(cnLetra(25, .heavy)).foregroundColor(CNC.ink)
                .fixedSize(horizontal: false, vertical: true)
                .cnEntra(entro, 1)
            if !m.texto.isEmpty {
                Text(m.texto).font(cnLetra(13)).foregroundColor(CNC.pmut)
                    .lineSpacing(2.5)
                    .fixedSize(horizontal: false, vertical: true)
                    .cnEntra(entro, 2)
            }
            if m.codigo {
                // EL CÓDIGO, Y NADA MÁS.
                //
                // Esta pantalla tiene UNA tarea: escribir seis cifras. Antes, al
                // lado del campo salían sueltas todas las demás maneras de
                // pedirlo —«mándalo al correo», «mándalo por Telegram», «usa la
                // app»— cada una en su pastilla. Con el teclado puesto, media
                // pantalla eran salidas y la otra media el sitio donde hay que
                // escribir. Ahora las salidas viven todas detrás de un solo
                // enlace, abajo.
                //
                // Y el campo es de código: grande, centrado, con las cifras
                // separadas, y marcado como `oneTimeCode` para que el teléfono
                // ofrezca pegarlo él solo en cuanto llegue el correo.
                campoCodigo(m)
                    .onChange(of: codigo) { v in onAccion("campo", "codigo|" + v) }
                    .cnEntra(entro, 3)
                if !m.respaldoNota.isEmpty {
                    Text(m.respaldoNota).font(cnLetra(12.5)).foregroundColor(CNC.pmut)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .cnEntra(entro, 4)
                }
            } else {
                if m.registro {
                    campo(m.labelNombre, m.labelNombre, $nombre, cual: .nombre, siguiente: .correo)
                        .onChange(of: nombre) { v in onAccion("campo", "nombre|" + v) }
                        .cnEntra(entro, 3)
                }
                campo(m.labelCorreo, m.phCorreo.isEmpty ? m.labelCorreo : m.phCorreo,
                      $email, teclado: .emailAddress, cual: .correo, siguiente: .clave)
                    .onChange(of: email) { v in onAccion("campo", "correo|" + v) }
                    .cnEntra(entro, 4)
                campo(m.labelClave, m.labelClave, $clave, oculto: $verClave,
                      cual: .clave, siguiente: m.registro ? .clave2 : nil)
                    .onChange(of: clave) { v in onAccion("campo", "clave|" + v) }
                    .cnEntra(entro, 5)
                if m.registro {
                    campo(m.labelClave2, m.phClave2.isEmpty ? m.labelClave2 : m.phClave2,
                          $clave2, oculto: $verClave2, cual: .clave2, siguiente: nil)
                        .onChange(of: clave2) { v in onAccion("campo", "clave2|" + v) }
                        .cnEntra(entro, 6)
                }
            }
            if !m.error.isEmpty {
                // El aviso NO entra escalonado: si acabas de darle a entrar y
                // el correo está mal, lo que dice por qué no puede llegar el
                // último ni hacerse esperar.
                aviso(m.error)
            }
            if !m.olvide.isEmpty && !m.codigo {
                // Subrayado y a la izquierda, como el enlace de la web. Antes
                // era un botón centrado del ancho entero: parecía una acción
                // más, y encima competía con la de entrar.
                Button { onAccion("olvide", "") } label: {
                    Text(m.olvide).font(cnLetra(13, .semibold)).foregroundColor(CNC.pmut)
                        .underline()
                }.buttonStyle(CNPulsable())
            }
        }
    }

    // MARK: el plan

    /**
     * EL PLAN: ELEGIR ARRIBA, LEER ABAJO.
     *
     * Eran tres tarjetones largos, uno debajo de otro, y para comparar había
     * que rodar media pantalla y acordarse. Ahora es una sola pantalla con tres
     * piezas, que es como lo resuelven las apps que viven de esto:
     *
     *  · arriba, TRES PASTILLAS con el nombre y el precio: se elige de un
     *    vistazo y se compara sin moverse;
     *  · debajo, UNA tarjeta con lo que lleva el elegido, línea por línea, cada
     *    una con su icono — una lista de once frases seguidas no se lee;
     *  · y el botón, fijo abajo, que nunca se va con el desplazamiento.
     *
     * Cada plan trae su propia paleta desde la web (verde, ámbar, lila): no es
     * decoración, es lo que hace que al tocar otro plan se note que has cambiado
     * de sitio sin leer una palabra.
     */
    private func planes(_ m: CNPuerta) -> some View {
        let elegido = m.planes.first(where: { $0.puesto }) ?? m.planes.first ?? CNPuerta.Plan(id: 0)
        return VStack(alignment: .leading, spacing: 14) {
            if !m.rotulo.isEmpty { rotulo(m.rotulo).cnEntra(entro, 0) }
            Text(m.titulo).font(cnLetra(27, .heavy)).foregroundColor(CNC.ink)
                .fixedSize(horizontal: false, vertical: true)
                .cnEntra(entro, 1)
            if !m.texto.isEmpty {
                Text(m.texto).font(cnLetra(14)).foregroundColor(CNC.pmut)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .cnEntra(entro, 2)
            }

            // ── las tres pastillas
            HStack(spacing: 9) {
                ForEach(m.planes) { p in pastillaDePlan(p) }
            }
            .padding(.top, 4)
            .cnEntra(entro, 3)

            // ── la tarjeta del elegido
            tarjetaDelPlan(elegido)
                .cnEntra(entro, 4)

            if !m.error.isEmpty { aviso(m.error) }
            if !m.pie.isEmpty {
                Text(m.pie).font(cnLetra(12)).foregroundColor(CNC.pmut)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 2)
                    .cnEntra(entro, 5)
            }
        }
    }

    /// Una de las tres de arriba. La elegida se tiñe de su color y se marca con
    /// un borde grueso; la que ya tiene puesta lleva su etiqueta flotando.
    private func pastillaDePlan(_ p: CNPuerta.Plan) -> some View {
        let acento = p.acento.isEmpty ? CNC.acc : cnColor(hexString: p.acento)
        let banda = p.banda.isEmpty ? CNC.soft : cnColor(hexString: p.banda)
        let tinta = p.tinta.isEmpty ? CNC.ink : cnColor(hexString: p.tinta)
        return Button {
            UISelectionFeedbackGenerator().selectionChanged()
            onAccion("plan-elegir", String(p.id))
        } label: {
            VStack(alignment: .leading, spacing: 2) {
                Text(p.nombre).font(cnLetra(14, .semibold))
                    .foregroundColor(p.puesto ? tinta : CNC.ink)
                Text(p.precio).font(cnLetra(21, .heavy)).monospacedDigit()
                    .foregroundColor(p.puesto ? tinta : CNC.ink)
                    .lineLimit(1).minimumScaleFactor(0.6)
                Text(p.cada).font(cnLetra(11))
                    .foregroundColor(p.puesto ? acento : CNC.pmut)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 10).padding(.top, 13).padding(.bottom, 12)
            .background(p.puesto ? banda : CNC.card,
                        in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(p.puesto ? acento : Color.clear, lineWidth: 2.5))
            .overlay(alignment: .topLeading) {
                // «El tuyo ahora», flotando sobre el borde: dentro se perdía
                // entre el nombre y el precio, que es justo lo que no puede
                // pasarle al dato que dice dónde estás.
                if p.actual {
                    Text(cnT("El tuyo ahora")).font(cnLetra(10, .heavy))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(CNC.pos, in: Capsule())
                        .offset(x: 8, y: -10)
                }
            }
        }
        .buttonStyle(CNPulsable())
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: p.puesto)
    }

    /// Lo que lleva el plan elegido, línea por línea.
    private func tarjetaDelPlan(_ p: CNPuerta.Plan) -> some View {
        let acento = p.acento.isEmpty ? CNC.acc : cnColor(hexString: p.acento)
        let banda = p.banda.isEmpty ? CNC.soft : cnColor(hexString: p.banda)
        let tinta = p.tinta.isEmpty ? CNC.ink : cnColor(hexString: p.tinta)
        return VStack(alignment: .leading, spacing: 0) {
            // la banda de arriba, del color del plan
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(p.para).font(cnLetra(13, .semibold)).foregroundColor(acento)
                    Spacer(minLength: 8)
                    if p.actual {
                        Text(cnT("Es el que tienes")).font(cnLetra(12, .semibold))
                            .foregroundColor(acento)
                            .padding(.horizontal, 10).padding(.vertical, 4)
                            .background(Color.white.opacity(0.75), in: Capsule())
                    }
                }
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(p.nombre).font(cnLetra(28, .heavy)).foregroundColor(tinta)
                    Spacer(minLength: 8)
                    Text(p.precio).font(cnLetra(30, .heavy)).monospacedDigit().foregroundColor(tinta)
                        .lineLimit(1).minimumScaleFactor(0.6)
                    Text(p.cada).font(cnLetra(14)).foregroundColor(acento)
                }
            }
            .padding(.horizontal, 18).padding(.top, 18).padding(.bottom, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(banda)

            if !p.prefijo.isEmpty {
                Text(p.prefijo).font(cnLetra(14, .semibold)).foregroundColor(CNC.pmut)
                    .padding(.horizontal, 18).padding(.top, 14).padding(.bottom, 2)
            }

            VStack(spacing: 0) {
                ForEach(p.items) { it in
                    lineaDePlan(it, acento: acento, banda: banda,
                                ultima: it.id == (p.items.last?.id ?? -1))
                }
            }
            .padding(.vertical, 6)
        }
        .background(CNC.card, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    /// Un renglón: su pastilla con el icono, lo que es, y el pie si lo lleva.
    /// Las de IA van en lila a propósito: son las que explican el precio.
    private func lineaDePlan(_ it: CNPuerta.Linea, acento: Color, banda: Color, ultima: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle().fill(it.ia ? cnColor(0xEEE9FF) : banda).frame(width: 30, height: 30)
                CNSVGShape(d: cnIconoDePlan(it.icono))
                    .stroke(it.ia ? cnColor(0x6A4FD6) : acento,
                            style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    .frame(width: 16, height: 16)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(it.t).font(cnLetra(16)).foregroundColor(CNC.ink)
                    .fixedSize(horizontal: false, vertical: true)
                if !it.pie.isEmpty {
                    Text(it.pie).font(cnLetra(13)).foregroundColor(CNC.pmut)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if !ultima {
                    Rectangle().fill(CNC.line).frame(height: 0.5).padding(.top, 10)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.leading, 16).padding(.trailing, 18)
        .padding(.vertical, 10)
    }

    // MARK: abajo
    // MARK: abajo

    /**
     * LAS ACCIONES, ABAJO Y FUERA DE LO QUE RUEDA.
     *
     * En la del plan el botón de seguir se iba con el desplazamiento: salía
     * cortado por el borde y había que rodar para encontrar la única acción de
     * la pantalla.
     *
     * Y una sola con fondo. Las salidas eran cajas del mismo tamaño que la
     * principal —«Saltar» pesaba lo mismo que «Siguiente»; en el acceso había
     * tres seguidas—, y una pantalla con tres botones iguales no dice por
     * dónde se sigue.
     */
    @ViewBuilder private func botonera(_ m: CNPuerta, oscura: Bool) -> some View {
        VStack(spacing: 10) {
            if !m.boton.isEmpty {
                botonGrande(m.boton, cargando: m.cargando, activo: activo(m)) { principal(m) }
            }
            // CON EL TECLADO PUESTO, LO DE AL LADO SE GUARDA.
            //
            // Apple, Google y «crear una cuenta» son tres cosas más debajo del
            // botón, y con el teclado abierto empujan la pantalla hasta dejar
            // el campo que estás escribiendo contra el borde de arriba. Son
            // para cuando MIRAS la pantalla, no para cuando escribes en ella.
            if m.paso == "auth" && !m.codigo && !teclado.abierto { entrarConOtros(m) }
            if m.paso == "auth" && m.codigo { otrasManeras(m) }
            if let otra = segunda(m) {
                botonTexto(otra.0, color: oscura ? sobreOscuro.opacity(0.75) : CNC.pmut,
                           borde: oscura) { onAccion(otra.1, "") }
            }
        }
        .animation(.easeInOut(duration: 0.22), value: teclado.abierto)
        .padding(.horizontal, 24).padding(.top, 12)
        .padding(.bottom, cnMargenAbajo() + 10)
        // LO QUE RUEDA SE DESVANECE AL LLEGAR AQUÍ.
        //
        // En la del plan la tercera tarjeta quedaba cortada en seco por el
        // borde del botón, como si la pantalla se hubiera roto ahí. Un
        // degradado del color del fondo por encima dice «esto sigue hacia
        // abajo» sin pintar una raya.
        .background(
            LinearGradient(colors: [CNC.scr.opacity(0), CNC.scr.opacity(oscura ? 0 : 1)],
                           startPoint: .top, endPoint: .bottom)
                .frame(height: 26).frame(maxHeight: .infinity, alignment: .top)
                .offset(y: -26)
                .allowsHitTesting(false),
            alignment: .top
        )
        .background(oscura ? Color.clear : CNC.scr)
        .cnEntra(entro, 6)
    }

    /// Entrar con Apple o con Google, y el cambio entre entrar y crear cuenta.
    /// Tal como los pone la web: los dos del mismo ancho, Apple en negro.
    @ViewBuilder private func entrarConOtros(_ m: CNPuerta) -> some View {
        if m.conApple || m.conGoogle {
            HStack(spacing: 12) {
                Rectangle().fill(CNC.line).frame(height: 1)
                Text(m.oDirecto.uppercased()).font(cnLetra(11, .heavy)).tracking(0.9)
                    .foregroundColor(CNC.pmut).fixedSize()
                Rectangle().fill(CNC.line).frame(height: 1)
            }
            HStack(spacing: 10) {
                if m.conGoogle {
                    Button { UISelectionFeedbackGenerator().selectionChanged(); onAccion("google", "") } label: {
                        HStack(spacing: 8) {
                            CNLogoGoogle().frame(width: 19, height: 19)
                            Text(m.google).font(cnLetra(15, .bold)).foregroundColor(CNC.ink)
                        }
                        .frame(maxWidth: .infinity).padding(.vertical, 13)
                        .background(CNC.card, in: Capsule())
                        .overlay(Capsule().stroke(CNC.line, lineWidth: 1))
                    }.buttonStyle(CNPulsable())
                }
                if m.conApple {
                    Button { UISelectionFeedbackGenerator().selectionChanged(); onAccion("apple", "") } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "apple.logo").font(cnLetra(17, .medium))
                            Text(m.apple).font(cnLetra(15, .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 13)
                        .background(cnColor(0x1A1A1A), in: Capsule())
                    }.buttonStyle(CNPulsable())
                }
            }
        }
        // «Ya tengo cuenta» / «Crear una cuenta»: una frase, no un botón.
        Button { onAccion("modo", m.registro ? "login" : "registro") } label: {
            Text(m.cambiar).font(cnLetra(13.5, .heavy)).foregroundColor(CNC.ink)
                .frame(maxWidth: .infinity).padding(.vertical, 6)
                .contentShape(Rectangle())
        }.buttonStyle(CNPulsable())
        if !m.sinCuenta.isEmpty {
            botonTexto(m.sinCuenta, color: CNC.pmut, borde: false) { onAccion("sin-cuenta", "") }
        }
    }

    /**
     * TODAS LAS MANERAS, DETRÁS DE UN SOLO ENLACE.
     *
     * Las otras formas de recibir el código salían sueltas en la pantalla, una
     * pastilla cada una, al lado del campo donde hay que escribir. Pero nadie
     * llega a esta pantalla queriendo cambiar de método: llega a escribir seis
     * cifras. Las salidas son para cuando algo no llega, y entonces lo que se
     * busca es «y si no, ¿qué?» — una sola puerta, y dentro todo lo que hay.
     *
     * Una hoja del sistema y no un menú escondido: las opciones salen con su
     * nombre entero y a tamaño de dedo, que es como el teléfono pregunta
     * «¿por dónde?».
     */
    @ViewBuilder private func otrasManeras(_ m: CNPuerta) -> some View {
        if !m.metodos.isEmpty {
            Button {
                UISelectionFeedbackGenerator().selectionChanged()
                abiertoOtras = true
            } label: {
                Text(cnT("Probar otro método")).font(cnLetra(15, .bold)).foregroundColor(CNC.pos)
                    .frame(maxWidth: .infinity).padding(.vertical, 11)
                    .contentShape(Rectangle())
            }
            .buttonStyle(CNPulsable())
            .confirmationDialog(m.otrosRotulo.isEmpty ? cnT("Probar otro método") : m.otrosRotulo,
                                isPresented: $abiertoOtras, titleVisibility: .visible) {
                ForEach(m.metodos) { x in
                    Button(x.label) {
                        UISelectionFeedbackGenerator().selectionChanged()
                        onAccion("metodo", String(x.id))
                    }
                }
                Button(cnT("Cancelar"), role: .cancel) { }
            }
        }
    }

    /// Qué hace el botón principal de cada paso.
    private func principal(_ m: CNPuerta) {
        switch m.paso {
        case "portada": onAccion("portada", "")
        case "lamina": onAccion("lamina", "")
        case "nombre": onAccion("nombre-seguir", "")
        case "verifica": onAccion("verifica-reenviar", "")
        case "auth": cnCerrarTeclado(); onAccion("entrar", "")
        case "plan": onAccion("plan-seguir", "")
        default: onAccion("listo", "")
        }
    }

    /// La salida de cada paso, si la tiene.
    private func segunda(_ m: CNPuerta) -> (String, String)? {
        if m.paso == "plan" { return m.salida.isEmpty ? nil : (m.salida, "plan-salir") }
        if m.paso == "auth" { return nil }
        guard !m.segundo.isEmpty else { return nil }
        switch m.paso {
        case "portada": return (m.segundo, "ya-tengo")
        case "lamina": return (m.segundo, "lamina-2")
        default: return (m.segundo, "verifica-volver")
        }
    }

    // MARK: piezas

    private func rotulo(_ t: String) -> some View {
        Text(t.uppercased()).font(cnLetra(11, .heavy)).tracking(1.1).foregroundColor(CNC.pmut)
    }

    /// Un campo como los de la web: su rótulo encima en versales y la caja con
    /// esquinas de 16. `oculto` lo convierte en contraseña, con su ojo.
    private func campo(_ label: String, _ ph: String, _ texto: Binding<String>,
                       teclado: UIKeyboardType = .default,
                       oculto: Binding<Bool>? = nil,
                       cual: CNPuertaCampo, siguiente: CNPuertaCampo?) -> some View {
        // EL BORDE DICE DÓNDE ESTÁS ESCRIBIENDO.
        //
        // Tres cajas iguales y ninguna pista de en cuál está el cursor: con el
        // teclado tapando media pantalla, eso se resuelve mirando dónde parpadea
        // una raya de un punto. El campo con el foco se tiñe del verde.
        let puesto = foco == cual
        return VStack(alignment: .leading, spacing: 5) {
            if !label.isEmpty {
                Text(label.uppercased()).font(cnLetra(11, .heavy)).tracking(0.9)
                    .foregroundColor(puesto ? CNC.pos : CNC.pmut)
            }
            HStack(spacing: 8) {
                Group {
                    if let o = oculto, !o.wrappedValue {
                        SecureField(ph, text: texto)
                    } else {
                        TextField(ph, text: texto)
                    }
                }
                .font(cnLetra(16)).foregroundColor(CNC.ink)
                .keyboardType(teclado)
                .textInputAutocapitalization(teclado == .emailAddress ? .never : .sentences)
                .disableAutocorrection(teclado != .default)
                .focused($foco, equals: cual)
                // LA TECLA DE LA ESQUINA ENCADENA. Del correo a la contraseña
                // sin volver a apuntar con el dedo, y en el último campo la
                // tecla dice «entrar» y entra.
                .submitLabel(siguiente == nil ? .go : .next)
                .onSubmit {
                    if let sig = siguiente { foco = sig } else { cnCerrarTeclado(); onAccion("entrar", "") }
                }
                if let o = oculto {
                    Button { o.wrappedValue.toggle() } label: {
                        Image(systemName: o.wrappedValue ? "eye.slash" : "eye")
                            .font(cnLetra(15)).foregroundColor(CNC.pmut)
                    }.buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14).padding(.vertical, 15)
            .background(CNC.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(puesto ? CNC.pos : CNC.line, lineWidth: puesto ? 1.8 : 1))
            .animation(.easeOut(duration: 0.16), value: puesto)
        }
    }

    /// El campo del código de dos pasos. Seis cifras, grandes y separadas, con
    /// el cursor puesto y el teléfono ofreciendo pegarlo en cuanto llegue.
    private func campoCodigo(_ m: CNPuerta) -> some View {
        let puesto = foco == .codigo
        return VStack(alignment: .leading, spacing: 6) {
            Text(m.labelCodigo.isEmpty ? cnT("Código") : m.labelCodigo)
                .font(cnLetra(11, .heavy)).tracking(0.9)
                .foregroundColor(puesto ? CNC.pos : CNC.pmut)
            // SIN `tracking` AQUÍ.
            //
            // Separar las cifras con `tracking` queda mejor, pero ese
            // modificador sobre un campo pide iOS 16 y la app llega más atrás:
            // el banco lo cazó —«'tracking' is only available in iOS 16.0 or
            // newer»— antes de que llegara a nadie. Lo que lo hace legible de
            // verdad es el tamaño y que esté centrado, no la separación.
            TextField("······", text: $codigo)
                .font(cnLetra(30, .heavy))
                .multilineTextAlignment(.center)
                .foregroundColor(CNC.ink)
                .keyboardType(.asciiCapable)
                .textContentType(.oneTimeCode)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .focused($foco, equals: .codigo)
                .submitLabel(.go)
                .onSubmit { cnCerrarTeclado(); onAccion("entrar", "") }
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(CNC.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(puesto ? CNC.pos : CNC.line, lineWidth: puesto ? 1.8 : 1))
                .animation(.easeOut(duration: 0.16), value: puesto)
        }
    }

    private func aviso(_ t: String) -> some View {
        Text(t).font(cnLetra(13)).foregroundColor(CNC.neg)
            .lineSpacing(2)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 14).padding(.vertical, 12)
            .background(CNC.neg.opacity(0.10), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
    }

    /// La acción principal: pastilla, como en la web. Mientras `cargando` da
    /// vueltas y no responde: dos toques no compran dos veces.
    private func botonGrande(_ t: String, cargando: Bool = false, activo: Bool = true,
                             _ go: @escaping () -> Void) -> some View {
        Button { UIImpactFeedbackGenerator(style: .medium).impactOccurred(); go() } label: {
            HStack(spacing: 8) {
                if cargando {
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: CNC.sobreAcc))
                }
                Text(t).font(cnLetra(16, .heavy)).foregroundColor(CNC.sobreAcc)
            }
            .frame(maxWidth: .infinity).padding(.vertical, 17)
            .background(CNC.acc, in: Capsule())
        }
        .buttonStyle(CNPulsable())
        .disabled(cargando || !activo)
        .opacity(cargando ? 0.75 : (activo ? 1 : 0.45))
        .animation(.easeOut(duration: 0.2), value: activo)
    }

    /// ¿Hay ya algo que mandar? Solo donde la respuesta es evidente sin
    /// preguntarle a nadie: el nombre. En el acceso el botón se deja vivo a
    /// propósito —un «falta el correo» dicho por la app ayuda más que un botón
    /// apagado que no explica por qué—.
    private func activo(_ m: CNPuerta) -> Bool {
        guard m.paso == "nombre" else { return true }
        return !quien.trimmingCharacters(in: .whitespaces).isEmpty
    }

    /// Las salidas, en texto. Sobre el verde de la portada llevan su marco
    /// claro, que es como las pone la web ahí: sin él no se ven.
    private func botonTexto(_ t: String, color: Color, borde: Bool,
                            _ go: @escaping () -> Void) -> some View {
        Button { UISelectionFeedbackGenerator().selectionChanged(); go() } label: {
            Text(t).font(cnLetra(15, .bold)).foregroundColor(borde ? sobreOscuro : color)
                .frame(maxWidth: .infinity).padding(.vertical, borde ? 16 : 12)
                .background(Color.white.opacity(borde ? 0.07 : 0), in: Capsule())
                .overlay(Capsule().stroke(Color.white.opacity(borde ? 0.28 : 0), lineWidth: 1))
                .contentShape(Rectangle())
        }.buttonStyle(CNPulsable())
    }
}

/// La G de Google, con sus cuatro colores. Es una marca: en un solo color o
/// como símbolo del sistema no es su logo, y se nota.
struct CNLogoGoogle: View {
    private static let trozos: [(String, UInt)] = [
        ("M24 9.5c3.5 0 6.6 1.2 9.1 3.6l6.8-6.8C35.6 2.4 30.2 0 24 0 14.6 0 6.5 5.4 2.6 13.2l7.9 6.2C12.4 13.7 17.7 9.5 24 9.5z", 0xEA4335),
        ("M46.98 24.55c0-1.6-.15-3.15-.42-4.64H24v9.02h12.94c-.56 2.9-2.2 5.36-4.7 7.02l7.6 5.9c4.44-4.1 7.14-10.15 7.14-17.3z", 0x4285F4),
        ("M10.49 28.6a14.5 14.5 0 0 1 0-9.2l-7.9-6.2a24 24 0 0 0 0 21.6l7.9-6.2z", 0xFBBC05),
        ("M24 48c6.2 0 11.5-2.05 15.32-5.58l-7.6-5.9c-2.1 1.42-4.8 2.28-7.72 2.28-6.3 0-11.6-4.2-13.5-9.9l-7.9 6.2C6.5 42.6 14.6 48 24 48z", 0x34A853)
    ]
    var body: some View {
        ZStack {
            ForEach(CNLogoGoogle.trozos.indices, id: \.self) { i in
                CNSVGShape(d: CNLogoGoogle.trozos[i].0, viewBox: 48)
                    .fill(cnColor(CNLogoGoogle.trozos[i].1))
            }
        }
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
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(CNC.line, lineWidth: 1))
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
                                    .overlay(RoundedRectangle(cornerRadius: 13, style: .continuous)
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
                                .overlay(RoundedRectangle(cornerRadius: 13, style: .continuous)
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
    struct Mensaje: Identifiable {
        var id: Int; var de = ""; var texto = ""; var error = false
        /// Quién contestó, ya escrito por la web («Apple Intelligence · sin
        /// salir del teléfono», «Tu IA · …»). Vacío en lo que escribe uno.
        var quien = ""
        /// Si es el primero de una tanda suya. Solo ese lleva la cara.
        var primeroDeChino = false
    }
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
        var antes = ""
        m.mensajes = ((r["mensajes"] as? [[String: Any]]) ?? []).map { j in
            let de = s(j, "de")
            defer { antes = de }
            return Mensaje(id: ((j["indice"] as? NSNumber)?.intValue) ?? 0, de: de,
                           texto: s(j, "texto"), error: b(j, "error"), quien: s(j, "quien"),
                           primeroDeChino: de != "yo" && antes != de)
        }
        return m
    }
}

/// El dictado: el reconocedor del sistema, en el idioma de la app.
/**
 * LA ONDA DE TU VOZ.
 *
 * Siete barras que suben con lo que se te oye, en el sitio donde iría el
 * texto. Es lo que convierte «hay un botón rojo» en «me está oyendo»: sin
 * ella, dictar es confiar y esperar, y cuando algo falla —el micrófono tapado,
 * la app colgada— no hay forma de saberlo hasta que no sale nada.
 *
 * Las de en medio suben más que las de los lados, que es como se dibuja una
 * voz y no un ecualizador. Y cada una lleva su retardo, para que la onda
 * RECORRA en vez de latir toda a la vez.
 */
struct CNOndaVoz: View {
    var nivel: Double
    private let pesos: [Double] = [0.45, 0.7, 0.9, 1, 0.9, 0.7, 0.45]
    var body: some View {
        HStack(spacing: 3) {
            ForEach(pesos.indices, id: \.self) { i in
                Capsule()
                    .fill(CNC.pos)
                    .frame(width: 3, height: 5 + CGFloat(max(0.06, nivel) * pesos[i]) * 22)
                    .animation(.easeOut(duration: 0.12).delay(Double(i) * 0.012), value: nivel)
            }
        }
        .frame(height: 30)
        .accessibilityHidden(true)
    }
}

final class CNDictado: ObservableObject {
    @Published var texto = ""
    @Published var grabando = false
    /// Por qué no se pudo dictar. Vacío cuando no hay nada que decir.
    @Published var pega = ""
    /**
     * CUÁNTO SE TE OYE, de 0 a 1.
     *
     * Es lo que más cambia la sensación y lo más barato: los búferes de audio
     * ya pasan por aquí para transcribirse, así que medirlos no cuesta nada.
     * Sin esto, dictar es mirar un botón rojo y confiar; con esto se ve que te
     * está oyendo, y se nota al instante si el micrófono está tapado o si la
     * app se quedó colgada.
     */
    @Published var nivel: Double = 0
    /// Cuándo se te oyó por última vez, para parar solo al callarte.
    private var ultimoSonido = Date()
    private var vigilante: Timer?
    private let motor = AVAudioEngine()
    private var tarea: SFSpeechRecognitionTask?
    private var peticion: SFSpeechAudioBufferRecognitionRequest?
    /**
     * CADA GRABACIÓN LLEVA SU NÚMERO.
     *
     * El reconocedor sigue contestando un rato DESPUÉS de parar, y esa
     * respuesta tardía volvía a escribir en el cuadro el mensaje que acababas
     * de mandar: lo dictabas, se enviaba, y el texto reaparecía solo. De ahí
     * también el mandarlo dos veces —el texto volvía, y lo mandabas otra vez
     * creyendo que no había salido—.
     *
     * Lo que llegue de una grabación que ya no es la de ahora, se tira.
     */
    private var vuelta = 0
    /// Entre el toque y el permiso pasa un momento. Sin esto, dos toques
    /// seguidos arrancaban DOS grabaciones sobre el mismo micrófono.
    private var arrancando = false
    /// Soltaste antes de que llegara a arrancar: en cuanto arranque, se para.
    private var pararAlArrancar = false

    func alternar() { if grabando { parar() } else { empezar() } }

    /**
     * SOLTASTE EL DEDO.
     *
     * Entre apretar y empezar a grabar hay un momento —el permiso, encender el
     * micrófono— y en un gesto de mantener pulsado es muy fácil soltar dentro
     * de ese hueco. Si solo se llamara a `parar()`, no habría nada que parar y
     * la grabación arrancaría DESPUÉS de haber soltado, sola y sin que nadie
     * la vigile.
     *
     * Así que si todavía está arrancando, se apunta para pararla en cuanto
     * arranque.
     */
    func suelta() {
        if grabando { parar() } else if arrancando { pararAlArrancar = true }
    }

    /// Soltar cancelando: ni se manda ni se queda escrito.
    func cancelar() {
        texto = ""
        suelta()
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    func empezar() {
        guard !grabando, !arrancando else { return }
        arrancando = true
        pararAlArrancar = false
        pega = ""
        SFSpeechRecognizer.requestAuthorization { estado in
            DispatchQueue.main.async {
                guard estado == .authorized else {
                    self.arrancando = false
                    self.pega = cnT("Hace falta tu permiso para dictar.")
                    return
                }
                AVAudioSession.sharedInstance().requestRecordPermission { ok in
                    DispatchQueue.main.async {
                        guard ok else {
                            self.arrancando = false
                            self.pega = cnT("Hace falta tu permiso para usar el micrófono.")
                            return
                        }
                        self.arranca()
                    }
                }
            }
        }
    }
    private func arranca() {
        arrancando = false
        guard let rec = SFSpeechRecognizer(locale: Locale(identifier: CNC.fmt.loc)) ?? SFSpeechRecognizer(),
              rec.isAvailable else {
            pega = cnT("El dictado no está disponible ahora mismo.")
            return
        }
        let sesion = AVAudioSession.sharedInstance()
        // ESTOS DOS ERRORES SE TRAGABAN, Y AHÍ EMPEZABA EL CIERRE.
        //
        // Con el micrófono cogido por otra app —una llamada, una nota de voz,
        // el navegador—, poner la sesión en modo grabación FALLA. Con `try?`
        // no se enteraba nadie y se seguía adelante.
        do {
            try sesion.setCategory(.record, mode: .measurement, options: .duckOthers)
            try sesion.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            pega = cnT("El micrófono lo está usando otra app. Ciérrala y vuelve a intentarlo.")
            return
        }
        let entrada = motor.inputNode
        let formato = entrada.outputFormat(forBus: 0)
        // Y AQUÍ SE CERRABA LA APP, no «fallaba»: se cerraba.
        //
        // Sin micrófono disponible, el formato de entrada vuelve a cero —cero
        // hercios, cero canales— e `installTap` con eso no devuelve un error:
        // lanza una excepción de las que no se pueden coger en Swift y mata el
        // proceso. Por eso se cerraba de golpe en vez de no hacer nada.
        guard formato.sampleRate > 0, formato.channelCount > 0 else {
            pega = cnT("El micrófono lo está usando otra app. Ciérrala y vuelve a intentarlo.")
            try? sesion.setActive(false, options: .notifyOthersOnDeactivation)
            return
        }
        let p = SFSpeechAudioBufferRecognitionRequest()
        p.shouldReportPartialResults = true
        // PUNTOS Y COMAS. Sin esto sale un chorro de palabras sin respirar, y
        // es la diferencia entre «parece dictado» y «parece escrito». Es de
        // iOS 16; debajo se queda como estaba.
        if #available(iOS 16.0, *) { p.addsPunctuation = true }
        peticion = p
        entrada.removeTap(onBus: 0)
        entrada.installTap(onBus: 0, bufferSize: 1024, format: formato) { [weak self] buffer, _ in
            p.append(buffer)
            // El nivel, del mismo búfer que ya va a transcribirse: la media de
            // los cuadrados, que es como se mide el volumen de verdad.
            guard let datos = buffer.floatChannelData?[0] else { return }
            let n = Int(buffer.frameLength)
            guard n > 0 else { return }
            var suma: Float = 0
            for k in 0..<n { suma += datos[k] * datos[k] }
            let rms = Double((suma / Float(n)).squareRoot())
            // De la escala del sonido a la de la vista: en decibelios, porque
            // el oído va así y de otro modo la onda casi no se movería.
            let db = 20 * log10(max(rms, 0.000_001))
            let v = max(0, min(1, (db + 50) / 50))
            DispatchQueue.main.async {
                guard let s = self, s.grabando else { return }
                s.nivel = v
                if v > 0.12 { s.ultimoSonido = Date() }
            }
        }
        motor.prepare()
        do { try motor.start() } catch {
            // Recoger lo puesto: un grifo abierto sobre un motor parado deja
            // el micrófono cogido para la próxima vez.
            entrada.removeTap(onBus: 0)
            peticion = nil
            try? sesion.setActive(false, options: .notifyOthersOnDeactivation)
            pega = cnT("No se pudo encender el micrófono.")
            return
        }
        vuelta += 1
        let mia = vuelta
        grabando = true
        ultimoSonido = Date()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        // SE PARA SOLA AL CALLARTE.
        //
        // Antes había que acordarse de volver a tocar el botón, y mientras
        // tanto seguía grabando el silencio —y la app seguía sin soltar el
        // micrófono—. Dos segundos sin oírte es haber terminado de hablar.
        vigilante?.invalidate()
        vigilante = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] t in
            DispatchQueue.main.async {
                guard let s = self, s.grabando, s.vuelta == mia else { t.invalidate(); return }
                if Date().timeIntervalSince(s.ultimoSonido) > 2.0 { s.parar() }
            }
        }
        tarea = rec.recognitionTask(with: p) { [weak self] res, err in
            DispatchQueue.main.async {
                guard let s = self, s.vuelta == mia else { return }
                if let r = res { s.texto = r.bestTranscription.formattedString }
                if err != nil || (res?.isFinal ?? false) { s.parar() }
            }
        }
        // Y si soltaste mientras esto arrancaba, se para ya.
        if pararAlArrancar { pararAlArrancar = false; parar() }
    }
    func parar() {
        guard grabando else { return }
        // El número sube ANTES de soltar nada: lo que conteste el reconocedor a
        // partir de aquí ya no es de esta grabación y no entra.
        vuelta += 1
        vigilante?.invalidate(); vigilante = nil
        nivel = 0
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
    /// Para pegar la barra de escribir al teclado cuando está puesto.
    @StateObject private var teclado = CNTecladoAbierto()
    /// La hoja con las otras maneras de recibir el código de dos pasos.
    @State private var abiertoOtras = false
    @State private var flota = false
    /// Grabando con el dedo encima (sin fijar). Mientras dure, se puede
    /// cancelar deslizando y fijar subiendo.
    @State private var conElDedo = false
    /// Fijado: sigue grabando con las manos libres, como en WhatsApp.
    @State private var fijado = false
    /// Pasado el punto de no retorno hacia la izquierda: al soltar, se cancela.
    @State private var cancelando = false
    /// Cuánto se ha llevado el dedo, para que el micrófono lo acompañe.
    @State private var llevaElDedo: CGSize = .zero

    /// ¿Hay algo que mandar? Decide si sale el botón de enviar, y la animación
    /// con la que sale. En un solo sitio para que no se separen.
    private var puedeMandar: Bool {
        !texto.trimmingCharacters(in: .whitespaces).isEmpty && !(datos.charla?.pensando ?? false)
    }

    var body: some View {
        let m = datos.charla ?? CNCharla()
        // Barra del sistema, la última que quedaba con la cabecera a mano.
        return NavigationView {
            VStack(spacing: 0) {
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
                            VStack(alignment: x.de == "yo" ? .trailing : .leading, spacing: 3) {
                                HStack(alignment: .bottom, spacing: 8) {
                                    if x.de == "yo" { Spacer(minLength: 50) }
                                    // EL PERSONAJE AL LADO DE LO QUE DICE.
                                    //
                                    // Como en cualquier chat: quien habla se
                                    // ve. Va pegado abajo y solo en el PRIMER
                                    // mensaje de una tanda suya — repetirlo en
                                    // cada burbuja de la misma respuesta llena
                                    // la columna de caras y cansa.
                                    if x.de != "yo" {
                                        if x.primeroDeChino, let img = cnImagenBase64(m.chinolo) {
                                            Image(uiImage: img).resizable().scaledToFit()
                                                .frame(width: 28, height: 28)
                                        } else {
                                            // El hueco se respeta igual, o las
                                            // burbujas de abajo se desalinean.
                                            Color.clear.frame(width: 28, height: 28)
                                        }
                                    }
                                    Text(x.texto).font(cnLetra(15))
                                        .foregroundColor(x.de == "yo" ? CNC.sobreAcc : (x.error ? CNC.neg : CNC.ink))
                                        .fixedSize(horizontal: false, vertical: true)
                                        .padding(.horizontal, 14).padding(.vertical, 10)
                                        .background(x.de == "yo" ? CNC.acc : (x.error ? CNC.neg.opacity(0.10) : CNC.card),
                                                    in: CNBurbuja(mia: x.de == "yo"))
                                    if x.de != "yo" { Spacer(minLength: 50) }
                                }
                                // QUIÉN CONTESTÓ, DEBAJO DE SU RESPUESTA.
                                //
                                // Hay tres caminos —la de Apple aquí dentro, la
                                // tuya con tu clave, la de Chinola— y se salta
                                // solo de uno a otro cuando alguno falla. Sin
                                // esto, configuras la tuya y no hay manera de
                                // saber si se está usando o si todo sigue
                                // saliendo por la de siempre.
                                if !x.quien.isEmpty {
                                    Text(x.quien).font(cnLetra(11)).foregroundColor(CNC.pmut)
                                        // 36 = la cara (28) más su hueco (8),
                                        // para que la firma caiga bajo la
                                        // burbuja y no bajo el personaje.
                                        .padding(.leading, x.de == "yo" ? 4 : 40).padding(.trailing, 4)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: x.de == "yo" ? .trailing : .leading)
                            .id(x.id)
                        }
                        if m.pensando {
                            HStack {
                                CNLatido()
                                    .padding(.horizontal, 14).padding(.vertical, 12)
                                    .background(CNC.card, in: CNBurbuja(mia: false))
                                Spacer(minLength: 50)
                            }
                            .id(-1)
                        }
                        // «Empezar de nuevo» NO va aquí. Estaba al final de la
                        // conversación, flotando entre la última respuesta y la
                        // caja de escribir, y ahí parece parte de la charla:
                        // Chino acaba de contestarte y debajo hay un botón que
                        // borra lo que acaba de decirte. Vive en los tres
                        // puntos de arriba, que es donde se buscan las cosas
                        // que se hacen una vez.
                        Color.clear.frame(height: 6).id("fin")
                    }
                    .padding(.horizontal, 16).padding(.top, 6)
                }
                .onChange(of: m.mensajes.count) { _ in withAnimation { lector.scrollTo("fin", anchor: .bottom) } }
                .onChange(of: m.pensando) { _ in withAnimation { lector.scrollTo("fin", anchor: .bottom) } }
            }
            /*
             LA CAJA DE ESCRIBIR, COMO LA DE MENSAJES.

             Eran TRES BULTOS EN FILA: un círculo gris de 46 con el micrófono,
             un campo con su borde y otro círculo de 46 con la flecha. Tres
             cosas del mismo tamaño peleándose, y el campo —que es lo único que
             se usa— con el mismo peso visual que los botones. Eso es lo que se
             ve «de formulario»: en el teléfono, escribir es UN sitio, no tres.

             Ahora es una sola cápsula y dentro va todo: el micrófono a la
             izquierda en gris y sin plato —un glifo, no un botón—, el texto, y
             la flecha SOLO CUANDO HAY ALGO QUE MANDAR. Un botón de enviar
             apagado ocupando sitio es un botón que no hace nada; apareciendo
             al escribir, además, dice que ya se puede.

             Y la raya de arriba: separa lo escrito de lo que se escribe, que
             es lo que hace que el texto parezca pasar por debajo.
             */
            // POR QUÉ NO SE PUDO DICTAR.
            //
            // Antes esto no existía: con el micrófono cogido por otra app, la
            // app se CERRABA. Arreglado el cierre, lo que quedaba era un botón
            // que no hacía nada, que es la otra forma de no contar lo que pasa.
            if !dictado.pega.isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(cnLetra(14)).foregroundColor(CNC.neg)
                    Text(dictado.pega).font(cnLetra(13)).foregroundColor(CNC.neg)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 18).padding(.top, 8)
            }
            HStack(alignment: .bottom, spacing: 6) {
                if dictado.grabando {
                    // Mientras hablas, la onda ocupa el sitio del texto: lo que
                    // importa en ese momento es que te está oyendo, no leer a
                    // medias lo que todavía estás diciendo.
                    //
                    // Y debajo, LO QUE PUEDES HACER AHORA MISMO. Un gesto que
                    // no se cuenta no existe: nadie desliza un botón a ver qué
                    // pasa. Se dice mientras lo tienes cogido, y cambia al
                    // pasarte de la raya para que se vea que ya estás en
                    // «cancelar» antes de soltar.
                    HStack(spacing: 10) {
                        CNOndaVoz(nivel: dictado.nivel)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(cancelando ? cnT("Suelta para cancelar")
                                 : (texto.isEmpty ? cnT("Te escucho…") : texto))
                                .font(cnLetra(15))
                                .foregroundColor(cancelando ? CNC.neg : (texto.isEmpty ? CNC.pmut : CNC.ink))
                                .lineLimit(2)
                            if conElDedo && !cancelando {
                                Text(cnT("◀ desliza para cancelar · ▲ para fijar"))
                                    .font(cnLetra(10.5)).foregroundColor(CNC.pmut.opacity(0.8))
                                    .lineLimit(1).minimumScaleFactor(0.8)
                            } else if fijado {
                                Text(cnT("Toca el botón para terminar"))
                                    .font(cnLetra(10.5)).foregroundColor(CNC.pmut.opacity(0.8))
                                    .lineLimit(1)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.leading, 10).padding(.vertical, 6)
                    .transition(.opacity)
                } else {
                    Group {
                        if #available(iOS 16.0, *) {
                            TextField(m.ph, text: $texto, axis: .vertical).lineLimit(1...5)
                        } else {
                            TextField(m.ph, text: $texto)
                        }
                    }
                    .font(cnLetra(16)).foregroundColor(CNC.ink)
                    .padding(.leading, 12).padding(.vertical, 8)
                    .onSubmit { mandar() }
                }
                /*
                 UN SOLO BOTÓN, Y A LA DERECHA.

                 El micrófono estaba a la IZQUIERDA, que es donde ninguna app de
                 mensajes lo pone —ahí va el «+» de adjuntar— y donde peor cae
                 el pulgar: cruzando la pantalla entera para mantenerlo pulsado
                 mientras hablas.

                 Y no son dos botones, es UNO QUE CAMBIA. Vacío es el
                 micrófono; en cuanto escribes algo se vuelve la flecha de
                 enviar. Es lo que hacen Mensajes y WhatsApp, y evita tener dos
                 cosas a la vez donde solo una sirve.

                 MANTENER PULSADO PARA HABLAR. Era un interruptor: tocar para
                 empezar, tocar para parar. Eso obliga a acordarse de volver, y
                 si te distraes el micrófono se queda abierto. Manteniendo, la
                 grabación dura exactamente lo que dura el dedo.

                 Con las dos salidas que la gente ya conoce: DESLIZAR A LA
                 IZQUIERDA para tirarlo —porque te arrepientes a mitad de frase,
                 y soltar sin más lo mandaría— y DESLIZAR ARRIBA para fijarlo y
                 seguir con las manos libres. Fijado vuelve a ser un botón.

                 Ni `Button` ni `onLongPressGesture`: los dos se quedan el dedo
                 mientras deciden qué fue aquello, y hasta que no sueltan el
                 arrastre no ve nada. Es el mismo fallo que tuvo el botón
                 flotante. Con el arrastre desde cero, el dedo manda desde el
                 primer punto.
                 */
                if puedeMandar {
                    Button { mandar() } label: {
                        Image(systemName: "arrow.up").font(cnLetra(15, .bold))
                            .foregroundColor(CNC.sobreAcc)
                            .frame(width: 32, height: 32).background(CNC.acc, in: Circle())
                    }
                    .buttonStyle(CNPulsable())
                    .transition(.scale(scale: 0.5).combined(with: .opacity))
                    .accessibilityLabel(cnT("Enviar"))
                } else {
                    Image(systemName: fijado ? "stop.circle.fill" : "mic.fill")
                        .font(cnLetra(17, .semibold))
                        .foregroundColor(cancelando ? CNC.neg
                            : (dictado.grabando ? CNC.pos : CNC.pmut))
                        .frame(width: 32, height: 32)
                        .scaleEffect(dictado.grabando && !fijado ? 1.3 : 1)
                        .offset(x: conElDedo ? max(-70, llevaElDedo.width) : 0)
                        .contentShape(Rectangle())
                        .animation(.spring(response: 0.22, dampingFraction: 0.7), value: dictado.grabando)
                        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: cancelando)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { v in
                                    guard !fijado else { return }
                                    if !conElDedo {
                                        conElDedo = true
                                        cancelando = false
                                        dictado.empezar()
                                    }
                                    llevaElDedo = v.translation
                                    // Arriba se mira PRIMERO: subir en diagonal
                                    // es lo normal, y al revés fijar acabaría
                                    // cancelando la mitad de las veces.
                                    if v.translation.height < -60 {
                                        fijado = true
                                        conElDedo = false
                                        llevaElDedo = .zero
                                        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                                        return
                                    }
                                    let tira = v.translation.width < -70
                                    if tira != cancelando {
                                        cancelando = tira
                                        UISelectionFeedbackGenerator().selectionChanged()
                                    }
                                }
                                .onEnded { _ in
                                    if fijado {
                                        fijado = false
                                        dictado.suelta()
                                        return
                                    }
                                    conElDedo = false
                                    llevaElDedo = .zero
                                    if cancelando {
                                        cancelando = false
                                        texto = ""          // antes de parar, o se manda
                                        dictado.cancelar()
                                    } else {
                                        dictado.suelta()
                                    }
                                }
                        )
                        .accessibilityLabel(dictado.grabando ? cnT("Parar") : cnT("Dictar"))
                        .accessibilityHint(cnT("Mantén pulsado para hablar"))
                }
            }
            // EL BOTÓN VA FUERA DE LA CAJA.
            //
            // Estaba DENTRO, y eso es lo que hacía que aquello pareciera un
            // formulario web: una caja con borde y cosas metidas a presión. En
            // el teléfono la cápsula es el CAMPO —el sitio donde escribes— y
            // los botones son controles aparte, a su lado. Mensajes y WhatsApp
            // lo hacen así los dos.
            //
            // Y sin borde: el campo se distingue del fondo por el color, no
            // por una raya. Un recuadro de un punto alrededor del texto es de
            // página web; en iOS, el relleno basta.
            .padding(.horizontal, 14).padding(.vertical, 9)
            .background(CNC.soft, in: Capsule())
            // PEGADA AL TECLADO.
            //
            // Los diez puntos de abajo son para el indicador de inicio, que es
            // lo que hay debajo cuando el teclado NO está. Con el teclado
            // puesto ese hueco ya lo pone el teclado, y los diez se veían como
            // una franja del color de la pantalla entre la cápsula y las
            // teclas. En Mensajes la barra va pegada.
            .padding(.horizontal, 12).padding(.top, 8)
            .padding(.bottom, teclado.abierto ? 3 : 10)
            .background(CNC.scr)
            .animation(.spring(response: 0.26, dampingFraction: 0.8), value: puedeMandar)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(CNC.scr.ignoresSafeArea())
            .cnTeclado(conListo: false)
            .navigationTitle(m.titulo)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(cnT("Cerrar")) { onClose() }
                }
                // LOS TRES PUNTOS. Estaban puestos en la charla de la WEB, y
                // la que se ve en el teléfono es ESTA, la nativa: por eso no
                // aparecían por más que estuvieran hechos.
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button { datos.onCharlaAccion("ayuda") } label: {
                            Label(cnT("Qué sabe hacer Chino"), systemImage: "sparkles")
                        }
                        Button { datos.onCharlaAccion("reportar") } label: {
                            Label(cnT("Reportar un problema"), systemImage: "exclamationmark.bubble")
                        }
                        Divider()
                        Button(role: .destructive) { datos.onCharlaAccion("empezar") } label: {
                            Label(cnT("Empezar de nuevo"), systemImage: "arrow.counterclockwise")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .tint(CNC.pos)
        .environment(\.locale, Locale(identifier: CNC.fmt.loc))
        .onReceive(dictado.$texto) { t in if !t.isEmpty { texto = t } }
        .onChange(of: texto) { _ in if !dictado.pega.isEmpty { dictado.pega = "" } }
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

// ── Avisos dentro de la app ─────────────────────────────────────────────────
//
// Lo que se le enseña a alguien cuando abre: una novedad, una recomendación,
// una oferta. Lo escribe una persona en el portal y lo ve quien abra la app a
// partir de ese momento, sin versión nueva ni revisión de Apple.
//
// Y se dibuja AQUÍ, no en la web, por una razón que se nota: aquí están las
// plantillas, el muelle de la entrada escalonada y el dibujo de Chino a tamaño
// de verdad. Un aviso que parece pegado encima de la app no lo lee nadie; uno
// que parece la app es una pantalla más.

struct CNAviso {
    var id = ""
    /// personaje · cifra · lamina · tarjeta · imagen
    var plantilla = "personaje"
    var animo = "feliz"
    /// crema · marca · suave · oscuro
    var fondo = "crema"
    var acento = ""
    var rotulo = ""; var titulo = ""; var texto = ""; var cifra = ""
    var imagen = ""; var chinolo = ""
    var boton = ""; var ir = ""; var segundo = ""
    var esperaSegundos: Double = 2.5

    static func desde(json: String) -> CNAviso? {
        guard let d = json.data(using: .utf8),
              let r = (try? JSONSerialization.jsonObject(with: d)) as? [String: Any] else { return nil }
        func s(_ k: String) -> String { (r[k] as? String) ?? "" }
        guard !s("id").isEmpty else { return nil }
        var a = CNAviso()
        a.id = s("id"); a.plantilla = s("plantilla").isEmpty ? "personaje" : s("plantilla")
        a.animo = s("animo"); a.fondo = s("fondo").isEmpty ? "crema" : s("fondo")
        a.acento = s("acento")
        a.rotulo = s("rotulo"); a.titulo = s("titulo"); a.texto = s("texto"); a.cifra = s("cifra")
        a.imagen = s("imagen"); a.chinolo = s("chinolo")
        a.boton = s("boton"); a.ir = s("ir"); a.segundo = s("segundo")
        a.esperaSegundos = ((r["esperaSegundos"] as? NSNumber)?.doubleValue) ?? 2.5
        return a
    }
}

struct CNAvisoVista: View {
    let aviso: CNAviso
    /// `que` es "tocado" o "descartado": las dos maneras de responder.
    var onAccion: (String) -> Void
    @State private var entro = false
    @State private var flota = false

    private var oscuro: Bool { aviso.fondo == "marca" || aviso.fondo == "oscuro" }
    private var tinta: Color { oscuro ? cnColor(0xF7F2E4) : CNC.ink }
    private var tintaSuave: Color { oscuro ? cnColor(0xF7F2E4).opacity(0.72) : CNC.pmut }
    private var acento: Color { aviso.acento.isEmpty ? CNC.acc : cnColor(hexString: aviso.acento) }

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            cuerpo
                .padding(.horizontal, 26).padding(.top, 30)
                .padding(.bottom, cnMargenAbajo() + 18)
                .frame(maxWidth: .infinity)
                .background(fondo)
                .clipShape(CNEsquinasArriba(radio: 30))
                .shadow(color: .black.opacity(0.2), radius: 26, y: -6)
                .offset(y: entro ? 0 : 620)
        }
        .ignoresSafeArea()
        .background(
            Color.black.opacity(entro ? 0.4 : 0)
                .ignoresSafeArea()
                .onTapGesture { cerrar("descartado") }
        )
        .onAppear {
            withAnimation(.spring(response: 0.46, dampingFraction: 0.86)) { entro = true }
            flota = true
        }
    }

    /// El fondo de cada piel. El de la marca no es un verde plano: lleva el
    /// mismo halo que la portada, que es lo que le da cuerpo.
    @ViewBuilder private var fondo: some View {
        switch aviso.fondo {
        case "marca":
            ZStack {
                CNC.side
                RadialGradient(colors: [Color.white.opacity(0.13), .clear],
                               center: UnitPoint(x: 0.5, y: 0.3), startRadius: 8, endRadius: 320)
            }
        case "oscuro": cnColor(0x1B221F)
        case "suave": acento.opacity(0.12)
        default: CNC.scr
        }
    }

    @ViewBuilder private var cuerpo: some View {
        VStack(spacing: 13) {
            // EL TIRADOR, porque esto se cierra arrastrando como cualquier hoja.
            Capsule().fill(tinta.opacity(0.18)).frame(width: 36, height: 5)
                .padding(.bottom, 4)

            if aviso.plantilla == "cifra" && !aviso.cifra.isEmpty {
                Text(aviso.cifra)
                    .font(cnLetra(56, .heavy)).foregroundColor(acento)
                    .lineLimit(1).minimumScaleFactor(0.5)
                    .cnEntra(entro, 0)
            } else if aviso.plantilla == "imagen", let img = cnImagenBase64(aviso.imagen) {
                Image(uiImage: img).resizable().scaledToFit()
                    .frame(maxWidth: .infinity).frame(maxHeight: 260)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .cnEntra(entro, 0)
            } else if let img = cnImagenBase64(aviso.chinolo) {
                let lado: CGFloat = aviso.plantilla == "lamina" ? 168 : 124
                Image(uiImage: img).resizable().scaledToFit().frame(width: lado, height: lado)
                    .offset(y: flota ? -4 : 4)
                    .animation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true), value: flota)
                    .cnEntra(entro, 0)
            }

            if !aviso.rotulo.isEmpty {
                Text(aviso.rotulo.uppercased()).font(cnLetra(11, .heavy)).tracking(1.1)
                    .foregroundColor(tintaSuave)
                    .cnEntra(entro, 1)
            }
            if !aviso.titulo.isEmpty {
                Text(aviso.titulo).font(cnLetra(24, .heavy)).foregroundColor(tinta)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .cnEntra(entro, 2)
            }
            if !aviso.texto.isEmpty {
                Text(aviso.texto).font(cnLetra(15)).foregroundColor(tintaSuave)
                    .multilineTextAlignment(.center).lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 320)
                    .cnEntra(entro, 3)
            }

            VStack(spacing: 8) {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    cerrar("tocado")
                } label: {
                    Text(aviso.boton.isEmpty ? cnT("Entendido") : aviso.boton)
                        .font(cnLetra(16, .heavy)).foregroundColor(cnSobre(acento))
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(acento, in: Capsule())
                }.buttonStyle(CNPulsable())
                // LA SALIDA SIEMPRE EXISTE, la escriba quien lo escribió o no.
                // Un aviso del que no se puede salir es una pantalla secuestrada.
                Button { cerrar("descartado") } label: {
                    Text(aviso.segundo.isEmpty ? cnT("Ahora no") : aviso.segundo)
                        .font(cnLetra(15, .semibold)).foregroundColor(tintaSuave)
                        .frame(maxWidth: .infinity).padding(.vertical, 11)
                        .contentShape(Rectangle())
                }.buttonStyle(CNPulsable())
            }
            .padding(.top, 6)
            .cnEntra(entro, 4)
        }
    }

    private func cerrar(_ que: String) {
        withAnimation(.easeIn(duration: 0.22)) { entro = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) { onAccion(que) }
    }
}

/**
 * Los dibujos de los renglones del plan.
 *
 * Van aquí y no los manda la web porque son FIJOS: diecinueve trazos que no
 * cambian con los datos de nadie. Mandarlos en cada modelo sería mandar lo
 * mismo cien veces para que al final se dibuje igual.
 */
func cnIconoDePlan(_ cual: String) -> String {
    switch cual {
    case "libro": return "M4 5h7v14H4zM13 5h7v14h-7z"
    case "libros": return "M3 5h5v14H3zM10 5h5v14h-5zM17 6l3 .8-2.6 13-3-.8z"
    case "flechas": return "M7 4v16M7 20l-3-3M17 20V4M17 4l3 3"
    case "pastel": return "M12 3v9h9a9 9 0 1 1-9-9"
    case "hucha": return "M4 13a6 6 0 0 1 6-6h4a6 6 0 0 1 6 6v3H4zM7 18v2M17 18v2M16 11h1"
    case "campana": return "M6 16V11a6 6 0 0 1 12 0v5l2 3H4zM10 22h4"
    case "ia": return "M12 3l1.8 5.2L19 10l-5.2 1.8L12 17l-1.8-5.2L5 10l5.2-1.8zM19 15l.8 2.2L22 18l-2.2.8L19 21l-.8-2.2L16 18l2.2-.8z"
    case "llave": return "M15 7a4 4 0 1 1-3.9 4.9L4 19v2h3v-2h2v-2h2l1.1-1.1A4 4 0 0 1 15 7zM16 9h.01"
    case "paleta": return "M12 21a9 9 0 1 1 0-18c5 0 9 3.6 9 8 0 2.2-1.8 3-3.4 3H15a2 2 0 0 0-1.4 3.4c.4.6 0 1.6-1.6 1.6M8 8h.01M7 12h.01M11 7h.01"
    case "descarga": return "M12 4v10M8 11l4 4 4-4M4 20h16"
    case "sync": return "M4 12a8 8 0 0 1 14-5.3M20 4v4h-4M20 12a8 8 0 0 1-14 5.3M4 20v-4h4"
    case "gente": return "M8 10a3 3 0 1 0 0-6 3 3 0 0 0 0 6M17 11a2.5 2.5 0 1 0 0-5 2.5 2.5 0 0 0 0 5M2 20a6 6 0 0 1 12 0M15 20a5 5 0 0 1 7-4"
    case "micro": return "M12 3a3 3 0 0 1 3 3v6a3 3 0 0 1-6 0V6a3 3 0 0 1 3-3M5 11a7 7 0 0 0 14 0M12 18v3"
    case "chat": return "M4 5h16v11H9l-5 4z"
    case "correo": return "M3 6h18v12H3zM3 7l9 6 9-6"
    case "soporte": return "M4 14v-2a8 8 0 0 1 16 0v2M4 14h3v5H4zM17 14h3v5h-3z"
    case "escudo": return "M12 21s7-3.5 7-9V5l-7-2-7 2v7c0 5.5 7 9 7 9z"
    case "informe": return "M6 3h9l4 4v14H6zM14 3v5h5M9 13h6M9 17h6"
    case "codigo": return "M8 8l-4 4 4 4M16 8l4 4-4 4M13 6l-2 12"
    // Sin icono conocido, una marca de verificación: nunca un hueco vacío.
    default: return "M5 12.5l5 5L19 7"
    }
}
