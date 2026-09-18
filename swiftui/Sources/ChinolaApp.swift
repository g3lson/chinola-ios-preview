import SwiftUI

@main
struct ChinolaApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.dark)
        }
    }
}

// La raíz: el contenido con la barra inferior nativa (4 pestañas + «+» elevado).
struct RootView: View {
    @State private var tab = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.scr.ignoresSafeArea()

            DashboardView()

            BottomBar(tab: $tab)
        }
    }
}

// Barra inferior estilo iOS: iconos SF, «+» central elevado que rompe la barra.
struct BottomBar: View {
    @Binding var tab: Int

    var body: some View {
        ZStack(alignment: .top) {
            HStack(spacing: 0) {
                item(0, "square.grid.2x2.fill", "Resumen")
                item(1, "arrow.left.arrow.right", "Movs")
                Spacer().frame(maxWidth: .infinity)   // hueco del «+»
                item(2, "creditcard.fill", "Cuentas")
                item(3, "chart.pie.fill", "Plan")
            }
            .padding(.horizontal, 10)
            .padding(.top, 10)
            .padding(.bottom, 6)
            .background(
                Color.navbg
                    .overlay(Rectangle().fill(Color.line).frame(height: 0.5), alignment: .top)
                    .ignoresSafeArea(edges: .bottom)
            )

            Button {
                tab = -1
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 23, weight: .semibold))
                    .foregroundColor(Color(hex: 0x20180a))
                    .frame(width: 56, height: 56)
                    .background(Color.acc)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.scr, lineWidth: 5))
                    .shadow(color: .black.opacity(0.45), radius: 8, y: 4)
            }
            .offset(y: -24)
        }
    }

    private func item(_ i: Int, _ icon: String, _ label: String) -> some View {
        Button { tab = i } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .medium))
                Text(label)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundColor(tab == i ? .ink : .pmut)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
