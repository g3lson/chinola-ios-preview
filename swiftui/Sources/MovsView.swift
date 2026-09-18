import SwiftUI

// Pantalla «Movimientos»: sin cabecera; título grande, botones redondos
// (calendario + «+») y buscador. Estilo homogéneo con Cuentas y Plan.
struct MovsView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                CabeceraTitulo(titulo: "Movimientos") {
                    BotonRedondo(icono: "calendar")
                    BotonRedondo(icono: "plus", acento: true)
                }
                busqueda
                VacioCard(titulo: "Sin movimientos",
                          detalle: "Lo que registres este mes aparecerá aquí.")
                Color.clear.frame(height: 100)
            }
            .padding(.horizontal, 14)
            .padding(.top, 8)
        }
        .background(Color.scr)
    }

    private var busqueda: some View {
        HStack(spacing: 10) {
            HStack(spacing: 9) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15, weight: .semibold)).foregroundColor(.pmut)
                Text("Buscar movimiento…").font(.system(size: 15)).foregroundColor(.pmut)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 15).padding(.vertical, 13)
            .background(Color.card)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.line, lineWidth: 1))

            Image(systemName: "line.3.horizontal.decrease")
                .font(.system(size: 17, weight: .semibold)).foregroundColor(.ink)
                .frame(width: 48, height: 48)
                .background(Color.card)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.line, lineWidth: 1))
        }
    }
}
