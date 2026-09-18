import SwiftUI

// Pantalla «Cuentas»: segmentos, dos KPIs (tienes / debes), y las secciones de
// cuentas, tarjetas y préstamos con sus vacíos. Calcada de la app.
struct CuentasView: View {
    @State private var seg = 0

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                CabeceraFina()
                Segmentos(items: ["Todo", "Cuentas", "Tarjetas", "Préstamos"], sel: $seg)

                HStack(spacing: 12) {
                    kpi("TIENES", "DOP 0", .pos)
                    kpi("DEBES", "DOP 0", .neg)
                }

                VStack(spacing: 12) {
                    SeccionHeader(titulo: "Cuentas", accion: "Cuenta")
                    FilaIcono(icono: "banknote", tinte: .pos, titulo: "Efectivo",
                              subtitulo: "Sin banco · 0 movimientos", valor: "DOP 0")
                        .tarjeta()
                }

                VStack(spacing: 12) {
                    SeccionHeader(titulo: "Tarjetas de crédito", accion: "Tarjeta")
                    VacioCard(titulo: "",
                              detalle: "Tus tarjetas aparecerán aquí, con su saldo y sus fechas.")
                }

                VStack(spacing: 12) {
                    SeccionHeader(titulo: "Préstamos y fíaos", accion: "Préstamo")
                    VacioCard(titulo: "",
                              detalle: "Tus préstamos y cuánto has pagado aparecerán aquí.")
                }

                Color.clear.frame(height: 108)
            }
            .padding(.horizontal, 8)
        }
        .background(Color.scr)
    }

    private func kpi(_ label: String, _ valor: String, _ c: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.system(size: 12, weight: .heavy)).tracking(0.4).foregroundColor(.pmut)
            Text(valor).font(.system(size: 24, weight: .heavy)).foregroundColor(c)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .tarjeta()
    }
}
