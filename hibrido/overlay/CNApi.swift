import Foundation

/**
 * EL TELÉFONO HABLANDO CON EL SERVIDOR, SIN PASAR POR LA WEB.
 *
 * Hasta ahora todo lo que Perfil sabía del servidor —tus claves de API, tus
 * métodos de verificación, tus aparatos conectados— lo pedía la web y cruzaba
 * el puente ya masticado. Eso significa que una subpantalla nativa solo podía
 * enseñar lo que la web hubiera pedido antes, y por eso «Seguridad» e
 * «Integraciones» salían vacías recién abierta la app: nadie lo había pedido
 * todavía.
 *
 * Esto es la manera normal de hacerlo: la app habla con su API.
 *
 * QUÉ HACE FALTA PARA QUE FUNCIONE, y por qué está donde está:
 *
 * **El vale de sesión ya estaba.** Lo guarda el puente en `cnSesion` desde que
 * existe el atajo de Siri, y la web lo actualiza al entrar, al refrescarlo y al
 * salir. No hay una segunda copia que se pueda quedar vieja.
 *
 * **La dirección es la misma que la de la web**, escrita una vez aquí. Si
 * algún día cambia, cambia en `src/nube.js` y aquí, y una prueba compara las
 * dos: dos direcciones distintas es media app hablando con otro servidor.
 *
 * **UN 401 AQUÍ NO CIERRA LA SESIÓN, y esto es lo más importante del fichero.**
 *
 * Lo hacía, y estaba mal. `caducoLaSesion()` de la web vacía `libretas: []` y
 * manda a la pantalla de acceso: es lo correcto cuando falla la SINCRONIZACIÓN,
 * porque ahí sí se acabó. Pero estas llamadas son lecturas opcionales de una
 * pantalla de ajustes, y darles ese poder significa que abrir «Seguridad» con
 * el servidor de mal humor te borra la app de delante.
 *
 * Es exactamente lo que pasó: tocabas un ajuste y desaparecían los datos, y no
 * volvían hasta reiniciar. Una pantalla que no puede leer tus claves de API
 * enseña lo que ya sabía; no te saca de tu propia cuenta.
 *
 * La sesión la sigue vigilando la web por su camino de siempre, que es el que
 * de verdad sabe si se acabó.
 */
enum CNApi {

    /**
     * La misma dirección que usa la web. Ver `SITIO` en `src/nube.js`.
     *
     * Se puede apuntar a otra con `CN_API`, y eso es lo que usa el banco.
     * Hasta ahora no había manera: la siembra del banco reemplaza
     * `window.fetch`, que solo intercepta las llamadas de la WEB, así que el
     * teléfono salía a internet de verdad con un vale inventado, le contestaban
     * 401, y las tres subpantallas que hablan con el servidor caían a la web —
     * pareciendo que funcionaban, porque la pantalla sale igual—.
     *
     * En un teléfono esa variable no existe y queda la de siempre.
     */
    static let sitio: String = {
        let otra = ProcessInfo.processInfo.environment["CN_API"] ?? ""
        return otra.isEmpty ? "https://chinola.fente.com.do" : otra
    }()

    /// El vale de sesión, o vacío si no hay.
    static var vale: String {
        UserDefaults.standard.string(forKey: "cnSesion") ?? ""
    }
    static var haySesion: Bool { !vale.isEmpty }

    /// Qué puede salir mal, dicho para poder decidir qué hacer.
    enum Fallo: Error {
        /// No hay vale: ni se intenta.
        case sinSesion
        /// El servidor dijo que la sesión no vale. La web tiene que enterarse.
        case sesionCaducada
        /// El servidor contestó con un error, con lo que dijo si lo dijo.
        case servidor(Int, String)
        /// No se pudo ni preguntar: sin red, o el servidor no contesta.
        case sinRed
    }

    /**
     * Una petición a la API.
     *
     * @param ruta   sin el `/api` de delante: «/claves», «/mfa/metodos»
     * @param metodo GET si no se dice otra cosa
     * @param cuerpo lo que se manda, ya como diccionario
     */
    /**
     * A PARTIR DE AQUÍ SE COMPRIME. El mismo número que la web
     * (`DESDE_COMPRIMIR` en `src/nube.js`): por debajo, comprimir cuesta más de
     * lo que ahorra.
     *
     * No es un detalle: la sincronización manda la libreta ENTERA en cada
     * guardado, y con años de movimientos son megas por cada gasto anotado.
     * Comprimida son unas décimas de eso. Sin esto, anotar un café con datos
     * móviles sube medio mega.
     */
    static let DESDE_COMPRIMIR = 64 * 1024

    static func pide(_ ruta: String, metodo: String = "GET",
                     cuerpo: [String: Any]? = nil, espera: TimeInterval = 15) async throws -> [String: Any] {
        guard haySesion else { throw Fallo.sinSesion }
        guard let url = URL(string: sitio + "/api" + ruta) else { throw Fallo.sinRed }
        var req = URLRequest(url: url)
        req.httpMethod = metodo
        req.timeoutInterval = espera
        req.setValue("application/json", forHTTPHeaderField: "content-type")
        req.setValue("Bearer " + vale, forHTTPHeaderField: "authorization")
        if let c = cuerpo, let crudo = try? JSONSerialization.data(withJSONObject: c) {
            if crudo.count > DESDE_COMPRIMIR, let apretado = CNGzip.comprime(crudo) {
                req.httpBody = apretado
                req.setValue("gzip", forHTTPHeaderField: "content-encoding")
            } else {
                req.httpBody = crudo
            }
        }

        let datos: Data, resp: URLResponse
        do { (datos, resp) = try await URLSession.shared.data(for: req) }
        catch { throw Fallo.sinRed }

        let estado = (resp as? HTTPURLResponse)?.statusCode ?? 0
        let j = (try? JSONSerialization.jsonObject(with: datos)) as? [String: Any] ?? [:]

        // Un 401 se devuelve como fallo y NADA MÁS. Ver la cabecera: cerrar la
        // sesión desde aquí vacía la app de delante, y esto son lecturas
        // opcionales de una pantalla de ajustes.
        if estado == 401 { throw Fallo.sesionCaducada }
        if estado >= 300 {
            throw Fallo.servidor(estado, (j["error"] as? String) ?? "")
        }
        return j
    }

    /**
     * Como `pide`, pero sin reventar: devuelve nil si algo falla.
     *
     * Es lo que quieren las pantallas. Una subpantalla de ajustes que no puede
     * hablar con el servidor tiene que enseñar lo que ya sabía, no un error:
     * casi siempre es un túnel, y para cuando alguien lee el aviso ya hay red
     * otra vez.
     */
    static func intenta(_ ruta: String, metodo: String = "GET",
                        cuerpo: [String: Any]? = nil) async -> [String: Any]? {
        try? await pide(ruta, metodo: metodo, cuerpo: cuerpo)
    }
}
