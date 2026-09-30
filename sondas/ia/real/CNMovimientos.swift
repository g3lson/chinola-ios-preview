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
            let total = delDia.reduce(0.0) { suma, m in
                switch m.tipo {
                case "Transferencia": return suma
                case "Ingreso": return suma + m.monto
                default: return suma - m.monto
                }
            }
            return Dia(fecha: fecha, label: cnDiaCorto(fecha),
                       total: (total >= 0 ? "+" : "−") + cnDinero(total),
                       positivo: total >= 0, movimientos: delDia)
        }
    }
}
