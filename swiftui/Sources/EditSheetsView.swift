import SwiftUI

// Hojas cortas de editar la cuenta: nombre, correo, contraseña y las acciones
// destructivas (eliminar cuenta / borrar datos). Mismo look nativo agrupado.

// Cuerpo corto reutilizable: cabecera + grupos + (opcional) botón ancho.
struct HojaCorta<Contenido: View>: View {
    let titulo: String
    var conCheck: Bool = true
    @ViewBuilder var contenido: Contenido
    var body: some View {
        ZStack(alignment: .bottom) {
            FondoAtenuado()
            VStack(spacing: 0) {
                CabeceraHoja(titulo: titulo, conCheck: conCheck)
                VStack(alignment: .leading, spacing: 16) {
                    contenido
                    Color.clear.frame(height: 24)
                }
                .padding(.horizontal, 16)
            }
            .comoHoja(grande: false)
        }
    }
}

// ── Editar mi nombre / perfil ──────────────────────────────────────────────
struct EditarNombreView: View {
    var body: some View {
        HojaCorta(titulo: "Mi nombre") {
            VStack(spacing: 6) {
                SeccionTitulo(texto: "¿Cómo te llamas?")
                Grupo { FilaCampo(placeholder: "Gelson") }
                NotaPie(texto: "Así apareces en tus libretas compartidas.")
            }
        }
    }
}

// ── Cambiar mi correo ───────────────────────────────────────────────────────
struct CorreoView: View {
    var body: some View {
        HojaCorta(titulo: "Mi correo") {
            VStack(spacing: 6) {
                SeccionTitulo(texto: "Correo de la cuenta")
                Grupo {
                    FilaCampo(placeholder: "correo@persona.com")
                    Divisor(sangria: 16)
                    FilaCampo(placeholder: "Contraseña actual")
                }
                NotaPie(texto: "Te enviaremos un enlace para confirmar el cambio.")
            }
        }
    }
}

// ── Cambiar mi contraseña ───────────────────────────────────────────────────
struct ClaveView: View {
    var body: some View {
        HojaCorta(titulo: "Contraseña") {
            VStack(spacing: 6) {
                SeccionTitulo(texto: "Nueva contraseña")
                Grupo {
                    FilaCampo(placeholder: "Contraseña actual")
                    Divisor(sangria: 16)
                    FilaCampo(placeholder: "Nueva contraseña")
                    Divisor(sangria: 16)
                    FilaCampo(placeholder: "Repite la nueva")
                }
            }
        }
    }
}

// ── Eliminar mi cuenta (acción destructiva) ────────────────────────────────
struct EliminarCuentaView: View {
    var body: some View {
        HojaCorta(titulo: "Eliminar cuenta", conCheck: false) {
            VStack(spacing: 14) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 34, weight: .bold)).foregroundColor(.neg)
                    .frame(maxWidth: .infinity)
                Text("Esto borra tu cuenta y todas tus libretas para siempre. No se puede deshacer.")
                    .font(.system(size: 14)).foregroundColor(.pmut)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                Grupo { FilaCampo(placeholder: "Escribe tu contraseña para confirmar") }
                Text("Eliminar mi cuenta")
                    .font(.system(size: 15.5, weight: .bold)).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 15)
                    .background(Color.neg).clipShape(Capsule())
            }
        }
    }
}
