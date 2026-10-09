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

    /**
     * ¿Sabe este lado armar esta subpantalla?
     *
     * No basta con mirar la lista de nombres: «libreta:3» es una libreta por
     * dentro y lleva su número pegado, así que nunca estaría en una lista fija.
     * Se me quedó fuera al escribirla —la función existía y no la llamaba
     * nadie—, que es exactamente el fallo que llevo todo el día encontrando en
     * otros sitios: código correcto, probado y muerto.
     */
    static func sabeArmar(_ id: String) -> Bool {
        sabeHacer.contains(id) || id.hasPrefix("libreta:")
    }

    /**
     * Las que este lado sabe armar. Lo demás sigue viniendo de la web.
     *
     * TIENE QUE DECIR LO MISMO QUE `armaDeVerdad`, y son dos listas. «Tu
     * personaje» se escribió entera aquí, con su prueba, y no salía nunca:
     * estaba en una y no en la otra, así que ni se intentaba y ganaba la de la
     * web. Y no se veía —la de la web enseña lo mismo—; lo dijo la sonda del
     * banco. Hay una prueba que compara las dos.
     */
    static let sabeHacer: Set<String> = ["dosPasos", "seguridad", "cuenta", "panel", "dinero", "libretas", "menu", "letra", "cabecera", "colores", "icono-app", "personaje", "integraciones"]

    /**
     * Lo que se le ha pedido al servidor, guardado mientras dure la app.
     *
     * Con caché porque entrar y salir de un ajuste es lo más normal del mundo y
     * pedirlo otra vez en cada entrada se nota. Se vacía al cambiar algo.
     */
    @MainActor static var delServidor: [String: [String: Any]] = [:]

    @MainActor static func olvida(_ ruta: String) { delServidor[ruta] = nil }

    /**
     * Cómo está ahora un ajuste de sí/no, para poder pedir el contrario.
     *
     * Solo los que alguna de estas subpantallas enseña. Lo que no esté aquí
     * devuelve `false`, así que pedir el contrario lo enciende — que es lo que
     * uno espera al tocar un interruptor que se ve apagado.
     */
    @MainActor static func puestoAhora(_ clave: String) -> Bool {
        switch clave {
        case "panelVivo": return CNC.fmt.panelVivo
        case "centavos": return CNC.fmt.centavos
        case "menuTitulos": return CNMenuEstado.shared.titulos
        case "cabeceraTarjeta": return CNC.fmt.cabeceraTarjeta
        case "cabeceraIntegrada": return CNC.fmt.cabeceraIntegrada
        default: return false
        }
    }

    /**
     * La subpantalla de un id, si este lado sabe armarla.
     *
     * Devuelve nil cuando no la sabe hacer O cuando le faltan los datos del
     * servidor: el que llama se queda entonces con la de la web, que es mejor
     * que una pantalla a medias. Pedir los datos es cosa aparte (`traer`).
     */
    @MainActor static func arma(_ id: String) -> CNSeccion? {
        var hecha = armaDeVerdad(id)
        // Marcada, para que después se pueda preguntar quién armó LO QUE ESTÁ
        // EN PANTALLA y no solo quién fue el último en intentarlo.
        hecha?.deQuien = "nativa"
        // QUIÉN ARMÓ ESTA PANTALLA, dicho en voz alta para el banco.
        //
        // «Libretas y permisos» estuvo armándose en la web mientras la versión
        // nativa existía, estaba probada y devolvía nil por no tener datos. La
        // pantalla salía IGUAL DE BIEN: lo único que la delató fue un chip de
        // más en una captura. Eso no se puede encontrar mirando fotos una por
        // una, así que ahora se dice, y el banco lo comprueba.
        if ProcessInfo.processInfo.environment["CN_CON"]?.contains("sonda") == true {
            NSLog("CNSECCION: %@ %@", id, hecha == nil ? "web" : "nativa")
        }
        return hecha
    }

    @MainActor private static func armaDeVerdad(_ id: String) -> CNSeccion? {
        switch id {
        case "dosPasos": return dosPasos()
        case "seguridad": return seguridad()
        case "cuenta": return cuenta()
        case "panel": return panel()
        case "dinero": return dinero()
        case "libretas": return libretas()
        case "menu": return menu()
        case "letra": return letra()
        case "cabecera": return cabecera()
        case "colores": return colores()
        case "icono-app": return iconoDeLaApp()
        case "personaje": return personaje()
        case "integraciones": return integraciones()
        // «libreta:3» es una libreta por dentro: sus miembros y sus permisos.
        case let x where x.hasPrefix("libreta:"): return unaLibreta(String(x.dropFirst(8)))
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
        case "cuenta": return ["/yo"]
        // Las tres de Integraciones: por dónde se puede anotar, las claves de
        // API y los métodos de dos pasos —de ahí sale si Telegram está
        // enlazado, que es el mismo enlace que sirve para entrar—.
        case "integraciones": return ["/integraciones/voz", "/claves", "/mfa/metodos"]
        // Estas dos no le preguntan NADA a nadie: todo lo que enseñan está en
        // el teléfono. Se dibujan enteras antes de que la web despierte.
        // Los miembros vienen DENTRO de la libreta, no de la API: la web los
        // cambia en local y la sincronización los sube. Ver `CNLibretas.Fila`.
        case "panel", "dinero", "libretas", "menu", "letra", "cabecera", "colores", "icono-app",
             "personaje": return []
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
            "autenticador", activo("totp") ? "mfaTotpOff" : "mfaTotp")

        // Telegram tiene un tercer estado: puede no estar disponible porque el
        // servidor no tenga bot. Decir «No» ahí es mentir: no es que no lo
        // tengas puesto, es que no se puede poner.
        let tgActivo = activo("telegram")
        let tgHay = (dato("telegram", "disponible") as? Bool) ?? true
        let tgPista = (dato("telegram", "pista") as? String) ?? ""
        pon("Telegram",
            tgActivo ? (tgPista.isEmpty ? si : tgPista) : (tgHay ? no : cnT("No disponible")),
            tgActivo, "telegram",
            tgActivo ? "mfaTelegramOff" : (tgHay ? "mfaTelegram" : ""))

        // Los de respaldo dicen CUÁNTOS quedan, no solo que están: gastarlos es
        // justo lo que pasa, y «Activo» con cero sin usar no ayuda a nadie.
        let quedan = (dato("respaldo", "quedan") as? Int) ?? 0
        pon(cnT("Códigos de respaldo"),
            activo("respaldo")
                ? cnT("{n} sin usar").replacingOccurrences(of: "{n}", with: String(quedan))
                : no,
            activo("respaldo"), "codigos", "mfaRespaldo")

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

    /* --------------------------- panel del resumen ------------------------ */

    /**
     * Un interruptor, una explicación y un botón.
     *
     * Es la más simple de las trece y por eso es la que enseña el patrón: no le
     * pregunta nada a nadie. El ajuste está en el teléfono, el texto está
     * traducido, y el botón lleva a organizar el panel, que ya es nativo.
     */
    @MainActor private static func panel() -> CNSeccion? {
        var s = CNSeccion()
        s.id = "panel"
        s.titulo = cnT("Panel del resumen")

        var vivo = CNSeccion.Bloque(); vivo.tipo = "interruptor"
        vivo.label = cnT("Tarjetas con color")
        vivo.texto = cnT("Las cifras del mes en tarjetas de su color, con más vida")
        vivo.puesto = CNC.fmt.panelVivo
        vivo.abre = "pon:panelVivo"

        var como = CNSeccion.Bloque(); como.tipo = "texto"
        como.texto = cnT("Mantén pulsada una tarjeta para moverla, pellizca para cambiar su tamaño, y en su menú la ocultas o la quitas.")

        var ir = CNSeccion.Bloque(); ir.tipo = "boton"
        ir.label = cnT("Ir a organizar el panel")
        ir.estilo = "acento"
        ir.abre = "organizar"

        s.bloques = [vivo, como, ir]
        return s
    }

    /* ----------------------------- dinero --------------------------------- */

    /**
     * La moneda y si se ven los centavos.
     *
     * Las monedas salen del catálogo generado: son quince y estaban escritas en
     * la web, así que copiarlas aquí sería la sexta lista paralela del día.
     *
     * Dos columnas como en la web: con una sola hay que rodar quince veces para
     * ver la última, y con tres el nombre largo —«Peso dominicano (RD$)»— no
     * cabe y se corta justo donde dice cuál es.
     */
    @MainActor private static func dinero() -> CNSeccion? {
        var s = CNSeccion()
        s.id = "dinero"
        s.titulo = cnT("Dinero")

        var mon = CNSeccion.Bloque(); mon.tipo = "opciones"
        mon.titulo = cnT("Moneda")
        mon.columnas = 2
        mon.opciones = CNCatalogos.monedas.map { m in
            CNSeccion.Opcion(label: cnT(m.nombre), puesta: m.id == CNC.fmt.moneda,
                             abre: "pon:moneda=" + m.id)
        }

        var cent = CNSeccion.Bloque(); cent.tipo = "opciones"
        cent.titulo = cnT("Los centavos")
        cent.columnas = 2
        cent.opciones = [
            CNSeccion.Opcion(label: cnT("Sin centavos"), puesta: !CNC.fmt.centavos,
                             abre: "pon:centavos=0"),
            CNSeccion.Opcion(label: cnT("Con centavos"), puesta: CNC.fmt.centavos,
                             abre: "pon:centavos=1")
        ]

        s.bloques = [mon, cent]
        return s
    }

    /* --------------------------- el icono de la app ----------------------- */

    /**
     * Cuál de los nueve se ve en la pantalla de inicio.
     *
     * CADA UNO ENSEÑA EL SUYO DE VERDAD, no una copia. Los nueve van dentro del
     * paquete —son los que iOS instala— así que se enseñan directamente. Una
     * copia rasterizada aparte podría parecerse y no ser el mismo, y eso es
     * exactamente lo que nadie comprobaría: se elige uno y sale otro.
     *
     * El primero es el de fábrica y lleva su propio dibujo, no una caja vacía:
     * es uno de los nueve, no la ausencia de icono.
     */
    @MainActor private static func iconoDeLaApp() -> CNSeccion? {
        let cual = CNC.fmt.iconoApp
        var s = CNSeccion()
        s.id = "icono-app"
        s.titulo = cnT("El icono de la app")

        var rejilla = CNSeccion.Bloque(); rejilla.tipo = "opciones"
        rejilla.titulo = cnT("Cuál quieres en la pantalla de inicio")
        rejilla.columnas = 3

        func uno(_ id: String, _ nombre: String, _ nota: String, _ dibujo: String) -> CNSeccion.Opcion {
            var o = CNSeccion.Opcion()
            o.label = nombre
            o.sub = nota
            o.puesta = cual == id
            // El nombre del fichero dentro del paquete, que es el mismo que usa
            // `setAlternateIconName`. Así lo que se enseña y lo que se instala
            // no pueden separarse.
            o.imagen = "Chinola-" + dibujo
            o.abre = "icono:" + id
            return o
        }

        let principal = CNCatalogos.iconoPrincipal
        let suyo = CNCatalogos.iconosDeLaApp.first { $0.id == principal }
        rejilla.opciones = [uno("", cnT("El de la app"),
                                cnT(suyo?.nombre ?? "") + " · " + cnT("el de fábrica"), principal)]
            + CNCatalogos.iconosDeLaApp.map { uno($0.id, cnT($0.nombre), cnT($0.nota), $0.id) }

        var aviso = CNSeccion.Bloque(); aviso.tipo = "texto"
        aviso.texto = cnT("Al cambiarlo, iOS avisa una vez de que el icono cambió. Es normal y lo pregunta él, no la app.")

        s.bloques = [rejilla, aviso]
        return s
    }

    /* -------------------------------- colores ----------------------------- */

    /// Los temas de día que se ofrecen, y en este orden.
    ///
    /// No son todos los que hay: son los que DE VERDAD se distinguen. Con
    /// treinta y tres miniaturas casi iguales no se elige, se renuncia.
    private static let CLAROS = ["sistema", "chinola", "claro", "hoja", "oceano",
                                 "menta", "uva", "cacao", "semillas", "flor"]
    private static let OSCUROS = ["sistema_noche", "chinola_noche", "noche", "carbon",
                                  "medianoche", "bosque", "ciruela", "cafe_noche"]

    /**
     * El modo, el tema de día, el de noche y los colores de las cifras.
     *
     * LO QUE NO SE VE Y HAY QUE CONSERVAR:
     *
     * **Cada miniatura se pinta con SU tema, no con el puesto.** Elegir un tema
     * por su nombre es elegir a ciegas; el dibujito ES la decisión.
     *
     * **«Automático» enseña las dos mitades**, la de día y la de noche, porque
     * eso es justo lo que hace: seguir al teléfono.
     *
     * **El de día y el de noche se marcan por separado.** Con «Automático»
     * puesto hay dos elegidos a la vez, y marcar solo el que se está viendo
     * ahora haría parecer que el otro no está.
     */
    @MainActor private static func colores() -> CNSeccion? {
        let f = CNC.fmt
        let esOscuroAhora = CNCatalogos.claroDe[f.temaId] != nil
        // Cuál es el de día y cuál el de noche, con los mismos respaldos que la
        // web: si no se ha elegido uno, el que le toca al que está puesto.
        let claroAhora = f.temaAuto
            ? (f.temaClaro.isEmpty
                ? (esOscuroAhora ? (CNCatalogos.claroDe[f.temaId] ?? "chinola") : f.temaId)
                : f.temaClaro)
            : (esOscuroAhora ? "" : f.temaId)
        let oscuroAhora = f.temaAuto
            ? (f.temaOscuro.isEmpty
                ? (CNCatalogos.oscuroDe[claroAhora] ?? "noche")
                : f.temaOscuro)
            : (esOscuroAhora ? f.temaId : "")

        /// Una miniatura pintada con los colores de ESE tema.
        func mini(_ k: String, _ o: inout CNSeccion.Opcion) {
            let t = CNCatalogos.temas[k]
            o.fondo = t?.bg ?? ""
            o.franja = t?.side ?? ""
            o.tarjeta = t?.card ?? ""
            o.tinta = t?.tinta ?? ""
            o.acento = CNCatalogos.acentos[k] ?? ""
            o.oscuro = CNCatalogos.claroDe[k] != nil
        }

        var s = CNSeccion()
        s.id = "colores"
        s.titulo = cnT("Colores")

        // ── el modo ────────────────────────────────────────────────────────
        var modo = CNSeccion.Bloque(); modo.tipo = "telefonos"
        modo.titulo = cnT("Modo")
        modo.pie = cnT("Automático sigue el modo claro u oscuro del teléfono.")
        let cualModo = f.temaAuto ? "auto" : (esOscuroAhora ? "oscuro" : "claro")
        var auto = CNSeccion.Opcion()
        auto.label = cnT("Automático"); auto.puesta = cualModo == "auto"
        auto.vista = "modo"; auto.valor = "auto"; auto.abre = "modo:auto"
        mini(claroAhora.isEmpty ? f.temaId : claroAhora, &auto)
        // La mitad de noche: es lo que hace «Automático», y enseñar solo la de
        // día lo dejaría igual que «Claro».
        let deNoche = CNCatalogos.temas[oscuroAhora.isEmpty ? "noche" : oscuroAhora]
        auto.nocheFondo = deNoche?.bg ?? ""
        auto.nocheFranja = deNoche?.side ?? ""
        auto.nocheTarjeta = deNoche?.card ?? ""

        var claro = CNSeccion.Opcion()
        claro.label = cnT("Claro"); claro.puesta = cualModo == "claro"
        claro.vista = "modo"; claro.valor = "claro"; claro.abre = "modo:claro"
        mini(claroAhora.isEmpty ? (CNCatalogos.claroDe[f.temaId] ?? "chinola") : claroAhora, &claro)

        var oscuro = CNSeccion.Opcion()
        oscuro.label = cnT("Oscuro"); oscuro.puesta = cualModo == "oscuro"
        oscuro.vista = "modo"; oscuro.valor = "oscuro"; oscuro.abre = "modo:oscuro"
        mini(oscuroAhora.isEmpty ? (CNCatalogos.oscuroDe[f.temaId] ?? "noche") : oscuroAhora, &oscuro)
        modo.opciones = [auto, claro, oscuro]

        // ── los temas, de día y de noche ───────────────────────────────────
        func rejilla(_ titulo: String, _ cuales: [String], _ elegido: String) -> CNSeccion.Bloque {
            var b = CNSeccion.Bloque(); b.tipo = "telefonos"
            b.titulo = titulo
            b.opciones = cuales.compactMap { k in
                guard let t = CNCatalogos.temas[k] else { return nil }
                var o = CNSeccion.Opcion()
                o.label = cnT(t.nombre)
                o.puesta = k == elegido
                o.vista = "tema"
                o.abre = "pon:tema=" + k
                mini(k, &o)
                return o
            }
            return b
        }

        // ── los colores de las cifras ──────────────────────────────────────
        var cifras = CNSeccion.Bloque(); cifras.tipo = "telefonos"
        cifras.titulo = cnT("Colores de las cifras")
        cifras.pie = cnT("Lo que entra, lo que sale y lo que apartas. Hay una que se distingue con daltonismo.")
        cifras.opciones = CNCatalogos.paletas.map { p in
            var o = CNSeccion.Opcion()
            o.label = cnT(p.nombre); o.sub = cnT(p.pista)
            o.puesta = p.id == f.paletaId
            o.vista = "paleta"
            o.fondo = CNC.hexScr
            o.tarjeta = CNC.hexCard
            o.oscuro = CNC.tema.oscuro
            o.puntos = [p.positivo, p.negativo, p.ahorro]
            o.abre = "pon:paleta=" + p.id
            return o
        }

        s.bloques = [modo,
                     rejilla(cnT("Tema de día"), CLAROS, claroAhora),
                     rejilla(cnT("Tema de noche"), OSCUROS, oscuroAhora),
                     cifras]
        return s
    }

    /* ------------------------------- cabecera ----------------------------- */

    /**
     * Qué se ve arriba del Resumen, y de qué color.
     *
     * LAS MINIATURAS ENSEÑAN LA FORMA, NO EL CONTENIDO: dos rayas y un bulto.
     * Es lo que deja distinguir siete cabeceras de un vistazo; con el contenido
     * de verdad serían siete pantallas pequeñas todas parecidas.
     *
     * El alto de la franja y si lleva bulto están escritos aquí a propósito:
     * son de la MINIATURA, no de la cabecera. Sacarlos de la cabecera de verdad
     * obligaría a montarla siete veces para dibujar siete dibujitos.
     */
    @MainActor private static func cabecera() -> CNSeccion? {
        let f = CNC.fmt
        var s = CNSeccion()
        s.id = "cabecera"
        s.titulo = cnT("Cabecera")

        // El alto de cada franja en la miniatura, y cuál lleva bulto. Los
        // mismos números que la web.
        let altos: [String: Double] = ["auto": 30, "fina": 14, "clara": 14,
                                       "minima": 12, "clasica": 26, "viva": 12]
        // Las claras no llevan franja de color: la suya es del color del papel.
        let sinFranja: Set<String> = ["clara", "minima", "viva"]

        var cuales = CNSeccion.Bloque(); cuales.tipo = "telefonos"
        cuales.titulo = cnT("Qué se ve arriba")
        cuales.opciones = CNCatalogos.cabeceras.map { c in
            var o = CNSeccion.Opcion()
            o.label = cnT(c.nombre)
            o.sub = cnT(c.pista)
            o.puesta = c.id == f.cabecera
            o.vista = "cabecera"
            o.fondo = CNC.hexScr
            o.franja = sinFranja.contains(c.id) ? CNC.hexSoft : CNC.hexSide
            o.alto = CGFloat(altos[c.id] ?? 20)
            o.bulto = c.id == "auto" || c.id == "clasica"
            o.tarjeta = CNC.hexCard
            o.oscuro = CNC.tema.oscuro
            o.abre = "pon:cabecera=" + c.id
            return o
        }

        // «Del tema» delante: es lo de fábrica, y va primero para que quien no
        // quiera elegir color vea enseguida cuál tiene.
        var colores = CNSeccion.Bloque(); colores.tipo = "muestras"
        colores.titulo = cnT("Color de la cabecera")
        colores.colores = [CNSeccion.Muestra(nombre: cnT("Del tema"), css: CNC.hexSide,
                                             puesta: f.cabeceraColor.isEmpty,
                                             abre: "pon:cabeceraColor=")]
            + CNCatalogos.coloresDeCabecera.map { c in
                CNSeccion.Muestra(nombre: cnT(c.nombre), css: c.css,
                                  puesta: c.id == f.cabeceraColor,
                                  abre: "pon:cabeceraColor=" + c.id)
            }

        var esquinas = CNSeccion.Bloque(); esquinas.tipo = "interruptor"
        esquinas.label = cnT("Esquinas redondeadas")
        esquinas.texto = cnT("Con las esquinas de abajo redondeadas, como una tarjeta")
        esquinas.puesto = f.cabeceraTarjeta
        esquinas.abre = "pon:cabeceraTarjeta"

        var integrada = CNSeccion.Bloque(); integrada.tipo = "interruptor"
        integrada.label = cnT("Integrada")
        integrada.texto = cnT("Sin color propio: la cabecera toma el fondo de la pantalla.")
        integrada.puesto = f.cabeceraIntegrada
        integrada.abre = "pon:cabeceraIntegrada"

        s.bloques = [cuales, colores, esquinas, integrada]
        return s
    }

    /* ------------------------------ menú de abajo ------------------------- */

    /// Un interruptor: si los iconos de abajo llevan su nombre debajo.
    @MainActor private static func menu() -> CNSeccion? {
        var s = CNSeccion()
        s.id = "menu"
        s.titulo = cnT("Menú de abajo")
        var b = CNSeccion.Bloque(); b.tipo = "interruptor"
        b.label = cnT("Nombres en el menú")
        b.texto = cnT("El rótulo debajo de cada icono")
        b.puesto = CNMenuEstado.shared.titulos
        b.abre = "pon:menuTitulos"
        s.bloques = [b]
        return s
    }

    /* ---------------------------------- letra ----------------------------- */

    /**
     * El tamaño del texto y las dos tipografías.
     *
     * TRES COSAS QUE PARECEN ADORNO Y NO LO SON:
     *
     * **Cada tamaño se enseña escrito con el suyo.** Una rejilla de cuatro
     * nombres —«Pequeña», «Normal»— no dice nada: lo que se elige es cómo se ve,
     * y verlo es la única manera de elegirlo.
     *
     * **Debajo va una muestra de verdad**: un título, un texto y una cifra con
     * el tamaño puesto. Es lo que deja decidir sin salir a mirar y volver.
     *
     * **Las tipografías llevan su pista** —«La del aparato», «Neutra»—, porque
     * once nombres propios seguidos no se distinguen entre sí.
     */
    /**
     * «TU PERSONAJE», ARMADA AQUÍ.
     *
     * Dos familias, tres pieles —solo con el orbe—, los seis ánimos y cómo se
     * ve el botón que flota. Se le pedía a la web, y para enseñarla ella
     * rasterizaba doce PNG: uno por muestra. Ahora las dibuja el teléfono, que
     * ya sabe hacer las dos familias.
     *
     * LAS PIELES SOLO CON EL ORBE: la chinola no tiene pieles, y enseñarlas
     * apagadas sería ofrecer algo que no existe.
     *
     * Y LA CARA DE CADA MUESTRA ES LA QUE DE VERDAD SALDRÍA HOY, no siempre la
     * contenta: si no, el selector miente sobre lo que vas a ver.
     */
    @MainActor private static func personaje() -> CNSeccion? {
        let f = CNC.fmt
        let familia = f.familia.isEmpty ? "chinola" : f.familia
        let piel = f.pielChino.isEmpty ? "clara" : f.pielChino
        let hoy = CNAnimo.puesto("auto", libreta: CNDatos.shared.libreta,
                                 mes: CNDatos.shared.mesActivo)
        var s = CNSeccion()
        s.id = "personaje"
        s.titulo = cnT("Tu personaje")

        var cual = CNSeccion.Bloque(); cual.tipo = "opciones"
        cual.titulo = cnT("Con qué cara aparece")
        cual.columnas = 2
        cual.opciones = [
            CNSeccion.Opcion(label: cnT("La chinola"),
                             sub: cnT("La fruta de siempre, con cuerpo y mejillas"),
                             puesta: familia == "chinola",
                             chino: "chinola|" + hoy + "|",
                             abre: "pon:familiaChino=chinola"),
            CNSeccion.Opcion(label: cnT("El orbe"),
                             sub: cnT("Una esfera de luz; solo mirada"),
                             puesta: familia == "orbe",
                             chino: "orbe|" + hoy + "|" + piel,
                             abre: "pon:familiaChino=orbe")
        ]
        s.bloques = [cual]

        if familia == "orbe" {
            var pieles = CNSeccion.Bloque(); pieles.tipo = "opciones"
            pieles.titulo = cnT("De qué está hecho")
            pieles.columnas = 3
            pieles.opciones = CNCatalogos.ordenDePieles.map { k in
                CNSeccion.Opcion(label: cnT(CNCatalogos.pielesDelOrbe[k]?.nombre ?? k),
                                 puesta: piel == k,
                                 chino: "orbe|" + hoy + "|" + k,
                                 abre: "pon:pielChino=" + k)
            }
            s.bloques.append(pieles)
        }

        var quien = CNSeccion.Bloque(); quien.tipo = "opciones"
        quien.titulo = cnT("Quién te acompaña")
        quien.columnas = 3
        quien.opciones = CNCatalogos.personajesQueSeEligen.map { p in
            // Por la CLAVE del propio personaje y no por su sitio en la lista:
            // «Automático» enseña la de hoy, y cada uno de los otros la suya.
            let suyo = p.id == "auto" ? hoy : p.id
            return CNSeccion.Opcion(label: cnT(p.nombre), puesta: f.personaje == p.id,
                                    chino: familia + "|" + suyo + "|" + piel,
                                    abre: "pon:personaje=" + p.id)
        }
        s.bloques.append(quien)

        // CÓMO SE VE EL BOTÓN QUE FLOTA. Aquí, con el personaje, que es de lo
        // que trata: la cara de Chino o el aro de la marca.
        var boton = CNSeccion.Bloque(); boton.tipo = "opciones"
        boton.titulo = cnT("Cómo se ve el botón que flota")
        boton.columnas = 1
        let comoEsta = CNFlotante.shared.como == "aro" ? "aro" : "cara"
        boton.opciones = [
            CNSeccion.Opcion(label: cnT("La cara de Chino"),
                             sub: cnT("Te acompaña mientras usas la app"),
                             puesta: comoEsta == "cara", abre: "pon:chinoBoton=cara"),
            CNSeccion.Opcion(label: cnT("El aro de la marca"),
                             sub: cnT("Discreto, del color del tema"),
                             puesta: comoEsta == "aro", abre: "pon:chinoBoton=aro")
        ]
        s.bloques.append(boton)
        return s
    }

    /**
     * «INTEGRACIONES», ARMADA AQUÍ.
     *
     * La más grande que hay: por dónde se puede anotar sin abrir la app
     * —Telegram, WhatsApp, Alexa, Siri—, el interruptor de Chino con IA, la IA
     * del propio iPhone, en qué orden se intentan y las claves de API.
     *
     * Tira de tres rutas del servidor, y por eso es la última que quedaba en la
     * web: las otras doce se dibujan con lo que ya hay en el teléfono. Sin
     * respuesta del servidor no se inventa nada —una fila que diga «Conectar»
     * cuando ya está conectado es peor que no estar—: se enseña lo que se sabe
     * y lo demás espera.
     *
     * LAS ACCIONES SIGUEN SIENDO DE LA WEB, por una sola puerta y dichas por su
     * nombre. Enlazar Telegram, pedir el código de WhatsApp o crear una clave
     * son conversaciones con el servidor que ella ya tiene montadas; lo que se
     * muda aquí es la PANTALLA, que es lo que se queda en blanco esperándola.
     */
    @MainActor private static func integraciones() -> CNSeccion? {
        var s = CNSeccion()
        s.id = "integraciones"
        s.titulo = cnT("Integraciones")

        let voz = delServidor["/integraciones/voz"] ?? [:]
        let claves = delServidor["/claves"] ?? [:]
        let metodos = (delServidor["/mfa/metodos"]?["metodos"] as? [String: Any]) ?? [:]
        func sub(_ d: [String: Any], _ k: String) -> [String: Any] { (d[k] as? [String: Any]) ?? [:] }
        func si(_ d: [String: Any], _ k: String) -> Bool { (d[k] as? Bool) ?? false }

        var texto = CNSeccion.Bloque(); texto.tipo = "texto"
        texto.texto = cnT("Con una clave puedes anotar gastos y transferencias desde WhatsApp, Instagram o Telegram, o desde cualquier cosa que sepa hacer una llamada web.")
        s.bloques = [texto]

        // ── EN QUÉ LIBRETA ANOTA CHINO ──────────────────────────────────────
        //
        // Lo primero, antes que los canales: por WhatsApp y por Telegram no se
        // ve dónde cae lo que anotas, así que elegirlo deja de ser un ajuste y
        // pasa a ser lo que hace que te fíes.
        //
        // SOLO LAS TUYAS. En las que eres Lector no puedes anotar, y ofrecerlas
        // es ofrecer que Chino escriba donde no le dejan.
        let yo = CNPapeles.yo(CNPerfilInfo.delAlmacen() ?? CNPerfilInfo())
        let mias = CNAlmacen.libretas().compactMap { CNLibretasArma.libretaDe($0) }
            .enumerated().filter { CNPapeles.rol($0.element, yo: yo) != CNPapeles.lector }
        if mias.count > 1 {
            let crudas = CNAlmacen.libretas()
            func idDe(_ i: Int) -> String {
                let x = crudas[i]
                if let t = x["id"] as? String { return t }
                if let n = x["id"] as? NSNumber { return n.stringValue }
                return ""
            }
            let puesta = (CNAlmacen.usuario()["libretaChino"] as? String) ?? ""
            let cual = mias.first { idDe($0.offset) == puesta } ?? mias[0]
            var b = CNSeccion.Bloque(); b.tipo = "lista"
            b.titulo = cnT("Dónde anota Chino")
            var it = CNSeccion.Item()
            it.titulo = cnT("Libreta por defecto")
            it.detalle = cual.element.nombre + " · " + cnT("Cuando no le digas en cuál, anota aquí")
            it.icono = CNCatalogos.iconosDeAjuste["libretas"] ?? ""
            it.color = CNCatalogos.tonos["indigo"] ?? ""
            it.chip = cnT("Cambiar")
            it.opciones = mias.map { CNSeccion.Elegible(id: idDe($0.offset), label: $0.element.nombre) }
            it.puesta = idDe(cual.offset)
            it.abre = "integra:libreta-chino"
            b.items = [it]
            s.bloques.append(b)
        }

        // ── POR DÓNDE SE PUEDE ANOTAR ───────────────────────────────────────
        let tg = sub(metodos, "telegram")
        let wa = sub(voz, "whatsapp")
        let alexa = sub(voz, "alexa")
        let conIA = si(voz, "ia")
        var canales = CNSeccion.Bloque(); canales.tipo = "lista"
        canales.titulo = cnT("Anotar por mensaje")
        canales.pie = cnT("Con «Chino con IA» apagado, Telegram solo entiende el formato corto («500 comida»).")

        func canal(_ titulo: String, _ detalle: String, _ icono: String, _ tono: String,
                   _ chip: String, puesto: Bool, abre: String,
                   fuera: String = "") -> CNSeccion.Item {
            var it = CNSeccion.Item()
            it.titulo = titulo; it.detalle = detalle
            it.icono = CNCatalogos.iconosDeAjuste[icono] ?? ""
            it.color = CNCatalogos.tonos[tono] ?? ""
            it.chip = chip
            it.abre = abre
            if puesto, !fuera.isEmpty {
                it.acciones = [CNSeccion.AccionItem(label: cnT("Desenlazar"), peligro: true, abre: fuera)]
            }
            return it
        }

        canales.items = [
            canal("Chino", conIA ? cnT("Aquí mismo, escribiendo o dictando")
                                 : cnT("Enciende «Chino con IA» abajo"),
                  "personajeIco", "oro", conIA ? cnT("Abrir") : "",
                  puesto: false, abre: conIA ? "integra:charla" : ""),
            canal("Telegram",
                  si(tg, "enlazado")
                    ? cnT("Enlazado {p} · escribe «500 comida» al bot")
                        .replacingOccurrences(of: "{p}", with: (tg["pista"] as? String) ?? "")
                    : (tg["disponible"] as? Bool == false ? cnT("No disponible todavía")
                        : cnT("Escribe «500 comida» y queda anotado")),
                  "telegram", "azul",
                  si(tg, "enlazado") ? cnT("Activo") : cnT("Conectar"),
                  puesto: si(tg, "enlazado"), abre: "integra:telegram",
                  fuera: "integra:telegram-fuera"),
            canal("WhatsApp",
                  si(wa, "enlazado") ? cnT("Enlazado · escríbele al número de Chinola")
                    : (si(wa, "disponible") ? cnT("Te damos un código y lo mandas al número de Chinola")
                        : cnT("No disponible todavía")),
                  "whatsapp", "verde",
                  si(wa, "enlazado") ? cnT("Activo") : cnT("Conectar"),
                  puesto: si(wa, "enlazado"), abre: "integra:voz:whatsapp",
                  fuera: "integra:voz-fuera:whatsapp"),
            canal("Alexa",
                  si(alexa, "enlazada") ? cnT("Enlazada · «Alexa, abre Chinola»")
                    : cnT("«Alexa, abre Chinola» y dile el código"),
                  "alexa", "azul",
                  si(alexa, "enlazada") ? cnT("Activo") : cnT("Conectar"),
                  puesto: si(alexa, "enlazada"), abre: "integra:voz:alexa",
                  fuera: "integra:voz-fuera:alexa"),
            // SIRI NO SE CONECTA: viene con la app. Por eso dice «Listo» y no
            // «Conectar», que es lo que se ofrece cuando hay algo que hacer.
            canal("Siri", cnT("Di «Anota en Chinola 500 de comida»"),
                  "siri", "morado", cnT("Listo"), puesto: false, abre: "")
        ]
        s.bloques.append(canales)

        // ── CHINO CON IA ────────────────────────────────────────────────────
        var ia = CNSeccion.Bloque(); ia.tipo = "interruptor"
        ia.label = cnT("Chino con IA")
        ia.pie = (voz["hayIA"] as? Bool) == false
            ? cnT("No disponible en este servidor todavía.")
            : cnT("Entiende lo que escribes o dictas —«pagué la luz, 2.300 con la Visa»— y te aconseja con tus números. Apagado de fábrica; solo se mandan totales y categorías.")
        ia.puesto = conIA
        ia.abre = "integra:ia"
        s.bloques.append(ia)

        // ── LAS CLAVES DE API ───────────────────────────────────────────────
        let lista = (claves["claves"] as? [[String: Any]]) ?? []
        let puedeCrear = (claves["api"] as? Bool) != false
        if lista.isEmpty {
            var vacio = CNSeccion.Bloque(); vacio.tipo = "texto"
            vacio.texto = puedeCrear
                ? cnT("Todavía no tienes ninguna. Crea una para empezar a conectar.")
                : cnT("Las integraciones son del plan Pro.")
            s.bloques.append(vacio)
        } else {
            var b = CNSeccion.Bloque(); b.tipo = "lista"
            b.titulo = cnT("Tus claves")
            b.items = lista.map { k in
                var it = CNSeccion.Item()
                it.titulo = (k["nombre"] as? String) ?? ""
                // QUÉ PUEDE HACER VA PRIMERO: es lo que hay que poder
                // comprobar de un vistazo al repasar las claves sueltas.
                let permisos = (k["permisosTexto"] as? String) ?? cnT("Todo")
                let usada = (k["ultimo_uso"] as? String).map {
                    cnT("usada el") + " " + cnFechaCorta($0)
                } ?? cnT("sin usar")
                it.detalle = permisos + "\n" + ((k["prefijo"] as? String) ?? "") + "… · "
                    + cnT("creada el") + " " + cnFechaCorta((k["creada"] as? String) ?? "")
                    + " · " + usada
                it.icono = "M15 7a4 4 0 1 1-3.9 5H7v3H4v-3l3.1-3H11A4 4 0 0 1 15 7M16 10h.01"
                return it
            }
            s.bloques.append(b)
        }
        var crear = CNSeccion.Bloque(); crear.tipo = "boton"
        crear.label = puedeCrear ? cnT("Nueva clave") : cnT("Ver los planes")
        crear.estilo = "acento"
        crear.abre = puedeCrear ? "integra:clave-nueva" : "integra:planes"
        s.bloques.append(crear)

        var docs = CNSeccion.Bloque(); docs.tipo = "boton"
        docs.label = cnT("Ver la documentación")
        docs.abre = "abrir:/desarrolladores.html"
        s.bloques.append(docs)
        return s
    }

    @MainActor private static func letra() -> CNSeccion? {
        var s = CNSeccion()
        s.id = "letra"
        s.titulo = cnT("Letra")

        let ahora = CNC.fmt.letraId
        var tam = CNSeccion.Bloque(); tam.tipo = "opciones"
        tam.titulo = cnT("Tamaño de la letra")
        tam.columnas = 4
        tam.opciones = CNCatalogos.letras.map { l in
            CNSeccion.Opcion(label: cnT(l.nombre), puesta: l.id == ahora,
                             muestra: "Aa", abre: "pon:letra=" + l.id)
        }

        var previa = CNSeccion.Bloque(); previa.tipo = "previa"
        previa.titulo = cnT("Así se verá")
        previa.escala = CNCatalogos.letras.first { $0.id == ahora }?.escala ?? 1
        previa.muestraTitulo = cnT("Balance del mes")
        previa.muestraTexto = cnT("Lo que entró, lo que salió y lo que te queda, de un vistazo.")
        previa.muestraCifra = cnDinero(24500)

        func tipos(_ titulo: String, _ clave: String, _ puesta: String) -> CNSeccion.Bloque {
            var b = CNSeccion.Bloque(); b.tipo = "selector"
            b.titulo = titulo
            b.valor = cnT(CNCatalogos.tipografias.first { $0.id == puesta }?.nombre ?? "")
            b.opciones = CNCatalogos.tipografias.map { f in
                CNSeccion.Opcion(label: cnT(f.nombre), sub: cnT(f.pista),
                                 puesta: f.id == puesta, abre: "pon:" + clave + "=" + f.id)
            }
            return b
        }
        s.bloques = [tam, previa,
                     tipos(cnT("Letra del texto"), "fuente", CNC.fmt.fuente),
                     tipos(cnT("Letra de los títulos"), "fuenteTitulo", CNC.fmt.fuenteTitulo)]
        return s
    }

    /* -------------------------- libretas y permisos ----------------------- */

    /**
     * La lista de libretas: la que ya tiene `CNDatos`, no una copia.
     *
     * Aquí había una segunda, y además fallaba al compilar —se escribía desde
     * fuera del hilo principal—. Quitarla arregla las dos cosas: dos listas de
     * libretas es una libreta que aparece en un sitio y no en el otro, y el
     * comentario que justificaba la copia decía exactamente eso.
     */
    @MainActor static var lasLibretas: CNLibretas? { CNDatos.shared.libretas }

    /**
     * La lista de libretas, con quién está en cada una.
     *
     * Cada fila abre la suya. El botón de crear va por el camino nativo, que es
     * el que sabe avisar cuando el plan no da para más.
     */
    @MainActor private static func libretas() -> CNSeccion? {
        guard let ls = lasLibretas, !ls.filas.isEmpty else { return nil }
        var s = CNSeccion()
        s.id = "libretas"
        s.titulo = cnT("Libretas y permisos")

        var lista = CNSeccion.Bloque(); lista.tipo = "lista"
        lista.items = ls.filas.map { f in
            var it = CNSeccion.Item()
            it.titulo = f.nombre
            // EL ICONO DE LA LIBRETA. Se ponía el fondo de color y el blanco
            // de encima, pero nunca el dibujo: un círculo de color vacío. Es la
            // misma cara que tiene en el selector y en la cabecera, y es por lo
            // que se reconoce una libreta de un vistazo sin leer su nombre.
            it.icono = f.iconoPath
            it.fondo = f.color
            it.color = "#ffffff"
            // EL TIPO Y EL PAPEL, Y SI NO, LO QUE YA VIENE HECHO.
            //
            // El papel solo existe habiendo sesión —sale de los miembros—, así
            // que sin cuenta esta línea se quedaba VACÍA y la fila era un
            // nombre suelto. La de la web decía «Personal · 2 personas», y
            // sustituirla por menos no es arreglarla.
            // Y TRES REDES, NO UNA.
            //
            // El papel sale de los miembros y sin sesión no hay ninguno; el
            // tipo y el color viven FUERA del cuerpo de la libreta —son columna
            // en el servidor— y hay caminos por los que llegan vacíos. Con una
            // sola fuente, la fila se quedaba en un nombre suelto.
            //
            // Lo último que se prueba es lo que SIEMPRE está, porque se cuenta
            // aquí mismo: cuántos movimientos tiene dentro. Una fila que dice
            // «35 movimientos» no es la ideal, pero es información; un nombre
            // solo no es nada.
            let suyo = [f.tipo, f.rol].filter { !$0.isEmpty }.joined(separator: " · ")
            it.detalle = !suyo.isEmpty ? suyo : (!f.detalle.isEmpty ? f.detalle : f.pie)
            it.chip = f.enUso ? f.rotuloEnUso : ""
            it.abre = "libreta:" + f.lid
            return it
        }
        var nueva = CNSeccion.Bloque(); nueva.tipo = "boton"
        nueva.label = cnT("Nueva libreta")
        nueva.estilo = "acento"
        nueva.abre = "hoja:libreta-nueva"
        s.bloques = [lista, nueva]
        return s
    }

    /**
     * Una libreta por dentro: quién está y qué puede hacer.
     *
     * LO QUE NO SE PUEDE PERDER AL REHACERLA:
     *
     * **Al dueño no se le cambia el papel ni se le quita**, y a uno mismo
     * tampoco: ese sería el botón con el que alguien se saca de su propia
     * libreta sin querer.
     *
     * **Los papeles que se ofrecen son los OTROS tres.** Ofrecer «Hacer Editor»
     * a quien ya es editor es una fila que no hace nada.
     *
     * **Invitar solo sale si eres el dueño y hay sesión.** Sin cuenta no hay a
     * quién invitar, y un botón que lleva a una pantalla que dice que no puedes
     * es peor que no tenerlo.
     *
     * Y NADA DE ESTO ESCRIBE AQUÍ: cambiar un papel o quitar a alguien toca la
     * libreta, que tiene un solo dueño —la copia que la web sincroniza—. Se le
     * pide a ella por nombre.
     */
    @MainActor private static func unaLibreta(_ lid: String) -> CNSeccion? {
        guard let f = lasLibretas?.filas.first(where: { $0.lid == lid }) else { return nil }
        var s = CNSeccion()
        s.id = "libreta:" + lid
        s.titulo = f.nombre
        s.volverA = "libretas"

        var cabeza = CNSeccion.Bloque(); cabeza.tipo = "lista"
        var suya = CNSeccion.Item()
        suya.titulo = f.nombre
        suya.detalle = [f.tipo, f.rol].filter { !$0.isEmpty }.joined(separator: " · ")
        suya.fondo = f.color
        suya.color = "#ffffff"
        suya.chip = f.enUso ? cnT("En uso") : ""
        cabeza.items = [suya]

        var gente = CNSeccion.Bloque(); gente.tipo = "lista"
        gente.titulo = cnT("Miembros") + (f.miembros.isEmpty ? "" : " · " + String(f.miembros.count))
        let papeles = ["Editor", "Registrador", "Lector"]
        gente.items = f.miembros.map { m in
            var it = CNSeccion.Item()
            it.titulo = m.nombre + (m.yo ? " · " + cnT("tú") : "")
            it.detalle = m.email
            it.chip = m.rol
            it.color = "#ffffff"
            if m.editable {
                // Los OTROS papeles: ofrecer el que ya tiene es una fila que no
                // hace nada.
                it.acciones = papeles.filter { $0 != m.rolId }.map { r in
                    CNSeccion.AccionItem(
                        label: cnT("Hacer {r}").replacingOccurrences(of: "{r}", with: cnT(r)),
                        abre: "rol:\(lid):\(m.email):\(r)")
                } + [CNSeccion.AccionItem(label: cnT("Quitar de la libreta"), peligro: true,
                                          abre: "quitar:\(lid):\(m.email)")]
            }
            return it
        }
        // Invitar solo si eres el dueño Y hay sesión: sin cuenta no hay a quién.
        if f.esDueno && CNApi.haySesion {
            gente.botones = [CNSeccion.Boton(label: "+ " + cnT("Invitar"), estilo: "suave",
                                             abre: "hoja:invitar:" + lid)]
        }

        s.bloques = [cabeza, gente]
        return s
    }

    /* -------------------------------- mi cuenta --------------------------- */

    /**
     * Quién eres, cómo entras, y en qué plan estás.
     *
     * Las tres primeras filas abren hojas —editar el perfil, cambiar el correo,
     * cambiar la contraseña— y llevan su valor al lado: el nombre y el correo
     * que tienes ahora. Esa es la única razón por la que esta pantalla le
     * pregunta al servidor: para poder enseñarlos.
     *
     * DOS COSAS QUE PARECEN DETALLE:
     *
     * **Lo que da el plan va de PIE del grupo, no de fila.** Es una frase, y
     * una frase entera de rótulo se corta a la mitad y no lleva a ningún sitio
     * distinto del que ya lleva la fila de arriba.
     *
     * **«Eliminar mi cuenta» va en su propio grupo, abajo y en rojo.** Apple
     * exige que la cuenta se pueda borrar desde dentro de la app y no solo por
     * la web (App Store Review Guidelines 5.1.1 v), así que tiene que estar; y
     * estando, tiene que costar llegar a ella sin querer.
     */
    @MainActor private static func cuenta() -> CNSeccion? {
        let u = (delServidor["/yo"]?["usuario"] as? [String: Any]) ?? [:]
        let nombre = (u["nombre"] as? String) ?? ""
        let correo = (u["email"] as? String) ?? ""
        let plan = (u["plan"] as? String) ?? "gratis"

        func fila(_ label: String, _ valor: String, _ icono: String,
                  _ tono: String, _ abre: String, tinta: String = "") -> CNSeccion.Fila {
            let color = CNCatalogos.tonos[tono] ?? ""
            return CNSeccion.Fila(
                label: label, valor: valor,
                icono: CNCatalogos.iconosDeAjuste[icono] ?? "",
                bg: color.isEmpty ? "" : "color-mix(in oklab, " + color + " 14%, transparent)",
                fg: color, tinta: tinta, entra: true, abre: abre)
        }

        var s = CNSeccion()
        s.id = "cuenta"
        s.titulo = cnT("Mi cuenta")

        var quien = CNSeccion.Bloque(); quien.tipo = "grupo"
        quien.filas = [
            fila(cnT("Editar mi perfil"), nombre, "perfil", "verde", "hoja:perfil"),
            fila(cnT("Cambiar mi correo"), correo, "correo", "azul", "hoja:correo"),
            fila(cnT("Cambiar mi contraseña"), "", "clave", "naranja", "hoja:clave")
        ]

        var elPlan = CNSeccion.Bloque(); elPlan.tipo = "grupo"
        elPlan.titulo = cnT("Plan")
        elPlan.pie = cnT(CNCatalogos.queDaElPlan[plan] ?? CNCatalogos.queDaElPlan["gratis"] ?? "")
        elPlan.filas = [
            fila(cnT("Mi plan"), cnT(CNCatalogos.nombreDelPlan[plan] ?? "Gratis"),
                 "plan", "", "plan")
        ]

        var baja = CNSeccion.Bloque(); baja.tipo = "grupo"
        baja.filas = [
            fila(cnT("Eliminar mi cuenta"), "", "baja", "rojo", "hoja:baja",
                 tinta: "var(--negativo)")
        ]

        s.bloques = [quien, elPlan, baja]
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
