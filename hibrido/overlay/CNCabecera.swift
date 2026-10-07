import Foundation

/**
 * LA CABECERA DEL RESUMEN, ARMADA AQUÍ.
 *
 * Es el bloque de arriba: la libreta, la cifra grande, el rótulo, la tira de
 * meses y —según el diseño— las cuatro cifras o lo gastado. Venía entera por
 * el puente, y con ella los COLORES, que es lo que la hace difícil: el fondo
 * puede ser un degradado de tres paradas, y de él dependen la tinta, el gris y
 * dos tonos de pastilla.
 *
 * NO SE INVENTA NADA. La paleta es la misma función de la web
 * (`paletaCabecera`) traducida rama por rama, y las piezas de cada uno de los
 * siete diseños están medidas con la app en marcha en `test/cabecera-oro.json`.
 *
 * LAS CUATRO RAMAS, EN ORDEN, QUE ES LO QUE IMPORTA:
 *
 *  1. **Integrada**: la cabecera renuncia a su color y toma el de la pantalla.
 *     Entonces las pastillas NO pueden ser blancas translúcidas —sobre el
 *     crema no se verían—: se sacan del fondo con una pizca de tinta.
 *  2. **Clara, mínima o viva**: sobre papel. La viva va sobre el MISMO papel
 *     que la pantalla para que no haya costura con las tarjetas; las otras dos
 *     sobre el de las tarjetas.
 *  3. **Con un color elegido** (hay catorce): su degradado, su tinta, y las
 *     pastillas en blanco o en negro según sobre cuál de los dos se lea.
 *  4. **Sin nada elegido**: el verde oscuro de la marca.
 *
 * El orden no es decorativo: «integrada» gana sobre «clara», y un color
 * elegido solo cuenta si no se dio ninguna de las dos antes.
 */
enum CNCabecera {

    /// Lo que hace falta del tema para armar la paleta. Son los mismos
    /// nombres que manda la web.
    struct Tema {
        var bg: String       // el papel de la pantalla
        var card: String     // el de las tarjetas
        var suave: String
        var borde: String
        var tinta: String
        var gris: String
        var side: String     // el verde oscuro de la marca
    }

    struct Paleta {
        var fondo: String
        var tinta: String
        var gris: String
        var pastilla: String
        var pastillaFuerte: String
        var linea: String
    }

    /// La tinta de la web sobre el verde oscuro (`SOBRE_OSCURO`).
    static let sobreOscuro = "#F7F2E4"

    /// Los tres diseños que van sobre papel y no sobre color.
    static let claras: Set<String> = ["clara", "minima", "viva"]

    static func paleta(diseno: String, color: String, integrada: Bool, tema t: Tema) -> Paleta {
        if integrada {
            return Paleta(
                fondo: t.bg, tinta: t.tinta, gris: t.gris,
                // Del fondo con una pizca de tinta, como los botones redondos
                // de los detalles. En blanco translúcido no se verían.
                pastilla: mezcla(t.tinta, 7, t.bg),
                pastillaFuerte: mezcla(t.tinta, 13, t.bg),
                linea: "transparent")
        }
        if claras.contains(diseno) {
            return Paleta(
                fondo: diseno == "viva" ? t.bg : t.card,
                tinta: t.tinta, gris: t.gris,
                pastilla: t.suave, pastillaFuerte: t.borde, linea: t.borde)
        }
        if !color.isEmpty,
           let c = CNCatalogos.coloresDeCabecera.first(where: { $0.id == color }) {
            let osc = c.sobre == "oscuro"
            // Más contraste que en la web de antes: el texto secundario y las
            // pastillas se suben para que las letras destaquen sobre el
            // degradado, que nunca es de un solo tono.
            return Paleta(
                fondo: c.css, tinta: c.tinta,
                gris: osc ? "rgb(0 0 0 / 0.72)" : "rgb(255 255 255 / 0.86)",
                pastilla: osc ? "rgb(0 0 0 / 0.13)" : "rgb(255 255 255 / 0.20)",
                pastillaFuerte: osc ? "rgb(0 0 0 / 0.22)" : "rgb(255 255 255 / 0.32)",
                linea: "transparent")
        }
        return Paleta(
            fondo: t.side, tinta: sobreOscuro, gris: "oklch(0.86 0.04 110)",
            pastilla: "rgb(255 255 255 / 0.13)", pastillaFuerte: "rgb(255 255 255 / 0.22)",
            linea: "transparent")
    }

    /**
     * `color-mix(in oklab, A n%, B)` dicho en una cadena que el teléfono sabe
     * leer. No se resuelve aquí: `cnColor` ya entiende `color-mix`, y
     * resolverlo a mano sería hacer la mezcla en otro espacio de color y que
     * saliera un tono distinto del de la web.
     */
    static func mezcla(_ a: String, _ pct: Int, _ b: String) -> String {
        "color-mix(in oklab, " + a + " " + String(pct) + "%, " + b + ")"
    }

    /**
     * EL DEGRADADO, DESMENUZADO.
     *
     * Los colores de cabecera son `linear-gradient(150deg, #f7c948, #ec9a2e
     * 55%, #3f9d54)`: un ángulo y dos o tres paradas, algunas con su posición
     * y otras sin ella. Las que no la traen se reparten a partes iguales, que
     * es lo que hace el navegador.
     */
    struct Fondo {
        var tipo = "color"      // "color" | "grad"
        var color = ""
        var angulo: Double = 180
        var paradas: [(color: String, pos: Double)] = []
    }

    static func fondo(_ css: String) -> Fondo {
        let t = css.trimmingCharacters(in: .whitespaces)
        guard t.hasPrefix("linear-gradient("), let abre = t.firstIndex(of: "("),
              t.hasSuffix(")") else {
            return Fondo(tipo: "color", color: t)
        }
        let dentro = String(t[t.index(after: abre)..<t.index(before: t.endIndex)])
        var piezas = partir(dentro)
        var f = Fondo(tipo: "grad")
        if let primera = piezas.first, primera.hasSuffix("deg"),
           let g = Double(primera.dropLast(3)) {
            f.angulo = g
            piezas.removeFirst()
        }
        // Primero las que traen posición; las demás se reparten en el hueco.
        var crudas: [(String, Double?)] = piezas.map { p in
            let trozos = p.split(separator: " ").map(String.init)
            if trozos.count >= 2, trozos[1].hasSuffix("%"),
               let v = Double(trozos[1].dropLast()) {
                return (trozos[0], v / 100)
            }
            return (p, nil)
        }
        if crudas.count == 1 { crudas[0].1 = 0 }
        for i in crudas.indices where crudas[i].1 == nil {
            crudas[i].1 = crudas.count > 1 ? Double(i) / Double(crudas.count - 1) : 0
        }
        f.paradas = crudas.map { ($0.0, $0.1 ?? 0) }
        return f
    }

    /// Partir por comas de PRIMER nivel: un `rgb(1, 2, 3)` dentro de un
    /// degradado lleva las suyas y partir a lo bruto lo rompe en tres.
    private static func partir(_ s: String) -> [String] {
        var fuera: [String] = []
        var actual = ""
        var hondo = 0
        for c in s {
            if c == "(" { hondo += 1 }
            if c == ")" { hondo -= 1 }
            if c == ",", hondo == 0 {
                fuera.append(actual.trimmingCharacters(in: .whitespaces)); actual = ""
            } else { actual.append(c) }
        }
        let ultimo = actual.trimmingCharacters(in: .whitespaces)
        if !ultimo.isEmpty { fuera.append(ultimo) }
        return fuera
    }

    /**
     * QUÉ PIEZAS LLEVA CADA DISEÑO.
     *
     * Medido con la app en marcha, uno por uno (`test/cabecera-oro.json`). No
     * se deduce del nombre: «detallada» va en grande, «viva» trae una frase y
     * ninguna tira de meses, «auto» trae la tira, y las otras cuatro van sin
     * rótulo encima de la cifra.
     */
    struct Piezas {
        var grande = false
        var conRotulo = false
        var conMeses = false
        var conFrase = false
    }

    static func piezas(_ diseno: String) -> Piezas {
        switch diseno {
        case "auto": return Piezas(grande: false, conRotulo: true, conMeses: true, conFrase: false)
        case "viva": return Piezas(grande: false, conRotulo: true, conMeses: false, conFrase: true)
        case "detallada": return Piezas(grande: true, conRotulo: true, conMeses: false, conFrase: false)
        default: return Piezas()
        }
    }
    /**
     * LA TIRA DE MESES.
     *
     * Cuatro meses y «Rango»: dos atrás, el de ahora y el siguiente. El de
     * ahora va con el nombre LARGO —«octubre»— y los otros tres en corto
     * —«ago», «sept», «nov»—: así se ve de un vistazo en cuál estás sin
     * tener que mirar cuál lleva el color.
     *
     * Y los que no están elegidos NO llevan pastilla propia: el carril que los
     * envuelve ya los agrupa. Con una cada uno parecían cinco botones sueltos
     * puestos encima de la cabecera, no un selector. Por eso su fondo es el
     * del carril —la pastilla de la paleta— y no uno suyo.
     *
     * El punto final del mes abreviado se quita a mano: en español el
     * formateador escribe «sept.» y en la tira, pegado al siguiente, parece
     * una palabra cortada.
     */
    static func meses(mes: String, hayRango: Bool, paleta p: Paleta,
                      acento: String, sobreAcento: String) -> [(label: String, puesto: Bool, bg: String, fg: String)] {
        var fuera: [(label: String, puesto: Bool, bg: String, fg: String)] = []
        for d in -2...1 {
            let ym = CNCabecera.mesVecino(mes, d)
            let viva = d == 0 && !hayRango
            fuera.append((label: nombreDeMes(ym, largo: d == 0),
                          puesto: viva,
                          bg: viva ? acento : p.pastilla,
                          fg: viva ? sobreAcento : p.tinta))
        }
        fuera.append((label: cnT("Rango"), puesto: hayRango,
                      bg: hayRango ? acento : p.pastilla,
                      fg: hayRango ? sobreAcento : p.tinta))
        return fuera
    }

    /// «2026-10» más tres meses es «2027-01», no «2026-13».
    static func mesVecino(_ mes: String, _ cuantos: Int) -> String {
        let t = mes.split(separator: "-")
        guard t.count >= 2, let y = Int(t[0]), let m = Int(t[1]) else { return mes }
        let total = y * 12 + (m - 1) + cuantos
        return String(format: "%04d-%02d", total / 12, total % 12 + 1)
    }

    /// El nombre del mes en el idioma de la app —no en el del teléfono, que
    /// pueden no ser el mismo— y sin el punto del abreviado.
    static func nombreDeMes(_ ym: String, largo: Bool) -> String {
        let t = ym.split(separator: "-")
        guard t.count >= 2, let y = Int(t[0]), let m = Int(t[1]) else { return ym }
        var c = DateComponents(); c.year = y; c.month = m; c.day = 1
        var cal = Calendar(identifier: .gregorian); cal.timeZone = .current
        guard let fecha = cal.date(from: c) else { return ym }
        let f = DateFormatter()
        f.calendar = cal
        f.locale = Locale(identifier: CNTextos.idioma)
        f.setLocalizedDateFormatFromTemplate(largo ? "MMMM" : "MMM")
        return f.string(from: fecha).replacingOccurrences(of: ".", with: "")
    }

}
