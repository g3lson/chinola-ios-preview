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

// La raíz: la pantalla de la pestaña activa, el «+» flotante y la barra inferior
// flotante. Cada pestaña muestra su propia pantalla.
struct RootView: View {
    // La pestaña inicial se puede fijar con la variable de entorno CHINOLA_TAB
    // (0..4); así el CI arranca la app en cada pantalla y saca su captura.
    @State private var tab = Int(ProcessInfo.processInfo.environment["CHINOLA_TAB"] ?? "0") ?? 0
    // Ajuste: mostrar u ocultar los títulos del menú (irá en Ajustes de la app).
    @State private var titulosMenu = true

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.scr.ignoresSafeArea()

            switch tab {
            case 1: MovsView()
            case 2: CuentasView()
            case 3: PlanView()
            case 4: PerfilView()
            default: DashboardView()
            }

            // «+» flotante, salvo en Perfil (que no lo tiene en la app).
            if tab != 4 {
                Button {} label: {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(Color(hex: 0x20180a))
                        .frame(width: 58, height: 58)
                        .background(Color.acc)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.22), radius: 10, y: 4)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(.trailing, 20)
                .padding(.bottom, 104)
            }

            BottomBar(tab: $tab, titulos: titulosMenu)
        }
    }
}

// Barra inferior FLOTANTE: tarjeta redondeada con márgenes y sombra. Iconos con
// los paths exactos de la app; el título de cada pestaña se puede ocultar.
struct BottomBar: View {
    @Binding var tab: Int
    var titulos: Bool = true

    var body: some View {
        HStack(spacing: 0) {
            item(0, TabIcono.resumen, "Resumen")
            item(1, TabIcono.movs, "Movs.")
            item(2, TabIcono.cuentas, "Cuentas")
            item(3, TabIcono.plan, "Plan")
            perfil(4)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, titulos ? 10 : 13)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.card)
                .shadow(color: .black.opacity(0.14), radius: 18, y: 6)
        )
        .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous).stroke(Color.line, lineWidth: 1))
        .padding(.horizontal, 14)
        .padding(.bottom, 4)
    }

    private func item(_ i: Int, _ d: String, _ label: String) -> some View {
        Button { tab = i } label: {
            VStack(spacing: 4) {
                IconoTab(d: d)
                if titulos {
                    Text(label).font(.system(size: 11, weight: .heavy)).tracking(-0.1)
                }
            }
            .foregroundColor(tab == i ? .ink : .pmut)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    // Perfil: el avatar de Chino en un círculo (el mascota, como en la app).
    private func perfil(_ i: Int) -> some View {
        Button { tab = i } label: {
            VStack(spacing: 4) {
                Text("🍊")
                    .font(.system(size: 19))
                    .frame(width: 26, height: 26)
                    .background(Color.acc.opacity(tab == i ? 1 : 0.85))
                    .clipShape(Circle())
                if titulos {
                    Text("Perfil").font(.system(size: 11, weight: .heavy)).tracking(-0.1)
                }
            }
            .foregroundColor(tab == i ? .ink : .pmut)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
