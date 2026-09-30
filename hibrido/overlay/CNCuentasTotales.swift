import Foundation

/**
 * LOS TOTALES DE LA PANTALLA DE CUENTAS, CALCULADOS AQUÍ.
 *
 * Cada grupo —cuentas, tarjetas, préstamos— dice en su propio rótulo cuánto
 * suma. Es la pregunta que uno se hace al mirar la lista: «¿cuánto tengo en
 * cuentas?», «¿cuánto debo de tarjetas?». Antes esa cifra estaba solo en el
 * patrimonio de arriba, mezclada con todo lo demás.
 *
 * LA REGLA QUE MÁS FÁCIL SE PIERDE, y por eso va la primera:
 *
 * **Los préstamos van en los dos sentidos.** Hay préstamos que debes y
 * préstamos que te deben, y el rótulo cambia según cuál pese: si no debes nada
 * y solo te deben, dice «Te deben» y va en verde. Rehaciéndolo de memoria sale
 * un único «Debes» en rojo — y alguien que solo presta dinero vería su pantalla
 * diciendo que debe lo que le deben a él. Ese fallo no rompe nada: solo miente.
 *
 * Y una que parece cosmética y no lo es: **los totales se tapan también cuando
 * el ojo está cerrado.** Ocultar las cifras de cada fila pero dejar la suma
 * arriba no oculta nada — con dos cuentas, la suma dice cuánto hay en cada una.
 */
enum CNCuentasTotales {

    /// Un total de grupo: qué dice, cuánto, y de qué color.
    struct Total {
        var rotulo: String
        var valor: String
        var positivo: Bool
    }

    /// Lo que se enseña cuando el ojo está cerrado.
    static let TAPADO = "••••"

    /// Cuánto queda por cobrar o por pagar de un préstamo.
    private static func falta(_ p: CNPrestamo) -> Double { max(0, p.total - p.pagado) }

    /// Los préstamos que te deben a ti. El resto son los que debes tú.
    private static func mio(_ p: CNPrestamo) -> Bool { p.sentido == "meDeben" }

    /// Lo que tienes, sumando todas las cuentas.
    static func cuentas(_ l: CNLibreta, oculto: Bool = false) -> Total {
        let suma = l.cuentas.reduce(0.0) { $0 + $1.saldo }
        return Total(rotulo: cnT("Tienes"),
                     valor: oculto ? TAPADO : cnDinero(suma), positivo: true)
    }

    /// Lo que debes de tarjetas.
    static func tarjetas(_ l: CNLibreta, oculto: Bool = false) -> Total {
        let suma = l.tarjetas.reduce(0.0) { $0 + $1.saldo }
        return Total(rotulo: cnT("Debes"),
                     valor: oculto ? TAPADO : cnDinero(suma), positivo: false)
    }

    /**
     * Los préstamos, en el sentido que toque.
     *
     * Si no debes nada y solo te deben, el rótulo cambia a «Te deben» y la
     * cifra va en verde. Con un único «Debes», alguien que solo presta dinero
     * vería su pantalla diciendo que debe lo que le deben a él.
     */
    static func prestamos(_ l: CNLibreta, oculto: Bool = false) -> Total {
        let debo = l.prestamos.filter { !mio($0) }.reduce(0.0) { $0 + falta($1) }
        let meDeben = l.prestamos.filter(mio).reduce(0.0) { $0 + falta($1) }
        let soloMeDeben = debo == 0 && meDeben > 0
        let cuanto = soloMeDeben ? meDeben : debo
        return Total(rotulo: soloMeDeben ? cnT("Te deben") : cnT("Debes"),
                     valor: oculto ? TAPADO : cnDinero(cuanto), positivo: soloMeDeben)
    }

    /**
     * El patrimonio: lo que tienes menos lo que debes.
     *
     * LO QUE TE DEBEN SÍ SUMA, y aquí estaba escrito al contrario. El dinero
     * prestado a alguien sigue siendo tuyo, solo que está fuera; restándolo,
     * prestarle dinero a un amigo te empobrecía en la pantalla. Y como los
     * pasivos se enseñan aparte, estaba mal por dos sitios: el número de abajo
     * decía que debías lo que te debían a ti.
     *
     * No se calcula aquí: se le pregunta a `CNCalculo`, que es quien lo sabe.
     * Habiendo dos cuentas del patrimonio en la misma app, una de las dos
     * miente, y el día que cambie la regla solo se cambia una.
     */
    static func patrimonio(_ l: CNLibreta, oculto: Bool = false) -> (valor: String, activos: String, pasivos: String) {
        // Lo que tienes: en cuentas, más lo que está prestado y va a volver.
        let activos = CNCalculo.saldoCuentas(l) + CNCalculo.porCobrarPrestamos(l)
        // Lo que debes: tarjetas y los préstamos que debes TÚ.
        let pasivos = CNCalculo.deudaTarjetas(l) + CNCalculo.deudaPrestamos(l)
        return (oculto ? TAPADO : cnDinero(CNCalculo.patrimonio(l)),
                oculto ? TAPADO : cnDinero(activos),
                oculto ? TAPADO : cnDinero(pasivos))
    }

    /**
     * Cuánto se está usando del límite de una tarjeta, de 0 a 1.
     *
     * Sin límite puesto devuelve 0 y no una división rota: mucha gente no
     * apunta el límite de su tarjeta, y esa tarjeta tiene que salir igual.
     */
    static func usoDelLimite(_ t: CNTarjeta) -> Double {
        t.limite > 0 ? min(1, t.saldo / t.limite) : 0
    }
}
