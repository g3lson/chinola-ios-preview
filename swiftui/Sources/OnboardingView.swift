import SwiftUI

// La mascota Chino: una china (naranja) con su tallo, dos ojos y la sonrisa.
// Dibujada con formas nativas para que sea nítida a cualquier tamaño.
struct Chino: View {
    var lado: CGFloat = 100
    var body: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(
                    colors: [Color(hex: 0xf4d24a), Color(hex: 0xe89b32), Color(hex: 0xc06a2a)],
                    center: UnitPoint(x: 0.32, y: 0.26), startRadius: 4, endRadius: lado * 0.75))
                .frame(width: lado, height: lado)
            // Tallo.
            RoundedRectangle(cornerRadius: lado * 0.06)
                .fill(Color(hex: 0x2f6b3a))
                .frame(width: lado * 0.09, height: lado * 0.21)
                .rotationEffect(.degrees(10))
                .offset(x: lado * 0.06, y: -lado * 0.53)
            // Ojos.
            HStack(spacing: lado * 0.18) {
                Capsule().fill(Color(hex: 0x1c2f18)).frame(width: lado * 0.14, height: lado * 0.17)
                Capsule().fill(Color(hex: 0x1c2f18)).frame(width: lado * 0.14, height: lado * 0.17)
            }
            .offset(y: -lado * 0.05)
            // Sonrisa.
            RoundedRectangle(cornerRadius: lado * 0.12)
                .fill(Color(hex: 0x243a1a))
                .frame(width: lado * 0.30, height: lado * 0.15)
                .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: lado * 0.14, bottomTrailingRadius: lado * 0.14))
                .offset(y: lado * 0.22)
        }
        .frame(width: lado, height: lado)
    }
}

// ── Bienvenida / onboarding ─────────────────────────────────────────────────
struct BienvenidaView: View {
    var body: some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: 40)
            HStack(spacing: 10) {
                Circle().fill(Color.side).frame(width: 32, height: 32)
                    .overlay(Circle().fill(Color.acc).frame(width: 12, height: 12))
                Text("Chinola").font(.system(size: 22, weight: .heavy)).foregroundColor(.ink)
            }
            .padding(.top, 6)

            Spacer(minLength: 0)

            // Tarjeta ilustrada del slide.
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(LinearGradient(colors: [Color(hex: 0x137d41), Color(hex: 0x0c5c30)], startPoint: .topLeading, endPoint: .bottomTrailing))
                Circle().stroke(Color.white.opacity(0.18), lineWidth: 14).frame(width: 146, height: 146).offset(x: -30, y: -40)
                Chino(lado: 96).offset(x: 150, y: -120)
                VStack(alignment: .leading, spacing: 8) {
                    ForEach([0.85, 0.6, 0.45], id: \.self) { w in
                        Capsule().fill(Color.white.opacity(0.85)).frame(width: 220 * w, height: 13)
                    }
                    Text("DOP 84,200").font(.system(size: 38, weight: .heavy)).foregroundColor(.white).padding(.top, 6)
                }
                .padding(24)
            }
            .frame(height: 300)
            .padding(.horizontal, 28)

            VStack(spacing: 11) {
                Text("Tu dinero, claro como el agua")
                    .font(.system(size: 27, weight: .heavy)).foregroundColor(.ink)
                    .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
                Text("Anota lo que entra y lo que sale, por libretas, sin enredos.")
                    .font(.system(size: 15)).foregroundColor(.pmut)
                    .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 28).padding(.top, 22)

            HStack(spacing: 7) {
                Capsule().fill(Color.side).frame(width: 22, height: 7)
                Circle().fill(Color.line).frame(width: 7, height: 7)
                Circle().fill(Color.line).frame(width: 7, height: 7)
            }
            .padding(.top, 20)

            Spacer(minLength: 0)

            VStack(spacing: 11) {
                Text("Crear mi cuenta gratis")
                    .font(.system(size: 16, weight: .bold)).foregroundColor(Color(hex: 0x20180a))
                    .frame(maxWidth: .infinity).padding(.vertical, 17)
                    .background(Color.acc).clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                Text("Usar sin cuenta (solo este equipo)")
                    .font(.system(size: 15, weight: .semibold)).foregroundColor(.ink)
                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(Color.card).clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.line, lineWidth: 1))
                HStack(spacing: 4) {
                    Text("¿Ya tienes cuenta?").font(.system(size: 14)).foregroundColor(.pmut)
                    Text("Iniciar sesión").font(.system(size: 14, weight: .bold)).foregroundColor(.info)
                }
            }
            .padding(.horizontal, 22).padding(.bottom, 28)
        }
        .background(Color.card.ignoresSafeArea())
    }
}

// ── Acceso (login / registro) ───────────────────────────────────────────────
struct AccesoView: View {
    var registro = true
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Color.clear.frame(height: 40)
            Image(systemName: "chevron.left").font(.system(size: 17, weight: .bold)).foregroundColor(.ink)
                .frame(width: 40, height: 40).background(Color.card)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.line, lineWidth: 1))
            Text(registro ? "Crea tu cuenta" : "Bienvenido de vuelta")
                .font(.system(size: 27, weight: .heavy)).foregroundColor(.ink)
            Text(registro ? "Gratis, y podrás compartir libretas y verlas en la web."
                          : "Entra para ver tus libretas en todos tus equipos.")
                .font(.system(size: 14)).foregroundColor(.pmut).fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 12) {
                if registro { campo("Tu nombre") }
                campo("tucorreo@mail.com")
                campo("Contraseña")
            }
            .padding(.top, 4)

            Text(registro ? "Crear cuenta" : "Iniciar sesión")
                .font(.system(size: 16, weight: .bold)).foregroundColor(Color(hex: 0x20180a))
                .frame(maxWidth: .infinity).padding(.vertical, 17)
                .background(Color.acc).clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            HStack(spacing: 4) {
                Text(registro ? "¿Ya tienes cuenta?" : "¿Aún no tienes cuenta?").font(.system(size: 14)).foregroundColor(.pmut)
                Text(registro ? "Inicia sesión" : "Créala gratis").font(.system(size: 14, weight: .bold)).foregroundColor(.info)
            }
            .frame(maxWidth: .infinity)

            Spacer(minLength: 0)
            Text("Con cuenta puedes compartir libretas y ver lo mismo en la web. Sin cuenta, los datos quedan solo en este equipo.")
                .font(.system(size: 12)).foregroundColor(.pmut)
                .padding(14).background(Color.soft).clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
        }
        .padding(.horizontal, 24).padding(.bottom, 28)
        .background(Color.card.ignoresSafeArea())
    }
    private func campo(_ ph: String) -> some View {
        Text(ph).font(.system(size: 16)).foregroundColor(.pmut)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(15).background(Color.card)
            .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 13).stroke(Color.line, lineWidth: 1))
    }
}

// ── Selector de libreta (hoja para cambiar de libreta o crear una) ─────────
struct SelectorLibretaView: View {
    @EnvironmentObject var estado: AppEstado
    var onClose: () -> Void = {}
    @State private var nueva = false
    private let colores = ["#093a20", "#398ad6", "#825eb9", "#137d41", "#d55948"]

    var body: some View {
        ZStack(alignment: .bottom) {
            FondoAtenuado()
            VStack(spacing: 0) {
                cabecera
                VStack(spacing: 0) {
                    Grupo {
                        let libs = estado.datos.libretas
                        ForEach(libs.indices, id: \.self) { i in
                            Button {
                                estado.cambiarLibreta(libs[i].id); onClose()
                            } label: {
                                HStack(spacing: 12) {
                                    Text(String(libs[i].nombre.prefix(1)).uppercased())
                                        .font(.system(size: 12, weight: .heavy)).foregroundColor(.white)
                                        .frame(width: 30, height: 30).background(Color(hexString: colores[i % colores.count]))
                                        .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(libs[i].nombre).font(.system(size: 16, weight: .semibold)).foregroundColor(.ink)
                                        Text(libs[i].tipo).font(.system(size: 12)).foregroundColor(.pmut)
                                    }
                                    Spacer(minLength: 6)
                                    if libs[i].id == estado.datos.activa {
                                        Image(systemName: "checkmark").font(.system(size: 15, weight: .bold)).foregroundColor(.acc)
                                    }
                                }
                                .padding(.horizontal, 14).padding(.vertical, 11)
                            }
                            .buttonStyle(.plain)
                            if i < libs.count - 1 { Divisor(sangria: 56) }
                        }
                    }
                    Button { nueva = true } label: { BotonAncho(texto: "Nueva libreta", icono: "plus") }
                        .buttonStyle(.plain).padding(.top, 12)
                    Color.clear.frame(height: 34)
                }
                .padding(.horizontal, 16)
            }
            .comoHoja(grande: false)
        }
        .fullScreenCover(isPresented: $nueva) {
            AgregarLibretaView(onClose: { nueva = false }).environmentObject(estado)
        }
    }
    private var cabecera: some View {
        VStack(spacing: 0) {
            Capsule().fill(Color.line).frame(width: 40, height: 5).padding(.top, 8).padding(.bottom, 10)
            ZStack {
                Text("Tus libretas").font(.system(size: 17, weight: .bold)).foregroundColor(.ink)
                HStack { Button(action: onClose) { BotonCirculo(icono: "xmark") }.buttonStyle(.plain); Spacer() }
            }
            .padding(.horizontal, 16).padding(.bottom, 14)
        }
    }
}

// ── Agregar libreta ─────────────────────────────────────────────────────────
struct AgregarLibretaView: View {
    @EnvironmentObject var estado: AppEstado
    var onClose: () -> Void = {}
    @State private var nombre = ""
    @State private var tipo = 0
    private let tipos = ["Personal", "Negocio", "Familia", "Otra"]

    var body: some View {
        ZStack(alignment: .bottom) {
            FondoAtenuado()
            VStack(spacing: 0) {
                CabeceraHojaAcc(titulo: "Nueva libreta", onClose: onClose, guardar: guardar)
                VStack(alignment: .leading, spacing: 16) {
                    VStack(spacing: 6) {
                        SeccionTitulo(texto: "Nombre y tipo")
                        Grupo { CampoTexto(placeholder: "Negocio, Familia, Gelson…", texto: $nombre) }
                        SegmentoPildora(items: tipos, sel: $tipo)
                    }
                    NotaPie(texto: "Cada libreta es una contabilidad aparte que puedes compartir.")
                    Color.clear.frame(height: 24)
                }
                .padding(.horizontal, 16)
            }
            .comoHoja(grande: false)
        }
    }
    private func guardar() {
        estado.crearLibreta(nombre, tipo: tipos[tipo])
        onClose()
    }
}

// ── Invitar a alguien a la libreta ─────────────────────────────────────────
struct InvitacionView: View {
    @State private var rol = 1
    private let roles: [(String, String)] = [
        ("Dueño", "Controla todo, incluso borrar la libreta."),
        ("Editor", "Puede anotar y editar movimientos."),
        ("Solo ver", "Ve la libreta pero no cambia nada.")
    ]
    var body: some View {
        HojaCorta(titulo: "Invitar") {
            VStack(spacing: 6) {
                SeccionTitulo(texto: "¿A quién invitas?")
                Grupo {
                    FilaCampo(placeholder: "correo@persona.com")
                    Divisor(sangria: 16)
                    FilaCampo(placeholder: "Nombre")
                }
            }
            VStack(spacing: 8) {
                SeccionTitulo(texto: "Permiso")
                ForEach(roles.indices, id: \.self) { i in
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(roles[i].0).font(.system(size: 15, weight: .bold)).foregroundColor(.ink)
                            Text(roles[i].1).font(.system(size: 12)).foregroundColor(.pmut)
                        }
                        Spacer(minLength: 8)
                        Image(systemName: i == rol ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 20)).foregroundColor(i == rol ? .acc : Color.pmut.opacity(0.4))
                    }
                    .padding(.horizontal, 14).padding(.vertical, 11)
                    .background(i == rol ? Color.soft : Color.card)
                    .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 13).stroke(i == rol ? Color.acc.opacity(0.5) : Color.line, lineWidth: 1))
                    .onTapGesture { rol = i }
                }
            }
        }
    }
}
