import Foundation

/**
 * LA FUSIÓN A TRES, EN NATIVO.
 *
 * Es la primera pieza de la SINCRONIZACIÓN que se muda al teléfono, y es la más
 * peligrosa de toda la app: decide qué se queda y qué se va cuando dos aparatos
 * tocan la misma libreta. Si se equivoca no falla nada —simplemente desaparece
 * un movimiento que alguien acababa de escribir, sin aviso y sin rastro—.
 *
 * Por eso se muda con red debajo: `test/fusion-oro.json` se genera ejecutando la
 * `fusiona` de verdad de `src/nube.js` sobre quince casos, y el banco ejecuta
 * ESTA contra el mismo fichero y compara. No es una copia mirando el original:
 * es una copia que tiene que dar el mismo resultado, caso por caso.
 *
 * POR QUÉ HACE FALTA TRES COPIAS. Dos aparatos con la misma libreta abierta se
 * pisan. El servidor lo nota por número de versión y rechaza el empuje del que
 * iba atrasado; hasta ahí, bien. Lo que no vale es lo que se hacía después:
 * bajar la copia del servidor y seguir, que borra en silencio lo que el usuario
 * acababa de escribir. Con la BASE delante —cómo estaba la libreta la última vez
 * que los dos coincidieron— ya no hay que adivinar quién tiene razón: se
 * distingue lo que cambié yo de lo que cambió el otro.
 *
 * TRABAJA SOBRE JSON, no sobre `CNLibreta`, y es a propósito: la fusión tiene
 * que conservar campos que este teléfono no conozca todavía. Pasándola por un
 * modelo tipado, un campo que la app vieja no sabe leer se perdería al subir —y
 * el aparato con la versión nueva vería desaparecer lo suyo.
 */
enum CNFusion {

    // MARK: - Comparar

    /**
     * ¿Son el mismo valor?
     *
     * La web compara con `JSON.stringify`, que depende del ORDEN de las claves.
     * Aquí se compara la estructura, que es lo que se quiere decir de verdad;
     * los dos coinciden porque las dos copias vienen del mismo servidor. El
     * fichero de oro lo comprueba caso por caso.
     *
     * `nil` y «no está» son lo mismo, como en la web (`a === undefined ? null`).
     */
    static func igual(_ a: Any?, _ b: Any?) -> Bool {
        let x = normal(a), y = normal(b)
        if x == nil && y == nil { return true }
        guard let x, let y else { return false }

        if let da = x as? [String: Any], let db = y as? [String: Any] {
            guard da.count == db.count else { return false }
            for (k, v) in da {
                guard db.keys.contains(k), igual(v, db[k]) else { return false }
            }
            return true
        }
        if let la = x as? [Any], let lb = y as? [Any] {
            guard la.count == lb.count else { return false }
            for (i, v) in la.enumerated() where !igual(v, lb[i]) { return false }
            return true
        }
        if let na = x as? NSNumber, let nb = y as? NSNumber {
            // `true` y `1` NO son lo mismo, aunque `NSNumber` los deje comparar:
            // en JSON son un booleano y un número, y confundirlos haría que un
            // interruptor apagado pareciera sin tocar.
            let boolA = CFGetTypeID(na) == CFBooleanGetTypeID()
            let boolB = CFGetTypeID(nb) == CFBooleanGetTypeID()
            return boolA == boolB && na == nb
        }
        if let sa = x as? String, let sb = y as? String { return sa == sb }
        return false
    }

    /// `NSNull` y `nil` son la misma cosa: «no hay valor».
    private static func normal(_ v: Any?) -> Any? {
        guard let v, !(v is NSNull) else { return nil }
        return v
    }

    // MARK: - Emparejar

    /**
     * La marca por la que se reconoce un mismo registro en dos copias.
     *
     * Los movimientos y las cuentas tienen `id`. Los MIEMBROS no: se emparejan
     * por correo, y sin mirar mayúsculas, porque si no cada fusión duplicaría a
     * la misma persona. Lo que no tiene ni una cosa ni otra se compara entero.
     */
    static func llave(_ x: Any?, _ i: Int) -> String {
        if let d = normal(x) as? [String: Any] {
            if let id = normal(d["id"]) { return "id:" + texto(id) }
            if let email = normal(d["email"]) as? String { return "email:" + email.lowercased() }
            return "val:" + texto(d)
        }
        return "val:" + texto(normal(x)) + ":" + String(i)
    }

    /// Un valor JSON escrito de una sola manera, para poder usarlo de clave.
    private static func texto(_ v: Any?) -> String {
        guard let v = normal(v) else { return "null" }
        if let s = v as? String { return "\"" + s + "\"" }
        if let n = v as? NSNumber {
            if CFGetTypeID(n) == CFBooleanGetTypeID() { return n.boolValue ? "true" : "false" }
            // Sin `.0` de más: en la web un 1 es «1», no «1.0».
            let d = n.doubleValue
            return d == d.rounded() && abs(d) < 1e15 ? String(Int64(d)) : String(d)
        }
        if let l = v as? [Any] { return "[" + l.map { texto($0) }.joined(separator: ",") + "]" }
        if let d = v as? [String: Any] {
            // Por clave ordenada: en Swift un diccionario no tiene orden, y sin
            // ordenarlo el mismo registro daría dos llaves distintas.
            return "{" + d.keys.sorted().map { "\"" + $0 + "\":" + texto(d[$0]) }.joined(separator: ",") + "}"
        }
        return "?"
    }

    // MARK: - Fusionar

    /**
     * Una lista de registros.
     *
     * Lo que yo añadí se queda, lo que yo borré se va, y lo que no toqué lo pone
     * el servidor. Si los dos cambiamos el mismo registro gana el mío, que es lo
     * que el usuario acaba de hacer y tiene delante.
     *
     * **Y EL BORRADO GANA SOBRE LA EDICIÓN**, en los dos sentidos: si yo edité
     * un registro que el otro borró, mi edición se pierde. Es la regla que hay
     * —va escrita porque no se adivina— y el fichero de oro la fija en sus dos
     * casos, para que cambiarla sea una decisión y no un efecto de cómo quedó
     * escrito el bucle.
     *
     * El orden es el del SERVIDOR primero, y detrás lo que yo añadí.
     */
    static func fusionaLista(_ base: Any?, _ mia: Any?, _ suya: Any?) -> Any? {
        guard let listaMia = normal(mia) as? [Any] else { return normal(suya) }
        guard let listaSuya = normal(suya) as? [Any] else { return listaMia }
        let listaBase = (normal(base) as? [Any]) ?? []

        var deBase: [String: Any] = [:]
        for (i, x) in listaBase.enumerated() { deBase[llave(x, i)] = x }
        var deMia: [String: Any] = [:]
        var ordenMia: [String] = []
        for (i, x) in listaMia.enumerated() {
            let k = llave(x, i)
            if deMia[k] == nil { ordenMia.append(k) }
            deMia[k] = x
        }

        var salida: [Any] = []
        var puestas = Set<String>()
        // Primero lo del servidor, en su orden, quitando lo que yo borré.
        for (i, x) in listaSuya.enumerated() {
            let k = llave(x, i)
            if deBase[k] != nil && deMia[k] == nil { continue }      // lo borré yo
            let mio = deMia[k]
            let cambiadoPorMi = mio != nil && !igual(mio, deBase[k])
            salida.append(cambiadoPorMi ? mio! : x)
            puestas.insert(k)
        }
        // Y después lo que yo añadí y el servidor no tiene.
        var deSuya = Set<String>()
        for (i, x) in listaSuya.enumerated() { deSuya.insert(llave(x, i)) }
        for k in ordenMia {
            if puestas.contains(k) { continue }
            if deBase[k] != nil && !deSuya.contains(k) { continue }  // lo borró el otro
            salida.append(deMia[k]!)
        }
        return salida
    }

    /// Igual, pero para un objeto suelto tipo `presupuesto`.
    static func fusionaMapa(_ base: Any?, _ mio: Any?, _ suyo: Any?) -> Any? {
        let b = (normal(base) as? [String: Any]) ?? [:]
        var salida = (normal(suyo) as? [String: Any]) ?? [:]
        let m = (normal(mio) as? [String: Any]) ?? [:]
        var claves = Set(b.keys)
        claves.formUnion(m.keys)
        claves.formUnion(salida.keys)
        for k in claves {
            let mioK = m[k]
            if igual(mioK, b[k]) { continue }                       // no lo toqué yo
            if normal(mioK) == nil { salida.removeValue(forKey: k) } else { salida[k] = mioK }
        }
        return salida
    }

    /**
     * Una libreta entera.
     *
     * Sin base no hay nada que comparar: gana la mía campo a campo, y lo que
     * solo tenga el servidor se conserva.
     */
    static func fusiona(_ base: [String: Any]?, _ mia: [String: Any]?, _ suya: [String: Any]?) -> [String: Any]? {
        guard let suya else { return mia }
        guard let mia else { return suya }
        guard let base else { return suya.merging(mia) { _, dela in dela } }

        var salida = suya
        var claves = Set(base.keys)
        claves.formUnion(mia.keys)
        claves.formUnion(suya.keys)
        for k in claves {
            // La versión y el rol los pone el servidor: fusionarlos haría que el
            // aparato se creyera al día sin estarlo, y su siguiente empuje se
            // rechazaría para siempre.
            if k.hasPrefix("__") { continue }
            let b = base[k], m = mia[k], s = suya[k]
            if normal(m) is [Any] || normal(s) is [Any] {
                salida[k] = fusionaLista(b, m, s)
            } else if let mo = normal(m) as? [String: Any], let so = normal(s) as? [String: Any] {
                salida[k] = fusionaMapa(b, mo, so)
            } else {
                salida[k] = igual(m, b) ? s : m                     // si no lo cambié yo, lo suyo
            }
            if salida[k] == nil { salida.removeValue(forKey: k) }
        }
        return salida
    }
}
