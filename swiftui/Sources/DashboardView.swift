import SwiftUI

// Pantalla «Resumen», calcada de la que ya trae la app: cabecera verde con el
// selector de libreta centrado, el balance grande, los chips de meses; y debajo
// las tarjetas sobre el fondo crema. Misma disposición, hecha en nativo.
struct DashboardView: View {
    @EnvironmentObject var estado: AppEstado
    var onSelector: () -> Void = {}
    private let meses = ["Jul", "Ago", "Sep", "Oct", "Rango"]
    @State private var mesSel = 2

    var body: some View {
        GeometryReader { geo in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    cabecera(top: geo.safeAreaInsets.top)
                    cuerpo
                    Color.clear.frame(height: 108)  // aire para el «+» y la barra flotante
                }
            }
            .background(Color.scr)
            .ignoresSafeArea(.container, edges: .top)
        }
    }

    // MARK: Cabecera (banda verde que cubre la isla dinámica)
    private func cabecera(top: CGFloat) -> some View {
        VStack(spacing: 10) {
            // Selector de libreta, centrado.
            Button(action: onSelector) {
                HStack(spacing: 7) {
                    Image(systemName: "house.fill").font(.system(size: 12, weight: .semibold))
                    Text(estado.libreta.nombre).font(.system(size: 15, weight: .semibold))
                    Image(systemName: "chevron.down").font(.system(size: 11, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 15).padding(.vertical, 8)
                .background(Color.white.opacity(0.14))
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            // Balance del mes.
            Text((estado.balanceMes >= 0 ? "" : "− ") + fmtDinero(estado.balanceMes))
                .font(.system(size: 40, weight: .heavy))
                .foregroundColor(.acc)
            Text("te queda este mes")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.72))

            // Chips de meses, centrados.
            HStack(spacing: 7) {
                ForEach(Array(meses.enumerated()), id: \.offset) { i, m in
                    Text(m)
                        .font(.system(size: 13.5, weight: .semibold))
                        .foregroundColor(i == mesSel ? Color(hex: 0x20180a) : .white.opacity(0.9))
                        .padding(.horizontal, 13).padding(.vertical, 8)
                        .background(i == mesSel ? Color.acc : Color.white.opacity(0.12))
                        .clipShape(Capsule())
                        .onTapGesture { mesSel = i }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 2)
        }
        .frame(maxWidth: .infinity)
        // Sube a cubrir la isla dinámica: el contenido baja por debajo de ella
        // (top + 16) y solo se redondea por abajo, como una sola tarjeta.
        .padding(.top, top + 16)
        .padding(.bottom, 18)
        .padding(.horizontal, 12)
        .background(Color.side)
        .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 30, bottomTrailingRadius: 30, style: .continuous))
    }

    // MARK: Cuerpo (tarjetas)
    private var cuerpo: some View {
        VStack(spacing: 14) {
            // Rejilla de KPIs del mes / patrimonio, como en el web.
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                kpi("Ingresos del mes", fmtDinero(estado.ingresosMes), .pos, "del mes")
                kpi("Gastos del mes", fmtDinero(estado.gastosMes), .neg, pctGastos)
                kpi("Deuda total", fmtDinero(estado.deudaTotal), Color(hex: 0xe0a92e), "tarjetas + préstamos")
                kpi("Patrimonio", fmtDinero(estado.patrimonio), .ink, "cuentas − deudas")
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

    private var pctGastos: String {
        guard estado.ingresosMes > 0 else { return "de tus ingresos" }
        return "\(Int((estado.gastosMes / estado.ingresosMes * 100).rounded()))% de tus ingresos"
    }

    // Tarjeta de KPI: rótulo, cifra grande de color y detalle.
    private func kpi(_ titulo: String, _ valor: String, _ color: Color, _ detalle: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(titulo).font(.system(size: 14, weight: .medium)).foregroundColor(.pmut)
            Text(valor).font(.system(size: 24, weight: .heavy)).foregroundColor(color).minimumScaleFactor(0.6).lineLimit(1)
            Text(detalle).font(.system(size: 12)).foregroundColor(.pmut).lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(15)
        .background(Color.card)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.line, lineWidth: 1))
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
