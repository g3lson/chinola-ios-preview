import Foundation

/**
 * LAS TRES TARJETAS DE GRÁFICO DEL RESUMEN, CALCULADAS AQUÍ.
 *
 * Gastos por categoría, ingresos contra gastos, y la mezcla de gastos. Igual
 * que las de cifra: el dibujo ya lo sabía hacer el nativo y las cuentas ya
 * estaban en `CNCalculo`; lo que faltaba era la receta, y la receta vivía en la
 * web.
 *
 * COPIADA REGLA POR REGLA. Y aquí las reglas pequeñas pesan más que en las
 * cifras, porque un gráfico mal ajustado no se ve mal — se ve BIEN y dice otra
 * cosa:
 *
 * - Las categorías se cortan en CINCO. No es un límite técnico: con doce
 *   barras de tres píxeles no se compara nada, y las cinco primeras son las
 *   que explican a dónde se fue el dinero.
 * - Cada barra se mide contra la MAYOR, no contra el total. Contra el total,
 *   un mes repartido entre ocho categorías da ocho barritas iguales de nada.
 * - Una columna nunca baja de 3 de alto aunque su mes sea cero. Sin ese suelo,
 *   un mes sin movimientos desaparece del gráfico y parece que no existió.
 * - La dona reparte sobre gastos MÁS ahorro, no solo gastos. Lo apartado
 *   también salió del mes: dejarlo fuera hincha los porcentajes de lo demás.
 *
 * Los colores vienen del tema, como en las cifras: aquí se decide cuál toca.
 */
enum CNTarjetasGrafico {

    /// Lo que hace falta del tema para pintar un gráfico.
    struct Tinte {
        var franja: String     // el verde de la marca, para lo fijo
        var negativo: String   // el coral, para lo variable
        var lila: String       // lo apartado
    }

    /// Una fila de barra: su nombre, su cifra y cuánto ocupa (0…100).
    struct FilaBarra {
        var label: String
        var valor: String
        var pct: Int
        var categoria: String
    }

    /// Una columna del mes a mes: dos alturas sobre la misma base.
    struct Columna {
        var label: String
        var a: Int   // lo que entró
        var b: Int   // lo que salió
    }

    /// Un trozo de la dona.
    struct Trozo {
        var label: String
        var valor: String
        var color: String
        var desde: Int
        var hasta: Int
    }

    /// Un porcentaje de a sobre b, redondeado y sin pasarse de 100.
    private static func pct(_ a: Double, _ b: Double) -> Int {
        b > 0 ? min(100, Int((a / b * 100).rounded())) : 0
    }

    /**
     * GASTOS POR CATEGORÍA: las cinco mayores, medidas contra la mayor.
     */
    static func porCategoria(_ l: CNLibreta, _ p: CNCalculo.Periodo) -> [FilaBarra] {
        let todas = CNCalculo.porCategoria(l, p)
        // Contra la MAYOR y no contra el total: contra el total, un mes
        // repartido entre ocho categorías da ocho barritas iguales de nada.
        let mayor = todas.first?.gastado ?? 0
        // Cinco: con doce barras de tres píxeles no se compara nada.
        return todas.prefix(5).map {
            FilaBarra(label: $0.categoria, valor: cnDinero($0.gastado),
                      pct: pct($0.gastado, mayor), categoria: $0.categoria)
        }
    }

    /**
     * INGRESOS Y GASTOS, mes a mes.
     *
     * @param meses  cuántos hacia atrás, contando el actual
     */
    static func tendencia(_ l: CNLibreta, hasta mes: String, meses: Int = 6) -> [Columna] {
        let serie = CNCalculo.porMeses(l, hasta: mes, cuantos: meses)
        // La escala la manda el mes más alto de los dos lados; el 1 evita
        // dividir por cero cuando no hay nada en ninguno.
        let tope = max(1, serie.map { max($0.t.ing, $0.t.gas + $0.t.aho) }.max() ?? 1)
        return serie.map { fila in
            // Nunca por debajo de 3: sin ese suelo, un mes sin movimientos
            // desaparece del gráfico y parece que no existió.
            Columna(label: cnMesCorto(fila.mes),
                    a: max(3, Int((fila.t.ing / tope * 100).rounded())),
                    b: max(3, Int(((fila.t.gas + fila.t.aho) / tope * 100).rounded())))
        }
    }

    /**
     * LA MEZCLA DE GASTOS: fijos, variables y lo apartado.
     *
     * Reparte sobre gastos MÁS ahorro. Lo apartado también salió del mes:
     * dejarlo fuera hincharía los porcentajes de los otros dos.
     */
    static func mezcla(_ l: CNLibreta, _ p: CNCalculo.Periodo, tinte t: Tinte) -> (total: String, trozos: [Trozo]) {
        let x = CNCalculo.totales(l, p)
        let tot = x.gas + x.aho
        let a = pct(x.fij, tot)
        let c = pct(x.vari, tot)
        return (cnDinero(tot), [
            Trozo(label: cnT("Fijos"), valor: cnDinero(x.fij), color: t.franja, desde: 0, hasta: a),
            Trozo(label: cnT("Variables"), valor: cnDinero(x.vari), color: t.negativo, desde: a, hasta: a + c),
            Trozo(label: cnT("Ahorro"), valor: cnDinero(x.aho), color: t.lila, desde: a + c, hasta: 100)
        ])
    }

    /// Los tipos que esto sabe calcular. Lo demás sigue viniendo de la web.
    static let sabeHacer: Set<String> = [
        "barras-categorias", "columnas-tendencia", "dona-mezcla"
    ]
}
