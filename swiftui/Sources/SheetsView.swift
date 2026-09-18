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

// Hoja «Nuevo movimiento» (la que abre el «+»), calcada de la app.
struct NuevoMovView: View {
    @State private var tipo = 2
    @State private var cat = 2
    @State private var repetir = false
    private let tipos = ["Ingreso", "Fijo", "Variable", "Ahorro"]
    private let cats = ["Personal", "Ahorro", "Otros"]

    var body: some View {
        ZStack(alignment: .bottom) {
            FondoAtenuado()
            hoja
        }
    }

    private var hoja: some View {
        VStack(spacing: 16) {
            Capsule().fill(Color.line).frame(width: 40, height: 5).padding(.top, 8)

            HStack {
                circulo("xmark")
                Spacer()
                Text("Nuevo movimiento").font(.system(size: 17, weight: .bold)).foregroundColor(.ink)
                Spacer()
                circulo("checkmark")
            }

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
            VStack(spacing: 10) {
                Text("MONTO").font(.system(size: 12, weight: .heavy)).tracking(0.5).foregroundColor(.pmut)
                HStack {
                    paso("minus")
                    Spacer()
                    Text("0").font(.system(size: 34, weight: .heavy)).foregroundColor(.ink)
                    Spacer()
                    paso("plus")
                }
            }

            campo(titulo: "DESCRIPCIÓN") {
                Text("Descripción").font(.system(size: 15)).foregroundColor(.pmut)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 15).padding(.vertical, 13)
                    .background(Color.soft).clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            campo(titulo: "CATEGORÍA") {
                HStack(spacing: 8) {
                    ForEach(cats.indices, id: \.self) { i in
                        Text(cats[i]).font(.system(size: 13.5, weight: .semibold))
                            .foregroundColor(i == cat ? .ink : .pmut)
                            .padding(.horizontal, 14).padding(.vertical, 9)
                            .background(Color.card)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(i == cat ? Color.acc : Color.line, lineWidth: i == cat ? 2 : 1))
                            .onTapGesture { cat = i }
                    }
                    Spacer(minLength: 0)
                }
            }

            campo(titulo: "CUÁNDO Y DE DÓNDE") {
                VStack(spacing: 10) {
                    fila("calendar", "18/09/2026")
                    fila("creditcard", "Efectivo")
                }
            }

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Repetir cada mes").font(.system(size: 15, weight: .bold)).foregroundColor(.ink)
                    Text("Para lo que siempre pagas: renta, luz, colegio.")
                        .font(.system(size: 12.5)).foregroundColor(.pmut).fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 8)
                ZStack(alignment: repetir ? .trailing : .leading) {
                    Capsule().fill(repetir ? Color.acc : Color.line).frame(width: 46, height: 28)
                    Circle().fill(.white).frame(width: 22, height: 22).padding(3)
                }.onTapGesture { repetir.toggle() }
            }
        }
        .padding(.horizontal, 16).padding(.bottom, 24)
        .frame(maxWidth: .infinity)
        .background(Color.card)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
    }

    private func circulo(_ icono: String) -> some View {
        Image(systemName: icono).font(.system(size: 15, weight: .bold)).foregroundColor(.ink)
            .frame(width: 34, height: 34).background(Color.soft).clipShape(Circle())
    }
    private func paso(_ icono: String) -> some View {
        Image(systemName: icono).font(.system(size: 18, weight: .bold)).foregroundColor(.ink)
            .frame(width: 44, height: 44).background(Color.soft).clipShape(Circle())
    }
    private func fila(_ icono: String, _ txt: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icono).font(.system(size: 15, weight: .medium)).foregroundColor(.pmut).frame(width: 22)
            Text(txt).font(.system(size: 15)).foregroundColor(.ink)
            Spacer()
            Image(systemName: "chevron.down").font(.system(size: 12, weight: .semibold)).foregroundColor(.pmut)
        }
        .padding(.horizontal, 14).padding(.vertical, 13)
        .background(Color.soft).clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
    private func campo<C: View>(titulo: String, @ViewBuilder _ c: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(titulo).font(.system(size: 12, weight: .heavy)).tracking(0.4).foregroundColor(.pmut)
            c()
        }.frame(maxWidth: .infinity, alignment: .leading)
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
