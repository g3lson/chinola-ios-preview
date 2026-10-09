import Foundation

/**
 * LOS AVISOS DEL SERVIDOR, PEDIDOS AQUÍ.
 *
 * Son las láminas que salen encima de la app —una novedad, un recordatorio de
 * plan, un «se te acaba la prueba»—. Las DIBUJA el teléfono desde hace tiempo,
 * pero el aviso se lo tenía que dar la web: viaja dentro de la respuesta de
 * «quién soy» y ella lo guardaba y se lo pasaba por el puente.
 *
 * El teléfono ya le pregunta «quién soy» al servidor —es lo que llena la
 * pantalla de Mi cuenta—, así que el aviso viene de camino y no hace falta
 * pedirle nada a nadie. Y por el mismo motivo que la web: **el aviso viaja con
 * eso y no en una llamada propia.** Un aviso que retrasa el arranque no lo lee
 * nadie.
 *
 * LO QUE HAY QUE RECORDAR ES CUÁLES YA SE VIERON, y eso es de este lado. El
 * servidor pone sus topes, pero mientras la respuesta de «quién soy» siga
 * trayendo el mismo aviso, volvería a salir en cada arranque: lo que lo evita
 * es decirle que se vio Y apuntarlo aquí, porque la respuesta se guarda en
 * memoria y el próximo arranque la vuelve a pedir igual.
 */
enum CNAvisos {

    /// Los que ya se enseñaron, para no repetirlos. En el teléfono, no en
    /// memoria: lo que se quiere evitar es que vuelva en el próximo arranque.
    private static let llave = "cnAvisosVistos"

    static func yaVisto(_ id: String) -> Bool {
        guard !id.isEmpty else { return true }
        return (UserDefaults.standard.stringArray(forKey: llave) ?? []).contains(id)
    }

    static func apunta(_ id: String) {
        guard !id.isEmpty, !yaVisto(id) else { return }
        var ya = UserDefaults.standard.stringArray(forKey: llave) ?? []
        // Los últimos veinte bastan: la lista no puede crecer para siempre, y
        // un aviso de hace veinte ya no vuelve.
        ya.append(id)
        if ya.count > 20 { ya.removeFirst(ya.count - 20) }
        UserDefaults.standard.set(ya, forKey: llave)
    }

    /**
     * EL AVISO QUE TOCA, SI HAY ALGUNO.
     *
     * `nil` cuando no hay, cuando no hay sesión, o cuando ya se vio. Pide
     * «quién soy» por el camino de siempre, que además lo tiene cacheado para
     * la pantalla de Mi cuenta: entrar en Perfil y abrir un aviso no son dos
     * llamadas.
     */
    @MainActor static func traer() async -> CNAviso? {
        guard CNApi.haySesion else { return nil }
        // SIN `??` CON UN `await` DENTRO: eso no compila, y el error solo sale
        // en el banco. Primero lo que ya se sabe; si no hay, se pregunta.
        var yo = CNSecciones.delServidor["/yo"]
        if yo == nil { yo = await CNApi.intenta("/yo") }
        guard let yo = yo else { return nil }
        CNSecciones.delServidor["/yo"] = yo
        guard let crudo = yo["aviso"] as? [String: Any],
              let d = try? JSONSerialization.data(withJSONObject: crudo),
              let json = String(data: d, encoding: .utf8),
              let a = CNAviso.desde(json: json), !yaVisto(a.id) else { return nil }
        return a
    }

    /// Lo tocó o lo cerró. Se le dice al servidor y se apunta aquí.
    static func responde(_ id: String, _ que: String) {
        apunta(id)
        guard !id.isEmpty, !que.isEmpty else { return }
        let ruta = "/avisos/" + (id.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? id)
            + "/" + (que.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? que)
        Task { _ = await CNApi.intenta(ruta, metodo: "POST") }
    }
}
