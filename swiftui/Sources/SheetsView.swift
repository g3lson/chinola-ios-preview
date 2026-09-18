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

// Hoja «Nuevo movimiento» (la que abre el «+»), con el look nativo de iOS:
// cabecera limpia, secciones agrupadas en tarjetas, toggle nativo y filas
// navegables. Fluida, nada se reajusta raro.
struct NuevoMovView: View {
    @State private var tipo = 2
    @State private var repetir = false
    private let tipos = ["Ingreso", "Fijo", "Variable", "Ahorro"]

    var body: some View {
        ZStack(alignment: .bottom) {
            FondoAtenuado()
            hoja
        }
    }

    private var hoja: some View {
        VStack(spacing: 0) {
            // Asa + cabecera.
            Capsule().fill(Color.line).frame(width: 40, height: 5).padding(.top, 8).padding(.bottom, 10)
            HStack {
                circulo("xmark", .ink, Color.soft)
                Spacer()
                Text("Nuevo movimiento").font(.system(size: 17, weight: .bold)).foregroundColor(.ink)
                Spacer()
                circulo("checkmark", Color(hex: 0x20180a), .acc)
            }
            .padding(.horizontal, 16).padding(.bottom, 14)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    // Tipo.
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

                    // Monto.
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

                    // Descripción.
                    Grupo { FilaCampo(placeholder: "Descripción o concepto") }

                    // Cuándo y de dónde.
                    VStack(spacing: 6) {
                        SeccionTitulo(texto: "Cuándo y de dónde")
                        Grupo {
                            FilaNav(icono: "calendar", tinte: .neg, titulo: "Fecha", valor: "18/09/2026")
                            Divisor()
                            FilaNav(icono: "creditcard.fill", tinte: .info, titulo: "Pagado con", valor: "Efectivo")
                        }
                    }

                    // Categoría.
                    VStack(spacing: 6) {
                        SeccionTitulo(texto: "Categoría")
                        Grupo { FilaNav(icono: "tag.fill", tinte: Color(hex: 0xe0a92e), titulo: "Categoría", valor: "Otros") }
                    }

                    // Repetir.
                    VStack(spacing: 6) {
                        Grupo { FilaToggle(icono: "repeat", tinte: .sav, titulo: "Repetir cada mes", on: $repetir) }
                        NotaPie(texto: "Para lo que siempre pagas: renta, luz, colegio.")
                    }

                    // Aire al final para el indicador de inicio del iPhone.
                    Color.clear.frame(height: 40)
                }
                .padding(.horizontal, 16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(
            Color.scr.clipShape(UnevenRoundedRectangle(topLeadingRadius: 28, topTrailingRadius: 28, style: .continuous))
        )
        .ignoresSafeArea(edges: .bottom)
        .padding(.top, 46)   // hoja grande: cubre casi toda la pantalla y llega hasta abajo
    }

    private func circulo(_ icono: String, _ fg: Color, _ bg: Color) -> some View {
        Image(systemName: icono).font(.system(size: 15, weight: .bold)).foregroundColor(fg)
            .frame(width: 34, height: 34).background(bg).clipShape(Circle())
    }
    private func boton(_ icono: String) -> some View {
        Image(systemName: icono).font(.system(size: 17, weight: .bold)).foregroundColor(.ink)
            .frame(width: 42, height: 42).background(Color.soft).clipShape(Circle())
    }
}

// Menú de acciones del «+» (Un movimiento / Una cuenta / Una categoría / Una meta).
struct AccionesMenu: View {
    private let items: [(String, String, Color)] = [
        ("Un movimiento", "arrow.up.arrow.down", .pos),
        ("Una cuenta", "creditcard", .info),
        ("Una categoría", "square.grid.2x2.fill", .pos),
        ("Una meta", "target", .sav)
    ]
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            FondoAtenuado()
            VStack(alignment: .trailing, spacing: 12) {
                ForEach(items.indices, id: \.self) { i in
                    HStack(spacing: 10) {
                        Text(items[i].0).font(.system(size: 15, weight: .bold)).foregroundColor(.ink)
                        Image(systemName: items[i].1).font(.system(size: 14, weight: .semibold))
                            .foregroundColor(items[i].2).frame(width: 30, height: 30)
                            .background(items[i].2.opacity(0.16)).clipShape(Circle())
                    }
                    .padding(.leading, 18).padding(.trailing, 8).padding(.vertical, 8)
                    .background(Color.card).clipShape(Capsule())
                    .shadow(color: .black.opacity(0.14), radius: 10, y: 3)
                }
                Image(systemName: "xmark").font(.system(size: 22, weight: .semibold)).foregroundColor(.ink)
                    .frame(width: 58, height: 58).background(Color.card).clipShape(Circle())
                    .shadow(color: .black.opacity(0.2), radius: 10, y: 4)
            }
            .padding(.trailing, 18).padding(.bottom, 96)
        }
    }
}
