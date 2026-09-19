import SwiftUI

// Pantalla «Cuentas», igual que la app: tarjeta de Patrimonio y luego tres
// secciones con encabezado en MAYÚSCULAS —Cuentas, Tarjetas de crédito,
// Préstamos y fiados—, cada una una tarjeta con sus filas (o su texto vacío).
struct CuentasView: View {
    @EnvironmentObject var estado: AppEstado
    @State private var oculto = false
    var abrirTendencia: () -> Void = {}
    var onNuevo: () -> Void = {}
    var onDetalle: (DetalleRef) -> Void = { _ in }

    private func dinero(_ n: Double) -> String { oculto ? "RD$••••" : fmtDinero(n) }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                CabeceraTitulo(titulo: "Cuentas") {
                    BotonRedondo(icono: "line.3.horizontal.decrease")
                    BotonRedondo(icono: "plus", acento: true, accion: onNuevo)
                }
                patrimonio

                seccion("Cuentas") {
                    let cuentas = estado.libreta.cuentas
                    if cuentas.isEmpty {
                        vacio("Aquí saldrán tus cuentas: efectivo, banco, ahorros.")
                    } else {
                        Grupo {
                            ForEach(cuentas.indices, id: \.self) { i in
                                let c = cuentas[i]
                                let movs = estado.movimientosDe("cuenta:\(c.id)").count
                                fila(icono: c.icono, color: Color(hexString: c.color), nombre: c.nombre,
                                     sub: (c.clase == "efectivo" ? "En mano" : (c.banco.isEmpty ? "Sin banco" : c.banco)) + " · \(movs) movs",
                                     monto: dinero(c.saldo), montoColor: .ink) {
                                    onDetalle(DetalleRef(tipo: .cuenta, ref: "\(c.id)"))
                                }
                                if i < cuentas.count - 1 { Divisor(sangria: 62) }
                            }
                        }
                    }
                }

                seccion("Tarjetas de crédito") {
                    let tarjetas = estado.libreta.tarjetas
                    if tarjetas.isEmpty {
                        vacio("Aquí saldrán tus tarjetas de crédito, con su deuda y sus fechas.")
                    } else {
                        Grupo {
                            ForEach(tarjetas.indices, id: \.self) { i in
                                let t = tarjetas[i]
                                fila(icono: "creditcard.fill", color: Color(hexString: t.color), nombre: t.nombre,
                                     sub: "Disp. \(dinero(t.disponible)) · corte \(t.corte)",
                                     monto: dinero(t.saldo), montoColor: .neg) {
                                    onDetalle(DetalleRef(tipo: .tarjeta, ref: "\(t.id)"))
                                }
                                if i < tarjetas.count - 1 { Divisor(sangria: 62) }
                            }
                        }
                    }
                }

                seccion("Préstamos y fiados") {
                    let prestamos = estado.libreta.prestamos
                    if prestamos.isEmpty {
                        vacio("Aquí saldrán tus préstamos y lo que llevas pagado.")
                    } else {
                        Grupo {
                            ForEach(prestamos.indices, id: \.self) { i in
                                let p = prestamos[i]
                                fila(icono: "hand.raised.fill", color: Color(hexString: p.color), nombre: p.nombre,
                                     sub: p.sentido == "meDeben" ? "Te debe · pagó \(dinero(p.pagado))" : "Le debes · pagaste \(dinero(p.pagado))",
                                     monto: dinero(p.pendiente), montoColor: p.sentido == "meDeben" ? .pos : .neg) {
                                    onDetalle(DetalleRef(tipo: .prestamo, ref: "\(p.id)"))
                                }
                                if i < prestamos.count - 1 { Divisor(sangria: 62) }
                            }
                        }
                    }
                }

                Color.clear.frame(height: 108)
            }
            .padding(.horizontal, 14)
            .padding(.top, 8)
        }
        .background(Color.scr)
    }

    // Tarjeta de Patrimonio (verde, con ocultar y tendencia).
    private var patrimonio: some View {
        VStack(spacing: 14) {
            HStack {
                boton(oculto ? "eye.slash" : "eye") { oculto.toggle() }
                Spacer()
                Text("Patrimonio").font(.system(size: 15, weight: .semibold)).foregroundColor(.white.opacity(0.92))
                Spacer()
                boton("chart.line.uptrend.xyaxis", action: abrirTendencia)
            }
            Text(dinero(estado.patrimonio)).font(.system(size: 34, weight: .heavy)).foregroundColor(.white)
            HStack(spacing: 0) {
                col("Activos", dinero(estado.totalCuentas + estado.porCobrar))
                col("Pasivos", dinero(estado.deudaTotal))
            }
        }
        .padding(.horizontal, 18).padding(.vertical, 18)
        .frame(maxWidth: .infinity)
        .background(LinearGradient(colors: [Color(hex: 0x0e4a29), Color.side], startPoint: .top, endPoint: .bottom))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.side.opacity(0.28), radius: 16, y: 8)
    }

    // Sección: encabezado en MAYÚSCULAS + su contenido.
    private func seccion<C: View>(_ titulo: String, @ViewBuilder _ contenido: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            SeccionTitulo(texto: titulo)
            contenido()
        }
    }

    private func vacio(_ texto: String) -> some View {
        Text(texto).font(.system(size: 13.5)).foregroundColor(.pmut)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .padding(16)
            .background(Color.card).clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.line, lineWidth: 1))
    }

    // Fila con icono en cuadrado pastel, nombre/subtítulo, monto y chevron.
    private func fila(icono: String, color: Color, nombre: String, sub: String, monto: String, montoColor: Color, tap: @escaping () -> Void) -> some View {
        Button(action: tap) {
            HStack(spacing: 12) {
                Image(systemName: icono)
                    .font(.system(size: 16, weight: .semibold)).foregroundColor(color)
                    .frame(width: 40, height: 40).background(color.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                VStack(alignment: .leading, spacing: 2) {
                    Text(nombre).font(.system(size: 15.5, weight: .semibold)).foregroundColor(.ink)
                    Text(sub).font(.system(size: 12.5)).foregroundColor(.pmut)
                }
                Spacer(minLength: 8)
                Text(monto).font(.system(size: 15, weight: .heavy)).foregroundColor(montoColor)
                Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundColor(Color.pmut.opacity(0.6))
            }
            .padding(.horizontal, 14).padding(.vertical, 11)
        }
        .buttonStyle(.plain)
    }

    private func col(_ t: String, _ v: String) -> some View {
        VStack(spacing: 3) {
            Text(t).font(.system(size: 12.5)).foregroundColor(.white.opacity(0.72))
            Text(v).font(.system(size: 15, weight: .bold)).foregroundColor(.white)
        }.frame(maxWidth: .infinity)
    }

    private func boton(_ icono: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icono).font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
                .frame(width: 36, height: 36).background(Color.white.opacity(0.16)).clipShape(Circle())
        }
    }
}
