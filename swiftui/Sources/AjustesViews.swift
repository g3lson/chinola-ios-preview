import SwiftUI

// Barra de navegación simple (‹ Título) para las pantallas de ajustes.
struct BarraNav: View {
    let titulo: String
    var body: some View {
        ZStack {
            Text(titulo).font(.system(size: 17, weight: .bold)).foregroundColor(.ink)
            HStack {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .bold)).foregroundColor(.ink)
                    .frame(width: 38, height: 38).background(Color.soft).clipShape(Circle())
                Spacer()
            }
        }
        .padding(.horizontal, 12).padding(.top, 8).padding(.bottom, 6)
    }
}

// Pantalla «Apariencia»: la lista de opciones (Dashboard, Cabecera, …).
struct AparienciaView: View {
    private struct Op { let icono: String; let tinte: Color; let titulo: String; let valor: String }
    private let ops: [Op] = [
        .init(icono: "square.grid.2x2.fill", tinte: .pos, titulo: "Dashboard", valor: ""),
        .init(icono: "rectangle.grid.1x2.fill", tinte: .info, titulo: "Cabecera", valor: "Automática"),
        .init(icono: "textformat", tinte: .sav, titulo: "Tipografía", valor: "Plus Jakarta"),
        .init(icono: "paintpalette.fill", tinte: .neg, titulo: "Colores", valor: "Chinola"),
        .init(icono: "dollarsign.circle.fill", tinte: Color(hex: 0xe0a92e), titulo: "Moneda", valor: "DOP"),
        .init(icono: "face.smiling", tinte: .pos, titulo: "Tu personaje", valor: "")
    ]

    var body: some View {
        VStack(spacing: 0) {
            BarraNav(titulo: "Apariencia")
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach(ops.indices, id: \.self) { i in
                        HStack(spacing: 12) {
                            Image(systemName: ops[i].icono)
                                .font(.system(size: 15, weight: .semibold)).foregroundColor(ops[i].tinte)
                                .frame(width: 36, height: 36)
                                .background(ops[i].tinte.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                            Text(ops[i].titulo).font(.system(size: 16, weight: .semibold)).foregroundColor(.ink)
                            Spacer(minLength: 8)
                            if !ops[i].valor.isEmpty {
                                Text(ops[i].valor).font(.system(size: 14)).foregroundColor(.pmut)
                            }
                            Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundColor(.pmut)
                        }
                        .padding(.vertical, 13)
                        if i < ops.count - 1 { Divider().overlay(Color.line).padding(.leading, 48) }
                    }
                }
                .tarjeta()
                .padding(.horizontal, 12).padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.scr)
    }
}

// Pantalla «Cabecera»: integrada, estilos, color con degradado y redondeado.
struct HeaderAjusteView: View {
    @State private var integrada = false
    @State private var estilo = 0
    @State private var color = "chinola"
    @State private var redondeado = true

    private let estilos: [(String, String, Bool)] = [
        ("Automática", "Grande en el resumen, fina al bajar", true),
        ("Fina", "Una línea verde con el balance al lado", true),
        ("Clara", "Color papel, sin banda", false),
        ("Mínima", "Solo la libreta y el mes", false),
        ("Clásica", "La banda verde de siempre", true),
        ("Detallada", "Con el gasto del mes en un botón", false)
    ]

    var body: some View {
        VStack(spacing: 0) {
            BarraNav(titulo: "Cabecera")
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    // Integrada.
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Integrada").font(.system(size: 15, weight: .bold)).foregroundColor(.ink)
                            Text("Sin color propio: toma el fondo de la pantalla.")
                                .font(.system(size: 12.5)).foregroundColor(.pmut)
                        }
                        Spacer(minLength: 8)
                        toggle($integrada)
                    }.tarjeta()

                    // Estilos.
                    Text("CABECERA").font(.system(size: 12, weight: .heavy)).tracking(0.4).foregroundColor(.pmut)
                    VStack(spacing: 10) {
                        ForEach(estilos.indices, id: \.self) { i in
                            HStack(spacing: 13) {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(estilos[i].2 ? Color.side : Color.soft)
                                    .frame(width: 52, height: 34)
                                    .overlay(RoundedRectangle(cornerRadius: 3).fill(Color.white.opacity(estilos[i].2 ? 0.5 : 0)).frame(width: 22, height: 4).padding(.bottom, 6), alignment: .bottom)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(estilos[i].0).font(.system(size: 15.5, weight: .bold)).foregroundColor(.ink)
                                    Text(estilos[i].1).font(.system(size: 12.5)).foregroundColor(.pmut)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                Spacer(minLength: 4)
                            }
                            .padding(12)
                            .background(Color.card)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 16)
                                .stroke(i == estilo ? Color.acc : Color.line, lineWidth: i == estilo ? 2 : 1))
                            .onTapGesture { estilo = i }
                        }
                    }

                    // Color de la cabecera.
                    Text("Color de la cabecera").font(.system(size: 14, weight: .bold)).foregroundColor(.ink)
                    let cols = Array(repeating: GridItem(.flexible(), spacing: 12), count: 6)
                    LazyVGrid(columns: cols, spacing: 12) {
                        // «Del tema» (sin color) primero.
                        muestra(sel: color == "tema", relleno: AnyView(Color.side)) { color = "tema" }
                        ForEach(COLORES_CABECERA) { c in
                            muestra(sel: color == c.id, relleno: AnyView(c.gradiente)) { color = c.id }
                        }
                    }

                    // Redondeado.
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Esquinas redondeadas").font(.system(size: 15, weight: .bold)).foregroundColor(.ink)
                            Text("La cabecera como una tarjeta, con las esquinas redondeadas.")
                                .font(.system(size: 12.5)).foregroundColor(.pmut).fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer(minLength: 8)
                        toggle($redondeado)
                    }.tarjeta()

                    Color.clear.frame(height: 20)
                }
                .padding(.horizontal, 12).padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.scr)
    }

    private func muestra(sel: Bool, relleno: AnyView, _ go: @escaping () -> Void) -> some View {
        ZStack {
            relleno.clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
            Image(systemName: "checkmark").font(.system(size: 15, weight: .heavy))
                .foregroundColor(.white).opacity(sel ? 1 : 0)
        }
        .frame(height: 46)
        .overlay(RoundedRectangle(cornerRadius: 13).stroke(sel ? Color.acc : Color.black.opacity(0.06), lineWidth: sel ? 2.5 : 1))
        .onTapGesture(perform: go)
    }

    private func toggle(_ on: Binding<Bool>) -> some View {
        ZStack(alignment: on.wrappedValue ? .trailing : .leading) {
            Capsule().fill(on.wrappedValue ? Color.acc : Color.line).frame(width: 46, height: 28)
            Circle().fill(.white).frame(width: 22, height: 22).padding(3)
        }
        .onTapGesture { on.wrappedValue.toggle() }
    }
}
