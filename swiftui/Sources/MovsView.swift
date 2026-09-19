import SwiftUI

// Pantalla «Movimientos»: título grande, botones redondos (calendario + «+»),
// buscador, y la lista real de movimientos de la libreta activa.
struct MovsView: View {
    @EnvironmentObject var estado: AppEstado
    var onNuevo: () -> Void = {}
    var onDetalle: (String) -> Void = { _ in }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                CabeceraTitulo(titulo: "Movimientos") {
                    BotonRedondo(icono: "calendar")
                    BotonRedondo(icono: "plus", acento: true, accion: onNuevo)
                }
                busqueda
                let movs = estado.movimientos
                if movs.isEmpty {
                    VacioCard(titulo: "Sin movimientos",
                              detalle: "Lo que registres este mes aparecerá aquí.")
                } else {
                    Grupo {
                        ForEach(movs.indices, id: \.self) { i in
                            Button { onDetalle(movs[i].id) } label: { fila(movs[i]) }.buttonStyle(.plain)
                            if i < movs.count - 1 { Divisor(sangria: 60) }
                        }
                    }
                }
                Color.clear.frame(height: 100)
            }
            .padding(.horizontal, 14)
            .padding(.top, 8)
        }
        .background(Color.scr)
    }

    private func fila(_ m: Movimiento) -> some View {
        let entra = m.tipo == .ingreso
        let signo = entra ? "+ " : (m.tipo == .transferencia ? "" : "− ")
        let color: Color = entra ? .pos : (m.tipo == .transferencia ? .ink : .neg)
        return HStack(spacing: 12) {
            Image(systemName: icono(m))
                .font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                .frame(width: 34, height: 34).background(tinte(m))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(m.concepto).font(.system(size: 15, weight: .semibold)).foregroundColor(.ink)
                Text("\(m.categoria) · \(fechaCorta(m.fecha))").font(.system(size: 11.5)).foregroundColor(.pmut)
            }
            Spacer(minLength: 6)
            Text(signo + fmtDinero(m.monto)).font(.system(size: 15, weight: .heavy)).foregroundColor(color)
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
    }

    private func icono(_ m: Movimiento) -> String {
        switch m.tipo {
        case .ingreso: return "banknote.fill"
        case .transferencia: return "arrow.left.arrow.right"
        case .ahorro: return "target"
        default:
            return estado.libreta.categorias.first { $0.nombre == m.categoria }?.icono ?? "tag.fill"
        }
    }
    private func tinte(_ m: Movimiento) -> Color {
        if m.tipo == .ingreso { return .pos }
        if m.tipo == .transferencia { return .info }
        if m.tipo == .ahorro { return .sav }
        if let c = estado.libreta.categorias.first(where: { $0.nombre == m.categoria }) { return Color(hexString: c.color) }
        return Color(hex: 0xe0a92e)
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
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.line, lineWidth: 1))
        }
    }
}

// Fecha corta "dd mmm" desde ISO.
func fechaCorta(_ iso: String) -> String {
    let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; f.locale = Locale(identifier: "en_US_POSIX")
    guard let d = f.date(from: iso) else { return iso }
    let o = DateFormatter(); o.locale = Locale(identifier: "es"); o.dateFormat = "d MMM"
    return o.string(from: d)
}
