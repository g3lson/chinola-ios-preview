import Foundation

/**
 * LA SINCRONIZACIÓN, EN NATIVO.
 *
 * Es la pieza que de verdad ata la app al webview: hoy la libreta la baja, la
 * concilia y la sube `src/nube.js`, y por eso el webview no se puede quitar
 * aunque todas las pantallas sean nativas.
 *
 * Aquí está el mismo ciclo en Swift, con las decisiones que ya se comparan con
 * la web caso por caso —`CNFusion` para conciliar y `CNSincro` para saber qué se
 * sube y qué significa cada rechazo—. Esto es lo que faltaba: el TRANSPORTE.
 *
 * **NO SE ENCIENDE TODAVÍA, Y ESO ES LO IMPORTANTE.**
 *
 * Dos escritores de la misma libreta la corrompen en silencio: el aparato sube
 * una versión, el otro escritor sube otra encima y lo del primero desaparece sin
 * que falle nada. Mientras la web siga sincronizando, esto solo corre en el
 * banco con `CN_SINCRO=1`, contra un servidor de mentira. El día que se encienda
 * hay que apagar la web en el MISMO cambio; no es una opción que se pueda dejar
 * a medias.
 *
 * Lo que sí hace ya: probar el ciclo entero contra el servidor del banco, para
 * que cuando se encienda no sea la primera vez que corre.
 */
enum CNNube {

    /// ¿Toca? Solo en el banco, como el fichero de oro.
    static var pedido: Bool { ProcessInfo.processInfo.environment["CN_SINCRO"] == "1" }

    /// La versión que el servidor aceptó de cada libreta.
    static var versiones: [String: Int] = [:]
    /// Cómo estaba cada libreta la última vez que el aparato y el servidor
    /// coincidieron. Es la BASE de la fusión a tres: sin ella hay que adivinar
    /// quién tiene razón, y adivinar aquí es borrar lo que alguien escribió.
    static var bases: [String: [String: Any]] = [:]

    // MARK: - Bajar

    /**
     * Las libretas del servidor.
     *
     * Bajar todas puede ser cosa de megas —años de movimientos—, así que va con
     * más margen que una llamada corriente.
     */
    static func traer() async throws -> [[String: Any]] {
        let r = try await CNApi.pide("/libretas", espera: 45)
        let libretas = (r["libretas"] as? [[String: Any]]) ?? []
        versiones.removeAll()
        bases.removeAll()
        for l in libretas {
            guard let id = l["id"] as? String else { continue }
            versiones[id] = (l["__version"] as? Int) ?? 1
            bases[id] = l
        }
        return libretas
    }

    // MARK: - Subir

    /// Lo que queda después de subir. Lo mismo que devuelve la web.
    struct Resultado {
        /// Libretas que no caben en el plan.
        var limite: [String] = []
        /// Libretas que de verdad dejaron de ser tuyas.
        var sinPermiso: [String] = []
        /// Las de llave vieja que hubo que renombrar, y con qué llave nueva.
        var renombradas: [(de: String, a: String)] = []
        /// La lista entera ya conciliada, o nil si no hizo falta tocar nada.
        var fusionadas: [[String: Any]]?
        /// Las que ni con la segunda vuelta se pudieron guardar. **Hay que
        /// avisar al usuario: tragárselo en silencio es perder su trabajo.**
        var perdidas: [String] = []
    }

    /**
     * Empuja el estado completo.
     *
     * Si el servidor rechaza alguna libreta por atrasada, se baja la suya, se
     * concilia con la de aquí y se vuelve a subir UNA sola vez. Más vueltas no
     * arreglan nada y pueden no acabar nunca.
     */
    static func empujar(_ libretas: [[String: Any]], segundaVuelta: Bool = false) async throws -> Resultado {
        let carga = CNSincro.queSeSube(libretas, versiones: versiones)
        // `completo` solo en la primera vuelta: con él, el servidor poda las
        // libretas propias que no vayan en el envío. En la segunda va apagado
        // porque esa subida lleva solo las rescatadas, y si dijera que va
        // completa el servidor borraría todas las demás.
        let r = try await CNApi.pide("/libretas", metodo: "PUT",
                                     cuerpo: ["libretas": carga, "completo": !segundaVuelta],
                                     espera: 45)

        for (id, v) in (r["versiones"] as? [String: Any]) ?? [:] {
            versiones[id] = (v as? Int) ?? 0
        }
        // Lo que el servidor aceptó es, a partir de ahora, la base común.
        let aceptadas = (r["versiones"] as? [String: Any]) ?? [:]
        for l in carga {
            if let id = l["id"] as? String, aceptadas[id] != nil { bases[id] = l }
        }

        // Sin `??`: el lado derecho de `??` es un autoclosure y ahí dentro no se
        // puede esperar a nada.
        var quien = (r["yo"] as? String) ?? ""
        if quien.isEmpty { quien = await miCorreo() }
        let c = CNSincro.comoClasificar((r["conflictos"] as? [[String: Any]]) ?? [],
                                        libretas, quien, segundaVuelta: segundaVuelta)

        var porLlave: [String: [String: Any]] = [:]
        for l in libretas { if let id = l["id"] as? String { porLlave[id] = l } }

        // Las de llave vieja que sí son tuyas: llave nueva y otra subida.
        var renombradas: [(de: String, a: String)] = []
        if !c.rescatables.isEmpty {
            var copias: [[String: Any]] = []
            for id in c.rescatables {
                guard var l = porLlave[id] else { continue }
                let nuevo = nuevaLibretaId()
                renombradas.append((de: id, a: nuevo))
                l["id"] = nuevo
                l["__version"] = 0
                copias.append(l)
            }
            _ = try? await empujar(copias, segundaVuelta: true)
            for x in renombradas { versiones.removeValue(forKey: x.de); bases.removeValue(forKey: x.de) }
        }

        if c.desactualizadas.isEmpty || segundaVuelta {
            return Resultado(limite: c.limite, sinPermiso: c.sinPermiso, renombradas: renombradas,
                             fusionadas: nil, perdidas: segundaVuelta ? c.desactualizadas : [])
        }

        // Segunda vuelta: bajar lo del servidor, conciliar y volver a subir.
        let basesPrevias = bases
        let frescas = try await traer()
        var porId: [String: [String: Any]] = [:]
        for l in frescas { if let id = l["id"] as? String { porId[id] = l } }

        var conciliadas: [[String: Any]] = []
        for id in c.desactualizadas {
            if let x = CNFusion.fusiona(basesPrevias[id], porLlave[id], porId[id]) {
                conciliadas.append(x)
            }
        }
        let dos = try await empujar(conciliadas, segundaVuelta: true)
        for l in conciliadas { if let id = l["id"] as? String { porId[id] = l } }

        return Resultado(limite: c.limite + dos.limite,
                         sinPermiso: c.sinPermiso + dos.sinPermiso,
                         renombradas: renombradas,
                         fusionadas: frescas.map { porId[($0["id"] as? String) ?? ""] ?? $0 },
                         perdidas: dos.perdidas)
    }

    /**
     * Mi correo, para saber si soy el dueño de una libreta que el servidor
     * rechaza.
     *
     * El puente solo guarda el vale de sesión, no el correo, así que se pregunta
     * —una vez— y se recuerda. Si no se puede preguntar queda vacío, y entonces
     * `comoClasificar` no rescata nada: es lo correcto, porque renombrar una
     * libreta que no es tuya sería quedársela.
     */
    private static var correoCache = ""
    static func miCorreo() async -> String {
        if !correoCache.isEmpty { return correoCache }
        let r = await CNApi.intenta("/yo")
        let u = (r?["usuario"] as? [String: Any]) ?? [:]
        correoCache = (u["email"] as? String) ?? ""
        return correoCache
    }

    /**
     * La llave con la que nace una libreta.
     *
     * La misma forma que `nuevaLibretaId` en `src/id.js`: `lb-` y un UUID. Al
     * principio era «lb1» —el primero que se le ocurre a cualquiera—, así que la
     * libreta del primero que se registró se quedó con la llave y la de todos
     * los demás chocaba.
     */
    static func nuevaLibretaId() -> String {
        "lb-" + UUID().uuidString.lowercased()
    }

    // MARK: - El banco

    /**
     * Un ciclo entero contra el servidor de mentira del banco.
     *
     * Baja, concilia con lo que hay aquí y sube. Escupe por el log qué pasó,
     * para que la sonda lo mire: que se bajó algo, que lo que se subió llevaba
     * lo de los dos lados, y que la llave vieja se rescató en vez de darse por
     * perdida.
     */
    static func correrEnElBanco() async {
        var salida: [String: Any] = [:]
        do {
            let bajadas = try await traer()
            salida["bajadas"] = bajadas.compactMap { $0["id"] as? String }.sorted()
            salida["versiones"] = versiones.mapValues { $0 }

            // Lo de este aparato: la primera libreta con un movimiento más, y
            // una de llave vieja que el servidor va a rechazar.
            var mias = bajadas
            if !mias.isEmpty {
                var tx = (mias[0]["tx"] as? [[String: Any]]) ?? []
                tx.append(["id": "m-local", "monto": 777, "concepto": "Anotado aquí"])
                mias[0]["tx"] = tx
            }
            mias.append(["id": "lb1", "nombre": "La vieja", "tx": []])

            let r = try await empujar(mias)
            salida["limite"] = r.limite
            salida["sinPermiso"] = r.sinPermiso
            salida["renombradas"] = r.renombradas.map { ["de": $0.de, "a": $0.a] }
            salida["perdidas"] = r.perdidas
            salida["fusionadas"] = (r.fusionadas ?? []).compactMap { $0["id"] as? String }.sorted()
        } catch {
            salida["error"] = String(describing: error)
        }
        if let j = try? JSONSerialization.data(withJSONObject: salida),
           let texto = String(data: j, encoding: .utf8) {
            // Sin caracteres raros, por lo mismo que el fichero de oro: `log
            // show` los escribe con barras y el JSON deja de poder leerse.
            NSLog("CNSINCRO %@", CNOro.soloAscii(texto))
        }
    }
}
