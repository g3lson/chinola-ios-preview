import SwiftUI

// Formularios de «agregar» y «editar» con el look nativo de iOS: todos comparten
// la misma cabecera de hoja (asa + × / título / ✓), los grupos redondeados y el
// bloque de monto grande. Iconos SF para que se sientan del sistema.

// Bloque de monto grande (— DOP 0 +), como en «Nuevo movimiento».
struct MontoBloque: View {
    var moneda: String = "DOP"
    var valor: String = "0"
    var body: some View {
        Grupo {
            HStack {
                botonRedondo("minus")
                Spacer()
                VStack(spacing: 1) {
                    Text("MONTO").font(.system(size: 11, weight: .semibold)).tracking(0.4).foregroundColor(.pmut)
                    Text("\(moneda) \(valor)").font(.system(size: 30, weight: .heavy)).foregroundColor(.ink)
                }
                Spacer()
                botonRedondo("plus")
            }
            .padding(.horizontal, 12).padding(.vertical, 12)
        }
    }
    private func botonRedondo(_ ic: String) -> some View {
        Image(systemName: ic).font(.system(size: 17, weight: .bold)).foregroundColor(.ink)
            .frame(width: 42, height: 42).background(Color.soft).clipShape(Circle())
    }
}

// Segmento en cápsula (dos o más opciones), como el de «Nuevo movimiento».
struct SegmentoPildora: View {
    let items: [String]
    @Binding var sel: Int
    var body: some View {
        HStack(spacing: 4) {
            ForEach(items.indices, id: \.self) { i in
                Text(items[i])
                    .font(.system(size: 13.5, weight: i == sel ? .bold : .semibold))
                    .foregroundColor(i == sel ? .white : .pmut)
                    .frame(maxWidth: .infinity).padding(.vertical, 9)
                    .background(i == sel ? Color.side : Color.clear)
                    .clipShape(Capsule())
                    .onTapGesture { sel = i }
            }
        }
        .padding(4).background(Color.soft).clipShape(Capsule())
    }
}

// Cuerpo de hoja reutilizable: cabecera fija + scroll + botón guardar abajo.
struct HojaForm<Contenido: View>: View {
    let titulo: String
    var guardar: String? = nil
    @ViewBuilder var contenido: Contenido
    var body: some View {
        ZStack(alignment: .bottom) {
            FondoAtenuado()
            VStack(spacing: 0) {
                CabeceraHoja(titulo: titulo, conCheck: true)
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        contenido
                        Color.clear.frame(height: 40)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .comoHoja()
        }
    }
}

// ── Transferencia entre cuentas ────────────────────────────────────────────
struct TransferenciaView: View {
    var body: some View {
        HojaForm(titulo: "Transferencia") {
            MontoBloque()
            VStack(spacing: 6) {
                SeccionTitulo(texto: "De dónde y hacia dónde")
                Grupo {
                    FilaNav(icono: "banknote.fill", tinte: .pos, titulo: "Desde", valor: "Efectivo")
                    Divisor()
                    FilaNav(icono: "building.columns.fill", tinte: .info, titulo: "Hacia", valor: "Banco Popular")
                }
            }
            VStack(spacing: 6) {
                SeccionTitulo(texto: "Detalles")
                Grupo {
                    FilaNav(icono: "calendar", tinte: .neg, titulo: "Fecha", valor: "18/09/2026")
                    Divisor(sangria: 16)
                    FilaCampo(placeholder: "Nota (opcional)")
                }
            }
        }
    }
}

// ── Préstamo / fiado (agregar y editar) ────────────────────────────────────
struct PrestamoView: View {
    var editar = false
    @State private var lado = 0   // 0 = presté · 1 = me prestaron
    var body: some View {
        HojaForm(titulo: editar ? "Editar el préstamo" : "Préstamo o fiado") {
            SegmentoPildora(items: ["Yo presté", "Me prestaron"], sel: $lado)
            MontoBloque()
            VStack(spacing: 6) {
                SeccionTitulo(texto: lado == 0 ? "¿A quién le prestaste?" : "¿Quién te prestó?")
                Grupo {
                    FilaCampo(placeholder: "Nombre de la persona")
                    Divisor(sangria: 16)
                    FilaCampo(placeholder: "Concepto (ej. fiado colmado)")
                }
            }
            VStack(spacing: 6) {
                SeccionTitulo(texto: "Fechas y cuenta")
                Grupo {
                    FilaNav(icono: "calendar", tinte: .neg, titulo: "Fecha", valor: "18/09/2026")
                    Divisor()
                    FilaNav(icono: "calendar.badge.clock", tinte: Color(hex: 0xe0a92e), titulo: "Fecha límite", valor: "Sin fecha")
                    Divisor()
                    FilaNav(icono: "banknote.fill", tinte: .info, titulo: "Cuenta", valor: "Efectivo")
                }
            }
        }
    }
}

// ── Abono a un préstamo ─────────────────────────────────────────────────────
struct AbonoView: View {
    var body: some View {
        HojaForm(titulo: "Registrar un abono") {
            MontoBloque()
            VStack(spacing: 6) {
                SeccionTitulo(texto: "¿A cuál préstamo?")
                Grupo {
                    FilaNav(icono: "hand.raised.fill", tinte: .sav, titulo: "Préstamo", valor: "Juan · DOP 5,000")
                    Divisor()
                    FilaNav(icono: "banknote.fill", tinte: .pos, titulo: "Entra a", valor: "Efectivo")
                    Divisor()
                    FilaNav(icono: "calendar", tinte: .neg, titulo: "Fecha", valor: "18/09/2026")
                }
                NotaPie(texto: "El saldo del préstamo baja automáticamente con cada abono.")
            }
        }
    }
}

// ── Aporte a una meta ───────────────────────────────────────────────────────
struct AporteView: View {
    var body: some View {
        HojaForm(titulo: "Aportar a la meta") {
            MontoBloque()
            VStack(spacing: 6) {
                SeccionTitulo(texto: "¿A cuál meta?")
                Grupo {
                    FilaNav(icono: "target", tinte: .sav, titulo: "Meta", valor: "Viaje · 60%")
                    Divisor()
                    FilaNav(icono: "banknote.fill", tinte: .pos, titulo: "Sale de", valor: "Ahorros")
                    Divisor()
                    FilaNav(icono: "calendar", tinte: .neg, titulo: "Fecha", valor: "18/09/2026")
                }
                NotaPie(texto: "Cada aporte acerca la meta a su objetivo.")
            }
        }
    }
}

// ── Meta de ahorro (agregar y editar) ──────────────────────────────────────
struct MetaView: View {
    var editar = false
    var body: some View {
        HojaForm(titulo: editar ? "Editar la meta" : "Nueva meta") {
            VStack(spacing: 6) {
                SeccionTitulo(texto: "¿Qué quieres lograr?")
                Grupo {
                    FilaCampo(placeholder: "Nombre (ej. Viaje a Punta Cana)")
                    Divisor(sangria: 16)
                    FilaCampo(placeholder: "¿Cuánto necesitas?")
                    Divisor(sangria: 16)
                    FilaCampo(placeholder: "Ya tienes ahorrado (opcional)")
                }
            }
            VStack(spacing: 6) {
                SeccionTitulo(texto: "Fecha e imagen")
                Grupo {
                    FilaNav(icono: "calendar.badge.clock", tinte: .neg, titulo: "Fecha límite", valor: "Sin fecha")
                    Divisor()
                    FilaNav(icono: "target", tinte: .sav, titulo: "Icono", valor: "Meta")
                    Divisor()
                    FilaNav(icono: "paintpalette.fill", tinte: Color(hex: 0xe0a92e), titulo: "Color", valor: "Morado")
                }
            }
        }
    }
}

// ── Tarjeta de crédito (agregar y editar) ──────────────────────────────────
struct TarjetaView: View {
    var editar = false
    var body: some View {
        HojaForm(titulo: editar ? "Editar la tarjeta" : "Nueva tarjeta") {
            VStack(spacing: 6) {
                SeccionTitulo(texto: "Datos de la tarjeta")
                Grupo {
                    FilaCampo(placeholder: "Nombre (ej. Visa Popular)")
                    Divisor(sangria: 16)
                    FilaCampo(placeholder: "Banco (opcional)")
                    Divisor(sangria: 16)
                    FilaCampo(placeholder: "Límite de crédito")
                    Divisor(sangria: 16)
                    FilaCampo(placeholder: "Deuda actual (opcional)")
                }
            }
            VStack(spacing: 6) {
                SeccionTitulo(texto: "Fechas y color")
                Grupo {
                    FilaNav(icono: "scissors", tinte: .neg, titulo: "Día de corte", valor: "25")
                    Divisor()
                    FilaNav(icono: "calendar.badge.exclamationmark", tinte: Color(hex: 0xe0a92e), titulo: "Día de pago", valor: "5")
                    Divisor()
                    FilaNav(icono: "paintpalette.fill", tinte: .sav, titulo: "Color", valor: "Rojo")
                }
            }
        }
    }
}

// ── Pago de tarjeta ─────────────────────────────────────────────────────────
struct PagoTarjetaView: View {
    var body: some View {
        HojaForm(titulo: "Pagar la tarjeta") {
            MontoBloque()
            VStack(spacing: 6) {
                SeccionTitulo(texto: "Detalles del pago")
                Grupo {
                    FilaNav(icono: "creditcard.fill", tinte: .neg, titulo: "Tarjeta", valor: "Visa · DOP 12,400")
                    Divisor()
                    FilaNav(icono: "banknote.fill", tinte: .pos, titulo: "Pagas desde", valor: "Efectivo")
                    Divisor()
                    FilaNav(icono: "calendar", tinte: .info, titulo: "Fecha", valor: "18/09/2026")
                }
                NotaPie(texto: "El pago baja la deuda de la tarjeta y sale de la cuenta elegida.")
            }
        }
    }
}

// ── Categoría (nombre, tipo, límite, color e icono) ────────────────────────
struct CategoriaView: View {
    @State private var tipo = 0
    @State private var color = 3
    @State private var icono = 0
    private let colores: [Color] = [.pos, .neg, .info, .sav, Color(hex: 0xe0a92e), Color(hex: 0x1fa9a0), Color(hex: 0xd55948)]
    private let iconos = ["cart.fill", "fork.knife", "car.fill", "house.fill", "bolt.fill", "cross.case.fill",
                          "gamecontroller.fill", "gift.fill", "airplane", "book.fill", "tshirt.fill", "pawprint.fill"]
    var body: some View {
        HojaForm(titulo: "Nueva categoría") {
            SegmentoPildora(items: ["Gasto", "Ingreso"], sel: $tipo)
            VStack(spacing: 6) {
                SeccionTitulo(texto: "Nombre y tope")
                Grupo {
                    FilaCampo(placeholder: "Nombre (ej. Supermercado)")
                    Divisor(sangria: 16)
                    FilaCampo(placeholder: "Tope mensual (opcional)")
                }
            }
            VStack(spacing: 8) {
                SeccionTitulo(texto: "Color")
                HStack(spacing: 10) {
                    ForEach(colores.indices, id: \.self) { i in
                        Circle().fill(colores[i]).frame(width: 30, height: 30)
                            .overlay(Circle().stroke(Color.ink, lineWidth: i == color ? 2.5 : 0).padding(-3))
                            .onTapGesture { color = i }
                    }
                    Spacer(minLength: 0)
                }
            }
            VStack(spacing: 8) {
                SeccionTitulo(texto: "Icono")
                Grupo {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 5), spacing: 10) {
                        ForEach(iconos.indices, id: \.self) { i in
                            Image(systemName: iconos[i])
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(i == icono ? .white : .pmut)
                                .frame(width: 46, height: 46)
                                .background(i == icono ? colores[color] : Color.soft)
                                .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                                .onTapGesture { icono = i }
                        }
                    }
                    .padding(12)
                }
            }
        }
    }
}
