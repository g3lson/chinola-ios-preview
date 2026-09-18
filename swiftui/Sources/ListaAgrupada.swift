import SwiftUI

// Piezas para las hojas/ventanas con el look nativo de iOS: secciones agrupadas
// en tarjetas, filas limpias con icono en cuadrado de color, toggles nativos y
// filas navegables con su chevron. Nada se reajusta raro; todo respira igual.

// Encabezado de sección (MAYÚSCULAS, gris) sobre un grupo.
struct SeccionTitulo: View {
    let texto: String
    var body: some View {
        Text(texto.uppercased())
            .font(.system(size: 12.5, weight: .semibold)).tracking(0.3)
            .foregroundColor(.pmut)
            .padding(.leading, 16).padding(.bottom, 2)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// Grupo: tarjeta blanca redondeada que envuelve unas filas.
struct Grupo<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        VStack(spacing: 0) { content }
            .background(Color.card)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.line, lineWidth: 0.5))
    }
}

// Icono en cuadrado de color (como los de iOS).
struct IconoCuadro: View {
    let sistema: String
    let tinte: Color
    var body: some View {
        Image(systemName: sistema)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white)
            .frame(width: 29, height: 29)
            .background(tinte)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

// Divisor fino con sangría (deja pasar el ancho del icono).
struct Divisor: View {
    var sangria: CGFloat = 57
    var body: some View {
        Rectangle().fill(Color.line).frame(height: 0.5).padding(.leading, sangria)
    }
}

// Fila con toggle nativo.
struct FilaToggle: View {
    let icono: String
    let tinte: Color
    let titulo: String
    @Binding var on: Bool
    var body: some View {
        HStack(spacing: 12) {
            IconoCuadro(sistema: icono, tinte: tinte)
            Text(titulo).font(.system(size: 16)).foregroundColor(.ink)
            Spacer(minLength: 8)
            Toggle("", isOn: $on).labelsHidden().tint(.pos)
        }
        .padding(.horizontal, 14).padding(.vertical, 9)
    }
}

// Fila navegable: icono + título + valor gris + chevron.
struct FilaNav: View {
    let icono: String
    let tinte: Color
    let titulo: String
    var valor: String = ""
    var body: some View {
        HStack(spacing: 12) {
            IconoCuadro(sistema: icono, tinte: tinte)
            Text(titulo).font(.system(size: 16)).foregroundColor(.ink)
            Spacer(minLength: 8)
            if !valor.isEmpty {
                Text(valor).font(.system(size: 15)).foregroundColor(.pmut)
            }
            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundColor(Color.pmut.opacity(0.6))
        }
        .padding(.horizontal, 14).padding(.vertical, 11)
    }
}

// Fila de campo de texto (placeholder gris).
struct FilaCampo: View {
    let placeholder: String
    var body: some View {
        Text(placeholder).font(.system(size: 16)).foregroundColor(.pmut)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 15).padding(.vertical, 13)
    }
}

// Nota gris bajo un grupo (como el pie del «Urgent» en Recordatorios).
struct NotaPie: View {
    let texto: String
    var body: some View {
        Text(texto).font(.system(size: 12.5)).foregroundColor(.pmut)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 16).padding(.top, 2)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
