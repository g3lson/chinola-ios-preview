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
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.4).ignoresSafeArea()
            VStack(spacing: 0) {
                cabecera
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) { content(); Color.clear.frame(height: 40) }
                        .padding(.horizontal, 16).padding(.top, 4)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(CNC.scr.clipShape(CNRedondo(radio: 28, esquinas: [.topLeft, .topRight])))
            .ignoresSafeArea(edges: .bottom).padding(.top, 46)
        }
    }

    private var cabecera: some View {
        VStack(spacing: 0) {
            Capsule().fill(CNC.line).frame(width: 40, height: 5).padding(.top, 8).padding(.bottom, 10)
            ZStack {
                Text(titulo).font(.system(size: 17, weight: .bold)).foregroundColor(CNC.ink)
                HStack {
                    Button(action: onClose) { Image(systemName: "xmark").font(.system(size: 15, weight: .bold)).foregroundColor(CNC.pmut).frame(width: 34, height: 34).background(.ultraThinMaterial, in: Circle()).overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 0.6)) }.buttonStyle(.plain)
                    Spacer()
                    Button(action: onGuardar) { HStack(spacing: 5) { Image(systemName: "checkmark").font(.system(size: 12, weight: .heavy)); Text(guardarTexto).font(.system(size: 14, weight: .bold)) }.foregroundColor(Color(cnHex: 0x3a2c00)).padding(.horizontal, 15).padding(.vertical, 8).background(Capsule().fill(.ultraThinMaterial).overlay(Capsule().fill(CNC.acc.opacity(0.55)))).overlay(Capsule().stroke(Color.white.opacity(0.45), lineWidth: 0.6)) }.buttonStyle(.plain)
                }
            }.padding(.horizontal, 16).padding(.bottom, 14)
        }
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
    var body: some View {
        cnGrupoHoja { VStack(spacing: 2) {
            Text("MONTO").font(.system(size: 11, weight: .semibold)).tracking(0.4).foregroundColor(CNC.pmut)
            HStack(spacing: 6) { Text("RD$").font(.system(size: 20, weight: .heavy)).foregroundColor(CNC.pmut)
                TextField("0", text: $monto).font(.system(size: 34, weight: .heavy)).foregroundColor(CNC.ink).keyboardType(.numberPad).multilineTextAlignment(.center).fixedSize() }
        }.frame(maxWidth: .infinity).padding(.vertical, 16) }
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
