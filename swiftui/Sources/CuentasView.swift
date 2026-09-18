import SwiftUI

// Pantalla «Cuentas»: tarjeta de Patrimonio (con ocultar dinero y tendencia) y
// los grupos Débito (cuentas), Crédito (tarjetas) y Préstamos, con datos reales
// de la libreta activa.
struct CuentasView: View {
    @EnvironmentObject var estado: AppEstado
    @State private var oculto = false
    var abrirTendencia: () -> Void = {}
    var onNuevo: () -> Void = {}

    private func dinero(_ n: Double) -> String { oculto ? "DOP ••••" : fmtDinero(n) }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                CabeceraTitulo(titulo: "Cuentas") {
                    BotonRedondo(icono: "line.3.horizontal.decrease")
                    BotonRedondo(icono: "plus", acento: true, accion: onNuevo)
                }
                patrimonio

                let cuentas = estado.libreta.cuentas
                if !cuentas.isEmpty {
                    grupo(titulo: "Débito", rotulo: "Bal.", total: estado.totalCuentas, tinte: .pos) {
                        ForEach(cuentas.indices, id: \.self) { i in
                            if i > 0 { Divisor(sangria: 46) }
                            filaCuenta(cuentas[i])
                        }
                    }
                }

                let tarjetas = estado.libreta.tarjetas
                let prestamos = estado.libreta.prestamos
                if !tarjetas.isEmpty || !prestamos.isEmpty {
                    grupo(titulo: "Crédito", rotulo: "Debes", total: estado.deudaTarjetas + estado.deudaPrestamos, tinte: .neg) {
                        ForEach(tarjetas.indices, id: \.self) { i in
                            if i > 0 { Divisor(sangria: 46) }
                            filaGenerica(icono: "creditcard.fill", color: Color(hexString: tarjetas[i].color),
                                         nombre: tarjetas[i].nombre, sub: "Disp. \(dinero(tarjetas[i].disponible))",
                                         monto: dinero(tarjetas[i].saldo), montoColor: .neg)
                        }
                        ForEach(prestamos.indices, id: \.self) { i in
                            if i > 0 || !tarjetas.isEmpty { Divisor(sangria: 46) }
                            filaGenerica(icono: "hand.raised.fill", color: Color(hexString: prestamos[i].color),
                                         nombre: prestamos[i].nombre,
                                         sub: prestamos[i].sentido == "meDeben" ? "Te debe" : "Le debes",
                                         monto: dinero(prestamos[i].pendiente),
                                         montoColor: prestamos[i].sentido == "meDeben" ? .pos : .neg)
                        }
                    }
                }

                if cuentas.isEmpty && tarjetas.isEmpty && prestamos.isEmpty {
                    VacioCard(titulo: "Sin cuentas", detalle: "Agrega tu efectivo, banco, tarjetas o préstamos con el «+».")
                }
                Color.clear.frame(height: 108)
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
        }
        .background(Color.scr)
    }

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

    private func filaCuenta(_ c: Cuenta) -> some View {
        filaGenerica(icono: c.icono, color: Color(hexString: c.color), nombre: c.nombre,
                     sub: c.banco.isEmpty ? "Sin banco" : c.banco, monto: dinero(c.saldo), montoColor: .ink)
    }

    private func filaGenerica(icono: String, color: Color, nombre: String, sub: String, monto: String, montoColor: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icono)
                .font(.system(size: 15, weight: .semibold)).foregroundColor(color)
                .frame(width: 34, height: 34).background(color.opacity(0.15)).clipShape(Circle())
            VStack(alignment: .leading, spacing: 1) {
                Text(nombre).font(.system(size: 15.5, weight: .semibold)).foregroundColor(.ink)
                Text(sub).font(.system(size: 12)).foregroundColor(.pmut)
            }
            Spacer(minLength: 8)
            Text(monto).font(.system(size: 15, weight: .heavy)).foregroundColor(montoColor)
        }
        .padding(.vertical, 10)
    }

    private func grupo<C: View>(titulo: String, rotulo: String, total: Double, tinte: Color, @ViewBuilder filas: () -> C) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(titulo).font(.system(size: 16, weight: .bold)).foregroundColor(tinte)
                Spacer()
                Text("\(rotulo) \(dinero(total))").font(.system(size: 14, weight: .semibold)).foregroundColor(.ink)
                Image(systemName: "chevron.down").font(.system(size: 12, weight: .bold)).foregroundColor(.pmut)
            }
            .padding(.bottom, 4)
            filas()
        }
        .padding(14)
        .background(Color.card)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.line, lineWidth: 1))
    }
}
