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

        default:
            return nil
        }
    }

    /// Los tipos que esto sabe calcular. Lo demás sigue viniendo de la web.
    static let sabeHacer: Set<String> = [
        "kpi-ingresos", "kpi-gastos", "kpi-balance", "kpi-deuda", "kpi-patrimonio"
    ]
}
