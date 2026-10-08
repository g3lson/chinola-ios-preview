import Foundation

/**
 * LA PANTALLA DEL PLAN, ARMADA AQUÍ.
 *
 * El contenido ya se calculaba en el teléfono —`refrescarPlan` rehace los
 * números de cada fila en cuanto cambia algo—, pero empezaba con
 * `guard var m = plan`: el ESQUELETO —las dos pestañas, los títulos, qué
 * categorías hay y qué metas— seguía viniendo de la web.
 *
 * Y la web solo lo arma estando EN la pestaña del Plan. Desde cualquier otra
 * contesta `listo:false` y sin una sola fila, así que el cálculo nativo no
 * tenía dónde escribir. Es el mismo fallo que dejó el Resumen con la cabecera
 * sola y Cuentas con la tarjeta del patrimonio sola.
 *
 * NADA SE DEDUJO: cada rótulo y cada regla salen de `test/plan-oro.json`,
 * medido con la app en marcha. Las que de memoria salen mal:
 *
 *  · **una categoría sin presupuesto no «deja» nada.** La derecha se calla y
 *    el pie lo dice una sola vez: «RD$0 · sin presupuesto», no
 *    «RD$0 de RD$0», que es decir que tienes un tope de cero;
 *  · **el aviso solo sale cuando hay algo que avisar.** Con todo dentro, la
 *    barra verde de arriba ya lo dice y un recuadro más solo estorba;
 *  · **y se dice como se habla**: «Una categoría se pasó» en singular, no
 *    «1 categoría»;
 *  · **los días que quedan son los del mes QUE SE MIRA.** Mirando otro mes no
 *    queda ninguno: decir «te quedan 23 días» de un mes ya cerrado es mentira.
 */
enum CNPlanArma {

    /// Los colores que cambian con la paleta.
    struct Tinte {
        var tinta = ""; var gris = ""; var positivo = ""; var aviso = ""; var negativo = ""
        var side = ""; var borde = ""; var lila = ""
    }

    /// Lo que se lee encima del carril de la pestaña elegida.
    static let sobreOscuro = "oklch(0.96 0.03 95)"

    /// «Una categoría se pasó del presupuesto: Transporte», en singular o en
    /// plural. Vacío cuando no hay ninguna: la barra verde de arriba ya lo dice.
    static func aviso(_ excedidas: [String]) -> String {
        guard !excedidas.isEmpty else { return "" }
        let cola = excedidas.joined(separator: ", ")
        if excedidas.count == 1 {
            return cnT("Una categoría se pasó del presupuesto: {c}")
                .replacingOccurrences(of: "{c}", with: cola)
        }
        return cnT("{n} categorías se pasaron del presupuesto: {c}")
            .replacingOccurrences(of: "{n}", with: String(excedidas.count))
            .replacingOccurrences(of: "{c}", with: cola)
    }

    static func arma(_ l: CNLibreta, _ p: CNCalculo.Periodo, tab: String,
                     yo correo: String, tinte t: Tinte) -> CNPlanModelo {
        var m = CNPlanModelo()
        m.listo = true
        m.titulo = cnT("Plan")
        m.tab = tab == "metas" ? "metas" : "presupuesto"
        let etiquetas = [cnT("Presupuesto"), cnT("Metas")]
        m.tabs = etiquetas.enumerated().map { i, label in
            CNPlanModelo.Tab(indice: i, label: label,
                             puesta: (i == 1) == (m.tab == "metas"))
        }
        m.puedeEditar = CNPapeles.puedeEditar(l, yo: correo)
        m.puedeRegistrar = CNPapeles.puedeRegistrar(l, yo: correo)

        let pres = CNCalculo.presupuesto(l, p)
        m.presGastado = cnDinero(pres.gastadoTotal)
        m.presDe = cnT("de")
        m.presTotal = cnDinero(pres.limiteTotal)
        m.presPct = Double(pres.pctTotal)
        let pasado = pres.gastadoTotal > pres.limiteTotal
        if pasado { m.presColor = t.negativo }
        else if pres.pctTotal > 85 { m.presColor = t.aviso }
        else { m.presColor = t.positivo }
        m.presAvisoTinta = t.aviso
        // LO QUE EL ARO NECESITA NO SE PONE AQUÍ, y a propósito.
        //
        // La web mandaba cuatro campos más —cuánto queda, si te pasaste, si
        // hay tope y los días que faltan— «para el aro». El modelo nativo
        // nunca los leyó: el aro los calcula él con la libreta, en
        // `CuentasPres`. Cuatro cifras que viajaban por el puente en cada
        // repintado y que nadie miraba. Rehacerlas aquí sería la misma cuenta
        // escrita dos veces, y de esas la que se desvía no avisa.

        let filasCalc = CNPlanCuentas.filas(l, p, tinte: CNPlanCuentas.Tinte(
            positivo: t.positivo, ambar: t.aviso, negativo: t.negativo))
        m.presNota = aviso(filasCalc.filter { $0.excedida }.map { cnT($0.categoria) })

        m.tituloCategorias = cnT("Categorías")
        m.rotuloNuevaCat = cnT("Categoría")
        m.tituloTusMetas = cnT("Tus metas")
        m.rotuloNuevaMeta = cnT("Meta")
        m.filas = filasCalc.enumerated().map { i, f in filaDe(i, f, l, t) }
        m.metas = l.metas.enumerated().map { i, g in metaDe(i, g, t) }
        return m
    }

    /// Una fila del presupuesto.
    private static func filaDe(_ i: Int, _ f: CNPlanCuentas.Fila,
                               _ l: CNLibreta, _ t: Tinte) -> CNPlanModelo.Fila {
        var x = CNPlanModelo.Fila()
        x.indice = i
        // POR EL DICCIONARIO: las de fábrica son textos nuestros —«Vivienda»,
        // «Alimentación»— y con la app en inglés salían en español. Una que
        // escriba el usuario no está en él y sale tal cual, que es lo correcto.
        x.nombre = cnT(f.categoria)
        let limite = l.presupuesto[f.categoria] ?? 0
        // SIN PRESUPUESTO NO HAY NADA QUE «QUEDE». La derecha se calla y el pie
        // lo dice una sola vez. Con «RD$0 de RD$0» parece que tienes un tope
        // de cero y te lo has gastado entero.
        x.queda = limite > 0 ? f.queda : ""
        x.pie = limite > 0
            ? [f.gastado, cnT("de"), f.limite].joined(separator: " ")
            : f.gastado + " · " + cnT("sin presupuesto")
        x.pct = Double(f.pct)
        x.color = f.color
        let cat = l.categorias.first { $0.nombre == f.categoria }
        x.iconoPath = CNCatalogos.iconos[CNCategorias.icono(f.categoria, en: l)] ?? ""
        x.catColor = cat?.color ?? ""
        x.iconoBg = CNCuentasFilas.tinte(cat?.color ?? "")
        return x
    }

    /// Una meta de la segunda pestaña.
    private static func metaDe(_ i: Int, _ g: CNMeta, _ t: Tinte) -> CNPlanModelo.Meta {
        var x = CNPlanModelo.Meta()
        let a = CNTarjetasLista.avanceDeMeta(g)
        x.indice = i
        x.idm = g.id
        x.nombre = g.nombre
        // «Completada» cuando no queda nada: «listo en ~0 meses» no se dice.
        // Y con mayúscula, que ese pie ya no va detrás de otra frase.
        let crudo = a.completada
            ? cnT("completada")
            : cnT("listo en ~{n} meses").replacingOccurrences(of: "{n}", with: String(a.meses))
        x.proyeccion = crudo.prefix(1).uppercased() + crudo.dropFirst()
        x.pct = Double(a.pct)
        x.pctLabel = String(a.pct) + "%"
        x.color = g.color.isEmpty ? t.lila : g.color
        x.iconoPath = CNDetallePantalla.glifoDeMeta(g)
        x.iconoBg = CNCuentasFilas.tinte(g.color.isEmpty ? t.lila : g.color)
        x.pie = [cnDinero(g.ahorrado), cnT("de"), cnDinero(g.meta)].joined(separator: " ")
        x.falta = cnT("Falta") + " " + cnDinero(a.restante)
        x.aportar = g.mensual > 0 ? cnT("Aportar") + " " + cnDinero(g.mensual) : ""
        return x
    }
}
