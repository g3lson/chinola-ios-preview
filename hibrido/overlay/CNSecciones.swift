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
    static let sabeHacer: Set<String> = ["dosPasos", "seguridad"]

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
        case "seguridad": return seguridad()
        default: return nil
        }
    }

    /// Qué hay que pedirle al servidor para armar esta subpantalla.
    ///
    /// Varias rutas porque una pantalla puede necesitar más de una cosa, y se
    /// piden a la vez: en serie, «Seguridad» tardaría el doble por nada.
    static func rutasDe(_ id: String) -> [String] {
        switch id {
        case "dosPasos": return ["/mfa/metodos"]
        case "seguridad": return ["/sesiones", "/actividad", "/mfa/metodos"]
        default: return []
        }
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

    /* ------------------------------ seguridad ----------------------------- */

    /**
     * La contraseña, la verificación en dos pasos, y dónde tienes la sesión.
     *
     * Las sesiones y la actividad son del SERVIDOR: no hay copia local de eso,
     * y por eso esta pantalla salía en blanco recién abierta la app. Ahora se
     * piden aquí.
     *
     * DOS COSAS QUE NO SE VEN Y HAY QUE CONSERVAR:
     *
     * **La sesión de este mismo aparato no se puede cerrar.** Cerrarse a uno
     * mismo desde aquí te deja fuera con un botón que parecía de limpiar.
     *
     * **Los aparatos y la actividad solo salen si hay.** Un rótulo «Dónde
     * tienes la sesión abierta» con la lista vacía se lee como que algo falló.
     */
    @MainActor private static func seguridad() -> CNSeccion? {
        var s = CNSeccion()
        s.id = "seguridad"
        s.titulo = cnT("Seguridad")

        // Las dos primeras filas no dependen del servidor: se dibujan siempre,
        // aunque no haya red. La de dos pasos dice su estado si se sabe.
        let mfa = ((delServidor["/mfa/metodos"]?["usuario"] as? [String: Any])?["mfa"] as? Bool)
        var arriba = CNSeccion.Bloque(); arriba.tipo = "grupo"
        arriba.filas = [
            CNSeccion.Fila(label: cnT("Cambiar mi contraseña"),
                           icono: CNCatalogos.iconosDeAjuste["clave"] ?? "",
                           entra: true, abre: "hoja:clave"),
            CNSeccion.Fila(label: cnT("Verificación en dos pasos"),
                           valor: mfa == nil ? "" : (mfa! ? cnT("Activada") : cnT("Desactivada")),
                           icono: CNCatalogos.iconosDeAjuste["dosPasos"] ?? "",
                           tinta: mfa == true ? "var(--positivo)" : "",
                           entra: true, abre: "dosPasos")
        ]
        s.bloques = [arriba]

        // Bloquear con Face ID: esto es del TELÉFONO y solo del teléfono, así
        // que no hay nada que pedirle a nadie.
        var bio = CNSeccion.Bloque()
        bio.tipo = "interruptor"
        bio.label = cnT("Bloquear con Face ID")
        bio.texto = cnT("Al volver a la app pide tu cara, tu huella o el código del teléfono.")
        // Donde ya lo guarda el puente. No hay una segunda copia: una copia es
        // lo que un día dice «apagado» con el bloqueo puesto.
        bio.puesto = UserDefaults.standard.bool(forKey: "cnBloqueo")
        bio.abre = "bloqueoBio"
        s.bloques.append(bio)

        // Los aparatos. Solo si hay: un rótulo con la lista vacía se lee como
        // que algo falló, y aquí lo normal es que haya al menos este.
        let ses = (delServidor["/sesiones"]?["sesiones"] as? [[String: Any]]) ?? []
        if !ses.isEmpty {
            var b = CNSeccion.Bloque(); b.tipo = "lista"
            b.titulo = cnT("Dónde tienes la sesión abierta")
            b.items = ses.map { q in
                let equipo = (q["equipo"] as? String) ?? ""
                let actual = (q["actual"] as? Bool) ?? false
                let movil = equipo.range(of: "iPhone|iPad|Android", options: [.regularExpression, .caseInsensitive]) != nil
                var it = CNSeccion.Item()
                it.titulo = cnT(equipo) + (actual ? " · " + cnT("este equipo") : "")
                it.detalle = cnT("Entró") + " " + cnHaceCuanto(q["creado"] as? String)
                    + " · " + cnT("visto") + " " + cnHaceCuanto(q["visto"] as? String)
                it.icono = CNCatalogos.iconosDeAjuste[movil ? "telefono" : "monitor"] ?? ""
                it.color = actual ? "var(--positivo)" : ""
                // La de este aparato NO lleva el botón de cerrar: cerrarse a uno
                // mismo desde aquí te deja fuera con un botón que parecía de
                // limpiar. Para eso está «Cerrar sesión», que avisa.
                if !actual, let id = q["id"] {
                    it.acciones = [CNSeccion.AccionItem(
                        label: cnT("Cerrar"), peligro: true, abre: "cerrarSesion:\(id)")]
                }
                return it
            }
            s.bloques.append(b)
        }

        // Y lo último que pasó. Doce como en la web: es un vistazo, no un
        // registro, y con cincuenta deja de leerse.
        let act = (delServidor["/actividad"]?["actividad"] as? [[String: Any]]) ?? []
        if !act.isEmpty {
            var b = CNSeccion.Bloque(); b.tipo = "lista"
            b.titulo = cnT("Lo último que pasó")
            b.items = act.prefix(12).map { a in
                var it = CNSeccion.Item()
                it.titulo = (a["accion"] as? String) ?? ""
                it.detalle = cnHaceCuanto(a["creado"] as? String)
                    + " · " + cnT((a["origen"] as? String) ?? "")
                return it
            }
            s.bloques.append(b)
        }
        return s
    }
}

/**
 * «hace un momento», «hace 3 h», «ayer».
 *
 * Los mismos cortes que la web, a propósito: noventa segundos para «un
 * momento», y un mes como tope. Poner otros haría que el mismo aparato dijera
 * «hace 2 h» en el teléfono y «hace 1 h» en el ordenador, que es la clase de
 * diferencia que hace dudar de si son el mismo dato.
 */
func cnHaceCuanto(_ iso: String?) -> String {
    guard let iso = iso, !iso.isEmpty else { return "" }
    let f = ISO8601DateFormatter()
    f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    let d = f.date(from: iso) ?? ISO8601DateFormatter().date(from: iso)
    guard let d = d else { return "" }
    let seg = max(0, Int((Date().timeIntervalSince(d)).rounded()))
    if seg < 90 { return cnT("hace un momento") }
    let min = Int((Double(seg) / 60).rounded())
    if min < 60 { return cnT("hace {n} min").replacingOccurrences(of: "{n}", with: String(min)) }
    let h = Int((Double(min) / 60).rounded())
    if h < 24 { return cnT("hace {n} h").replacingOccurrences(of: "{n}", with: String(h)) }
    let dias = Int((Double(h) / 24).rounded())
    if dias == 1 { return cnT("ayer") }
    if dias < 30 { return cnT("hace {n} días").replacingOccurrences(of: "{n}", with: String(dias)) }
    return cnT("hace más de un mes")
}
