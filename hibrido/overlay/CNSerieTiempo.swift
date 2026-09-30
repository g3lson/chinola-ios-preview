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
        case ingresos, gastos, balance, ahorro, patrimonio

        /// De dónde sale el número de esta serie en un mes.
        func valor(_ t: CNCalculo.Totales) -> Double {
            switch self {
            case .ingresos: return t.ing
            case .gastos: return t.gas
            case .balance: return t.bal
            case .ahorro: return t.aho
            // El patrimonio de ESTA tarjeta no es el de la tarjeta de cifra:
            // aquí es lo que sobró en el mes —ingresos menos gastos menos lo
            // apartado—, no activos menos pasivos. Se llaman igual en la web y
            // son dos cosas distintas; «arreglarlo» aquí para que cuadren haría
            // que la línea dijera algo que su leyenda no dice.
            case .patrimonio: return t.ing - t.gas - t.aho
            }
        }
    }

    /**
     * Cómo se dibuja.
     *
     * `barras` y `columnas` son las dos de barra y NO son lo mismo: en `barras`
     * todas las series comparten el hueco del mes —una barra ancha, unas sobre
     * otras—, y en `columnas` el hueco se reparte y van una al lado de otra.
     * Confundirlas no rompe nada: hace que el gráfico que alguien eligió salga
     * siendo el otro.
     */
    enum Forma: String { case linea, area, puntos, barras, columnas }

    struct Punto { var x: Double; var y: Double }
    struct Trazo { var serie: Serie; var puntos: [Punto] }
    struct Barra { var serie: Serie; var x: Double; var y: Double; var w: Double; var h: Double }
    /// `ultimo` es el último valor ya escrito; `valor`, el mismo número sin
    /// formato, para poder compararlo con el de la web.
    struct Leyenda { var serie: Serie; var etiqueta: String; var ultimo: String; var valor: Double = 0 }

    struct Dibujo {
        var etiquetas: [String] = []
        var trazos: [Trazo] = []
        /// El mismo trazo cerrado por abajo, para poder rellenarlo. Solo `area`.
        var areas: [Trazo] = []
        var barras: [Barra] = []
        var leyenda: [Leyenda] = []
        /// Cada cuántas etiquetas se escribe una: con doce meses no caben todas.
        var cadaCuantas = 1
        /// Los meses dibujados, sin rótulo: «2026-09». Para poder comparar.
        var meses: [String] = []
        /// La escala que comparten todas las series. Incluye el cero.
        var minV: Double = 0
        var maxV: Double = 1
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
        d.meses = filas.map { $0.mes }
        d.minV = minV
        d.maxV = maxV
        // Con doce meses no caben doce etiquetas: se escribe una de cada
        // tantas, para que nunca haya más de ocho.
        d.cadaCuantas = max(1, Int(ceil(Double(filas.count) / 8)))
        // Las que no se escriben van EN BLANCO, no se quitan: quitándolas, las
        // que quedan se reparten el ancho entero y dejan de caer debajo de su
        // mes.
        //
        // Y la cuenta va DESDE EL FINAL, que es lo que hace la app. Contando
        // desde el principio, con doce meses y una de cada dos, la última —el
        // mes en el que estás, que es el que se mira— se queda sin escribir o
        // hay que escribirla aparte, pegada a la anterior.
        //
        // Lleva el año de dos cifras: con veinticuatro meses hay dos
        // septiembres y sin el año son la misma etiqueta dos veces.
        d.etiquetas = filas.enumerated().map { i, f in
            (filas.count - 1 - i) % d.cadaCuantas == 0
                ? cnMesCorto(f.mes) + " " + String(f.mes.prefix(4).suffix(2)) : ""
        }

        for (si, k) in activas.enumerated() {
            d.leyenda.append(Leyenda(serie: k, etiqueta: cnT(k.rawValue.capitalized),
                                     // Con signo: balance y patrimonio pueden ser negativos, y la
            // leyenda dice el último valor de la línea. Sin él, una línea
            // dibujada por debajo del cero venía rotulada en positivo.
            ultimo: cnDineroFirmado(k.valor(filas[filas.count - 1].t)),
                                     valor: k.valor(filas[filas.count - 1].t)))
            switch forma {
            case .linea, .area, .puntos:
                let puntos = filas.enumerated().map {
                    Punto(x: px($0.offset), y: py(k.valor($0.element.t)))
                }
                d.trazos.append(Trazo(serie: k, puntos: puntos))
                // El área lleva su línea ENCIMA, y se cierra bajando a la base
                // por los dos lados. Sin cerrarla, el relleno sale por donde
                // quiera; sin la línea, el borde de arriba se pierde dentro del
                // relleno y deja de poder seguirse con la vista.
                if forma == .area {
                    d.areas.append(Trazo(serie: k, puntos:
                        [Punto(x: 0, y: ALTO)] + puntos + [Punto(x: 100, y: ALTO)]))
                }
            case .barras, .columnas:
                // En `barras` todas las series comparten el hueco del mes; en
                // `columnas` el hueco se reparte y van una al lado de otra.
                let paso = 100 / Double(filas.count)
                let ancho = forma == .barras ? paso * 0.62 : (paso * 0.62) / Double(activas.count)
                for (i, f) in filas.enumerated() {
                    let v = k.valor(f.t)
                    let y0 = py(max(0, minV)), y1 = py(v)
                    let x = Double(i) * paso + paso * 0.19
                          + (forma == .barras ? 0 : Double(si) * ancho)
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
