import Foundation

/**
 * LA SERIE DE TIEMPO: LA TARJETA MÁS COMPLICADA DEL PANEL.
 *
 * Es la única configurable: se elige cuántos meses mirar, qué series pintar
 * —ingresos, gastos, balance, ahorro, neto— y de qué forma —línea, área,
 * puntos o barras—. Todo lo demás del panel enseña una cosa fija.
 *
 * LAS CUATRO REGLAS QUE NO SE ADIVINAN, y que al perderse no rompen nada sino
 * que hacen que el gráfico diga otra cosa:
 *
 * **La escala incluye el cero.** `minV` empieza en 0 y solo baja si alguna
 * serie es negativa. Si la escala se ajustara al mínimo real, tres meses entre
 * 40.000 y 42.000 saldrían como una montaña rusa — y son tres meses casi
 * iguales. Un gráfico que exagera es peor que uno que no dice nada.
 *
 * **Todas las series comparten escala.** Ingresos y gastos se miden con la
 * misma regla, o compararlos deja de tener sentido: es justo lo que se quiere
 * ver al ponerlos juntos.
 *
 * **Con un solo mes, el punto va al centro.** Dividir entre `meses−1` con un
 * mes es dividir por cero; y ponerlo en el borde izquierdo se lee como si
 * hubiera más y no cupieran.
 *
 * **Una barra nunca es más fina que 0,6.** Un mes con valor casi cero dibuja
 * una barra invisible y parece que falta el dato, cuando lo que hay es un cero.
 *
 * Las coordenadas salen en 0…100 de ancho y 0…40 de alto, que es el lienzo en
 * el que dibuja la vista. No son píxeles: la vista las estira a lo que haya.
 */
enum CNSerieTiempo {

    /// El alto del lienzo. El ancho siempre es 100.
    static let ALTO: Double = 40

    /// Qué se puede pintar. Las claves son las mismas que guarda el panel.
    enum Serie: String, CaseIterable {
        case ingresos, gastos, balance, ahorro, neto

        /// De dónde sale el número de esta serie en un mes.
        func valor(_ t: CNCalculo.Totales) -> Double {
            switch self {
            case .ingresos: return t.ing
            case .gastos: return t.gas
            case .balance: return t.bal
            case .ahorro: return t.aho
            // El neto no es el balance: el balance ya descuenta el ahorro, y
            // este descuenta también lo apartado otra vez a propósito — es lo
            // que sobra de verdad después de todo.
            case .neto: return t.ing - t.gas - t.aho
            }
        }
    }

    /// Cómo se dibuja.
    enum Forma: String { case linea, area, puntos, barras }

    struct Punto { var x: Double; var y: Double }
    struct Trazo { var serie: Serie; var puntos: [Punto] }
    struct Barra { var serie: Serie; var x: Double; var y: Double; var w: Double; var h: Double }
    struct Leyenda { var serie: Serie; var etiqueta: String; var ultimo: String }

    struct Dibujo {
        var etiquetas: [String] = []
        var trazos: [Trazo] = []
        var barras: [Barra] = []
        var leyenda: [Leyenda] = []
        /// Cada cuántas etiquetas se escribe una: con doce meses no caben todas.
        var cadaCuantas = 1
    }

    /**
     * El dibujo entero.
     *
     * @param meses  cuántos hacia atrás, contando el actual
     * @param series cuáles pintar; vacío = solo ingresos, como la web
     */
    static func dibujo(_ l: CNLibreta, hasta mes: String, meses n: Int = 12,
                       series: [Serie] = [.ingresos, .gastos], forma: Forma = .linea) -> Dibujo {
        let filas = CNCalculo.porMeses(l, hasta: mes, cuantos: max(1, n))
        guard !filas.isEmpty else { return Dibujo() }
        let activas = series.isEmpty ? [Serie.ingresos] : series

        // LA ESCALA INCLUYE EL CERO, y la comparten todas las series.
        //
        // Empieza en 1 y 0 y solo se estira: si se ajustara al mínimo real,
        // tres meses entre 40.000 y 42.000 saldrían como una montaña rusa. Y
        // compartiéndola, ingresos y gastos se miden con la misma regla, que es
        // justo lo que se quiere ver al ponerlos juntos.
        var maxV: Double = 1
        var minV: Double = 0
        for k in activas {
            for f in filas {
                let v = k.valor(f.t)
                if v > maxV { maxV = v }
                if v < minV { minV = v }
            }
        }
        let rango = (maxV - minV) == 0 ? 1 : (maxV - minV)

        // Con un solo mes el punto va al centro: dividir entre `meses−1` sería
        // dividir por cero, y ponerlo en el borde se lee como si hubiera más y
        // no cupieran.
        let px: (Int) -> Double = { i in filas.count > 1 ? Double(i) * (100 / Double(filas.count - 1)) : 50 }
        let py: (Double) -> Double = { v in 1 + (ALTO - 2) * (1 - ((v - minV) / rango)) }

        var d = Dibujo()
        d.etiquetas = filas.map { cnMesCorto($0.mes) }
        // Con doce meses no caben doce etiquetas: se escribe una de cada
        // tantas, para que nunca haya más de ocho.
        d.cadaCuantas = max(1, Int(ceil(Double(filas.count) / 8)))

        for (si, k) in activas.enumerated() {
            d.leyenda.append(Leyenda(serie: k, etiqueta: cnT(k.rawValue.capitalized),
                                     ultimo: cnDinero(k.valor(filas[filas.count - 1].t))))
            switch forma {
            case .linea, .area, .puntos:
                d.trazos.append(Trazo(serie: k, puntos: filas.enumerated().map {
                    Punto(x: px($0.offset), y: py(k.valor($0.element.t)))
                }))
            case .barras:
                // Con varias series, cada una ocupa su parte del hueco del mes
                // y van una al lado de otra. Con una sola, la barra es ancha.
                let paso = 100 / Double(filas.count)
                let ancho = activas.count > 1 ? (paso * 0.62) / Double(activas.count) : paso * 0.62
                for (i, f) in filas.enumerated() {
                    let v = k.valor(f.t)
                    let y0 = py(max(0, minV)), y1 = py(v)
                    let x = Double(i) * paso + paso * 0.19 + (activas.count > 1 ? Double(si) * ancho : 0)
                    // Nunca más fina que 0,6: un mes en cero dibujaría una
                    // barra invisible y parecería que falta el dato.
                    d.barras.append(Barra(serie: k, x: x, y: min(y0, y1), w: ancho,
                                          h: max(0.6, abs(y0 - y1))))
                }
            }
        }
        return d
    }
}
