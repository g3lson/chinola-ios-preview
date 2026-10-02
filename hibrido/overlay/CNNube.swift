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

    /// Lo que puede salir mal aquí y no en `CNApi`.
    enum Fallo: Error {
        /// Se iba a subir una lista vacía teniendo libretas que subir: algo se
        /// leyó mal, y subirla borraría las del servidor.
        case nadaQueSubir
    }

    /// ¿Toca correr el ciclo de prueba del banco?
    static var pedido: Bool { ProcessInfo.processInfo.environment["CN_SINCRO"] == "1" }

    /**
     * ¿SINCRONIZA EL TELÉFONO?
     *
     * El interruptor que decide quién habla con el servidor. Mientras esté en
     * `false`, lo hace la web exactamente como siempre; en `true`, la web deja
     * de hablar con el servidor y se lo pide aquí.
     *
     * No puede estar encendido en los dos sitios a la vez: dos escritores de la
     * misma libreta la corrompen en silencio —uno sube su versión, el otro sube
     * la suya encima y lo del primero desaparece sin que falle nada—. Por eso el
     * interruptor es UNO y lo lee la web (`Nativo.nubeManda`), en vez de haber
     * uno en cada lado que se puedan contradecir.
     *
     * Y aunque esté encendido, hacen falta las dos cosas de `CNAlmacen`: la
     * copia con libretas y el vale. Sin alguna, el teléfono NO toma el mando y
     * lo sigue haciendo la web. Fallar hacia el camino que ya funciona.
     */
    static var encendido = false
    static var elTelefonoManda: Bool { encendido && CNAlmacen.listoParaSincronizar() }

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
        // Ni siquiera se intenta con la lista vacía cuando el que llama creía
        // tener libretas: `completo` haría que el servidor podara las de la
        // cuenta. Que no quede nada que subir es normal —todas de lectura, todas
        // pendientes de aceptar— y entonces tampoco hay nada que podar, porque
        // el servidor solo poda las PROPIAS; pero si el que llama traía libretas
        // y no queda ninguna, algo se leyó mal y es mejor no tocar nada.
        let carga = CNSincro.queSeSube(libretas, versiones: versiones)
        if carga.isEmpty && !libretas.isEmpty && libretas.contains(where: { l in
            (l["__rol"] as? String) != "Lector" && (l["__estado"] as? String) != "pendiente"
        }) {
            throw Fallo.nadaQueSubir
        }
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

            // LO DE ESTE APARATO SALE DE LA COPIA, que es de donde saldrá de
            // verdad: la web la deja escrita en el teléfono cada dos segundos.
            // Si no hay copia —la web aún no ha guardado— se sigue con lo
            // bajado, y queda dicho en el log para no confundir las dos cosas.
            let deLaCopia = CNAlmacen.listoParaSincronizar()
            salida["deLaCopia"] = deLaCopia
            salida["enLaCopia"] = CNAlmacen.libretas().compactMap { $0["id"] as? String }.sorted()
            var mias = deLaCopia ? CNAlmacen.libretas() : bajadas
            // `lb-uno` ES EL CASO QUE SE VIENE A PROBAR: la libreta que el
            // servidor rechaza por atrasada, o sea los dos aparatos tocando la
            // misma. Es lo único que obliga a bajar, conciliar y volver a
            // subir.
            //
            // Y cuando lo de este aparato sale de la COPIA —y sale en cuanto la
            // web ha guardado una vez— esa libreta no está: la copia tiene las
            // de verdad. Entonces no se subía, el servidor no rechazaba nada, y
            // la sonda decía «no concilió» sin que la app tuviera nada roto.
            // Se trae de lo bajado para que el caso se pruebe SIEMPRE, con
            // copia o sin ella.
            if !mias.contains(where: { ($0["id"] as? String) == "lb-uno" }),
               let deAlla = bajadas.first(where: { ($0["id"] as? String) == "lb-uno" }) {
                mias.append(deAlla)
            }
            // Un movimiento anotado aquí, para ver si sobrevive a la
            // conciliación, y una libreta de llave vieja que el servidor va a
            // rechazar por no ser suya.
            if let i = mias.firstIndex(where: { ($0["id"] as? String) == "lb-uno" }) {
                var tx = (mias[i]["tx"] as? [[String: Any]]) ?? []
                tx.append(["id": "m-local", "monto": 777, "concepto": "Anotado aquí"])
                mias[i]["tx"] = tx
            }
            mias.append(["id": "lb1", "nombre": "La vieja", "tx": []])

            let r = try await empujar(mias)
            salida["limite"] = r.limite
            salida["sinPermiso"] = r.sinPermiso
            salida["renombradas"] = r.renombradas.map { ["de": $0.de, "a": $0.a] }
            salida["perdidas"] = r.perdidas
            salida["fusionadas"] = (r.fusionadas ?? []).compactMap { $0["id"] as? String }.sorted()
            // Y QUÉ MOVIMIENTOS quedaron en la libreta que hubo que conciliar.
            // Sin esto la sonda solo podía decir que el ciclo terminó, no que
            // conservara lo de los dos aparatos —que es lo único que importa—.
            var dentro: [String: [String]] = [:]
            for l in r.fusionadas ?? [] {
                guard let id = l["id"] as? String else { continue }
                dentro[id] = ((l["tx"] as? [[String: Any]]) ?? []).compactMap { $0["id"] as? String }.sorted()
            }
            salida["movimientos"] = dentro
        } catch {
            salida["error"] = String(describing: error)
        }
        // En base64, por lo mismo que el fichero de oro: `log show` reescribe
        // los caracteres raros Y las barras invertidas, así que escaparlos no
        // sirve —escapa el escape—. En base64 no hay ninguno de los dos.
        if let j = try? JSONSerialization.data(withJSONObject: salida) {
            NSLog("CNSINCRO %@", j.base64EncodedString())
        }
    }
}
