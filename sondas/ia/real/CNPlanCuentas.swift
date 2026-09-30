import Foundation

/**
 * LO QUE DICE CADA FILA DEL PLAN.
 *
 * Se llama `CNPlanCuentas` y no `CNPlan` porque ese nombre ya era de la VISTA
 * de la pantalla. Dos tipos con el mismo nombre no compilan, y el que estaba
 * primero es el que se queda.
 *
 * El cálculo del presupuesto ya estaba en `CNCalculo.presupuesto`: qué
 * categorías entran, cuánto se gastó de cada tope y cuáles se pasaron. Lo que
 * faltaba era lo que se LEE, y ahí hay una regla que importa más de lo que
 * parece.
 *
 * **La barra se recorta al 100 %, pero el texto no.** Una categoría con el tope
 * en 1.000 y 1.500 gastados enseña la barra llena —no hay barra más llena que
 * llena— y el texto dice «−500». Si el texto también se recortara, gastar un
 * 10 % de más y gastar el triple se verían exactamente igual: la barra llena y
 * «100 %». Justo cuando más falta hace saber cuánto.
 *
 * Y tres estados distintos que se confunden fácil:
 *
 * - **Te pasaste**: se dice cuánto, en negativo.
 * - **Agotado**: gastaste exactamente el tope. No te pasaste, pero no queda
 *   nada — y «0» a secas se lee como si no hubieras gastado.
 * - **Queda**: lo que falta para llegar al tope.
 *
 * El color sigue lo mismo: rojo al pasarse, ámbar a partir del 85 % —que es
 * cuando todavía se puede hacer algo— y verde por debajo.
 */
enum CNPlanCuentas {

    /// Lo que hace falta del tema para pintar una fila del plan.
    struct Tinte {
        var positivo: String
        var ambar: String
        var negativo: String
    }

    /// Una fila lista para leer.
    struct Fila {
        var categoria: String
        var limite: String
        var gastado: String
        /// 0…100: la barra no pasa de llena.
        var pct: Int
        /// Lo que queda, lo que te pasaste, o «Agotado».
        var queda: String
        var color: String
        var excedida: Bool
    }

    /// A partir de qué porcentaje del tope se avisa en ámbar.
    private static let AVISO = 85

    /**
     * Las filas del plan, con su texto y su color.
     *
     * Ojo con el orden de los tres casos: «agotado» tiene que mirarse DESPUÉS
     * de «te pasaste» y con `>=`, o gastar exactamente el tope caería en «te
     * queda 0» — que se lee como si no hubieras gastado nada.
     */
    static func filas(_ l: CNLibreta, _ p: CNCalculo.Periodo, tinte t: Tinte) -> [Fila] {
        CNCalculo.presupuesto(l, p).filas.map { f in
            // El porcentaje SIN recortar, solo para decidir el color: con el
            // recortado, una categoría al 150 % y otra al 100 % darían el mismo
            // aviso.
            let crudo = f.limite > 0 ? Int((f.gastado / f.limite * 100).rounded()) : 0
            let queda: String
            if f.excedida {
                // Cuánto de más, en negativo. Es el dato que la barra no puede
                // enseñar porque ya está llena.
                queda = "−" + cnDinero(f.gastado - f.limite)
            } else if f.limite > 0 && f.gastado >= f.limite {
                queda = cnT("Agotado")
            } else {
                queda = cnDinero(f.limite - f.gastado)
            }
            return Fila(categoria: f.categoria,
                        limite: cnDinero(f.limite), gastado: cnDinero(f.gastado),
                        pct: f.pct, queda: queda,
                        color: f.excedida ? t.negativo : (crudo > AVISO ? t.ambar : t.positivo),
                        excedida: f.excedida)
        }
    }

    /**
     * El resumen de arriba: cuánto del plan llevas gastado y cuántas se pasaron.
     *
     * Sin ningún tope puesto no hay plan que resumir, y decir «0 %» sería
     * decir que vas bien cuando en realidad no hay nada con qué comparar.
     */
    static func resumen(_ l: CNLibreta, _ p: CNCalculo.Periodo) -> (hay: Bool, pct: Int, gastado: String, tope: String, excedidas: Int) {
        let r = CNCalculo.presupuesto(l, p)
        return (r.limiteTotal > 0, r.pctTotal, cnDinero(r.gastadoTotal), cnDinero(r.limiteTotal), r.excedidas)
    }
}
