import SwiftUI

// Pantalla «Resumen», calcada de la que ya trae la app: cabecera verde con el
// selector de libreta centrado, el balance grande, los chips de meses; y debajo
// las tarjetas sobre el fondo crema. Misma disposición, hecha en nativo.
struct DashboardView: View {
    private let meses = ["Jul", "Ago", "Sep", "Oct", "Rango"]
    @State private var mesSel = 2

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                cabecera
                cuerpo
                Color.clear.frame(height: 96)   // aire para el «+» y la barra
            }
        }
        .background(Color.scr)
        .ignoresSafeArea(edges: .top)
    }

    // MARK: Cabecera (banda verde)
    private var cabecera: some View {
        VStack(spacing: 10) {
            // Selector de libreta, centrado.
            HStack(spacing: 7) {
                Image(systemName: "house.fill").font(.system(size: 12, weight: .semibold))
                Text("Personal").font(.system(size: 15, weight: .semibold))
                Image(systemName: "chevron.down").font(.system(size: 11, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 15).padding(.vertical, 8)
            .background(Color.white.opacity(0.14))
            .clipShape(Capsule())
            .padding(.top, 8)

            // Balance del mes.
            Text("DOP 0")
                .font(.system(size: 40, weight: .heavy))
                .foregroundColor(.acc)
            Text("te queda este mes")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.72))

            // Chips de meses.
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(meses.enumerated()), id: \.offset) { i, m in
                        Text(m)
                            .font(.system(size: 13.5, weight: .semibold))
                            .foregroundColor(i == mesSel ? Color(hex: 0x20180a) : .white.opacity(0.9))
                            .padding(.horizontal, 15).padding(.vertical, 8)
                            .background(i == mesSel ? Color.acc : Color.white.opacity(0.12))
                            .clipShape(Capsule())
                            .onTapGesture { mesSel = i }
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.top, 2)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 52)          // hueco de la barra de estado
        .padding(.bottom, 18)
        .background(Color.side)
    }

    // MARK: Cuerpo (tarjetas)
    private var cuerpo: some View {
        VStack(spacing: 14) {
            // Empieza aquí.
            tarjeta {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Empieza aquí").font(.system(size: 18, weight: .bold)).foregroundColor(.ink)
                    Text("Dile cuánto tienes ahora mismo y la app empieza a sumar sola. No tiene que ser exacto.")
                        .font(.system(size: 14)).foregroundColor(.pmut).fixedSize(horizontal: false, vertical: true)
                    Button {} label: {
                        Text("Ingresar lo que tengo")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color(hex: 0x20180a))
                            .frame(maxWidth: .infinity).padding(.vertical, 14)
                            .background(Color.acc).clipShape(RoundedRectangle(cornerRadius: 26))
                    }
                    .padding(.top, 2)
                    Text("Lo hago luego")
                        .font(.system(size: 14, weight: .semibold)).foregroundColor(.ink)
                        .frame(maxWidth: .infinity).padding(.vertical, 4)
                }
            }

            // Balance del mes.
            tarjeta {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Balance del mes").font(.system(size: 14, weight: .medium)).foregroundColor(.pmut)
                    Text("DOP 0").font(.system(size: 30, weight: .heavy)).foregroundColor(.ink)
                    Text("disponible este mes").font(.system(size: 13)).foregroundColor(.pmut)
                }.frame(maxWidth: .infinity, alignment: .leading)
            }

            // Gastos por categoría.
            tarjeta {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Gastos por categoría").font(.system(size: 15, weight: .semibold)).foregroundColor(.ink)
                    Button {} label: {
                        Text("Ver el presupuesto")
                            .font(.system(size: 14, weight: .bold)).foregroundColor(.ink)
                            .frame(maxWidth: .infinity).padding(.vertical, 13)
                            .background(Color.soft).clipShape(RoundedRectangle(cornerRadius: 22))
                    }
                }.frame(maxWidth: .infinity, alignment: .leading)
            }

            // Ingresos y gastos (con mini gráfico).
            tarjeta {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Ingresos y gastos").font(.system(size: 15, weight: .semibold)).foregroundColor(.ink)
                        Spacer()
                        Text("6 m").font(.system(size: 13)).foregroundColor(.pmut)
                    }
                    HStack(spacing: 16) {
                        leyenda(.pos, "Ingresos")
                        leyenda(.neg, "Gastos")
                    }
                    miniGrafico
                }.frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 16)
    }

    // Un par de barras tenues, como el gráfico vacío del arranque.
    private var miniGrafico: some View {
        HStack(alignment: .bottom, spacing: 10) {
            ForEach(0..<6, id: \.self) { _ in
                HStack(alignment: .bottom, spacing: 3) {
                    RoundedRectangle(cornerRadius: 3).fill(Color.pos.opacity(0.18)).frame(width: 10, height: 14)
                    RoundedRectangle(cornerRadius: 3).fill(Color.neg.opacity(0.18)).frame(width: 10, height: 14)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 56, alignment: .bottom)
        .overlay(Rectangle().fill(Color.line).frame(height: 1), alignment: .bottom)
    }

    private func leyenda(_ c: Color, _ t: String) -> some View {
        HStack(spacing: 6) {
            Circle().fill(c).frame(width: 9, height: 9)
            Text(t).font(.system(size: 13)).foregroundColor(.pmut)
        }
    }

    private func tarjeta<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content()
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.card)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.line, lineWidth: 1))
    }
}
