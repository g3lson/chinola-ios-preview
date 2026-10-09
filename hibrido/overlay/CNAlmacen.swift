import Foundation

/**
 * LA LIBRETA EN EL TELÉFONO, LEÍDA POR EL TELÉFONO.
 *
 * La copia ya existía y no la leía nadie de este lado. La web la escribe cada
 * dos segundos —libretas, sesión, usuario y vale de sesión— en `copia.json`,
 * dentro del contenedor de la app, para el caso de que iOS le vacíe el almacén
 * al webview. Está ahí, entera, y hasta ahora solo sabía leerla la web.
 *
 * Esto la lee desde Swift. Es lo que hace posible que el teléfono sincronice él
 * solo sin tener que borrar nada ni volver a bajarlo todo del servidor: los
 * datos ya están aquí.
 *
 * Y AHORA ES EL DUEÑO DEL FICHERO. La escribía la web con el sistema de
 * ficheros de Capacitor, dos segundos después de cada cambio; ahora se la manda
 * al teléfono y la escribe él. El dato sigue siendo suyo —ella lleva la libreta
 * en su almacén—, pero el fichero, que es lo que sobrevive a que el webview
 * desaparezca, tiene UN SOLO ESCRITOR.
 *
 * Eso es lo que hace que el teléfono pueda meter lo que él escribe sin pisar
 * nada: antes, si él tocaba el fichero, el temporizador de la web llegaba dos
 * segundos después con su versión y se lo llevaba por delante, sin error y sin
 * que se notara hasta que faltara un movimiento.
 */
enum CNAlmacen {

    /// Las mismas llaves que copia la web (`LLAVES_COPIADAS` en app.js).
    static let LIBRETAS = "chinola-datos-v3"
    static let SESION = "chinola-sesion-v3"
    static let USUARIO = "chinola-usuario"
    static let VALE = "chinola-token"

    /// Donde Capacitor pone `Directory.Data` en iOS: la carpeta Documents de la
    /// app. Si esto cambiara de sitio, aquí no se encontraría nada y el teléfono
    /// se quedaría sin sincronizar —callado—, así que hay una prueba que lo mira.
    static var archivo: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            .first?.appendingPathComponent("copia.json")
    }

    /**
     * ESCRIBIR LA COPIA. El único sitio desde el que se toca el fichero.
     *
     * `llaves` son las que trae quien llama, y las que no traiga se quedan como
     * estaban: la web manda las cuatro, y el teléfono, cuando escribe una
     * libreta, manda solo la suya. Sin esa mezcla, el que escribiera el último
     * borraría la sesión o las libretas del otro.
     *
     * A UN FICHERO TEMPORAL Y LUEGO SE MUEVE. Escribir encima deja el fichero a
     * medias si la app se muere a mitad —y entonces, al abrir, no hay libreta—:
     * mover es atómico y o está la de antes o está la nueva.
     */
    @discardableResult
    static func escribe(_ llaves: [String: String]) -> Bool {
        guard let u = archivo, !llaves.isEmpty else { return false }
        var todo = copia() ?? [:]
        for (k, v) in llaves { todo[k] = v }
        guard let d = try? JSONSerialization.data(withJSONObject: todo) else { return false }
        let tmp = u.appendingPathExtension("nuevo")
        do {
            try d.write(to: tmp, options: .atomic)
            _ = try FileManager.default.replaceItemAt(u, withItemAt: tmp)
            return true
        } catch {
            // Y si no se pudo mover —la primera vez no hay fichero que
            // reemplazar—, se escribe donde va y ya.
            try? FileManager.default.removeItem(at: tmp)
            return (try? d.write(to: u, options: .atomic)) != nil
        }
    }

    /// La copia entera, tal como está en el fichero: llave → texto.
    static func copia() -> [String: String]? {
        guard let u = archivo, let d = try? Data(contentsOf: u),
              let j = (try? JSONSerialization.jsonObject(with: d)) as? [String: Any] else { return nil }
        var salida: [String: String] = [:]
        for (k, v) in j { if let t = v as? String { salida[k] = t } }
        return salida.isEmpty ? nil : salida
    }

    /**
     * GUARDAR UNA LIBRETA RECIÉN ESCRITA, en el sitio que le toca de la lista.
     *
     * El teléfono escribe el movimiento, la web lo acepta… y hasta dos segundos
     * después no había nada en disco: su temporizador espera a que dejes de
     * escribir. Si la app se cierra en ese hueco —o si iOS le vacía el almacén
     * al webview, que es justo para lo que existe este fichero— el movimiento
     * no está en ninguna parte.
     *
     * EN EL SITIO DE LA ACTIVA, que es la que el teléfono tiene. Una libreta
     * no lleva su id dentro —la que está en memoria es siempre la activa— así
     * que el sitio sale de `activa`, que está en el mismo fichero.
     *
     * Y SOLO SI EL NOMBRE CUADRA. Es lo que evita escribir la libreta de la
     * casa encima de la del negocio si justo acaban de cambiar de una a otra.
     * Cuando no cuadra no se escribe y ya: dos segundos después la escribe la
     * web, que es el camino que siempre ha funcionado.
     */
    @discardableResult
    static func guardaLibreta(_ l: CNLibreta) -> Bool {
        guard let c = copia(), let texto = c[LIBRETAS], let d = texto.data(using: .utf8),
              var j = (try? JSONSerialization.jsonObject(with: d)) as? [String: Any],
              var ls = j["libretas"] as? [[String: Any]] else { return false }
        func idDe(_ x: [String: Any]) -> String {
            if let t = x["id"] as? String { return t }
            if let n = x["id"] as? NSNumber { return n.stringValue }
            return ""
        }
        var cual = (j["activa"] as? String) ?? ""
        if cual.isEmpty, let n = j["activa"] as? NSNumber { cual = n.stringValue }
        guard !cual.isEmpty, let donde = ls.firstIndex(where: { idDe($0) == cual }),
              (ls[donde]["nombre"] as? String) == l.nombre else { return false }
        ls[donde] = l.aDiccionario()
        j["libretas"] = ls
        guard let fuera = try? JSONSerialization.data(withJSONObject: j),
              let t = String(data: fuera, encoding: .utf8) else { return false }
        return escribe([LIBRETAS: t])
    }

    /// Las libretas, ya leídas. Vacío si no hay copia o si está a medias: es
    /// mejor no sincronizar que sincronizar media libreta.
    static func libretas() -> [[String: Any]] {
        guard let c = copia(), let texto = c[LIBRETAS],
              let d = texto.data(using: .utf8),
              let j = (try? JSONSerialization.jsonObject(with: d)) as? [String: Any],
              let ls = j["libretas"] as? [[String: Any]] else { return [] }
        return ls
    }

    /// El vale de sesión. El puente también lo guarda en `cnSesion`; este es el
    /// de la copia, y sirve para saber si la copia es de una sesión iniciada.
    static func vale() -> String { copia()?[VALE] ?? "" }

    /// El correo de quien está dentro, para saber si una libreta es suya.
    static func correo() -> String { (usuario()["email"] as? String) ?? "" }

    /**
     * QUIÉN ESTÁ DENTRO Y QUÉ TIENE PUESTO.
     *
     * Todo esto ya estaba en la copia y no lo leía nadie de este lado: el
     * teléfono le preguntaba a la web hasta su propio nombre. `chinola-usuario`
     * trae la cuenta —correo, nombre, plan— y `chinola-sesion-v3` trae la
     * sesión y TODOS los ajustes, que es donde vive `nombreLocal`, el nombre
     * de quien usa la app sin cuenta.
     *
     * Siguen siendo de la WEB: ella los escribe y esto solo los lee. Lo que
     * cambia es que ya no hay que preguntárselos.
     */
    static func usuario() -> [String: Any] {
        guard let t = copia()?[USUARIO], let d = t.data(using: .utf8),
              let j = (try? JSONSerialization.jsonObject(with: d)) as? [String: Any] else { return [:] }
        return j
    }

    /// La sesión y los ajustes, que viajan en el mismo paquete.
    static func ajustes() -> [String: Any] {
        guard let t = copia()?[SESION], let d = t.data(using: .utf8),
              let j = (try? JSONSerialization.jsonObject(with: d)) as? [String: Any] else { return [:] }
        return j
    }

    /// ¿Hay sesión de verdad? Quien empezó sin cuenta tiene datos y NO tiene
    /// sesión: no es un resto de una vieja, son los únicos que tiene.
    static func haySesion() -> Bool {
        (ajustes()["sesion"] as? [String: Any])?["email"] is String
    }

    /**
     * ¿Se puede sincronizar desde aquí?
     *
     * Hacen falta las dos cosas: la copia con libretas dentro y un vale. Sin
     * alguna de ellas, el teléfono NO toma el mando y lo sigue haciendo la web.
     * Es a propósito: fallar hacia el camino que ya funciona.
     */
    static func listoParaSincronizar() -> Bool {
        !vale().isEmpty && !libretas().isEmpty
    }
}
