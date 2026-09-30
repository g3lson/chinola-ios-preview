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
 * **Un 401 no se traga.** Si el servidor dice que la sesión no vale, se le
 * cuenta a la web para que cierre sesión ella también. Sin eso, la web seguiría
 * creyendo que hay sesión y las dos mitades de la app dirían cosas distintas
 * sobre si estás dentro.
 */
enum CNApi {

    /// La misma dirección que usa la web. Ver `SITIO` en `src/nube.js`.
    static let sitio = "https://chinola.fente.com.do"

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

    /// Lo que se hace cuando el servidor dice que la sesión caducó. Lo pone el
    /// controlador, que es quien sabe hablar con la web.
    static var alCaducar: () -> Void = {}

    /**
     * Una petición a la API.
     *
     * @param ruta   sin el `/api` de delante: «/claves», «/mfa/metodos»
     * @param metodo GET si no se dice otra cosa
     * @param cuerpo lo que se manda, ya como diccionario
     */
    static func pide(_ ruta: String, metodo: String = "GET",
                     cuerpo: [String: Any]? = nil, espera: TimeInterval = 15) async throws -> [String: Any] {
        guard haySesion else { throw Fallo.sinSesion }
        guard let url = URL(string: sitio + "/api" + ruta) else { throw Fallo.sinRed }
        var req = URLRequest(url: url)
        req.httpMethod = metodo
        req.timeoutInterval = espera
        req.setValue("application/json", forHTTPHeaderField: "content-type")
        req.setValue("Bearer " + vale, forHTTPHeaderField: "authorization")
        if let c = cuerpo { req.httpBody = try? JSONSerialization.data(withJSONObject: c) }

        let datos: Data, resp: URLResponse
        do { (datos, resp) = try await URLSession.shared.data(for: req) }
        catch { throw Fallo.sinRed }

        let estado = (resp as? HTTPURLResponse)?.statusCode ?? 0
        let j = (try? JSONSerialization.jsonObject(with: datos)) as? [String: Any] ?? [:]

        // Un 401 se cuenta: la web tiene que cerrar sesión también, o las dos
        // mitades de la app dirían cosas distintas sobre si estás dentro.
        if estado == 401 {
            await MainActor.run { alCaducar() }
            throw Fallo.sesionCaducada
        }
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
