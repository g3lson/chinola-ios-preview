import Foundation

/**
 * LAS DOS DECISIONES DEL EMPUJE, en nativo.
 *
 * Subir la libreta al servidor son dos cosas muy distintas: el TRANSPORTE —una
 * petición HTTP— y las DECISIONES. Esto es lo segundo, y va aparte por lo mismo
 * que la fusión: es lo que se puede ejecutar contra la web y comparar número a
 * número. `test/fusion-oro.json` trae los casos y el banco corre los dos lados.
 *
 * Las dos han costado ya un fallo de los que borran datos:
 *
 * · **Qué se sube.** Una libreta en la que solo puedes leer no se sube: el
 *   servidor la rechaza por «sin permiso», que es la misma respuesta que da
 *   cuando de verdad te han sacado de una libreta, y el aparato se creía lo
 *   segundo. A quien lo invitaban como Lector le desaparecía la libreta
 *   compartida en la primera subida, con un aviso diciendo que le habían quitado
 *   el acceso.
 *
 * · **Qué significa un rechazo.** Detrás de «sin permiso» hay dos cosas: que te
 *   sacaron de una libreta, o el choque de llaves de las libretas viejas —las
 *   que nacieron llamándose «lb1», igual que las de todo el mundo—. La segunda
 *   es tuya y hay que renombrarla; se veía como una libreta que no dejaba
 *   escribir.
 */
enum CNSincro {

    /// ¿Es una de las llaves cortas de antes? `lb1`, `lb2`, `lb3`…
    ///
    /// La misma que `esIdViejo` en `src/id.js`. Sirve para saber si una libreta
    /// que el servidor rechaza es de las que chocaban por nacer con el mismo
    /// nombre que las de todo el mundo, o si de verdad dejó de ser tuya.
    static func esIdViejo(_ id: String) -> Bool {
        guard id.hasPrefix("lb") else { return false }
        let resto = id.dropFirst(2)
        return (1...3).contains(resto.count) && resto.allSatisfy { $0.isASCII && $0.isNumber }
    }

    /**
     * Qué libretas se suben, y con qué número de versión.
     *
     * Fuera las de solo lectura y las invitaciones sin aceptar: el servidor
     * rechaza las dos y, hasta aceptar, la libreta no es tuya para subirla.
     * Dejarlas fuera tampoco las borra — el servidor solo poda las propias.
     *
     * La versión es la que el aparato tenga apuntada del servidor; si no hay,
     * la que traiga la libreta; y si tampoco, cero: nueva para el servidor.
     */
    static func queSeSube(_ libretas: [[String: Any]],
                          versiones: [String: Int]) -> [[String: Any]] {
        libretas.filter { l in
            (l["__rol"] as? String) != "Lector" && (l["__estado"] as? String) != "pendiente"
        }.map { l in
            var copia = l
            let id = (l["id"] as? String) ?? ""
            let suya = versiones[id] ?? 0
            let propia = (l["__version"] as? Int) ?? 0
            // El `||` de la web: el primero que no sea cero.
            copia["__version"] = suya != 0 ? suya : propia
            return copia
        }
    }

    /// Lo que sale de mirar los rechazos del servidor.
    struct Rechazos {
        var desactualizadas: [String] = []
        var limite: [String] = []
        var ajenas: [String] = []
        var rescatables: [String] = []
        var sinPermiso: [String] = []
    }

    /**
     * Qué significa cada rechazo.
     *
     * `rescatables` son las libretas que el servidor dice que no son tuyas pero
     * sí lo son: llave de las cortas y tú figurando como dueño. Se renombran y
     * se vuelven a subir. En la segunda vuelta no se rescata ninguna: ya se
     * intentó una vez y repetirlo sería un bucle.
     */
    static func comoClasificar(_ conflictos: [[String: Any]],
                               _ libretas: [[String: Any]],
                               _ yo: String,
                               segundaVuelta: Bool = false) -> Rechazos {
        func con(_ motivo: String) -> [String] {
            conflictos.filter { ($0["motivo"] as? String) == motivo }
                .compactMap { $0["id"] as? String }
        }
        let correo = yo.lowercased()
        func soyDueno(_ l: [String: Any]) -> Bool {
            // Una libreta local no tiene lista de miembros: sin lista, es tuya.
            guard let m = l["miembros"] as? [[String: Any]], !m.isEmpty else { return true }
            return m.contains { ($0["email"] as? String)?.lowercased() == correo
                                && ($0["rol"] as? String) == "Dueño" }
        }
        var porLlave: [String: [String: Any]] = [:]
        for l in libretas { if let id = l["id"] as? String { porLlave[id] = l } }

        let ajenas = conflictos
            .filter { ($0["motivo"] as? String) == "sin-permiso"
                   || ($0["motivo"] as? String) == "no-eres-dueno" }
            .compactMap { $0["id"] as? String }
        let rescatables = segundaVuelta ? [] : ajenas.filter { id in
            esIdViejo(id) && porLlave[id] != nil && soyDueno(porLlave[id]!)
        }
        return Rechazos(desactualizadas: con("desactualizada"),
                        limite: con("limite-plan"),
                        ajenas: ajenas,
                        rescatables: rescatables,
                        sinPermiso: ajenas.filter { !rescatables.contains($0) })
    }
}
