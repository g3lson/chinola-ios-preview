import SwiftUI

// Pantalla «Cuentas», reorganizada: sin cabecera; una tarjeta de Patrimonio con
// botón de ocultar el dinero y botón de tendencia; y los grupos (Débito, Crédito,
// Préstamos) como lista, uno debajo del otro, con sus cuentas indentadas.
// Mantiene el estilo Chinola (verde, crema, acento).
struct CuentasView: View {
    @State private var oculto = false
    var abrirTendencia: () -> Void = {}

    private struct Cuenta { let nombre: String; let sub: String?; let icono: String; let tinte: Color; let saldo: String }
    private let debito: [Cuenta] = [
        .init(nombre: "Efectivo", sub: "Sin banco", icono: "banknote", tinte: .pos, saldo: "DOP 0")
    ]

    private func dinero(_ s: String) -> String { oculto ? "DOP ••••" : s }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                topRow
                patrimonio
                grupo(titulo: "Débito", rotulo: "Bal.", total: "DOP 0", tinte: .pos, cuentas: debito)
                grupoVacio(titulo: "Crédito", rotulo: "Debes", total: "DOP 0", tinte: .neg,
                           detalle: "Tus tarjetas y préstamos aparecerán aquí.")
                Color.clear.frame(height: 108)
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
        }
        .background(Color.scr)
    }

    // Fila superior: título + botones redondos (opciones/filtro y «+»), igual
    // que Movimientos y Plan.
    private var topRow: some View {
        CabeceraTitulo(titulo: "Cuentas") {
            BotonRedondo(icono: "line.3.horizontal.decrease")
            BotonRedondo(icono: "plus", acento: true)
        }
    }

    // Tarjeta de Patrimonio (con ocultar y tendencia).
    private var patrimonio: some View {
        VStack(spacing: 14) {
            HStack {
                boton(oculto ? "eye.slash" : "eye") { oculto.toggle() }
                Spacer()
                Text("Patrimonio").font(.system(size: 15, weight: .semibold)).foregroundColor(.white.opacity(0.92))
                Spacer()
                boton("chart.line.uptrend.xyaxis", action: abrirTendencia)
            }
            Text(dinero("DOP 0")).font(.system(size: 34, weight: .heavy)).foregroundColor(.white)
            HStack(spacing: 0) {
                col("Activos", dinero("DOP 0"))
                col("Pasivos", dinero("DOP 0"))
            }
        }
        .padding(.horizontal, 18).padding(.vertical, 18)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(colors: [Color(hex: 0x0e4a29), Color.side],
                           startPoint: .top, endPoint: .bottom)
        )
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

    // Grupo con cuentas indentadas.
    private func grupo(titulo: String, rotulo: String, total: String, tinte: Color, cuentas: [Cuenta]) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(titulo).font(.system(size: 16, weight: .bold)).foregroundColor(tinte)
                Spacer()
                Text("\(rotulo) \(dinero(total))").font(.system(size: 14, weight: .semibold)).foregroundColor(.ink)
                Image(systemName: "chevron.down").font(.system(size: 12, weight: .bold)).foregroundColor(.pmut)
            }
            .padding(.bottom, 4)
            ForEach(cuentas.indices, id: \.self) { i in
                if i > 0 { Divider().overlay(Color.line).padding(.leading, 46) }
                HStack(spacing: 12) {
                    Image(systemName: cuentas[i].icono)
                        .font(.system(size: 15, weight: .semibold)).foregroundColor(cuentas[i].tinte)
                        .frame(width: 34, height: 34).background(cuentas[i].tinte.opacity(0.15)).clipShape(Circle())
                    VStack(alignment: .leading, spacing: 1) {
                        Text(cuentas[i].nombre).font(.system(size: 15.5, weight: .semibold)).foregroundColor(.ink)
                        if let s = cuentas[i].sub {
                            Text(s).font(.system(size: 12)).foregroundColor(.pmut)
                        }
                    }
                    Spacer(minLength: 8)
                    Text(dinero(cuentas[i].saldo)).font(.system(size: 15, weight: .heavy)).foregroundColor(.ink)
                }
                .padding(.vertical, 10)
            }
        }
        .padding(14)
        .background(Color.card)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.line, lineWidth: 1))
    }

    private func grupoVacio(titulo: String, rotulo: String, total: String, tinte: Color, detalle: String) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text(titulo).font(.system(size: 16, weight: .bold)).foregroundColor(tinte)
                Spacer()
                Text("\(rotulo) \(dinero(total))").font(.system(size: 14, weight: .semibold)).foregroundColor(.ink)
                Image(systemName: "chevron.down").font(.system(size: 12, weight: .bold)).foregroundColor(.pmut)
            }
            Text(detalle).font(.system(size: 13.5)).foregroundColor(.pmut)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(Color.card)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.line, lineWidth: 1))
    }
}
