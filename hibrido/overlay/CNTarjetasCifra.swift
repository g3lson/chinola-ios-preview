import Foundation

/**
 * LAS SEIS TARJETAS DE CIFRA DEL RESUMEN, CALCULADAS AQUÍ.
 *
 * Son las que dicen un número y una nota: ingresos, gastos, balance, deuda y
 * patrimonio. Hasta ahora las armaba la web y llegaban por el puente ya
 * escritas; esto las calcula en el teléfono, con la libreta que ya está aquí y
 * las cuentas que `CNCalculo` ya sabía hacer.
 *
 * ESTÁ COPIADO DE LA WEB REGLA POR REGLA, y eso importa más que el cálculo: lo
 * que hay que conservar no es el número —ese sale igual de cualquier manera—
 * sino las decisiones pequeñas que nadie recuerda haber tomado:
 *
 * - Gastos lleva su nota en PORCENTAJE de los ingresos, no en dinero. Y con
 *   cero ingresos ese porcentaje es 0, no infinito ni un guion.
 * - Balance cambia de nota Y de color según el signo: «disponible este mes» en
 *   el color del texto, «déficit del mes» en rojo. Son dos tarjetas distintas
 *   escondidas en una.
 * - Patrimonio hace lo mismo, pero su nota no cambia: siempre «cuentas −
 *   deudas», porque explica de dónde sale el número, no cómo va.
 * - Deuda suma tarjetas y préstamos en una sola cifra, y lo dice.
 *
 * Perder cualquiera de esas no rompe nada: simplemente la pantalla dice algo un
 * poco peor, y nadie se entera. Por eso van escritas.
 *
 * LOS COLORES NO SE ELIGEN AQUÍ. Vienen del tema, que la web ya manda, porque
 * cambian con la paleta que cada quien tenga puesta. Aquí se decide CUÁL de
 * ellos toca, que es lo que sí es una regla.
 */
enum CNTarjetasCifra {

    /// Lo que hace falta saber del tema para pintar una cifra.
    struct Tinte {
        var tinta: String
        var positivo: String
        var negativo: String
        var ambar: String
        /// El gris del tema. Las seis nuevas lo usan para decir «esto no es ni
        /// bueno ni malo»: una racha de cero días no va en rojo.
        var gris: String = ""
    }

    /// Una tarjeta ya resuelta: el número, su nota y su color.
    struct Cifra {
        var valor: String
        var nota: String
        var color: String
        var icono: String
    }

    /**
     * La tarjeta que toca, o `nil` si ese tipo no es de cifra.
     *
     * @param tipo  la clave del catálogo (`kpi-balance`, `kpi-deuda`…)
     */
    /**
     * LA DECISIÓN DE CADA TARJETA, sin formato.
     *
     * La misma que `cifraDelPanel` de la web, y el fichero de oro ejecuta las
     * dos y las compara. El formato lo pone cada lado; lo que no puede cambiar
     * es CUÁNDO cambia cada cosa, y aquí hay tres reglas que se pierden al
     * rehacer la pantalla de memoria:
     *
     * - En gastos la nota es un PORCENTAJE de lo que entró, y sin ingresos es
     *   0, no una división rota.
     * - En el balance cambian la nota Y el tono. Son dos tarjetas en una.
     * - En el patrimonio cambia el TONO pero NO la nota: la nota explica de
     *   dónde sale el número, no cómo va la cosa.
     *
     * La nota va en español sin traducir: es la clave, y se traduce al pintar.
     */
    struct Decision {
        var monto: Double = 0
        var nota = ""
        var pct = 0
        var tono = ""
    }

    static func decision(_ tipo: String, _ total: CNCalculo.Totales,
                         deuda: Double, patrimonio: Double) -> Decision? {
        switch tipo {
        case "kpi-ingresos":
            return Decision(monto: total.ing, nota: "del mes", tono: "positivo")
        case "kpi-gastos":
            return Decision(monto: total.gas, nota: "% de tus ingresos",
                            pct: total.ing > 0 ? Int((total.gas / total.ing * 100).rounded()) : 0,
                            tono: "negativo")
        case "kpi-balance":
            let bien = total.bal >= 0
            return Decision(monto: total.bal,
                            nota: bien ? "disponible este mes" : "déficit del mes",
                            tono: bien ? "tinta" : "negativo")
        case "kpi-deuda":
            return Decision(monto: deuda, nota: "tarjetas + préstamos", tono: "ambar")
        case "kpi-patrimonio":
            return Decision(monto: patrimonio, nota: "cuentas − deudas",
                            tono: patrimonio >= 0 ? "tinta" : "negativo")
        default:
            return nil
        }
    }

    // MARK: - Las cuentas pequeñas de las seis

    /// Redondeado y con tope en 999, como la web: un porcentaje de cuatro
    /// cifras no cabe y no dice nada que no diga «999».
    private static func porciento(_ a: Double, _ b: Double) -> Int {
        b > 0 ? min(999, Int((a / b * 100).rounded())) : 0
    }

    private static var calendario: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = .current
        return c
    }

    /// Cuántos días tiene el mes «2026-10».
    static func diasDelMes(_ mes: String) -> Int {
        let p = mes.split(separator: "-")
        guard p.count >= 2, let y = Int(p[0]), let m = Int(p[1]) else { return 30 }
        var c = DateComponents(); c.year = y; c.month = m; c.day = 1
        guard let d = calendario.date(from: c),
              let r = calendario.range(of: .day, in: .month, for: d) else { return 30 }
        return r.count
    }

    /// El mes anterior a «2026-01» es «2025-12», no «2026-00».
    static func mesAntesDe(_ mes: String) -> String {
        let p = mes.split(separator: "-")
        guard p.count >= 2, let y = Int(p[0]), let m = Int(p[1]) else { return mes }
        let total = y * 12 + (m - 1) - 1
        return String(format: "%04d-%02d", total / 12, total % 12 + 1)
    }

    /// El mismo mes del año pasado: «2026-02» → «2025-02».
    static func mesDelAnoPasado(_ mes: String) -> String {
        let p = mes.split(separator: "-")
        guard p.count >= 2, let y = Int(p[0]), let m = Int(p[1]) else { return mes }
        return String(format: "%04d-%02d", y - 1, m)
    }

    /**
     * DÍAS SEGUIDOS SIN GASTAR, contando desde AYER.
     *
     * El de hoy no ha terminado: contarlo da una racha que se rompe por la
     * tarde con la primera compra, y eso es peor que no enseñarla. Con tope de
     * 400 vueltas, que una libreta sin gastos no puede dejar el bucle suelto.
     */
    static func diasSinGastar(_ l: CNLibreta, hoy: Date = Date()) -> Int {
        let conGasto = Set(l.tx
            .filter { $0.tipo == "Gasto Fijo" || $0.tipo == "Gasto Variable" }
            .map { String($0.fecha.prefix(10)) })
        let f = DateFormatter()
        f.calendar = calendario; f.timeZone = calendario.timeZone
        f.locale = Locale(identifier: "en_US_POSIX"); f.dateFormat = "yyyy-MM-dd"
        guard var d = calendario.date(byAdding: .day, value: -1, to: hoy) else { return 0 }
        var n = 0
        while n < 400 && !conGasto.contains(f.string(from: d)) {
            n += 1
            guard let antes = calendario.date(byAdding: .day, value: -1, to: d) else { break }
            d = antes
        }
        return n
    }

    static func esEsteMes(_ mes: String) -> Bool { mes == mesDeHoy() }

    static func mesDeHoy(_ hoy: Date = Date()) -> String {
        let c = calendario.dateComponents([.year, .month], from: hoy)
        return String(format: "%04d-%02d", c.year ?? 0, c.month ?? 1)
    }

    static func diaDeHoy(_ hoy: Date = Date()) -> Int {
        calendario.component(.day, from: hoy)
    }

    /**
     * LOS DÍAS SEGUIDOS ANOTANDO.
     *
     * Se cuenta hacia atrás desde hoy. Y si hoy todavía no hay nada, se mira
     * ayer: la racha no se rompe a las once de la mañana por no haber anotado
     * aún. Es la misma concesión que hace la web, y sin ella la tarjeta dice
     * «0 días» media mañana a quien lleva un mes seguido.
     */
    static func rachaDeDias(_ l: CNLibreta, hoy: Date = Date()) -> Int {
        let dias = Set(l.tx.map { String($0.fecha.prefix(10)) })
        if dias.isEmpty { return 0 }
        let f = DateFormatter()
        f.calendar = calendario; f.timeZone = calendario.timeZone
        f.locale = Locale(identifier: "en_US_POSIX"); f.dateFormat = "yyyy-MM-dd"
        var d = hoy
        var n = 0
        if !dias.contains(f.string(from: d)) {
            // Hoy no hay nada: se empieza por ayer, y si ayer tampoco, cero.
            guard let ayer = calendario.date(byAdding: .day, value: -1, to: d),
                  dias.contains(f.string(from: ayer)) else { return 0 }
            d = ayer
        }
        while dias.contains(f.string(from: d)) {
            n += 1
            guard let antes = calendario.date(byAdding: .day, value: -1, to: d) else { break }
            d = antes
        }
        return n
    }

    static func de(_ tipo: String, libreta l: CNLibreta,
                   periodo p: CNCalculo.Periodo, tinte t: Tinte) -> Cifra? {
        let total = CNCalculo.totales(l, p)
        switch tipo {

        case "kpi-ingresos":
            return Cifra(valor: cnDinero(total.ing), nota: cnT("del mes"),
                         color: t.positivo, icono: "entra")

        case "kpi-gastos":
            // En porcentaje de los ingresos, no en dinero: el dinero ya está
            // arriba, y lo que dice algo es cuánto de lo que entró se fue.
            // Sin ingresos es 0 y no una división rota.
            let pct = total.ing > 0 ? Int((total.gas / total.ing * 100).rounded()) : 0
            return Cifra(valor: cnDinero(total.gas),
                         nota: String(pct) + cnT("% de tus ingresos"),
                         color: t.negativo, icono: "sale")

        case "kpi-balance":
            // Dos tarjetas escondidas en una: cambia la nota Y el color.
            let bien = total.bal >= 0
            // CON SIGNO. `cnDinero` lo quita, y un mes en rojo salía con la
            // cifra en positivo y debajo «déficit del mes»: el número decía una
            // cosa y las dos palabras de abajo la contraria.
            return Cifra(valor: cnDineroFirmado(total.bal),
                         nota: bien ? cnT("disponible este mes") : cnT("déficit del mes"),
                         color: bien ? t.tinta : t.negativo, icono: "balance")

        case "kpi-deuda":
            let deuda = CNCalculo.deudaTarjetas(l) + CNCalculo.pendientePrestamos(l)
            return Cifra(valor: cnDinero(deuda), nota: cnT("tarjetas + préstamos"),
                         color: t.ambar, icono: "deuda")

        case "kpi-patrimonio":
            // El color cambia con el signo, pero la nota NO: explica de dónde
            // sale el número, no cómo va.
            let pat = CNCalculo.patrimonio(l)
            // Con signo, por lo mismo: debiendo más de lo que tienes, sin él la
            // tarjeta diría que tu patrimonio es lo que te falta.
            return Cifra(valor: cnDineroFirmado(pat), nota: cnT("cuentas − deudas"),
                         color: pat >= 0 ? t.tinta : t.negativo, icono: "patrimonio")

        // ── LAS SEIS QUE CALCULABA LA WEB ───────────────────────────────
        //
        // Mismas reglas, copiadas una a una de `tarjetaExtra`. Las notas son
        // las suyas, palabra por palabra: son textos traducidos y no me los
        // invento.

        case "kpi-ahorro":
            // En porcentaje de los ingresos, como gastos. Sin ingresos no hay
            // porcentaje que dar y se dice «del mes», no un cero.
            let pc = porciento(total.aho, total.ing)
            return Cifra(valor: cnDinero(total.aho),
                         nota: total.ing > 0
                            ? cnT("{n}% de tus ingresos").replacingOccurrences(of: "{n}", with: String(pc))
                            : cnT("del mes"),
                         color: total.aho > 0 ? t.positivo : t.gris, icono: "hucha")

        case "kpi-diario":
            // Lo que va del mes repartido entre los días CORRIDOS, no entre
            // los del mes: a día 5 el promedio es de cinco días. En un mes
            // pasado se reparte entre todos, que ya terminó.
            let dm = diasDelMes(p.mes)
            let hoyEs = esEsteMes(p.mes)
            let dias = hoyEs ? max(1, diaDeHoy()) : dm
            let porDia = dias > 0 ? total.gas / Double(dias) : 0
            return Cifra(valor: cnDinero((porDia).rounded()),
                         nota: hoyEs
                            ? cnT("a este ritmo, {n} al cierre").replacingOccurrences(
                                of: "{n}", with: cnDinero((porDia * Double(dm)).rounded()))
                            : cnT("promedio del mes"),
                         color: t.negativo, icono: "calendario")

        case "kpi-vs-mes":
            // Contra el mes anterior. El signo es «+» o «−» —el menos de
            // verdad, no un guion— y el color se invierte: gastar MENOS es
            // bueno, así que va en verde.
            let antes = CNCalculo.totales(l, CNCalculo.Periodo(mes: mesAntesDe(p.mes)))
            let dif = total.gas - antes.gas
            let pc = antes.gas > 0 ? Int((dif / antes.gas * 100).rounded()) : 0
            let signo = dif > 0 ? "+" : (dif < 0 ? "\u{2212}" : "")
            return Cifra(valor: signo + cnDinero(abs(dif)),
                         nota: antes.gas > 0
                            ? (dif > 0 ? cnT("gastas {n}% más que el mes pasado")
                                       : cnT("gastas {n}% menos que el mes pasado"))
                                .replacingOccurrences(of: "{n}", with: String(abs(pc)))
                            : cnT("el mes pasado no hubo gastos"),
                         color: dif > 0 ? t.negativo : (dif < 0 ? t.positivo : t.gris),
                         icono: "flechas")

        case "kpi-presupuesto":
            // Solo las categorías CON tope: las que no tienen no entran ni en
            // el límite ni en lo usado, o el porcentaje sale pequeño siempre.
            let conTope = l.presupuesto.filter { $0.value > 0 }
            let limite = conTope.values.reduce(0, +)
            let gastos = CNCalculo.porCategoria(l, p)
            let usado = gastos.filter { conTope[$0.categoria] != nil }.reduce(0) { $0 + $1.gastado }
            let pc = porciento(usado, limite)
            return Cifra(valor: limite > 0 ? String(pc) + "%" : "—",
                         nota: limite > 0
                            ? cnDinero(usado) + " " + cnT("de") + " " + cnDinero(limite)
                            : cnT("Ponle presupuesto a tus categorías"),
                         color: pc > 100 ? t.negativo : (pc > 85 ? t.ambar : t.positivo),
                         icono: "pastel")

        case "kpi-cuotas":
            // Lo que hay que pagar sí o sí: la cuota de cada préstamo que aún
            // debe algo, y lo que se debe en cada tarjeta.
            let dePrestamos = l.prestamos.reduce(0.0) { a, d in
                a + ((d.total - d.pagado) > 0 ? d.cuota : 0)
            }
            let deTarjetas = l.tarjetas.reduce(0.0) { $0 + max(0, $1.saldo) }
            let cuotas = dePrestamos + deTarjetas
            return Cifra(valor: cnDinero(cuotas),
                         nota: total.ing > 0
                            ? cnT("{n}% de tus ingresos").replacingOccurrences(
                                of: "{n}", with: String(porciento(cuotas, total.ing)))
                            : cnT("préstamos y tarjetas"),
                         color: t.ambar, icono: "factura")

        case "kpi-racha":
            // Días seguidos anotando algo. Si hoy no hay nada todavía, la
            // racha de ayer sigue contando: castigar a las once de la mañana
            // por no haber gastado aún no tiene sentido.
            let n = rachaDeDias(l)
            // Los dos `cnT` por separado, no uno con el ternario dentro: el
            // que recoge los textos para traducirlos lee literales, y «día»
            // escondido en un ternario no lo ve nadie.
            return Cifra(valor: String(n) + " " + (n == 1 ? cnT("día") : cnT("días")),
                         nota: n >= 7 ? cnT("¡Sigue así!")
                             : (n > 0 ? cnT("anotando seguido") : cnT("Anota algo hoy y arranca la racha")),
                         color: n >= 7 ? t.positivo : t.gris, icono: "estrella")

        case "kpi-queda-dia":
            // LA ÚNICA CIFRA QUE DICE QUÉ HACER HOY: el presupuesto entero
            // menos lo gastado, repartido entre los días que QUEDAN. Sin
            // presupuesto no hay nada que repartir, y se dice en vez de
            // enseñar un cero que parece un dato.
            let tope = l.presupuesto.values.reduce(0, +)
            if tope <= 0 {
                return Cifra(valor: "—", nota: cnT("Pon un presupuesto y te lo reparto"),
                             color: t.gris, icono: "pastel")
            }
            let dm2 = diasDelMes(p.mes)
            let quedan = esEsteMes(p.mes) ? max(1, dm2 - diaDeHoy() + 1) : dm2
            let queda = tope - total.gas
            return Cifra(valor: cnDinero((queda / Double(quedan)).rounded()),
                         nota: queda > 0
                            ? cnT("al día, {n} días por delante").replacingOccurrences(
                                of: "{n}", with: String(quedan))
                            : cnT("Ya pasaste el presupuesto del mes"),
                         color: queda > 0 ? t.positivo : t.negativo, icono: "calendario")

        case "kpi-cierre":
            // A ESTE RITMO. El gasto por día de lo que va de mes, estirado
            // hasta el último. Es una proyección, no una promesa, y la nota lo
            // dice: «si sigues gastando igual».
            let dm3 = diasDelMes(p.mes)
            let esteMes3 = esEsteMes(p.mes)
            let van = esteMes3 ? max(1, diaDeHoy()) : dm3
            let cierre = total.ing - (total.gas / Double(van)) * Double(dm3)
            return Cifra(valor: (cierre < 0 ? "\u{2212}" : "") + cnDinero(abs(cierre).rounded()),
                         nota: esteMes3 ? cnT("si sigues gastando igual") : cnT("así cerró el mes"),
                         color: cierre >= 0 ? t.positivo : t.negativo, icono: "grafico")

        case "kpi-proximo":
            // EL SIGUIENTE, no la lista: la de recordatorios ya existe. Lo que
            // se mira cada mañana es cuál toca ahora.
            guard let p0 = CNCalculo.pagosQueVienen(l).first else {
                return Cifra(valor: "—", nota: cnT("Nada por pagar"), color: t.gris, icono: "campana")
            }
            let cuando = p0.dias == 0 ? cnT("hoy")
                : cnT("en {n} d").replacingOccurrences(of: "{n}", with: String(p0.dias))
            return Cifra(valor: cnDinero(p0.monto), nota: p0.nombre + " · " + cuando,
                         color: p0.dias <= 3 ? t.negativo : (p0.dias <= 7 ? t.ambar : t.gris),
                         icono: "campana")

        case "kpi-sin-gastar":
            // Días seguidos SIN gastar, contando desde AYER: el de hoy todavía
            // no ha terminado, y contarlo da una racha que se rompe por la
            // tarde con la primera compra.
            let n2 = diasSinGastar(l)
            return Cifra(valor: String(n2) + " " + (n2 == 1 ? cnT("día") : cnT("días")),
                         nota: n2 == 0 ? cnT("Ayer gastaste") : cnT("seguidos sin gastar"),
                         color: n2 >= 3 ? t.positivo : t.gris, icono: "estrella")

        case "kpi-comprometido":
            // CUÁNTO DEL MES YA ESTABA DECIDIDO antes de empezarlo. Lo fijo no
            // se negocia con uno mismo; lo variable sí, y por ahí se recorta.
            let fijo = total.fij
            let pcF = porciento(fijo, total.gas)
            return Cifra(valor: String(pcF) + "%",
                         nota: total.gas > 0
                            ? cnT("de tus gastos es fijo · {n} variable").replacingOccurrences(
                                of: "{n}", with: cnDinero((total.gas - fijo).rounded()))
                            : cnT("Sin gastos este mes"),
                         color: pcF >= 70 ? t.negativo : (pcF >= 50 ? t.ambar : t.positivo),
                         icono: "candado")

        case "kpi-ahorro-ano":
            // Las metas van cada una por su lado y el total nunca se ve.
            let ano = String(p.mes.prefix(4))
            let apartado = l.tx
                .filter { $0.tipo == "Ahorro" && $0.fecha.hasPrefix(ano) }
                .reduce(0.0) { $0 + abs($1.monto) }
            return Cifra(valor: cnDinero(apartado),
                         nota: cnT("apartado en {a}").replacingOccurrences(of: "{a}", with: ano),
                         color: apartado > 0 ? t.positivo : t.gris, icono: "hucha")

        case "kpi-ano-pasado":
            // La única comparación honesta cuando hay temporadas: diciembre
            // con diciembre. Frente al mes pasado, diciembre siempre sale mal.
            let haceUnAno = mesDelAnoPasado(p.mes)
            let antesA = CNCalculo.totales(l, CNCalculo.Periodo(mes: haceUnAno))
            if antesA.gas <= 0 {
                return Cifra(valor: "—", nota: cnT("No hay nada del año pasado"),
                             color: t.gris, icono: "grafico")
            }
            let difA = total.gas - antesA.gas
            let pcA = porciento(abs(difA), antesA.gas)
            let signoA = difA > 0 ? "+" : (difA < 0 ? "\u{2212}" : "")
            return Cifra(valor: signoA + String(pcA) + "%",
                         nota: cnT("que en el mismo mes de {a}").replacingOccurrences(
                            of: "{a}", with: String(haceUnAno.prefix(4))),
                         color: difA > 0 ? t.negativo : (difA < 0 ? t.positivo : t.gris),
                         icono: "grafico")

        default:
            return nil
        }
    }

    /// Los tipos que esto sabe calcular. Lo demás sigue viniendo de la web.
    static let sabeHacer: Set<String> = [
        "kpi-ingresos", "kpi-gastos", "kpi-balance", "kpi-deuda", "kpi-patrimonio",
        // Las que la web calculaba en `tarjetaExtra` y el teléfono no sabía
        // hacer: llegaban escritas por el puente y, sin web, salían en blanco.
        "kpi-ahorro", "kpi-diario", "kpi-vs-mes", "kpi-presupuesto", "kpi-cuotas", "kpi-racha",
        "kpi-queda-dia", "kpi-cierre", "kpi-proximo", "kpi-sin-gastar",
        "kpi-comprometido", "kpi-ahorro-ano", "kpi-ano-pasado"
    ]
}
