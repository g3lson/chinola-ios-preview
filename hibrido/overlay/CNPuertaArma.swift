import Foundation

/**
 * LAS LÁMINAS DE BIENVENIDA, ARMADAS AQUÍ.
 *
 * Son lo PRIMERO que ve quien instala la app, y viajaban enteras por el
 * puente: tres títulos, tres párrafos y nueve filas con su icono y su color.
 * Mientras la web no arrancaba, esa pantalla estaba en blanco — que es justo
 * la primera impresión que da la app.
 *
 * Son datos fijos y los genera `npm run sync` de la misma lista que lee ella.
 *
 * QUIÉN DECIDE QUÉ PASO SE ENSEÑA SIGUE SIENDO LA WEB: ella lleva la cuenta de
 * por dónde vas, si ya tienes sesión y si el correo está confirmado, y eso no
 * es una pantalla, es el estado de una conversación con el servidor. De su
 * respuesta se lee EN QUÉ lámina estás; lo que dice sale de aquí.
 */
enum CNPuertaArma {

    static var cuantas: Int { CNCatalogos.laminasDeBienvenida.count }

    /**
     * LA PORTADA: la primerísima pantalla, cuatro frases fijas.
     *
     * Es la que más tardaba en aparecer y la única que no se puede saltar: sin
     * la web no había ni título. Lo que lleva encima —el dibujo de Chino— ya lo
     * hace el teléfono desde antes.
     */
    static func portada() -> CNPuerta {
        var m = CNPuerta()
        m.paso = "portada"
        m.titulo = cnT("Tu dinero, sin enredos")
        m.texto = cnT("Soy Chino. Te ayudo a saber en qué se te va la plata y cuánto te queda de verdad.")
        m.boton = cnT("Empezar")
        m.segundo = cnT("Ya tengo cuenta")
        m.animo = "feliz"
        return m
    }

    /**
     * Y LA DE «LISTO», que es la última.
     *
     * Con el nombre si se sabe —y SOLO EL PRIMERO: «¡Listo, Juan Carlos
     * Pérez!» no lo dice nadie—. Y el texto cambia si eligió un plan de pago:
     * se entra con el gratis mientras se activa, y callárselo es dejar a
     * alguien buscando lo que pagó.
     */
    static func listo(_ nombre: String, plan: String) -> CNPuerta {
        var m = CNPuerta()
        m.paso = "listo"
        let suyo = nombre.split(separator: " ").first.map(String.init) ?? ""
        m.titulo = suyo.isEmpty
            ? cnT("¡Listo!")
            : cnT("¡Listo, {n}!").replacingOccurrences(of: "{n}", with: suyo)
        m.texto = (!plan.isEmpty && plan != "gratis")
            ? cnT("Empiezas con el plan gratis mientras activamos el tuyo: te escribimos a tu correo. Si te pierdes, tócame en Perfil.")
            : cnT("Ya puedes anotar lo primero. Si te pierdes, tócame en Perfil y te vuelvo a enseñar la casa.")
        m.boton = cnT("Entrar")
        m.animo = "feliz"
        return m
    }

    /// La lámina número `i`, o `nil` si no existe —y entonces manda la web.
    static func lamina(_ i: Int) -> CNPuerta? {
        let ls = CNCatalogos.laminasDeBienvenida
        guard i >= 0, i < ls.count else { return nil }
        let l = ls[i]
        var m = CNPuerta()
        m.paso = "lamina"
        m.rotulo = cnT(l.rotulo)
        m.titulo = cnT(l.titulo)
        m.texto = cnT(l.texto)
        m.animo = l.animo
        m.indice = i
        m.total = ls.count
        // «Siguiente» EN TODAS, también en la última, y el segundo botón
        // vacío. Es lo que dice la web, y lo que cambia al final no es el
        // rótulo sino a dónde lleva. Poner aquí «Crear mi cuenta» sería
        // cambiar la pantalla en vez de traerla.
        m.boton = cnT("Siguiente")
        m.segundo = ""
        m.atras = ""
        m.volver = "atras"
        m.lista = l.filas.enumerated().map { k, f in
            // EL TONO POR SU NOMBRE: el color de la letra y el del fondo salen
            // del mismo catálogo que usa el resto de la app, así que cambiar
            // un tono lo cambia aquí también.
            let color = CNCatalogos.tonos[f.tono] ?? ""
            return CNPuerta.Punto(id: k, titulo: cnT(f.titulo), pie: cnT(f.pie),
                                  iconoPath: CNCatalogos.iconos[f.icono] ?? "",
                                  color: color,
                                  fondo: CNCuentasFilas.tinte(color, 0.12))
        }
        return m
    }
}
