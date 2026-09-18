import SwiftUI

// El Dashboard (Resumen) en SwiftUI. Datos de ejemplo por ahora.
struct DashboardView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 13) {

                // Título grande + avatar (patrón iOS).
                HStack {
                    Text("Personal")
                        .font(.system(size: 30, weight: .heavy, design: .rounded))
                        .foregroundColor(.ink)
                    Spacer()
                    Circle()
                        .fill(LinearGradient(colors: [Color(hex: 0xf0c34a), Color(hex: 0xd98f1e)],
                                             startPoint: .top, endPoint: .bottom))
                        .frame(width: 34, height: 34)
                        .overlay(Text("GR").font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(hex: 0x3a2c12)))
                }
                .padding(.top, 8)

                // Cabecera flotante con degradado.
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        capsule
                        Spacer()
                        HStack(spacing: 8) {
                            arrow("chevron.left")
                            Text("Septiembre").font(.system(size: 12, weight: .bold))
                            arrow("chevron.right")
                        }
                    }
                    Text("TE QUEDA ESTE MES")
                        .font(.system(size: 10, weight: .heavy))
                        .tracking(0.8)
                        .foregroundColor(Color(hex: 0x2b2010).opacity(0.7))
                    Text("RD$12,300")
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(hex: 0x1c3a12))
                    HStack(spacing: 16) {
                        miniStat("arrow.up", "RD$72,000", Color(hex: 0x1c3a12))
                        miniStat("arrow.down", "RD$51,700", Color(hex: 0x5a2418))
                    }
                    .font(.system(size: 12, weight: .semibold))
                }
                .padding(14)
                .background(LinearGradient.chinola)
                .cornerRadius(24)
                .shadow(color: Color(hex: 0x8a5a10).opacity(0.35), radius: 14, y: 6)

                // KPIs.
                HStack(spacing: 8) {
                    kpi("Ingresos", "72k", .pos)
                    kpi("Gastos", "51.7k", .neg)
                    kpi("Ahorro", "8k", .sav)
                }

                // Gastos por categoría.
                VStack(alignment: .leading, spacing: 11) {
                    Text("Gastos por categoría")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.ink)
                    catRow("house.fill", "Vivienda", "RD$18,000", 1.0, .info)
                    catRow("fork.knife", "Alimentación", "RD$11,500", 0.64, .acc)
                    catRow("graduationcap.fill", "Educación", "RD$6,500", 0.36, .sav)
                    catRow("bolt.fill", "Servicios", "RD$3,700", 0.21, .pos)
                }
                .padding(13)
                .background(Color.card)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.line, lineWidth: 1))
                .cornerRadius(16)

                Color.clear.frame(height: 96)   // espacio para la barra
            }
            .padding(.horizontal, 14)
        }
        .background(Color.scr)
    }

    // MARK: - piezas

    private var capsule: some View {
        HStack(spacing: 7) {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(hex: 0x2c8f52))
                .frame(width: 20, height: 20)
                .overlay(Image(systemName: "house.fill").font(.system(size: 10)).foregroundColor(.white))
            Text("Personal").font(.system(size: 12, weight: .bold))
            Image(systemName: "chevron.down").font(.system(size: 9, weight: .bold)).opacity(0.7)
        }
        .foregroundColor(Color(hex: 0x2b2010))
        .padding(.vertical, 5).padding(.horizontal, 9)
        .background(Color.black.opacity(0.12))
        .clipShape(Capsule())
    }

    private func arrow(_ name: String) -> some View {
        Image(systemName: name)
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(Color(hex: 0x2b2010))
            .frame(width: 26, height: 26)
            .background(Color.black.opacity(0.12))
            .clipShape(Circle())
    }

    private func miniStat(_ icon: String, _ text: String, _ color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.system(size: 10, weight: .bold))
            Text(text)
        }
        .foregroundColor(color)
    }

    private func kpi(_ label: String, _ value: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label.uppercased())
                .font(.system(size: 8, weight: .heavy)).tracking(0.5)
                .foregroundColor(.pmut)
            Text(value)
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(9)
        .background(Color.card)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.line, lineWidth: 1))
        .cornerRadius(12)
    }

    private func catRow(_ icon: String, _ name: String, _ amount: String, _ pct: CGFloat, _ color: Color) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 9) {
                RoundedRectangle(cornerRadius: 8).fill(color).frame(width: 24, height: 24)
                    .overlay(Image(systemName: icon).font(.system(size: 12)).foregroundColor(.white))
                Text(name).font(.system(size: 12, weight: .semibold)).foregroundColor(.ink)
                Spacer()
                Text(amount).font(.system(size: 11, weight: .heavy, design: .rounded)).foregroundColor(.ink)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.line)
                    Capsule().fill(color).frame(width: geo.size.width * pct)
                }
            }
            .frame(height: 5)
        }
    }
}
