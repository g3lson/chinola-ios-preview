import Foundation
import SwiftUI

/**
 * EL TEMA Y LOS AJUSTES, ARMADOS AQUÍ.
 *
 * Era lo que ataba los COLORES de la app a la web: al abrirla, las pantallas
 * nativas salían con los de fábrica hasta que ella arrancaba, calculaba y
 * contestaba. Se ve —el primer momento de la app con otro traje— y, sobre
 * todo, el día que el webview se quite se queda sin colores.
 *
 * Todo lo que hace falta estaba ya escrito en el teléfono:
 *
 *  · **qué tema está puesto** y los demás ajustes, en la copia que la web deja
 *    (`chinola-sesion-v3`, que lleva la sesión Y las preferencias);
 *  · **de qué color es cada tema**, en el catálogo que genera `npm run sync`
 *    del mismo sitio que lo lee ella.
 *
 * TRES COSAS QUE DE MEMORIA SALEN MAL, y las tres se ven:
 *
 *  · **el modo automático no es un tema**: es una pareja. Con «seguir al
 *    teléfono» puesto, el tema que toca es el claro elegido de día y el oscuro
 *    de noche, y lo que hay guardado en `tema` puede ser cualquiera de los dos;
 *  · **el acento no sale de la paleta**, sale del TEMA: el amarillo de la marca
 *    en casi todos, y uno propio en los de color. Sacarlo de la paleta deja la
 *    app entera amarilla con un tema azul;
 *  · **los colores de las cifras sí salen de la paleta** —positivo, negativo,
 *    ahorro y aviso—, que se elige aparte del tema. Son dos ajustes distintos
 *    y mezclarlos hace que cambiar de tema cambie el verde de los ingresos.
 */
enum CNTemaArma {

    /// Los oscuros son los que están al otro lado de alguna pareja.
    static var oscuros: Set<String> { Set(CNCatalogos.oscuroDe.values) }

    /**
     * QUÉ TEMA TOCA AHORA.
     *
     * Sin modo automático, el guardado. Con él, el claro elegido de día y el
     * oscuro de noche; y si no hay pareja guardada, la de la tabla.
     */
    static func cual(_ a: [String: Any], deNoche: Bool) -> String {
        let puesto = (a["tema"] as? String) ?? "chinola"
        guard (a["temaAuto"] as? Bool) ?? false else { return puesto }
        let claroGuardado = (a["temaClaro"] as? String) ?? ""
        let claro = !claroGuardado.isEmpty ? claroGuardado
            : (oscuros.contains(puesto) ? (CNCatalogos.claroDe[puesto] ?? "chinola") : puesto)
        let oscuroGuardado = (a["temaOscuro"] as? String) ?? ""
        let oscuro = !oscuroGuardado.isEmpty ? oscuroGuardado
            : (CNCatalogos.oscuroDe[claro] ?? "noche")
        return deNoche ? oscuro : claro
    }

    /// El amarillo de la marca, que es el acento de casi todos los temas.
    static let amarilloDeLaMarca = "oklch(0.852 0.147 93)"

    /// La paleta de un tema, lista para pintar. `nil` si ese tema no existe:
    /// mejor quedarse con la que hay que pintar la app de un color inventado.
    static func paleta(_ clave: String, paletaId: String) -> CNPaletaTema? {
        guard let t = CNCatalogos.temas[clave] else { return nil }
        var p = CNPaletaTema()
        p.scr = cnColor(hexString: t.bg)
        p.card = cnColor(hexString: t.card)
        p.soft = cnColor(hexString: t.suave)
        p.line = cnColor(hexString: t.borde)
        p.ink = cnColor(hexString: t.tinta)
        p.pmut = cnColor(hexString: t.gris)
        p.side = cnColor(hexString: t.side)
        // EL ACENTO ES DEL TEMA, no de la paleta.
        p.acc = cnColor(hexString: CNCatalogos.acentos[clave] ?? amarilloDeLaMarca)
        // Y LAS CIFRAS SON DE LA PALETA, que se elige aparte.
        let c = CNCatalogos.paletas.first { $0.id == paletaId } ?? CNCatalogos.paletas[0]
        p.pos = cnColor(hexString: c.positivo)
        p.neg = cnColor(hexString: c.negativo)
        p.info = cnColor(hexString: c.ahorro)
        p.oscuro = oscuros.contains(clave)
        return p
    }

    /// Cómo se escribe: la moneda, los centavos, el idioma, la letra y los
    /// cuatro de la cabecera. Son decisiones del usuario y viven con el resto.
    static func formato(_ a: [String: Any]) -> CNFormato {
        var f = CNFormato()
        func s(_ k: String, _ porDefecto: String) -> String {
            let v = (a[k] as? String) ?? ""
            return v.isEmpty ? porDefecto : v
        }
        func b(_ k: String) -> Bool { (a[k] as? Bool) ?? false }
        f.moneda = s("moneda", "DOP")
        f.centavos = b("centavos")
        // El idioma se guarda corto («es») y el formateador quiere la región.
        let idioma = s("idioma", "es")
        f.loc = ["es": "es-DO", "en": "en-US", "fr": "fr-FR"][idioma] ?? "es-DO"
        // Y se recuerda, que es de donde `cnT` saca en qué idioma hablar y
        // tiene que valer también en el primer fotograma del próximo arranque.
        CNTextos.recuerdaIdioma(idioma)
        f.fuente = s("fuente", "sistema")
        f.fuenteTitulo = s("fuenteTitulo", "sistema")
        // LA LETRA: su nombre y CUÁNTO MIDE. La escala sale del catálogo y no
        // de un número guardado: «grande» sin su 1.18 deja toda la app en el
        // tamaño de fábrica con el ajuste puesto.
        f.letraId = s("letra", "normal")
        if let l = CNCatalogos.letras.first(where: { $0.id == f.letraId }) {
            f.letra = CGFloat(l.escala)
        }
        f.cabecera = s("cabecera", "auto")
        f.cabeceraColor = s("cabeceraColor", "")
        f.cabeceraTarjeta = b("cabeceraTarjeta")
        f.cabeceraIntegrada = b("cabeceraIntegrada")
        f.temaAuto = b("temaAuto")
        f.temaId = s("tema", "chinola")
        f.temaClaro = s("temaClaro", "")
        f.temaOscuro = s("temaOscuro", "")
        f.paletaId = s("paleta", "clasica")
        f.iconoApp = s("iconoApp", "")
        f.panelVivo = b("panelVivo")
        f.tarjetaCuentas = s("tarjetaCuentas", "clasica")
        f.colorPatrimonio = s("colorPatrimonio", "tema")
        f.metaPatrimonio = ((a["metaPatrimonio"] as? NSNumber)?.doubleValue) ?? 0
        f.personaje = s("personaje", "auto")
        f.planAro = b("planAro")
        f.planPestanas = s("planPestanas", "pastillas")
        return f
    }
}
