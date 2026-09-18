import SwiftUI

// Pantalla «Plan»: segmentos (Presupuesto/Metas), la barra del total y la lista
// de categorías con su tope. Calcada de la app.
struct PlanView: View {
    @State private var seg: Int
    init(seg: Int? = nil) {
        let env = Int(ProcessInfo.processInfo.environment["CHINOLA_PLANSEG"] ?? "")
        _seg = State(initialValue: seg ?? env ?? 0)
    }

    private struct Cat { let nombre: String; let icono: String; let tinte: Color }
    private let cats: [Cat] = [
        .init(nombre: "Vivienda", icono: "house.fill", tinte: .info),
        .init(nombre: "Alimentación", icono: "fork.knife", tinte: Color(hex: 0xe0a92e)),
        .init(nombre: "Servicios", icono: "bolt.fill", tinte: Color(hex: 0x1fa9a0)),
        .init(nombre: "Transporte", icono: "car.fill", tinte: .neg),
        .init(nombre: "Educación", icono: "graduationcap.fill", tinte: .sav),
        .init(nombre: "Salud", icono: "cross.case.fill", tinte: .pos)
    ]

    var body: some View {
        GeometryReader { geo in
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                CabeceraFina(topInset: geo.safeAreaInsets.top)
                Group {
                Segmentos(items: ["Presupuesto", "Metas"], sel: $seg)

                if seg == 0 {
                    // Total presupuestado.
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("DOP 0").font(.system(size: 26, weight: .heavy)).foregroundColor(.pos)
                            Spacer()
                            Text("de DOP 0").font(.system(size: 14)).foregroundColor(.pmut)
                        }
                        Capsule().fill(Color.line).frame(height: 8)
                    }.tarjeta()

                    VStack(spacing: 12) {
                        SeccionHeader(titulo: "Categorías", accion: "Categoría")
                        VStack(spacing: 0) {
                            ForEach(cats.indices, id: \.self) { i in
                                fila(cats[i])
                                if i < cats.count - 1 {
                                    Divider().overlay(Color.line).padding(.leading, 52)
                                }
                            }
                        }.tarjeta()
                    }
                } else {
                    SeccionHeader(titulo: "Tus metas", accion: "Meta")
                    VacioCard(titulo: "",
                              detalle: "Ponte una meta de ahorro y ve cuánto te falta cada mes.")
                }
                }
                .padding(.horizontal, 8)

                Color.clear.frame(height: 108)
            }
        }
        .background(Color.scr)
        .ignoresSafeArea(.container, edges: .top)
        }
    }

    private func fila(_ c: Cat) -> some View {
        HStack(spacing: 12) {
            Image(systemName: c.icono)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(c.tinte)
                .frame(width: 40, height: 40)
                .background(c.tinte.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(c.nombre).font(.system(size: 15.5, weight: .semibold)).foregroundColor(.ink)
                    Spacer()
                    Text("DOP 0").font(.system(size: 14.5, weight: .heavy)).foregroundColor(.pos)
                }
                Capsule().fill(Color.line).frame(height: 5)
                Text("DOP 0 de sin tope").font(.system(size: 12)).foregroundColor(.pmut)
            }
            Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundColor(.pmut)
        }
        .padding(.vertical, 11)
    }
}
