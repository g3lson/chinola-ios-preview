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
        .environment(\.locale, Locale(identifier: "es_DO"))
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
                    Button("Listo") { cnCerrarTeclado() }.font(.system(size: 16, weight: .semibold))
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
    var onClose: () -> Void
    var onGuardar: (() -> Void)? = nil
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
                    }.buttonStyle(CNPulsable())
                    Spacer()
                    if let guardar = onGuardar {
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            guardar()
                        } label: {
                            Text(guardarTexto).font(.system(size: 15, weight: .bold))
                                .foregroundColor(CNC.sobreAcc)
                                .padding(.horizontal, 16).frame(height: 36)
                                .cnVidrio(Capsule(), tinte: guardarActivo ? CNC.acc : CNC.line)
                        }
                        .buttonStyle(CNPulsable())
                        .disabled(!guardarActivo)
                        .opacity(guardarActivo ? 1 : 0.55)
                    }
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
                Text(texto).font(.system(size: 17, weight: .bold)).foregroundColor(CNC.sobreAcc)
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
                    Text(r).font(.system(size: 11, weight: .semibold)).tracking(0.4).foregroundColor(CNC.pmut)
                }
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
                            Text(o.1).font(.system(size: 14, weight: .semibold)).foregroundColor(puesta ? cnSobre(color) : CNC.ink)
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
                    .font(.system(size: 16)).foregroundColor(CNC.ink)
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
            Text(titulo).font(.system(size: 16)).foregroundColor(CNC.ink)
            Spacer(minLength: 8)
            HStack(spacing: 4) {
                Spacer(minLength: 0)
                Text("RD$").font(.system(size: 13, weight: .bold)).foregroundColor(CNC.pmut)
                TextField("0", text: $monto)
                    .font(.system(size: 16, weight: .semibold)).foregroundColor(CNC.ink)
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
            Text(titulo).font(.system(size: 16)).foregroundColor(CNC.ink)
            Spacer(minLength: 8)
            TextField(marca, text: $texto)
                .font(.system(size: 16, weight: .semibold)).foregroundColor(CNC.ink)
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
                Text(nombre).font(.system(size: 14, weight: .semibold))
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
        CNHoja(titulo: "Nueva cuenta", guardarActivo: !nombre.trimmingCharacters(in: .whitespaces).isEmpty,
               onClose: onClose, onGuardar: guardar) {
            CNGrupoCampos(campos: [("Nombre (ej. Cuenta principal)", $nombre, .default),
                                   ("Banco (opcional)", $banco, .default)])
            VStack(alignment: .leading, spacing: 6) { cnHojaTitulo("Saldo actual"); CNMontoCampo(monto: $saldo, rotulo: nil) }
            VStack(alignment: .leading, spacing: 8) { cnHojaTitulo("Tipo"); CNFichas(opciones: clases, elegida: $clase) }
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
        CNHoja(titulo: "Nueva tarjeta", guardarActivo: !nombre.trimmingCharacters(in: .whitespaces).isEmpty,
               onClose: onClose, onGuardar: guardar) {
            CNGrupoCampos(campos: [("Nombre (ej. Visa Popular)", $nombre, .default),
                                   ("Banco (opcional)", $banco, .default)])
            VStack(alignment: .leading, spacing: 6) { cnHojaTitulo("Límite"); CNMontoCampo(monto: $limite, paso: 5000, rotulo: nil) }
            VStack(alignment: .leading, spacing: 8) {
                cnHojaTitulo("Deuda y fechas")
                cnGrupoHoja {
                    CNFilaMonto(icono: "creditcard.fill", tinte: CNC.neg, titulo: "Deuda actual", monto: $saldo)
                    cnDiviHoja()
                    CNFilaNumero(icono: "calendar", tinte: CNC.info, titulo: "Día de corte", marca: "20", texto: $corte)
                    cnDiviHoja()
                    CNFilaNumero(icono: "calendar.badge.clock", tinte: cnColor(0x825eb9), titulo: "Día de pago", marca: "5", texto: $pago)
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
        CNHoja(titulo: "Nuevo préstamo", guardarActivo: !nombre.trimmingCharacters(in: .whitespaces).isEmpty,
               onClose: onClose, onGuardar: guardar) {
            VStack(alignment: .leading, spacing: 8) {
                cnHojaTitulo("¿Cómo es?")
                CNFichas(opciones: [("debo", "Yo debo", "mano"), ("meDeben", "Me deben", "billete")], elegida: $sentido)
            }
            CNGrupoCampos(campos: [("Nombre (ej. Préstamo del carro)", $nombre, .default),
                                   ("Entidad o persona (opcional)", $entidad, .default)])
            VStack(alignment: .leading, spacing: 6) { cnHojaTitulo("Monto total"); CNMontoCampo(monto: $total, paso: 1000, rotulo: nil) }
            cnGrupoHoja {
                CNFilaMonto(icono: "checkmark.circle.fill", tinte: CNC.pos, titulo: "Ya pagado", monto: $pagado)
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
        CNHoja(titulo: "Nueva meta", guardarActivo: !nombre.trimmingCharacters(in: .whitespaces).isEmpty,
               onClose: onClose, onGuardar: guardar) {
            CNCampoTexto(placeholder: "Nombre (ej. Fondo de emergencia)", texto: $nombre)
            VStack(alignment: .leading, spacing: 6) { cnHojaTitulo("Objetivo"); CNMontoCampo(monto: $objetivo, paso: 5000, rotulo: nil) }
            cnGrupoHoja {
                CNFilaMonto(icono: "arrow.down.circle.fill", tinte: cnColor(hexString: color), titulo: "Aporte mensual", monto: $mensual)
            }
            VStack(alignment: .leading, spacing: 8) {
                cnHojaTitulo("Icono")
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

    /// Sin atenuado ni esquinas propias: ya vamos DENTRO de una hoja del
    /// sistema, y ponerle otra encima se veía como dos hojas.
    private var chooser: some View {
        VStack(spacing: 0) {
            CNHojaCabecera(titulo: "¿Qué quieres agregar?", onClose: onClose)
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
                VStack(alignment: .leading, spacing: 2) { Text(t).font(.system(size: 16, weight: .semibold)).foregroundColor(CNC.ink); Text(s).font(.system(size: 12.5)).foregroundColor(CNC.pmut) }
                Spacer(minLength: 6); Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundColor(CNC.pmut.opacity(0.6))
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
                           guardarActivo: !m.cargando, onClose: onClose,
                           onGuardar: { datos.onHojaEnviar() })
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    if !m.texto.isEmpty {
                        Text(m.texto).font(.system(size: 13.5)).foregroundColor(CNC.pmut)
                            .fixedSize(horizontal: false, vertical: true).padding(.horizontal, 4)
                    }
                    ForEach(m.campos) { c in campo(c) }
                    if !m.error.isEmpty { aviso(m.error, CNC.neg) }
                    if !m.ok.isEmpty { aviso(m.ok, CNC.pos) }
                    Color.clear.frame(height: 24)
                }
                .padding(.horizontal, 16).padding(.top, 4)
            }
            .cnTeclado()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(CNC.scr.ignoresSafeArea())
        .environment(\.locale, Locale(identifier: "es_DO"))
    }

    private func aviso(_ t: String, _ color: Color) -> some View {
        Text(t).font(.system(size: 13)).foregroundColor(color)
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
                            Text(etiqueta(c)).font(.system(size: 16)).foregroundColor(CNC.ink).lineLimit(1)
                            Spacer(minLength: 8)
                            Image(systemName: "chevron.up.chevron.down").font(.system(size: 11, weight: .semibold))
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
                                .keyboardType(cnTeclado(c.teclado))
                                .textInputAutocapitalization(c.teclado == "email" ? .never : .sentences)
                                .disableAutocorrection(c.teclado == "email")
                        }
                    }
                    .font(.system(size: 16)).foregroundColor(CNC.ink)
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
func cnTeclado(_ nombre: String) -> UIKeyboardType {
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
