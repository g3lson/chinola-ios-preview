import SwiftUI

// Pantalla «Plan»: segmentos (Presupuesto/Metas), la barra del total y la lista
// de categorías con su tope y lo gastado del mes, o las metas con su progreso.
// Datos reales de la libreta activa.
struct PlanView: View {
    @EnvironmentObject var estado: AppEstado
    @State private var seg: Int
    var onNuevo: (Int) -> Void = { _ in }
    init(seg: Int? = nil, onNuevo: @escaping (Int) -> Void = { _ in }) {
        let env = Int(ProcessInfo.processInfo.environment["CHINOLA_PLANSEG"] ?? "")
        _seg = State(initialValue: seg ?? env ?? 0)
        self.onNuevo = onNuevo
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                CabeceraTitulo(titulo: "Plan") {
                    BotonRedondo(icono: "calendar")
                    BotonRedondo(icono: "plus", acento: true, accion: { onNuevo(seg) })
                }
                Segmentos(items: ["Presupuesto", "Metas"], sel: $seg)

                if seg == 0 { presupuesto } else { metas }

                Color.clear.frame(height: 100)
            }
            .padding(.horizontal, 14)
            .padding(.top, 8)
        }
        .background(Color.scr)
    }

    // MARK: Presupuesto
    private var presupuesto: some View {
        let cats = estado.libreta.categorias.filter { $0.tipo == "Gasto" }
        let gastadoTotal = cats.reduce(0.0) { $0 + estado.gastadoCategoria($1.nombre) }
        let total = estado.presupuestoTotal
        return VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(fmtDinero(gastadoTotal)).font(.system(size: 26, weight: .heavy)).foregroundColor(.pos)
                    Spacer()
                    Text("de \(fmtDinero(total))").font(.system(size: 14)).foregroundColor(.pmut)
                }
                barra(gastadoTotal, total, .pos)
            }.tarjeta()

            VStack(spacing: 12) {
                SeccionHeader(titulo: "Categorías", accion: "Categoría", go: { onNuevo(0) })
                if cats.isEmpty {
                    VacioCard(titulo: "Sin categorías", detalle: "Crea categorías para organizar tus gastos.")
                } else {
                    VStack(spacing: 0) {
                        ForEach(cats.indices, id: \.self) { i in
                            fila(cats[i])
                            if i < cats.count - 1 { Divider().overlay(Color.line).padding(.leading, 52) }
                        }
                    }.tarjeta()
                }
            }
        }
    }

    private func fila(_ c: Categoria) -> some View {
        let gastado = estado.gastadoCategoria(c.nombre)
        let tope = c.limite
        return HStack(spacing: 12) {
            Image(systemName: c.icono)
                .font(.system(size: 15, weight: .semibold)).foregroundColor(Color(hexString: c.color))
                .frame(width: 40, height: 40).background(Color(hexString: c.color).opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(c.nombre).font(.system(size: 15.5, weight: .semibold)).foregroundColor(.ink)
                    Spacer()
                    Text(fmtDinero(gastado)).font(.system(size: 14.5, weight: .heavy))
                        .foregroundColor(tope > 0 && gastado > tope ? .neg : .pos)
                }
                barra(gastado, tope, tope > 0 && gastado > tope ? .neg : .pos)
                Text(tope > 0 ? "\(fmtDinero(gastado)) de \(fmtDinero(tope))" : "\(fmtDinero(gastado)) · sin tope")
                    .font(.system(size: 12)).foregroundColor(.pmut)
            }
            Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundColor(.pmut)
        }
        .padding(.vertical, 11)
    }

    // MARK: Metas
    private var metas: some View {
        let ms = estado.libreta.metas
        return VStack(spacing: 12) {
            SeccionHeader(titulo: "Tus metas", accion: "Meta", go: { onNuevo(1) })
            if ms.isEmpty {
                VacioCard(titulo: "", detalle: "Ponte una meta de ahorro y ve cuánto te falta cada mes.")
            } else {
                ForEach(ms.indices, id: \.self) { i in filaMeta(ms[i]) }
            }
        }
    }

    private func filaMeta(_ m: Meta) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: m.icono)
                    .font(.system(size: 15, weight: .semibold)).foregroundColor(Color(hexString: m.color))
                    .frame(width: 40, height: 40).background(Color(hexString: m.color).opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                VStack(alignment: .leading, spacing: 1) {
                    Text(m.nombre).font(.system(size: 15.5, weight: .semibold)).foregroundColor(.ink)
                    Text("\(Int(m.progreso * 100))% · faltan \(fmtDinero(max(0, m.meta - m.ahorrado)))")
                        .font(.system(size: 12)).foregroundColor(.pmut)
                }
                Spacer(minLength: 6)
                Text(fmtDinero(m.ahorrado)).font(.system(size: 15, weight: .heavy)).foregroundColor(Color(hexString: m.color))
            }
            barra(m.ahorrado, m.meta, Color(hexString: m.color))
        }.tarjeta()
    }

    private func barra(_ v: Double, _ total: Double, _ color: Color) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.line)
                Capsule().fill(color)
                    .frame(width: total > 0 ? min(geo.size.width, geo.size.width * CGFloat(v / total)) : 0)
            }
        }
        .frame(height: 7)
    }
}
