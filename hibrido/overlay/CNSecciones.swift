import Foundation

/**
 * LAS SUBPANTALLAS DE PERFIL, ARMADAS EN EL TELÉFONO.
 *
 * Hasta ahora las armaba la web —`seccionNativa(id)` devuelve unos bloques y
 * SwiftUI los dibuja— y eso funciona, pero tiene dos costes que se ven:
 *
 * **Hay que esperar a que la web despierte.** Entrar en un ajuste antes de eso
 * deja la pantalla en blanco, y solo la primera vez, que es cuando peor sienta.
 *
 * **Lo que vive en el SERVIDOR lo pedía la web.** Así que una subpantalla
 * nativa solo podía enseñar lo que la web hubiera pedido antes: «Seguridad» e
 * «Integraciones» salían diciendo que no tienes ninguna clave teniendo tres.
 *
 * Aquí se arman en Swift y los datos del servidor se piden con `CNApi`, que es
 * como funciona una app normal. Lo que NO se toca es la libreta: ahí la fuente
 * de verdad es la copia local que la web sincroniza, y dos escritores sin
 * ponerse de acuerdo no dan un fallo visible, dan movimientos que desaparecen.
 *
 * REGLAS DE LA CASA, para que esto no se convierta en la web escrita otra vez:
 *
 * - **Los catálogos no se copian**: los iconos salen de `CNCatalogos`, que
 *   genera `npm run sync` desde la web. Ya se desvió uno cuando estaban a mano.
 * - **Los textos van por `cnT`**, que es lo que los mete en la lista que la app
 *   traduce. Un texto escrito suelto sale en español en una app en inglés.
 * - **Las acciones van por NOMBRE, no por número.** La web guarda sus acciones
 *   en una lista y las dispara por su índice; eso solo vale si la lista la hizo
 *   ella. Aquí cada fila dice qué hoja abre, y el puente la abre por su nombre.
 */
enum CNSecciones {

    /// Las que este lado sabe armar. Lo demás sigue viniendo de la web.
    static let sabeHacer: Set<String> = ["dosPasos"]

    /**
     * Lo que se le ha pedido al servidor, guardado mientras dure la app.
     *
     * Con caché porque entrar y salir de un ajuste es lo más normal del mundo y
     * pedirlo otra vez en cada entrada se nota. Se vacía al cambiar algo.
     */
    @MainActor static var delServidor: [String: [String: Any]] = [:]

    @MainActor static func olvida(_ ruta: String) { delServidor[ruta] = nil }

    /**
     * La subpantalla de un id, si este lado sabe armarla.
     *
     * Devuelve nil cuando no la sabe hacer O cuando le faltan los datos del
     * servidor: el que llama se queda entonces con la de la web, que es mejor
     * que una pantalla a medias. Pedir los datos es cosa aparte (`traer`).
     */
    @MainActor static func arma(_ id: String) -> CNSeccion? {
        switch id {
        case "dosPasos": return dosPasos()
        default: return nil
        }
    }

    /// Qué hay que pedirle al servidor para armar esta subpantalla.
    static func rutaDe(_ id: String) -> String? {
        id == "dosPasos" ? "/mfa/metodos" : nil
    }

    /* ------------------------ verificación en dos pasos ------------------- */

    /**
     * Los cuatro métodos, con su estado.
     *
     * El ORDEN es el de la web y no es alfabético: correo primero porque es el
     * que casi todo el mundo puede activar sin instalar nada, y los códigos de
     * respaldo al final porque son la red por si pierdes los otros tres.
     *
     * Cada fila abre una hoja distinta según esté activo o no: la de encender y
     * la de apagar no son la misma pantalla.
     */
    @MainActor private static func dosPasos() -> CNSeccion? {
        guard let r = delServidor["/mfa/metodos"] else { return nil }
        let m = (r["metodos"] as? [String: Any]) ?? [:]
        func activo(_ k: String) -> Bool {
            ((m[k] as? [String: Any])?["activo"] as? Bool) ?? false
        }
        func dato(_ k: String, _ campo: String) -> Any? {
            (m[k] as? [String: Any])?[campo]
        }

        let verde = "var(--positivo)"
        let gris = ""
        let si = cnT("Activo"), no = cnT("No")

        var filas: [CNSeccion.Fila] = []
        func pon(_ label: String, _ valor: String, _ encendido: Bool,
                 _ icono: String, _ hoja: String) {
            filas.append(CNSeccion.Fila(
                label: label, valor: valor,
                icono: CNCatalogos.iconosDeAjuste[icono] ?? "",
                tinta: encendido ? verde : gris, entra: true,
                abre: "hoja:" + hoja))
        }

        pon(cnT("Código por correo"), activo("correo") ? si : no, activo("correo"),
            "correo", activo("correo") ? "mfaCorreoOff" : "mfaCorreoOn")
        pon(cnT("App de autenticación"), activo("totp") ? si : no, activo("totp"),
            "telefono", activo("totp") ? "mfaTotpOff" : "mfaTotp")

        // Telegram tiene un tercer estado: puede no estar disponible porque el
        // servidor no tenga bot. Decir «No» ahí es mentir: no es que no lo
        // tengas puesto, es que no se puede poner.
        let tgActivo = activo("telegram")
        let tgHay = (dato("telegram", "disponible") as? Bool) ?? true
        let tgPista = (dato("telegram", "pista") as? String) ?? ""
        pon("Telegram",
            tgActivo ? (tgPista.isEmpty ? si : tgPista) : (tgHay ? no : cnT("No disponible")),
            tgActivo, "dosPasos",
            tgActivo ? "mfaTelegramOff" : (tgHay ? "mfaTelegram" : ""))

        // Los de respaldo dicen CUÁNTOS quedan, no solo que están: gastarlos es
        // justo lo que pasa, y «Activo» con cero sin usar no ayuda a nadie.
        let quedan = (dato("respaldo", "quedan") as? Int) ?? 0
        pon(cnT("Códigos de respaldo"),
            activo("respaldo")
                ? cnT("{n} sin usar").replacingOccurrences(of: "{n}", with: String(quedan))
                : no,
            activo("respaldo"), "clave", "mfaRespaldo")

        let puesta = ((r["usuario"] as? [String: Any])?["mfa"] as? Bool) ?? false
        var s = CNSeccion()
        s.id = "dosPasos"
        s.titulo = cnT("Verificación en dos pasos")
        s.volverA = "seguridad"
        var explica = CNSeccion.Bloque(); explica.tipo = "texto"
        explica.texto = puesta
            ? cnT("Con la verificación puesta, tu contraseña sola no abre la cuenta.")
            : cnT("Activa al menos un método: al entrar te pediremos un código además de la contraseña.")
        var lista = CNSeccion.Bloque(); lista.tipo = "grupo"
        lista.filas = filas
        lista.pie = cnT("Puedes tener varios a la vez y elegir con cuál entrar. Todos son gratis.")
        s.bloques = [explica, lista]
        return s
    }
}
