import SwiftUI

// Pantallas de detalle (al tocar una cuenta, tarjeta, préstamo, meta o
// movimiento): cabecera de color, tarjeta de cifras reales, acciones y el
// extracto. Leen el item real del estado por su id.

// Cabecera de color: ‹ volver + inicial + nombre y subtítulo.
struct CabeceraDetalle: View {
    let inicial: String
    let nombre: String
    let sub: String
    var fondo: Color = .side
    var cuadro: Color = .info
    var volverA: String = "Cuentas"
    var onClose: () -> Void = {}
    var body: some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: 44)
            HStack(spacing: 12) {
                Button(action: onClose) {
                    HStack(spacing: 2) {
                        Image(systemName: "chevron.left").font(.system(size: 16, weight: .bold))
                        Text(volverA).font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(.white).opacity(0.9)
                }
                .buttonStyle(.plain)
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

// Tarjeta de cifra principal + columnas.
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

private func cuerpoDetalle<C: View>(@ViewBuilder _ c: () -> C) -> some View {
    ScrollView(showsIndicators: false) {
        VStack(alignment: .leading, spacing: 14) { c(); Color.clear.frame(height: 40) }
            .padding(.horizontal, 16).padding(.top, 14)
    }
    .background(Color.scr.ignoresSafeArea())
}

private func inicialDe(_ s: String) -> String {
    let p = s.split(separator: " ").prefix(2).compactMap { $0.first }
    return String(p).uppercased()
}

// Fila de un movimiento en el extracto.
private struct FilaMovDet: View {
    let m: Movimiento
    let esta: String   // medio de esta cuenta, para saber si entra o sale
    var body: some View {
        let entra = m.tipo == .ingreso || (m.tipo == .transferencia && m.destino == esta)
        let color: Color = entra ? .pos : .neg
        return HStack(spacing: 12) {
            Image(systemName: m.tipo == .transferencia ? "arrow.left.arrow.right" : (entra ? "arrow.down" : "arrow.up"))
                .font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                .frame(width: 32, height: 32).background(color).clipShape(Circle())
            VStack(alignment: .leading, spacing: 1) {
                Text(m.concepto).font(.system(size: 15, weight: .semibold)).foregroundColor(.ink)
                Text("\(m.categoria) · \(fechaCorta(m.fecha))").font(.system(size: 11.5)).foregroundColor(.pmut)
            }
            Spacer(minLength: 6)
            Text((entra ? "+ " : "− ") + fmtDinero(m.monto)).font(.system(size: 15, weight: .heavy)).foregroundColor(color)
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
    }
}

// ── Detalle de cuenta ───────────────────────────────────────────────────────
struct DetalleCuentaView: View {
    @EnvironmentObject var estado: AppEstado
    var cuentaId: Int = 1
    var onClose: () -> Void = {}

    var body: some View {
        let medio = "cuenta:\(cuentaId)"
        let c = estado.libreta.cuentas.first { $0.id == cuentaId }
        let movs = estado.movimientosDe(medio)
        let mes = String(Movimiento.hoy().prefix(7))
        let delMes = movs.filter { String($0.fecha.prefix(7)) == mes }
        let entra = delMes.filter { $0.tipo == .ingreso || ($0.tipo == .transferencia && $0.destino == medio) }.reduce(0) { $0 + abs($1.monto) }
        let sale = delMes.filter { $0.tipo.esGasto || $0.tipo == .ahorro || ($0.tipo == .transferencia && $0.medio == medio) }.reduce(0) { $0 + abs($1.monto) }
        return VStack(spacing: 0) {
            CabeceraDetalle(inicial: inicialDe(c?.nombre ?? "?"), nombre: c?.nombre ?? "Cuenta",
                            sub: (c?.banco.isEmpty ?? true ? "Sin banco" : c!.banco) + " · \(movs.count) mov.",
                            cuadro: Color(hexString: c?.color ?? "#137d41"), onClose: onClose)
            cuerpoDetalle {
                TarjetaCifra(rotulo: "Saldo disponible", valor: fmtDinero(c?.saldo ?? 0), color: .ink,
                             cols: [("Entró este mes", fmtDinero(entra), .pos), ("Salió este mes", fmtDinero(sale), .neg)])
                SeccionTitulo(texto: "Movimientos de esta cuenta")
                if movs.isEmpty {
                    VacioCard(titulo: "Sin movimientos", detalle: "Lo que anotes con esta cuenta saldrá aquí.")
                } else {
                    Grupo {
                        ForEach(movs.indices, id: \.self) { i in
                            FilaMovDet(m: movs[i], esta: medio)
                            if i < movs.count - 1 { Divisor(sangria: 58) }
                        }
                    }
                }
            }
        }
    }
}

// ── Detalle de préstamo / fiado ────────────────────────────────────────────
struct DetallePrestamoView: View {
    @EnvironmentObject var estado: AppEstado
    var prestamoId: Int = 1
    var onClose: () -> Void = {}
    @State private var abono = false

    var body: some View {
        let p = estado.libreta.prestamos.first { $0.id == prestamoId }
        let meDeben = (p?.sentido ?? "meDeben") == "meDeben"
        return VStack(spacing: 0) {
            CabeceraDetalle(inicial: inicialDe(p?.nombre ?? "?"), nombre: p?.nombre ?? "Préstamo",
                            sub: meDeben ? "Te debe" : "Le debes",
                            fondo: Color(hex: 0x5a3fa0), cuadro: .sav, onClose: onClose)
            cuerpoDetalle {
                TarjetaCifra(rotulo: meDeben ? "Te deben" : "Debes", valor: fmtDinero(p?.pendiente ?? 0), color: .sav,
                             cols: [(meDeben ? "Prestaste" : "Te prestaron", fmtDinero(p?.total ?? 0), .ink),
                                    ("Ya \(meDeben ? "abonó" : "abonaste")", fmtDinero(p?.pagado ?? 0), .pos)])
                Button { abono = true } label: { BotonAncho(texto: "Registrar un abono", icono: "plus") }.buttonStyle(.plain)
                NotaPie(texto: "Cada abono baja el saldo del préstamo y mueve tu cuenta.")
            }
        }
        .fullScreenCover(isPresented: $abono) {
            AbonoView(prestamoId: prestamoId, onClose: { abono = false }).environmentObject(estado)
        }
    }
}

// ── Detalle de tarjeta ──────────────────────────────────────────────────────
struct DetalleTarjetaView: View {
    @EnvironmentObject var estado: AppEstado
    var tarjetaId: Int = 1
    var onClose: () -> Void = {}
    @State private var pago = false

    var body: some View {
        let t = estado.libreta.tarjetas.first { $0.id == tarjetaId }
        return VStack(spacing: 0) {
            CabeceraDetalle(inicial: inicialDe(t?.nombre ?? "?"), nombre: t?.nombre ?? "Tarjeta",
                            sub: "Corte \(t?.corte ?? 0) · Pago \(t?.pago ?? 0)",
                            fondo: Color(hex: 0x9a3f3f), cuadro: .neg, onClose: onClose)
            cuerpoDetalle {
                TarjetaCifra(rotulo: "Deuda actual", valor: fmtDinero(t?.saldo ?? 0), color: .neg,
                             cols: [("Límite", fmtDinero(t?.limite ?? 0), .ink), ("Disponible", fmtDinero(t?.disponible ?? 0), .pos)])
                Button { pago = true } label: { BotonAncho(texto: "Pagar la tarjeta", icono: "creditcard") }.buttonStyle(.plain)
                NotaPie(texto: "El pago baja la deuda y sale de la cuenta que elijas.")
            }
        }
        .fullScreenCover(isPresented: $pago) {
            PagoTarjetaView(tarjetaId: tarjetaId, onClose: { pago = false }).environmentObject(estado)
        }
    }
}

// ── Detalle de meta ─────────────────────────────────────────────────────────
struct DetalleMetaView: View {
    @EnvironmentObject var estado: AppEstado
    var metaId: Int = 1
    var onClose: () -> Void = {}
    @State private var aporte = false

    var body: some View {
        let m = estado.libreta.metas.first { $0.id == metaId }
        let prog = m?.progreso ?? 0
        return VStack(spacing: 0) {
            CabeceraDetalle(inicial: "◎", nombre: m?.nombre ?? "Meta", sub: "Meta de ahorro",
                            fondo: Color(hex: 0x5a3fa0), cuadro: .sav, volverA: "Plan", onClose: onClose)
            cuerpoDetalle {
                VStack(spacing: 14) {
                    ZStack {
                        Circle().stroke(Color.soft, lineWidth: 12).frame(width: 128, height: 128)
                        Circle().trim(from: 0, to: CGFloat(prog))
                            .stroke(Color.sav, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                            .rotationEffect(.degrees(-90)).frame(width: 128, height: 128)
                        VStack(spacing: 1) {
                            Text("\(Int(prog * 100))%").font(.system(size: 28, weight: .heavy)).foregroundColor(.ink)
                            Text("logrado").font(.system(size: 11.5)).foregroundColor(.pmut)
                        }
                    }
                    .padding(.top, 4)
                    TarjetaCifra(rotulo: "Ahorrado", valor: fmtDinero(m?.ahorrado ?? 0), color: .sav,
                                 cols: [("Objetivo", fmtDinero(m?.meta ?? 0), .ink),
                                        ("Te falta", fmtDinero(max(0, (m?.meta ?? 0) - (m?.ahorrado ?? 0))), .neg)])
                }
                Button { aporte = true } label: { BotonAncho(texto: "Aportar a la meta", icono: "plus") }.buttonStyle(.plain)
            }
        }
        .fullScreenCover(isPresented: $aporte) {
            AporteView(metaId: metaId, onClose: { aporte = false }).environmentObject(estado)
        }
    }
}

// ── Detalle de un movimiento (con borrar) ──────────────────────────────────
struct DetalleMovimientoView: View {
    @EnvironmentObject var estado: AppEstado
    var movId: String = "s2"
    var onClose: () -> Void = {}

    var body: some View {
        let m = estado.libreta.tx.first { $0.id == movId }
        let entra = m?.tipo == .ingreso
        return VStack(spacing: 0) {
            CabeceraDetalle(inicial: inicialDe(m?.concepto ?? "?"), nombre: m?.concepto ?? "Movimiento",
                            sub: "\(m?.categoria ?? "") · \(fechaCorta(m?.fecha ?? ""))",
                            fondo: Color(hex: 0x7a5f10), cuadro: Color(hex: 0xe0a92e), volverA: "Movimientos", onClose: onClose)
            cuerpoDetalle {
                VStack(spacing: 3) {
                    Text("MONTO").font(.system(size: 11, weight: .semibold)).tracking(0.4).foregroundColor(.pmut)
                    Text((entra ? "+ " : "− ") + fmtDinero(m?.monto ?? 0)).font(.system(size: 34, weight: .heavy))
                        .foregroundColor(entra ? .pos : .neg)
                }
                .frame(maxWidth: .infinity).padding(.vertical, 18)
                .background(Color.card).clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.line, lineWidth: 0.5))

                Grupo {
                    FilaNav(icono: "tag.fill", tinte: Color(hex: 0xe0a92e), titulo: "Categoría", valor: m?.categoria ?? "")
                    Divisor()
                    FilaNav(icono: "banknote.fill", tinte: .pos, titulo: "Cuenta", valor: estado.nombreMedio(m?.medio ?? ""))
                    Divisor()
                    FilaNav(icono: "calendar", tinte: .neg, titulo: "Fecha", valor: fechaCorta(m?.fecha ?? ""))
                    Divisor()
                    FilaNav(icono: "repeat", tinte: .sav, titulo: "Se repite", valor: (m?.recurrente ?? false) ? "Sí" : "No")
                }

                Button {
                    if let m = m { estado.borrar(m) }
                    onClose()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "trash").font(.system(size: 14, weight: .bold))
                        Text("Eliminar movimiento").font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(.neg).frame(maxWidth: .infinity).padding(.vertical, 14)
                    .background(Color.card).clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 13).stroke(Color.neg.opacity(0.3), lineWidth: 1))
                }
                .buttonStyle(.plain).padding(.top, 4)
            }
        }
    }
}
