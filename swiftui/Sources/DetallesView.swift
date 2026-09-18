import SwiftUI

// Pantallas de detalle (al tocar una cuenta, préstamo, tarjeta, meta o
// movimiento). Todas comparten la cabecera de color con la inicial, la tarjeta
// grande de cifras y, cuando aplica, el extracto por mes. Look nativo de iOS.

// Cabecera de color: ‹ volver + inicial en cuadro + nombre y subtítulo.
struct CabeceraDetalle: View {
    let inicial: String
    let nombre: String
    let sub: String
    var fondo: Color = .side
    var cuadro: Color = .info
    var volverA: String = "Cuentas"
    var body: some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: 44)
            HStack(spacing: 12) {
                HStack(spacing: 2) {
                    Image(systemName: "chevron.left").font(.system(size: 16, weight: .bold))
                    Text(volverA).font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(.white).opacity(0.9)
                Spacer(minLength: 0)
            }
            HStack(spacing: 12) {
                Text(inicial).font(.system(size: 15, weight: .heavy)).foregroundColor(.white)
                    .frame(width: 44, height: 44).background(cuadro)
                    .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                VStack(alignment: .leading, spacing: 2) {
                    Text(nombre).font(.system(size: 20, weight: .heavy)).foregroundColor(.white)
                    Text(sub).font(.system(size: 12.5)).foregroundColor(Color.white.opacity(0.8))
                }
                Spacer(minLength: 0)
            }
            .padding(.top, 12)
        }
        .padding(.horizontal, 16).padding(.bottom, 16)
        .background(fondo.ignoresSafeArea(edges: .top))
    }
}

// Tarjeta de cifra principal + dos columnas (entró / salió, etc.).
struct TarjetaCifra: View {
    let rotulo: String
    let valor: String
    var color: Color = .ink
    let cols: [(String, String, Color)]
    var body: some View {
        VStack(spacing: 14) {
            VStack(spacing: 3) {
                Text(rotulo).font(.system(size: 12.5, weight: .semibold)).foregroundColor(.pmut)
                Text(valor).font(.system(size: 32, weight: .heavy)).foregroundColor(color)
            }
            HStack(spacing: 0) {
                ForEach(cols.indices, id: \.self) { i in
                    VStack(spacing: 3) {
                        Text(cols[i].0).font(.system(size: 11, weight: .semibold)).foregroundColor(.pmut)
                        Text(cols[i].1).font(.system(size: 16, weight: .heavy)).foregroundColor(cols[i].2)
                    }
                    .frame(maxWidth: .infinity)
                    if i < cols.count - 1 { Rectangle().fill(Color.line).frame(width: 0.5, height: 30) }
                }
            }
        }
        .padding(.vertical, 18).padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background(Color.card).clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.line, lineWidth: 0.5))
    }
}

// Fila de un movimiento en el extracto.
struct FilaExtracto: View {
    let icono: String
    let tinte: Color
    let concepto: String
    let sub: String
    let monto: String
    let color: Color
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icono).font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                .frame(width: 34, height: 34).background(tinte).clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(concepto).font(.system(size: 15, weight: .semibold)).foregroundColor(.ink)
                Text(sub).font(.system(size: 11.5)).foregroundColor(.pmut)
            }
            Spacer(minLength: 6)
            Text(monto).font(.system(size: 15, weight: .heavy)).foregroundColor(color)
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
    }
}

// Grupo de extracto de un mes con su subtotal.
struct MesExtracto: View {
    let mes: String
    let total: String
    let filas: [(String, Color, String, String, String, Color)]
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(mes).font(.system(size: 12.5, weight: .heavy)).foregroundColor(.pmut)
                Spacer()
                Text(total).font(.system(size: 12.5, weight: .heavy)).foregroundColor(.pmut)
            }
            .padding(.horizontal, 4)
            Grupo {
                ForEach(filas.indices, id: \.self) { i in
                    FilaExtracto(icono: filas[i].0, tinte: filas[i].1, concepto: filas[i].2, sub: filas[i].3, monto: filas[i].4, color: filas[i].5)
                    if i < filas.count - 1 { Divisor(sangria: 60) }
                }
            }
        }
    }
}

private func cuerpoDetalle<C: View>(@ViewBuilder _ c: () -> C) -> some View {
    ScrollView(showsIndicators: false) {
        VStack(alignment: .leading, spacing: 14) { c(); Color.clear.frame(height: 40) }
            .padding(.horizontal, 16).padding(.top, 14)
    }
    .background(Color.scr.ignoresSafeArea())
}

// ── Detalle de cuenta ───────────────────────────────────────────────────────
struct DetalleCuentaView: View {
    var body: some View {
        VStack(spacing: 0) {
            CabeceraDetalle(inicial: "EF", nombre: "Efectivo", sub: "Sin banco · 32 movimientos", cuadro: .pos)
            cuerpoDetalle {
                TarjetaCifra(rotulo: "Saldo disponible", valor: "DOP 24,500", color: .ink,
                             cols: [("Entró este mes", "DOP 41,000", .pos), ("Salió este mes", "DOP 16,500", .neg)])
                HStack(spacing: 10) {
                    BotonAncho(texto: "Transferir", icono: "arrow.left.arrow.right")
                    BotonAncho(texto: "Nuevo", icono: "plus")
                }
                SeccionTitulo(texto: "Movimientos de esta cuenta")
                MesExtracto(mes: "Septiembre 2026", total: "+ DOP 24,500", filas: [
                    ("cart.fill", Color(hex: 0xe0a92e), "Supermercado", "Comida · 16 sep", "− DOP 2,300", .neg),
                    ("banknote.fill", .pos, "Salario", "Ingreso · 15 sep", "+ DOP 38,000", .pos),
                    ("bolt.fill", .info, "Luz", "Servicios · 12 sep", "− DOP 1,900", .neg)
                ])
                MesExtracto(mes: "Agosto 2026", total: "+ DOP 18,200", filas: [
                    ("fork.knife", .neg, "Restaurante", "Comida · 28 ago", "− DOP 1,450", .neg),
                    ("banknote.fill", .pos, "Salario", "Ingreso · 15 ago", "+ DOP 38,000", .pos)
                ])
            }
        }
    }
}

// ── Detalle de préstamo / fiado ────────────────────────────────────────────
struct DetallePrestamoView: View {
    var body: some View {
        VStack(spacing: 0) {
            CabeceraDetalle(inicial: "JU", nombre: "Juan", sub: "Le presté · vence 30 sep", fondo: Color(hex: 0x5a3fa0), cuadro: .sav, volverA: "Cuentas")
            cuerpoDetalle {
                TarjetaCifra(rotulo: "Te deben", valor: "DOP 3,000", color: .sav,
                             cols: [("Prestaste", "DOP 5,000", .ink), ("Ya te abonó", "DOP 2,000", .pos)])
                BotonAncho(texto: "Registrar un abono", icono: "plus")
                SeccionTitulo(texto: "Abonos")
                MesExtracto(mes: "Septiembre 2026", total: "DOP 2,000", filas: [
                    ("arrow.down.circle.fill", .pos, "Abono", "Efectivo · 14 sep", "+ DOP 1,200", .pos),
                    ("arrow.down.circle.fill", .pos, "Abono", "Efectivo · 5 sep", "+ DOP 800", .pos)
                ])
            }
        }
    }
}

// ── Detalle de tarjeta de crédito ──────────────────────────────────────────
struct DetalleTarjetaView: View {
    var body: some View {
        VStack(spacing: 0) {
            CabeceraDetalle(inicial: "VP", nombre: "Visa Popular", sub: "Corte 25 · Pago 5", fondo: Color(hex: 0x9a3f3f), cuadro: .neg)
            cuerpoDetalle {
                TarjetaCifra(rotulo: "Deuda actual", valor: "DOP 12,400", color: .neg,
                             cols: [("Límite", "DOP 50,000", .ink), ("Disponible", "DOP 37,600", .pos)])
                BotonAncho(texto: "Pagar la tarjeta", icono: "creditcard")
                SeccionTitulo(texto: "Consumos")
                MesExtracto(mes: "Septiembre 2026", total: "− DOP 5,600", filas: [
                    ("cart.fill", Color(hex: 0xe0a92e), "Supermercado", "Comida · 16 sep", "− DOP 3,200", .neg),
                    ("airplane", .info, "Vuelo", "Viajes · 8 sep", "− DOP 2,400", .neg)
                ])
            }
        }
    }
}

// ── Detalle de meta ─────────────────────────────────────────────────────────
struct DetalleMetaView: View {
    var body: some View {
        VStack(spacing: 0) {
            CabeceraDetalle(inicial: "✈", nombre: "Viaje a Punta Cana", sub: "Meta · vence dic 2026", fondo: Color(hex: 0x5a3fa0), cuadro: .sav, volverA: "Plan")
            cuerpoDetalle {
                VStack(spacing: 14) {
                    ZStack {
                        Circle().stroke(Color.soft, lineWidth: 12).frame(width: 128, height: 128)
                        Circle().trim(from: 0, to: 0.6)
                            .stroke(Color.sav, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                            .rotationEffect(.degrees(-90)).frame(width: 128, height: 128)
                        VStack(spacing: 1) {
                            Text("60%").font(.system(size: 28, weight: .heavy)).foregroundColor(.ink)
                            Text("logrado").font(.system(size: 11.5)).foregroundColor(.pmut)
                        }
                    }
                    .padding(.top, 4)
                    TarjetaCifra(rotulo: "Ahorrado", valor: "DOP 30,000", color: .sav,
                                 cols: [("Objetivo", "DOP 50,000", .ink), ("Te falta", "DOP 20,000", .neg)])
                }
                BotonAncho(texto: "Aportar a la meta", icono: "plus")
                SeccionTitulo(texto: "Aportes")
                MesExtracto(mes: "Septiembre 2026", total: "DOP 8,000", filas: [
                    ("arrow.up.circle.fill", .sav, "Aporte", "Ahorros · 12 sep", "+ DOP 5,000", .sav),
                    ("arrow.up.circle.fill", .sav, "Aporte", "Ahorros · 2 sep", "+ DOP 3,000", .sav)
                ])
            }
        }
    }
}

// ── Detalle de un movimiento (con acciones) ────────────────────────────────
struct DetalleMovimientoView: View {
    var body: some View {
        VStack(spacing: 0) {
            CabeceraDetalle(inicial: "SU", nombre: "Supermercado", sub: "Gasto · 16 sep 2026", fondo: Color(hex: 0x7a5f10), cuadro: Color(hex: 0xe0a92e), volverA: "Movimientos")
            cuerpoDetalle {
                VStack(spacing: 3) {
                    Text("MONTO").font(.system(size: 11, weight: .semibold)).tracking(0.4).foregroundColor(.pmut)
                    Text("− DOP 2,300").font(.system(size: 34, weight: .heavy)).foregroundColor(.neg)
                }
                .frame(maxWidth: .infinity).padding(.vertical, 18)
                .background(Color.card).clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.line, lineWidth: 0.5))

                Grupo {
                    FilaNav(icono: "tag.fill", tinte: Color(hex: 0xe0a92e), titulo: "Categoría", valor: "Comida")
                    Divisor()
                    FilaNav(icono: "banknote.fill", tinte: .pos, titulo: "Pagado con", valor: "Efectivo")
                    Divisor()
                    FilaNav(icono: "calendar", tinte: .neg, titulo: "Fecha", valor: "16/09/2026")
                    Divisor()
                    FilaNav(icono: "repeat", tinte: .sav, titulo: "Se repite", valor: "No")
                }

                VStack(spacing: 10) {
                    BotonAncho(texto: "Editar movimiento", icono: "pencil")
                    HStack(spacing: 10) {
                        accion("Duplicar", "plus.square.on.square", .info)
                        accion("Eliminar", "trash", .neg)
                    }
                }
                .padding(.top, 4)
            }
        }
    }
    private func accion(_ t: String, _ ic: String, _ c: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: ic).font(.system(size: 14, weight: .bold))
            Text(t).font(.system(size: 14, weight: .semibold))
        }
        .foregroundColor(c).frame(maxWidth: .infinity).padding(.vertical, 13)
        .background(Color.card).clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 13).stroke(c.opacity(0.3), lineWidth: 1))
    }
}
