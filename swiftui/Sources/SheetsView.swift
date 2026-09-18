import SwiftUI

// Fondo para las hojas: el dashboard atenuado detrás.
struct FondoAtenuado: View {
    var body: some View {
        ZStack {
            DashboardView()
            Color.black.opacity(0.4).ignoresSafeArea()
        }
    }
}

// Botón circular liquid glass de la cabecera (× cerrar): material translúcido
// como los botones del sistema en iOS, con brillo arriba y sombrita suave.
struct BotonCirculo: View {
    let icono: String
    var fg: Color = .pmut
    var body: some View {
        Image(systemName: icono).font(.system(size: 15, weight: .bold)).foregroundColor(fg)
            .frame(width: 34, height: 34)
            .background(.ultraThinMaterial, in: Circle())
            .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 0.6))
            .shadow(color: .black.opacity(0.10), radius: 6, y: 2)
    }
}

// Botón «Guardar» liquid glass: cápsula de material con un tinte dorado (el
// acento Chinola) y el check, como una acción destacada nativa de iOS 26.
struct BotonGuardar: View {
    var texto: String = "Guardar"
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "checkmark").font(.system(size: 12, weight: .heavy))
            Text(texto).font(.system(size: 14, weight: .bold))
        }
        .foregroundColor(Color(hex: 0x3a2c00))
        .padding(.horizontal, 15).padding(.vertical, 8)
        .background(
            Capsule().fill(.ultraThinMaterial)
                .overlay(Capsule().fill(Color.acc.opacity(0.55)))
        )
        .overlay(Capsule().stroke(Color.white.opacity(0.45), lineWidth: 0.6))
        .shadow(color: Color.acc.opacity(0.35), radius: 8, y: 2)
    }
}

// Botón de acción a lo ancho, liquid glass (Guardar/Confirmar al pie de una hoja).
struct BotonAncho: View {
    let texto: String
    var icono: String? = nil
    var body: some View {
        HStack(spacing: 6) {
            if let ic = icono { Image(systemName: ic).font(.system(size: 15, weight: .heavy)) }
            Text(texto).font(.system(size: 15.5, weight: .bold))
        }
        .foregroundColor(Color(hex: 0x3a2c00))
        .frame(maxWidth: .infinity).padding(.vertical, 15)
        .background(
            Capsule().fill(.ultraThinMaterial)
                .overlay(Capsule().fill(Color.acc.opacity(0.6)))
        )
        .overlay(Capsule().stroke(Color.white.opacity(0.5), lineWidth: 0.7))
        .shadow(color: Color.acc.opacity(0.4), radius: 12, y: 4)
    }
}

// Cabecera fija de una hoja: asa + (× / título / Guardar). El título va centrado
// en un ZStack para que no se descuadre aunque el botón de la derecha sea ancho.
struct CabeceraHoja: View {
    let titulo: String
    var conCheck: Bool = false
    var body: some View {
        VStack(spacing: 0) {
            Capsule().fill(Color.line).frame(width: 40, height: 5).padding(.top, 8).padding(.bottom, 10)
            ZStack {
                Text(titulo).font(.system(size: 17, weight: .bold)).foregroundColor(.ink)
                HStack {
                    BotonCirculo(icono: "xmark")
                    Spacer()
                    if conCheck { BotonGuardar() }
                }
            }
            .padding(.horizontal, 16).padding(.bottom, 14)
        }
    }
}

// Igual que CabeceraHoja pero con × y Guardar cableados de verdad.
struct CabeceraHojaAcc: View {
    let titulo: String
    var onClose: () -> Void
    var guardar: () -> Void
    var body: some View {
        VStack(spacing: 0) {
            Capsule().fill(Color.line).frame(width: 40, height: 5).padding(.top, 8).padding(.bottom, 10)
            ZStack {
                Text(titulo).font(.system(size: 17, weight: .bold)).foregroundColor(.ink)
                HStack {
                    Button(action: onClose) { BotonCirculo(icono: "xmark") }.buttonStyle(.plain)
                    Spacer()
                    Button(action: guardar) { BotonGuardar() }.buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16).padding(.bottom, 14)
        }
    }
}

// Campo de texto nativo dentro de un grupo (para los formularios funcionales).
struct CampoTexto: View {
    let placeholder: String
    @Binding var texto: String
    var numero: Bool = false
    var body: some View {
        TextField(placeholder, text: $texto)
            .font(.system(size: 16)).foregroundColor(.ink)
            .keyboardType(numero ? .numberPad : .default)
            .padding(.horizontal, 15).padding(.vertical, 13)
    }
}

// Contenedor de hoja: llega hasta el fondo, esquinas redondeadas solo arriba.
// `grande` la hace casi de pantalla completa; si no, se ajusta a su contenido.
extension View {
    func comoHoja(grande: Bool = true) -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: grande ? .infinity : nil, alignment: .top)
            .background(
                Color.scr.clipShape(UnevenRoundedRectangle(topLeadingRadius: 28, topTrailingRadius: 28, style: .continuous))
            )
            .ignoresSafeArea(edges: .bottom)
            .padding(.top, grande ? 46 : 0)
    }
}

// Hoja «Nuevo movimiento»: funcional de verdad — escribe el monto y concepto,
// elige tipo, cuenta y categoría, y guarda al estado de la app.
struct NuevoMovView: View {
    @EnvironmentObject var estado: AppEstado
    var onClose: () -> Void = {}

    @State private var tipo = 2
    @State private var repetir = false
    @State private var monto = ""
    @State private var concepto = ""
    @State private var cuentaId = 0
    @State private var categoria = ""
    @State private var fecha = Date()
    private let tipos = ["Ingreso", "Fijo", "Variable", "Ahorro"]
    private let mapa: [TipoMov] = [.ingreso, .gastoFijo, .gastoVariable, .ahorro]

    var body: some View {
        ZStack(alignment: .bottom) {
            FondoAtenuado()
            VStack(spacing: 0) {
                cabecera
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        SegmentoPildora(items: tipos, sel: $tipo)

                        Grupo {
                            VStack(spacing: 2) {
                                Text("MONTO").font(.system(size: 11, weight: .semibold)).tracking(0.4).foregroundColor(.pmut)
                                HStack(spacing: 6) {
                                    Text("DOP").font(.system(size: 20, weight: .heavy)).foregroundColor(.pmut)
                                    TextField("0", text: $monto)
                                        .font(.system(size: 34, weight: .heavy)).foregroundColor(.ink)
                                        .keyboardType(.numberPad).multilineTextAlignment(.center)
                                        .fixedSize()
                                }
                            }
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                        }

                        Grupo {
                            TextField("Descripción o concepto", text: $concepto)
                                .font(.system(size: 16)).foregroundColor(.ink)
                                .padding(.horizontal, 15).padding(.vertical, 13)
                        }

                        VStack(spacing: 6) {
                            SeccionTitulo(texto: "Cuándo y de dónde")
                            Grupo {
                                HStack(spacing: 12) {
                                    IconoCuadro(sistema: "calendar", tinte: .neg)
                                    Text("Fecha").font(.system(size: 16)).foregroundColor(.ink)
                                    Spacer()
                                    DatePicker("", selection: $fecha, displayedComponents: .date)
                                        .labelsHidden()
                                }
                                .padding(.horizontal, 14).padding(.vertical, 7)
                                Divisor()
                                menuFila(icono: "banknote.fill", tinte: .info, titulo: "Pagado con", valor: cuentaNombre) {
                                    ForEach(estado.libreta.cuentas) { c in
                                        Button(c.nombre) { cuentaId = c.id }
                                    }
                                }
                            }
                        }

                        VStack(spacing: 6) {
                            SeccionTitulo(texto: "Categoría")
                            Grupo {
                                menuFila(icono: "tag.fill", tinte: Color(hex: 0xe0a92e), titulo: "Categoría", valor: categoria.isEmpty ? "Otros" : categoria) {
                                    ForEach(estado.libreta.categorias) { c in
                                        Button(c.nombre) { categoria = c.nombre }
                                    }
                                    Button("Otros") { categoria = "Otros" }
                                }
                            }
                        }

                        VStack(spacing: 6) {
                            Grupo { FilaToggle(icono: "repeat", tinte: .sav, titulo: "Repetir cada mes", on: $repetir) }
                            NotaPie(texto: "Para lo que siempre pagas: renta, luz, colegio.")
                        }

                        Color.clear.frame(height: 40)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .comoHoja()
        }
        .onAppear { if cuentaId == 0 { cuentaId = estado.libreta.cuentas.first?.id ?? 0 } }
    }

    // Cabecera con × y Guardar cableados de verdad.
    private var cabecera: some View {
        VStack(spacing: 0) {
            Capsule().fill(Color.line).frame(width: 40, height: 5).padding(.top, 8).padding(.bottom, 10)
            ZStack {
                Text("Nuevo movimiento").font(.system(size: 17, weight: .bold)).foregroundColor(.ink)
                HStack {
                    Button(action: onClose) { BotonCirculo(icono: "xmark") }.buttonStyle(.plain)
                    Spacer()
                    Button(action: guardar) { BotonGuardar() }.buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16).padding(.bottom, 14)
        }
    }

    private var cuentaNombre: String {
        estado.libreta.cuentas.first { $0.id == cuentaId }?.nombre ?? "Efectivo"
    }

    private func menuFila<M: View>(icono: String, tinte: Color, titulo: String, valor: String, @ViewBuilder menu: () -> M) -> some View {
        Menu {
            menu()
        } label: {
            HStack(spacing: 12) {
                IconoCuadro(sistema: icono, tinte: tinte)
                Text(titulo).font(.system(size: 16)).foregroundColor(.ink)
                Spacer(minLength: 8)
                Text(valor).font(.system(size: 15)).foregroundColor(.pmut)
                Image(systemName: "chevron.up.chevron.down").font(.system(size: 11, weight: .semibold)).foregroundColor(Color.pmut.opacity(0.6))
            }
            .padding(.horizontal, 14).padding(.vertical, 11)
        }
    }

    private func guardar() {
        let n = Double(monto.replacingOccurrences(of: ",", with: "")) ?? 0
        guard n > 0 else { onClose(); return }
        let mov = Movimiento(
            id: "m\(Int(Date().timeIntervalSince1970 * 1000))",
            concepto: concepto.isEmpty ? (categoria.isEmpty ? "Movimiento" : categoria) : concepto,
            categoria: categoria.isEmpty ? "Otros" : categoria,
            tipo: mapa[tipo], monto: n, fecha: Movimiento.hoy(),
            recurrente: repetir, medio: "cuenta:\(cuentaId)")
        estado.agregar(mov)
        onClose()
    }
}

// Hoja «Agregar» (la del «+»): un chooser corto que abre cada formulario.
struct AccionesMenu: View {
    var onClose: () -> Void = {}
    var elegir: (HojaActiva) -> Void = { _ in }
    private let items: [(String, String, Color, HojaActiva)] = [
        ("Un movimiento", "arrow.up.arrow.down", .pos, .nuevo),
        ("Una transferencia", "arrow.left.arrow.right", .info, .transferencia),
        ("Una cuenta", "banknote.fill", .info, .cuenta),
        ("Una tarjeta", "creditcard.fill", .neg, .tarjeta),
        ("Un préstamo o fiado", "hand.raised.fill", Color(hex: 0x825eb9), .prestamo),
        ("Una categoría", "tag.fill", Color(hex: 0xe0a92e), .categoria),
        ("Una meta", "target", .sav, .meta)
    ]
    var body: some View {
        ZStack(alignment: .bottom) {
            FondoAtenuado()
            VStack(spacing: 0) {
                cabecera
                VStack(spacing: 0) {
                    Grupo {
                        ForEach(items.indices, id: \.self) { i in
                            Button { elegir(items[i].3) } label: {
                                HStack(spacing: 12) {
                                    IconoCuadro(sistema: items[i].1, tinte: items[i].2)
                                    Text(items[i].0).font(.system(size: 16, weight: .medium)).foregroundColor(.ink)
                                    Spacer()
                                    Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundColor(Color.pmut.opacity(0.6))
                                }
                                .padding(.horizontal, 14).padding(.vertical, 12)
                            }
                            .buttonStyle(.plain)
                            if i < items.count - 1 { Divisor() }
                        }
                    }
                    .padding(.horizontal, 16)
                    Color.clear.frame(height: 34)
                }
            }
            .comoHoja(grande: false)
        }
    }
    private var cabecera: some View {
        VStack(spacing: 0) {
            Capsule().fill(Color.line).frame(width: 40, height: 5).padding(.top, 8).padding(.bottom, 10)
            ZStack {
                Text("Agregar").font(.system(size: 17, weight: .bold)).foregroundColor(.ink)
                HStack { Button(action: onClose) { BotonCirculo(icono: "xmark") }.buttonStyle(.plain); Spacer() }
            }
            .padding(.horizontal, 16).padding(.bottom, 14)
        }
    }
}

// Hoja «Nueva cuenta»: formulario funcional (guarda la cuenta al estado).
struct NuevaCuentaView: View {
    @EnvironmentObject var estado: AppEstado
    var onClose: () -> Void = {}
    @State private var nombre = ""
    @State private var banco = ""
    @State private var saldo = ""
    @State private var clase = 0
    private let clases: [(String, String, String, String)] = [
        ("Efectivo", "efectivo", "banknote.fill", "#137d41"),
        ("Banco", "banco", "building.columns.fill", "#398ad6"),
        ("Ahorro", "ahorro", "target", "#825eb9")
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            FondoAtenuado()
            VStack(spacing: 0) {
                CabeceraHojaAcc(titulo: "Nueva cuenta", onClose: onClose, guardar: guardar)
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        VStack(spacing: 6) {
                            SeccionTitulo(texto: "Datos")
                            Grupo {
                                CampoTexto(placeholder: "Nombre (ej. Ahorros)", texto: $nombre)
                                Divisor(sangria: 16)
                                CampoTexto(placeholder: "Banco (opcional)", texto: $banco)
                                Divisor(sangria: 16)
                                CampoTexto(placeholder: "Cuánto tienes ahora", texto: $saldo, numero: true)
                            }
                        }
                        VStack(spacing: 6) {
                            SeccionTitulo(texto: "Tipo")
                            SegmentoPildora(items: clases.map { $0.0 }, sel: $clase)
                        }
                        Color.clear.frame(height: 40)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .comoHoja()
        }
    }

    private func guardar() {
        let n = nombre.trimmingCharacters(in: .whitespaces)
        guard !n.isEmpty else { onClose(); return }
        let c = clases[clase]
        var lb = estado.libreta
        let id = Int(Date().timeIntervalSince1970)
        lb.cuentas.append(Cuenta(id: id, nombre: n, banco: banco.trimmingCharacters(in: .whitespaces),
                                 saldo: Double(saldo.replacingOccurrences(of: ",", with: "")) ?? 0,
                                 color: c.3, clase: c.1, icono: c.2))
        estado.libreta = lb
        onClose()
    }
}

// Hoja «Filtrar»: chooser corto de tipo, hasta el fondo.
struct FiltroSheet: View {
    @State private var sel = 0
    private let items: [(String, String)] = [
        ("Todo", "line.3.horizontal"),
        ("Cuentas", "banknote.fill"),
        ("Tarjetas", "creditcard.fill"),
        ("Préstamos", "hand.raised.fill")
    ]
    var body: some View {
        ZStack(alignment: .bottom) {
            FondoAtenuado()
            VStack(spacing: 0) {
                CabeceraHoja(titulo: "Filtrar")
                VStack(spacing: 0) {
                    Grupo {
                        ForEach(items.indices, id: \.self) { i in
                            HStack(spacing: 12) {
                                IconoCuadro(sistema: items[i].1, tinte: i == sel ? .acc : .pmut)
                                Text(items[i].0).font(.system(size: 16, weight: .medium)).foregroundColor(.ink)
                                Spacer()
                                if i == sel {
                                    Image(systemName: "checkmark").font(.system(size: 15, weight: .bold)).foregroundColor(.acc)
                                }
                            }
                            .padding(.horizontal, 14).padding(.vertical, 12)
                            .onTapGesture { sel = i }
                            if i < items.count - 1 { Divisor() }
                        }
                    }
                    .padding(.horizontal, 16)
                    Color.clear.frame(height: 34)
                }
            }
            .comoHoja(grande: false)
        }
    }
}
