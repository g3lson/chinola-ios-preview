import SwiftUI

// Pantalla «Perfil»: el logo Chinola, la tarjeta del usuario y los ajustes en
// secciones nativas (Cuenta / Preferencias / Datos / Sobre Chinola), con iconos
// en cuadros de color, como los Ajustes de iOS.
struct PerfilView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
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

                seccion("Cuenta")
                Grupo {
                    fila("person.fill", .pos, "Mi nombre", valor: "Gelson")
                    Divisor()
                    fila("book.closed.fill", .info, "Libretas y permisos", valor: "1")
                }

                seccion("Preferencias")
                Grupo {
                    fila("paintpalette.fill", .sav, "Personalización", valor: "Chinola")
                    Divisor()
                    fila("character.bubble.fill", .info, "Idioma", valor: "Español")
                    Divisor()
                    fila("bell.fill", .neg, "Notificaciones", valor: "Solo en la app")
                }

                seccion("Datos")
                Grupo {
                    fila("square.and.arrow.down.fill", Color(hex: 0x1fa9a0), "Exportar esta libreta", valor: "")
                    Divisor()
                    fila("square.and.arrow.up.fill", Color(hex: 0xe0a92e), "Importar movimientos", valor: "CSV")
                }

                seccion("Sobre Chinola")
                Grupo {
                    fila("play.circle.fill", .pos, "Ver el tour otra vez", valor: "10 pasos")
                    Divisor()
                    fila("questionmark.circle.fill", .info, "Ayuda y guía", valor: "")
                    Divisor()
                    fila("checkmark.shield.fill", .sav, "Privacidad y términos", valor: "")
                }
                Text("Versión v1.0.71 · nativo")
                    .font(.system(size: 12)).foregroundColor(.pmut)
                    .padding(.leading, 4).padding(.top, 2)

                Color.clear.frame(height: 108)
            }
            .padding(.horizontal, 14)
        }
        .background(Color.scr)
    }

    private func seccion(_ t: String) -> some View {
        Text(t.uppercased()).font(.system(size: 12.5, weight: .semibold)).tracking(0.3)
            .foregroundColor(.pmut).padding(.leading, 16).padding(.bottom, -6)
    }

    private func fila(_ icono: String, _ tinte: Color, _ titulo: String, valor: String) -> some View {
        HStack(spacing: 12) {
            IconoCuadro(sistema: icono, tinte: tinte)
            Text(titulo).font(.system(size: 16)).foregroundColor(.ink)
            Spacer(minLength: 8)
            if !valor.isEmpty {
                Text(valor).font(.system(size: 14)).foregroundColor(.pmut)
            }
            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundColor(Color.pmut.opacity(0.6))
        }
        .padding(.horizontal, 14).padding(.vertical, 11)
    }
}
