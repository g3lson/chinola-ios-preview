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

// Botón circular de la cabecera (× / ✓).
struct BotonCirculo: View {
    let icono: String
    var fg: Color = .ink
    var bg: Color = Color.soft
    var body: some View {
        Image(systemName: icono).font(.system(size: 15, weight: .bold)).foregroundColor(fg)
            .frame(width: 34, height: 34).background(bg).clipShape(Circle())
    }
}

// Cabecera fija de una hoja: asa + (× / título / ✓). Queda fuera del scroll, así
// que no se mueve ni se tapa al desplazar.
struct CabeceraHoja: View {
    let titulo: String
    var conCheck: Bool = false
    var body: some View {
        VStack(spacing: 0) {
            Capsule().fill(Color.line).frame(width: 40, height: 5).padding(.top, 8).padding(.bottom, 10)
            HStack {
                BotonCirculo(icono: "xmark")
                Spacer()
                Text(titulo).font(.system(size: 17, weight: .bold)).foregroundColor(.ink)
                Spacer()
                if conCheck {
                    BotonCirculo(icono: "checkmark", fg: Color(hex: 0x20180a), bg: .acc)
                } else {
                    Color.clear.frame(width: 34, height: 34)
                }
            }
            .padding(.horizontal, 16).padding(.bottom, 14)
        }
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

// Hoja «Nuevo movimiento»: grande, con el look nativo de iOS.
struct NuevoMovView: View {
    @State private var tipo = 2
    @State private var repetir = false
    private let tipos = ["Ingreso", "Fijo", "Variable", "Ahorro"]

    var body: some View {
        ZStack(alignment: .bottom) {
            FondoAtenuado()
            VStack(spacing: 0) {
                CabeceraHoja(titulo: "Nuevo movimiento", conCheck: true)
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        HStack(spacing: 4) {
                            ForEach(tipos.indices, id: \.self) { i in
                                Text(tipos[i])
                                    .font(.system(size: 13.5, weight: i == tipo ? .bold : .semibold))
                                    .foregroundColor(i == tipo ? .white : .pmut)
                                    .frame(maxWidth: .infinity).padding(.vertical, 9)
                                    .background(i == tipo ? Color.side : Color.clear)
                                    .clipShape(Capsule())
                                    .onTapGesture { tipo = i }
                            }
                        }
                        .padding(4).background(Color.soft).clipShape(Capsule())

                        Grupo {
                            HStack {
                                boton("minus")
                                Spacer()
                                VStack(spacing: 1) {
                                    Text("MONTO").font(.system(size: 11, weight: .semibold)).tracking(0.4).foregroundColor(.pmut)
                                    Text("DOP 0").font(.system(size: 30, weight: .heavy)).foregroundColor(.ink)
                                }
                                Spacer()
                                boton("plus")
                            }
                            .padding(.horizontal, 12).padding(.vertical, 12)
                        }

                        Grupo { FilaCampo(placeholder: "Descripción o concepto") }

                        VStack(spacing: 6) {
                            SeccionTitulo(texto: "Cuándo y de dónde")
                            Grupo {
                                FilaNav(icono: "calendar", tinte: .neg, titulo: "Fecha", valor: "18/09/2026")
                                Divisor()
                                FilaNav(icono: "creditcard.fill", tinte: .info, titulo: "Pagado con", valor: "Efectivo")
                            }
                        }

                        VStack(spacing: 6) {
                            SeccionTitulo(texto: "Categoría")
                            Grupo { FilaNav(icono: "tag.fill", tinte: Color(hex: 0xe0a92e), titulo: "Categoría", valor: "Otros") }
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
    }

    private func boton(_ icono: String) -> some View {
        Image(systemName: icono).font(.system(size: 17, weight: .bold)).foregroundColor(.ink)
            .frame(width: 42, height: 42).background(Color.soft).clipShape(Circle())
    }
}

// Hoja «Agregar» (la del «+»): un chooser corto, hasta el fondo.
struct AccionesMenu: View {
    private let items: [(String, String, Color)] = [
        ("Un movimiento", "arrow.up.arrow.down", .pos),
        ("Una cuenta", "banknote.fill", .info),
        ("Una tarjeta", "creditcard.fill", .neg),
        ("Una categoría", "tag.fill", Color(hex: 0xe0a92e)),
        ("Una meta", "target", .sav)
    ]
    var body: some View {
        ZStack(alignment: .bottom) {
            FondoAtenuado()
            VStack(spacing: 0) {
                CabeceraHoja(titulo: "Agregar")
                VStack(spacing: 0) {
                    Grupo {
                        ForEach(items.indices, id: \.self) { i in
                            HStack(spacing: 12) {
                                IconoCuadro(sistema: items[i].1, tinte: items[i].2)
                                Text(items[i].0).font(.system(size: 16, weight: .medium)).foregroundColor(.ink)
                                Spacer()
                                Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundColor(Color.pmut.opacity(0.6))
                            }
                            .padding(.horizontal, 14).padding(.vertical, 12)
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

// Hoja «Nueva cuenta»: formulario con el look nativo agrupado.
struct NuevaCuentaView: View {
    @State private var enTarjeta = false
    var body: some View {
        ZStack(alignment: .bottom) {
            FondoAtenuado()
            VStack(spacing: 0) {
                CabeceraHoja(titulo: "Nueva cuenta", conCheck: true)
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        VStack(spacing: 6) {
                            SeccionTitulo(texto: "Datos")
                            Grupo {
                                FilaCampo(placeholder: "Nombre (ej. Ahorros)")
                                Divisor(sangria: 16)
                                FilaCampo(placeholder: "Banco (opcional)")
                                Divisor(sangria: 16)
                                FilaCampo(placeholder: "Cuánto tienes ahora")
                            }
                        }
                        VStack(spacing: 6) {
                            SeccionTitulo(texto: "Icono y color")
                            Grupo {
                                FilaNav(icono: "banknote.fill", tinte: .pos, titulo: "Icono", valor: "Efectivo")
                                Divisor()
                                FilaNav(icono: "paintpalette.fill", tinte: .sav, titulo: "Color", valor: "Verde")
                            }
                        }
                        VStack(spacing: 6) {
                            Grupo { FilaToggle(icono: "star.fill", tinte: Color(hex: 0xe0a92e), titulo: "Cuenta principal", on: $enTarjeta) }
                            NotaPie(texto: "La principal es la que se usa por defecto al registrar.")
                        }
                        Color.clear.frame(height: 40)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .comoHoja()
        }
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
