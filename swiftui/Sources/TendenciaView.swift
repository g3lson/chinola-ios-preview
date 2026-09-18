import SwiftUI

// Pantalla «Tendencia» (el botón de la tarjeta de Patrimonio): el rango de meses,
// un gráfico de área y la lista mes a mes. Estilo Chinola.
struct TendenciaView: View {
    var onClose: () -> Void = {}
    private let meses = ["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"]

    var body: some View {
        VStack(spacing: 0) {
            // Barra: × y título.
            ZStack {
                Text("Tendencia").font(.system(size: 17, weight: .bold)).foregroundColor(.ink)
                HStack {
                    Button(action: onClose) {
                        Image(systemName: "xmark").font(.system(size: 16, weight: .bold)).foregroundColor(.ink)
                            .frame(width: 38, height: 38).background(Color.soft).clipShape(Circle())
                    }
                    Spacer()
                }
            }
            .padding(.horizontal, 12).padding(.top, 8).padding(.bottom, 4)

            // Rango.
            HStack(spacing: 16) {
                Image(systemName: "chevron.left").font(.system(size: 13, weight: .bold)).foregroundColor(.pmut)
                Text("2026.01 ~ 2026.12").font(.system(size: 15, weight: .semibold)).foregroundColor(.ink)
                Image(systemName: "chevron.right").font(.system(size: 13, weight: .bold)).foregroundColor(.pmut)
            }
            .padding(.vertical, 8)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    // Gráfico.
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            HStack(spacing: 5) {
                                Text("Patrimonio").font(.system(size: 14, weight: .semibold)).foregroundColor(.info)
                                Image(systemName: "chevron.down").font(.system(size: 11, weight: .bold)).foregroundColor(.info)
                            }
                            Spacer()
                            Text("DOP 0").font(.system(size: 14, weight: .heavy)).foregroundColor(.pos)
                        }
                        GraficoArea().frame(height: 120)
                    }
                    .tarjeta()

                    // Lista mes a mes.
                    VStack(spacing: 0) {
                        ForEach(meses.indices.reversed(), id: \.self) { i in
                            HStack {
                                Text("\(meses[i]) 2026").font(.system(size: 15, weight: .semibold)).foregroundColor(.ink)
                                Spacer()
                                Text("DOP 0").font(.system(size: 15, weight: .heavy)).foregroundColor(.ink)
                            }
                            .padding(.vertical, 13)
                            if i > 0 { Divider().overlay(Color.line) }
                        }
                    }
                    .tarjeta()

                    Color.clear.frame(height: 24)
                }
                .padding(.horizontal, 12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.scr)
    }
}

// Un área tenue plana (datos en cero), como el gráfico vacío del arranque.
struct GraficoArea: View {
    var body: some View {
        GeometryReader { g in
            let w = g.size.width, h = g.size.height
            ZStack {
                // Rejilla.
                VStack(spacing: 0) {
                    ForEach(0..<4, id: \.self) { _ in
                        Rectangle().fill(Color.line).frame(height: 1)
                        Spacer()
                    }
                }
                // Línea plana con relleno.
                Path { p in
                    p.move(to: CGPoint(x: 0, y: h * 0.5))
                    p.addLine(to: CGPoint(x: w, y: h * 0.5))
                    p.addLine(to: CGPoint(x: w, y: h))
                    p.addLine(to: CGPoint(x: 0, y: h))
                    p.closeSubpath()
                }
                .fill(LinearGradient(colors: [Color.acc.opacity(0.28), Color.acc.opacity(0.02)],
                                     startPoint: .top, endPoint: .bottom))
                Path { p in
                    p.move(to: CGPoint(x: 0, y: h * 0.5))
                    p.addLine(to: CGPoint(x: w, y: h * 0.5))
                }
                .stroke(Color.acc, style: StrokeStyle(lineWidth: 2, lineCap: .round))
            }
        }
    }
}
