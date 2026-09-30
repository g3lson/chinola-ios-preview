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

    // MARK: - Las hojas de dinero
    //
    // Las cuatro que tocan DOS sitios a la vez —el saldo y el avance— y por eso
    // se pierden al rehacerlas de memoria: el aporte que baja la cuenta pero no
    // sube la meta, o al revés. Son las mismas de `src/dinero.js`, y el fichero
    // de oro ejecuta las dos versiones con los mismos casos.

    /// Lo que sale de una hoja de dinero: la libreta ya tocada y el movimiento
    /// que se anotó, o `nil` si no había nada que hacer.
    struct Hecho {
        var libreta: CNLibreta
        var item: CNMov?
    }

    /// De dónde sale el dinero cuando no se dice: la primera cuenta.
    private static func primerMedio(_ l: CNLibreta) -> String {
        l.cuentas.first.map { "cuenta:\($0.id)" } ?? "efectivo"
    }

    /// Aportar a una meta: sale de la cuenta y sube lo ahorrado.
    ///
    /// El movimiento va marcado con `meta`. Sin esa marca, borrarlo deja el
    /// dinero apuntado en la meta y devuelto en la cuenta: contado dos veces.
    static func aporteAMeta(_ l: CNLibreta, meta: CNMeta, monto: Double,
                            medio: String, texto: String) -> Hecho? {
        let cuanto = max(0, monto)
        guard cuanto > 0 else { return nil }
        var item = CNMov()
        item.id = "ap" + String(Int(Date().timeIntervalSince1970 * 1000))
        item.concepto = texto
        item.categoria = "Ahorro"
        item.tipo = "Ahorro"
        item.monto = cuanto
        item.fecha = CNFormateadores.iso.string(from: Date())
        item.medio = medio.isEmpty ? primerMedio(l) : medio
        item.meta = meta.id

        var nueva = l
        _ = CNCalculo.aplica(&nueva, item, signo: 1)
        nueva.metas = nueva.metas.map { m in
            guard m.id == meta.id else { return m }
            var x = m; x.ahorrado += cuanto; return x
        }
        nueva.tx.append(item)
        return Hecho(libreta: nueva, item: item)
    }

    /// Abonar a un préstamo: sale de la cuenta y sube lo pagado.
    ///
    /// **No se paga más de lo que falta.** Abonar de más dejaría un préstamo
    /// pagado por encima de su total, y de ahí salen porcentajes de más de cien.
    static func abonoAPrestamo(_ l: CNLibreta, prestamo: CNPrestamo, monto: Double,
                               medio: String, texto: String) -> Hecho? {
        let falta = max(0, prestamo.total - prestamo.pagado)
        let cuanto = min(falta, max(0, monto))
        guard cuanto > 0 else { return nil }
        var item = CNMov()
        item.id = "ab" + String(Int(Date().timeIntervalSince1970 * 1000))
        item.concepto = texto
        item.categoria = "Deudas"
        item.tipo = "Gasto Fijo"
        item.monto = cuanto
        item.fecha = CNFormateadores.iso.string(from: Date())
        item.medio = medio.isEmpty ? primerMedio(l) : medio
        item.prestamo = prestamo.id

        var nueva = l
        _ = CNCalculo.aplica(&nueva, item, signo: 1)
        nueva.prestamos = nueva.prestamos.map { p in
            guard p.id == prestamo.id else { return p }
            var x = p; x.pagado = min(p.total, p.pagado + cuanto); return x
        }
        nueva.tx.append(item)
        return Hecho(libreta: nueva, item: item)
    }

    /**
     * Pasar dinero de un sitio a otro.
     *
     * Es UN SOLO apunte, de tipo «Transferencia», que sale de `desde` y entra
     * en `hasta`: ni ingreso ni gasto, así que no toca los totales del mes ni
     * los gastos por categoría. Los dos saldos los mueve `aplica`, que entiende
     * ese tipo —y en una tarjeta va al revés, porque pagarla baja la deuda—.
     *
     * No se pasa dinero al mismo sitio del que sale: sería un apunte que no
     * mueve nada y que además ensucia la lista.
     */
    static func transferencia(_ l: CNLibreta, desde: String, hasta: String,
                              monto: Double, texto: String) -> Hecho? {
        let cuanto = max(0, monto)
        guard cuanto > 0, !hasta.isEmpty, hasta != desde else { return nil }
        var item = CNMov()
        item.id = "tr" + String(Int(Date().timeIntervalSince1970 * 1000))
        item.concepto = texto
        item.categoria = "Otros"
        item.tipo = "Transferencia"
        item.monto = cuanto
        item.fecha = CNFormateadores.iso.string(from: Date())
        item.medio = desde
        item.destino = hasta

        var nueva = l
        _ = CNCalculo.aplica(&nueva, item, signo: 1)
        nueva.tx.append(item)
        return Hecho(libreta: nueva, item: item)
    }

    /// Sumar o restar a lo ahorrado de una meta, sin bajar de cero.
    static func ajusteDeMeta(_ l: CNLibreta, id: Int, delta: Double) -> CNLibreta {
        var nueva = l
        nueva.metas = nueva.metas.map { m in
            guard m.id == id else { return m }
            var x = m; x.ahorrado = max(0, m.ahorrado + delta); return x
        }
        return nueva
    }

    /// Lo mismo con lo pagado de un préstamo, sin pasarse del total.
    static func ajusteDePrestamo(_ l: CNLibreta, id: Int, delta: Double) -> CNLibreta {
        var nueva = l
        nueva.prestamos = nueva.prestamos.map { p in
            guard p.id == id else { return p }
            var x = p; x.pagado = max(0, min(p.total, p.pagado + delta)); return x
        }
        return nueva
    }

    // MARK: - Crear y editar cosas
    //
    // Cuenta, tarjeta, préstamo y meta. Aquí no se mueve dinero —eso lo hacen
    // los movimientos— pero sí se RECORTAN valores, y ahí están las decisiones:
    // un día de corte tiene que caber en un mes, lo pagado no puede pasarse del
    // total, y editar no puede borrar lo que no se tocó.
    //
    // `antes` es el que se está editando; sin él, se crea uno nuevo.

    static func guardarCuenta(_ l: CNLibreta, _ f: [String: Any], antes: Int? = nil) -> CNLibreta {
        let nombre = texto(f["nombre"]).trimmingCharacters(in: .whitespaces)
        guard !nombre.isEmpty else { return l }
        var nueva = l
        var c = antes.flatMap { id in l.cuentas.first { $0.id == id } } ?? CNCuenta()
        c.nombre = nombre
        c.banco = texto(f["banco"]).trimmingCharacters(in: .whitespaces)
        c.saldo = numero(f["saldo"])
        c.clase = texto(f["clase"]).isEmpty ? "banco" : texto(f["clase"])
        c.icono = texto(f["icono"])
        c.color = texto(f["color"])
        if let id = antes {
            nueva.cuentas = nueva.cuentas.map { $0.id == id ? c : $0 }
        } else {
            c.id = nuevoId()
            nueva.cuentas.append(c)
        }
        return nueva
    }

    static func guardarTarjeta(_ l: CNLibreta, _ f: [String: Any], antes: Int? = nil) -> CNLibreta {
        let nombre = texto(f["nombre"]).trimmingCharacters(in: .whitespaces)
        guard !nombre.isEmpty else { return l }
        var nueva = l
        var t = antes.flatMap { id in l.tarjetas.first { $0.id == id } } ?? CNTarjeta()
        t.nombre = nombre
        t.banco = texto(f["banco"]).trimmingCharacters(in: .whitespaces)
        t.limite = max(0, numero(f["limite"]))
        t.saldo = max(0, numero(f["saldo"]))
        // Los días, dentro del mes: un corte el 45 no llega nunca.
        t.corte = min(31, max(1, entero(f["corte"], 20)))
        t.pago = min(31, max(1, entero(f["pago"], 5)))
        t.color = texto(f["color"])
        if let id = antes {
            nueva.tarjetas = nueva.tarjetas.map { $0.id == id ? t : $0 }
        } else {
            t.id = nuevoId()
            nueva.tarjetas.append(t)
        }
        return nueva
    }

    static func guardarPrestamo(_ l: CNLibreta, _ f: [String: Any], antes: Int? = nil) -> CNLibreta {
        let nombre = texto(f["nombre"]).trimmingCharacters(in: .whitespaces)
        guard !nombre.isEmpty else { return l }
        var nueva = l
        var p = antes.flatMap { id in l.prestamos.first { $0.id == id } } ?? CNPrestamo()
        p.nombre = nombre
        p.total = max(0, numero(f["total"]))
        // Lo pagado nunca pasa del total: de ahí salen los «110% pagado».
        p.pagado = min(p.total, max(0, numero(f["pagado"])))
        p.cuota = max(0, numero(f["cuota"]))
        p.dia = min(31, max(1, entero(f["dia"], 1)))
        p.sentido = texto(f["sentido"]) == "meDeben" ? "meDeben" : "debo"
        p.color = texto(f["color"])
        if let id = antes {
            nueva.prestamos = nueva.prestamos.map { $0.id == id ? p : $0 }
        } else {
            p.id = nuevoId()
            nueva.prestamos.append(p)
        }
        return nueva
    }

    static func guardarMeta(_ l: CNLibreta, _ f: [String: Any], antes: Int? = nil) -> CNLibreta {
        let nombre = texto(f["nombre"]).trimmingCharacters(in: .whitespaces)
        guard !nombre.isEmpty else { return l }
        var nueva = l
        var m = antes.flatMap { id in l.metas.first { $0.id == id } } ?? CNMeta()
        m.nombre = nombre
        m.meta = max(0, numero(f["objetivo"]))
        m.mensual = max(0, numero(f["mensual"]))
        m.color = texto(f["color"])
        m.icono = texto(f["icono"]).isEmpty ? "hucha" : texto(f["icono"])
        if let id = antes {
            // Editar NO toca lo ahorrado: es lo que ya metiste, y rehacerlo
            // desde el formulario lo pondría en cero sin decir nada.
            nueva.metas = nueva.metas.map { $0.id == id ? m : $0 }
        } else {
            m.id = nuevoId()
            m.ahorrado = 0
            nueva.metas.append(m)
        }
        return nueva
    }

    /**
     * Guardar una categoría.
     *
     * La que más cosas arrastra, y por eso es la que peor sale rehecha de
     * memoria: **al cambiarle el nombre hay que cambiarlo también en todos sus
     * movimientos y mover su tope de presupuesto**. Sin eso, los movimientos se
     * quedan apuntando a una categoría que ya no existe —salen como «Otros» en
     * el gráfico— y el tope se queda huérfano con el nombre viejo.
     *
     * El tope vive en `presupuesto`, no en la categoría, aunque
     * `CNCategoria.limite` dé a entender lo contrario.
     */
    static func guardarCategoria(_ l: CNLibreta, _ f: [String: Any], antes: Int? = nil) -> CNLibreta {
        let nombre = texto(f["nombre"]).trimmingCharacters(in: .whitespaces)
        guard !nombre.isEmpty else { return l }
        var nueva = l
        let limite = max(0, numero(f["limite"]))

        guard let id = antes, let vieja = l.categorias.first(where: { $0.id == id }) else {
            var c = CNCategoria()
            c.id = nuevoId()
            c.nombre = nombre
            c.color = texto(f["color"])
            c.icono = texto(f["icono"])
            c.ingreso = (f["ingreso"] as? Bool) ?? false
            nueva.categorias.append(c)
            nueva.presupuesto[nombre] = limite
            return nueva
        }

        nueva.categorias = nueva.categorias.map { x in
            guard x.id == id else { return x }
            var c = x
            c.nombre = nombre
            c.color = texto(f["color"])
            c.icono = texto(f["icono"])
            c.ingreso = (f["ingreso"] as? Bool) ?? false
            return c
        }
        if vieja.nombre != nombre {
            // Los movimientos se van con ella, y el tope también.
            nueva.tx = nueva.tx.map { m in
                guard m.categoria == vieja.nombre else { return m }
                var y = m; y.categoria = nombre; return y
            }
            nueva.presupuesto.removeValue(forKey: vieja.nombre)
        }
        nueva.presupuesto[nombre] = limite
        return nueva
    }

    /// El identificador de algo nuevo: los milisegundos, como en la web.
    ///
    /// En el banco sale FIJO, porque el fichero de oro compara la libreta
    /// entera y un identificador sacado del reloj no coincidiría nunca. Es el
    /// mismo truco que el resto del oro: fijar lo que depende del momento para
    /// poder comparar lo que no.
    private static func nuevoId() -> Int {
        CNOro.pedido ? 1 : Int(Date().timeIntervalSince1970 * 1000)
    }

    private static func texto(_ v: Any?) -> String { (v as? String) ?? "" }
    private static func entero(_ v: Any?, _ porDefecto: Int) -> Int {
        if let i = v as? Int { return i }
        if let d = v as? Double { return Int(d) }
        if let s = v as? String, let i = Int(s) { return i }
        return porDefecto
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
