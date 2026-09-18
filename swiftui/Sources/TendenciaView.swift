import SwiftUI

// Pantalla «Tendencia» (el botón de la tarjeta de Patrimonio): gráfico de área
// del patrimonio mes a mes y la lista con el cambio de cada mes. Datos reales.
struct TendenciaView: View {
    @EnvironmentObject var estado: AppEstado
    var onClose: () -> Void = {}

    var body: some View {
        let puntos = estado.tendencia()
        return VStack(spacing: 0) {
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

            HStack(spacing: 16) {
                Image(systemName: "chevron.left").font(.system(size: 13, weight: .bold)).foregroundColor(.pmut)
                Text("Últimos 12 meses").font(.system(size: 15, weight: .semibold)).foregroundColor(.ink)
                Image(systemName: "chevron.right").font(.system(size: 13, weight: .bold)).foregroundColor(.pmut)
            }
            .padding(.vertical, 8)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Patrimonio").font(.system(size: 14, weight: .semibold)).foregroundColor(.info)
                            Spacer()
                            Text(fmtDinero(estado.patrimonio)).font(.system(size: 14, weight: .heavy)).foregroundColor(.pos)
                        }
                        GraficoArea(valores: puntos.map { $0.valor }).frame(height: 130)
                    }
                    .tarjeta()

                    VStack(spacing: 0) {
                        let filas = Array(puntos.reversed())
                        ForEach(filas.indices, id: \.self) { i in
                            HStack {
                                Text(filas[i].label).font(.system(size: 15, weight: .semibold)).foregroundColor(.ink)
                                Spacer()
                                VStack(alignment: .trailing, spacing: 1) {
                                    Text(fmtDinero(filas[i].valor)).font(.system(size: 15, weight: .heavy)).foregroundColor(.ink)
                                    Text((filas[i].cambio >= 0 ? "+ " : "− ") + fmtDinero(filas[i].cambio))
                                        .font(.system(size: 11.5, weight: .bold))
                                        .foregroundColor(filas[i].cambio >= 0 ? .pos : .neg)
                                }
                            }
                            .padding(.vertical, 12)
                            if i < filas.count - 1 { Divider().overlay(Color.line) }
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

// Área del patrimonio a partir de una serie de valores (viejo → nuevo).
struct GraficoArea: View {
    var valores: [Double] = []
    var body: some View {
        GeometryReader { g in
            let w = g.size.width, h = g.size.height
            let vals = valores.isEmpty ? [0, 0] : valores
            let maxV = max(vals.max() ?? 1, 1)
            let minV = min(vals.min() ?? 0, 0)
            let rango = max(maxV - minV, 1)
            let puntos: [CGPoint] = vals.enumerated().map { i, v in
                let x = vals.count > 1 ? w * CGFloat(i) / CGFloat(vals.count - 1) : 0
                let y = h - (h - 8) * CGFloat((v - minV) / rango) - 4
                return CGPoint(x: x, y: y)
            }
            ZStack {
                VStack(spacing: 0) {
                    ForEach(0..<4, id: \.self) { _ in
                        Rectangle().fill(Color.line).frame(height: 1); Spacer()
                    }
                }
                Path { p in
                    guard let first = puntos.first else { return }
                    p.move(to: CGPoint(x: first.x, y: h))
                    p.addLine(to: first)
                    for pt in puntos.dropFirst() { p.addLine(to: pt) }
                    p.addLine(to: CGPoint(x: puntos.last!.x, y: h))
                    p.closeSubpath()
                }
                .fill(LinearGradient(colors: [Color.acc.opacity(0.30), Color.acc.opacity(0.02)], startPoint: .top, endPoint: .bottom))
                Path { p in
                    guard let first = puntos.first else { return }
                    p.move(to: first)
                    for pt in puntos.dropFirst() { p.addLine(to: pt) }
                }
                .stroke(Color.acc, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            }
        }
    }
}
