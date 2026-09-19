import SwiftUI

// Formularios de «agregar» y «editar» con el look nativo de iOS: todos comparten
// la misma cabecera de hoja (asa + × / título / ✓), los grupos redondeados y el
// bloque de monto grande. Iconos SF para que se sientan del sistema.

// Bloque de monto grande (— DOP 0 +), como en «Nuevo movimiento».
struct MontoBloque: View {
    var moneda: String = "DOP"
    var valor: String = "0"
    var body: some View {
        Grupo {
            HStack {
                botonRedondo("minus")
                Spacer()
                VStack(spacing: 1) {
                    Text("MONTO").font(.system(size: 11, weight: .semibold)).tracking(0.4).foregroundColor(.pmut)
                    Text("\(moneda) \(valor)").font(.system(size: 30, weight: .heavy)).foregroundColor(.ink)
                }
                Spacer()
                botonRedondo("plus")
            }
            .padding(.horizontal, 12).padding(.vertical, 12)
        }
    }
    private func botonRedondo(_ ic: String) -> some View {
        Image(systemName: ic).font(.system(size: 17, weight: .bold)).foregroundColor(.ink)
            .frame(width: 42, height: 42).background(Color.soft).clipShape(Circle())
    }
}

// Segmento en cápsula (dos o más opciones), como el de «Nuevo movimiento».
struct SegmentoPildora: View {
    let items: [String]
    @Binding var sel: Int
    var body: some View {
        HStack(spacing: 4) {
            ForEach(items.indices, id: \.self) { i in
                Text(items[i])
                    .font(.system(size: 13.5, weight: i == sel ? .bold : .semibold))
                    .foregroundColor(i == sel ? .white : .pmut)
                    .frame(maxWidth: .infinity).padding(.vertical, 9)
                    .background(i == sel ? Color.side : Color.clear)
                    .clipShape(Capsule())
                    .onTapGesture { sel = i }
            }
        }
        .padding(4).background(Color.soft).clipShape(Capsule())
    }
}

// Cuerpo de hoja reutilizable: cabecera fija + scroll. Si se le pasan `onClose`
// y `guardar`, los botones × y Guardar quedan cableados de verdad.
struct HojaForm<Contenido: View>: View {
    let titulo: String
    var onClose: (() -> Void)? = nil
    var guardar: (() -> Void)? = nil
    @ViewBuilder var contenido: Contenido
    var body: some View {
        ZStack(alignment: .bottom) {
            FondoAtenuado()
            VStack(spacing: 0) {
                if let onClose = onClose, let guardar = guardar {
                    CabeceraHojaAcc(titulo: titulo, onClose: onClose, guardar: guardar)
                } else {
                    CabeceraHoja(titulo: titulo, conCheck: true)
                }
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        contenido
                        Color.clear.frame(height: 40)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .comoHoja()
        }
    }
}

// ── Transferencia entre cuentas ────────────────────────────────────────────
struct TransferenciaView: View {
    @EnvironmentObject var estado: AppEstado
    var onClose: () -> Void = {}
    @State private var monto = ""
    @State private var desde = 0
    @State private var hacia = 0
    @State private var nota = ""

    var body: some View {
        HojaForm(titulo: "Transferencia", onClose: onClose, guardar: guardar) {
            MontoEditable(monto: $monto)
            VStack(spacing: 6) {
                SeccionTitulo(texto: "De dónde y hacia dónde")
                Grupo {
                    MenuCuenta(estado: estado, titulo: "Desde", icono: "banknote.fill", tinte: .pos, sel: $desde)
                    Divisor()
                    MenuCuenta(estado: estado, titulo: "Hacia", icono: "building.columns.fill", tinte: .info, sel: $hacia)
                }
            }
            VStack(spacing: 6) {
                SeccionTitulo(texto: "Detalles")
                Grupo { CampoTexto(placeholder: "Nota (opcional)", texto: $nota) }
            }
        }
        .onAppear {
            let c = estado.libreta.cuentas
            if desde == 0 { desde = c.first?.id ?? 0 }
            if hacia == 0 { hacia = (c.count > 1 ? c[1].id : c.first?.id) ?? 0 }
        }
    }

    private func guardar() {
        let n = Double(monto.replacingOccurrences(of: ",", with: "")) ?? 0
        guard n > 0, desde != hacia else { onClose(); return }
        let mov = Movimiento(id: "tr\(Int(Date().timeIntervalSince1970 * 1000))",
                             concepto: nota.isEmpty ? "Transferencia" : nota,
                             categoria: "Otros", tipo: .transferencia, monto: n, fecha: Movimiento.hoy(),
                             medio: "cuenta:\(desde)", destino: "cuenta:\(hacia)")
        estado.agregar(mov)
        onClose()
    }
}

// Bloque de monto EDITABLE (— DOP [campo] +) para los formularios funcionales.
struct MontoEditable: View {
    @Binding var monto: String
    var moneda: String = "DOP"
    var body: some View {
        Grupo {
            VStack(spacing: 2) {
                Text("MONTO").font(.system(size: 11, weight: .semibold)).tracking(0.4).foregroundColor(.pmut)
                HStack(spacing: 6) {
                    Text(moneda).font(.system(size: 20, weight: .heavy)).foregroundColor(.pmut)
                    TextField("0", text: $monto)
                        .font(.system(size: 34, weight: .heavy)).foregroundColor(.ink)
                        .keyboardType(.numberPad).multilineTextAlignment(.center).fixedSize()
                }
            }
            .frame(maxWidth: .infinity).padding(.vertical, 16)
        }
    }
}

// Fila-menú para elegir una cuenta de la libreta.
struct MenuCuenta: View {
    let estado: AppEstado
    let titulo: String
    let icono: String
    let tinte: Color
    @Binding var sel: Int
    var body: some View {
        Menu {
            ForEach(estado.libreta.cuentas) { c in Button(c.nombre) { sel = c.id } }
        } label: {
            HStack(spacing: 12) {
                IconoCuadro(sistema: icono, tinte: tinte)
                Text(titulo).font(.system(size: 16)).foregroundColor(.ink)
                Spacer(minLength: 8)
                Text(estado.libreta.cuentas.first { $0.id == sel }?.nombre ?? "Efectivo")
                    .font(.system(size: 15)).foregroundColor(.pmut)
                Image(systemName: "chevron.up.chevron.down").font(.system(size: 11, weight: .semibold)).foregroundColor(Color.pmut.opacity(0.6))
            }
            .padding(.horizontal, 14).padding(.vertical, 11)
        }
    }
}

// ── Préstamo / fiado (agregar) ─────────────────────────────────────────────
struct PrestamoView: View {
    @EnvironmentObject var estado: AppEstado
    var onClose: () -> Void = {}
    @State private var lado = 0   // 0 = yo presté (meDeben) · 1 = me prestaron (debo)
    @State private var monto = ""
    @State private var nombre = ""

    var body: some View {
        HojaForm(titulo: "Préstamo o fiado", onClose: onClose, guardar: guardar) {
            SegmentoPildora(items: ["Yo presté", "Me prestaron"], sel: $lado)
            MontoEditable(monto: $monto)
            VStack(spacing: 6) {
                SeccionTitulo(texto: lado == 0 ? "¿A quién le prestaste?" : "¿Quién te prestó?")
                Grupo { CampoTexto(placeholder: "Nombre de la persona", texto: $nombre) }
            }
        }
    }

    private func guardar() {
        let n = nombre.trimmingCharacters(in: .whitespaces)
        let total = Double(monto.replacingOccurrences(of: ",", with: "")) ?? 0
        guard !n.isEmpty, total > 0 else { onClose(); return }
        var lb = estado.libreta
        lb.prestamos.append(Prestamo(id: Int(Date().timeIntervalSince1970), nombre: n, total: total,
                                     pagado: 0, color: "#825eb9", sentido: lado == 0 ? "meDeben" : "debo"))
        estado.libreta = lb
        onClose()
    }
}

// ── Abono a un préstamo ─────────────────────────────────────────────────────
struct AbonoView: View {
    @EnvironmentObject var estado: AppEstado
    var prestamoId: Int = 0
    var onClose: () -> Void = {}
    @State private var monto = ""
    @State private var cuenta = 0

    var body: some View {
        let p = estado.libreta.prestamos.first { $0.id == prestamoId }
        return HojaForm(titulo: "Registrar un abono", onClose: onClose, guardar: guardar) {
            MontoEditable(monto: $monto)
            VStack(spacing: 6) {
                SeccionTitulo(texto: (p?.sentido ?? "meDeben") == "meDeben" ? "Entra a" : "Sale de")
                Grupo { MenuCuenta(estado: estado, titulo: "Cuenta", icono: "banknote.fill", tinte: .pos, sel: $cuenta) }
                NotaPie(texto: "El saldo del préstamo baja con cada abono.")
            }
        }
        .onAppear { if cuenta == 0 { cuenta = estado.libreta.cuentas.first?.id ?? 0 } }
    }
    private func guardar() {
        let n = Double(monto.replacingOccurrences(of: ",", with: "")) ?? 0
        guard n > 0 else { onClose(); return }
        estado.abonar(prestamoId, monto: n, medio: "cuenta:\(cuenta)")
        onClose()
    }
}

// ── Aporte a una meta ───────────────────────────────────────────────────────
struct AporteView: View {
    @EnvironmentObject var estado: AppEstado
    var metaId: Int = 0
    var onClose: () -> Void = {}
    @State private var monto = ""
    @State private var cuenta = 0

    var body: some View {
        HojaForm(titulo: "Aportar a la meta", onClose: onClose, guardar: guardar) {
            MontoEditable(monto: $monto)
            VStack(spacing: 6) {
                SeccionTitulo(texto: "Sale de")
                Grupo { MenuCuenta(estado: estado, titulo: "Cuenta", icono: "banknote.fill", tinte: .pos, sel: $cuenta) }
                NotaPie(texto: "Cada aporte acerca la meta a su objetivo.")
            }
        }
        .onAppear { if cuenta == 0 { cuenta = estado.libreta.cuentas.first?.id ?? 0 } }
    }
    private func guardar() {
        let n = Double(monto.replacingOccurrences(of: ",", with: "")) ?? 0
        guard n > 0 else { onClose(); return }
        estado.aportar(metaId, monto: n, medio: "cuenta:\(cuenta)")
        onClose()
    }
}

// ── Meta de ahorro (agregar) ────────────────────────────────────────────────
struct MetaView: View {
    @EnvironmentObject var estado: AppEstado
    var onClose: () -> Void = {}
    @State private var nombre = ""
    @State private var objetivo = ""
    @State private var ahorrado = ""

    var body: some View {
        HojaForm(titulo: "Nueva meta", onClose: onClose, guardar: guardar) {
            VStack(spacing: 6) {
                SeccionTitulo(texto: "¿Qué quieres lograr?")
                Grupo {
                    CampoTexto(placeholder: "Nombre (ej. Viaje a Punta Cana)", texto: $nombre)
                    Divisor(sangria: 16)
                    CampoTexto(placeholder: "¿Cuánto necesitas?", texto: $objetivo, numero: true)
                    Divisor(sangria: 16)
                    CampoTexto(placeholder: "Ya tienes ahorrado (opcional)", texto: $ahorrado, numero: true)
                }
            }
        }
    }

    private func guardar() {
        let n = nombre.trimmingCharacters(in: .whitespaces)
        let obj = Double(objetivo.replacingOccurrences(of: ",", with: "")) ?? 0
        guard !n.isEmpty, obj > 0 else { onClose(); return }
        var lb = estado.libreta
        lb.metas.append(Meta(id: Int(Date().timeIntervalSince1970), nombre: n, meta: obj,
                             ahorrado: Double(ahorrado.replacingOccurrences(of: ",", with: "")) ?? 0,
                             color: "#825eb9", icono: "target"))
        estado.libreta = lb
        onClose()
    }
}

// ── Tarjeta de crédito (agregar) ────────────────────────────────────────────
struct TarjetaView: View {
    @EnvironmentObject var estado: AppEstado
    var onClose: () -> Void = {}
    @State private var nombre = ""
    @State private var banco = ""
    @State private var limite = ""
    @State private var deuda = ""

    var body: some View {
        HojaForm(titulo: "Nueva tarjeta", onClose: onClose, guardar: guardar) {
            VStack(spacing: 6) {
                SeccionTitulo(texto: "Datos de la tarjeta")
                Grupo {
                    CampoTexto(placeholder: "Nombre (ej. Visa Popular)", texto: $nombre)
                    Divisor(sangria: 16)
                    CampoTexto(placeholder: "Banco (opcional)", texto: $banco)
                    Divisor(sangria: 16)
                    CampoTexto(placeholder: "Límite de crédito", texto: $limite, numero: true)
                    Divisor(sangria: 16)
                    CampoTexto(placeholder: "Deuda actual (opcional)", texto: $deuda, numero: true)
                }
            }
        }
    }

    private func guardar() {
        let n = nombre.trimmingCharacters(in: .whitespaces)
        guard !n.isEmpty else { onClose(); return }
        var lb = estado.libreta
        lb.tarjetas.append(Tarjeta(id: Int(Date().timeIntervalSince1970), nombre: n,
                                   banco: banco.trimmingCharacters(in: .whitespaces),
                                   limite: Double(limite.replacingOccurrences(of: ",", with: "")) ?? 0,
                                   saldo: Double(deuda.replacingOccurrences(of: ",", with: "")) ?? 0,
                                   color: "#d55948",
                                   last4: String(format: "%04d", Int.random(in: 1000...9999))))
        estado.libreta = lb
        onClose()
    }
}

// ── Pago de tarjeta ─────────────────────────────────────────────────────────
struct PagoTarjetaView: View {
    @EnvironmentObject var estado: AppEstado
    var tarjetaId: Int = 0
    var onClose: () -> Void = {}
    @State private var monto = ""
    @State private var cuenta = 0

    var body: some View {
        HojaForm(titulo: "Pagar la tarjeta", onClose: onClose, guardar: guardar) {
            MontoEditable(monto: $monto)
            VStack(spacing: 6) {
                SeccionTitulo(texto: "Pagas desde")
                Grupo { MenuCuenta(estado: estado, titulo: "Cuenta", icono: "banknote.fill", tinte: .pos, sel: $cuenta) }
                NotaPie(texto: "El pago baja la deuda de la tarjeta y sale de la cuenta elegida.")
            }
        }
        .onAppear { if cuenta == 0 { cuenta = estado.libreta.cuentas.first?.id ?? 0 } }
    }
    private func guardar() {
        let n = Double(monto.replacingOccurrences(of: ",", with: "")) ?? 0
        guard n > 0 else { onClose(); return }
        estado.pagarTarjeta(tarjetaId, monto: n, medio: "cuenta:\(cuenta)")
        onClose()
    }
}

// ── Categoría (nombre, tipo, límite, color e icono) ────────────────────────
struct CategoriaView: View {
    @EnvironmentObject var estado: AppEstado
    var onClose: () -> Void = {}
    @State private var tipo = 0
    @State private var color = 3
    @State private var icono = 0
    @State private var nombre = ""
    @State private var tope = ""
    private let colores: [Color] = [.pos, .neg, .info, .sav, Color(hex: 0xe0a92e), Color(hex: 0x1fa9a0), Color(hex: 0xd55948)]
    private let coloresHex = ["#137d41", "#d55948", "#398ad6", "#825eb9", "#e0a92e", "#1fa9a0", "#d55948"]
    private let iconos = ["cart.fill", "fork.knife", "car.fill", "house.fill", "bolt.fill", "cross.case.fill",
                          "gamecontroller.fill", "gift.fill", "airplane", "book.fill", "tshirt.fill", "pawprint.fill"]
    var body: some View {
        HojaForm(titulo: "Nueva categoría", onClose: onClose, guardar: guardar) {
            SegmentoPildora(items: ["Gasto", "Ingreso"], sel: $tipo)
            VStack(spacing: 6) {
                SeccionTitulo(texto: "Nombre y tope")
                Grupo {
                    CampoTexto(placeholder: "Nombre (ej. Supermercado)", texto: $nombre)
                    Divisor(sangria: 16)
                    CampoTexto(placeholder: "Tope mensual (opcional)", texto: $tope, numero: true)
                }
            }
            VStack(spacing: 8) {
                SeccionTitulo(texto: "Color")
                HStack(spacing: 10) {
                    ForEach(colores.indices, id: \.self) { i in
                        Circle().fill(colores[i]).frame(width: 30, height: 30)
                            .overlay(Circle().stroke(Color.ink, lineWidth: i == color ? 2.5 : 0).padding(-3))
                            .onTapGesture { color = i }
                    }
                    Spacer(minLength: 0)
                }
            }
            VStack(spacing: 8) {
                SeccionTitulo(texto: "Icono")
                Grupo {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 5), spacing: 10) {
                        ForEach(iconos.indices, id: \.self) { i in
                            Image(systemName: iconos[i])
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(i == icono ? .white : .pmut)
                                .frame(width: 46, height: 46)
                                .background(i == icono ? colores[color] : Color.soft)
                                .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                                .onTapGesture { icono = i }
                        }
                    }
                    .padding(12)
                }
            }
        }
    }

    private func guardar() {
        let n = nombre.trimmingCharacters(in: .whitespaces)
        guard !n.isEmpty else { onClose(); return }
        var lb = estado.libreta
        lb.categorias.append(Categoria(id: Int(Date().timeIntervalSince1970), nombre: n,
                                       tipo: tipo == 0 ? "Gasto" : "Ingreso",
                                       limite: Double(tope.replacingOccurrences(of: ",", with: "")) ?? 0,
                                       color: coloresHex[color], icono: iconos[icono]))
        estado.libreta = lb
        onClose()
    }
}
