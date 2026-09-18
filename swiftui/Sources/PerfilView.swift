import SwiftUI

// Pantalla «Perfil»: el logo Chinola, la tarjeta del usuario y las listas de
// ajustes (cuenta, avisos y datos, sobre Chinola). Calcada de la app.
struct PerfilView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                // Marca.
                HStack(spacing: 10) {
                    Circle().fill(Color.side)
                        .frame(width: 30, height: 30)
                        .overlay(Circle().fill(Color.acc).frame(width: 14, height: 14))
                    Text("Chinola").font(.system(size: 22, weight: .heavy)).foregroundColor(.ink)
                }
                .padding(.top, 6)

                // Tarjeta del usuario.
                HStack(spacing: 13) {
                    Text("G").font(.system(size: 20, weight: .heavy)).foregroundColor(Color(hex: 0x20180a))
                        .frame(width: 48, height: 48).background(Color.acc).clipShape(Circle())
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Gelson").font(.system(size: 17, weight: .bold)).foregroundColor(.ink)
                        Text("Los datos se quedan en este dispositivo")
                            .font(.system(size: 12.5)).foregroundColor(.pmut)
                    }
                    Spacer(minLength: 6)
                    Text("Local").font(.system(size: 12, weight: .bold)).foregroundColor(.pmut)
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(Color.soft).clipShape(Capsule())
                }.tarjeta()

                // Cuenta.
                VStack(spacing: 0) {
                    fila("person", "Mi nombre", valor: "Gelson")
                    sep()
                    fila("book.closed", "Libretas y permisos", valor: "1")
                    sep()
                    fila("paintpalette", "Apariencia", valor: "Chinola")
                    sep()
                    fila("character.bubble", "Idioma", valor: "Español")
                }.tarjeta()

                seccion("Avisos y datos")
                VStack(spacing: 0) {
                    fila("play.circle", "Ver el tour otra vez", valor: "10 pasos")
                    sep()
                    fila("square.and.arrow.down", "Exportar esta libreta", valor: "0 movimientos")
                    sep()
                    fila("square.and.arrow.up", "Importar movimientos", valor: "CSV")
                }.tarjeta()

                seccion("Sobre Chinola")
                VStack(spacing: 0) {
                    fila("questionmark.circle", "Ayuda y guía", valor: nil)
                    sep()
                    fila("checkmark.shield", "Privacidad y términos", valor: nil)
                }.tarjeta()

                Text("Versión v1.0.60 · nativo")
                    .font(.system(size: 12)).foregroundColor(.pmut)
                    .padding(.leading, 4)

                Color.clear.frame(height: 108)
            }
            .padding(.horizontal, 12)
        }
        .background(Color.scr)
    }

    private func seccion(_ t: String) -> some View {
        Text(t.uppercased()).font(.system(size: 12, weight: .heavy)).tracking(0.4)
            .foregroundColor(.pmut).padding(.leading, 4).padding(.top, 4)
    }

    private func sep() -> some View { Divider().overlay(Color.line).padding(.leading, 42) }

    private func fila(_ icono: String, _ titulo: String, valor: String?) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icono).font(.system(size: 17, weight: .regular))
                .foregroundColor(.ink).frame(width: 26)
            Text(titulo).font(.system(size: 15.5, weight: .medium)).foregroundColor(.ink)
            Spacer(minLength: 8)
            if let v = valor {
                Text(v).font(.system(size: 14)).foregroundColor(.pmut)
            }
            Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundColor(.pmut)
        }
        .padding(.vertical, 12)
    }
}
