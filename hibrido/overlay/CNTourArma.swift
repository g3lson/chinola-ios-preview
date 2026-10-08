import Foundation

/**
 * EL RECORRIDO, ARMADO AQUÍ.
 *
 * Son diez globos que Chino cuenta la primera vez, cada uno señalando una cosa
 * de la pantalla con un aro. El aro y los globos ya los dibuja el teléfono; lo
 * que venía de la web era el CONTENIDO —diez títulos y diez párrafos enteros,
 * por el puente, en cada paso— y son datos fijos. Los genera `npm run sync` de
 * `GUIA`, la misma lista que lee la web, y ya están traducidos.
 *
 * LO QUE NO SE ADIVINA, y sin él el globo explica una cosa mientras el aro
 * marca otra: **el «+» flotante no existe en el teléfono.** En la web se anota
 * desde un botón que flota; aquí se anota desde Movimientos o manteniendo
 * pulsada su pestaña. Así que ese paso señala `tab-movs` y su texto es OTRO
 * —el que el catálogo trae como propio del teléfono—.
 *
 * QUIÉN DECIDE QUE EL RECORRIDO ESTÁ ABIERTO SIGUE SIENDO LA WEB: es ella la
 * que lo saca la primera vez y la que recuerda que ya se vio, y eso vive con el
 * resto de los ajustes. Esto es el contenido de cada paso, no cuándo sale.
 */
enum CNTourArma {

    /// Cuántos pasos hay. La web y el teléfono tienen que contar los mismos:
    /// «3 de 10» con una lista de nueve es un paso que nunca llega.
    static var cuantos: Int { CNCatalogos.pasosDelTour.count }

    /// El paso número `i`, o `nil` si no existe —y entonces el recorrido se
    /// acabó, que es lo que hace que el último botón cierre.
    static func paso(_ i: Int) -> CNTour? {
        let g = CNCatalogos.pasosDelTour
        guard i >= 0, i < g.count else { return nil }
        var m = CNTour()
        m.paso = i
        m.total = g.count
        m.vista = g[i].vista
        // EL «+» FLOTANTE NO EXISTE AQUÍ.
        m.ancla = g[i].ancla == "fab" ? "tab-movs" : g[i].ancla
        m.titulo = cnT(g[i].titulo)
        m.texto = cnT(g[i].texto)
        m.animo = g[i].animo
        // «Listo» en el último y «Siguiente» en los demás: un «Siguiente» que
        // cierra deja a quien lo toca esperando otro globo.
        m.textoSiguiente = i + 1 >= g.count ? cnT("Listo") : cnT("Siguiente")
        m.textoSaltar = cnT("Saltar")
        return m
    }
}
