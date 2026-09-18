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

// La raíz: rutea a la pestaña activa o a una pantalla especial (CHINOLA_SCREEN),
// con el «+» flotante y la barra inferior flotante. Las variables de entorno
// CHINOLA_TAB / CHINOLA_SCREEN dejan que el CI arranque la app en cada pantalla
// y saque su captura.
struct RootView: View {
    @State private var tab = Int(ProcessInfo.processInfo.environment["CHINOLA_TAB"] ?? "0") ?? 0
    @State private var titulosMenu = true
    @State private var tendencia = false
    private let pantalla = ProcessInfo.processInfo.environment["CHINOLA_SCREEN"]

    var body: some View {
        ZStack {
            Color.scr.ignoresSafeArea()
            switch pantalla {
            case "nuevo": NuevoMovView()
            case "acciones": AccionesMenu()
            case "nueva-cuenta": NuevaCuentaView()
            case "filtro": FiltroSheet()
            case "apariencia": AparienciaView()
            case "header": HeaderAjusteView()
            case "tendencia": TendenciaView()
            case "transferencia": TransferenciaView()
            case "prestamo": PrestamoView()
            case "abono": AbonoView()
            case "aporte": AporteView()
            case "meta": MetaView()
            case "tarjeta": TarjetaView()
            case "pago-tarjeta": PagoTarjetaView()
            case "categoria": CategoriaView()
            case "libretas": LibretasView()
            case "libreta-detalle": LibretaDetalleView()
            case "idioma": IdiomaView()
            case "notificaciones": NotificacionesView()
            case "editar-nombre": EditarNombreView()
            case "correo": CorreoView()
            case "clave": ClaveView()
            case "eliminar-cuenta": EliminarCuentaView()
            case "det-cuenta": DetalleCuentaView()
            case "det-prestamo": DetallePrestamoView()
            case "det-tarjeta": DetalleTarjetaView()
            case "det-meta": DetalleMetaView()
            case "det-movimiento": DetalleMovimientoView()
            case "bienvenida": BienvenidaView()
            case "registro": AccesoView(registro: true)
            case "login": AccesoView(registro: false)
            case "selector": SelectorLibretaView()
            case "agregar-libreta": AgregarLibretaView()
            case "invitacion": InvitacionView()
            default: appTabs
            }
        }
    }

    private var appTabs: some View {
        ZStack(alignment: .bottom) {
            switch tab {
            case 1: MovsView()
            case 2: CuentasView(abrirTendencia: { tendencia = true })
            case 3: PlanView()
            case 4: PerfilView()
            default: DashboardView()
            }

            // «+» flotante solo en Resumen: en Movs., Cuentas y Plan el «+» vive
            // arriba (junto al título), y Perfil no lo tiene.
            if tab == 0 {
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
        .overlay {
            if tendencia {
                TendenciaView(onClose: { tendencia = false })
                    .background(Color.scr.ignoresSafeArea())
                    .transition(.move(edge: .bottom))
            }
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
        .padding(.vertical, titulos ? 9 : 12)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(.ultraThinMaterial)   // material translúcido, nativo de iOS
                .shadow(color: .black.opacity(0.12), radius: 20, y: 6)
        )
        .overlay(RoundedRectangle(cornerRadius: 30, style: .continuous).stroke(Color.ink.opacity(0.08), lineWidth: 1))
        .padding(.horizontal, 14)
        .padding(.bottom, 2)
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
