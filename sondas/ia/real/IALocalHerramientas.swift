import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

/**
 * LO QUE CHINO PUEDE HACER CUANDO PIENSA DENTRO DEL TELÉFONO.
 *
 * Chino no «escribe» un movimiento: lo ejecuta. Cuando le dices «pagué la luz,
 * 2.300», el modelo no redacta nada — devuelve una llamada con los campos
 * separados, y alguien la ejecuta.
 *
 * Con los modelos de fuera eso vive en el servidor y está escrito una vez para
 * todos, porque todos hablan el mismo idioma de herramientas. El de Apple
 * tiene el suyo, y además quien ejecuta tiene que ser el propio teléfono: con
 * la IA local el servidor no se entera de nada, que es justo la gracia.
 *
 * Así que aquí están otra vez, en Swift. Son las mismas de siempre y hacen lo
 * mismo: acaban llamando a la web, que es la que sabe de libretas, igual que
 * cuando anotas a mano.
 *
 * AVISO SOBRE EL MODELO: el de Apple es pequeño comparado con los de fuera.
 * Con frases sencillas acierta; con frases retorcidas se equivoca más. Por eso
 * lo que no entienda se dice, en vez de inventarse un movimiento: un gasto
 * inventado en las cuentas de alguien es mucho peor que un «no te he
 * entendido».
 */

#if canImport(FoundationModels)
@available(iOS 26.0, *)
struct CNAnotarMovimiento: Tool {
    let name = "registrar_movimiento"
    let description = "Anota un gasto, un ingreso o un ahorro en la libreta de la persona."

    @Generable
    struct Arguments {
        @Guide(description: "Qué fue, en pocas palabras. Por ejemplo: Luz, Supermercado, Sueldo.")
        var concepto: String
        @Guide(description: "Cuánto, en números y sin símbolo de moneda.")
        var monto: Double
        @Guide(description: "Ingreso, Gasto Fijo, Gasto Variable o Ahorro.")
        var tipo: String
        @Guide(description: "La categoría; si no está claro, Otros.")
        var categoria: String
    }

    func call(arguments a: Arguments) async throws -> String {
        // Sin monto no se anota nada: es la clase de dato que un modelo
        // pequeño se inventa con gusto, y un cero en las cuentas de alguien
        // no es un detalle.
        guard a.monto > 0 else { return "No anoté nada: no entendí de cuánto era." }
        let limpio = a.concepto.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !limpio.isEmpty else { return "No anoté nada: no entendí de qué era." }
        let tipos = ["Ingreso", "Gasto Fijo", "Gasto Variable", "Ahorro"]
        let tipo = tipos.first { $0.lowercased() == a.tipo.lowercased() } ?? "Gasto Variable"
        await MainActor.run {
            CNDatos.shared.onCrearMov([
                "concepto": limpio,
                "monto": a.monto,
                "tipo": tipo,
                "categoria": a.categoria.isEmpty ? "Otros" : a.categoria
            ])
        }
        return "Anotado: \(limpio), \(cnDinero(a.monto)), \(tipo.lowercased())."
    }
}

@available(iOS 26.0, *)
struct CNMirarElMes: Tool {
    let name = "mirar_el_mes"
    let description = "Dice cuánto entró, cuánto salió y qué balance hay en el mes que la persona está mirando."

    @Generable
    struct Arguments {
        // Un macro de generación no sabe qué hacer con una estructura vacía,
        // así que lleva una que además sirve: el mes a mirar, si lo dijeron.
        @Guide(description: "El mes en formato 2026-09. Déjalo vacío para el mes que está mirando.")
        var mes: String
    }

    func call(arguments a: Arguments) async throws -> String {
        let l = await MainActor.run { CNDatos.shared.libreta }
        let pedido = a.mes.trimmingCharacters(in: .whitespaces)
        let mes = pedido.count == 7 ? pedido : String(cnHoy().prefix(7))
        let t = CNCalculo.totales(l, CNCalculo.Periodo(mes: mes))
        // `bal` ya viene restado —ingresos menos gastos menos ahorro—, así que
        // no se recalcula aquí: si un día cambia la regla, cambia en un sitio.
        return "Este mes entró \(cnDinero(t.ing)), salió \(cnDinero(t.gas)), "
            + "ahorraste \(cnDinero(t.aho)) y el balance es \(cnDinero(t.bal))."
    }
}

@available(iOS 26.0, *)
struct CNGastosPorCategoria: Tool {
    let name = "gastos_por_categoria"
    let description = "Dice en qué se le va el dinero a la persona este mes, por categorías y de mayor a menor."

    @Generable
    struct Arguments {
        // Un macro de generación no sabe qué hacer con una estructura vacía,
        // así que lleva una que además sirve: el mes a mirar, si lo dijeron.
        @Guide(description: "El mes en formato 2026-09. Déjalo vacío para el mes que está mirando.")
        var mes: String
    }

    func call(arguments a: Arguments) async throws -> String {
        let l = await MainActor.run { CNDatos.shared.libreta }
        let pedido = a.mes.trimmingCharacters(in: .whitespaces)
        let mes = pedido.count == 7 ? pedido : String(cnHoy().prefix(7))
        let filas = CNCalculo.porCategoria(l, CNCalculo.Periodo(mes: mes)).prefix(6)
        guard !filas.isEmpty else { return "Este mes todavía no hay gastos anotados." }
        return filas.map { "\($0.categoria): \(cnDinero($0.gastado))" }.joined(separator: ", ") + "."
    }
}

@available(iOS 26.0, *)
struct CNCuantoTengo: Tool {
    let name = "cuanto_tengo"
    let description = "Dice cuánto dinero tiene la persona en sus cuentas, cuánto debe y su patrimonio."

    @Generable
    struct Arguments {
        // Un macro de generación no sabe qué hacer con una estructura vacía,
        // así que lleva una que además sirve: el mes a mirar, si lo dijeron.
        @Guide(description: "El mes en formato 2026-09. Déjalo vacío para el mes que está mirando.")
        var mes: String
    }

    func call(arguments _: Arguments) async throws -> String {
        let l = await MainActor.run { CNDatos.shared.libreta }
        return "En cuentas tienes \(cnDinero(CNCalculo.saldoCuentas(l))), "
            + "debes \(cnDinero(CNCalculo.deudaTarjetas(l) + CNCalculo.pendientePrestamos(l))) "
            + "y tu patrimonio es \(cnDinero(CNCalculo.patrimonio(l)))."
    }
}
#endif
