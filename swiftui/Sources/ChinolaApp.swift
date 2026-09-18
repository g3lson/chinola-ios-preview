import SwiftUI

@main
struct ChinolaApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.light)   // el tema Chinola por defecto es claro
        }
    }
}

// La raíz: el dashboard, el «+» flotante abajo a la derecha y la barra inferior
// de 5 pestañas. Calca la disposición que ya trae la app; no la reinventa.
struct RootView: View {
    @State private var tab = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.scr.ignoresSafeArea()

            DashboardView()

            // «+» flotante, como el de la app (esquina inferior derecha,
            // por encima de la barra), no un botón central de la barra.
            Button {
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(Color(hex: 0x20180a))
                    .frame(width: 58, height: 58)
                    .background(Color.acc)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.22), radius: 10, y: 4)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .padding(.trailing, 18)
            .padding(.bottom, 78)

            BottomBar(tab: $tab)
        }
    }
}

// Barra inferior de 5 pestañas (iconos SF), tal cual la app: Resumen, Movs.,
// Cuentas, Plan, Perfil. Perfil lleva el avatar de Chino, no un icono suelto.
struct BottomBar: View {
    @Binding var tab: Int

    var body: some View {
        HStack(spacing: 0) {
            item(0, "square.grid.2x2.fill", "Resumen")
            item(1, "arrow.up.arrow.down", "Movs.")
            item(2, "creditcard", "Cuentas")
            item(3, "clock", "Plan")
            perfil(4)
        }
        .padding(.top, 9)
        .padding(.bottom, 4)
        .background(
            Color.card
                .overlay(Rectangle().fill(Color.line).frame(height: 0.5), alignment: .top)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func item(_ i: Int, _ icon: String, _ label: String) -> some View {
        Button { tab = i } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                Text(label)
                    .font(.system(size: 10.5, weight: .medium))
            }
            .foregroundColor(tab == i ? .ink : .pmut)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    // Perfil: el carita de Chino en un círculo amarillo.
    private func perfil(_ i: Int) -> some View {
        Button { tab = i } label: {
            VStack(spacing: 4) {
                Text("🍊")
                    .font(.system(size: 17))
                    .frame(width: 24, height: 24)
                    .background(Color.acc.opacity(tab == i ? 1 : 0.85))
                    .clipShape(Circle())
                Text("Perfil")
                    .font(.system(size: 10.5, weight: .medium))
            }
            .foregroundColor(tab == i ? .ink : .pmut)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
