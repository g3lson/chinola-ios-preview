import SwiftUI

// Subsecciones de la cuenta con sesión: Mi cuenta, Seguridad e Integraciones,
// y el tour de bienvenida. Mismo look nativo agrupado.

// ── Mi cuenta (con sesión) ──────────────────────────────────────────────────
struct MiCuentaView: View {
    var body: some View {
        PantallaSub(titulo: "Mi cuenta") {
            SeccionTitulo(texto: "Datos")
            Grupo {
                FilaNav(icono: "person.fill", tinte: .pos, titulo: "Editar mi perfil", valor: "Gelson")
                Divisor()
                FilaNav(icono: "envelope.fill", tinte: .info, titulo: "Cambiar mi correo", valor: "gelson@…")
                Divisor()
                FilaNav(icono: "lock.fill", tinte: Color(hex: 0xe0a92e), titulo: "Cambiar mi contraseña")
            }
            VStack(spacing: 6) {
                SeccionTitulo(texto: "Plan")
                Grupo { FilaNav(icono: "star.fill", tinte: .sav, titulo: "Mi plan", valor: "Gratis") }
                NotaPie(texto: "El plan gratis guarda una libreta local. Con cuenta puedes compartir y sincronizar.")
            }
            Grupo {
                HStack(spacing: 12) {
                    IconoCuadro(sistema: "trash.fill", tinte: .neg)
                    Text("Eliminar mi cuenta").font(.system(size: 16)).foregroundColor(.neg)
                    Spacer()
                    Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundColor(Color.pmut.opacity(0.6))
                }
                .padding(.horizontal, 14).padding(.vertical, 11)
            }
        }
    }
}

// ── Seguridad ───────────────────────────────────────────────────────────────
struct SeguridadView: View {
    private let sesiones: [(String, String, String, Bool)] = [
        ("iphone", "iPhone de Gelson", "Santo Domingo · ahora", true),
        ("laptopcomputer", "MacBook", "Santo Domingo · hace 2 h", false),
        ("globe", "Chrome en Windows", "Santiago · ayer", false)
    ]
    var body: some View {
        PantallaSub(titulo: "Seguridad") {
            SeccionTitulo(texto: "Acceso")
            Grupo {
                FilaNav(icono: "lock.fill", tinte: Color(hex: 0xe0a92e), titulo: "Cambiar mi contraseña")
                Divisor()
                FilaNav(icono: "checkmark.shield.fill", tinte: .pos, titulo: "Verificación en dos pasos", valor: "Activada")
            }
            VStack(spacing: 6) {
                SeccionTitulo(texto: "Sesiones activas")
                Grupo {
                    ForEach(sesiones.indices, id: \.self) { i in
                        HStack(spacing: 12) {
                            IconoCuadro(sistema: sesiones[i].0, tinte: sesiones[i].3 ? .pos : .pmut)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(sesiones[i].1).font(.system(size: 15, weight: .semibold)).foregroundColor(.ink)
                                Text(sesiones[i].2).font(.system(size: 12)).foregroundColor(.pmut)
                            }
                            Spacer(minLength: 6)
                            if sesiones[i].3 {
                                Text("Este equipo").font(.system(size: 11, weight: .semibold)).foregroundColor(.pos)
                            } else {
                                Text("Salir").font(.system(size: 13, weight: .semibold)).foregroundColor(.neg)
                            }
                        }
                        .padding(.horizontal, 14).padding(.vertical, 10)
                        if i < sesiones.count - 1 { Divisor(sangria: 57) }
                    }
                }
            }
        }
    }
}

// ── Integraciones (claves de API) ──────────────────────────────────────────
struct IntegracionesView: View {
    var body: some View {
        PantallaSub(titulo: "Integraciones") {
            Text("Con una clave puedes anotar gastos y transferencias desde WhatsApp, Instagram o Telegram, o desde cualquier cosa que sepa hacer una llamada web.")
                .font(.system(size: 13.5)).foregroundColor(.pmut)
                .fixedSize(horizontal: false, vertical: true)
                .padding(14).background(Color.soft)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(spacing: 6) {
                SeccionTitulo(texto: "Tus claves")
                Grupo {
                    fila("Bot de WhatsApp", "Creada 12 sep · usada hoy")
                    Divisor(sangria: 57)
                    fila("Zapier", "Creada 2 ago · sin uso")
                }
            }
            BotonAncho(texto: "Nueva clave", icono: "plus")
        }
    }
    private func fila(_ n: String, _ sub: String) -> some View {
        HStack(spacing: 12) {
            IconoCuadro(sistema: "key.fill", tinte: .sav)
            VStack(alignment: .leading, spacing: 2) {
                Text(n).font(.system(size: 15, weight: .semibold)).foregroundColor(.ink)
                Text(sub).font(.system(size: 12)).foregroundColor(.pmut)
            }
            Spacer(minLength: 6)
            Image(systemName: "ellipsis").font(.system(size: 16, weight: .bold)).foregroundColor(.pmut)
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
    }
}

// ── Tour de bienvenida (globo sobre el dashboard) ──────────────────────────
struct TourView: View {
    var body: some View {
        ZStack {
            DashboardView()
            Color.black.opacity(0.55).ignoresSafeArea()
            VStack {
                Spacer()
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 10) {
                        Chino(lado: 40)
                        Text("Toca aquí para cambiar de libreta")
                            .font(.system(size: 16, weight: .bold)).foregroundColor(.ink)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Text("Cada libreta es una contabilidad aparte: personal, negocio, familia… Cámbialas desde el nombre de arriba.")
                        .font(.system(size: 13.5)).foregroundColor(.pmut)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack {
                        Text("Paso 1 de 6").font(.system(size: 12, weight: .semibold)).foregroundColor(.pmut)
                        Spacer()
                        Text("Saltar").font(.system(size: 14, weight: .semibold)).foregroundColor(.pmut)
                        Text("Siguiente")
                            .font(.system(size: 14, weight: .bold)).foregroundColor(Color(hex: 0x20180a))
                            .padding(.horizontal, 16).padding(.vertical, 9)
                            .background(Color.acc).clipShape(Capsule())
                    }
                    .padding(.top, 2)
                }
                .padding(18)
                .background(Color.card).clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: .black.opacity(0.3), radius: 20, y: 8)
                .padding(.horizontal, 16)
                Spacer()
            }
        }
    }
}
