import SwiftUI

// Pantalla «Movimientos» (Movs.): cabecera fina, buscador con filtro y estado
// vacío. Calcada de la app.
struct MovsView: View {
    var body: some View {
        VStack(spacing: 12) {
            CabeceraFina()
            busqueda
            VacioCard(titulo: "Sin movimientos",
                      detalle: "Lo que registres este mes aparecerá aquí.")
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
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
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.line, lineWidth: 1))

            Image(systemName: "line.3.horizontal.decrease")
                .font(.system(size: 17, weight: .semibold)).foregroundColor(.ink)
                .frame(width: 48, height: 48)
                .background(Color.card)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.line, lineWidth: 1))
        }
    }
}
