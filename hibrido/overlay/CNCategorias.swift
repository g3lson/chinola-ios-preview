import Foundation

/**
 * QUÉ ICONO Y QUÉ COLOR LE TOCA A CADA CATEGORÍA.
 *
 * Es el hueco que quedaba de las tarjetas: el gráfico de categorías y la lista
 * de movimientos enseñan un iconito por cada una, y esa correspondencia vivía
 * solo en la web. Sin ella, todas las categorías saldrían con el mismo punto
 * gris — la pantalla funcionaría igual y se leería mucho peor, que es la clase
 * de pérdida que este trabajo busca evitar.
 *
 * TRES NIVELES, Y EL ORDEN IMPORTA:
 *
 * 1. **Lo que la persona eligió.** Si la categoría tiene su icono puesto, ese.
 *    Manda siempre: alguien entró a elegirlo.
 * 2. **Lo que le toca por nombre**, para las trece de fábrica. Es lo que hace
 *    que una libreta recién creada ya salga con sus iconos sin que nadie los
 *    haya tocado.
 * 3. **El de por defecto.** Una categoría inventada por alguien —«Perro»,
 *    «Moto»— no tiene por qué adivinarse, y adivinar mal es peor que no
 *    adivinar: un icono equivocado confunde más que uno neutro.
 *
 * Con el color pasa lo mismo, con dos niveles: el suyo si lo tiene, y si no el
 * último de la paleta, que es el gris apagado — a propósito, para que las
 * categorías sin color no compitan con las que sí lo tienen.
 */
enum CNCategorias {

    /**
     * El icono de cada una de las trece de fábrica.
     *
     * GENERADO: sale de `CAT_ICONO` de la web por `npm run sync`. Estaba escrito
     * a mano aquí, trece entradas, y es exactamente lo que le pasó a los ochenta
     * y cinco glifos: uno se desvió —`banco` dibujaba una casa en el teléfono y
     * un banco en la web— y eso no se encuentra buscándolo.
     */
    static let porNombre: [String: String] = CNCatalogos.iconoPorCategoria

    /// El que se usa cuando no hay nada mejor.
    static let POR_DEFECTO = "puntos"

    /**
     * El gris apagado de la paleta, para las categorías sin color propio.
     *
     * Es el último de los siete a propósito: apagado, para que las que no
     * tienen color no compitan con las que sí.
     */
    static let COLOR_POR_DEFECTO = "oklch(0.32 0.03 155)"

    /// El icono que le toca a una categoría, por su nombre.
    static func icono(_ nombre: String, en l: CNLibreta) -> String {
        // Lo que la persona eligió manda: alguien entró a ponerlo.
        if let c = l.categorias.first(where: { $0.nombre == nombre }), !c.icono.isEmpty {
            return c.icono
        }
        // Y si no, lo que le toca por nombre. Una categoría inventada cae en el
        // de por defecto: adivinar mal confunde más que no adivinar.
        return porNombre[nombre] ?? POR_DEFECTO
    }

    /// El color que le toca a una categoría.
    static func color(_ nombre: String, en l: CNLibreta) -> String {
        guard let c = l.categorias.first(where: { $0.nombre == nombre }), !c.color.isEmpty else {
            return COLOR_POR_DEFECTO
        }
        return c.color
    }

    /**
     * La inicial que se enseña cuando no hay icono que valga.
     *
     * DOS letras, no una: la primera de las dos primeras palabras. Es lo que
     * hace la web (`ini`), y aquí era una sola, así que la misma categoría
     * —«Gastos Personales»— salía «GP» en la web y «G» en el teléfono, en la
     * misma app. La burbuja es pequeña y dos letras distinguen lo que una no:
     * con «Comida» y «Casa» delante, una «C» sola no dice cuál es.
     *
     * Y con las categorías vacías —que existen, se pueden crear sin nombre—
     * devuelve «?», también como la web: una burbuja en blanco se ve como un
     * fallo de carga.
     */
    static func inicial(_ nombre: String) -> String {
        let palabras = nombre.split(whereSeparator: { $0.isWhitespace })
        let primera = palabras.first.map { String($0.prefix(1)) } ?? "?"
        let segunda = palabras.count > 1 ? String(palabras[1].prefix(1)) : ""
        return (primera + segunda).uppercased()
    }
}
