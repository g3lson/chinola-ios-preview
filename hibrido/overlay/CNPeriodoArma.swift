import Foundation

/**
 * LA HOJA DEL PERIODO, ARMADA AQUÍ.
 *
 * Es la hoja que sale al tocar el calendario de la cabecera: los siete atajos
 * —«Este mes», «3 meses», «Este año»…—, la línea que dice cuánto hay dentro y,
 * si eliges «Personalizado», el calendario para marcar dos fechas.
 *
 * Todo eso lo armaba la web y el teléfono solo lo dibujaba, con tres problemas
 * que se veían:
 *
 *  · **la hoja salía vacía.** `abrirPeriodo` preguntaba cinco veces con cuarto
 *    de segundo entre medias y, si la web no había repintado, enseñaba la
 *    pantalla WEB por detrás —se ve el cambio— o una hoja con su «Listo» y
 *    nada dentro;
 *  · **cada toque daba una vuelta al puente.** Elegir «3 meses» era mandar el
 *    toque, esperar 250 ms y volver a pedir la hoja entera. Por eso la
 *    palomita tardaba en moverse;
 *  · **la línea de abajo mentía.** «0 movimientos en este periodo» con quince
 *    dentro, porque la web solo cuenta los movimientos cuando ESTÁ en la
 *    pestaña de Movimientos. Parada en el Resumen, no cuenta ninguno.
 *
 * El teléfono ya tiene todo lo que hace falta: la libreta, el periodo y el
 * tema. Lo único que no tenía era el calendario —qué mes se está mirando y qué
 * dos fechas llevas marcadas—, y eso vive aquí al lado, en `CNDatos`.
 *
 * LAS CUENTAS NO SE DEDUJERON: están copiadas de `src/periodo.js`, que es de
 * donde salían. Los rótulos tampoco se escriben dos veces —`npm run sync` los
 * saca de ese mismo módulo y los mete en el diccionario—, así que cambiarlos
 * allí los cambia en los dos sitios.
 */
enum CNPeriodoArma {

    // MARK: - Los siete atajos

    /// En el mismo orden que `CLAVES_PERIODO`, que es el orden en que salen.
    static let claves = ["esteMes", "mesPasado", "ultimos3", "ultimos6",
                         "esteAnio", "anioPasado", "personalizado"]

    /// El rótulo corto de cada atajo: los siete juntos con el nombre largo
    /// ocupan cuatro renglones y dejan el calendario fuera de la vista.
    ///
    /// Va como un `switch` y NO como un diccionario de `cnT(...)`: en un
    /// diccionario los textos se evaluarían al arrancar, con el idioma de ese
    /// momento, y al cambiar de idioma la hoja se quedaría en el anterior.
    static func rotulo(_ clave: String) -> String {
        switch clave {
        case "esteMes": return cnT("Este mes")
        case "mesPasado": return cnT("Mes pasado")
        case "ultimos3": return cnT("3 meses")
        case "ultimos6": return cnT("6 meses")
        case "esteAnio": return cnT("Este año")
        case "anioPasado": return cnT("Año pasado")
        case "personalizado": return cnT("Personalizado")
        default: return ""
        }
    }

    /**
     * CUÁL DE LOS SIETE ESTÁ PUESTO.
     *
     * Se deduce de las fechas, no se guarda. Guardarla pedía un campo más en
     * el puente y, sobre todo, se desincroniza: la web también cambia el
     * periodo —al entrar, al tirar de la tira de meses— y entonces la marca
     * diría una cosa y las fechas otra.
     *
     * Sin rango, solo son un atajo los dos que son un mes exacto: este y el
     * pasado. Cualquier otro mes al que hayas llegado con las flechas no es
     * ninguno de los siete, y no se marca ninguno. Marcar «Este mes» estando
     * en marzo sería decir algo falso.
     *
     * Con rango, se compara con lo que daría cada atajo. El que cuadre es el
     * que está puesto; si no cuadra ninguno, es uno a medida.
     */
    static func activa(mes: String, desde: String, hasta: String) -> String {
        if desde.isEmpty || hasta.isEmpty {
            let esteMes = String((hoyDePrueba.isEmpty ? cnHoy() : hoyDePrueba).prefix(7))
            if mes == esteMes { return "esteMes" }
            if mes == CNCabecera.mesVecino(esteMes, -1) { return "mesPasado" }
            return ""
        }
        for k in ["ultimos3", "ultimos6", "esteAnio", "anioPasado"] {
            if let d = destino(k), d.desde == desde, d.hasta == hasta { return k }
        }
        return "personalizado"
    }

    /// EL DÍA DE HOY, CONGELABLE. Solo lo toca el oro del banco: «Este año»
    /// depende de qué día es, y sin poder fijarlo no se puede comparar con
    /// nada. En un teléfono de verdad está vacío y manda el reloj.
    static var hoyDePrueba = ""

    /**
     * A QUÉ PERIODO LLEVA CADA ATAJO.
     *
     * Devuelve el mes y las dos fechas; vacías cuando el atajo no es un rango.
     * «Personalizado» no lleva a ninguno: abre el calendario y espera.
     *
     * Ojo con «Año pasado»: el mes al que salta es DICIEMBRE del año anterior,
     * no enero. Es el último del periodo, que es el que hace que la cabecera y
     * la tira de meses enseñen el final del año y no su principio.
     */
    static func destino(_ clave: String) -> (mes: String, desde: String, hasta: String)? {
        let hoy = hoyDePrueba.isEmpty ? cnHoy() : hoyDePrueba
        let y = Int(hoy.prefix(4)) ?? 2026
        let esteMes = String(hoy.prefix(7))
        func dia1(_ ym: String) -> String { ym + "-01" }
        func finDe(_ ym: String) -> String { ym + "-" + String(format: "%02d", diasDelMes(ym)) }
        switch clave {
        case "esteMes": return (esteMes, "", "")
        case "mesPasado": return (CNCabecera.mesVecino(esteMes, -1), "", "")
        case "ultimos3": return (esteMes, dia1(CNCabecera.mesVecino(esteMes, -2)), finDe(esteMes))
        case "ultimos6": return (esteMes, dia1(CNCabecera.mesVecino(esteMes, -5)), finDe(esteMes))
        case "esteAnio": return (esteMes, "\(y)-01-01", "\(y)-12-31")
        case "anioPasado": return (String(format: "%04d-12", y - 1), "\(y - 1)-01-01", "\(y - 1)-12-31")
        default: return nil
        }
    }

    /// Cuántos días tiene «2026-02». Con los bisiestos, que febrero los tiene.
    static func diasDelMes(_ ym: String) -> Int {
        let t = ym.split(separator: "-")
        guard t.count >= 2, let y = Int(t[0]), let m = Int(t[1]) else { return 30 }
        var c = DateComponents(); c.year = y; c.month = m; c.day = 1
        var cal = Calendar(identifier: .gregorian); cal.timeZone = .current
        guard let d = cal.date(from: c),
              let r = cal.range(of: .day, in: .month, for: d) else { return 30 }
        return r.count
    }

    // MARK: - El calendario

    /**
     * LAS INICIALES DE LOS DÍAS, EN EL IDIOMA DE LA APP.
     *
     * De la PRIMERA LETRA DEL NOMBRE CORTO, no del formato «estrecho» de Apple.
     * Parece lo mismo y no lo es: en español, el estrecho de iOS da «X» para el
     * miércoles —a propósito, para distinguirlo del martes— y la web, que usa
     * `Intl`, da «M». El banco lo cazó comparando las dos: la cabecera del
     * calendario decía D L M X J V S en el teléfono y D L M M J V S en la web,
     * en la misma app.
     *
     * Con la inicial del corto («mié» → M) salen iguales en los tres idiomas:
     * D L M M J V S en español y en francés, S M T W T F S en inglés.
     *
     * Y se sacan formateando una semana de verdad —del domingo 1 de septiembre
     * de 2024 en adelante—, que es lo que hace `Intl`.
     */
    static func diasSemana() -> [String] {
        var cal = Calendar(identifier: .gregorian); cal.timeZone = .current
        let f = DateFormatter()
        f.calendar = cal
        f.locale = Locale(identifier: CNTextos.idioma)
        f.dateFormat = "EEE"
        var c = DateComponents(); c.year = 2024; c.month = 9; c.day = 1
        guard let domingo = cal.date(from: c) else { return ["D", "L", "M", "M", "J", "V", "S"] }
        return (0..<7).compactMap { i -> String? in
            guard let d = cal.date(byAdding: .day, value: i, to: domingo) else { return nil }
            // Sin tilde: el miércoles es «mié» y su inicial no lleva ninguna.
            let corto = f.string(from: d)
                .folding(options: .diacriticInsensitive, locale: Locale(identifier: "es"))
            return corto.prefix(1).uppercased()
        }
    }

    /// «Octubre de 2026». Con mayúscula inicial, que el formateador la da en
    /// minúscula y en la web se pone a mano.
    static func tituloMes(_ ym: String) -> String {
        let t = ym.split(separator: "-")
        guard t.count >= 2, let y = Int(t[0]), let m = Int(t[1]) else { return ym }
        var c = DateComponents(); c.year = y; c.month = m; c.day = 1
        var cal = Calendar(identifier: .gregorian); cal.timeZone = .current
        guard let fecha = cal.date(from: c) else { return ym }
        let f = DateFormatter()
        f.calendar = cal
        f.locale = Locale(identifier: CNTextos.idioma)
        f.setLocalizedDateFormatFromTemplate("MMMM yyyy")
        let s = f.string(from: fecha)
        return s.prefix(1).uppercased() + s.dropFirst()
    }

    /// El amarillo de la marca, que es el del rango elegido.
    static let amarillo = "oklch(0.88 0.17 95)"
    /// La franja que une los días de en medio: el mismo amarillo al 26 %. La
    /// web lo escribe con `color-mix(... 26%, transparent)` y el navegador lo
    /// entrega con ese alfa; aquí se le pone directamente, sin convertir de
    /// espacio, que es donde se pierden los colores.
    static let franja = "oklch(0.88 0.17 95 / 0.26)"
    /// La tinta de los dos extremos, verde muy oscura sobre el amarillo.
    static let sobreAmarillo = "oklch(0.24 0.05 155)"
    /// Lo que se lee encima del color del carril de ajustes.
    static let sobreOscuro = "oklch(0.96 0.03 95)"

    /**
     * LA REJILLA DEL MES.
     *
     * Empieza en el domingo de la semana del día 1 y se corta por semanas
     * enteras: un mes que empieza en lunes dejaría una fila completa del mes
     * siguiente ocupando sitio sin decir nada.
     *
     * Los días de los meses vecinos salen, pero a media luz: hacen falta para
     * que la rejilla sea una rejilla y no una escalera.
     */
    static func rejilla(_ ym: String, desde: String, hasta: String, tinta: String) -> [CNPeriodo.Dia] {
        let t = ym.split(separator: "-")
        guard t.count >= 2, let y = Int(t[0]), let m = Int(t[1]) else { return [] }
        var cal = Calendar(identifier: .gregorian); cal.timeZone = .current
        var c = DateComponents(); c.year = y; c.month = m; c.day = 1
        guard let primero = cal.date(from: c) else { return [] }
        // 1 = domingo en el calendario gregoriano, y la rejilla empieza ahí.
        let hueco = cal.component(.weekday, from: primero) - 1
        let ultimo = diasDelMes(ym)
        let casillas = Int(ceil(Double(hueco + ultimo) / 7.0)) * 7
        guard let arranque = cal.date(byAdding: .day, value: -hueco, to: primero) else { return [] }
        let iso = CNFormateadores.iso
        var fuera: [CNPeriodo.Dia] = []
        for i in 0..<casillas {
            guard let d = cal.date(byAdding: .day, value: i, to: arranque) else { continue }
            let fecha = iso.string(from: d)
            let e = estado(fecha, desde: desde, hasta: hasta)
            let punta = e == "inicio" || e == "fin" || e == "solo"
            fuera.append(CNPeriodo.Dia(
                id: i,
                n: cal.component(.day, from: d),
                banda: (e == "dentro" || e == "inicio" || e == "fin") ? franja : "rgba(0,0,0,0)",
                bandaRadio: e == "inicio" ? "999px 0 0 999px" : e == "fin" ? "0 999px 999px 0" : "0",
                circulo: punta ? amarillo : "rgba(0,0,0,0)",
                tinta: punta ? sobreAmarillo : tinta,
                fuerte: punta,
                opacidad: cal.component(.month, from: d) == m ? 1 : 0.28))
        }
        return fuera
    }

    /**
     * QUÉ FECHA ES EL HUECO NÚMERO `i` DE LA REJILLA.
     *
     * La rejilla no guarda la fecha de cada casilla —la vista solo necesita el
     * número que se escribe dentro—, así que al tocar una hay que volver a
     * hacer la cuenta. Es la misma de `rejilla`, y por eso está aquí al lado:
     * dos cuentas separadas que tienen que dar lo mismo acaban no dándolo.
     */
    static func fechaDelHueco(_ ym: String, _ i: Int) -> String? {
        let t = ym.split(separator: "-")
        guard t.count >= 2, let y = Int(t[0]), let m = Int(t[1]), i >= 0 else { return nil }
        var cal = Calendar(identifier: .gregorian); cal.timeZone = .current
        var c = DateComponents(); c.year = y; c.month = m; c.day = 1
        guard let primero = cal.date(from: c) else { return nil }
        let hueco = cal.component(.weekday, from: primero) - 1
        guard let d = cal.date(byAdding: .day, value: i - hueco, to: primero) else { return nil }
        return CNFormateadores.iso.string(from: d)
    }

    /// En qué parte del rango cae un día. Los dos extremos se distinguen para
    /// poder redondear la franja por fuera y dejarla recta por dentro.
    static func estado(_ fecha: String, desde: String, hasta: String) -> String {
        if desde.isEmpty { return "" }
        if hasta.isEmpty { return fecha == desde ? "solo" : "" }
        if fecha == desde && fecha == hasta { return "solo" }
        if fecha == desde { return "inicio" }
        if fecha == hasta { return "fin" }
        return (fecha > desde && fecha < hasta) ? "dentro" : ""
    }

    /**
     * CÓMO SE LLAMA UN RANGO.
     *
     * Del 1 de enero al 31 de diciembre es «2026», no «1 ene – 31 dic 2026». De
     * principio a fin de mes es «Octubre 2026». Y si no cuadra con nada, las
     * dos fechas, con el año solo donde hace falta.
     */
    static func etiquetaRango(desde: String, hasta: String, corto: Bool) -> String {
        var cal = Calendar(identifier: .gregorian); cal.timeZone = .current
        let iso = CNFormateadores.iso
        guard let d1 = iso.date(from: desde), let d2 = iso.date(from: hasta) else { return "" }
        let c1 = cal.dateComponents([.year, .month, .day], from: d1)
        let c2 = cal.dateComponents([.year, .month, .day], from: d2)
        func nombreMes(_ d: Date, _ largo: Bool) -> String {
            let f = DateFormatter()
            f.calendar = cal
            f.locale = Locale(identifier: CNTextos.idioma)
            f.setLocalizedDateFormatFromTemplate(largo ? "MMMM" : "MMM")
            return f.string(from: d).replacingOccurrences(of: ".", with: "")
        }
        let mismoAnio = c1.year == c2.year
        let anioEntero = c1.month == 1 && c1.day == 1 && c2.month == 12 && c2.day == 31
        if mismoAnio && anioEntero { return String(c1.year ?? 0) }

        let empiezaMes = c1.day == 1
        let acabaMes = c2.day == diasDelMes(String(hasta.prefix(7)))
        if mismoAnio && empiezaMes && acabaMes {
            let a = nombreMes(d1, !corto), b = nombreMes(d2, !corto)
            let txt = (a == b ? a : a + " – " + b) + " " + String(c1.year ?? 0)
            return corto ? txt : txt.prefix(1).uppercased() + txt.dropFirst()
        }
        func dia(_ d: Date, _ cp: DateComponents, _ conAnio: Bool) -> String {
            String(cp.day ?? 0) + " " + nombreMes(d, false) + (conAnio ? " " + String(cp.year ?? 0) : "")
        }
        if desde == hasta { return dia(d1, c1, true) }
        return dia(d1, c1, !mismoAnio) + " – " + dia(d2, c2, true)
    }

    // MARK: - La hoja entera

    /// Los colores que cambian con el tema. Van por fuera para poder armar la
    /// hoja en una prueba sin tema puesto.
    struct Tinte {
        var side = ""; var tinta = ""; var borde = ""
    }

    /**
     * La hoja, lista para dibujar.
     *
     * `calendario` abierto es lo que hace crecer la hoja: sin él son los siete
     * atajos y la línea de abajo, y con él, media pantalla más.
     */
    static func arma(libreta l: CNLibreta, periodo p: CNCalculo.Periodo,
                     calAbierto: Bool, calMes: String, calDesde: String, calHasta: String,
                     tinte t: Tinte) -> CNPeriodo {
        var x = CNPeriodo()
        x.abierto = true
        x.calendario = calAbierto
        // CUÁNTOS HAY DENTRO, CONTADOS DE VERDAD.
        //
        // La web contaba los que tiene DIBUJADOS, y solo los dibuja estando en
        // la pestaña de Movimientos: desde el Resumen la línea decía siempre
        // «0 movimientos en este periodo». Aquí se cuentan los del periodo, que
        // es lo que la frase promete.
        let n = CNMovimientos.visibles(l, periodo: p).count
        x.resumen = n == 1 ? cnT("1 movimiento en este periodo")
            : cnT("{n} movimientos en este periodo").replacingOccurrences(of: "{n}", with: String(n))
        let puesta = activa(mes: p.mes, desde: p.desde ?? "", hasta: p.hasta ?? "")
        x.opciones = claves.enumerated().map { i, k in
            let viva = k == puesta
            return CNPeriodo.Opcion(
                id: i, label: rotulo(k), puesta: viva,
                fondo: viva ? t.side : "rgba(0,0,0,0)",
                tinta: viva ? sobreOscuro : t.tinta,
                borde: viva ? t.side : t.borde)
        }
        let mes = calMes.isEmpty ? p.mes : calMes
        x.calTitulo = tituloMes(mes)
        x.diasSemana = diasSemana()
        x.dias = rejilla(mes, desde: calDesde, hasta: calHasta, tinta: t.tinta)
        x.seleccion = calDesde.isEmpty ? cnT("Elige la fecha de inicio")
            : calHasta.isEmpty ? cnT("Ahora elige la fecha final")
            : etiquetaRango(desde: calDesde, hasta: calHasta, corto: true)
        x.textoAplicar = cnT("Aplicar")
        x.puedeAplicar = !calDesde.isEmpty
        return x
    }
}
