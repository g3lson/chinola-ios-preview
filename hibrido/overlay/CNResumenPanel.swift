import Foundation

/**
 * EL ESQUELETO DEL PANEL, ARMADO AQUÍ.
 *
 * El contenido de las tarjetas ya se calculaba en el teléfono —`refrescarCifras`
 * rehace las trece que saben los módulos en cuanto cambia un número—. Lo que
 * seguía viniendo de la web era el ESQUELETO: qué tarjetas hay, en qué orden,
 * con qué título y de qué forma.
 *
 * Y la web solo arma el modelo de la pestaña en la que está. Parada en otra,
 * contesta con la cabecera y CERO tarjetas; y como `refrescarCifras` empieza
 * con `guard resumen != nil`, no había dónde escribir los números ya
 * calculados. El Resumen se quedaba con la cabecera y nada debajo.
 *
 * De dónde sale cada cosa:
 *
 *  · **el orden y el ancho**, del panel de la libreta —que ahora sí se lee— o
 *    del de fábrica si la libreta no trae ninguno, igual que hace la web;
 *  · **el título, la forma y el pie**, de `CNCatalogos.tarjetasDePanel`, que
 *    genera `npm run sync` leyendo lo que la web DIBUJA para cada uno de los
 *    treinta y dos tipos. No se dedujeron: el título de `columnas-tendencia`
 *    es «Ingresos y gastos» y en el catálogo de «organizar» se llama
 *    «Tendencia 6 meses». Deducirlo habría salido mal y nadie lo habría visto.
 *
 * LO QUE NO SE INVENTA: las tarjetas que alguien ESCONDE. Esa lista no vive en
 * la libreta —vive en el aparato, a propósito, para que una tarjeta pueda
 * estar oculta en el teléfono y visible en la web sin pisarse—. Así que aquí
 * no se adivina: se recuerda la que la web haya dicho, y se vuelve a aplicar.
 * Inventarla sería hacer reaparecer lo que alguien escondió.
 */
enum CNResumenPanel {

    // MARK: - Las que están escondidas

    private static let llaveOcultas = "cnPanelOcultas"

    /// Lo que la web dijo la última vez sobre qué tarjetas están escondidas.
    /// Se guarda por libreta, que es como lo guarda ella.
    static func ocultas(libreta: String) -> Set<String> {
        let t = UserDefaults.standard.dictionary(forKey: llaveOcultas) as? [String: [String]] ?? [:]
        return Set(t[libreta] ?? [])
    }

    /// Se apunta cuando llega un modelo COMPLETO de la web: el que viene a
    /// medias no sabe de ocultas y apuntarlo las resucitaría todas.
    static func apunta(ocultas lista: Set<String>, libreta: String) {
        var t = UserDefaults.standard.dictionary(forKey: llaveOcultas) as? [String: [String]] ?? [:]
        t[libreta] = Array(lista).sorted()
        UserDefaults.standard.set(t, forKey: llaveOcultas)
    }

    // MARK: - El esqueleto

    /// Las entradas del panel: las de la libreta o, si no trae, las de fábrica.
    static func entradas(_ l: CNLibreta) -> [CNEntradaPanel] {
        if !l.panel.isEmpty { return l.panel }
        return CNCatalogos.panelDeFabrica.map { f in
            var e = CNEntradaPanel()
            e.id = f.id; e.tipo = f.tipo; e.ancho = f.ancho
            // La única de fábrica con ajustes es la serie de tiempo, y son los
            // mismos que escribe la web al crear la libreta.
            if f.tipo == "serie-tiempo" {
                e.grafico = "linea"; e.rango = 12; e.series = ["ingresos", "gastos"]
            }
            return e
        }
    }

    /**
     * El esqueleto entero, listo para que `refrescarCifras` le meta los
     * números. De cada tarjeta se deja puesto lo que no depende de los datos:
     * dónde va, cómo se titula y de qué forma es.
     */
    static func widgets(_ l: CNLibreta, ocultas escondidas: Set<String>,
                        positivo: String = "", negativo: String = "") -> [CNResumenModelo.Widget] {
        entradas(l).enumerated().map { i, e in
            var w = CNResumenModelo.Widget()
            w.indice = i
            w.wid = e.id
            w.tipoPanel = e.tipo
            w.ancho = e.ancho
            w.oculta = escondidas.contains(e.id)
            let t = CNCatalogos.tarjetasDePanel[e.tipo]
            if let t = t {
                w.titulo = cnT(t.titulo)
                w.periodo = t.periodo.isEmpty ? "" : cnT(t.periodo)
                w.clase = t.clase
                w.puedeChica = t.puedeChica
            } else {
                // Un tipo que este teléfono no conoce todavía: se deja sin
                // forma y la vista no lo dibuja. Mejor que inventarle una.
                w.clase = "texto"
            }
            // A media anchura solo las que caben: una gráfica con meses debajo
            // no. La web decide lo mismo con `puedeChica`.
            w.chica = w.puedeChica && e.ancho <= 1
            w.vistas = vistas(e)
            // LO QUE CADA FORMA NECESITA ADEMÁS DEL CONTENIDO.
            //
            // La de columnas lleva su leyenda y los colores de las dos barras:
            // sin ellos la tarjeta sale con su título y el recuadro VACÍO, que
            // es lo que pasó la primera vez que se quitó la puerta. Y la de
            // barras, el rótulo del botón que lleva al presupuesto.
            if t?.clase == "columnas" {
                w.rotuloEntra = cnT("Ingresos")
                w.rotuloSale = cnT("Gastos")
                w.entraColor = positivo
                w.saleColor = negativo
            }
            if e.tipo == "barras-categorias" {
                w.rotuloPresupuesto = cnT("Ver el presupuesto")
                w.vaAlPresupuesto = true
            }
            if e.tipo == "serie-tiempo" {
                w.cfgGrafico = e.grafico.isEmpty ? "linea" : e.grafico
                w.cfgRango = String(e.rango > 0 ? e.rango : 12)
            }
            return w
        }
    }
    /**
     * CÓMO SE PUEDE VER CADA TARJETA.
     *
     * La misma cifra contada de otra manera: los gastos por categoría en
     * barras, en dona o en lista; los movimientos de cinco en cinco o de tres.
     * La PRIMERA de cada lista es la de fábrica, así que una tarjeta que ya
     * existe se queda exactamente como estaba.
     *
     * Son tres y dos, no diez: «Últimos movimientos» la calcula el teléfono
     * con su propio tope de cinco, así que ofrecer más obligaría a tocar los
     * dos lados y a cuadrarlos. Recortar vale con uno.
     */
    static let vistasDe: [String: [(id: String, label: String)]] = [
        "barras-categorias": [("barras", "Barras"), ("dona", "Dona"), ("lista", "Lista")],
        "lista-recientes": [("5", "5 movimientos"), ("3", "3 movimientos")]
    ]

    /// Cuál está puesta en esta tarjeta: la suya, o la primera de su lista.
    static func vistaDe(_ e: CNEntradaPanel) -> String {
        guard let v = vistasDe[e.tipo], let primera = v.first else { return "" }
        return e.vista.isEmpty ? primera.id : e.vista
    }

    static func vistas(_ e: CNEntradaPanel) -> [CNResumenModelo.SerieCfg] {
        guard let v = vistasDe[e.tipo] else { return [] }
        let puesta = vistaDe(e)
        return v.map { CNResumenModelo.SerieCfg(id: $0.id, label: cnT($0.label),
                                                color: "", puesta: $0.id == puesta) }
    }

}
