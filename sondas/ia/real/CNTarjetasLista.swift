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
        let vis = l.tx.filter { CNCalculo.enPeriodo($0.fecha, p) }
            .sorted { $0.fecha != $1.fecha ? $0.fecha > $1.fecha : $0.id > $1.id }
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
                        sigla: String(x.categoria.prefix(1)).uppercased(),
                        color: color, categoria: x.categoria)
        }
    }

    /* ------------------------ recordatorios de pago ----------------------- */

    static func recordatorios(_ l: CNLibreta, tinte t: Tinte, desde: Date = Date()) -> [Fila] {
        CNCalculo.pagosQueVienen(l, desde: desde).map { p in
            // Por cercanía: rojo si es esta semana corta, ámbar si es la que
            // viene, y verde si aún queda. Es lo que deja barrer la lista sin
            // leer los días.
            let color = p.dias <= 3 ? t.negativo : (p.dias <= 7 ? t.ambar : t.positivo)
            // «hoy» y no «en 0 d»: nadie dice «en cero días».
            let plazo = p.dias == 0 ? cnT("hoy") : cnT("en {n} d").replacingOccurrences(of: "{n}", with: String(p.dias))
            // El título dice QUÉ es —un pago de tarjeta o una cuota— y no
            // solo el nombre: con tres filas seguidas, «Visa» y «Visa» no se
            // distinguen si una es el corte y otra la cuota de un préstamo.
            let que = p.tipo == "tarjeta" ? cnT("Pago") : cnT("Cuota")
            return Fila(titulo: que + " " + p.nombre, detalle: cnDinero(p.monto),
                        monto: plazo, montoColor: color,
                        sigla: "!", color: color, categoria: "")
        }
    }

    /* ---------------------------- avance de metas ------------------------- */

    static func metas(_ l: CNLibreta, tinte t: Tinte) -> [Fila] {
        l.metas.map { g in
            let pct = g.meta > 0 ? min(100, Int((g.ahorrado / g.meta * 100).rounded())) : 0
            let color = g.color.isEmpty ? t.lila : g.color
            return Fila(titulo: g.nombre,
                        detalle: cnDinero(g.ahorrado) + " " + cnT("de") + " " + cnDinero(g.meta),
                        monto: String(pct) + "%", montoColor: color,
                        sigla: String(g.nombre.prefix(1)).uppercased(),
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
    static func consejo(_ l: CNLibreta, _ p: CNCalculo.Periodo) -> String {
        let t = CNCalculo.totales(l, p)
        if t.bal < 0 { return cnT("Este mes va corto: empieza por los gastos variables.") }
        let cuotas = l.prestamos.filter { $0.total - $0.pagado > 0 }.reduce(0.0) { $0 + $1.cuota }
        if cuotas > 0 {
            let pct = t.ing > 0 ? Int((cuotas / t.ing * 100).rounded()) : 0
            return cnT("Tus cuotas fijas son {monto}, un {pct}% de tus ingresos.")
                .replacingOccurrences(of: "{monto}", with: cnDinero(cuotas))
                .replacingOccurrences(of: "{pct}", with: String(pct))
        }
        return cnT("Sin cuotas este mes: buen momento para aportar a tus metas.")
    }

    /// Los tipos que esto sabe hacer. Lo demás sigue viniendo de la web.
    static let sabeHacer: Set<String> = [
        "lista-recientes", "lista-recordatorios", "lista-metas", "texto-consejo"
    ]
}
