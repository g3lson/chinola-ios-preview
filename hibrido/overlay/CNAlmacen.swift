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
 * NO ES EL DUEÑO TODAVÍA. Quien escribe la libreta sigue siendo la web —una sola
 * mano— y esto solo lee. Cuando `CNNube` concilie, devolverá el resultado por el
 * mismo sitio por el que llegó, para que no haya dos versiones distintas de la
 * misma libreta en el mismo teléfono.
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

    /// La copia entera, tal como la dejó la web: llave de localStorage → texto.
    static func copia() -> [String: String]? {
        guard let u = archivo, let d = try? Data(contentsOf: u),
              let j = (try? JSONSerialization.jsonObject(with: d)) as? [String: Any] else { return nil }
        var salida: [String: String] = [:]
        for (k, v) in j { if let t = v as? String { salida[k] = t } }
        return salida.isEmpty ? nil : salida
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
    static func correo() -> String {
        guard let t = copia()?[USUARIO], let d = t.data(using: .utf8),
              let j = (try? JSONSerialization.jsonObject(with: d)) as? [String: Any] else { return "" }
        return (j["email"] as? String) ?? ""
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
