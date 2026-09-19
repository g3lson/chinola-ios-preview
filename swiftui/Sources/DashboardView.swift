import SwiftUI

// Pantalla «Resumen», igual que la app: cabecera con degradado (selector de
// libreta + navegación de mes), el balance grande con la fila ↑ ingresos /
// ↓ gastos, y debajo las tarjetas sobre el fondo crema.
struct DashboardView: View {
    @EnvironmentObject var estado: AppEstado
    var onSelector: () -> Void = {}
    @State private var mesOffset = 0

    var body: some View {
        GeometryReader { geo in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    cabecera(top: geo.safeAreaInsets.top)
                    cuerpo
                    Color.clear.frame(height: 108)
                }
            }
            .background(Color.scr)
            .ignoresSafeArea(.container, edges: .top)
        }
    }

    private var nombreMes: String {
        let cal = Calendar.current
        let d = cal.date(byAdding: .month, value: mesOffset, to: Date()) ?? Date()
        let f = DateFormatter(); f.locale = Locale(identifier: "es"); f.dateFormat = "MMMM"
        return f.string(from: d).capitalized
    }

    // MARK: Cabecera (degradado que cubre la isla dinámica)
    private func cabecera(top: CGFloat) -> some View {
        VStack(spacing: 12) {
            // Selector de libreta (izq) + navegación de mes (der).
            HStack(spacing: 8) {
                Button(action: onSelector) {
                    HStack(spacing: 6) {
                        Image(systemName: "house.fill").font(.system(size: 12, weight: .semibold))
                        Text(estado.libreta.nombre).font(.system(size: 14, weight: .bold)).lineLimit(1)
                        Image(systemName: "chevron.down").font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 13).padding(.vertical, 8)
                    .background(Color.black.opacity(0.16)).clipShape(Capsule())
                }
                .buttonStyle(.plain)
                Spacer(minLength: 6)
                HStack(spacing: 6) {
                    navBtn("chevron.left") { mesOffset -= 1 }
                    Text(nombreMes).font(.system(size: 13, weight: .bold)).foregroundColor(.white).lineLimit(1)
                    navBtn("chevron.right") { if mesOffset < 0 { mesOffset += 1 } }
                }
            }

            VStack(spacing: 6) {
                Text("TE QUEDA ESTE MES").font(.system(size: 11, weight: .heavy)).tracking(0.5)
                    .foregroundColor(Color(hex: 0x0f3d1e).opacity(0.65))
                Text(fmtDinero(estado.balanceMes)).font(.system(size: 42, weight: .heavy))
                    .foregroundColor(Color(hex: 0x0d3a1c)).minimumScaleFactor(0.6).lineLimit(1)
                HStack(spacing: 18) {
                    HStack(spacing: 5) {
                        Image(systemName: "arrow.up").font(.system(size: 12, weight: .heavy)).foregroundColor(Color(hex: 0x0d5a2b))
                        Text(fmtDinero(estado.ingresosMes)).font(.system(size: 15, weight: .heavy)).foregroundColor(Color(hex: 0x0d3a1c))
                    }
                    HStack(spacing: 5) {
                        Image(systemName: "arrow.down").font(.system(size: 12, weight: .heavy)).foregroundColor(Color(hex: 0xb43a2a))
                        Text(fmtDinero(estado.gastosMes)).font(.system(size: 15, weight: .heavy)).foregroundColor(Color(hex: 0x0d3a1c))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, top + 14)
        .padding(.bottom, 20)
        .padding(.horizontal, 16)
        .background(
            LinearGradient(colors: [Color(hex: 0xf0b638), Color(hex: 0xe0a92e), Color(hex: 0x2f8a44), Color(hex: 0x137d41)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 30, bottomTrailingRadius: 30, style: .continuous))
    }

    private func navBtn(_ icono: String, _ tap: @escaping () -> Void) -> some View {
        Button(action: tap) {
            Image(systemName: icono).font(.system(size: 12, weight: .bold)).foregroundColor(.white)
                .frame(width: 30, height: 30).background(Color.black.opacity(0.16)).clipShape(Circle())
        }.buttonStyle(.plain)
    }

    // MARK: Cuerpo (tarjetas)
    private var cuerpo: some View {
        VStack(spacing: 14) {
            if estado.totalCuentas == 0 && estado.libreta.cuentas.isEmpty {
                tarjeta {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Empieza por aquí").font(.system(size: 18, weight: .bold)).foregroundColor(.ink)
                        Text("Dile cuánto tienes ahora mismo y la app empieza a cuadrar sola. No tiene que ser exacto.")
                            .font(.system(size: 14)).foregroundColor(.pmut).fixedSize(horizontal: false, vertical: true)
                        Text("Poner lo que tengo")
                            .font(.system(size: 15, weight: .bold)).foregroundColor(Color(hex: 0x20180a))
                            .frame(maxWidth: .infinity).padding(.vertical, 14)
                            .background(Color.acc).clipShape(RoundedRectangle(cornerRadius: 26))
                            .padding(.top, 2)
                        Text("Lo pongo después").font(.system(size: 14, weight: .semibold)).foregroundColor(.ink)
                            .frame(maxWidth: .infinity).padding(.vertical, 4)
                    }
                }
            }

            // KPIs del mes / patrimonio.
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                kpi("Ingresos del mes", fmtDinero(estado.ingresosMes), .pos, "del mes")
                kpi("Gastos del mes", fmtDinero(estado.gastosMes), .neg, pctGastos)
                kpi("Deuda total", fmtDinero(estado.deudaTotal), Color(hex: 0xe0a92e), "tarjetas + préstamos")
                kpi("Patrimonio", fmtDinero(estado.patrimonio), .ink, "cuentas − deudas")
            }

            // Evolución en el tiempo.
            tarjeta {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Evolución en el tiempo").font(.system(size: 15, weight: .semibold)).foregroundColor(.ink)
                    HStack(spacing: 16) {
                        leyenda(.pos, "Ingresos", fmtDinero(estado.ingresosMes))
                        leyenda(.neg, "Gastos", fmtDinero(estado.gastosMes))
                    }
                    miniGrafico
                }.frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 16)
    }

    private var pctGastos: String {
        guard estado.ingresosMes > 0 else { return "de tus ingresos" }
        return "\(Int((estado.gastosMes / estado.ingresosMes * 100).rounded()))% de tus ingresos"
    }

    private func kpi(_ titulo: String, _ valor: String, _ color: Color, _ detalle: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(titulo).font(.system(size: 14, weight: .medium)).foregroundColor(.pmut)
            Text(valor).font(.system(size: 24, weight: .heavy)).foregroundColor(color).minimumScaleFactor(0.6).lineLimit(1)
            Text(detalle).font(.system(size: 12)).foregroundColor(.pmut).lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(15)
        .background(Color.card).clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.line, lineWidth: 1))
    }

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

    private func leyenda(_ c: Color, _ t: String, _ v: String) -> some View {
        HStack(spacing: 6) {
            Circle().fill(c).frame(width: 9, height: 9)
            Text(t).font(.system(size: 13)).foregroundColor(.pmut)
            Text(v).font(.system(size: 13, weight: .bold)).foregroundColor(.ink)
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
