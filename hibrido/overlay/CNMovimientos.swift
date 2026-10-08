import Foundation

/**
 * LA PANTALLA DE MOVIMIENTOS: FILTRAR, BUSCAR Y AGRUPAR POR DÍA.
 *
 * Es la pantalla más usada de la app y la que más reglas pequeñas tiene
 * escondidas. Ninguna de ellas rompe nada al perderse: hacen que la lista salga
 * en otro orden, o que una búsqueda no encuentre algo que está ahí. Cosas que
 * se notan como «la app va rara» y no como un fallo.
 *
 * LAS CUATRO QUE IMPORTAN:
 *
 * **El desempate dentro del mismo día.** Por fecha, y dentro de la misma fecha
 * la ÚLTIMA ANOTADA arriba. Sin ese desempate manda el orden de inserción:
 * anotas tres movimientos hoy y el tercero se queda abajo del grupo, donde no
 * lo buscas. La hora de alta va escondida en los primeros trece dígitos del
 * identificador, que es de donde se saca.
 *
 * **Buscar sin tildes y sin mayúsculas.** Quien escribe «cafe» tiene que
 * encontrar «Café». En un teclado de teléfono la tilde cuesta, y una búsqueda
 * que obliga a ponerla es una búsqueda que no se usa.
 *
 * **La búsqueda mira el concepto Y la categoría.** Escribir «comida» encuentra
 * todo lo de esa categoría aunque ningún concepto diga «comida». Es como se
 * busca de verdad: por dónde fue el dinero, no por cómo se llamó el apunte.
 *
 * **El total de cada día no cuenta las transferencias.** Un traspaso entre
 * cuentas tuyas no entra ni sale: sumarlo haría que un día en que moviste
 * dinero de un sitio a otro apareciera como un día de gasto enorme.
 */
enum CNMovimientos {

    /// Los filtros de la barra, tal como se llaman en la pantalla.
    enum Filtro: String {
        case todos = "Todos"
        case ingresos = "Ingresos"
        case fijos = "Fijos"
        case variables = "Variables"
        case ahorro = "Ahorro"

        /// Qué tipo de movimiento deja pasar cada uno.
        var tipo: String? {
            switch self {
            case .todos: return nil
            case .ingresos: return "Ingreso"
            case .fijos: return "Gasto Fijo"
            case .variables: return "Gasto Variable"
            case .ahorro: return "Ahorro"
            }
        }
    }

    /// Un día con sus movimientos y lo que sumó.
    struct Dia: Identifiable {
        var id: String { fecha }
        var fecha: String
        var label: String
        var total: String
        var positivo: Bool
        var movimientos: [CNMov]
    }

    /**
     * Cuándo se anotó, para desempatar dentro del mismo día.
     *
     * Va escondida en los primeros trece dígitos del identificador, que son los
     * milisegundos del momento en que se creó. Si el identificador no los trae
     * —uno viejo, uno de otra fuente— devuelve 0 y ese movimiento se va abajo:
     * es lo correcto, porque no se sabe cuándo se anotó.
     */
    static func alta(_ m: CNMov) -> Double {
        let soloDigitos = m.id.drop { !$0.isNumber }
        return Double(soloDigitos.prefix(13)) ?? 0
    }

    /// Sin tildes y en minúsculas, para buscar como se escribe de verdad.
    static func normal(_ s: String) -> String {
        s.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "es"))
    }

    /**
     * Los movimientos que se ven: del periodo, del filtro, y que casen con la
     * búsqueda. Ordenados por fecha y, dentro del día, por hora de alta.
     */
    static func visibles(_ l: CNLibreta, periodo p: CNCalculo.Periodo,
                         filtro: Filtro = .todos, buscando: String = "") -> [CNMov] {
        let q = normal(buscando.trimmingCharacters(in: .whitespaces))
        return l.tx
            .filter { CNCalculo.enPeriodo($0.fecha, p) }
            .filter { m in filtro.tipo == nil || m.tipo == filtro.tipo }
            // Concepto Y categoría: se busca por dónde fue el dinero, no por
            // cómo se llamó el apunte.
            .filter { m in q.isEmpty || normal(m.concepto + " " + m.categoria).contains(q) }
            .sorted { a, b in
                // Dentro del mismo día, la última anotada arriba. Sin esto
                // manda el orden de inserción y el tercer apunte del día se
                // queda abajo, donde no lo buscas.
                a.fecha != b.fecha ? a.fecha > b.fecha : alta(a) > alta(b)
            }
    }

    /**
     * LO QUE ENTRÓ Y SALIÓ EN UN DÍA.
     *
     * Una TRANSFERENCIA no cuenta: es un traspaso entre cuentas tuyas, no entra
     * ni sale, y restándola un día en que moviste dinero de un sitio a otro
     * parecía un día de gasto enorme.
     *
     * Aparte de `porDias` porque el fichero de oro ejecuta esta cuenta contra la
     * de la web y las compara.
     */
    static func totalDelDia(_ movs: [CNMov]) -> Double {
        movs.reduce(0.0) { suma, m in
            switch m.tipo {
            case "Transferencia": return suma
            case "Ingreso": return suma + m.monto
            default: return suma - m.monto
            }
        }
    }

    /**
     * Los mismos, agrupados por día, del más nuevo al más viejo.
     *
     * El total de cada día NO cuenta las transferencias: un traspaso entre
     * cuentas tuyas no entra ni sale, y sumarlo haría que un día en que moviste
     * dinero de un sitio a otro pareciera un día de gasto enorme.
     */
    static func porDias(_ movs: [CNMov]) -> [Dia] {
        var mapa: [String: [CNMov]] = [:]
        for m in movs { mapa[m.fecha, default: []].append(m) }
        return mapa.keys.sorted(by: >).map { fecha in
            let delDia = mapa[fecha] ?? []
            let total = totalDelDia(delDia)
            return Dia(fecha: fecha, label: cnDiaCorto(fecha),
                       total: (total >= 0 ? "+" : "−") + cnDinero(total),
                       positivo: total >= 0, movimientos: delDia)
        }
    }
}

/**
 * EL DETALLE DE UN MOVIMIENTO, ARMADO AQUÍ.
 *
 * Era de la web: tocabas una fila y el modelo entero se le pedía a ella. Y
 * como todo lo que pasa por `valsNativo`, solo está armado si la web está EN
 * la pantalla que lo arma; en cualquier otra contestaba vacío y el detalle se
 * quedaba con su barra de navegación y nada debajo.
 *
 * Cada campo se sacó del `detalleMovimiento` de la web, no de memoria. Lo que
 * más fácil se pierde rehaciéndolo:
 *
 *  · **un traspaso no es un gasto.** Ni el icono, ni el color, ni los rótulos:
 *    lleva su flecha doble, la tinta normal —no roja— y dice de dónde sale y a
 *    dónde va en vez de una categoría. Tratarlo como gasto pinta en rojo un
 *    dinero que no se ha ido a ningún sitio;
 *  · **el gris de la categoría sin color es el del TEMA, no el de la paleta.**
 *    La web tiene dos funciones para lo mismo y no dan igual: la lista usa el
 *    verde apagado de la paleta y esta pantalla el gris del tema. Con el otro,
 *    el icono sale verde oscuro sobre una pantalla donde todo lo demás es gris;
 *  · **el tipo se dice corto.** «Gasto Variable» se escribe «Variable»: el
 *    rótulo de al lado ya dice si entró o salió.
 */
extension CNMovimientos {

    /// Los colores que cambian con el tema. Se pasan de fuera para poder armar
    /// el detalle en una prueba sin tema puesto.
    struct TinteDetalle {
        var tinta = ""; var gris = ""; var suave = ""
        var positivo = ""; var negativo = ""
    }

    /// Cómo se llama cada tipo en la ficha. Corto: el rótulo de al lado ya dice
    /// si entró o salió.
    static func nombreDelTipo(_ t: String) -> String {
        switch t {
        case "Ingreso": return cnT("Ingreso")
        case "Gasto Fijo": return cnT("Fijo")
        case "Gasto Variable": return cnT("Variable")
        case "Ahorro": return cnT("Ahorro")
        case "Transferencia": return cnT("Traspaso")
        default: return t
        }
    }

    /// «cuenta:3» → «Banco Popular». Lo que no sea una cuenta o una tarjeta de
    /// la libreta es efectivo, que es de donde sale el dinero cuando no se dice.
    static func nombreDeMedio(_ medio: String, _ l: CNLibreta) -> String {
        if medio.hasPrefix("cuenta:"), let n = Int(medio.dropFirst("cuenta:".count)),
           let c = l.cuentas.first(where: { $0.id == n }) { return c.nombre }
        if medio.hasPrefix("tarjeta:"), let n = Int(medio.dropFirst("tarjeta:".count)),
           let c = l.tarjetas.first(where: { $0.id == n }) { return c.nombre }
        return cnT("Efectivo")
    }

    /// «5 de octubre», en el idioma de la app y con mayúscula inicial.
    static func cuando(_ fecha: String) -> String {
        guard let d = CNFormateadores.iso.date(from: fecha) else { return fecha }
        let f = DateFormatter()
        f.locale = Locale(identifier: CNTextos.idioma)
        f.setLocalizedDateFormatFromTemplate("dMMMM")
        let s = f.string(from: d)
        return s.prefix(1).uppercased() + s.dropFirst()
    }

    /// La flecha doble del traspaso. No es de ninguna categoría: un traspaso no
    /// tiene, y ponerle la de «otros» lo disfraza de gasto.
    static let glifoTraspaso = "M4 9h11a4 4 0 0 1 4 4M20 15H9a4 4 0 0 1-4-4M7 6L4 9l3 3M17 18l3-3-3-3"

    static func detalle(_ id: String, _ l: CNLibreta, puedeRegistrar: Bool,
                        tinte t: TinteDetalle) -> CNMovDetalle? {
        guard let x = l.tx.first(where: { $0.id == id }) else { return nil }
        let traspaso = x.tipo == "Transferencia"
        let entra = x.tipo == "Ingreso"
        var m = CNMovDetalle()
        m.nombre = x.concepto
        m.rotulo = traspaso ? cnT("Traspaso") : entra ? cnT("Entró") : cnT("Salió")
        m.montoFmt = cnDinero(abs(x.monto))
        m.color = traspaso ? t.tinta : entra ? t.positivo : t.negativo
        if traspaso {
            m.iconoPath = glifoTraspaso
            m.iconoColor = t.gris
            m.iconoBg = t.suave
        } else {
            let clave = CNCategorias.icono(x.categoria, en: l)
            m.iconoPath = CNCatalogos.iconos[clave] ?? ""
            // El gris del TEMA, no el de la paleta: son dos funciones distintas
            // en la web y esta pantalla usa esta.
            let cat = l.categorias.first { $0.nombre == x.categoria }
            let color = (cat?.color.isEmpty == false) ? cat!.color : t.gris
            m.iconoColor = color
            m.iconoBg = CNCuentasFilas.tinte(color, 0.15)
        }
        m.puedeEditar = puedeRegistrar
        m.textoEditar = cnT("Editar")
        m.textoDuplicar = cnT("Duplicar")
        var filas: [(String, String)] = []
        if traspaso {
            filas.append((cnT("De dónde sale"), nombreDeMedio(x.medio, l)))
            filas.append((cnT("A dónde va"), nombreDeMedio(x.destino, l)))
        } else {
            filas.append((cnT("Categoría"), x.categoria))
        }
        filas.append((cnT("Tipo"), nombreDelTipo(x.tipo)))
        filas.append((cnT("Fecha"), cuando(x.fecha)))
        if !traspaso { filas.append((cnT("Pagado con"), nombreDeMedio(x.medio, l))) }
        filas.append((cnT("Se repite"), x.recurrente ? cnT("Cada mes") : cnT("No")))
        m.datos = filas.enumerated().map { CNMovDetalle.Dato(id: $0.offset, label: $0.element.0, valor: $0.element.1) }
        return m
    }
}
