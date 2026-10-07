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
    /// La lista entera, sin formato y sin cortar: cada pantalla corta las que le
    /// caben —cinco en el teléfono, seis en el escritorio—. Va aparte para que el
    /// fichero de oro pueda ejecutarla contra la de la web.
    static func barrasCrudas(_ l: CNLibreta, _ p: CNCalculo.Periodo)
        -> [(categoria: String, gastado: Double, pct: Int)] {
        let todas = CNCalculo.porCategoria(l, p)
        // Contra la MAYOR y no contra el total: contra el total, un mes
        // repartido entre ocho categorías da ocho barritas iguales de nada.
        let mayor = todas.first?.gastado ?? 0
        return todas.map { (categoria: $0.categoria, gastado: $0.gastado,
                            pct: pct($0.gastado, mayor)) }
    }

    static func porCategoria(_ l: CNLibreta, _ p: CNCalculo.Periodo) -> [FilaBarra] {
        // Cinco: con doce barras de tres píxeles no se compara nada.
        barrasCrudas(l, p).prefix(5).map {
            FilaBarra(label: $0.categoria, valor: cnDinero($0.gastado),
                      pct: $0.pct, categoria: $0.categoria)
        }
    }

    /**
     * INGRESOS Y GASTOS, mes a mes.
     *
     * @param meses  cuántos hacia atrás, contando el actual
     */
    /// La misma cuenta sin el rótulo: el mes tal cual y las dos alturas.
    ///
    /// Va aparte porque el fichero de oro la EJECUTA contra la web, y el rótulo
    /// depende del idioma que tenga puesto cada quien.
    struct Tendencia {
        var tope: Double = 1
        var columnas: [(mes: String, ing: Double, gas: Double, a: Int, b: Int)] = []
    }

    static func tendenciaCruda(_ l: CNLibreta, hasta mes: String, meses: Int = 6) -> Tendencia {
        let serie = CNCalculo.porMeses(l, hasta: mes, cuantos: meses)
        // La escala la manda el mes más alto de los dos lados; el 1 evita
        // dividir por cero cuando no hay nada en ninguno.
        let tope = max(1, serie.map { max($0.t.ing, $0.t.gas + $0.t.aho) }.max() ?? 1)
        return Tendencia(tope: tope, columnas: serie.map { fila in
            // Nunca por debajo de 3: sin ese suelo, un mes sin movimientos
            // desaparece del gráfico y parece que no existió.
            (mes: fila.mes, ing: fila.t.ing, gas: fila.t.gas + fila.t.aho,
             a: max(3, Int((fila.t.ing / tope * 100).rounded())),
             b: max(3, Int(((fila.t.gas + fila.t.aho) / tope * 100).rounded())))
        })
    }

    static func tendencia(_ l: CNLibreta, hasta mes: String, meses: Int = 6) -> [Columna] {
        tendenciaCruda(l, hasta: mes, meses: meses)
            .columnas.map { Columna(label: cnMesCorto($0.mes), a: $0.a, b: $0.b) }
    }

    /**
     * LA MEZCLA DE GASTOS: fijos, variables y lo apartado.
     *
     * Reparte sobre gastos MÁS ahorro. Lo apartado también salió del mes:
     * dejarlo fuera hincharía los porcentajes de los otros dos.
     */
    /// El reparto, en números: lo que mide cada trozo de la dona.
    ///
    /// Aparte del formato para que el fichero de oro pueda ejecutarlo contra la
    /// web: lo que no puede cambiar es que reparta sobre gastos MÁS ahorro.
    struct Reparto {
        var total: Double = 0
        var fijos: Double = 0
        var variables: Double = 0
        var ahorro: Double = 0
        var a = 0
        var c = 0
        var hasta = 0
    }

    static func reparto(_ x: CNCalculo.Totales) -> Reparto {
        let tot = x.gas + x.aho
        let a = pct(x.fij, tot), c = pct(x.vari, tot)
        return Reparto(total: tot, fijos: x.fij, variables: x.vari, ahorro: x.aho,
                       a: a, c: c, hasta: a + c)
    }

    static func mezcla(_ l: CNLibreta, _ p: CNCalculo.Periodo, tinte t: Tinte) -> (total: String, trozos: [Trozo]) {
        let x = CNCalculo.totales(l, p)
        let r = reparto(x)
        let tot = r.total, a = r.a, c = r.c
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
    /* ------------------------- presupuesto por categoría ------------------ */

    /**
     * CUÁNTO LLEVAS DE CADA TOPE.
     *
     * Solo las categorías CON presupuesto —las que no tienen no se pueden
     * pasar de nada— y ordenadas por lo lleno que va, no por lo que gastaste:
     * lo que hay que mirar es la que está a punto de reventar, aunque sean
     * cuatrocientos pesos.
     */
    static func porPresupuesto(_ l: CNLibreta, _ p: CNCalculo.Periodo) -> [FilaBarra] {
        let gastado = Dictionary(uniqueKeysWithValues:
            CNCalculo.porCategoria(l, p).map { ($0.categoria, $0.gastado) })
        return l.presupuesto.filter { $0.value > 0 }
            .map { (nombre, tope) -> (FilaBarra, Int) in
                let g = gastado[nombre] ?? 0
                let pct = min(999, Int((g / tope * 100).rounded()))
                return (FilaBarra(label: nombre,
                                  valor: cnDinero(g) + " / " + cnDinero(tope),
                                  pct: min(100, pct), categoria: nombre), pct)
            }
            .sorted { $0.1 > $1.1 }
            .prefix(5)
            .map { $0.0 }
    }

    /* ------------------------- gastos por medio de pago ------------------- */

    /**
     * CON QUÉ PAGASTE.
     *
     * Las barras van contra la MAYOR, no contra el total: con cinco medios, el
     * porcentaje sobre el total deja todas las barras pequeñas y no se compara
     * nada. Y un medio que ya no existe —una cuenta borrada— se cuenta como
     * efectivo, que es lo que hace la web: perder el gasto sería peor.
     */
    static func porMedio(_ l: CNLibreta, _ p: CNCalculo.Periodo) -> [FilaBarra] {
        func nombre(_ medio: String) -> String {
            if medio.isEmpty || medio == "efectivo" { return cnT("Efectivo") }
            let partes = medio.split(separator: ":", maxSplits: 1)
            guard partes.count == 2, let id = Int(partes[1]) else { return cnT("Efectivo") }
            if partes[0] == "tarjeta" {
                return l.tarjetas.first { $0.id == id }?.nombre ?? cnT("Efectivo")
            }
            return l.cuentas.first { $0.id == id }?.nombre ?? cnT("Efectivo")
        }
        var por: [String: Double] = [:]
        for x in l.tx where (x.tipo == "Gasto Fijo" || x.tipo == "Gasto Variable")
            && CNCalculo.enPeriodo(x.fecha, p) {
            por[nombre(x.medio), default: 0] += x.monto
        }
        let orden = por.sorted { $0.value > $1.value }.prefix(5)
        let mayor = max(1, orden.first?.value ?? 1)
        return orden.map { k, v in
            FilaBarra(label: k, valor: cnDinero(v),
                      pct: min(100, Int((v / mayor * 100).rounded())), categoria: "")
        }
    }

}
