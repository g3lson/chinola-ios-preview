import Foundation

/**
 * LAS TRES TARJETAS DE LISTA DEL RESUMEN, Y EL CONSEJO.
 *
 * Últimos movimientos, recordatorios de pago y avance de metas. Más el consejo
 * de Chino, que es una frase pero con reglas.
 *
 * COPIADO REGLA POR REGLA, como los otros dos. Y en las listas lo que se pierde
 * al rehacerlas de memoria es el FORMATO, que es justo lo que nadie apunta:
 *
 * - Cinco movimientos, no diez. La tarjeta es un vistazo, no la pantalla de
 *   movimientos: con diez hay que leerla y deja de servir de vistazo.
 * - El signo del monto depende del tipo, y una transferencia NO LLEVA NINGUNO.
 *   Es lo correcto: un traspaso entre cuentas tuyas no entra ni sale, y
 *   ponerle un signo lo convierte en un gasto o un ingreso que no existió.
 * - El detalle de un movimiento es «categoría · día mes», en ese orden. La
 *   categoría primero porque es por lo que se busca con la vista.
 * - Un recordatorio de HOY dice «hoy», no «en 0 d». Nadie dice «en cero días».
 * - Una meta terminada dice «completada» y no «listo en ~0 meses».
 *
 * Los colores salen del tema, como en las demás.
 */
enum CNTarjetasLista {

    /// Lo que hace falta del tema para pintar una lista.
    struct Tinte {
        var gris: String
        var positivo: String
        var negativo: String
        var lila: String
        var ambar: String
    }

    /// Una fila de cualquiera de las tres listas.
    struct Fila {
        var titulo: String
        var detalle: String
        var monto: String
        var montoColor: String
        var sigla: String
        var color: String
        var categoria: String
    }

    /// Cuántas filas caben en un vistazo.
    private static let CABEN = 5

    /* ------------------------- últimos movimientos ------------------------ */

    static func recientes(_ l: CNLibreta, _ p: CNCalculo.Periodo, tinte t: Tinte) -> [Fila] {
        // El MISMO orden que la pantalla de Movimientos, y por la misma razón.
        //
        // Aquí desempataba por identificador —un texto— en vez de por la hora de
        // alta, y eso no es lo mismo: los identificadores llevan una letra
        // delante («m», «tr», «dp»), así que una transferencia y un movimiento
        // del mismo día salían ordenados por esa letra. Dos listas del mismo día
        // en la misma pantalla, cada una en su orden.
        let vis = CNMovimientos.visibles(l, periodo: p)
        return vis.prefix(CABEN).map { x in
            // Una transferencia no lleva signo: es un traspaso entre cuentas
            // tuyas, no entra ni sale. Ponerle uno la convierte en un gasto o
            // un ingreso que no existió.
            let signo = x.tipo == "Transferencia" ? "" : (x.tipo == "Ingreso" ? "+" : "−")
            let color = x.tipo == "Transferencia" ? t.gris
                : x.tipo == "Ingreso" ? t.positivo
                : x.tipo == "Ahorro" ? t.lila : t.negativo
            return Fila(titulo: x.concepto,
                        // La categoría primero: es por lo que se busca con la
                        // vista al repasar la lista.
                        detalle: x.categoria + " · " + cnFechaCorta(x.fecha),
                        monto: signo + cnDinero(x.monto), montoColor: color,
                        sigla: CNCategorias.inicial(x.categoria),
                        color: color, categoria: x.categoria)
        }
    }

    /* ------------------------ recordatorios de pago ----------------------- */

    /**
     * CÓMO SE ROTULA UN PAGO QUE VIENE, sin formato ni traducción.
     *
     * La misma que `pagosQueVienen` de la web, y el fichero de oro ejecuta las
     * dos y las compara. El tono va por cercanía —rojo si es esta semana corta,
     * ámbar si es la que viene, verde si aún queda—, que es lo que deja barrer
     * la lista sin leer los días.
     */
    struct Aviso {
        var esHoy = false
        var plazo = ""
        var tono = ""
    }

    static func avisoDe(_ dias: Int) -> Aviso {
        // «hoy» y no «en 0 d»: nadie dice «en cero días».
        Aviso(esHoy: dias == 0, plazo: dias == 0 ? "hoy" : "en \(dias) d",
              tono: dias <= 3 ? "negativo" : (dias <= 7 ? "ambar" : "positivo"))
    }

    static func recordatorios(_ l: CNLibreta, tinte t: Tinte, desde: Date = Date()) -> [Fila] {
        CNCalculo.pagosQueVienen(l, desde: desde).map { p in
            let av = avisoDe(p.dias)
            let color = av.tono == "negativo" ? t.negativo : (av.tono == "ambar" ? t.ambar : t.positivo)
            let plazo = av.esHoy ? cnT("hoy") : cnT("en {n} d").replacingOccurrences(of: "{n}", with: String(p.dias))
            // El título dice QUÉ es —un pago de tarjeta o una cuota— y no
            // solo el nombre: con tres filas seguidas, «Visa» y «Visa» no se
            // distinguen si una es el corte y otra la cuota de un préstamo.
            let que = p.tipo == "tarjeta" ? cnT("Pago") : cnT("Cuota")
            // El detalle dice cuánto y, en una tarjeta, DESDE CUÁNDO cuenta:
            // «RD$3,200 · corte día 15». Sin el corte la fila dice cuánto hay
            // que pagar y cuándo, pero no qué periodo se está pagando, que es
            // justo lo que uno mira para saber si el gasto de ayer ya entró.
            var detalle = cnDinero(p.monto)
            if p.tipo == "tarjeta" && p.corte > 0 {
                detalle += " · " + cnT("corte día {n}").replacingOccurrences(of: "{n}", with: String(p.corte))
            }
            return Fila(titulo: que + " " + p.nombre, detalle: detalle,
                        monto: plazo, montoColor: color,
                        sigla: "!", color: color, categoria: "")
        }
    }

    /* ---------------------------- avance de metas ------------------------- */

    /**
     * CÓMO VA UNA META: el porcentaje, lo que falta y en cuántos meses se llega.
     *
     * La misma que `avanceDeMeta` de la web. Sin aporte mensual no hay
     * proyección —cero meses—, y una meta terminada dice «completada» y no
     * «listo en ~0 meses».
     */
    struct Avance {
        var pct = 0
        var restante: Double = 0
        var meses = 0
        var completada = false
    }

    static func avanceDeMeta(_ g: CNMeta) -> Avance {
        let restante = max(0, g.meta - g.ahorrado)
        return Avance(pct: g.meta > 0 ? min(100, Int((g.ahorrado / g.meta * 100).rounded())) : 0,
                      restante: restante,
                      meses: g.mensual > 0 ? Int(ceil(restante / g.mensual)) : 0,
                      completada: restante == 0)
    }

    static func metas(_ l: CNLibreta, tinte t: Tinte) -> [Fila] {
        l.metas.map { g in
            let pct = avanceDeMeta(g).pct
            let color = g.color.isEmpty ? t.lila : g.color
            return Fila(titulo: g.nombre,
                        detalle: cnDinero(g.ahorrado) + " " + cnT("de") + " " + cnDinero(g.meta),
                        monto: String(pct) + "%", montoColor: color,
                        sigla: CNCategorias.inicial(g.nombre),
                        color: color, categoria: "")
        }
    }

    /* --------------------------- el consejo de Chino ---------------------- */

    /**
     * La frase del consejo.
     *
     * Tres, en orden de urgencia. La primera es la única que pide hacer algo
     * hoy; las otras dos cuentan cómo estás.
     */
    /// Cuál de las tres frases toca, y con qué números. Sin la frase: la escribe
    /// cada pantalla, y en el escritorio no dice lo mismo.
    struct Consejo {
        var clave = ""
        var monto: Double = 0
        var pct = 0
    }

    static func consejoDeChino(_ l: CNLibreta, _ t: CNCalculo.Totales) -> Consejo {
        if t.bal < 0 { return Consejo(clave: "corto") }
        let cuotas = l.prestamos.filter { $0.total - $0.pagado > 0 }.reduce(0.0) { $0 + $1.cuota }
        if cuotas > 0 {
            return Consejo(clave: "cuotas", monto: cuotas,
                           pct: t.ing > 0 ? Int((cuotas / t.ing * 100).rounded()) : 0)
        }
        return Consejo(clave: "sinCuotas")
    }

    static func consejo(_ l: CNLibreta, _ p: CNCalculo.Periodo) -> String {
        let c = consejoDeChino(l, CNCalculo.totales(l, p))
        if c.clave == "corto" { return cnT("Este mes va corto: empieza por los gastos variables.") }
        if c.clave == "cuotas" {
            return cnT("Tus cuotas fijas son {monto}, un {pct}% de tus ingresos.")
                .replacingOccurrences(of: "{monto}", with: cnDinero(c.monto))
                .replacingOccurrences(of: "{pct}", with: String(c.pct))
        }
        return cnT("Sin cuotas este mes: buen momento para aportar a tus metas.")
    }

    /// Los tipos que esto sabe hacer. Lo demás sigue viniendo de la web.
    static let sabeHacer: Set<String> = [
        "lista-recientes", "lista-recordatorios", "lista-metas", "texto-consejo"
    ]
}
