import Foundation

/**
 * ESCRIBIR UN MOVIMIENTO, EN NATIVO.
 *
 * Hasta ahora el teléfono dibujaba el formulario y la web escribía: el nativo
 * mandaba los campos por el puente y era `app.js` quien tocaba la libreta. Es la
 * última atadura gorda —mientras el que escribe sea la web, el webview no se
 * puede quitar— y también la más delicada, porque aquí se mueve el dinero.
 *
 * Por eso se muda con red debajo, como la fusión: `test/calculo-oro.json` trae
 * once casos generados ejecutando la web, y el banco corre ESTO contra los
 * mismos y compara la libreta que sale —los saldos incluidos, no solo la lista
 * de movimientos—.
 *
 * TODO PASA POR `CNCalculo.aplica`, que ya cuadra con la web desde hace tiempo.
 * Lo que se añade aquí es lo de alrededor, que es donde están las tres
 * decisiones que no se adivinan:
 *
 * · Un movimiento sin monto NO se anota. Devolver la libreta tal cual es la
 *   respuesta, no un error.
 * · Al cambiar uno, PRIMERO se deshace el viejo y luego se aplica el nuevo. Si
 *   se cambió de cuenta o de tarjeta, el dinero tiene que salir de donde estaba
 *   antes de entrar donde va.
 * · Y lo que no se dice, no se cambia: editar el monto no puede tocar la fecha.
 */
enum CNEscribir {

    /// Un movimiento nuevo. Devuelve la libreta con él dentro y los saldos ya
    /// movidos, o la misma libreta si no había nada que anotar.
    static func movimientoNuevo(_ l: CNLibreta, _ m: [String: Any]) -> CNLibreta {
        var item = CNMov()
        item.id = (m["id"] as? String) ?? ("m" + String(Int(Date().timeIntervalSince1970 * 1000)))
        item.concepto = (m["concepto"] as? String) ?? "Movimiento"
        item.categoria = (m["categoria"] as? String) ?? "Otros"
        item.tipo = (m["tipo"] as? String) ?? "Gasto Variable"
        item.monto = abs(numero(m["monto"]))
        item.fecha = (m["fecha"] as? String) ?? CNFormateadores.iso.string(from: Date())
        item.recurrente = (m["recurrente"] as? Bool) ?? false
        // Sin medio, la primera cuenta: es donde cae el dinero de quien no elige.
        item.medio = (m["medio"] as? String)
            ?? ("cuenta:" + String(l.cuentas.first?.id ?? 1))
        item.destino = (m["destino"] as? String) ?? ""
        guard item.monto > 0 else { return l }

        var nueva = l
        _ = CNCalculo.aplica(&nueva, item, signo: 1)
        nueva.tx.append(item)
        return nueva
    }

    /// Uno que ya existe. Lo que no venga en `m` se queda como estaba.
    static func movimientoCambiado(_ l: CNLibreta, _ m: [String: Any]) -> CNLibreta {
        guard let id = m["id"] as? String,
              let antes = l.tx.first(where: { $0.id == id }) else { return l }

        // Primero se deshace el viejo: si cambió de cuenta o de tarjeta, el
        // dinero tiene que salir de donde estaba antes de entrar donde va.
        var base = l
        _ = CNCalculo.aplica(&base, antes, signo: -1)

        var item = antes
        if let v = m["concepto"] as? String { item.concepto = v }
        if let v = m["categoria"] as? String { item.categoria = v }
        if let v = m["tipo"] as? String { item.tipo = v }
        if m["monto"] != nil { item.monto = abs(numero(m["monto"])) }
        if let v = m["fecha"] as? String { item.fecha = v }
        if let v = m["recurrente"] as? Bool { item.recurrente = v }
        if let v = m["medio"] as? String { item.medio = v }
        if let v = m["destino"] as? String { item.destino = v }
        guard item.monto > 0 else { return l }

        var nueva = base
        _ = CNCalculo.aplica(&nueva, item, signo: 1)
        nueva.tx = nueva.tx.map { $0.id == item.id ? item : $0 }
        return nueva
    }

    /// Borrar: se deshace lo que hizo y se quita.
    static func movimientoBorrado(_ l: CNLibreta, _ id: String) -> CNLibreta {
        guard let x = l.tx.first(where: { $0.id == id }) else { return l }
        var nueva = l
        _ = CNCalculo.aplica(&nueva, x, signo: -1)
        nueva.tx.removeAll { $0.id == id }
        return nueva
    }

    /// Un número que puede venir como número o como texto.
    private static func numero(_ v: Any?) -> Double {
        if let d = v as? Double { return d }
        if let i = v as? Int { return Double(i) }
        if let n = v as? NSNumber { return n.doubleValue }
        if let s = v as? String { return cnMonto(s) }
        return 0
    }
}
