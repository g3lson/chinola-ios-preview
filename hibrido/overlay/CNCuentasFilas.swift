import Foundation

/**
 * LAS FILAS DE LA PANTALLA DE CUENTAS, ARMADAS AQUÍ.
 *
 * Lo que tenía la pantalla era medio nativo y medio prestado: los totales de
 * cada grupo, el patrimonio y el uso del límite se calculaban aquí, y las
 * FILAS —qué cuentas hay, con qué nombre, qué icono y qué color— se las pedía
 * a la web (`__chinolaCuentasJSON`).
 *
 * Y la web solo arma el modelo de la pestaña EN LA QUE ESTÁ. Parada en otra,
 * contesta `listo:false` con cero filas, y como cada refresco de aquí empieza
 * con `guard var m = cuentas`, el cálculo nativo no tenía dónde escribir: la
 * pantalla se quedaba con la tarjeta del patrimonio y ni una cuenta debajo.
 * Los números estaban bien y no se veían.
 *
 * Esto arma las filas de la libreta que ya está en memoria. No se inventa
 * nada: cada campo se sacó mirando lo que la web manda de verdad, fila por
 * fila, con la app en marcha. Lo único que sigue siendo suyo son los
 * disparadores de deslizar (editar, eliminar, predeterminada): esos son
 * funciones de la web y se conservan tal cual mientras la escritura no sea
 * también nativa.
 */
enum CNCuentasFilas {

    // MARK: - Piezas

    /// El mismo color con un 14 % de opacidad, que es el tinte del aro del
    /// icono. La web lo hace con `color-mix(in oklab, color 14%, transparent)`
    /// y el navegador lo entrega como `oklab(L a b / 0.14)`: el mismo color y
    /// el mismo alfa que poniéndoselo aquí, así que se le añade sin convertir
    /// de espacio —convertir es donde se pierden los colores—.
    static func tinte(_ color: String, _ alfa: Double = 0.14) -> String {
        let c = color.trimmingCharacters(in: .whitespaces)
        if c.isEmpty { return "" }
        // Ya trae alfa: se deja como está.
        if c.contains("/") { return c }
        let texto = String(format: "%.2f", alfa)
        for f in ["oklch(", "oklab(", "rgb(", "rgba(", "hsl(", "hsla(", "color("] where c.lowercased().hasPrefix(f) {
            guard c.hasSuffix(")") else { return c }
            return String(c.dropLast()) + " / " + texto + ")"
        }
        if c.hasPrefix("#") {
            // #rrggbb → #rrggbbaa. El alfa va al final, no delante.
            let h = c.dropFirst()
            if h.count == 6 {
                return c + String(format: "%02x", Int((alfa * 255).rounded()))
            }
        }
        return c
    }

    /// El glifo que le toca a una cuenta. Primero el suyo, si eligió uno; si
    /// no, el de su clase. Lo que no se reconozca va con el del banco, que es
    /// lo que hace la web: nunca un hueco.
    static func glifoDeCuenta(_ c: CNCuenta) -> String {
        if !c.icono.isEmpty, let p = CNCatalogos.iconos[c.icono] { return p }
        let porClase: [String: String] = [
            "banco": "banco", "efectivo": "billete", "billetera": "telefono",
            "ahorro": "hucha", "inversion": "grafico"
        ]
        let nombre = porClase[c.clase] ?? "banco"
        return CNCatalogos.iconos[nombre] ?? CNCatalogos.iconos["banco"] ?? ""
    }

    /// Cuántos movimientos tocan esta cuenta. Va en el subtítulo de la fila.
    static func movimientosDe(_ l: CNLibreta, cuenta id: Int) -> Int {
        // También los que SALEN hacia esta cuenta: una transferencia toca
        // dos cuentas y contarla solo en una deja la otra diciendo «0 movs»
        // con dinero dentro.
        l.tx.filter { m in
            CNCalculo.idDe(m.medio, "cuenta") == id
                || CNCalculo.idDe(m.destino, "cuenta") == id
        }.count
    }

    // MARK: - Las tres listas

    /// Los colores que cambian con la paleta. No se escriben aquí: el verde de
    /// un tema no es el verde de otro, y una fila con el verde de fábrica sobre
    /// un tema oscuro se ve como un parche.
    struct Tinte {
        var positivo = ""; var aviso = ""; var negativo = ""
    }

    static func cuentas(_ l: CNLibreta, predeterminada: Int = 0,
                        rotuloPred: String = "") -> [CNCuentasModelo.Fila] {
        l.cuentas.enumerated().map { i, c in
            var f = CNCuentasModelo.Fila()
            f.indice = i
            f.nombre = c.nombre
            // «Banco Popular · 12 movs». Sin banco lo dice, que dejar el hueco
            // parece que falta un dato y lo que pasa es que no lo hay.
            let banco = c.banco.isEmpty ? cnT("Sin banco") : c.banco
            let movs = cnT("{n} movs").replacingOccurrences(
                of: "{n}", with: String(movimientosDe(l, cuenta: c.id)))
            f.detalle = banco + " · " + movs
            f.valor = cnDineroFirmado(c.saldo)
            f.iconoPath = glifoDeCuenta(c)
            f.color = c.color
            f.fondo = tinte(c.color)
            f.predeterminada = predeterminada != 0 && c.id == predeterminada
            f.rotuloPred = rotuloPred
            return f
        }
    }

    static func tarjetas(_ l: CNLibreta, tinte t: Tinte) -> [CNCuentasModelo.Fila] {
        l.tarjetas.enumerated().map { i, c in
            var f = CNCuentasModelo.Fila()
            f.indice = i
            f.nombre = c.nombre
            f.valor = cnDinero(c.saldo)
            f.iconoPath = CNCatalogos.iconos["tarjeta"] ?? ""
            f.color = c.color
            f.fondo = tinte_(c.color)
            // El uso va en 0…100: la vista lo divide ella.
            let uso = (CNCuentasTotales.usoDelLimite(c) * 100).rounded()
            f.uso = uso
            f.usoColor = colorDelUso(uso, t)
            // «31 % del límite · pago en 29 d». El segundo trozo solo si hay
            // día de pago: sin él, la frase prometía una fecha inventada.
            var trozos: [String] = []
            if c.limite > 0 {
                trozos.append(String(Int(uso)) + "% " + cnT("del límite"))
            }
            if c.pago > 0 {
                trozos.append(cnT("pago en {n} d").replacingOccurrences(
                    of: "{n}", with: String(CNCalculo.diasHastaElDia(c.pago))))
            }
            f.pie = trozos.joined(separator: " · ")
            return f
        }
    }

    static func prestamos(_ l: CNLibreta, tinte t: Tinte) -> [CNCuentasModelo.Fila] {
        l.prestamos.enumerated().map { i, p in
            var f = CNCuentasModelo.Fila()
            f.indice = i
            f.nombre = p.nombre
            let falta = max(0, p.total - p.pagado)
            f.valor = cnDinero(falta)
            // EL SENTIDO MANDA, y es lo que más fácil se pierde. Un préstamo
            // que te deben no es una deuda: ni el icono ni el color ni el signo
            // son los mismos. Rehaciéndolo de memoria sale todo en rojo.
            let meDeben = p.sentido == "meDeben"
            f.iconoPath = CNCatalogos.iconos[meDeben ? "usuario" : "banco"] ?? ""
            f.color = p.color
            f.fondo = tinte_(p.color)
            f.tintaValor = meDeben ? t.positivo : t.negativo
            f.uso = p.total > 0 ? (min(1, p.pagado / p.total) * 100).rounded() : 0
            f.usoColor = p.color
            // «Banreservas · RD$12,500 al mes · día 10».
            var trozos: [String] = []
            if !p.entidad.isEmpty { trozos.append(p.entidad) }
            if p.cuota > 0 { trozos.append(cnDinero(p.cuota) + " " + cnT("al mes")) }
            if p.dia > 0 {
                trozos.append(cnT("día {d}").replacingOccurrences(of: "{d}", with: String(p.dia)))
            }
            f.pie = trozos.joined(separator: " · ")
            return f
        }
    }

    /// Verde hasta la mitad, ámbar hasta el 80 y rojo a partir de ahí. Medido
    /// contra la web: 45 % verde, 60 % ámbar, 85 % rojo.
    static func colorDelUso(_ uso: Double, _ t: Tinte) -> String {
        if uso >= 80 { return t.negativo }
        if uso > 50 { return t.aviso }
        return t.positivo
    }

    /// Alias corto, que `tinte` ya es el nombre del parámetro de color.
    private static func tinte_(_ c: String) -> String { tinte(c) }
}
