import SwiftUI

// Piezas compartidas por las pantallas, para que todas se vean iguales que la
// app (mismos colores, mismas tarjetas, misma cabecera fina).

// Cabecera fina (Movs./Cuentas/Plan): tarjeta verde flotante con el selector de
// libreta a la izquierda y el balance + calendario a la derecha.
struct CabeceraFina: View {
    var body: some View {
        HStack(spacing: 10) {
            HStack(spacing: 7) {
                Image(systemName: "house.fill").font(.system(size: 12, weight: .semibold))
                Text("Personal").font(.system(size: 15, weight: .semibold))
                Image(systemName: "chevron.down").font(.system(size: 11, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 13).padding(.vertical, 7)
            .background(Color.white.opacity(0.14))
            .clipShape(Capsule())

            Spacer(minLength: 0)

            VStack(alignment: .trailing, spacing: 1) {
                Text("DOP 0").font(.system(size: 19, weight: .heavy)).foregroundColor(.acc)
                Text("Este mes").font(.system(size: 11)).foregroundColor(.white.opacity(0.72))
            }
            Image(systemName: "calendar")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
        .background(Color.side)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.side.opacity(0.28), radius: 14, y: 6)
        .padding(.top, 6)
    }
}

// Segmentos (All time / Accounts…): la opción activa es una pastilla verde.
struct Segmentos: View {
    let items: [String]
    @Binding var sel: Int
    var body: some View {
        HStack(spacing: 6) {
            ForEach(items.indices, id: \.self) { i in
                Text(items[i])
                    .font(.system(size: 14, weight: i == sel ? .bold : .semibold))
                    .foregroundColor(i == sel ? .white : .pmut)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(i == sel ? Color.side : Color.clear)
                    .clipShape(Capsule())
                    .onTapGesture { sel = i }
            }
            Spacer(minLength: 0)
        }
    }
}

// Encabezado de sección (MAYÚSCULAS) con un botón «+ Algo» opcional a la derecha.
struct SeccionHeader: View {
    let titulo: String
    var accion: String? = nil
    var body: some View {
        HStack {
            Text(titulo.uppercased())
                .font(.system(size: 12, weight: .heavy)).tracking(0.4)
                .foregroundColor(.pmut)
            Spacer()
            if let a = accion {
                HStack(spacing: 5) {
                    Image(systemName: "plus").font(.system(size: 12, weight: .bold))
                    Text(a).font(.system(size: 13, weight: .bold))
                }
                .foregroundColor(.ink)
                .padding(.horizontal, 13).padding(.vertical, 8)
                .background(Color.card)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.line, lineWidth: 1))
            }
        }
    }
}

// Fila con icono en cuadrado de color, título/subtítulo y valor a la derecha.
struct FilaIcono: View {
    let icono: String
    let tinte: Color
    let titulo: String
    var subtitulo: String? = nil
    var valor: String
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icono)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(tinte)
                .frame(width: 40, height: 40)
                .background(tinte.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(titulo).font(.system(size: 15.5, weight: .semibold)).foregroundColor(.ink)
                if let s = subtitulo {
                    Text(s).font(.system(size: 12.5)).foregroundColor(.pmut)
                }
            }
            Spacer(minLength: 8)
            Text(valor).font(.system(size: 15, weight: .heavy)).foregroundColor(.ink)
            Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundColor(.pmut)
        }
    }
}

// Tarjeta blanca estándar.
struct TarjetaFondo: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.card)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.line, lineWidth: 1))
    }
}
extension View { func tarjeta() -> some View { modifier(TarjetaFondo()) } }

// Tarjeta de estado vacío (texto centrado).
struct VacioCard: View {
    let titulo: String
    let detalle: String
    var body: some View {
        VStack(spacing: 6) {
            if !titulo.isEmpty {
                Text(titulo).font(.system(size: 15, weight: .bold)).foregroundColor(.ink)
            }
            Text(detalle).font(.system(size: 13.5)).foregroundColor(.pmut)
                .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24).padding(.horizontal, 16)
        .background(Color.card)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.line, style: StrokeStyle(lineWidth: 1, dash: [5, 4])))
    }
}
