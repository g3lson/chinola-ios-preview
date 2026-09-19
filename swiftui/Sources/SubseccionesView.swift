import SwiftUI

// Subsecciones del Perfil, cada una como una pantalla nativa que «entra» desde
// la derecha con su cabecera de volver (‹ Perfil), grupos redondeados e iconos
// SF en cuadros de color. Se sienten del sistema, no de una web.

// Cabecera con botón de volver (‹) + título, estilo navegación de iOS.
struct CabeceraAtras: View {
    let titulo: String
    var atras: String = "Perfil"
    var body: some View {
        HStack(spacing: 2) {
            HStack(spacing: 2) {
                Image(systemName: "chevron.left").font(.system(size: 17, weight: .semibold))
                Text(atras).font(.system(size: 17))
            }
            .foregroundColor(.info)
            Spacer()
        }
        .overlay(Text(titulo).font(.system(size: 17, weight: .bold)).foregroundColor(.ink))
        .padding(.horizontal, 14)
        .padding(.top, 8).padding(.bottom, 10)
    }
}

// Envoltura común: cabecera de volver fija + scroll con los grupos.
struct PantallaSub<Contenido: View>: View {
    let titulo: String
    @ViewBuilder var contenido: Contenido
    var body: some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: 44)   // deja pasar la isla dinámica
            CabeceraAtras(titulo: titulo)
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    contenido
                    Color.clear.frame(height: 40)
                }
                .padding(.horizontal, 16)
            }
        }
        .background(Color.scr.ignoresSafeArea())
    }
}

// ── Libretas y permisos ─────────────────────────────────────────────────────
struct LibretasView: View {
    private let libretas: [(String, String, String, Color)] = [
        ("P", "Personal", "Solo yo · Dueño", .side),
        ("N", "Negocio", "3 miembros · Dueño", .info),
        ("F", "Familia", "2 miembros · Editor", .sav)
    ]
    var body: some View {
        PantallaSub(titulo: "Libretas") {
            SeccionTitulo(texto: "Tus libretas")
            Grupo {
                ForEach(libretas.indices, id: \.self) { i in
                    HStack(spacing: 12) {
                        Text(libretas[i].0)
                            .font(.system(size: 13, weight: .heavy)).foregroundColor(.white)
                            .frame(width: 34, height: 34).background(libretas[i].3)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(libretas[i].1).font(.system(size: 16)).foregroundColor(.ink)
                            Text(libretas[i].2).font(.system(size: 12.5)).foregroundColor(.pmut)
                        }
                        Spacer(minLength: 8)
                        Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundColor(Color.pmut.opacity(0.6))
                    }
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    if i < libretas.count - 1 { Divisor(sangria: 60) }
                }
            }
            BotonAncho(texto: "Nueva libreta", icono: "plus")
            NotaPie(texto: "Cada libreta es una contabilidad aparte. Puedes compartirla e invitar gente con distintos permisos.")
        }
    }
}

// ── Detalle de una libreta (miembros, roles, invitar) ──────────────────────
struct LibretaDetalleView: View {
    private let kpis: [(String, String, Color)] = [
        ("SALDO", "RD$84,200", .pos),
        ("ESTE MES", "+ RD$12,400", .pos),
        ("MOVIMIENTOS", "148", .ink),
        ("MIEMBROS", "3", .ink)
    ]
    private let miembros: [(String, String, String, String, Color)] = [
        ("G", "Gelson (tú)", "gelson@correo.com", "Dueño", .side),
        ("M", "María", "maria@correo.com", "Editor", .sav),
        ("J", "José", "jose@correo.com", "Solo ver", .info)
    ]
    var body: some View {
        VStack(spacing: 0) {
            // Cabecera de color con la inicial de la libreta.
            VStack(spacing: 0) {
                Color.clear.frame(height: 44)
                HStack(spacing: 12) {
                    Image(systemName: "chevron.left").font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white).frame(width: 34, height: 34)
                        .background(Color.white.opacity(0.14)).clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                    Text("N").font(.system(size: 13, weight: .heavy)).foregroundColor(.white)
                        .frame(width: 38, height: 38).background(Color.info)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Negocio").font(.system(size: 18, weight: .heavy)).foregroundColor(.white)
                        Text("Compartida · Dueño").font(.system(size: 11.5)).foregroundColor(Color.white.opacity(0.8))
                    }
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 16).padding(.bottom, 14)
            }
            .background(Color.side.ignoresSafeArea(edges: .top))

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                        ForEach(kpis.indices, id: \.self) { i in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(kpis[i].0).font(.system(size: 10, weight: .heavy)).tracking(0.5).foregroundColor(.pmut)
                                Text(kpis[i].1).font(.system(size: 18, weight: .heavy)).foregroundColor(kpis[i].2)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(13).background(Color.card)
                            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.line, lineWidth: 0.5))
                        }
                    }
                    .padding(.top, 14)

                    BotonAncho(texto: "Abrir esta libreta", icono: "arrow.right")

                    HStack {
                        Text("Miembros").font(.system(size: 15, weight: .bold)).foregroundColor(.ink)
                        Text("3").font(.system(size: 12, weight: .semibold)).foregroundColor(.pmut)
                        Spacer()
                        Image(systemName: "person.badge.plus").font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.info).frame(width: 32, height: 32)
                            .background(.ultraThinMaterial, in: Circle())
                            .overlay(Circle().stroke(Color.line, lineWidth: 0.6))
                    }
                    .padding(.top, 4)

                    Grupo {
                        ForEach(miembros.indices, id: \.self) { i in
                            HStack(spacing: 11) {
                                Text(miembros[i].0).font(.system(size: 11, weight: .heavy)).foregroundColor(.white)
                                    .frame(width: 32, height: 32).background(miembros[i].4).clipShape(Circle())
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(miembros[i].1).font(.system(size: 14, weight: .semibold)).foregroundColor(.ink)
                                    Text(miembros[i].2).font(.system(size: 11.5)).foregroundColor(.pmut)
                                }
                                Spacer(minLength: 6)
                                Text(miembros[i].3).font(.system(size: 12, weight: .semibold)).foregroundColor(.pmut)
                                    .padding(.horizontal, 9).padding(.vertical, 5)
                                    .background(Color.soft).clipShape(Capsule())
                            }
                            .padding(.horizontal, 13).padding(.vertical, 9)
                            if i < miembros.count - 1 { Divisor(sangria: 56) }
                        }
                    }

                    Text("Eliminar libreta")
                        .font(.system(size: 14, weight: .semibold)).foregroundColor(.neg)
                        .frame(maxWidth: .infinity).padding(.vertical, 13)
                        .background(Color.card).clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 13).stroke(Color.neg.opacity(0.3), lineWidth: 1))
                        .padding(.top, 4)

                    Color.clear.frame(height: 40)
                }
                .padding(.horizontal, 16)
            }
        }
        .background(Color.scr.ignoresSafeArea())
    }
}

// ── Idioma ──────────────────────────────────────────────────────────────────
struct IdiomaView: View {
    @State private var sel = 0
    private let idiomas = ["Español", "English", "Français", "Português"]
    var body: some View {
        PantallaSub(titulo: "Idioma") {
            SeccionTitulo(texto: "Elige el idioma de la app")
            Grupo {
                ForEach(idiomas.indices, id: \.self) { i in
                    HStack(spacing: 12) {
                        Text(idiomas[i]).font(.system(size: 16)).foregroundColor(.ink)
                        Spacer()
                        if i == sel {
                            Image(systemName: "checkmark").font(.system(size: 15, weight: .bold)).foregroundColor(.info)
                        }
                    }
                    .padding(.horizontal, 15).padding(.vertical, 13)
                    .onTapGesture { sel = i }
                    if i < idiomas.count - 1 { Divisor(sangria: 15) }
                }
            }
        }
    }
}

// ── Notificaciones ──────────────────────────────────────────────────────────
struct NotificacionesView: View {
    @State private var pagos = true
    @State private var resumen = false
    var body: some View {
        PantallaSub(titulo: "Notificaciones") {
            VStack(spacing: 6) {
                SeccionTitulo(texto: "Avisos")
                Grupo {
                    FilaToggle(icono: "bell.badge.fill", tinte: .neg, titulo: "Avisos de pago", on: $pagos)
                    Divisor()
                    FilaToggle(icono: "chart.bar.fill", tinte: .info, titulo: "Resumen semanal", on: $resumen)
                }
                NotaPie(texto: "Los avisos de pago los da la app instalada. Te avisamos el día de cada préstamo o tarjeta con fecha.")
            }
        }
    }
}
