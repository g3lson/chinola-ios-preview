import SwiftUI
import UIKit
import CoreImage

// Pantallas NATIVAS incrustadas en la app Capacitor. La web le pasa el JSON de
// la libreta (el de localStorage) y aquí se decodifica y se dibuja en SwiftUI.
// Todo autocontenido para no chocar con el resto del proyecto (prefijos CN…).

// ── Colores del tema Chinola (mismos valores del diseño) ────────────────────
func cnColor(_ hex: UInt) -> Color {
    Color(.sRGB, red: Double((hex >> 16) & 0xff) / 255, green: Double((hex >> 8) & 0xff) / 255, blue: Double(hex & 0xff) / 255, opacity: 1)
}
/// Los números de dentro de un paréntesis de CSS, en orden. Entiende comas,
/// espacios y la barra del alfa, y devuelve los porcentajes ya en 0…1.
///
/// El texto que llega no siempre es `rgb()`: WebKit devuelve un
/// `color-mix(in oklab, …)` resuelto como `oklab(…)`, y un color de otro
/// espacio como `color(srgb …)`. Leerlos como hexadecimal daba 0 —NEGRO— y de
/// ahí los cuadros de los iconos en negro.
func cnNumerosCSS(_ s: String) -> [(Double, Bool)] {
    let dentro = s.drop(while: { $0 != "(" }).dropFirst()
    var out: [(Double, Bool)] = []
    var actual = ""
    func cierra(_ pct: Bool) {
        if let v = Double(actual) { out.append((v, pct)) }
        actual = ""
    }
    for ch in dentro {
        if ch == ")" { break }
        if ch.isNumber || ch == "." || ch == "-" || ch == "+" { actual.append(ch) }
        else if ch == "%" { cierra(true) }
        else { cierra(false) }
    }
    cierra(false)
    return out
}

/// Lo ya leído, para no volver a leerlo. Un color llega SIEMPRE como texto
/// («#137d41», «rgb(19,125,65)»…) y hay que interpretarlo; pasaba en cada
/// repintado y hay casi cien sitios que lo piden, así que en una lista que
/// rueda eran miles de análisis de texto por segundo.
private let cnColoresLeidos = CNCache<String, Color>(tope: 512)

/// Una memoria pequeña y segura entre hilos, que se vacía si crece de más.
final class CNCache<K: Hashable, V> {
    private var mapa: [K: V] = [:]
    private let tope: Int
    private let cerrojo = NSLock()
    init(tope: Int) { self.tope = tope }
    func valor(_ k: K, _ hacer: () -> V) -> V {
        cerrojo.lock()
        if let v = mapa[k] { cerrojo.unlock(); return v }
        cerrojo.unlock()
        let v = hacer()
        cerrojo.lock()
        if mapa.count >= tope { mapa.removeAll(keepingCapacity: true) }
        mapa[k] = v
        cerrojo.unlock()
        return v
    }
}

/**
 * El camino de vuelta: un color, escrito como texto.
 *
 * Hace falta porque los modelos de las tarjetas llevan los colores como texto
 * —así llegan de la web— y algunas tarjetas se rehacen ya aquí, con colores que
 * solo existen en la paleta (la franja del tema, por ejemplo). Sin esto habría
 * que mandar la paleta otra vez por el puente solo para volver a leerla.
 *
 * Sale en `#rrggbb`, que es lo que `cnColor(hexString:)` lee sin dudar. Se
 * pierde el alfa a propósito: los colores de la paleta son opacos, y un alfa a
 * medias en un texto que luego se vuelve a leer es de donde salen los grises
 * raros.
 */
func cnHexDe(_ c: Color) -> String {
    #if canImport(UIKit)
    var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    guard UIColor(c).getRed(&r, green: &g, blue: &b, alpha: &a) else { return "#000000" }
    let n = { (v: CGFloat) in Int((max(0, min(1, v)) * 255).rounded()) }
    return String(format: "#%02x%02x%02x", n(r), n(g), n(b))
    #else
    return "#000000"
    #endif
}

/**
 * El dibujo de una opción: del paquete o escrito en la propia cadena.
 *
 * La web manda sus muestras como texto en base64 —las rasteriza ella— y las
 * subpantallas que arma el teléfono mandan el NOMBRE de un fichero que ya está
 * dentro de la app. El caso que importa es el del icono de la app: los nueve
 * están en el paquete porque son los que iOS instala, así que se enseña EL
 * MISMO, no una copia. Una copia podría parecerse y no serlo, y eso es
 * exactamente lo que nadie comprobaría: eliges uno y sale otro.
 */
func cnImagenDeOpcion(_ q: String) -> UIImage? {
    // Un base64 de verdad es largo y no tiene nada que hacer como nombre de
    // fichero; se prueba primero el paquete, que es lo barato.
    if !q.contains("/"), q.count < 80, let img = UIImage(named: q) { return img }
    return cnImagenBase64(q)
}

func cnColor(hexString s: String) -> Color {
    cnColoresLeidos.valor(s) { cnColorLeer(s) }
}

private func cnColorLeer(_ s: String) -> Color {
    let t = s.trimmingCharacters(in: .whitespaces).lowercased()
    // «transparent» no es un número hexadecimal: leído como tal daba 0, o sea
    // NEGRO, y el calendario salía con bandas y círculos negros por todos lados.
    if t.isEmpty || t == "transparent" || t == "none" { return .clear }
    if t.hasPrefix("rgb") {
        let n = cnNumerosCSS(t)
        if n.count >= 3 {
            // En rgb() un porcentaje es sobre 255; el alfa, sobre 1.
            func c(_ i: Int) -> Double { n[i].1 ? n[i].0 / 100 : n[i].0 / 255 }
            let a = n.count > 3 ? (n[3].1 ? n[3].0 / 100 : n[3].0) : 1
            return Color(.sRGB, red: c(0), green: c(1), blue: c(2), opacity: a)
        }
        return .clear
    }
    if t.hasPrefix("hsl") {
        let n = cnNumerosCSS(t)
        guard n.count >= 3 else { return .clear }
        return cnDesdeHSL(n[0].0, n[1].0 / 100, n[2].0 / 100,
                          n.count > 3 ? (n[3].1 ? n[3].0 / 100 : n[3].0) : 1)
    }
    // El diseño guarda los colores en oklch(...) (CSS). Se convierten a sRGB para
    // que las cuentas/categorías/metas se vean IGUAL que en la web y no en negro.
    if t.hasPrefix("oklch") { return cnOklch(t) }
    if t.hasPrefix("oklab") {
        let n = cnNumerosCSS(t)
        guard n.count >= 3 else { return .clear }
        // La L puede venir en porcentaje (0…100%) o en 0…1.
        let L = n[0].1 ? n[0].0 / 100 : n[0].0
        let a = n.count > 3 ? (n[3].1 ? n[3].0 / 100 : n[3].0) : 1
        return cnDesdeOklab(L, n[1].0, n[2].0, a)
    }
    // color(srgb r g b / a) y color(display-p3 r g b / a): componentes en 0…1.
    if t.hasPrefix("color(") {
        let dentro = String(t.drop(while: { $0 != "(" }).dropFirst().prefix(while: { $0 != ")" }))
        // Fuera el nombre del espacio antes de leer números: «display-p3» lleva
        // un 3 dentro y se colaba como si fuera el primer componente.
        let trozos = dentro.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
        let resto = trozos.count > 1 ? String(trozos[1]) : dentro
        let n = cnNumerosCSS("(" + resto + ")")
        guard n.count >= 3 else { return .clear }
        func c(_ i: Int) -> Double { min(1, max(0, n[i].1 ? n[i].0 / 100 : n[i].0)) }
        let a = n.count > 3 ? (n[3].1 ? n[3].0 / 100 : n[3].0) : 1
        if t.contains("display-p3") { return cnDesdeP3(c(0), c(1), c(2), a) }
        return Color(.sRGB, red: c(0), green: c(1), blue: c(2), opacity: a)
    }
    var h = t.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
    if h.count == 3 { h = h.map { "\($0)\($0)" }.joined() }
    // #rrggbbaa: el alfa va al final, no en los bits altos.
    if h.count == 8, let v = UInt64(h, radix: 16) {
        return Color(.sRGB, red: Double((v >> 24) & 0xff) / 255, green: Double((v >> 16) & 0xff) / 255,
                     blue: Double((v >> 8) & 0xff) / 255, opacity: Double(v & 0xff) / 255)
    }
    if let v = UInt64(h, radix: 16), h.count == 6 {
        return Color(.sRGB, red: Double((v >> 16) & 0xff) / 255, green: Double((v >> 8) & 0xff) / 255,
                     blue: Double(v & 0xff) / 255, opacity: 1)
    }
    if h == "white" { return .white }
    if h == "black" { return .black }
    // Lo que no se entienda, invisible. Antes salía 0, que es NEGRO, y un
    // color que no se sabe leer se llevaba media pantalla por delante.
    return .clear
}

/// oklab → sRGB (fórmula de Björn Ottosson). El alfa se respeta: un tinte al
/// 14% tiene que llegar al 14%, no opaco.
func cnDesdeOklab(_ L: Double, _ a: Double, _ b: Double, _ alfa: Double) -> Color {
    let l_ = L + 0.3963377774 * a + 0.2158037573 * b
    let m_ = L - 0.1055613458 * a - 0.0638541728 * b
    let s_ = L - 0.0894841775 * a - 1.2914855480 * b
    let l = l_ * l_ * l_, m = m_ * m_ * m_, q = s_ * s_ * s_
    let r =  4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * q
    let g = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * q
    let bl = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * q
    func gam(_ c: Double) -> Double { let x = max(0, c); return x <= 0.0031308 ? 12.92 * x : 1.055 * pow(x, 1 / 2.4) - 0.055 }
    func cl(_ c: Double) -> Double { min(1, max(0, c)) }
    return Color(.sRGB, red: cl(gam(r)), green: cl(gam(g)), blue: cl(gam(bl)),
                 opacity: min(1, max(0, alfa)))
}

/// display-p3 → sRGB, por si algún día un color llega en ese espacio.
func cnDesdeP3(_ r: Double, _ g: Double, _ b: Double, _ alfa: Double) -> Color {
    func lin(_ c: Double) -> Double { c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4) }
    func gam(_ c: Double) -> Double { let x = max(0, c); return x <= 0.0031308 ? 12.92 * x : 1.055 * pow(x, 1 / 2.4) - 0.055 }
    let lr = lin(r), lg = lin(g), lb = lin(b)
    let R =  1.2249401 * lr - 0.2249404 * lg + 0.0000000 * lb
    let G = -0.0420569 * lr + 1.0420571 * lg + 0.0000000 * lb
    let B = -0.0196376 * lr - 0.0786361 * lg + 1.0982735 * lb
    func cl(_ c: Double) -> Double { min(1, max(0, c)) }
    return Color(.sRGB, red: cl(gam(R)), green: cl(gam(G)), blue: cl(gam(B)), opacity: min(1, max(0, alfa)))
}

func cnDesdeHSL(_ h: Double, _ s: Double, _ l: Double, _ alfa: Double) -> Color {
    let c = (1 - abs(2 * l - 1)) * min(1, max(0, s))
    let hp = (h.truncatingRemainder(dividingBy: 360) + 360).truncatingRemainder(dividingBy: 360) / 60
    let x = c * (1 - abs(hp.truncatingRemainder(dividingBy: 2) - 1))
    var r = 0.0, g = 0.0, b = 0.0
    switch Int(hp) {
    case 0: (r, g, b) = (c, x, 0)
    case 1: (r, g, b) = (x, c, 0)
    case 2: (r, g, b) = (0, c, x)
    case 3: (r, g, b) = (0, x, c)
    case 4: (r, g, b) = (x, 0, c)
    default: (r, g, b) = (c, 0, x)
    }
    let m = l - c / 2
    return Color(.sRGB, red: r + m, green: g + m, blue: b + m, opacity: min(1, max(0, alfa)))
}

// oklch(L C H) o oklch(L C H / a) → sRGB.
func cnOklch(_ s: String) -> Color {
    let n = cnNumerosCSS(s)
    guard n.count >= 3 else { return CNC.ink }
    let L = n[0].1 ? n[0].0 / 100 : n[0].0
    let C = n[1].0, hr = n[2].0 * .pi / 180
    let alfa = n.count > 3 ? (n[3].1 ? n[3].0 / 100 : n[3].0) : 1
    return cnDesdeOklab(L, C * cos(hr), C * sin(hr), alfa)
}
/// Lo que decide cómo se ESCRIBE en las pantallas nativas: la moneda, si se
/// enseñan los centavos, el idioma —para los meses y los días— y el tamaño de
/// la letra. Lo elige el usuario en Ajustes y lo manda la web junto al tema;
/// antes el nativo llevaba «RD$», cero decimales y los meses en español a
/// fuego, así que esos tres ajustes no se notaban al salir de la web.
struct CNFormato {
    var moneda = "DOP"
    var centavos = false
    var loc = "es-DO"
    /// La tipografía elegida (su id en la web: sistema, jakarta, nunito…).
    var fuente = "sistema"
    /// Y la de los títulos, que se elige aparte.
    var fuenteTitulo = "sistema"
    /// CUÁL tamaño de letra está puesto («chica», «normal», «grande», «mayor»).
    ///
    /// Aparte de `letra`, que es cuánto mide: la subpantalla tiene que marcar
    /// el elegido, y con la escala sola habría que adivinarlo comparando
    /// números —y dos tamaños con la misma escala se marcarían los dos—.
    var letraId = "normal"
    /// Los cuatro de la cabecera: cuál, de qué color, con esquinas redondeadas
    /// y si toma el fondo de la pantalla. Van con los ajustes y no con el
    /// modelo del Resumen porque ese solo llega estando en el Resumen, y esta
    /// subpantalla se abre desde Perfil.
    var cabecera = "auto"; var cabeceraColor = ""
    var cabeceraTarjeta = false; var cabeceraIntegrada = false
    /// Cuál tema está puesto, y los de día y de noche por separado. No son
    /// siempre el mismo: con «Automático» hay uno para cada momento.
    var temaId = "chinola"; var temaAuto = false
    var temaClaro = ""; var temaOscuro = ""
    var paletaId = "clasica"
    /// Cuál de los nueve iconos de la app está puesto. Vacío = el de fábrica.
    var iconoApp = ""
    /// Qué se ve en la pestaña de Perfil: «chino» o «perfil».
    /// La inicial del usuario, para el icono redondo.
    var inicial = ""
    /// Las tarjetas de cifras del panel, cada una del color de su cifra.
    var panelVivo = false
    /// Qué tarjeta se ve arriba en Cuentas: clasica, apilada, suma, grafica,
    /// chino, bloques… o «ninguna».
    ///
    /// Estos cuatro vivían en @AppStorage, o sea en el teléfono y solo en el
    /// teléfono: no existían en la web ni en la PWA, y no seguían a la persona
    /// de su iPhone a su iPad ni sobrevivían a reinstalar. Ahora los guarda la
    /// web con el resto de ajustes y llegan por aquí, que es el mismo camino
    /// que ya traía el tema y la letra.
    var tarjetaCuentas = "clasica"
    /// A cuánto quiere llegar: lo usa la barra de meta de la tarjeta de Chino.
    var metaPatrimonio: Double = 0
    /// El presupuesto en aro en vez de en barra.
    var planAro = false
    /// Cómo se ven las pestañas del Plan: sistema, subrayado o pastillas.
    var planPestanas = "pastillas"
    /// 1 = el tamaño de siempre. La web usa 1,07 como «Normal», así que se
    /// divide entre eso: lo normal aquí tiene que seguir midiendo lo que medía.
    var letra: CGFloat = 1

    static func desde(_ o: [String: Any]) -> CNFormato {
        var f = CNFormato()
        if let m = o["moneda"] as? String, !m.isEmpty { f.moneda = m }
        if let c = o["centavos"] as? Bool { f.centavos = c }
        if let l = o["loc"] as? String, !l.isEmpty { f.loc = l; CNTextos.recuerdaIdioma(l) }
        if let t = o["fuente"] as? String, !t.isEmpty { f.fuente = t }
        if let t = o["fuenteTitulo"] as? String, !t.isEmpty { f.fuenteTitulo = t }
        if let t = o["letraId"] as? String, !t.isEmpty { f.letraId = t }
        if let t = o["cabecera"] as? String, !t.isEmpty { f.cabecera = t }
        if let t = o["cabeceraColor"] as? String { f.cabeceraColor = t }
        f.cabeceraTarjeta = (o["cabeceraTarjeta"] as? Bool) ?? f.cabeceraTarjeta
        f.cabeceraIntegrada = (o["cabeceraIntegrada"] as? Bool) ?? f.cabeceraIntegrada
        if let t = o["temaId"] as? String, !t.isEmpty { f.temaId = t }
        f.temaAuto = (o["temaAuto"] as? Bool) ?? f.temaAuto
        if let t = o["temaClaro"] as? String { f.temaClaro = t }
        if let t = o["temaOscuro"] as? String { f.temaOscuro = t }
        if let t = o["paletaId"] as? String, !t.isEmpty { f.paletaId = t }
        if let t = o["iconoApp"] as? String { f.iconoApp = t }
        if let t = o["inicial"] as? String { f.inicial = t }
        if let v = o["panelVivo"] as? Bool { f.panelVivo = v }
        if let t = o["tarjetaCuentas"] as? String, !t.isEmpty { f.tarjetaCuentas = t }
        if let e = o["metaPatrimonio"] as? NSNumber { f.metaPatrimonio = e.doubleValue }
        if let v = o["planAro"] as? Bool { f.planAro = v }
        if let t = o["planPestanas"] as? String, !t.isEmpty { f.planPestanas = t }
        if let e = o["letra"] as? NSNumber {
            let v = CGFloat(truncating: e)
            if v > 0.4 && v < 2.5 { f.letra = v }
        }
        return f
    }
}

/**
 * LO QUE ACABAS DE TOCAR, HASTA QUE LA WEB CONFIRME.
 *
 * Aquí estaba lo que hace que Perfil se sienta prestado. El valor que se ve
 * sale SIEMPRE de la web: tocas un interruptor, el aviso cruza el puente, la
 * web cambia su estado, rearma la pantalla entera, la manda de vuelta y
 * entonces —y solo entonces— el interruptor se mueve. Entre medias no pasa
 * nada, y ese hueco es exactamente lo que se nota.
 *
 * Y la decisión de no guardar copia aquí tenía su motivo, que sigue siendo
 * bueno: dos copias del mismo ajuste acaban discrepando y ganando la
 * equivocada. Así que esto no es una segunda copia — es un apunte de lo que
 * acabas de tocar, con hora, que vale UN RATO CORTO:
 *
 * - Mientras vale, manda él: el control se mueve en el mismo fotograma.
 * - En cuanto la web manda un valor, manda la web y el apunte se tira. No hay
 *   nada que pueda quedarse discrepando.
 * - Y si la web no contesta —porque rechazó el cambio, o se cayó—, el apunte
 *   caduca solo y el control vuelve a lo que de verdad hay. Mejor que se
 *   deshaga a la vista que quedarse mintiendo.
 *
 * Un segundo y medio es de sobra: el viaje real son decenas de milisegundos.
 */
enum CNRecienTocado {
    private static var apuntes: [String: (valor: Any, cuando: Date)] = [:]
    /// Cuánto vale un apunte sin confirmar.
    private static let dura: TimeInterval = 1.5

    /// Apunta lo que se acaba de tocar.
    static func pon(_ clave: String, _ valor: Any) {
        apuntes[clave] = (valor, Date())
    }

    /// Lo apuntado, si todavía vale. `nil` = manda lo que diga la web.
    static func de<T>(_ clave: String, _ tipo: T.Type) -> T? {
        guard let a = apuntes[clave] else { return nil }
        if Date().timeIntervalSince(a.cuando) > dura { apuntes.removeValue(forKey: clave); return nil }
        return a.valor as? T
    }

    /// La web mandó lo suyo: a partir de aquí manda ella.
    static func confirma(_ clave: String) { apuntes.removeValue(forKey: clave) }

    /// Llegó una pantalla nueva entera: todo lo apuntado queda confirmado.
    static func llegoLaPantalla() { apuntes.removeAll() }
}

/// Un ajuste de pantalla como Binding, para que los Picker sigan siendo Picker.
///
/// Lee del formato que manda la web y escribe de vuelta por el puente. El valor
/// que se ve es siempre el de la web: no se guarda una copia aquí que luego
/// discrepe de la del navegador.
/// `Equatable` a propósito: sin comparar, SwiftUI vuelve a llamar al `set`
/// cuando el valor de la web llega y coincide, y se escribe por el puente otra
/// vez para nada. Con un interruptor que dispara una ACCIÓN eso es peor que un
/// desperdicio: la deshace. Ver la prueba `interruptores-nativos`.
func cnAjuste<T: Equatable>(_ clave: String, _ leer: @escaping () -> T, _ aJS: @escaping (T) -> Any) -> Binding<T> {
    Binding(
        // Lo que acabas de tocar manda mientras la web no diga lo suyo: sin
        // esto el control no se mueve hasta que vuelve del puente.
        get: { CNRecienTocado.de(clave, T.self) ?? leer() },
        set: { nuevo in
            guard nuevo != (CNRecienTocado.de(clave, T.self) ?? leer()) else { return }
            CNRecienTocado.pon(clave, nuevo)
            CNC.alPoner?(clave, aJS(nuevo))
        })
}

/// Un tamaño de letra del diseño, ya escalado por el ajuste del usuario.
func cnPt(_ v: CGFloat) -> CGFloat { v * CNC.fmt.letra }

/// Los textos que se escriben DENTRO de lo nativo —los que no vienen en ningún
/// modelo: los títulos de las pantallas, los rótulos de los formularios, el
/// menú—. La web los traduce con su mismo diccionario y los manda junto al
/// tema; en español el mapa va vacío y esto devuelve lo que se le pasa.
///
/// Se escriben SIEMPRE en español en el código: así lo que se lee aquí es lo
/// que se ve, y `sync` comprueba que cada uno tenga traducción.
enum CNTextos {
    /// Lo que manda la web por el puente. Manda por encima de lo generado: si
    /// algún día la web sabe un texto que el teléfono no, gana el suyo.
    static var mapa: [String: String] = [:]

    /**
     * EN QUÉ IDIOMA ESTÁ LA APP, sabido por el teléfono solo.
     *
     * Hasta ahora esto lo decía la web, así que al abrir la app en inglés las
     * pantallas nativas salían en español hasta que la web arrancaba. Y era una
     * atadura: el día que el webview se quite, lo nativo se queda sin idioma.
     *
     * Primero el que la web haya dicho la última vez —que es el que la persona
     * eligió y puede no ser el del teléfono—, y si no hay, el del teléfono.
     */
    static var idioma: String {
        let guardado = UserDefaults.standard.string(forKey: "cnIdioma") ?? ""
        if !guardado.isEmpty { return guardado }
        return String((Locale.preferredLanguages.first ?? "es").prefix(2))
    }

    /// Se recuerda para el próximo arranque, que es cuando hace falta.
    static func recuerdaIdioma(_ loc: String) {
        let corto = String(loc.prefix(2))
        guard !corto.isEmpty else { return }
        UserDefaults.standard.set(corto, forKey: "cnIdioma")
    }
}

/// El texto en el idioma puesto: lo que mandó la web, y si no, la tabla
/// generada del mismo diccionario. En español los dos sobran: el propio Swift
/// está escrito en español.
/**
 * UN MONTO ESCRITO A MANO, LEÍDO SIEMPRE IGUAL.
 *
 * La misma cuenta estaba escrita de dos maneras en la misma pantalla: el campo
 * del monto quitaba las comas antes de leer el número —para que los botones − y
 * + funcionaran con «50,000»— y el guardado hacía `Double(texto)` a secas, que
 * con una coma dentro devuelve nada y se queda en CERO.
 *
 * O sea: escribías 50,000 de saldo, la pantalla te enseñaba 50,000, y se
 * guardaba una cuenta con cero. Sin aviso, porque `?? 0` no es un error.
 */
/**
 * DE DÓNDE SALE EL DINERO CUANDO NO SE DICE.
 *
 * La predeterminada que marcaste, y la primera cuenta solo si no hay ninguna.
 * Estaba escrito tres veces —el formulario del movimiento, la hoja de monto y
 * `CNEscribir`— y las tres daban la primera cuenta: marcabas una como
 * predeterminada y el teléfono seguía sacando el dinero de la otra.
 *
 * Se comprueba que la marcada EXISTA: si se borró esa cuenta y quedó la marca,
 * apuntaría a una que ya no está.
 */
func cnMedioPorDefecto(_ l: CNLibreta) -> String {
    let pred = l.medioPorDefecto
    if pred.hasPrefix("cuenta:"), let id = Int(pred.dropFirst(7)),
       l.cuentas.contains(where: { $0.id == id }) { return pred }
    return l.cuentas.first.map { "cuenta:\($0.id)" } ?? "efectivo"
}

func cnMonto(_ texto: String) -> Double {
    Double(texto.replacingOccurrences(of: ",", with: "")) ?? 0
}

func cnT(_ es: String) -> String {
    CNTextos.mapa[es] ?? CNTextosGenerados.de(CNTextos.idioma)[es] ?? es
}
/// Como `cnT`, pero con un hueco: cnT("Presupuesto de {n}", nombre).
func cnT(_ es: String, _ hueco: String) -> String {
    cnT(es).replacingOccurrences(of: "{n}", with: hueco)
}

/// Las tipografías de la marca, dentro del paquete.
///
/// La web las usa en .woff2, que CoreText no lee; en `ios/App/App/Fuentes/` van
/// las MISMAS familias en .ttf variable (un archivo por familia, de la fina a
/// la negra) y aquí se registran al arrancar. Sin esto, elegir «Plus Jakarta»
/// o «Nunito» no cambiaba nada en las pantallas nativas.
enum CNFuentes {
    /// id del ajuste → nombre de la familia ya dentro del sistema.
    static let familias: [String: String] = [
        "jakarta": "Plus Jakarta Sans", "inter": "Inter", "outfit": "Outfit",
        "nunito": "Nunito", "bricolage": "Bricolage Grotesque",
        "atkinson": "Atkinson Hyperlegible Next", "source": "Source Serif 4",
        "lora": "Lora", "fraunces": "Fraunces", "jetbrains": "JetBrains Mono"
    ]
    private static var registradas = false
    static func registrar() {
        guard !registradas else { return }
        registradas = true
        guard let dir = Bundle.main.url(forResource: "Fuentes", withExtension: nil),
              let archivos = try? FileManager.default.contentsOfDirectory(
                at: dir, includingPropertiesForKeys: nil) else { return }
        for f in archivos where f.pathExtension.lowercased() == "ttf" {
            CTFontManagerRegisterFontsForURL(f as CFURL, .process, nil)
        }
    }
    /// Son VARIABLES: sin pedirle el peso al eje «wght», Outfit sale finísima y
    /// Bricolage negrísima (su cara por defecto). Y se guarda lo ya construido,
    /// que esto se llama en cada texto de cada pintado.
    private static var cache: [String: UIFont] = [:]
    static func fuente(_ familia: String, _ tam: CGFloat, _ peso: CGFloat) -> UIFont {
        let clave = familia + "|" + String(format: "%.1f|%.0f", tam, peso)
        if let f = cache[clave] { return f }
        let eje = UIFontDescriptor.AttributeName(rawValue: kCTFontVariationAttribute as String)
        let desc = UIFontDescriptor(fontAttributes: [
            .family: familia,
            eje: [2003265652: peso]        // 'wght'
        ])
        let f = UIFont(descriptor: desc, size: tam)
        cache[clave] = f
        return f
    }
    static func numero(_ p: Font.Weight) -> CGFloat {
        if p == .ultraLight { return 100 }
        if p == .thin { return 200 }
        if p == .light { return 300 }
        if p == .medium { return 500 }
        if p == .semibold { return 600 }
        if p == .bold { return 700 }
        if p == .heavy { return 800 }
        if p == .black { return 900 }
        return 400
    }
}

/// La letra de un texto nativo: la del sistema, o la tipografía elegida si es
/// una de las que viajan en el paquete. Ya escalada por el ajuste de tamaño.
func cnLetra(_ tam: CGFloat, _ peso: Font.Weight = .regular) -> Font {
    let t = cnPt(tam)
    guard let familia = CNFuentes.familias[CNC.fmt.fuente] else {
        return .system(size: t, weight: peso, design: cnDiseno)
    }
    return Font(CNFuentes.fuente(familia, t, CNFuentes.numero(peso)))
}

/// Lo mismo para UIKit (el menú de abajo).
func cnUIFuente(_ tam: CGFloat, _ peso: UIFont.Weight) -> UIFont {
    let t = cnPt(tam)
    guard let familia = CNFuentes.familias[CNC.fmt.fuente] else {
        return UIFont.systemFont(ofSize: t, weight: peso)
    }
    return CNFuentes.fuente(familia, t, peso.rawValue >= 0.5 ? 800 : (peso.rawValue >= 0.3 ? 700 : (peso.rawValue >= 0.2 ? 600 : 400)))
}

/// La forma de la letra que más se parece a la tipografía elegida en Ajustes.
///
/// Las de la marca son archivos .woff2 (Plus Jakarta, Inter, Outfit…) y iOS
/// nativo no los lee, así que aquí se traduce la elección a lo que SÍ trae el
/// sistema: redondeada, con serifa, de ancho fijo o la normal. No es la misma
/// letra, pero la elección se nota.
var cnDiseno: Font.Design {
    switch CNC.fmt.fuente {
    case "nunito": return .rounded
    case "source", "serif", "lora", "merriweather": return .serif
    case "mono", "jetbrains", "space": return .monospaced
    default: return .default
    }
}

/// El símbolo de la moneda puesta: «RD$», «$», «€»… Estaba escrito a mano en
/// los campos de monto, así que cambiar de moneda dejaba el «RD$» delante.
var cnSimboloMoneda: String {
    CNFormateadores.dinero.currencySymbol ?? "$"
}

/// La paleta del tema que tiene puesto el usuario. La web tiene 31 temas y los
/// pinta con variables CSS; el nativo los recibe por `__chinolaTemaJSON` y los
/// guarda aquí, para que las pantallas nativas cambien de color con la app.
/**
 * EL AVISO DE QUE LA APP NO ARRANCÓ.
 *
 * Las pantallas nativas van ENCIMA del webview, así que un cartel de error
 * dibujado por la web queda debajo y no se ve: la app se queda en blanco y
 * nadie sabe por qué. Esto lo enseña desde aquí, por encima de todo, y se
 * puede leer y copiar.
 *
 * Dos maneras de llegar aquí:
 *
 *   · La web dice que reventó, por `Nativo.fallo({ texto })`.
 *   · La web no dice NADA en diez segundos. El primer tema que manda es la
 *     señal de que arrancó; si no llega, es que no arrancó —o que ni siquiera
 *     llegó a cargar su código, que es cuando su propio cartel tampoco sale—.
 */
final class CNAvisoDeFallo {
    static let shared = CNAvisoDeFallo()
    private var contesto = false
    private var puesto = false
    private var reloj: Timer?
    /// Le pregunta al webview qué tiene cargado. Lo pone el controlador, que es
    /// quien lo tiene a mano. Sin esto el aviso solo puede decir «no contestó»,
    /// que es verdad pero no dice por qué.
    var estadoDeLaWeb: ((@escaping (String) -> Void) -> Void)?
    /// Cuántas veces se ha dado más tiempo. Ver `vigilar`.
    private var esperas = 0
    /// ¿Se pintó la app? Lo pone el controlador, igual que el anterior.
    ///
    /// La señal que apaga el vigía es el primer tema, y ese lo manda la app ya
    /// montada. Si el puente tarda o el plugin no contesta, la app puede estar
    /// perfectamente pintada y el cartel sale igual, a pantalla completa y por
    /// encima: un fallo inventado tapando una app que va. Antes de dar la cara,
    /// se mira.
    var laWebSePinto: ((@escaping (Bool) -> Void) -> Void)?

    /// Arranca el vigía. Lo llama el controlador al montar.
    func vigilar() {
        reloj?.invalidate()
        reloj = Timer.scheduledTimer(withTimeInterval: 15, repeats: false) { [weak self] _ in
            guard let s = self, !s.contesto else { return }
            let cabecera = "La parte web de la app no llegó a arrancar: no mandó señal en quince segundos.\n\n"
            // Antes de enseñarlo, se le pregunta al webview qué tiene dentro:
            // si cargó su página, en qué estado está y cuántos scripts ve. Eso
            // distingue «no cargó nada» de «cargó y su código falló».
            guard let preguntar = s.estadoDeLaWeb else {
                s.mostrar(cabecera + "No se pudo mirar qué tiene cargado el webview.")
                return
            }
            preguntar { detalle in
                guard let mirar = s.laWebSePinto else {
                    s.mostrar(cabecera + "Lo que ve el webview:\n" + detalle)
                    return
                }
                mirar { pintada in
                    if pintada { s.laWebContesto(); return }   // va: no estorbar
                    // NI SIQUIERA HA CARGADO LA PÁGINA: no es un fallo, es que
                    // va lenta. Pasa en el primer arranque después de instalar
                    // —el webview sigue en `about:blank` y no hay ni un script
                    // que contar—, y dar ahí el cartel es acusar a una app que
                    // todavía no existe. Se le dan dos plazos más.
                    if detalle.contains("about:blank") || detalle.contains("raiz: no"), s.esperas < 2 {
                        s.esperas += 1
                        NSLog("CNVIGIA: la web aún no ha cargado; otro plazo (\(s.esperas) de 2)")
                        s.vigilar()
                        return
                    }
                    s.mostrar(cabecera + "Lo que ve el webview:\n" + detalle)
                }
            }
        }
    }

    func laWebContesto() {
        contesto = true
        reloj?.invalidate()
        reloj = nil
    }

    func mostrar(_ texto: String) {
        guard !puesto else { return }          // uno basta; el segundo taparía al primero
        puesto = true
        /*
         DICHO EN VOZ ALTA, SIEMPRE.
         
         Esto solo se veía MIRANDO LA PANTALLA. En el banco, una caída que
         tumbaba la app entera pasaba por «esta subpantalla la armó la web» —que
         es verdad: la armó la web porque la app estaba muerta— y nadie la
         miraba dos veces. Se encontró de casualidad, abriendo una foto.
         
         Un fallo que solo se ve en una foto es un fallo que no se ve.
         */
        NSLog("CNFALLO: la web se cayó · %@", texto.replacingOccurrences(of: "\n", with: " | "))
        reloj?.invalidate()
        guard let raiz = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
            .first?.rootViewController else { return }
        var arriba = raiz
        while let otro = arriba.presentedViewController { arriba = otro }

        var vista: UIHostingController<CNPantallaDeFallo>!
        vista = UIHostingController(rootView: CNPantallaDeFallo(texto: texto, alCerrar: { [weak self] in
            vista?.dismiss(animated: true)
            self?.puesto = false
        }))
        vista.modalPresentationStyle = .fullScreen
        arriba.present(vista, animated: false)
    }
}

/// El cartel, con el texto seleccionable para poder copiarlo o fotografiarlo.
struct CNPantallaDeFallo: View {
    let texto: String
    /// Se puede cerrar: si alguna vez saltara de más —un teléfono lento que
    /// tarda más de la cuenta en arrancar—, un cartel a pantalla completa sin
    /// salida sería peor que el fallo que intenta contar.
    var alCerrar: () -> Void = {}
    private var version: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"
        return v + " (" + b + ")"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Chinola no pudo abrir")
                    .font(.system(size: 22, weight: .heavy))
                Text("Esto es un fallo nuestro, no tuyo. Mándanos esta pantalla y lo arreglamos; "
                     + "tus datos siguen guardados en el teléfono.")
                    .font(.system(size: 14)).foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(texto)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(Color(red: 0.55, green: 0.17, blue: 0.13))
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                Text("Versión " + version + " · iOS " + UIDevice.current.systemVersion
                     + " · " + UIDevice.current.model)
                    .font(.system(size: 12)).foregroundColor(.secondary)
                Button(action: alCerrar) {
                    Text("Cerrar y seguir")
                        .font(.system(size: 15, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 13))
                }
                .padding(.top, 4)
                Spacer(minLength: 0)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
    }
}

struct CNPaletaTema {
    // De fábrica, los grises de iOS: los mismos que usan Ajustes y el resto del
    // teléfono, con el verde y el amarillo de Chinola solo donde hacen falta.
    // Antes era un crema propio, y la app se veía como algo pegado encima del
    // sistema en vez de parte de él. Es solo el punto de partida: el tema que
    // el usuario elija en Ajustes llega de la web y pisa esto.
    var scr  = cnColor(0xf0f0f3)
    var card = cnColor(0xffffff)
    var soft = cnColor(0xe6e6e9)
    var line = cnColor(0xd4d4d7)
    var ink  = cnColor(0x1a1a1c)
    var pmut = cnColor(0x6b6b6f)
    var acc  = cnColor(0xfbd530)
    var side = cnColor(0x064425)      // la franja de la cabecera
    var pos  = cnColor(0x137d41)
    var neg  = cnColor(0xd55948)
    var info = cnColor(0x398ad6)
    var oscuro = false

    /// La misma paleta con los colores de OTRO tema encima: los semánticos
    /// (positivo, negativo, acento…) no cambian de un tema a su pareja.
    static func pintada(_ o: [String: Any]?, base: CNPaletaTema) -> CNPaletaTema? {
        guard let o = o else { return nil }
        var p = base
        func col(_ k: String, _ destino: inout Color) {
            if let v = o[k] as? String, !v.isEmpty, !v.contains("var(") { destino = cnColor(hexString: v) }
        }
        col("bg", &p.scr); col("card", &p.card); col("suave", &p.soft); col("borde", &p.line)
        col("tinta", &p.ink); col("gris", &p.pmut); col("side", &p.side)
        p.oscuro = (o["oscuro"] as? Bool) ?? false
        return p
    }

    /// Del JSON que manda la web: { bg, card, suave, borde, tinta, gris, side,
    /// acento, pos, neg, oscuro }. Lo que falte se queda como está.
    static func desde(json: String) -> CNPaletaTema? {
        guard let d = json.data(using: .utf8),
              let o = (try? JSONSerialization.jsonObject(with: d)) as? [String: Any] else { return nil }
        var p = CNPaletaTema()
        func col(_ k: String, _ destino: inout Color) {
            if let v = o[k] as? String, !v.isEmpty, !v.contains("var(") { destino = cnColor(hexString: v) }
        }
        col("bg", &p.scr); col("card", &p.card); col("suave", &p.soft); col("borde", &p.line)
        col("tinta", &p.ink); col("gris", &p.pmut); col("side", &p.side); col("acento", &p.acc)
        col("pos", &p.pos); col("neg", &p.neg); col("info", &p.info)
        p.oscuro = (o["oscuro"] as? Bool) ?? false
        // Las dos paletas del modo automático: con ellas el cambio de claro a
        // oscuro del teléfono se ve AL INSTANTE, sin esperar a la web.
        if let par = o["pareja"] as? [String: Any] {
            CNC.pareja = (CNPaletaTema.pintada(par["claro"] as? [String: Any], base: p),
                          CNPaletaTema.pintada(par["oscuro"] as? [String: Any], base: p))
        } else {
            CNC.pareja = (nil, nil)
        }
        // La moneda, los centavos, el idioma y la letra vienen en el mismo
        // paquete: es lo que decide cómo se escribe, y cambia con los mismos
        // ajustes que el tema.
        CNC.fmt = CNFormato.desde(o)
        if let t = o["textos"] as? [String: String] { CNTextos.mapa = t }
        // Los nombres del menú llegan también por aquí: la llamada suelta del
        // plugin se podía perder y el ajuste se quedaba sin efecto.
        if let mt = o["menuTitulos"] as? Bool { CNMenuEstado.shared.titulos = mt }
        return p
    }
}

/// Los colores, siempre leídos del tema puesto (por eso son `var` calculadas:
/// al cambiar el tema, el siguiente dibujo ya sale del color nuevo).
enum CNC {
    static var tema = CNPaletaTema()
    static var fmt = CNFormato()
    /// Guardar un ajuste de pantalla. Lo pone el controlador y acaba en
    /// `window.__chinolaPon`, que es quien lo escribe donde se guarda todo lo
    /// demás. Antes estos ajustes eran @AppStorage y por eso solo existían en
    /// este teléfono: ni en la web, ni en la PWA, ni en el otro aparato.
    static var alPoner: ((String, Any) -> Void)?
    /// Las paletas de día y de noche cuando se sigue al teléfono.
    static var pareja: (claro: CNPaletaTema?, oscuro: CNPaletaTema?) = (nil, nil)
    static var scr: Color  { tema.scr }
    static var card: Color { tema.card }
    static var soft: Color { tema.soft }
    static var line: Color { tema.line }
    static var ink: Color  { tema.ink }
    static var pmut: Color { tema.pmut }
    static var acc: Color  { tema.acc }
    /**
     * Los mismos colores, ESCRITOS COMO TEXTO.
     *
     * Las miniaturas de la cabecera y de los temas llevan sus colores en un
     * modelo que los guarda como cadenas —porque así llegan de la web— y las
     * subpantallas que arma el teléfono los tienen como `Color`. Esto es el
     * puente entre las dos formas, en un sitio y no repetido en cada uno que lo
     * necesite.
     */
    static var hexScr: String  { cnHexDe(scr) }
    static var hexCard: String { cnHexDe(card) }
    static var hexSoft: String { cnHexDe(soft) }
    static var hexSide: String { cnHexDe(tema.side) }
    static var side: Color { tema.side }
    static var pos: Color  { tema.pos }
    static var neg: Color  { tema.neg }
    static var info: Color { tema.info }
    /// Lo que se escribe ENCIMA del acento (el amarillo de la marca pide tinta
    /// oscura; un acento oscuro pide tinta clara).
    static var sobreAcc: Color { cnSobre(tema.acc) }
}

/// La tinta que se lee encima de un color: oscura sobre claro y al revés.
func cnSobre(_ c: Color) -> Color { cnClaro(c) ? cnColor(0x20180a) : .white }

/// El difuminado de arriba: lo que sube por detrás de la hora y la batería se
/// va desvaneciendo en vez de cruzarlas a la vista, como en las apps de Apple.
///
/// No es una franja opaca: es vidrio con una máscara en degradado, así que
/// arriba tapa del todo y abajo no se nota dónde acaba.
struct CNDifuminadoArriba: View {
    var extra: CGFloat = 10
    var body: some View {
        ZStack {
            Rectangle().fill(.ultraThinMaterial)
            // Un velo ligero: lo que manda es el desenfoque. Con el velo al
            // 82 % era una franja del color de la pantalla, no un difuminado.
            Rectangle().fill(CNC.scr.opacity(0.42))
        }
        .mask(
            LinearGradient(stops: [.init(color: .black, location: 0),
                                   .init(color: .black, location: 0.55),
                                   .init(color: .black.opacity(0.6), location: 0.8),
                                   .init(color: .clear, location: 1)],
                           startPoint: .top, endPoint: .bottom)
        )
        .frame(height: max(0, cnMargenArriba() + extra))
        .frame(maxWidth: .infinity, alignment: .top)
        .ignoresSafeArea(edges: .top)
        .allowsHitTesting(false)
    }
}

/// El velo que va DETRÁS de la fila del buscador cuando se queda fija.
///
/// El degradado de arriba no puede bajar más: pintaría por encima de la propia
/// cápsula. Así que la fila lleva el suyo por debajo —material y un velo del
/// color de la pantalla que se apaga hacia abajo—, y entre los dos el contenido
/// se desvanece desde el reloj hasta el final del buscador, sin franja ni corte.
struct CNVeloFila: View {
    var body: some View {
        ZStack {
            Rectangle().fill(.ultraThinMaterial)
            Rectangle().fill(CNC.scr.opacity(0.62))
        }
        .mask(
            LinearGradient(stops: [.init(color: .black, location: 0),
                                   .init(color: .black.opacity(0.85), location: 0.55),
                                   .init(color: .clear, location: 1)],
                           startPoint: .top, endPoint: .bottom)
        )
        .ignoresSafeArea(edges: .top)
        .allowsHitTesting(false)
    }
}

/// El margen seguro de abajo (34 con indicador de inicio, 0 con botón).
func cnMargenAbajo() -> CGFloat {
    let escenas = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    let ventana = escenas.flatMap { $0.windows }.first { $0.isKeyWindow } ?? escenas.first?.windows.first
    return ventana?.safeAreaInsets.bottom ?? 0
}

/// El margen seguro de arriba del aparato (59 pt con isla, 47 con muesca).
/// Las esquinas de la pantalla del aparato (0 en los de esquinas rectas).
/// Se usa para que una pantalla que entra o sale lleve el mismo redondeo que
/// el cristal, como las del sistema.
func cnRadioPantalla() -> CGFloat {
    let s = UIScreen.main
    guard s.responds(to: Selector(("_displayCornerRadius"))) else { return 0 }
    return (s.value(forKey: "_displayCornerRadius") as? CGFloat) ?? 0
}

/// Los nombres de las categorías de fábrica, para que el diccionario los tenga:
/// se guardan en español en la libreta y se enseñan en el idioma de la app.
let CN_CATEGORIAS_BASE = [cnT("Ingresos"), cnT("Vivienda"), cnT("Alimentación"), cnT("Servicios"), cnT("Transporte"),
                          cnT("Educación"), cnT("Salud"), cnT("Donaciones"), cnT("Entretenimiento"), cnT("Deudas"),
                          cnT("Personal"), cnT("Ahorro"), cnT("Otros")]

/// A qué altura empieza la cabecera de una pantalla.
///
/// El margen seguro de un iPhone con isla es más alto que la isla: hay unos
/// diez puntos por debajo que el sistema reserva y nadie usa. Esto los sube.
/// Estaba escrito en la cabecera del resumen y la barra de organizar llevaba
/// otra cuenta distinta, veinticuatro puntos más abajo: al entrar en organizar
/// el título daba un salto.
func cnArribaDeLaCabecera() -> CGFloat {
    2 - max(0, cnMargenArriba() - 56)
}

func cnMargenArriba() -> CGFloat {
    let escenas = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    let ventana = escenas.flatMap { $0.windows }.first { $0.isKeyWindow } ?? escenas.first?.windows.first
    return ventana?.safeAreaInsets.top ?? 47
}

/// ¿Este color es claro? (luminancia relativa, como hace la web en color.js)
func cnClaro(_ c: Color) -> Bool {
    let u = UIColor(c); var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    u.getRed(&r, green: &g, blue: &b, alpha: &a)
    return (0.299 * r + 0.587 * g + 0.114 * b) > 0.6
}

// ── Modelos (tolerantes: campos faltantes toman un valor por defecto) ───────
struct CNCuenta: Decodable, Identifiable { var id: Int = 0; var nombre: String = ""; var banco: String = ""; var saldo: Double = 0; var color: String = "#137d41"; var clase: String = ""; var icono: String = ""
    /**
     * LA CLASE, CON SU RELLENO APARTE.
     *
     * `clase` guarda lo que de verdad viene, que puede ser nada. El «banco»
     * de relleno es `claseParaAgrupar`, y se usa donde hace falta repartir las
     * cuentas en grupos: una cuenta sin clase se gasta, como la del banco.
     *
     * Estaban fundidos —`clase` salía «banco» cuando no venía ninguna— y así
     * no hay manera de saber si alguien la eligió. El icono sí lo necesita:
     * sin clase guardada se adivina por el nombre, y «Ahorros» lleva hucha.
     * Con el relleno por delante, las tres cuentas del banco de pruebas
     * salieron con el icono del banco tres fotos seguidas.
     *
     * Es el fallo de siempre aquí: un valor por defecto que se traga lo que no
     * encaja. No falla; miente.
     */
    var claseParaAgrupar: String { clase.isEmpty ? "banco" : clase }
    /// Uno vacío, para armarlo a mano: con `init(from:)` escrito, Swift ya no
    /// regala el de por defecto.
    init() {}
    init(from d: Decoder) throws { let c = try d.container(keyedBy: K.self)
        id = (try? c.decodeIfPresent(Int.self, forKey: .id)) ?? 0
        nombre = (try? c.decodeIfPresent(String.self, forKey: .nombre)) ?? ""
        banco = (try? c.decodeIfPresent(String.self, forKey: .banco)) ?? ""
        saldo = (try? c.decodeIfPresent(Double.self, forKey: .saldo)) ?? 0
        color = (try? c.decodeIfPresent(String.self, forKey: .color)) ?? "#137d41"
        clase = (try? c.decodeIfPresent(String.self, forKey: .clase)) ?? ""
        icono = (try? c.decodeIfPresent(String.self, forKey: .icono)) ?? "" }
    enum K: String, CodingKey { case id, nombre, banco, saldo, color, clase, icono } }

/// Ojo con `tipo` y `limite`: la web NO los manda. Lo que manda es `ingreso`
/// —si la categoría es de entradas— y el presupuesto va aparte, en
/// `CNLibreta.presupuesto`. Los dos campos se quedan porque hay código que los
/// nombra, pero salen siempre "Gasto" y 0: no te fíes de ellos.
/// El icono y el color van VACÍOS por defecto, y eso es la regla, no un
/// descuido: «vacío» significa «no lo eligió nadie», y entonces manda la tabla
/// —`CNCategorias`— igual que en la web.
///
/// Antes el icono nacía como «tag.fill», un nombre de SF Symbol de cuando no
/// existía el catálogo de glifos. Como no está vacío, `CNCategorias.icono` lo
/// daba por elegido y devolvía «tag.fill» para TODAS las categorías a las que
/// nadie les había puesto uno a mano; y como «tag.fill» tampoco está en el
/// catálogo, lo que se pintaba era un hueco. El color hacía lo mismo con un
/// ámbar: todas las categorías sin color propio salían ámbar en el teléfono y
/// grises en la web. Lo encontró el fichero de oro.
struct CNCategoria: Decodable, Identifiable {
    /// El identificador que le pone la web. No se leía, y eso deja al teléfono
    /// sin manera de distinguir dos categorías que se llamen igual —el mismo
    /// fallo que tenía el total de las cuentas—; además, sin él no se puede
    /// editar una: hay que saber CUÁL.
    var id: Int = 0
    var nombre: String = ""; var tipo: String = "Gasto"; var limite: Double = 0; var ingreso: Bool = false; var color: String = ""; var icono: String = ""
    /// Uno vacío, para armarlo a mano: con `init(from:)` escrito, Swift ya no
    /// regala el de por defecto.
    init() {}
    init(from d: Decoder) throws { let c = try d.container(keyedBy: K.self)
        id = (try? c.decodeIfPresent(Int.self, forKey: .id)) ?? 0
        nombre = (try? c.decodeIfPresent(String.self, forKey: .nombre)) ?? ""
        tipo = (try? c.decodeIfPresent(String.self, forKey: .tipo)) ?? "Gasto"
        limite = (try? c.decodeIfPresent(Double.self, forKey: .limite)) ?? 0
        ingreso = (try? c.decodeIfPresent(Bool.self, forKey: .ingreso)) ?? false
        color = (try? c.decodeIfPresent(String.self, forKey: .color)) ?? ""
        icono = (try? c.decodeIfPresent(String.self, forKey: .icono)) ?? "" }
    enum K: String, CodingKey { case id, nombre, tipo, limite, ingreso, color, icono } }

struct CNTarjeta: Decodable, Identifiable { var id: Int = 0; var nombre: String = ""; var banco: String = ""; var saldo: Double = 0; var limite: Double = 0; var corte: Int = 0; var pago: Int = 0; var color: String = "#d55948"
    /// Los cuatro dígitos del final. No se piden ni se usan para nada:
    /// salen dibujados en la tarjeta. Se leen SOLO para no perderlos al
    /// reescribir la libreta —un campo que no se decodifica desaparece en
    /// silencio la primera vez que el teléfono toca esa tarjeta—.
    var last4: String = ""
    /// Uno vacío, para armarlo a mano: con `init(from:)` escrito, Swift ya no
    /// regala el de por defecto.
    init() {}
    init(from d: Decoder) throws { let c = try d.container(keyedBy: K.self)
        id = (try? c.decodeIfPresent(Int.self, forKey: .id)) ?? 0
        nombre = (try? c.decodeIfPresent(String.self, forKey: .nombre)) ?? ""
        saldo = (try? c.decodeIfPresent(Double.self, forKey: .saldo)) ?? 0
        limite = (try? c.decodeIfPresent(Double.self, forKey: .limite)) ?? 0
        corte = (try? c.decodeIfPresent(Int.self, forKey: .corte)) ?? 0
        pago = (try? c.decodeIfPresent(Int.self, forKey: .pago)) ?? 0
        banco = (try? c.decodeIfPresent(String.self, forKey: .banco)) ?? ""
        color = (try? c.decodeIfPresent(String.self, forKey: .color)) ?? "#d55948"
        last4 = (try? c.decodeIfPresent(String.self, forKey: .last4)) ?? "" }
    enum K: String, CodingKey { case id, nombre, banco, saldo, limite, corte, pago, color, last4 }
    var disponible: Double { max(0, limite - saldo) } }

struct CNPrestamo: Decodable, Identifiable { var id: Int = 0; var nombre: String = ""; var total: Double = 0; var pagado: Double = 0; var sentido: String = "debo"; var color: String = "#825eb9"
    /// La cuota del mes y el día en que vence.
    ///
    /// Venían en los datos desde siempre y no se leían: el lado nativo solo
    /// necesitaba el saldo. En cuanto quiso calcular el consejo de Chino —«tus
    /// cuotas fijas son X, un Y % de tus ingresos»— no tenía con qué, y un
    /// campo que no se decodifica no falla: sale cero y la frase dice otra
    /// cosa, que es peor que no decir nada.
    var cuota: Double = 0
    var dia: Int = 1
    /// El banco o la persona. Va de subtítulo en la fila del préstamo, y la
    /// escribe el formulario nativo; aquí se lee para no perderla.
    var entidad: String = ""
    /// Uno vacío, para armarlo a mano: con `init(from:)` escrito, Swift ya no
    /// regala el de por defecto.
    init() {}
    init(from d: Decoder) throws { let c = try d.container(keyedBy: K.self)
        id = (try? c.decodeIfPresent(Int.self, forKey: .id)) ?? 0
        nombre = (try? c.decodeIfPresent(String.self, forKey: .nombre)) ?? ""
        total = (try? c.decodeIfPresent(Double.self, forKey: .total)) ?? 0
        pagado = (try? c.decodeIfPresent(Double.self, forKey: .pagado)) ?? 0
        // «DEBO» CUANDO NO VIENE, y no «me deben»: la web pregunta
        // `sentido !== 'meDeben'` para saber lo que debes, así que un préstamo
        // sin el campo cuenta ahí. Con «meDeben» por defecto contaba justo al
        // revés, y el mismo préstamo salía como deuda en la web y como dinero a
        // tu favor en el teléfono: el patrimonio se iba el doble de su importe.
        sentido = (try? c.decodeIfPresent(String.self, forKey: .sentido)) ?? "debo"
        cuota = (try? c.decodeIfPresent(Double.self, forKey: .cuota)) ?? 0
        dia = (try? c.decodeIfPresent(Int.self, forKey: .dia)) ?? 1
        color = (try? c.decodeIfPresent(String.self, forKey: .color)) ?? "#825eb9"
        entidad = (try? c.decodeIfPresent(String.self, forKey: .entidad)) ?? "" }
    enum K: String, CodingKey { case id, nombre, total, pagado, sentido, color, cuota, dia, entidad }
    var pendiente: Double { max(0, total - pagado) } }

struct CNMeta: Decodable, Identifiable { var id: Int = 0; var nombre: String = ""; var meta: Double = 0; var ahorrado: Double = 0; var mensual: Double = 0; var color: String = ""; var icono: String = ""
    /// Uno vacío, para armarlo a mano: con `init(from:)` escrito, Swift ya no
    /// regala el de por defecto.
    init() {}
    init(from d: Decoder) throws { let c = try d.container(keyedBy: K.self)
        id = (try? c.decodeIfPresent(Int.self, forKey: .id)) ?? 0
        nombre = (try? c.decodeIfPresent(String.self, forKey: .nombre)) ?? ""
        meta = (try? c.decodeIfPresent(Double.self, forKey: .meta)) ?? 0
        ahorrado = (try? c.decodeIfPresent(Double.self, forKey: .ahorrado)) ?? 0
        mensual = (try? c.decodeIfPresent(Double.self, forKey: .mensual)) ?? 0
        // Vacío, como el icono: «no lo eligió nadie». Con el lila puesto por
        // defecto, la rama que usa el color del TEMA no se ejecutaba nunca, y
        // una meta sin color propio salía morada en el teléfono mientras en la
        // web seguía la paleta que tuvieras puesta.
        color = (try? c.decodeIfPresent(String.self, forKey: .color)) ?? ""
        icono = (try? c.decodeIfPresent(String.self, forKey: .icono)) ?? "" }
    enum K: String, CodingKey { case id, nombre, meta, ahorrado, mensual, color, icono }
    var progreso: Double { meta > 0 ? min(1, ahorrado / meta) : 0 } }

struct CNMov: Decodable, Identifiable {
    var id: String = ""; var concepto: String = ""; var categoria: String = ""
    /// Cuándo se anotó. Dentro del mismo día, la última anotada va arriba.
    ///
    /// El id NO empieza por los milisegundos: lleva una letra delante —«m» un
    /// movimiento, «tr» una transferencia, «dp» un duplicado, «im» uno
    /// importado—. Leer trece caracteres a pelo se tragaba esa letra, `Double`
    /// devolvía nil y TODOS los movimientos valían cero; entonces, dentro de
    /// un mismo día, el orden acababa siendo el de inserción y el último que
    /// anotabas se quedaba abajo. Ahora se salta lo que no sea número.
    var alta: Double {
        Double(id.drop(while: { !$0.isNumber }).prefix(13)) ?? 0
    }
    static func masNuevaPrimero(_ a: CNMov, _ b: CNMov) -> Bool {
        a.fecha != b.fecha ? a.fecha > b.fecha : a.alta > b.alta
    }
    var tipo: String = ""; var monto: Double = 0; var fecha: String = ""; var medio: String = ""; var destino: String = ""; var recurrente: Bool = false
    /// LAS MARCAS QUE ATAN UN MOVIMIENTO A SU META O A SU PRÉSTAMO.
    ///
    /// Las escribe la web al aportar a una meta o abonar a un préstamo, y sin
    /// ellas borrar ese movimiento deja el dinero apuntado en la meta y devuelto
    /// en la cuenta: contado dos veces y devuelto una.
    ///
    /// El teléfono no las leía. Mientras solo pintaba, daba igual; en cuanto
    /// escribe la libreta —que es lo que se está mudando ahora— un movimiento
    /// reescrito las perdería, y el dinero con ellas.
    var meta: Int = 0
    var prestamo: Int = 0
    /// La tarjeta que este movimiento PAGÓ, cuando se pagó desde su hoja.
    ///
    /// Sin la marca, ese pago es indistinguible de un gasto cualquiera, y la
    /// gráfica del patrimonio lo cuenta al revés: baja tu deuda y dibuja que
    /// te empobreciste. Es la misma marca que llevan el aporte (`meta`) y el
    /// abono (`prestamo`), y por el mismo motivo.
    var tarjeta: Int = 0
    /// Uno vacío, para armarlo a mano. Con `init(from:)` escrito, Swift ya no
    /// regala el de por defecto, y `CNMov()` no compila sin esto.
    init() {}

    init(from d: Decoder) throws { let c = try d.container(keyedBy: K.self)
        // id puede venir como número o texto.
        if let s = try? c.decodeIfPresent(String.self, forKey: .id) { id = s }
        else if let n = try? c.decodeIfPresent(Int.self, forKey: .id) { id = String(n) }
        concepto = (try? c.decodeIfPresent(String.self, forKey: .concepto)) ?? ""
        categoria = (try? c.decodeIfPresent(String.self, forKey: .categoria)) ?? ""
        tipo = (try? c.decodeIfPresent(String.self, forKey: .tipo)) ?? ""
        monto = (try? c.decodeIfPresent(Double.self, forKey: .monto)) ?? 0
        fecha = (try? c.decodeIfPresent(String.self, forKey: .fecha)) ?? ""
        medio = (try? c.decodeIfPresent(String.self, forKey: .medio)) ?? ""
        destino = (try? c.decodeIfPresent(String.self, forKey: .destino)) ?? ""
        recurrente = (try? c.decodeIfPresent(Bool.self, forKey: .recurrente)) ?? false
        meta = (try? c.decodeIfPresent(Int.self, forKey: .meta)) ?? 0
        prestamo = (try? c.decodeIfPresent(Int.self, forKey: .prestamo)) ?? 0
        tarjeta = (try? c.decodeIfPresent(Int.self, forKey: .tarjeta)) ?? 0 }
    enum K: String, CodingKey { case id, concepto, categoria, tipo, monto, fecha, medio, destino, recurrente, meta, prestamo, tarjeta }
    var esIngreso: Bool { tipo == "Ingreso" }
    var esGasto: Bool { tipo.hasPrefix("Gasto") }
    var esTransfer: Bool { tipo == "Transferencia" } }

/**
 * UNA TARJETA DEL PANEL, COMO LA GUARDA LA LIBRETA.
 *
 * `cfg` solo lo lleva la serie de tiempo —qué gráfico, cuántos meses, qué
 * series— y la vista elegida de las tarjetas que tienen varias.
 */
struct CNEntradaPanel: Decodable, Identifiable {
    var id: String = ""
    var tipo: String = ""
    var ancho: Int = 2
    var grafico: String = ""
    var rango: Int = 0
    var series: [String] = []
    var vista: String = ""
    init() {}
    init(from d: Decoder) throws {
        let c = try d.container(keyedBy: K.self)
        id = (try? c.decodeIfPresent(String.self, forKey: .id)) ?? ""
        tipo = (try? c.decodeIfPresent(String.self, forKey: .tipo)) ?? ""
        ancho = (try? c.decodeIfPresent(Int.self, forKey: .ancho)) ?? 2
        // UN SOLO `let`. `try?` sobre algo que ya es opcional NO da dos capas:
        // Swift las aplana, así que el segundo `let` no compila —«initializer
        // for conditional binding must have Optional type»—. Aquí no hay
        // Xcode: esto solo se ve en el banco, y cuesta una vuelta entera.
        if let g = try? c.decodeIfPresent(Cfg.self, forKey: .cfg) {
            grafico = g.grafico; rango = g.rango; series = g.series; vista = g.vista
        }
    }
    struct Cfg: Decodable {
        var grafico = ""; var rango = 0; var series: [String] = []; var vista = ""
        init(from d: Decoder) throws {
            let c = try d.container(keyedBy: K.self)
            grafico = (try? c.decodeIfPresent(String.self, forKey: .grafico)) ?? ""
            rango = (try? c.decodeIfPresent(Int.self, forKey: .rango)) ?? 0
            series = ((try? c.decodeIfPresent([String].self, forKey: .series)) ?? []) ?? []
            vista = (try? c.decodeIfPresent(String.self, forKey: .vista)) ?? ""
        }
        enum K: String, CodingKey { case grafico, rango, series, vista }
    }
    enum K: String, CodingKey { case id, tipo, ancho, cfg }
}

struct CNLibreta: Decodable {
    /**
     * ¿Esta libreta no ha llegado todavía?
     *
     * La libreta y los modelos de cada pantalla cruzan el puente por separado y
     * no tienen por qué llegar en ese orden. Con la libreta aún vacía, todo lo
     * que se calcule aquí da CERO, y escribir esos ceros encima machaca lo que
     * la web ya había dicho bien: la cabecera enseñaba «RD$0 · te queda este
     * mes» con la tarjeta de dos dedos más abajo diciendo «RD$43,900 ·
     * disponible este mes».
     *
     * Una libreta de verdad vacía —alguien que acaba de empezar— tampoco pierde
     * nada: la web manda cero también, así que dejar lo suyo dice lo mismo.
     */
    var sinLlegar: Bool {
        tx.isEmpty && cuentas.isEmpty && tarjetas.isEmpty && prestamos.isEmpty && metas.isEmpty
    }
    var nombre: String = "Personal"
    var cuentas: [CNCuenta] = []
    var tarjetas: [CNTarjeta] = []
    var prestamos: [CNPrestamo] = []
    var categorias: [CNCategoria] = []
    var metas: [CNMeta] = []
    var tx: [CNMov] = []
    /// El presupuesto: categoría → tope del mes. Vive AQUÍ, no en la
    /// categoría, aunque `CNCategoria.limite` dé a entender lo contrario.
    var presupuesto: [String: Double] = [:]
    /**
     * LO QUE VALÍA TU PATRIMONIO AL CERRAR CADA MES.
     *
     * La libreta guarda los saldos de HOY, así que la gráfica de Cuentas tenía
     * que inventarse el pasado caminando hacia atrás por los movimientos. Eso
     * vale si todo lo que mueve tu patrimonio es un movimiento, y no lo es:
     * crear una cuenta con saldo, o una tarjeta con deuda, no lo son.
     *
     * Un número por mes, en vez de deducirlo. Aquí se LEE y se devuelve tal
     * cual: el teléfono no la escribe —lo hace la web, en el único sitio por el
     * que pasa todo guardado— pero si no la leyera, se la llevaría por delante
     * la primera vez que escribiera la libreta.
     */
    var historia: [String: Double] = [:]
    /// De dónde sale el dinero cuando no se dice: `cuenta:3`, o vacío.
    ///
    /// No es de la libreta: es la cuenta que marcaste como predeterminada, y
    /// llega con ella porque es una por libreta. Vacío significa «no la mandó
    /// nadie», y entonces se usa la primera cuenta —que es lo que hacía siempre
    /// el teléfono, marcaras la que marcaras—.
    var medioPorDefecto: String = ""
    /// Las tarjetas del Resumen, en su orden. Vacío = el de fábrica.
    var panel: [CNEntradaPanel] = []
    init() {}
    /**
     * ¿HUBO ALGO QUE NO SE PUDO LEER?
     *
     * Cada lista se lee con `(try? …) ?? []`, así que un elemento malo no
     * rompe la libreta: se lleva su lista entera y se queda vacía. Mientras la
     * web era la que escribía, eso solo se VEÍA mal —una pantalla sin cuentas—
     * y al refrescar volvía.
     *
     * Desde que escribe el teléfono es otra cosa: lo que el teléfono lee es lo
     * que le devuelve a la web, así que una lista que se quedó vacía por no
     * poder leerse se GUARDARÍA vacía. Se borrarían las cuentas de verdad.
     *
     * Por eso aquí se apunta. Con esto puesto, el teléfono no escribe: deja que
     * lo haga la web, que tiene los datos buenos. Y no es lo mismo que
     * `sinLlegar`: una libreta nueva está vacía y se puede escribir; esta está
     * vacía por no haberse podido leer y no se puede.
     */
    var dudoso = false

    init(from d: Decoder) throws { let c = try d.container(keyedBy: K.self)
        nombre = (try? c.decodeIfPresent(String.self, forKey: .nombre)) ?? "Personal"
        // `presente` distingue «no lo mandó nadie» de «lo mandó y no se pudo
        // leer». Sin esa diferencia, una libreta sin tarjetas quedaría marcada
        // como dudosa y el teléfono no escribiría nunca.
        var malas: [String] = []
        func lista<T: Decodable>(_ t: [T].Type, _ k: K) -> [T] {
            if let v = try? c.decodeIfPresent([T].self, forKey: k) { return v ?? [] }
            if c.contains(k) { malas.append(k.stringValue) }
            return []
        }
        cuentas = lista([CNCuenta].self, .cuentas)
        tarjetas = lista([CNTarjeta].self, .tarjetas)
        prestamos = lista([CNPrestamo].self, .prestamos)
        categorias = lista([CNCategoria].self, .categorias)
        metas = lista([CNMeta].self, .metas)
        tx = lista([CNMov].self, .tx)
        if let p = try? c.decodeIfPresent([String: Double].self, forKey: .presupuesto) {
            presupuesto = p ?? [:]
        } else {
            if c.contains(.presupuesto) { malas.append("presupuesto") }
            presupuesto = [:]
        }
        if let h = try? c.decodeIfPresent([String: Double].self, forKey: .historia) {
            historia = h ?? [:]
        } else {
            if c.contains(.historia) { malas.append("historia") }
        }
        medioPorDefecto = (try? c.decodeIfPresent(String.self, forKey: .medioPorDefecto)) ?? ""
        // EL PANEL: qué tarjetas tiene el Resumen y en qué orden.
        //
        // Venía en la libreta desde siempre y aquí no se leía: el esqueleto
        // del Resumen se le pedía a la web entera. Una libreta puede no
        // traerlo —las de antes, las del servidor, las compartidas—, y
        // entonces manda el de fábrica, que es lo que hace la web.
        panel = lista([CNEntradaPanel].self, .panel)
        dudoso = !malas.isEmpty
        if dudoso { NSLog("CNLIBRETA: no se pudo leer %@ — el teléfono no escribirá", malas.joined(separator: ", ")) } }
    enum K: String, CodingKey { case nombre, cuentas, tarjetas, prestamos, categorias, metas, tx, presupuesto, historia, medioPorDefecto, panel }

    func categoria(_ nombre: String) -> CNCategoria? { categorias.first { $0.nombre == nombre } }
    func gastadoCategoria(_ nombre: String) -> Double {
        let mes = String(cnHoy().prefix(7))
        return tx.filter { $0.categoria == nombre && $0.esGasto && $0.fecha.hasPrefix(mes) }.reduce(0) { $0 + abs($1.monto) }
    }
    /// Sumaba `categorias[].limite`, que la web nunca manda: daba siempre 0.
    /// Ahora suma el presupuesto de verdad, igual que la web (`presRows`):
    /// las categorías de gasto, sin contar Ahorro.
    var presupuestoTotal: Double {
        categorias.filter { !$0.ingreso && $0.nombre != "Ahorro" }
            .reduce(0) { $0 + (presupuesto[$1.nombre] ?? 0) }
    }
    var deudaTarjetas: Double { tarjetas.reduce(0) { $0 + $1.saldo } }
    private var mesActual: String { String(cnHoy().prefix(7)) }
    var ingresosMes: Double { tx.filter { $0.esIngreso && $0.fecha.hasPrefix(mesActual) }.reduce(0) { $0 + abs($1.monto) } }
    var gastosMes: Double { tx.filter { $0.esGasto && $0.fecha.hasPrefix(mesActual) }.reduce(0) { $0 + abs($1.monto) } }
    var balanceMes: Double { ingresosMes - gastosMes }
    func movimientosDe(_ medio: String) -> [CNMov] { tx.filter { $0.medio == medio || $0.destino == medio }.sorted(by: CNMov.masNuevaPrimero) }
    func nombreMedio(_ medio: String) -> String {
        if medio.hasPrefix("cuenta:"), let id = Int(medio.dropFirst(7)), let c = cuentas.first(where: { $0.id == id }) { return c.nombre }
        if medio.hasPrefix("tarjeta:"), let id = Int(medio.dropFirst(8)), let t = tarjetas.first(where: { $0.id == id }) { return t.nombre }
        return "Efectivo"
    }

    static func desde(json: String) -> CNLibreta? {
        guard let data = json.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(CNLibreta.self, from: data)
    }

    var totalCuentas: Double { cuentas.reduce(0) { $0 + $1.saldo } }
    var porCobrar: Double { prestamos.filter { $0.sentido == "meDeben" }.reduce(0) { $0 + $1.pendiente } }
    var deudaTotal: Double { tarjetas.reduce(0) { $0 + $1.saldo } + prestamos.filter { $0.sentido == "debo" }.reduce(0) { $0 + $1.pendiente } }
    var patrimonio: Double { totalCuentas + porCobrar - deudaTotal }

    // Patrimonio mes a mes (viejo → nuevo), caminando hacia atrás por el neto.
    struct Punto: Identifiable { let id = UUID(); let label: String; let valor: Double; let cambio: Double }
    func tendencia(_ n: Int = 12) -> [Punto] {
        let cal = Calendar.current
        let ym = CNFormateadores.formato("yyyy-MM", loc: "en_US_POSIX")
        let et = CNFormateadores.formato("MMM yy", loc: CNC.fmt.loc)
        var res: [Punto] = []; var running = patrimonio
        for k in 0..<n {
            guard let d = cal.date(byAdding: .month, value: -k, to: Date()) else { continue }
            let mes = ym.string(from: d)
            let ing = tx.filter { $0.esIngreso && $0.fecha.hasPrefix(mes) }.reduce(0.0) { $0 + abs($1.monto) }
            let gas = tx.filter { $0.esGasto && $0.fecha.hasPrefix(mes) }.reduce(0.0) { $0 + abs($1.monto) }
            let neto = ing - gas
            res.append(Punto(label: et.string(from: d).capitalized, valor: running, cambio: neto))
            running -= neto
        }
        return res.reversed()
    }
}

func cnHoy() -> String {
    let f = CNFormateadores.iso
    return f.string(from: Date())
}
/// El dinero CON su signo, como lo escribe la web (`Intl.NumberFormat` lo
/// conserva). Para lo que puede ser negativo de verdad: el balance del mes, el
/// saldo de una cuenta en rojo, el patrimonio. `cnDinero` se come el signo
/// —hace abs()— y para esos sitios enseñaría un número en positivo que es
/// mentira.
/// LOS FORMATEADORES, HECHOS UNA VEZ.
///
/// `NumberFormatter` y `DateFormatter` son de lo más caro que hay de construir
/// en Foundation, y aquí se hacía uno NUEVO por cada cifra y por cada fecha que
/// se escribía: en una lista de veinte movimientos, cuarenta por repintado.
/// Se guardan por lo que los distingue —idioma, moneda, centavos, formato—, así
/// que cambiar de moneda o de idioma sigue funcionando: la clave cambia y se
/// hace otro.
enum CNFormateadores {
    private static var numeros: [String: NumberFormatter] = [:]
    private static var fechas: [String: DateFormatter] = [:]
    private static let cerrojo = NSLock()

    /**
     * COMO `dinero`, PERO CON LOS CENTAVOS SIEMPRE.
     *
     * Para cuando hay que repetir lo que alguien acaba de decir. Con «sin
     * centavos» puesto, dictar «gasté 2.50 en transporte» enseñaba RD$2: un
     * número que nadie dijo, puesto en pantalla con cara de confirmado. La
     * preferencia es sobre cómo se mira la libreta, no sobre qué se oyó.
     */
    static var dineroExacto: NumberFormatter {
        let clave = "\(CNC.fmt.loc)|\(CNC.fmt.moneda)|exacto"
        cerrojo.lock(); defer { cerrojo.unlock() }
        if let f = numeros[clave] { return f }
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.locale = Locale(identifier: CNC.fmt.loc)
        f.currencyCode = CNC.fmt.moneda
        f.minimumFractionDigits = 2; f.maximumFractionDigits = 2
        numeros[clave] = f
        return f
    }

    static var dinero: NumberFormatter {
        let dec = CNC.fmt.centavos ? 2 : 0
        let clave = "\(CNC.fmt.loc)|\(CNC.fmt.moneda)|\(dec)"
        cerrojo.lock(); defer { cerrojo.unlock() }
        if let f = numeros[clave] { return f }
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.locale = Locale(identifier: CNC.fmt.loc)
        f.currencyCode = CNC.fmt.moneda
        f.minimumFractionDigits = dec; f.maximumFractionDigits = dec
        numeros[clave] = f
        return f
    }

    /// El que LEE la fecha guardada: siempre el mismo, no depende del idioma.
    static var iso: DateFormatter { fecha(clave: "iso") { $0.dateFormat = "yyyy-MM-dd"; $0.locale = Locale(identifier: "en_US_POSIX") } }

    /// Uno que ESCRIBE, con la plantilla que se le pida en el idioma puesto.
    static func plantilla(_ p: String) -> DateFormatter {
        fecha(clave: "p|\(p)|\(CNC.fmt.loc)") {
            $0.locale = Locale(identifier: CNC.fmt.loc)
            $0.setLocalizedDateFormatFromTemplate(p)
        }
    }

    static func formato(_ fmt: String, loc: String) -> DateFormatter {
        fecha(clave: "f|\(fmt)|\(loc)") { $0.dateFormat = fmt; $0.locale = Locale(identifier: loc) }
    }

    private static func fecha(clave: String, _ armar: (DateFormatter) -> Void) -> DateFormatter {
        cerrojo.lock(); defer { cerrojo.unlock() }
        if let f = fechas[clave] { return f }
        let f = DateFormatter()
        armar(f)
        fechas[clave] = f
        return f
    }
}

func cnDineroFirmado(_ n: Double) -> String {
    CNFormateadores.dinero.string(from: NSNumber(value: n)) ?? ""
}

func cnDinero(_ n: Double) -> String {
    CNFormateadores.dinero.string(from: NSNumber(value: abs(n))) ?? ""
}

/**
 * El nombre corto de un mes «2026-09», en el idioma de la app.
 *
 * Va por el idioma puesto y no por el del teléfono: quien tiene la app en
 * francés con el móvil en español espera ver los meses en francés, como el
 * resto de la pantalla. Y si la fecha no se entiende, se devuelven los dos
 * dígitos: una etiqueta rara es mejor que una columna sin nombre.
 */
func cnMesCorto(_ mes: String) -> String {
    let f = CNFormateadores.iso
    guard let d = f.date(from: mes + "-01") else { return String(mes.suffix(2)) }
    let n = DateFormatter()
    n.locale = Locale(identifier: CNC.fmt.loc)
    n.setLocalizedDateFormatFromTemplate("MMM")
    return n.string(from: d)
}

// Fecha "d MMM" desde ISO.
func cnFechaCorta(_ iso: String) -> String {
    guard let d = CNFormateadores.iso.date(from: iso) else { return iso }
    return CNFormateadores.plantilla("d MMM").string(from: d)
}
/// "7 SEPTIEMBRE" — el formato que usa la app en las cabeceras de día.
func cnDiaCorto(_ iso: String) -> String {
    guard let d = CNFormateadores.iso.date(from: iso) else { return iso }
    return CNFormateadores.plantilla("d MMMM").string(from: d).uppercased()
}

func cnDiaLargo(_ iso: String) -> String {
    guard let d = CNFormateadores.iso.date(from: iso) else { return iso }
    let o = CNFormateadores.plantilla("EEEE d MMMM")
    // Solo la PRIMERA letra. `.capitalized` sube la de cada palabra y salía
    // «Lunes, 7 De Septiembre»; antes no se notaba porque quien lo escribía lo
    // pasaba entero a mayúsculas.
    let t = o.string(from: d)
    return t.isEmpty ? t : t.prefix(1).uppercased() + t.dropFirst()
}

// Estado compartido: la libreta que la web empuja + las acciones que rebotan a
// la web (abrir "nuevo movimiento", abrir el detalle).
struct CNPerfilInfo: Decodable {
    var nombre: String = "Tú"; var email: String = ""; var plan: String = "Gratis"; var libretas: Int = 1; var local: Bool = true
    init() {}
    init(from d: Decoder) throws { let c = try d.container(keyedBy: K.self)
        nombre = (try? c.decodeIfPresent(String.self, forKey: .nombre)) ?? "Tú"
        email = (try? c.decodeIfPresent(String.self, forKey: .email)) ?? ""
        plan = (try? c.decodeIfPresent(String.self, forKey: .plan)) ?? "Gratis"
        libretas = (try? c.decodeIfPresent(Int.self, forKey: .libretas)) ?? 1
        local = (try? c.decodeIfPresent(Bool.self, forKey: .local)) ?? true }
    enum K: String, CodingKey { case nombre, email, plan, libretas, local }
    static func desde(json: String) -> CNPerfilInfo? {
        guard let d = json.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(CNPerfilInfo.self, from: d)
    }
}

final class CNDatos: ObservableObject {
    // Store COMPARTIDO: Capacitor puede atender la llamada JS con una instancia
    // del plugin distinta a la nuestra; si cada quien usa su propio CNDatos, los
    // datos que empuja la web nunca llegan a la pantalla (salía "No hay
    // movimientos"). Con un singleton, plugin y vista usan el MISMO store.
    static let shared = CNDatos()
    @Published var libreta = CNLibreta()
    @Published var perfil = CNPerfilInfo()
    /// ¿Llegó algo de la web alguna vez? Las pantallas nativas tapan el
    /// webview con un fondo opaco: si nunca llega nada que pintar, lo que ve
    /// el usuario es una pantalla vacía —una app en blanco— y no hay forma de
    /// salir de ahí. Con esto, el controlador sabe que tiene que devolverle el
    /// sitio a la web, que siempre sabe qué enseñar.
    private(set) var llegoAlgo = false
    func apuntaQueLlego() { llegoAlgo = true }
    /// Las tres opciones de los puntos de la charla: ayuda, reportar, empezar
    /// de nuevo. Las hace la web, que ya las tenía.
    var onCharlaAccion: (String) -> Void = { _ in }
    var onNuevoMov: () -> Void = {}
    var onDetalleMov: (String) -> Void = { _ in }
    var onPerfil: (String) -> Void = { _ in }
    var onTendencia: () -> Void = {}
    var onAgregar: () -> Void = {}
    var onNuevaCategoria: () -> Void = {}
    var onNuevaMeta: () -> Void = {}
    var onAbrirCuenta: (Int) -> Void = { _ in }
    var onAbrirTarjeta: (Int) -> Void = { _ in }
    var onAbrirPrestamo: (Int) -> Void = { _ in }
    var onAbrirMeta: (Int) -> Void = { _ in }
    var onAccion: (String, String) -> Void = { _, _ in }   // (tipo, id) → flujo web
    var onCrearMov: ([String: Any]) -> Void = { _ in }     // guardar un movimiento nativo → web
    var onEditarMov: ([String: Any]) -> Void = { _ in }    // editar un movimiento (incluye id) → web
    var onBorrarMov: (String) -> Void = { _ in }           // borrar un movimiento por id → web
    // Guardar una "hoja" nativa (cuenta/tarjeta/préstamo/meta/abono/aporte/pago)
    // reusando toda la lógica de la web: (tipo, form, extra?) → enviarHoja.
    var onGuardarHoja: (String, [String: Any], [String: Any]?) -> Void = { _, _, _ in }
    var onSelector: () -> Void = {}
    /// Las libretas, para la hoja nativa del selector.
    var onLibreta: (String, Int) -> Void = { _, _ in }
    /// Crear una libreta desde el formulario nativo.
    var onCrearLibreta: ([String: Any]) -> Void = { _ in }
    /// Chino en grande (mantener pulsado su icono o la pestaña de Perfil).
    var onMascota: () -> Void = {}
    /// La hoja de la categoría: escribir, elegir icono o color, guardar.
    var onCategoria: (String, String) -> Void = { _, _ in }
    /// Mandar una invitación desde el formulario nativo.
    var onInvitar: ([String: Any]) -> Void = { _ in }
    var onVerPresupuesto: () -> Void = {}
    var onLimiteCategoria: (String, Double) -> Void = { _, _ in }   // (categoría, presupuesto) → web
    var onMes: (Int) -> Void = { _ in }         // −1 / +1 desde la cabecera
    var onEmpezar: () -> Void = {}              // el «empieza aquí» del resumen vacío
    var onEditarPanel: () -> Void = {}          // organizar el panel (en la web)
    /// El resumen entra en «organizar» cuando esto se pone a true (desde
    /// Perfil, desde el menú de una tarjeta…); el resumen lo vuelve a false.
    @Published var organizarPanel = false
    /// Dónde está cada cosa que el tour señala (en coordenadas de la
    /// pantalla): las pestañas las mide el controlador, lo demás se apunta
    /// solo desde las vistas con `cnAncla`.
    @Published var anclas: [String: CGRect] = [:]
    func apuntaAncla(_ id: String, _ r: CGRect) {
        guard let v = anclas[id], abs(v.minX - r.minX) < 0.5, abs(v.minY - r.minY) < 0.5,
              abs(v.width - r.width) < 0.5, abs(v.height - r.height) < 0.5 else { anclas[id] = r; return }
    }
    /// Avisa al controlador de que se está organizando (el menú de abajo se va).
    var onOrganizando: (Bool) -> Void = { _ in }
    /**
     * TAPAR EL MENÚ DE ABAJO, POR DOS MOTIVOS A LA VEZ.
     *
     * Lo piden dos sitios —organizar el panel y entrar en un ajuste— y pueden
     * solaparse. Con un booleano a secas, el que termina primero lo devuelve
     * aunque el otro siga queriéndolo fuera. Se cuenta cuántos lo piden.
     */
    private var tapando = 0
    func tapaLaBarra(_ on: Bool) {
        tapando = max(0, tapando + (on ? 1 : -1))
        onOrganizando(tapando > 0)
    }
    var onCalendario: () -> Void = {}           // abrir el calendario / periodo
    var onMesTira: (Int) -> Void = { _ in }     // saltar a un mes de la tira
    var onPlegar: () -> Void = {}               // plegar la cabecera clásica
    /// Editar el panel: (op, id, valor). op = quitar·ocultar·ancho·mover·agregar·grafico·rango·serie
    var onPanel: (String, String, String) -> Void = { _, _, _ in }
    /// Perfil: disparar una fila de los ajustes (grupo, fila, valor de lista).
    var onAjuste: (Int, Int, String?) -> Void = { _, _, _ in }
    var onPlan: () -> Void = {}
    @Published var ajustes: CNAjustes? = nil
    /// Subpantalla del perfil abierta (nativa).
    @Published var seccion: CNSeccion? = nil {
        // Cerrada = «-»: cualquier JSON que llegue tarde (un refresco de la
        // anterior) se descarta hasta que se pida otra.
        didSet {
            if seccion == nil { seccionPedida = "-" }
            // Y EL MENÚ DE ABAJO SE VA mientras hay un ajuste abierto.
            //
            // Estas subpantallas entran desde la derecha tapando la pantalla
            // entera: no son una pestaña, son otro sitio. Con el menú puesto
            // debajo parecía que seguías dentro de Perfil y que aquello era un
            // trozo más de la misma pantalla, cuando lo único que se puede
            // hacer ahí es volver.
            if (oldValue == nil) != (seccion == nil) { tapaLaBarra(seccion != nil) }
        }
    }
    /// La última subpantalla pedida. Un JSON de otra (uno que llegó tarde) se
    /// tira: era lo que hacía que, al tocar una opción, saliera otra cosa.
    var seccionPedida = ""
    /**
     * LA ÚLTIMA VEZ QUE SE VIO CADA SUBPANTALLA.
     *
     * Al entrar en una se vaciaba la pantalla y se esperaba a que la web la
     * armara. Tocabas, se quedaba en blanco, y al rato aparecía el contenido:
     * eso es el salto raro. Con lo de la vez pasada puesto desde el primer
     * fotograma, la transición tiene qué animar y el modelo nuevo llega encima
     * sin que se note.
     *
     * Solo en memoria a propósito. Guardarlo en disco haría que, tras
     * actualizar la app, la primera entrada enseñara una pantalla de la versión
     * anterior — con opciones que a lo mejor ya no existen. Perder esto al
     * cerrar la app cuesta un parpadeo una vez; lo otro cuesta enseñar algo
     * falso.
     */
    var seccionesVistas: [String: CNSeccion] = [:]
    /// Lo que lleva recorrido el dedo desde la orilla en la subpantalla de
    /// Perfil. Lo mueve el reconocedor de UIKit; aquí solo se dibuja.
    @Published var arrastreSec: CGFloat = 0
    /// Pide a la web el modelo de una sección; la respuesta llega por
    /// `cargarSeccion`.
    var onAbrirSeccion: (String) -> Void = { _ in }
    /// Dispara una acción de la sección (su número) y vuelve a pedir el modelo.
    var onSeccionAccion: (Int, String?) -> Void = { _, _ in }
    /// Las hojas de la web, dibujadas en nativo.
    var onHojaCampo: (Int, String, String) -> Void = { _, _, _ in }
    var onHojaEnviar: () -> Void = {}
    @Published var hojaWeb: CNHojaWeb.Modelo? = nil
    @Published var periodo: CNPeriodo? = nil
    @Published var libretas: CNLibretas? = nil
    @Published var libretaNueva: CNLibretaNueva? = nil
    @Published var invitar: CNInvitar? = nil
    @Published var tour: CNTour? = nil
    /// La charla con Chino (mensajes, si está pensando).
    @Published var charla: CNCharla? = nil
    func cargarCharla(json: String) { charla = CNCharla.desde(json: json) }
    var onCharla: (String) -> Void = { _ in }
    var onCharlaLimpiar: () -> Void = {}
    @Published var mascota: CNMascota? = nil
    @Published var puerta: CNPuerta? = nil
    @Published var categoria: CNHojaCategoria? = nil
    /// tipo: opcion · dia · antes · despues · aplicar · cerrar
    var onPeriodo: (String, Int) -> Void = { _, _ in }
    /// El detalle de un movimiento, armado por la web.
    @Published var movDetalle: CNMovDetalle? = nil
    var onMovAccion: (String) -> Void = { _ in }
    /// La pantalla de Cuentas, armada por la web.
    @Published var cuentas: CNCuentasModelo? = nil
    var onCuentasAccion: (String, Int) -> Void = { _, _ in }
    /// Una acción de las que salen al deslizar una fila.
    var onFilaAccion: (Int, String) -> Void = { _, _ in }
    /// El Plan, armado por la web.
    @Published var plan: CNPlanModelo? = nil
    /// tipo: tab · categoria · meta · aportar · nuevaCat · nuevaMeta
    var onPlanAccion: (String, Int) -> Void = { _, _ in }
    /// Cambiar de pestaña se nota al instante, sin esperar a la web.
    func ponerPestanaPlan(_ i: Int) {
        guard var m = plan else { return }
        m.tab = i == 1 ? "metas" : "presupuesto"
        m.tabs = m.tabs.map { t in var x = t; x.puesta = (t.indice == i); return x }
        plan = m
    }
    var onCuentaAccion: (String) -> Void = { _ in }
    /// Cualquier detalle (cuenta, tarjeta, préstamo, meta, categoría).
    @Published var detalle: CNDetalle? = nil
    var onDetalleAccion: (String, Int) -> Void = { _, _ in }
    /// Abrir una hoja de Perfil por su nombre: «chino-ayuda», «chino-aviso».
    var onPerfilHoja: (String) -> Void = { _ in }
    /// Abrir una hoja de monto del teléfono: abono, aporte o pago de tarjeta.
    var onHojaDeMonto: (String, Int, Double) -> Void = { _, _, _ in }
    /// Abrir el movimiento nuevo del teléfono con algo ya puesto: la categoría
    /// desde la que vienes, o la cuenta.
    var onNuevoMovCon: (String, String) -> Void = { _, _ in }

    /// Un botón del detalle, por su única puerta.
    ///
    /// Los tres sitios que dibujan botones llamaban cada uno por su cuenta a
    /// `onDetalleAccion`, y añadir una forma nueva de abrir obligaba a
    /// acordarse de los tres. Aquí se decide una vez.
    func tocaBotonDetalle(_ b: CNDetalle.Boton) {
        if b.abre == "movCat" || b.abre == "movMedio" {
            onNuevoMovCon(b.abre, b.conQue); return
        }
        if !b.abre.isEmpty { onHojaDeMonto(b.abre, b.cual, b.monto); return }
        onDetalleAccion("boton", b.id)
    }
    /// Marca un chip del detalle sin esperar a la web: el periodo se enciende
    /// al tocarlo y las cifras llegan un instante después.
    func marcarChip(_ i: Int) {
        guard var d = detalle else { return }
        d.chips = d.chips.map { c in var x = c; x.puesta = (c.indice == i); return x }
        detalle = d
    }
    func cargarDetalle(json: String) { detalle = CNDetalle.desde(json: json) }
    /// LO ÚLTIMO QUE SE PINTÓ, GUARDADO EN EL TELÉFONO.
    ///
    /// Las pantallas nativas dibujan modelos que calcula la web, y hasta ahora
    /// vivían solo en memoria: al abrir la app no había NADA que enseñar hasta
    /// que la web arrancaba, calculaba y contestaba. Si tardaba, veías una
    /// pantalla vacía; si fallaba, la veías vacía para siempre, con tus datos
    /// ahí mismo en el teléfono.
    ///
    /// Ahora cada modelo que llega se guarda, y al arrancar se pintan los de la
    /// última vez antes de preguntarle nada a nadie. La app se ve al instante
    /// y con datos de verdad —los tuyos, los de la última vez que la usaste— y
    /// se refrescan solos cuando la web contesta.
    ///
    /// No es lo mismo que calcularlo aquí, y no pretende serlo: si cambias de
    /// mes sin que la web conteste, verás el mes de antes. Pero la diferencia
    /// entre eso y una pantalla en blanco es toda.
    private static let guardados = "cn.modelos."
    /// Lo último que se cargó de cada cosa, para no volver a cargarlo igual.
    private var ultimo: [String: String] = [:]

    /**
     * ¿ESTO ES NUEVO, O ES LO MISMO OTRA VEZ?
     *
     * La web manda su modelo en cada refresco, y el refresco salta al abrir una
     * pantalla, al volver, al cambiar de pestaña. Casi siempre es EXACTAMENTE
     * el mismo texto que ya está puesto, y aun así se volvía a aplicar: el tema
     * se reasignaba, el sello subía y SwiftUI repintaba la pantalla entera.
     *
     * Eso es lo que se ve como un saltito al abrir una subpantalla de Perfil:
     * la letra se recoloca un pelo porque todo se vuelve a medir, sin que haya
     * cambiado nada. Comparando el texto se acabó: lo mismo no se repinta.
     */
    private func cambio(_ que: String, _ json: String) -> Bool {
        guard ultimo[que] != json else { return false }
        ultimo[que] = json
        return true
    }

    private func guarda(_ que: String, _ json: String) {
        guard json.count > 2 else { return }          // un modelo vacío no se guarda
        UserDefaults.standard.set(json, forKey: Self.guardados + que)
    }
    private static func guardado(_ que: String) -> String? {
        UserDefaults.standard.string(forKey: guardados + que)
    }

    /// FUERA LO GUARDADO. Al cerrar sesión, lo de la última vez es de OTRA
    /// persona: pintarlo en el próximo arranque sería enseñarle sus cifras a
    /// quien entre después. Lo llama el controlador en cuanto la web dice que
    /// ya no se está dentro.
    func olvidaLoGuardado() {
        for que in ["libreta", "tema", "resumen", "cuentas", "plan", "ajustes", "perfil", "mascota"] {
            UserDefaults.standard.removeObject(forKey: Self.guardados + que)
        }
    }

    /**
     * Y LO QUE HAY EN PANTALLA AHORA MISMO.
     *
     * `olvidaLoGuardado` borra lo del disco: lo que se pintaría en el PRÓXIMO
     * arranque. Lo que está cargado en memoria seguía ahí, y como un modelo
     * «a medias» no pisa al bueno —`if m.listo || x == nil`, que es lo que
     * evita que la pantalla parpadee mientras la web repinta— los modelos
     * nuevos, todos con `listo: false` porque ya no hay libreta, no lo
     * reemplazaban NUNCA.
     *
     * Resultado: cerrabas sesión y la app seguía enseñando el patrimonio, el
     * balance del mes y los totales de la persona que acababa de salir. Los
     * movimientos y las tarjetas sí desaparecían —esos salen de la libreta, que
     * no lleva guardia— y eso era justo lo que lo hacía parecer medio normal.
     *
     * Se llama cuando la web dice que ya no hay sesión, que es una señal clara
     * y no una suposición: la manda `salir()` y la caducidad.
     */
    func olvidaTodo() {
        olvidaLoGuardado()
        ultimo.removeAll()
        libreta = CNLibreta()
        perfil = CNPerfilInfo()
        resumen = nil; cuentas = nil; plan = nil; ajustes = nil
        mascota = nil; charla = nil; detalle = nil; movDetalle = nil
        seccion = nil; hojaWeb = nil; periodo = nil; libretas = nil
        libretaNueva = nil; invitar = nil; categoria = nil; tour = nil
    }

    /// La libreta que acaba de llegar, guardada para el próximo arranque.
    func guardaLaLibreta(_ json: String) { guarda("libreta", json) }

    /// Los de la última vez, antes de preguntarle nada a la web. Lo llama el
    /// controlador nada más arrancar.
    func pintaLoDeLaUltimaVez() {
        if let j = Self.guardado("libreta"), let l = CNLibreta.desde(json: j) { libreta = l; apuntaQueLlego() }
        if let j = Self.guardado("tema") { cargarTema(json: j) }
        if let j = Self.guardado("resumen") { cargarResumen(json: j) }
        if let j = Self.guardado("cuentas") { cargarCuentas(json: j) }
        if let j = Self.guardado("plan") { cargarPlan(json: j) }
        if let j = Self.guardado("ajustes") { cargarAjustes(json: j) }
        if let j = Self.guardado("perfil") { cargarPerfil(json: j) }
        if let j = Self.guardado("mascota") { cargarMascota(json: j) }
    }

    /// Un modelo a medias (leído mientras la web repinta) NO pisa al bueno:
    /// así la pantalla no se queda en blanco al cambiar de pestaña.
    func cargarPlan(json: String) {
        // El `defer` va PRIMERO: aunque el modelo sea el mismo, el refresco
        // tiene que correr igual —depende también de la libreta, que cambia
        // por su cuenta—. Lo que se evita es volver a aplicar lo idéntico.
        defer { refrescarPlan() }
        guard cambio("plan", json) else { return }
        guard let m = CNPlanModelo.desde(json: json) else { return }
        if m.listo { guarda("plan", json) }
        if m.listo || plan == nil { plan = m }
    }
    func cargarCuentas(json: String) {
        // El `defer` va PRIMERO: aunque el modelo sea el mismo, el refresco
        // tiene que correr igual —depende también de la libreta, que cambia
        // por su cuenta—. Lo que se evita es volver a aplicar lo idéntico.
        defer { refrescarCuentas() }
        guard cambio("cuentas", json) else { return }
        guard let m = CNCuentasModelo.desde(json: json) else { return }
        if m.listo { guarda("cuentas", json) }
        if m.listo || cuentas == nil { cuentas = m }
    }
    func cargarMovDetalle(json: String) { movDetalle = CNMovDetalle.desde(json: json) }
    func cargarPeriodo(json: String) { periodo = CNPeriodo.desde(json: json) }
    /// Marca una opción, una muestra o un interruptor de una subpantalla EN EL
    /// ACTO, sin esperar a que la web conteste. Es lo que hace que tocar se
    /// sienta como tocar y no como pedir: la web confirma un instante después.
    func marcarEnSeccion(bloque bi: Int, opcion: Int? = nil, muestra: Int? = nil, llave: Int? = nil) {
        guard var sec = seccion, bi >= 0, bi < sec.bloques.count else { return }
        var q = sec.bloques[bi]
        if let i = opcion, i < q.opciones.count {
            for k in q.opciones.indices { q.opciones[k].puesta = (k == i) }
        }
        if let i = muestra, i < q.colores.count {
            for k in q.colores.indices { q.colores[k].puesta = (k == i) }
        }
        if let i = llave, i < q.llaves.count {
            q.llaves[i].puesto.toggle()
        }
        sec.bloques[bi] = q
        seccion = sec
    }
    func cargarLibretas(json: String) { libretas = CNLibretas.desde(json: json) }
    func cargarLibretaNueva(json: String) { libretaNueva = CNLibretaNueva.desde(json: json) }
    func cargarInvitar(json: String) { invitar = CNInvitar.desde(json: json) }
    func cargarTour(json: String) { tour = CNTour.desde(json: json) }
    /// Los dos PNG de Chino, que casi nunca cambian.
    ///
    /// Pesan 106 KB entre los dos y viajaban por el puente en cada refresco. Se
    /// guardan aquí y se vuelven a pegar cuando el modelo llega sin ellos.
    private var dibujoChino = ""
    func cargarMascota(json: String) {
        guard var m = CNMascota.desde(json: json) else { return }
        // Con dibujo dentro: es lo que hace que al abrir se vea Chino y no un
        // hueco. Sin dibujo llega cuando no cambió, y ese no vale para guardar.
        if !m.chinolo.isEmpty { guarda("mascota", json) }
        // Si viene sin dibujo es que no cambió: se le pega el que ya había.
        if m.chinolo.isEmpty { m.chinolo = dibujoChino } else { dibujoChino = m.chinolo }
        mascota = m
    }
    /// La puerta se vuelve a pedir cada poco mientras está puesta; si la web
    /// contesta lo mismo, no se repinta (lo que se escribe en un campo no se
    /// mueve). Con la puerta quitada, el mismo JSON de antes SÍ vale: es una
    /// puerta nueva.
    private var puertaCruda = ""
    func cargarPuerta(json: String) {
        guard json != puertaCruda || puerta == nil else { return }
        puertaCruda = json
        puerta = CNPuerta.desde(json: json)
    }
    func cargarCategoria(json: String) { categoria = CNHojaCategoria.desde(json: json) }
    func cargarHojaWeb(json: String) { hojaWeb = CNHojaWeb.Modelo.desde(json: json) }
    /// El panel del resumen, YA calculado por la web.
    @Published var resumen: CNResumenModelo? = nil
    func cargar(json: String) {
        if let l = CNLibreta.desde(json: json) { libreta = l; refrescarCifras(); refrescarCuentas(); refrescarPlan() }
    }

    /// EL PERÍODO, que hasta ahora solo sabía la web.
    ///
    /// Sin él lo nativo no podía sumar nada: no sabía de qué mes hablar. Lo
    /// manda `fijaPeriodo`, el embudo por el que pasan todos los cambios.
    @Published var mesActivo: String = String(cnHoy().prefix(7))
    @Published var desdeActivo: String = ""
    @Published var hastaActivo: String = ""
    var periodoCalculo: CNCalculo.Periodo {
        CNCalculo.Periodo(mes: mesActivo,
                          desde: desdeActivo.isEmpty ? nil : desdeActivo,
                          hasta: hastaActivo.isEmpty ? nil : hastaActivo)
    }
    func ponPeriodo(mes: String, desde: String, hasta: String) {
        if !mes.isEmpty { mesActivo = mes }
        desdeActivo = desde
        hastaActivo = hasta
        refrescarCifras(); refrescarCuentas(); refrescarPlan()
    }

    /// Las CIFRAS de la cabecera del resumen, calculadas aquí con CNCalculo.
    ///
    /// El aspecto —cuál de las siete cabeceras, los colores, el degradado— lo
    /// sigue mandando la web: eso es configuración, no cálculo, y sólo cambia
    /// cuando el usuario la toca. Lo que cambia a cada rato son los números, y
    /// esos ya no hay que pedirlos: salen de la libreta que ya tenemos.
    /// Las cifras de CUENTAS, calculadas aquí.
    ///
    /// La fila número `i` es la cuenta número `i` de la libreta: así las numera
    /// la web, y por eso se pueden emparejar sin más. Lo que NO se toca es la
    /// decoración —iconos, colores, rótulos, lo que sale al deslizar— ni nada
    /// si el dinero está oculto, que entonces la web manda cifras tapadas y
    /// destaparlas sería un fallo de verdad.
    func refrescarCuentas() {
        guard !libreta.sinLlegar else { return }
        // SIN MODELO TAMBIÉN SE PINTA.
        //
        // Esto empezaba con `guard var m = cuentas`: si la web no había
        // mandado su esqueleto —porque estaba parada en otra pestaña—, el
        // cálculo nativo no tenía dónde escribir y se iba sin hacer nada. La
        // pantalla se quedaba con la tarjeta del patrimonio y ni una cuenta
        // debajo, con los números ya calculados aquí al lado.
        var m = cuentas ?? CNCuentasModelo()
        guard !m.oculto else { return }
        let l = libreta

        // LAS FILAS, DE LA LIBRETA Y NO DE LA WEB.
        //
        // Los colores que cambian con la paleta salen del modelo del resumen
        // si ya llegó, y si no, del tema que tenga puesto: el verde de un tema
        // no es el verde de otro, y escribir el de fábrica deja un parche.
        let cab = resumen?.cabecera
        let t = CNCuentasFilas.Tinte(
            positivo: cab?.positivo.isEmpty == false ? cab!.positivo : cnHexDe(CNC.pos),
            aviso: cab?.aviso.isEmpty == false ? cab!.aviso : cnHexDe(CNC.acc),
            negativo: cab?.negativo.isEmpty == false ? cab!.negativo : cnHexDe(CNC.neg))
        m.cuentas = conLoDeLaWeb(CNCuentasFilas.cuentas(l), como: m.cuentas)
        m.tarjetas = conLoDeLaWeb(CNCuentasFilas.tarjetas(l, tinte: t), como: m.tarjetas)
        m.prestamos = conLoDeLaWeb(CNCuentasFilas.prestamos(l, tinte: t), como: m.prestamos)
        // Los tres totales y el patrimonio, por el módulo. Aquí se calculaban a
        // mano, y el de préstamos se quedaba a medias: solo se escribía el
        // NÚMERO y el rótulo seguía siendo el que mandó la web. Si cobrabas el
        // último préstamo que debías, la pantalla se quedaba diciendo «Debes» y
        // debajo la cifra de lo que te deben a ti. No fallaba nada: mentía.
        let tc = CNCuentasTotales.cuentas(l)
        let tt = CNCuentasTotales.tarjetas(l)
        let tp = CNCuentasTotales.prestamos(l)
        m.totalCuentas.rotulo = tc.rotulo; m.totalCuentas.valor = tc.valor
        m.totalTarjetas.rotulo = tt.rotulo; m.totalTarjetas.valor = tt.valor
        m.totalPrestamos.rotulo = tp.rotulo; m.totalPrestamos.valor = tp.valor
        let pat = CNCuentasTotales.patrimonio(l)
        m.patrimonio.valor = pat.valor
        m.patrimonio.activos = pat.activos
        m.patrimonio.pasivos = pat.pasivos
        // Y los rótulos, por si el esqueleto nunca llegó: sin ellos los tres
        // grupos salen sin título.
        if m.rotuloCuentas.isEmpty { m.rotuloCuentas = cnT("Cuentas") }
        if m.rotuloTarjetas.isEmpty { m.rotuloTarjetas = cnT("Tarjetas de crédito") }
        if m.rotuloPrestamos.isEmpty { m.rotuloPrestamos = cnT("Préstamos") }
        if m.patrimonio.titulo.isEmpty { m.patrimonio.titulo = cnT("Patrimonio") }
        if m.patrimonio.activosLabel.isEmpty { m.patrimonio.activosLabel = cnT("Activos") }
        if m.patrimonio.pasivosLabel.isEmpty { m.patrimonio.pasivosLabel = cnT("Pasivos") }
        cuentas = m
    }

    /**
     * LO QUE TODAVÍA ES DE LA WEB, CONSERVADO.
     *
     * Las filas se arman aquí, pero lo que sale al DESLIZAR una —editar,
     * eliminar, poner como predeterminada— son funciones que viven en la web y
     * se disparan por su número. Moverlas sin más sería cambiar
     * comportamiento, no aspecto. Se emparejan por posición, que es el mismo
     * orden de la libreta en los dos lados, y se conservan tal cual.
     */
    private func conLoDeLaWeb(_ nuevas: [CNCuentasModelo.Fila],
                              como viejas: [CNCuentasModelo.Fila]) -> [CNCuentasModelo.Fila] {
        nuevas.enumerated().map { i, f in
            guard i < viejas.count, viejas[i].nombre == f.nombre else { return f }
            var x = f
            x.acciones = viejas[i].acciones
            x.predeterminada = viejas[i].predeterminada
            x.rotuloPred = viejas[i].rotuloPred
            return x
        }
    }

    /**
     * EL PLAN, RECALCULADO AQUÍ.
     *
     * Las filas van en el mismo orden que en la web —las categorías de gasto,
     * sin las de ingreso y sin Ahorro—, así que se emparejan por posición.
     *
     * Aquí solo se movía el RELLENO de la barra. Anotabas un gasto y la barra
     * se llenaba mientras el texto de al lado seguía diciendo lo que te quedaba
     * ANTES, y seguía en verde después de pasarte del tope. La barra decía una
     * cosa y las dos letras de su derecha decían otra, en la misma fila.
     *
     * El texto no se inventa: es el mismo que escribe la web, palabra por
     * palabra, y vive en `CNPlanCuentas` para que no se puedan separar.
     *
     * Lo que NO se toca es el nombre, el icono, ni lo que sale al deslizar: eso
     * no cambia porque anotes un movimiento.
     */
    func refrescarPlan() {
        guard var m = plan, !libreta.sinLlegar else { return }
        let pres = CNCalculo.presupuesto(libreta, periodoCalculo)
        m.presGastado = cnDinero(pres.gastadoTotal)
        m.presTotal = cnDinero(pres.limiteTotal)
        m.presPct = Double(pres.pctTotal)
        // El color y el texto de cada fila, por el módulo. Los colores del tema
        // salen del modelo que mandó la web: cambian con la paleta que haya
        // puesta, no con los números.
        let t = CNPlanCuentas.Tinte(
            positivo: resumen?.cabecera.positivo ?? "",
            ambar: resumen?.cabecera.aviso ?? "",
            negativo: resumen?.cabecera.negativo ?? "")
        let filas = CNPlanCuentas.filas(libreta, periodoCalculo, tinte: t)
        for i in m.filas.indices where i < filas.count {
            m.filas[i].pct = Double(filas[i].pct)
            m.filas[i].queda = filas[i].queda
            // «RD$3,200 de RD$5,000»: los dos números, y el «de» tal como venga,
            // que es una palabra traducida y no me la invento. Se quedaba viejo
            // igual que el otro texto: la barra se llenaba y el pie seguía
            // diciendo el gasto de antes.
            m.filas[i].pie = [filas[i].gastado, m.presDe, filas[i].limite]
                .filter { !$0.isEmpty }.joined(separator: " ")
            // El color solo si de verdad hay uno: con la paleta sin llegar
            // todavía, pintar de vacío deja la barra transparente.
            if !filas[i].color.isEmpty { m.filas[i].color = filas[i].color }
        }
        plan = m
    }

    /**
     * LA CABECERA, ARMADA AQUÍ CUANDO NO LLEGA.
     *
     * Los colores salen de `CNCabecera`, que es la misma función de la web
     * rama por rama; las piezas que lleva cada diseño están medidas en
     * `test/cabecera-oro.json`. Las cifras ya las sabía calcular el teléfono.
     *
     * Solo se arma si falta: cuando la web contesta, manda ella, porque
     * todavía trae cosas que aquí no se calculan —la tira de meses con sus
     * nombres y el estado de plegado—.
     */
    func armaLaCabecera() {
        var m = resumen ?? CNResumenModelo()
        var c = m.cabecera
        let p = CNCabecera.paleta(
            diseno: CNC.fmt.cabecera, color: CNC.fmt.cabeceraColor,
            integrada: CNC.fmt.cabeceraIntegrada,
            tema: CNCabecera.Tema(
                bg: CNC.hexScr, card: CNC.hexCard, suave: CNC.hexSoft,
                borde: cnHexDe(CNC.line), tinta: cnHexDe(CNC.ink),
                gris: cnHexDe(CNC.pmut), side: CNC.hexSide))
        let f = CNCabecera.fondo(p.fondo)
        c.diseno = CNC.fmt.cabecera
        c.fondo = CNResumenModelo.Fondo(
            tipo: f.tipo, color: f.color, angulo: f.angulo,
            paradas: f.paradas.map { CNResumenModelo.Parada(color: $0.color, pos: $0.pos) })
        c.tinta = p.tinta; c.gris = p.gris
        c.pastilla = p.pastilla; c.pastillaFuerte = p.pastillaFuerte
        let piezas = CNCabecera.piezas(CNC.fmt.cabecera)
        c.grande = piezas.grande
        c.tarjeta = CNC.fmt.cabeceraTarjeta
        if c.positivo.isEmpty { c.positivo = cnHexDe(CNC.pos) }
        if c.negativo.isEmpty { c.negativo = cnHexDe(CNC.neg) }
        // Las cifras del mes, que ya se sabían calcular.
        let t = CNCalculo.totales(libreta, periodoCalculo)
        if c.balanceRotulo.isEmpty { c.balanceRotulo = cnT("Balance del mes") }
        if c.ingRotulo.isEmpty { c.ingRotulo = cnT("Ingresos") }
        if c.gasRotulo.isEmpty { c.gasRotulo = cnT("Gastos") }
        if piezas.conRotulo && c.rotulo.isEmpty { c.rotulo = cnT("te queda este mes") }
        c.balanceFmt = cnDineroFirmado(t.bal)
        c.ingFmt = cnDinero(t.ing); c.gasFmt = cnDinero(t.gas)
        c.entraFmt = cnDinero(t.ing); c.saleFmt = cnDinero(t.gas)
        c.nombre = c.nombre.isEmpty ? libreta.nombre : c.nombre
        // Y la tira de meses, si el diseño la lleva. El acento y su tinta
        // salen del tema, que es de donde los saca la web.
        if piezas.conMeses, c.meses.isEmpty {
            c.meses = CNCabecera.meses(
                mes: periodoCalculo.mes, hayRango: periodoCalculo.aMedida, paleta: p,
                acento: cnHexDe(CNC.acc), sobreAcento: cnHexDe(CNC.sobreAcc)
            ).enumerated().map { i, x in
                CNResumenModelo.MesTira(indice: i, label: x.label, puesto: x.puesto,
                                        bg: x.bg, fg: x.fg)
            }
        }
        if c.mesLargo.isEmpty { c.mesLargo = CNCabecera.nombreDeMes(periodoCalculo.mes, largo: false) }
        if c.mesCorto.isEmpty { c.mesCorto = c.mesLargo }
        m.cabecera = c
        resumen = m
    }

    /**
     * EL PANEL ENTERO, RECALCULADO AQUÍ EN CUANTO CAMBIAN LOS DATOS.
     *
     * La cabecera ya lo hacía; las tarjetas no, y se quedaban con lo que la web
     * hubiera mandado la última vez. Anotabas un gasto y el balance de arriba
     * se movía al instante mientras la tarjeta de «Gastos del mes» —la misma
     * cifra, dos centímetros más abajo— seguía con el número viejo hasta que la
     * web rearmara y volviera. Dos números distintos para lo mismo en la misma
     * pantalla.
     *
     * Se recalculan las trece que los módulos saben hacer: las cinco cifras,
     * los tres gráficos, las tres listas, el consejo y la serie de tiempo. La
     * que no sepa ninguno se queda tal cual vino: es mejor una tarjeta con el
     * dato de hace un segundo que una tarjeta en blanco.
     *
     * DE CADA TARJETA SOLO SE TOCA EL CONTENIDO. Su sitio, su ancho, su icono y
     * a dónde lleva siguen siendo de la web: eso no cambia porque anotes un
     * movimiento, y tocarlo sería arriesgar el aspecto para arreglar un número.
     */
    func refrescarCifras() {
        // Sin libreta no hay nada que añadir: escribir ceros encima machacaría
        // lo que la web ya dijo bien. (Ver `CNLibreta.sinLlegar`.)
        guard !libreta.sinLlegar else { return }
        // SIN ESQUELETO SE ARMA UNO.
        //
        // Esto empezaba con `guard resumen != nil`: si la web no había mandado
        // el suyo —porque estaba parada en otra pestaña— se iba sin hacer
        // nada, y el Resumen se quedaba con la cabecera y ni una tarjeta,
        // teniendo los números calculados aquí mismo.
        if resumen == nil || resumen?.widgets.isEmpty == true {
            var m = resumen ?? CNResumenModelo()
            m.widgets = CNResumenPanel.widgets(
                libreta, ocultas: CNResumenPanel.ocultas(libreta: libreta.nombre))
            resumen = m
        }
        // Y LA CABECERA, si tampoco llegó. Es lo que da el color a todo lo de
        // arriba: sin ella el bloque sale sin fondo y la cifra sin tinta.
        if resumen?.cabecera.fondo.paradas.isEmpty == true, resumen?.cabecera.fondo.color.isEmpty == true {
            armaLaCabecera()
        }
        let t = CNCalculo.totales(libreta, periodoCalculo)
        resumen?.cabecera.balanceFmt = cnDineroFirmado(t.bal)
        resumen?.cabecera.ingFmt = cnDinero(t.ing)
        resumen?.cabecera.gasFmt = cnDinero(t.gas)
        resumen?.cabecera.entraFmt = cnDinero(t.ing)
        resumen?.cabecera.saleFmt = cnDinero(t.gas)

        // Los colores salen del modelo que mandó la web, no de aquí: cambian
        // con la paleta que cada quien tenga puesta.
        let cab = resumen?.cabecera ?? CNResumenModelo.Cabecera()
        let tinte = CNTarjetasCifra.Tinte(
            tinta: cab.tinta, positivo: cab.positivo,
            negativo: cab.negativo, ambar: cab.aviso,
            // El gris dice «ni bueno ni malo»: una racha de cero días no va en
            // rojo. Sin él, esas tarjetas salían con el color vacío.
            gris: cab.gris.isEmpty ? cnHexDe(CNC.pmut) : cab.gris)
        // La franja de la dona es el verde oscuro del tema —el mismo de la
        // cabecera—, y ese no viene en el modelo: viene en la paleta, que es la
        // que cambia cuando alguien cambia de tema.
        let tinteG = CNTarjetasGrafico.Tinte(
            franja: cnHexDe(CNC.side), negativo: cab.negativo, lila: cab.ahorro)
        let tinteL = CNTarjetasLista.Tinte(
            gris: cab.gris, positivo: cab.positivo, negativo: cab.negativo,
            lila: cab.ahorro, ambar: cab.aviso)

        guard let widgets = resumen?.widgets else { return }
        for (i, w) in widgets.enumerated() {
            switch w.tipoPanel {

            // ── las cinco cifras ───────────────────────────────────────────
            case let kpi where CNTarjetasCifra.sabeHacer.contains(kpi):
                guard let c = CNTarjetasCifra.de(kpi, libreta: libreta,
                                                 periodo: periodoCalculo, tinte: tinte) else { break }
                resumen?.widgets[i].valor = c.valor
                resumen?.widgets[i].nota = c.nota
                resumen?.widgets[i].color = c.color

            // ── los tres gráficos ──────────────────────────────────────────
            case "barras-categorias":
                resumen?.widgets[i].filas = CNTarjetasGrafico.porCategoria(libreta, periodoCalculo)
                    .map { f in filaBarraDe(f) }

            case "columnas-tendencia":
                resumen?.widgets[i].columnas = CNTarjetasGrafico
                    .tendencia(libreta, hasta: periodoCalculo.mes)
                    // Sin color ni peso: el color de las dos barras es el del
                    // rótulo de arriba —`entraColor` y `saleColor`—, y el del
                    // mes lo pone la vista. Es lo que manda la web también.
                    .map { CNResumenModelo.Columna(label: $0.label, a: Double($0.a),
                                                   b: Double($0.b), peso: 500, color: "") }

            case "dona-mezcla":
                let d = CNTarjetasGrafico.mezcla(libreta, periodoCalculo, tinte: tinteG)
                resumen?.widgets[i].total = d.total
                resumen?.widgets[i].tramos = d.trozos.map {
                    CNResumenModelo.Tramo(color: $0.color, desde: Double($0.desde), hasta: Double($0.hasta))
                }
                resumen?.widgets[i].filasDona = d.trozos.map {
                    CNResumenModelo.FilaDona(label: $0.label, valor: $0.valor, color: $0.color)
                }

            // ── las tres listas ────────────────────────────────────────────
            case "lista-recientes":
                resumen?.widgets[i].items = CNTarjetasLista
                    .recientes(libreta, periodoCalculo, tinte: tinteL).map { itemDe($0) }

            case "lista-recordatorios":
                resumen?.widgets[i].items = CNTarjetasLista
                    .recordatorios(libreta, tinte: tinteL).map { itemDe($0) }

            case "lista-metas":
                resumen?.widgets[i].items = CNTarjetasLista
                    .metas(libreta, tinte: tinteL).map { itemDe($0) }

            // ── las cuatro listas y las dos barras que faltaban ────────────
            //
            // Las armaba la web en `tarjetaExtra` y llegaban escritas por el
            // puente: sin web salían en blanco. Son la misma forma que las de
            // arriba, así que la vista ya sabe dibujarlas; lo único que faltaba
            // era la cuenta.
            case "lista-suscripciones":
                let sus = CNTarjetasLista.suscripciones(libreta, tinte: tinteL)
                resumen?.widgets[i].items = sus.filas.map { itemDe($0) }
                resumen?.widgets[i].nota = sus.nota

            case "lista-top":
                resumen?.widgets[i].items = CNTarjetasLista
                    .mayores(libreta, periodoCalculo, tinte: tinteL).map { itemDe($0) }

            case "lista-cuentas":
                resumen?.widgets[i].items = CNTarjetasLista
                    .saldoPorCuenta(libreta, tinte: tinteL).map { itemDe($0) }

            case "lista-tarjetas":
                resumen?.widgets[i].items = CNTarjetasLista
                    .cupoDeTarjetas(libreta, tinte: tinteL).map { itemDe($0) }

            case "barras-presupuesto":
                resumen?.widgets[i].filas = CNTarjetasGrafico
                    .porPresupuesto(libreta, periodoCalculo).map { f in filaBarraDe(f) }

            case "barras-medios":
                resumen?.widgets[i].filas = CNTarjetasGrafico
                    .porMedio(libreta, periodoCalculo).map { f in filaBarraDe(f) }

            // ── el consejo ─────────────────────────────────────────────────
            case "texto-consejo":
                resumen?.widgets[i].texto = CNTarjetasLista.consejo(libreta, periodoCalculo)

            // ── la serie de tiempo, que es la única configurable ───────────
            case "serie-tiempo":
                if var x = resumen?.widgets[i] {
                    aplicaSerie(&x, tinte: tinteG)
                    resumen?.widgets[i] = x
                }

            // Lo que ningún módulo sabe hacer se queda con lo que vino de la
            // web: mejor el dato de hace un segundo que una tarjeta en blanco.
            default: break
            }
        }
    }

    /// Una fila de barra del módulo, con su icono y su color de categoría.
    private func filaBarraDe(_ f: CNTarjetasGrafico.FilaBarra) -> CNResumenModelo.FilaBarra {
        let nombre = CNCategorias.icono(f.categoria, en: libreta)
        let color = CNCategorias.color(f.categoria, en: libreta)
        // El fondo del cuadro se deja VACÍO a propósito: la vista pone el color
        // propio al 15%, que es lo mismo que la web manda resuelto. Calcularlo
        // aquí obligaría a escribir un `color-mix` que en Swift se lee como
        // negro, y de ahí salían los cuadros negros.
        return CNResumenModelo.FilaBarra(label: f.label, valor: f.valor, pct: Double(f.pct),
                                         color: color,
                                         iconoPath: CNIconos.paths[nombre] ?? "",
                                         iconoBg: "")
    }

    /**
     * Una fila de lista del módulo, en el item que dibuja la tarjeta.
     *
     * Las tres listas se pintan distinto y es lo que más fácil se equivoca al
     * rehacerlas, porque ninguna de las dos maneras falla: solo se ve peor.
     *
     * **Los movimientos llevan el icono de su categoría**, del color de la
     * categoría, sobre ese mismo color al 15%. Su cifra va de OTRO color —el
     * del tipo: verde si entró, coral si salió, lila si se apartó, gris si fue
     * un traspaso—. Son dos colores distintos en la misma fila, y usar uno para
     * las dos cosas es la confusión fácil: con el del tipo, todas las filas de
     * gasto salen coral y el icono deja de decir de qué eran.
     *
     * **Los recordatorios y las metas no llevan icono**, llevan su sigla en
     * BLANCO sobre el color entero. Ahí el color sí es uno solo —la urgencia,
     * el color de la meta—, y la sigla del mismo color que su fondo es una
     * burbuja de color vacía: se lee como un fallo de carga.
     */
    private func itemDe(_ f: CNTarjetasLista.Fila) -> CNResumenModelo.Item {
        guard !f.categoria.isEmpty else {
            // Sin categoría: la sigla en blanco sobre el color entero.
            return CNResumenModelo.Item(
                tieneIcono: false, iconoPath: "", color: f.color, fondo: f.color,
                sigla: f.sigla, siglaColor: "#ffffff", titulo: f.titulo,
                detalle: f.detalle, monto: f.monto, montoColor: f.montoColor)
        }
        let nombre = CNCategorias.icono(f.categoria, en: libreta)
        let path = CNIconos.paths[nombre] ?? ""
        let catColor = CNCategorias.color(f.categoria, en: libreta)
        return CNResumenModelo.Item(
            // Sin icono en el catálogo queda la sigla, que es lo que hay.
            tieneIcono: !path.isEmpty, iconoPath: path,
            color: path.isEmpty ? f.color : catColor,
            // El fondo se deja VACÍO: la vista pone el color propio al 15%, que
            // es lo que la web manda ya resuelto. Escribirlo aquí obligaría a
            // un `color-mix` que en Swift se lee como negro.
            fondo: path.isEmpty ? catColor : "",
            sigla: f.sigla, siglaColor: "#ffffff", titulo: f.titulo,
            detalle: f.detalle, monto: f.monto, montoColor: f.montoColor)
    }

    /**
     * La serie de tiempo, con la configuración que tenga puesta la tarjeta.
     *
     * Es la única que se configura desde la propia tarjeta —cuántos meses, qué
     * series, qué forma—, así que la configuración se lee del widget y no de
     * ningún sitio fijo. Las series se pintan del color que la web ya les dio,
     * que es el que tiene la leyenda: recalcularlos aquí las dejaría de un
     * color y la leyenda de otro.
     */
    private func aplicaSerie(_ w: inout CNResumenModelo.Widget, tinte: CNTarjetasGrafico.Tinte) {
        let puestas = w.series.filter { $0.puesta }
        let series = puestas.compactMap { CNSerieTiempo.Serie(rawValue: $0.id) }
        guard !series.isEmpty else { return }
        let forma = CNSerieTiempo.Forma(rawValue: w.cfgGrafico) ?? .linea
        let d = CNSerieTiempo.dibujo(libreta, hasta: periodoCalculo.mes,
                                     meses: Int(w.cfgRango) ?? 12,
                                     series: series, forma: forma)
        // El color de cada serie, el que ya tenía puesto en su interruptor.
        var color: [String: String] = [:]
        for t in puestas { color[t.id] = t.color }
        let colorDe: (CNSerieTiempo.Serie) -> String = { color[$0.rawValue] ?? tinte.franja }

        w.etiquetas = d.etiquetas
        w.leyenda = d.leyenda.map {
            CNResumenModelo.Serie(label: $0.etiqueta, color: colorDe($0.serie), ultimo: $0.ultimo)
        }
        // El SVG quiere los puntos como texto, con dos decimales, igual que los
        // manda la web: con más, la cadena crece sin que se vea nada.
        let comoTexto: ([CNSerieTiempo.Punto]) -> String = { ps in
            ps.map { String(format: "%.2f,%.2f", $0.x, $0.y) }.joined(separator: " ")
        }
        // La línea va SIEMPRE que haya trazo, incluso con área: el área la
        // rellena y la línea le da el borde de arriba, que es lo que se sigue
        // con la vista.
        w.lineas = d.trazos.map {
            CNResumenModelo.Traza(puntos: comoTexto($0.puntos), color: colorDe($0.serie))
        }
        w.areas = d.areas.map {
            CNResumenModelo.Traza(puntos: comoTexto($0.puntos), color: colorDe($0.serie))
        }
        w.puntos = forma == .puntos
            ? d.trazos.flatMap { t in t.puntos.map {
                CNResumenModelo.Punto(x: $0.x, y: $0.y, color: colorDe(t.serie)) } }
            : []
        w.barras = d.barras.map {
            CNResumenModelo.Barra(x: $0.x, y: $0.y, w: $0.w, h: $0.h, color: colorDe($0.serie))
        }
    }
    func cargarPerfil(json: String) {
        guard cambio("perfil", json) else { return }
        if let p = CNPerfilInfo.desde(json: json) { perfil = p; guarda("perfil", json) }
    }
    /// El tema de la web. Al cambiar, se avisa para que TODO se vuelva a dibujar
    /// con los colores nuevos (los de CNC son calculados).
    @Published var selloTema = 0
    /**
     * Guardar una subpantalla SIN enseñarla.
     *
     * Es lo que deja traer las de personalización por adelantado: quedan
     * listas para cuando alguien entre, pero no cambian lo que se está viendo
     * ahora. Poner `seccion` aquí sacaría al usuario de donde estaba.
     */
    func guardaSeccionVista(json: String) {
        guard let x = CNSeccion.desde(json: json) else { return }
        seccionesVistas[x.id] = x
        // Y si resulta que es justo la que se está mirando, se refresca: viene
        // más nueva que la que hay puesta. Salvo que la puesta la haya armado
        // el teléfono, por lo mismo de arriba: esta es la precarga de las doce
        // de golpe, y pisaría la nativa sin que nadie hubiera pedido nada.
        if seccion?.id == x.id, seccion?.deQuien != "nativa" { seccion = x }
    }

    func cargarSeccion(json: String) {
        guard let x = CNSeccion.desde(json: json) else { return }
        if !seccionPedida.isEmpty && x.id != seccionPedida { return }
        /*
         LA WEB NO PISA UNA QUE ARMÓ EL TELÉFONO.
         
         Aquí se perdía «Libretas y permisos». Al entrar se le pide el modelo a
         la web y además se vuelve a pedir a los 0,5 y 1,4 segundos; el teléfono
         arma el suyo por el camino, y el último que llega manda. Las otras
         subpantallas nativas se salvaban de casualidad: la web no las construye
         —devuelve nada y no hay con qué pisar—. Libretas sí la construye, así
         que su copia ganaba siempre, por los pelos y en cada entrada.
         
         La de la web se queda como red: si el teléfono no puede armarla —sin
         datos todavía—, es ella la que se ve. Lo que no puede es ganarle a una
         que ya está hecha.
         */
        if let ya = seccion, ya.id == x.id, ya.deQuien == "nativa", x.deQuien != "nativa" { return }
        // La web acaba de decir lo suyo: a partir de aquí manda ella y lo que
        // se apuntó al tocar ya no pinta nada. Es lo que impide que existan dos
        // copias del mismo ajuste discrepando — que era el motivo de no
        // guardar copia aquí en primer lugar.
        CNRecienTocado.llegoLaPantalla()
        seccionesVistas[x.id] = x
        seccion = x
    }
    func cargarAjustes(json: String) {
        guard cambio("ajustes", json) else { return }
        if let a = CNAjustes.desde(json: json) { ajustes = a; guarda("ajustes", json) }
    }
    func cargarResumen(json: String) {
        guard let m = CNResumenModelo.desde(json: json) else { return }
        defer { refrescarCifras() }
        // Solo se guarda el completo: el que llega desde otra pestaña trae la
        // cabecera pero no las tarjetas, y guardarlo dejaría la próxima
        // apertura con medio resumen.
        if m.listo {
            guarda("resumen", json)
            // Y SE APUNTA QUÉ TARJETAS ESTÁN ESCONDIDAS. Esa lista no vive en
            // la libreta —vive en el aparato, para que una tarjeta pueda estar
            // oculta aquí y visible en la web—, así que la única manera de
            // saberla sin preguntar es acordarse de la última vez que la web
            // la dijo. Solo del modelo COMPLETO: el que viene a medias no
            // trae tarjetas y las resucitaría todas.
            CNResumenPanel.apunta(
                ocultas: Set(m.widgets.filter { $0.oculta }.map { $0.wid }),
                libreta: libreta.nombre)
        }
        if m.listo || resumen == nil {
            resumen = m
            return
        }
        // Leído desde otra pestaña: la cabecera y los iconos sí valen; las
        // tarjetas no, y pisarlas dejaba el resumen en blanco.
        var actual = resumen!
        actual.cabecera = m.cabecera
        actual.catIconos = m.catIconos
        resumen = actual
    }
    func cargarTema(json: String) {
        guarda("tema", json)
        // El mismo tema otra vez no se vuelve a poner: subir el sello repinta
        // TODA la app, y de ahí el saltito al abrir una pantalla.
        guard cambio("tema", json) else { return }
        guard let p = CNPaletaTema.desde(json: json) else { return }
        CNC.tema = p
        selloTema += 1
        // Los textos vienen en el mismo paquete que el tema, así que este es el
        // momento en que puede haber cambiado el idioma. Se avisa a la barra de
        // abajo, que lleva los nombres DIBUJADOS DENTRO de sus iconos y no se
        // entera de otra manera.
        CNMenuEstado.shared.sello += 1
        CNMenuEstado.shared.alRepintar()
        // Guardado para el próximo arranque: así la primera pantalla ya sale
        // con el tema, la letra y la moneda del usuario, sin el parpadeo de
        // empezar en crema y cambiar medio segundo después.
        UserDefaults.standard.set(json, forKey: "cnTema")
    }
    /// El teléfono acaba de cambiar de claro a oscuro (o al revés): se pinta
    /// con la paleta que toca sin preguntarle a nadie. Devuelve `true` si de
    /// verdad cambió algo.
    @discardableResult
    func aplicarModo(oscuro: Bool) -> Bool {
        guard let p = oscuro ? CNC.pareja.oscuro : CNC.pareja.claro else { return false }
        guard p.oscuro != CNC.tema.oscuro || p.scr != CNC.tema.scr else { return false }
        CNC.tema = p
        selloTema += 1
        return true
    }

    /// Una línea para el pie de Perfil: compilación, modo del teléfono y si
    /// llegó la pareja de paletas. Sirve para saber, sin adivinar.
    static func diagnostico() -> String {
        let v = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "?"
        let b = (Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? "?"
        let modo = UIScreen.main.traitCollection.userInterfaceStyle == .dark ? "oscuro" : "claro"
        let pareja = CNC.pareja.oscuro != nil ? "sí" : "no"
        return "v\(v) (\(b)) · sistema \(modo) · paleta \(CNC.tema.oscuro ? "oscura" : "clara") · pareja \(pareja)"
    }

    /// Lo último que se supo del tema, para pintar desde el primer fotograma.
    func temaGuardado() {
        guard let j = UserDefaults.standard.string(forKey: "cnTema"), j.count > 2 else { return }
        if let p = CNPaletaTema.desde(json: j) { CNC.tema = p }
    }
}

// ── Pantalla «Movimientos» NATIVA ──────────────────────────────────────────
// Título arriba (se va con el scroll), búsqueda sticky en liquid glass real
// (material) y la lista agrupada por día. Los datos vienen del web.
/// Botón redondo de 44pt (el tamaño táctil por defecto de iOS) con Liquid Glass.
struct CNBotonVidrio: View {
    let icono: String
    var acento: Bool = false
    var accion: () -> Void
    var body: some View {
        Button(action: accion) {
            Image(systemName: icono)
                .font(cnLetra(17, .semibold))
                .foregroundColor(acento ? CNC.sobreAcc : .primary)
                .frame(width: 44, height: 44)
                .cnVidrio(Circle(), tinte: acento ? CNC.acc : nil)
        }
        .buttonStyle(.plain)
    }
}

/// Menú nativo (el del sistema) con el mismo botón de vidrio: filtros y
/// acciones salen pegados a su botón, como en cualquier app de iOS.
struct CNMenuVidrio<C: View>: View {
    let icono: String
    var acento: Bool = false
    var activo: Bool = false
    var lado: CGFloat = 44
    /// Color del glifo (blanco cuando va sobre la franja de la cabecera).
    var color: Color? = nil
    @ViewBuilder var contenido: () -> C
    var body: some View {
        Menu {
            contenido()
        } label: {
            Image(systemName: icono)
                .font(.system(size: acento ? 20 : 17, weight: .semibold))
                .foregroundColor(acento ? CNC.sobreAcc : (color ?? CNC.ink))
                .frame(width: lado, height: lado)
                .cnVidrio(Circle(), tinte: acento ? CNC.acc : (activo ? CNC.acc.opacity(0.5) : nil))
        }
    }
}

struct CNMovs: View {
    @ObservedObject var datos: CNDatos
    /// Solo para el banco de pruebas: rodar sola para ver el buscador fijo.
    var rodarAlEmpezar = false
    @State private var q = ""
    /// Los mismos filtros de la web, pero en menús del sistema.
    @State private var filtro = 0
    @State private var periodo = 0
    private static let filtros = ["Todos", "Ingresos", "Gastos", "Fijos", "Variables", "Ahorro"]
    private static let periodos = ["Todo", "Este mes", "Mes pasado", "Últimos 3 meses"]

    private var movimientos: [CNMov] {
        var t = datos.libreta.tx.sorted(by: CNMov.masNuevaPrimero)
        switch filtro {
        case 1: t = t.filter { $0.esIngreso }
        case 2: t = t.filter { !$0.esIngreso && !$0.esTransfer }
        case 3: t = t.filter { $0.tipo.lowercased().contains("fijo") }
        case 4: t = t.filter { $0.tipo.lowercased().contains("variable") }
        case 5: t = t.filter { $0.tipo.lowercased().contains("ahorro") }
        default: break
        }
        if periodo > 0 {
            let cal = Calendar.current, hoy = Date()
            let f = CNFormateadores.iso
            t = t.filter { m in
                guard let d = f.date(from: m.fecha) else { return true }
                switch periodo {
                case 1: return cal.isDate(d, equalTo: hoy, toGranularity: .month)
                case 2:
                    guard let anterior = cal.date(byAdding: .month, value: -1, to: hoy) else { return true }
                    return cal.isDate(d, equalTo: anterior, toGranularity: .month)
                default:
                    guard let desde = cal.date(byAdding: .month, value: -3, to: hoy) else { return true }
                    return d >= desde
                }
            }
        }
        guard !q.isEmpty else { return t }
        // SIN TILDES, como en la web. Bajando solo a minúsculas, quien escribe
        // «cafe» no encuentra «Café»: en un teclado de teléfono la tilde cuesta,
        // y una búsqueda que obliga a ponerla es una búsqueda que no se usa.
        let n = CNMovimientos.normal(q)
        return t.filter { CNMovimientos.normal($0.concepto + " " + $0.categoria).contains(n) }
    }
    private var porDia: [(String, [CNMov])] {
        var orden: [String] = []; var mapa: [String: [CNMov]] = [:]
        for m in movimientos { if mapa[m.fecha] == nil { orden.append(m.fecha) }; mapa[m.fecha, default: []].append(m) }
        return orden.map { ($0, mapa[$0] ?? []) }
    }
    /*
     * CON QUÉ SE PAGÓ, EN EL IDIOMA DE LA APP.
     *
     * «Efectivo» iba a pelo, sin pasar por el diccionario, y el nombre de la
     * cuenta tampoco: con la app en inglés la lista de movimientos decía
     * «Efectivo» debajo de cada fila. El nombre de fábrica de una cuenta es un
     * texto nuestro, no algo que haya escrito nadie, y por eso se traduce; uno
     * que no esté en el diccionario —el que ponga cada quien— sale tal cual,
     * que es justo lo que tiene que pasar.
     */
    private func medioNombre(_ medio: String) -> String {
        if medio.hasPrefix("cuenta:"), let id = Int(medio.dropFirst(7)),
           let c = datos.libreta.cuentas.first(where: { $0.id == id }) { return cnT(c.nombre) }
        if medio.hasPrefix("tarjeta:"), let id = Int(medio.dropFirst(8)),
           let t = datos.libreta.tarjetas.first(where: { $0.id == id }) { return cnT(t.nombre) }
        return cnT("Efectivo")
    }

    var body: some View {
        // LA BARRA DE ARRIBA ES DE IOS, no un dibujo.
        //
        // Antes el título grande, el buscador y los botones estaban hechos a
        // mano: un Text de 34 pt, un TextField dentro de una cápsula y unos
        // círculos. Se parecía, pero no era: ni el título encogía como el del
        // sistema, ni el buscador se comportaba como el del sistema, ni los
        // botones traían la cápsula de vidrio de iOS 26. Ahora lo pone el
        // sistema: `navigationTitle` grande, `searchable` y `toolbar`.
        NavigationView {
            // Una `List` agrupada DE VERDAD, no tarjetas dibujadas: los mismos
            // márgenes, el mismo redondeo, las mismas rayas y las mismas
            // cabeceras de sección que el Perfil o la pantalla de un
            // movimiento. Era lo que hacía que estas dos listas se vieran de
            // otra app que el resto.
            List {
                if porDia.isEmpty {
                    Section { vacio }.listRowBackground(Color.clear)
                }
                ForEach(porDia.indices, id: \.self) { i in
                    Section {
                        ForEach(porDia[i].1) { m in fila(m) }
                    } header: {
                        // El espía va COLGADO de la cabecera, no como fila: una
                        // fila, aunque mida cero, se lleva su hueco y su raya.
                        // Una superposición no ocupa sitio.
                        cabeceraDia(porDia[i].0, porDia[i].1)
                            .overlay(alignment: .top) { if i == 0 { espia } }
                    }
                }
                // El hueco de abajo lo pone el margen seguro que el contenedor
                // le añade por la barra flotante; aquí no hace falta nada.
                if rodarAlEmpezar {
                    Section { Color.clear.frame(height: 800).id("cnAbajo") }
                        .listRowBackground(Color.clear).listRowInsets(EdgeInsets())
                }
            }
            .listStyle(.insetGrouped)
            .modifier(CNFondoLista())
            .background(CNC.scr.ignoresSafeArea())
            .navigationTitle(cnT("Movimientos"))
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $q,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: Text(cnT("Buscar movimiento…")))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Picker("", selection: $periodo) {
                            ForEach(CNMovs.periodos.indices, id: \.self) { i in
                                Text(cnT(CNMovs.periodos[i])).tag(i)
                            }
                        }
                    } label: {
                        Image(systemName: periodo > 0 ? "calendar.badge.clock" : "calendar")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("", selection: $filtro) {
                            ForEach(CNMovs.filtros.indices, id: \.self) { i in
                                Text(cnT(CNMovs.filtros[i])).tag(i)
                            }
                        }
                    } label: {
                        Image(systemName: filtro > 0
                              ? "line.3.horizontal.decrease.circle.fill"
                              : "line.3.horizontal.decrease.circle")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { datos.onNuevoMov() } label: { Image(systemName: "plus") }
                }
            }
        }
        .navigationViewStyle(.stack)
        .tint(CNC.pos)
    }

    /// Mira por dónde va el scroll (para encoger la barra de abajo) sin ocupar
    /// sitio: fila de alto cero, sin fondo, sin margen y sin raya.
    private var espia: some View {
        CNEspiaScroll { CNScrollEstado.shared.mirar($0) }
            .frame(height: 0)
            .allowsHitTesting(false)
    }

    /// El día y lo que dejó: una cabecera de sección, con la letra y el tono
    /// que el sistema le da a las suyas.
    private func cabeceraDia(_ fecha: String, _ items: [CNMov]) -> some View {
        let total = items.reduce(0.0) { $0 + ($1.esIngreso ? abs($1.monto) : ($1.esTransfer ? 0 : -abs($1.monto))) }
        return HStack {
            Text(cnDiaLargo(fecha))
            Spacer(minLength: 8)
            Text((total >= 0 ? "+" : "−") + cnDinero(total))
        }
        .font(cnLetra(13, .semibold))
        .foregroundColor(CNC.pmut)
        .textCase(nil)
    }

    /**
     * El trazo del icono de un movimiento: el que mandó la web, o el que le
     * toca a su categoría por la libreta.
     *
     * Aparte y no dentro del `if` por dos razones. La primera es que ahí dentro
     * la expresión encadenaba dos opcionales y una llamada, y el comprobador de
     * tipos de SwiftUI se atragantaba con ella. La segunda es que así se lee.
     */
    private func pathDeCategoria(_ m: CNMov, _ ic: CNResumenModelo.IconoCat?) -> String? {
        if let p = ic?.path, !p.isEmpty { return p }
        return CNIconos.paths[CNCategorias.icono(m.categoria, en: datos.libreta)]
    }

    private func fila(_ m: CNMov) -> some View {
        let entra = m.esIngreso
        let color: Color = entra ? CNC.pos : (m.esTransfer ? CNC.ink : CNC.neg)
        // El icono y el color los manda la web si los mandó, y si no los saca
        // `CNCategorias` de la propia libreta.
        //
        // Venían SOLO de la web, y del modelo del RESUMEN además: entrando
        // directo a Movimientos —abriendo la app en esta pestaña, o volviendo a
        // ella— el resumen podía no haber llegado todavía y la lista salía
        // entera con el mismo iconito ámbar. No fallaba: se leía peor, y solo a
        // veces, que es lo difícil de ver.
        let ic = datos.resumen?.catIconos[m.categoria]
        let propio = CNCategorias.color(m.categoria, en: datos.libreta)
        let tinte = entra ? CNC.pos : (m.esTransfer ? CNC.info
                                       : (ic.map { cnColor(hexString: $0.color) }
                                          ?? cnColor(hexString: propio)))
        return Button { datos.onDetalleMov(m.id) } label: {
            HStack(spacing: 12) {
                Group {
                    if entra {
                        cnGlifo("banknote.fill", tam: 17)
                    } else if m.esTransfer {
                        cnGlifo("arrow.left.arrow.right", tam: 17)
                    } else if let p = pathDeCategoria(m, ic), !p.isEmpty {
                        // El de la web si lo mandó; si no, el que le toca a la
                        // categoría por la libreta. La etiqueta genérica queda
                        // solo para una categoría que no esté ni en el catálogo.
                        CNSVGShape(d: p)
                            .stroke(style: StrokeStyle(lineWidth: 1.9, lineCap: .round, lineJoin: .round))
                            .frame(width: 18, height: 18)
                    } else {
                        cnGlifo("tag.fill", tam: 17)
                    }
                }
                .foregroundColor(tinte)
                .frame(width: 34, height: 34)
                .background(tinte.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                VStack(alignment: .leading, spacing: 2) {
                    Text(m.concepto.isEmpty ? cnT(m.categoria) : m.concepto).font(cnLetra(15, .semibold)).foregroundColor(CNC.ink)
                        .lineLimit(1)
                    Text("\(cnT(m.categoria)) · \(medioNombre(m.medio))").font(cnLetra(11.5)).foregroundColor(CNC.pmut).lineLimit(1)
                }
                Spacer(minLength: 6)
                Text((entra ? "+ " : (m.esTransfer ? "" : "− ")) + cnDinero(m.monto)).font(cnLetra(15, .heavy)).foregroundColor(color)
            }
            .padding(.vertical, 5)
        }
        .buttonStyle(.plain)
        // Mantener pulsado: las mismas acciones, en el menú del sistema.
        .contextMenu {
            Button { datos.onDetalleMov(m.id) } label: { Label(cnT("Ver detalle"), systemImage: "doc.text.magnifyingglass") }
            Button { datos.onAccion("editarMov", m.id) } label: { Label(cnT("Editar"), systemImage: "pencil") }
            Button(role: .destructive) { datos.onBorrarMov(m.id) } label: { Label(cnT("Eliminar"), systemImage: "trash") }
        }
    }

    private var vacio: some View {
        VStack(spacing: 6) {
            Text(cnT("No hay movimientos")).font(cnLetra(15, .bold)).foregroundColor(CNC.ink)
            Text(cnT("Aquí saldrá lo que anotes este mes.")).font(cnLetra(13.5)).foregroundColor(CNC.pmut)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 26)
        .background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

}

/// La franja de color de la cabecera: la misma en Movimientos, Cuentas y Plan,
/// para que las pantallas nativas y las de la web se lean como una sola app.
struct CNFranja<Acciones: View, Debajo: View>: View {
    let titulo: String
    @ViewBuilder var acciones: () -> Acciones
    @ViewBuilder var debajo: () -> Debajo
    var body: some View {
        VStack(spacing: 11) {
            HStack(alignment: .center, spacing: 10) {
                Text(titulo).font(cnLetra(26, .heavy)).foregroundColor(.white)
                    .lineLimit(1).minimumScaleFactor(0.8)
                Spacer(minLength: 8)
                acciones()
            }
            debajo()
        }
        .padding(.horizontal, 16).padding(.top, 4).padding(.bottom, 14)
        .background(CNC.side.ignoresSafeArea(edges: .top))
    }
}

/// El botón redondo de acción principal («+»), en vidrio tintado con el acento.
struct CNCirculoAcento: View {
    let icono: String
    var accion: () -> Void
    var body: some View {
        Button(action: accion) {
            Image(systemName: icono).font(cnLetra(20, .semibold))
                .foregroundColor(CNC.sobreAcc)
                .frame(width: 46, height: 46)
                .cnVidrio(Circle(), tinte: CNC.acc)
                .shadow(color: CNC.acc.opacity(0.35), radius: 10, y: 4)
        }.buttonStyle(.plain)
    }
}

// Helper de color por si acaso (mismo que cnColor).
extension Color { init(cnHex: UInt) { self = cnColor(cnHex) } }

// ── Barra de menú NATIVA (liquid glass) ─────────────────────────────────────
// Vive encima del webview y cambia de pestaña llamando a la web. El material
// translúcido deja pasar el contenido por detrás, como el menú de iOS 26.
final class CNMenuEstado: ObservableObject {
    static let shared = CNMenuEstado()
    @Published var activa: String = "resumen"
    @Published var titulos: Bool = true
    /*
     * EL SELLO DEL IDIOMA.
     *
     * Los nombres de las pestañas se sacan con `cnT` al dibujar, y `cnT` lee
     * una tabla estática: cambiarla no le dice nada a SwiftUI, que solo repinta
     * cuando cambia algo que observa. Como la barra solo observaba `activa` y
     * `titulos`, al cambiar de idioma se quedaba con los nombres de antes hasta
     * que tocabas otra pestaña o cerrabas la app.
     */
    @Published var sello = 0
    var alTocar: (String) -> Void = { _ in }
    /// Lo pone el contenedor: repinta la barra de UIKit cuando la web avisa de
    /// un cambio (pestaña activa, títulos, tema).
    var alRepintar: () -> Void = {}
    /// Un aviso corto de la web, para dibujarlo en nativo.
    var alAviso: (String, String) -> Void = { _, _ in }
    /// La web avisa de que la subpantalla abierta cambió (llegó algo del servidor).
    var alSeccion: () -> Void = {}
}

/// Las 5 pestañas, en un solo sitio (las usa la barra nativa UITabBar).
enum CNTabs {
    struct T { let id: String; let titulo: String; let path: String }
    static let todas: [T] = [
        .init(id: "resumen", titulo: "Resumen", path: CNTabIcono.resumen),
        .init(id: "movs", titulo: "Movs", path: CNTabIcono.movs),
        .init(id: "cuentas", titulo: "Cuentas", path: CNTabIcono.cuentas),
        .init(id: "plan", titulo: "Plan", path: CNTabIcono.plan),
        .init(id: "perfil", titulo: "Perfil", path: CNTabIcono.perfil)
    ]
}

/// EL MENÚ, con un `UITabBar` de VERDAD.
///
/// En iOS 26 los controles de UIKit traen el Liquid Glass del sistema: la lente
/// que se desliza hasta la pestaña elegida, el brillo de los bordes y el
/// morfeo al hacer scroll. Una barra dibujada a mano (aunque se meta dentro de
/// un UIVisualEffectView) NO tiene nada de eso: se ve como cristal, pero está
/// quieta. Es la misma solución que en Batuta.
/// Quién manda si la barra de abajo va entera o encogida.
///
/// Todas las pantallas nativas le cuentan cuánto se ha rodado; al bajar se
/// encoge (los rótulos se van y queda solo el icono) y al subir vuelve a su
/// tamaño, como hacen las apps del teléfono.
final class CNScrollEstado {
    static let shared = CNScrollEstado()
    private var ultimo: CGFloat = 0
    private(set) var compacto = false
    var alCambiar: (Bool) -> Void = { _ in }

    func mirar(_ y: CGFloat) {
        // Arriba del todo, siempre entera.
        if y <= 4 { poner(false); ultimo = y; return }
        if y > ultimo + 6 { poner(true); ultimo = y }
        else if y < ultimo - 6 { poner(false); ultimo = y }
    }
    func reiniciar() { ultimo = 0; poner(false) }
    private func poner(_ v: Bool) {
        guard v != compacto else { return }
        compacto = v
        alCambiar(v)
    }
}

extension UIImage {
    /// La misma imagen, más tenue. Para el icono apagado del menú.
    func withAlphaComponent(_ a: CGFloat) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size), blendMode: .normal, alpha: a)
        }
    }
}

final class CNBarraNativa: NSObject, UITabBarDelegate {
    let barra = UITabBar()
    private var ids: [String] = []
    private var conTitulos = true
    /*
     * CON QUÉ RÓTULOS SE ARMÓ LA BARRA.
     *
     * Los nombres de las pestañas van DIBUJADOS DENTRO de la imagen de cada
     * una —es la única forma de que iOS 26 no los corte en «Cu...»—, así que
     * cambiar de idioma no los cambia: la imagen ya está hecha. Y la barra solo
     * se rehacía al encender o apagar los rótulos, nunca por el idioma.
     *
     * Resultado: cambiabas la app a inglés y abajo seguía poniendo «Cuentas» y
     * «Perfil» hasta que cerrabas la app y la volvías a abrir.
     */
    private var conRotulos = ""
    /// Encogida: solo iconos, y más baja.
    private var compacto = false
    private var altoC: NSLayoutConstraint?
    private weak var anfitriona: UIView?
    var alTocar: (String) -> Void = { _ in }

    /// Mantener pulsado un botón del menú: el atajo de esa pestaña (anotar,
    /// agregar una cuenta…) sin tener que ir a la pantalla primero.
    var alMantener: (String) -> Void = { _ in }

    func montar(en vista: UIView) {
        barra.translatesAutoresizingMaskIntoConstraints = false
        barra.delegate = self
        // Repartir el ancho A PARTES IGUALES entre las cinco. Suelta, la barra
        // le da a cada opción lo que su texto pide y luego recorta a las que no
        // caben: salían «Cu...» y «Pe...» mientras «Resumen» cabía entera.
        barra.itemPositioning = .fill
        barra.itemSpacing = 0
        barra.itemWidth = 0
        let largo = UILongPressGestureRecognizer(target: self, action: #selector(mantenido(_:)))
        largo.minimumPressDuration = 0.4
        largo.cancelsTouchesInView = false
        barra.addGestureRecognizer(largo)
        vista.addSubview(barra)
        // El alto a mano. Una UITabBar SUELTA (fuera de un UITabBarController)
        // recibe el margen seguro de abajo pero NO lo suma a su alto: se queda
        // en 49 pt, le descuenta los 34 del indicador y deja 15 para el
        // contenido; ahí es donde el rótulo se subía encima del icono.
        let alto = barra.heightAnchor.constraint(equalToConstant: 49)
        altoC = alto
        anfitriona = vista
        NSLayoutConstraint.activate([
            barra.leadingAnchor.constraint(equalTo: vista.leadingAnchor),
            barra.trailingAnchor.constraint(equalTo: vista.trailingAnchor),
            barra.bottomAnchor.constraint(equalTo: vista.bottomAnchor),
            alto
        ])
        rehacer()
        ajustar()
    }

    /// Hay que llamarla cuando cambie el margen seguro (al girar, al aparecer).
    func ajustar() {
        let abajo = anfitriona?.safeAreaInsets.bottom ?? 0
        let nuevo = (conTitulos ? 58 : 52) + abajo
        if altoC?.constant != nuevo { altoC?.constant = nuevo }
    }

    /// Encoger la barra ENTERA al bajar y devolverla a su tamaño al subir.
    ///
    /// Se encoge la pieza completa —el vidrio y todo lo que lleva dentro—, no
    /// se le quitan los rótulos: son dos cosas distintas. Se escala desde el
    /// borde de abajo para que no se despegue del filo de la pantalla.
    func compactar(_ on: Bool) {
        guard on != compacto else { return }
        compacto = on
        let alto = barra.bounds.height
        UIView.animate(withDuration: 0.26, delay: 0,
                       usingSpringWithDamping: 0.9, initialSpringVelocity: 0,
                       options: [.curveEaseOut, .allowUserInteraction]) {
            if on {
                let e: CGFloat = 0.84
                self.barra.transform = CGAffineTransform(translationX: 0, y: (1 - e) * alto / 2)
                    .scaledBy(x: e, y: e)
            } else {
                self.barra.transform = .identity
            }
        }
    }


    /// Alto de la imagen compuesta: icono, hueco y nombre.
    private static let altoIcono: CGFloat = 23
    private static let hueco: CGFloat = 3
    private static let altoTexto: CGFloat = 12

    /// La tinta de la pestaña. Va DENTRO de la imagen, así que se decide aquí.
    ///
    /// Apagada no es `secondaryLabel`: ese gris es tan claro que las opciones
    /// se confundían con lo que pasa por detrás del vidrio. Va casi a tinta
    /// llena; lo que distingue a la puesta es el verde y la lente, no que las
    /// demás se borren.
    static func tintaTab(_ puesta: Bool) -> UIColor {
        puesta ? UIColor(CNC.pos) : UIColor.label.withAlphaComponent(0.92)
    }

    /// ICONO Y NOMBRE EN UNA IMAGEN, ya del color que toca.
    static func conNombre(_ path: String, _ nombre: String, puesta: Bool) -> UIImage {
        let fuente = UIFont.systemFont(ofSize: 10, weight: puesta ? .semibold : .medium)
        let tinta = tintaTab(puesta)
        let atrib: [NSAttributedString.Key: Any] = [.font: fuente, .foregroundColor: tinta]
        let medida = (nombre as NSString).size(withAttributes: atrib)
        let ancho = max(altoIcono, ceil(medida.width))
        let alto = altoIcono + hueco + altoTexto
        let img = UIGraphicsImageRenderer(size: CGSize(width: ancho, height: alto)).image { _ in
            let icono = cnIconoUIImage(path, lado: altoIcono, grosor: 2.6)
                .withTintColor(tinta, renderingMode: .alwaysOriginal)
            icono.draw(in: CGRect(x: (ancho - altoIcono) / 2, y: 0, width: altoIcono, height: altoIcono))
            (nombre as NSString).draw(
                in: CGRect(x: (ancho - medida.width) / 2, y: altoIcono + hueco,
                           width: medida.width, height: altoTexto),
                withAttributes: atrib)
        }
        return img.withRenderingMode(.alwaysOriginal)
    }

    /// EL ICONO DE PERFIL: EL DE SIEMPRE, COMO LOS DEMÁS.
    ///
    /// Aquí se pisaba el icono de la pestaña con el dibujo de Chino. Con Chino
    /// ya en su propio botón flotante —con su cara y su ánimo— tenerlo también
    /// en la barra era tenerlo dos veces en pantalla, y además descuadraba la
    /// fila: cuatro trazos finos y un dibujo a color en medio.
    ///
    /// La barra ya crea el icono de Perfil igual que los otros cuatro, con su
    /// mismo trazo y su mismo color. Así que lo único que hay que hacer es no
    /// tocarlo. Esto se queda como puerta —lo llaman dos sitios cuando llega un
    /// dibujo nuevo— para que quede dicho que el dibujo ya no va ahí.
    func ponerChinolo(_ b64: String) { }

    /// El mismo truco que `conNombre`, pero partiendo de un dibujo ya hecho (el
    /// de Chino o el círculo con la inicial): se le pone el nombre debajo. Sin
    /// rótulos devuelve el dibujo tal cual.
    static func bajoNombre(_ dibujo: UIImage, _ nombre: String, puesta: Bool) -> UIImage {
        guard CNMenuEstado.shared.titulos else { return dibujo.withRenderingMode(.alwaysOriginal) }
        let fuente = UIFont.systemFont(ofSize: 10, weight: puesta ? .semibold : .medium)
        let atrib: [NSAttributedString.Key: Any] = [.font: fuente, .foregroundColor: tintaTab(puesta)]
        let medida = (nombre as NSString).size(withAttributes: atrib)
        let ancho = max(dibujo.size.width, ceil(medida.width))
        let alto = dibujo.size.height + hueco + altoTexto
        let img = UIGraphicsImageRenderer(size: CGSize(width: ancho, height: alto)).image { _ in
            dibujo.draw(in: CGRect(x: (ancho - dibujo.size.width) / 2, y: 0,
                                   width: dibujo.size.width, height: dibujo.size.height))
            (nombre as NSString).draw(
                in: CGRect(x: (ancho - medida.width) / 2, y: dibujo.size.height + hueco,
                           width: medida.width, height: altoTexto),
                withAttributes: atrib)
        }
        return img.withRenderingMode(.alwaysOriginal)
    }

    /// El icono redondo del perfil: la silueta dentro de un aro, como el de
    /// otras apps. Apagado, aro y silueta finos en gris; puesto, el aro y la
    /// silueta gruesos, del color del tema. Del tamaño de los demás iconos.
    private static func redondo(_ inicial: String, puesto: Bool) -> UIImage {
        let lado: CGFloat = 26
        return UIGraphicsImageRenderer(size: CGSize(width: lado, height: lado)).image { _ in
            let tinta = puesto ? UIColor(CNC.pos) : UIColor(CNC.pmut)
            let grosor: CGFloat = puesto ? 2.6 : 2.2
            let aro = UIBezierPath(ovalIn: CGRect(x: 1.5, y: 1.5, width: lado - 3, height: lado - 3))
            aro.lineWidth = grosor; tinta.setStroke(); aro.stroke()
            // La cabeza.
            let cabeza = UIBezierPath(ovalIn: CGRect(x: lado / 2 - 3.6, y: 6.2, width: 7.2, height: 7.2))
            cabeza.lineWidth = grosor; cabeza.stroke()
            // Los hombros: un arco que se recorta contra el aro.
            let hombros = UIBezierPath(arcCenter: CGPoint(x: lado / 2, y: lado - 4.2), radius: 6.6,
                                       startAngle: .pi * 1.12, endAngle: .pi * 1.88, clockwise: true)
            hombros.lineWidth = grosor; hombros.lineCapStyle = .round; hombros.stroke()
        }
    }
    private static func enGris(_ img: UIImage) -> UIImage? {
        guard let ci = CIImage(image: img),
              let f = CIFilter(name: "CIColorControls") else { return nil }
        f.setValue(ci, forKey: kCIInputImageKey)
        f.setValue(0, forKey: kCIInputSaturationKey)
        f.setValue(-0.08, forKey: kCIInputBrightnessKey)
        guard let salida = f.outputImage,
              let cg = CIContext().createCGImage(salida, from: salida.extent) else { return nil }
        return UIImage(cgImage: cg, scale: img.scale, orientation: img.imageOrientation)
            .withAlphaComponent(0.72)
    }

    @objc private func mantenido(_ g: UILongPressGestureRecognizer) {
        guard g.state == .began, !ids.isEmpty else { return }
        let x = g.location(in: barra).x
        let ancho = barra.bounds.width / CGFloat(ids.count)
        let i = min(ids.count - 1, max(0, Int(x / max(1, ancho))))
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        alMantener(ids[i])
    }

    private func rehacer() {
        var items: [UITabBarItem] = []
        ids = []
        // Sin nombres: además de dejar el título en nil, se le quita el color al
        // rótulo en la apariencia y se centra el icono. Un UITabBar suelto no
        // siempre hace caso al nil —los nombres seguían saliendo—, y esto sí,
        // sin tocar el fondo (que es de donde sale el vidrio del sistema).
        let ap = barra.standardAppearance
        for st in [ap.stackedLayoutAppearance, ap.inlineLayoutAppearance, ap.compactInlineLayoutAppearance] {
            if conTitulos {
                // La letra del SISTEMA y un punto más pequeña que la de la
                // app. Con la tipografía propia los rótulos salían más anchos
                // de lo que la barra reparte y los cortaba en «Cu...», «Pe...»;
                // la pestaña puesta se lleva una cápsula más ancha y a las
                // otras les queda menos sitio, así que hay que ser modesto.
                st.normal.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 10, weight: .medium)]
                st.selected.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 10, weight: .semibold)]
            } else {
                st.normal.titleTextAttributes = [.foregroundColor: UIColor.clear,
                                                 .font: UIFont.systemFont(ofSize: 0.1)]
                st.selected.titleTextAttributes = [.foregroundColor: UIColor.clear,
                                                   .font: UIFont.systemFont(ofSize: 0.1)]
            }
        }
        barra.standardAppearance = ap
        if #available(iOS 15.0, *) { barra.scrollEdgeAppearance = ap }
        for (i, t) in CNTabs.todas.enumerated() {
            let nombre = cnT(t.titulo)
            let item: UITabBarItem
            if conTitulos {
                // EL ICONO Y EL RÓTULO, EN UNA SOLA IMAGEN.
                //
                // Suelta, esta barra mide mal los rótulos en iOS 26: al texto
                // de algunas pestañas le daba el ancho del icono —23 pt— y las
                // escribía «Cu...», «Pe...», «M...». No dependía del largo del
                // texto («Plan» cabía y «Movs» no), no hay forma pública de
                // corregir la medida y retocar los marcos a mano no sirve:
                // UIKit los rehace después. Dibujando el nombre DENTRO de la
                // imagen no queda nada que medir. Es lo mismo que ya se hacía
                // con la pestaña de Perfil.
                item = UITabBarItem(title: nil,
                                    image: CNBarraNativa.conNombre(t.path, nombre, puesta: false),
                                    tag: i)
                item.selectedImage = CNBarraNativa.conNombre(t.path, nombre, puesta: true)
                item.imageInsets = .zero
            } else {
                // Más grandes y más gruesos: en una barra de cinco, un trazo
                // fino se pierde.
                let img = cnIconoUIImage(t.path, lado: 23, grosor: 2.6).withRenderingMode(.alwaysTemplate)
                item = UITabBarItem(title: nil, image: img, tag: i)
                // Sin rótulo el icono se centra solo bajándolo un poco.
                item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
            }
            item.accessibilityLabel = nombre
            items.append(item); ids.append(t.id)
        }
        conRotulos = CNTabs.todas.map { cnT($0.titulo) }.joined(separator: "·")
        let antes = barra.selectedItem?.tag
        barra.setItems(items, animated: false)
        if let t = antes, t < items.count { barra.selectedItem = items[t] }
    }

    /// Pestaña activa, títulos y colores del tema.
    func pintar(activa: String, titulos: Bool) {
        let rotulos = CNTabs.todas.map { cnT($0.titulo) }.joined(separator: "·")
        if titulos != conTitulos || rotulos != conRotulos {
            conTitulos = titulos
            conRotulos = rotulos
            rehacer(); ajustar()
        }
        barra.tintColor = UIColor(CNC.pos)
        barra.overrideUserInterfaceStyle = CNC.tema.oscuro ? .dark : .light
        if let i = ids.firstIndex(of: activa), let items = barra.items, i < items.count,
           barra.selectedItem !== items[i] {
            barra.selectedItem = items[i]
        }
    }

    var alto: CGFloat { max(barra.frame.height, altoC?.constant ?? 49) }

    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard item.tag >= 0, item.tag < ids.count else { return }
        UISelectionFeedbackGenerator().selectionChanged()
        alTocar(ids[item.tag])
    }
}

struct CNBarraMenu: View {
    @ObservedObject var estado: CNMenuEstado
    /// false = el vidrio lo pone UIKit (UIGlassEffect) por fuera.
    var conFondo: Bool = true
    struct Item { let id: String; let label: String; let path: String }
    let items: [Item] = [
        .init(id: "resumen", label: "Resumen", path: CNTabIcono.resumen),
        .init(id: "movs", label: "Movs.", path: CNTabIcono.movs),
        .init(id: "cuentas", label: "Cuentas", path: CNTabIcono.cuentas),
        .init(id: "plan", label: "Plan", path: CNTabIcono.plan),
        .init(id: "perfil", label: "Perfil", path: CNTabIcono.perfil)
    ]
    var body: some View {
        // Leer el sello es lo que ata este dibujo al idioma: `cnT` devuelve lo
        // nuevo, pero sin esto nadie vuelve a llamarlo.
        let _ = estado.sello
        return HStack(spacing: 4) {
            ForEach(items, id: \.id) { it in
                let sel = estado.activa == it.id
                Button { estado.alTocar(it.id) } label: {
                    VStack(spacing: 3) {
                        CNIconoTab(d: it.path).frame(height: 25)
                        if estado.titulos {
                            Text(cnT(it.label)).font(cnLetra(10.5, .semibold))
                        }
                    }
                    .foregroundColor(sel ? CNC.pos : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 7)
                    // LA LENTE: cápsula de vidrio sobre la opción activa.
                    .background(lente(sel))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 6)
        .padding(.top, estado.titulos ? 7 : 11)
        .padding(.bottom, 7)
        .modifier(CNVidrio(activo: conFondo))
        .padding(.horizontal, conFondo ? 16 : 0)
        .padding(.bottom, conFondo ? 2 : 0)
    }

    @ViewBuilder private func lente(_ sel: Bool) -> some View {
        if sel {
            if #available(iOS 26.0, *) {
                Capsule().fill(.clear).glassEffect(.regular.interactive(), in: Capsule())
            } else {
                Capsule().fill(Color.white.opacity(0.18))
                    .overlay(Capsule().stroke(Color.white.opacity(0.38), lineWidth: 1))
            }
        }
    }
}

/// El vidrio de la barra. En iOS 26 usa **Liquid Glass de verdad**
/// (`.glassEffect`): transparente, con refracción en los bordes y brillo, como la
/// barra de Apple Music. En iOS anteriores no existe esa API, así que cae al
/// material esmerilado (lo mejor disponible ahí).
struct CNVidrio: ViewModifier {
    var activo: Bool = true
    func body(content: Content) -> some View {
        if !activo {
            content
        } else if #available(iOS 26.0, *) {
            content
                .glassEffect(.regular.interactive(), in: Capsule())
                .shadow(color: .black.opacity(0.18), radius: 26, y: 10)
        } else {
            content
                .background(
                    Capsule().fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.16), radius: 24, y: 8)
                )
                .overlay(Capsule().stroke(Color.white.opacity(0.6), lineWidth: 1))
        }
    }
}

/// Liquid Glass de VERDAD: UIVisualEffectView con UIGlassEffect (iOS 26).
///
/// El .glassEffect() de SwiftUI, dentro de un UIHostingController aislado, se
/// queda en un gris plano: no refracta lo que pasa por detrás. El de UIKit sí,
/// y es el mismo que usa la barra del menú.
struct CNVidrioUIKit: UIViewRepresentable {
    var tinte: UIColor? = nil
    func makeUIView(context: Context) -> UIVisualEffectView {
        var efecto: UIVisualEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        if #available(iOS 26.0, *) {
            let e = UIGlassEffect()
            e.isInteractive = true
            if let t = tinte { e.tintColor = t }
            efecto = e
        }
        let v = UIVisualEffectView(effect: efecto)
        v.isUserInteractionEnabled = false
        v.backgroundColor = .clear
        return v
    }
    func updateUIView(_ v: UIVisualEffectView, context: Context) {}
}

/// Liquid Glass en CUALQUIER forma (círculos de «+», cerrar, búsqueda, botones
/// de las hojas…), recortado a esa forma.
struct CNVidrioForma<S: Shape>: ViewModifier {
    let forma: S
    var tinte: Color? = nil
    func body(content: Content) -> some View {
        content.background(fondo)
    }
    @ViewBuilder private var fondo: some View {
        if let t = tinte {
            // Con color de marca: el color va pintado y el vidrio encima le pone
            // el brillo. Así el botón nunca sale gris, refracte o no el aparato.
            ZStack {
                forma.fill(t)
                CNVidrioUIKit().clipShape(forma).opacity(0.35)
            }
            .overlay(forma.stroke(Color.white.opacity(0.35), lineWidth: 0.8))
            // Sombra neutra y corta. Con el color del botón parecía un bombillo:
            // el amarillo se salía del círculo y teñía lo de alrededor.
            .shadow(color: Color.black.opacity(0.12), radius: 5, y: 2)
        } else {
            // El vidrio solo se ve cuando algo pasa por detrás. Quieto sobre el
            // crema desaparecía —de ahí los botones que casi no se distinguen—,
            // así que lleva un velo con la tinta del tema (clara u oscura,
            // siempre contrasta con su fondo), un filo fino y una sombra corta.
            // Sigue refractando lo que le pasa por debajo: el velo es un 7%.
            ZStack {
                CNVidrioUIKit().clipShape(forma)
                forma.fill(CNC.ink.opacity(0.07))
            }
            .overlay(forma.stroke(CNC.ink.opacity(0.12), lineWidth: 1))
            .shadow(color: Color.black.opacity(0.10), radius: 8, y: 2)
        }
    }
}

extension View {
    /// Vidrio (Liquid Glass en iOS 26) con la forma dada.
    func cnVidrio<S: Shape>(_ forma: S, tinte: Color? = nil) -> some View {
        modifier(CNVidrioForma(forma: forma, tinte: tinte))
    }
}

// ── Pantalla Tendencia (SwiftUI, misma que la nativa) ──────────────────────
struct CNTendencia: View {
    let libreta: CNLibreta
    var onClose: () -> Void = {}

    var body: some View {
        let puntos = libreta.tendencia()
        return VStack(spacing: 0) {
            ZStack {
                Text(cnT("Tendencia")).font(cnLetra(17, .bold)).foregroundColor(CNC.ink)
                HStack {
                    Button(action: onClose) {
                        Image(systemName: "xmark").font(cnLetra(17, .semibold)).foregroundColor(CNC.pmut)
                            .frame(width: 44, height: 44).cnVidrio(Circle())
                            .shadow(color: .black.opacity(0.10), radius: 6, y: 2)
                    }
                    Spacer()
                }
            }
            .padding(.horizontal, 12).padding(.top, 14).padding(.bottom, 4)

            HStack(spacing: 16) {
                Image(systemName: "chevron.left").font(cnLetra(13, .bold)).foregroundColor(CNC.pmut)
                Text(cnT("Últimos 12 meses")).font(cnLetra(15, .semibold)).foregroundColor(CNC.ink)
                Image(systemName: "chevron.right").font(cnLetra(13, .bold)).foregroundColor(CNC.pmut)
            }.padding(.vertical, 8)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(cnT("Patrimonio")).font(cnLetra(14, .semibold)).foregroundColor(CNC.info)
                            Spacer()
                            // Con signo y con su color: en verde a secas, un
                            // patrimonio negativo se lee como si fuera bueno.
                            Text(cnDineroFirmado(libreta.patrimonio)).font(cnLetra(14, .heavy))
                                .foregroundColor(libreta.patrimonio >= 0 ? CNC.pos : CNC.neg)
                        }
                        CNArea(valores: puntos.map { $0.valor }).frame(height: 130)
                    }
                    .padding(16).background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                    VStack(spacing: 0) {
                        let filas = Array(puntos.reversed())
                        ForEach(filas.indices, id: \.self) { i in
                            HStack {
                                Text(filas[i].label).font(cnLetra(15, .semibold)).foregroundColor(CNC.ink)
                                Spacer()
                                VStack(alignment: .trailing, spacing: 1) {
                                    Text(cnDinero(filas[i].valor)).font(cnLetra(15, .heavy)).foregroundColor(CNC.ink)
                                    Text((filas[i].cambio >= 0 ? "+ " : "− ") + cnDinero(filas[i].cambio))
                                        .font(cnLetra(11.5, .bold)).foregroundColor(filas[i].cambio >= 0 ? CNC.pos : CNC.neg)
                                }
                            }
                            .padding(.vertical, 12)
                            if i < filas.count - 1 { Divider().overlay(CNC.line) }
                        }
                    }
                    .padding(.horizontal, 16).background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                    Color.clear.frame(height: 24)
                }
                .padding(.horizontal, 12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(CNC.scr.ignoresSafeArea())
    }
}

struct CNArea: View {
    var valores: [Double] = []
    var body: some View {
        GeometryReader { g in
            let w = g.size.width, h = g.size.height
            let vals = valores.isEmpty ? [0, 0] : valores
            let maxV = max(vals.max() ?? 1, 1), minV = min(vals.min() ?? 0, 0)
            let rango = max(maxV - minV, 1)
            let pts: [CGPoint] = vals.enumerated().map { i, v in
                CGPoint(x: vals.count > 1 ? w * CGFloat(i) / CGFloat(vals.count - 1) : 0,
                        y: h - (h - 8) * CGFloat((v - minV) / rango) - 4)
            }
            ZStack {
                VStack(spacing: 0) { ForEach(0..<4, id: \.self) { _ in Rectangle().fill(CNC.line).frame(height: 1); Spacer() } }
                Path { p in guard let f = pts.first else { return }
                    p.move(to: CGPoint(x: f.x, y: h)); p.addLine(to: f)
                    for q in pts.dropFirst() { p.addLine(to: q) }
                    p.addLine(to: CGPoint(x: pts.last!.x, y: h)); p.closeSubpath() }
                .fill(LinearGradient(colors: [CNC.acc.opacity(0.30), CNC.acc.opacity(0.02)], startPoint: .top, endPoint: .bottom))
                Path { p in guard let f = pts.first else { return }
                    p.move(to: f); for q in pts.dropFirst() { p.addLine(to: q) } }
                .stroke(CNC.acc, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            }
        }
    }
}

// ── Iconos SVG originales del menú (mismos paths que ICONOS_TAB del web) ────
// SwiftUI no entiende SVG; este intérprete mínimo dibuja los paths (M/L/H/V y
// arcos A) para usar los iconos EXACTOS de la app, no aproximaciones SF.
struct CNSVGShape: Shape {
    let d: String
    var viewBox: CGFloat = 24

    /// El dibujo ya interpretado, en las coordenadas del propio SVG (0…24).
    /// SwiftUI pide `path(in:)` en CADA repintado y en cada tamaño, y aquí se
    /// leía la cadena entera —carácter a carácter— todas las veces. Con veinte
    /// iconos en pantalla y una lista rodando eso son miles de lecturas por
    /// segundo, que es parte de por qué la app se sentía pesada y calentaba.
    /// Ahora se lee una vez por dibujo y luego solo se escala y se centra.
    private static let dibujos = CNCache<String, Path>(tope: 256)

    func path(in rect: CGRect) -> Path {
        let e = min(rect.width, rect.height) / viewBox
        let ox = rect.minX + (rect.width - viewBox * e) / 2
        let oy = rect.minY + (rect.height - viewBox * e) / 2
        let base = CNSVGShape.dibujos.valor(d) { crudo() }
        return base.applying(CGAffineTransform(translationX: ox, y: oy).scaledBy(x: e, y: e))
    }

    /// El dibujo tal cual viene, sin escalar ni mover.
    private func crudo() -> Path {
        let s: CGFloat = 1
        let ox: CGFloat = 0
        let oy: CGFloat = 0
        var p = Path(); var cur = CGPoint.zero; var start = CGPoint.zero
        // El último control de una curva: lo necesitan S/s y T/t, que lo
        // reflejan en vez de repetirlo.
        var ctrl = CGPoint.zero
        let pt = { (x: CGFloat, y: CGFloat) in CGPoint(x: ox + x * s, y: oy + y * s) }
        let toks = tokenize(d); var i = 0
        func num() -> CGFloat { let v = toks[i].num; i += 1; return v }
        while i < toks.count {
            let t = toks[i]; guard t.isCmd else { i += 1; continue }
            let c = t.cmd; i += 1
            switch c {
            case "M", "m":
                var x = num(); var y = num(); if c == "m" { x += cur.x; y += cur.y }
                cur = CGPoint(x: x, y: y); start = cur; ctrl = cur; p.move(to: pt(cur.x, cur.y))
                while i < toks.count, !toks[i].isCmd {
                    var lx = num(); var ly = num(); if c == "m" { lx += cur.x; ly += cur.y }
                    cur = CGPoint(x: lx, y: ly); ctrl = cur; p.addLine(to: pt(cur.x, cur.y)) }
            case "L", "l":
                while i < toks.count, !toks[i].isCmd {
                    var x = num(); var y = num(); if c == "l" { x += cur.x; y += cur.y }
                    cur = CGPoint(x: x, y: y); ctrl = cur; p.addLine(to: pt(cur.x, cur.y)) }
            case "H", "h":
                while i < toks.count, !toks[i].isCmd { var x = num(); if c == "h" { x += cur.x }; cur.x = x; p.addLine(to: pt(cur.x, cur.y)) }
            case "V", "v":
                while i < toks.count, !toks[i].isCmd { var y = num(); if c == "v" { y += cur.y }; cur.y = y; p.addLine(to: pt(cur.x, cur.y)) }
            case "A", "a":
                while i < toks.count, !toks[i].isCmd {
                    let rx = num(); _ = num(); _ = num(); let large = num() != 0; let sweep = num() != 0
                    var x = num(); var y = num(); if c == "a" { x += cur.x; y += cur.y }
                    arco(&p, from: cur, to: CGPoint(x: x, y: y), r: rx, large: large, sweep: sweep, pt: pt)
                    cur = CGPoint(x: x, y: y); ctrl = cur }
            case "C", "c":
                while i < toks.count, !toks[i].isCmd {
                    var x1 = num(); var y1 = num(); var x2 = num(); var y2 = num(); var x = num(); var y = num()
                    if c == "c" { x1 += cur.x; y1 += cur.y; x2 += cur.x; y2 += cur.y; x += cur.x; y += cur.y }
                    p.addCurve(to: pt(x, y), control1: pt(x1, y1), control2: pt(x2, y2))
                    ctrl = CGPoint(x: x2, y: y2); cur = CGPoint(x: x, y: y) }
            case "S", "s":
                while i < toks.count, !toks[i].isCmd {
                    var x2 = num(); var y2 = num(); var x = num(); var y = num()
                    if c == "s" { x2 += cur.x; y2 += cur.y; x += cur.x; y += cur.y }
                    let r1 = CGPoint(x: 2 * cur.x - ctrl.x, y: 2 * cur.y - ctrl.y)
                    p.addCurve(to: pt(x, y), control1: pt(r1.x, r1.y), control2: pt(x2, y2))
                    ctrl = CGPoint(x: x2, y: y2); cur = CGPoint(x: x, y: y) }
            case "Q", "q":
                while i < toks.count, !toks[i].isCmd {
                    var x1 = num(); var y1 = num(); var x = num(); var y = num()
                    if c == "q" { x1 += cur.x; y1 += cur.y; x += cur.x; y += cur.y }
                    p.addQuadCurve(to: pt(x, y), control: pt(x1, y1))
                    ctrl = CGPoint(x: x1, y: y1); cur = CGPoint(x: x, y: y) }
            case "T", "t":
                while i < toks.count, !toks[i].isCmd {
                    var x = num(); var y = num(); if c == "t" { x += cur.x; y += cur.y }
                    let r1 = CGPoint(x: 2 * cur.x - ctrl.x, y: 2 * cur.y - ctrl.y)
                    p.addQuadCurve(to: pt(x, y), control: pt(r1.x, r1.y))
                    ctrl = r1; cur = CGPoint(x: x, y: y) }
            case "Z", "z": p.closeSubpath(); cur = start
            default: break
            }
        }
        return p
    }
    private func arco(_ p: inout Path, from a: CGPoint, to b: CGPoint, r: CGFloat, large: Bool, sweep: Bool, pt: (CGFloat, CGFloat) -> CGPoint) {
        let d = hypot(b.x - a.x, b.y - a.y); if d < 0.0001 { return }
        let rr = max(r, d / 2); let mx = (a.x + b.x) / 2, my = (a.y + b.y) / 2
        let ux = -(b.y - a.y) / d, uy = (b.x - a.x) / d
        let h = (rr * rr - d * d / 4).squareRoot(); let sign: CGFloat = (large == sweep) ? -1 : 1
        let cx = mx + sign * ux * h, cy = my + sign * uy * h
        let a1 = atan2(a.y - cy, a.x - cx); var a2 = atan2(b.y - cy, b.x - cx)
        if sweep { if a2 < a1 { a2 += 2 * .pi } } else { if a2 > a1 { a2 -= 2 * .pi } }
        let steps = max(2, Int(abs(a2 - a1) / (.pi / 24)))
        for k in 1...steps { let ang = a1 + (a2 - a1) * CGFloat(k) / CGFloat(steps); p.addLine(to: pt(cx + rr * cos(ang), cy + rr * sin(ang))) }
    }
    private struct Tok { var isCmd = false; var cmd: Character = " "; var num: CGFloat = 0 }
    private func tokenize(_ s: String) -> [Tok] {
        var out: [Tok] = []; var numBuf = ""
        func flush() { if !numBuf.isEmpty { out.append(Tok(isCmd: false, cmd: " ", num: CGFloat(Double(numBuf) ?? 0))); numBuf = "" } }
        for ch in s {
            if ch.isLetter { flush(); out.append(Tok(isCmd: true, cmd: ch, num: 0)) }
            else if ch == "-" { if !numBuf.isEmpty && (numBuf.last == "e" || numBuf.last == "E") { numBuf.append(ch) } else { flush(); numBuf.append(ch) } }
            else if ch == "." { if numBuf.contains(".") { flush() }; numBuf.append(ch) }
            else if ch.isNumber || ch == "e" || ch == "E" { numBuf.append(ch) }
            else { flush() }
        }
        flush(); return out
    }
}

enum CNTabIcono {
    static let resumen =
        "M5 3h3a2 2 0 0 1 2 2v3a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2z"
      + "M16 3h3a2 2 0 0 1 2 2v1a2 2 0 0 1-2 2h-3a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2z"
      + "M16 12h3a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-3a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2z"
      + "M5 14h3a2 2 0 0 1 2 2v3a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-3a2 2 0 0 1 2-2z"
    static let movs = "M7 4.5v15M7 19.5l-3-3M7 19.5l3-3M17 19.5v-15M17 4.5l-3 3M17 4.5l3 3"
    static let cuentas = "M7.5 5.5h9a4 4 0 0 1 4 4v5a4 4 0 0 1-4 4h-9a4 4 0 0 1-4-4v-5a4 4 0 0 1 4-4zM3.5 10h17M7 14.5h3.5"
    static let plan = "M12 3a9 9 0 1 0 0 18 9 9 0 0 0 0-18M12 3.4v7.6a1 1 0 0 0 1 1h7.6"
    static let perfil = "M12 11a4 4 0 1 0 0-8 4 4 0 0 0 0 8M4 21a8 8 0 0 1 16 0"
}

/// Convierte un icono SVG de la app en UIImage (plantilla) para usarlo en un
/// UITabBar nativo — igual que hace Batuta con sus PNG.
func cnIconoUIImage(_ d: String, lado: CGFloat = 26, grosor: CGFloat = 2) -> UIImage {
    let r = UIGraphicsImageRenderer(size: CGSize(width: lado, height: lado))
    let img = r.image { ctx in
        let p = CNSVGShape(d: d).path(in: CGRect(x: 0, y: 0, width: lado, height: lado))
        let c = ctx.cgContext
        c.addPath(p.cgPath)
        c.setLineWidth(grosor)
        c.setLineCap(.round)
        c.setLineJoin(.round)
        c.setStrokeColor(UIColor.label.cgColor)
        c.strokePath()
    }
    return img.withRenderingMode(.alwaysTemplate)
}

struct CNIconoTab: View {
    let d: String
    var body: some View {
        CNSVGShape(d: d).stroke(style: StrokeStyle(lineWidth: 2.3, lineCap: .round, lineJoin: .round)).frame(width: 24, height: 24)
    }
}

// ── Catálogo de iconos (mismos paths que ICONOS del web) ────────────────────
// Para que cuentas, categorías y metas usen EXACTAMENTE los mismos glifos que la
// web, no aproximaciones de SF Symbols.
/**
 * Los colores del tema escritos como texto.
 *
 * Las miniaturas de la cabecera y de los temas llevan sus colores en un modelo
 * que los guarda como cadenas —porque así llegan de la web— y las que arma el
 * teléfono los tienen como `Color`. Esto es el puente entre las dos formas, en
 * un sitio y no repetido en cada sitio que lo necesite.
 */
enum CNIconos {
    /// Los ochenta y cinco glifos, GENERADOS desde la web.
    ///
    /// Estaban escritos aquí a mano, uno por uno, y ya se había desviado
    /// uno: `banco` dibujaba una casa en el teléfono y un banco en la web.
    /// Ochenta y cinco dibujos copiados a mano es una lista que se desvía
    /// sola; ahora salen de `CNCatalogos.swift`, que escribe `npm run sync`
    /// desde el mismo sitio del que los lee la web.
    ///
    /// `let` y no `var`: una propiedad CALCULADA rehace el diccionario entero
    /// en cada acceso, y esto se lee una vez por fila y por fotograma dentro de
    /// una lista. Un `static let` se calcula una sola vez, la primera que hace
    /// falta, y además le deja el tipo claro al comprobador — que con la
    /// versión calculada se atragantaba en una expresión de SwiftUI.
    static let paths: [String: String] = CNCatalogos.iconos
    // El icono que le toca a cada categoría NO vive aquí. Vivía: había un mapa
    // gemelo del de `CNCategorias.porNombre`, palabra por palabra, y no lo usaba
    // nadie. Dos mapas iguales son un mapa y una trampa: el día que alguien
    // añada una categoría, la cambia en uno y se pregunta por qué no sale.
    // `CNCategorias` es el que manda, porque además mira el icono que la persona
    // haya elegido, que este no miraba.
}

// Dibuja un glifo por nombre: si está en el catálogo del diseño lo pinta con
// CNSVGShape (idéntico a la web); si no, cae a un SF Symbol con ese nombre.
@ViewBuilder func cnGlifo(_ nombre: String, tam: CGFloat = 20, grosor: CGFloat = 2) -> some View {
    if let d = CNIconos.paths[nombre] {
        CNSVGShape(d: d).stroke(style: StrokeStyle(lineWidth: grosor, lineCap: .round, lineJoin: .round)).frame(width: tam, height: tam)
    } else {
        Image(systemName: nombre).font(.system(size: tam * 0.82, weight: .semibold))
    }
}

extension View { func tarjetaCN() -> some View {
    self.padding(14).frame(maxWidth: .infinity)
        .background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
} }

// ── Pantallas de DETALLE nativas (al tocar un item) ─────────────────────────
private func cnInicial(_ s: String) -> String {
    let p = s.split(separator: " ").prefix(2).compactMap { $0.first }; return String(p).uppercased()
}
/// Una acción del menú ⋯ de una pantalla de detalle.
struct CNAccion: Identifiable {
    let id = UUID()
    let texto: String
    let icono: String
    var peligro: Bool = false
    let hacer: () -> Void
}

struct CNDetCabecera: View {
    let inicial: String; let nombre: String; let sub: String
    var fondo: Color = CNC.side; var cuadro: Color = CNC.info; var volverA: String = "Cuentas"
    /// Acciones de la pantalla (editar, eliminar…): salen en el menú ⋯.
    var acciones: [CNAccion] = []
    var onClose: () -> Void
    var body: some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: 14)
            HStack(spacing: 12) {
                // Atrás y ⋯ en vidrio, como el resto de botones de la app.
                Button(action: onClose) {
                    HStack(spacing: 3) {
                        Image(systemName: "chevron.left").font(cnLetra(15, .bold))
                        Text(volverA).font(cnLetra(15, .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.leading, 10).padding(.trailing, 14).frame(height: 38)
                    .cnVidrio(Capsule())
                }.buttonStyle(.plain)
                Spacer(minLength: 0)
                if !acciones.isEmpty {
                    Menu {
                        ForEach(acciones) { a in
                            Button(role: a.peligro ? .destructive : nil, action: a.hacer) {
                                Label(a.texto, systemImage: a.icono)
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(cnLetra(16, .bold)).foregroundColor(.white)
                            .frame(width: 38, height: 38).cnVidrio(Circle())
                    }
                }
            }
            HStack(spacing: 12) {
                Text(inicial).font(cnLetra(15, .heavy)).foregroundColor(.white)
                    .frame(width: 44, height: 44).background(cuadro).clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                VStack(alignment: .leading, spacing: 2) {
                    Text(nombre).font(cnLetra(20, .heavy)).foregroundColor(.white)
                    Text(sub).font(cnLetra(12.5)).foregroundColor(.white.opacity(0.8))
                }
                Spacer(minLength: 0)
            }.padding(.top, 12)
        }
        .padding(.horizontal, 16).padding(.bottom, 16).background(fondo.ignoresSafeArea(edges: .top))
    }
}
struct CNDetCifra: View {
    let rotulo: String; let valor: String; var color: Color = CNC.ink; let cols: [(String, String, Color)]
    var body: some View {
        VStack(spacing: 14) {
            VStack(spacing: 3) { Text(rotulo).font(cnLetra(12.5, .semibold)).foregroundColor(CNC.pmut); Text(valor).font(cnLetra(32, .heavy)).foregroundColor(color) }
            HStack(spacing: 0) { ForEach(cols.indices, id: \.self) { i in
                VStack(spacing: 3) { Text(cols[i].0).font(cnLetra(11, .semibold)).foregroundColor(CNC.pmut); Text(cols[i].1).font(cnLetra(16, .heavy)).foregroundColor(cols[i].2) }.frame(maxWidth: .infinity)
                if i < cols.count - 1 { Rectangle().fill(CNC.line).frame(width: 0.5, height: 30) }
            } }
        }
        .padding(.vertical, 18).padding(.horizontal, 16).frame(maxWidth: .infinity)
        .background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
struct CNBotonAncho: View {
    let texto: String; var icono: String? = nil; var tap: () -> Void
    var body: some View {
        Button(action: tap) {
            HStack(spacing: 6) { if let ic = icono { Image(systemName: ic).font(cnLetra(15, .heavy)) }; Text(texto).font(cnLetra(15.5, .bold)) }
                .foregroundColor(CNC.sobreAcc).frame(maxWidth: .infinity).padding(.vertical, 15)
                .cnVidrio(Capsule(), tinte: CNC.acc)
                .shadow(color: CNC.acc.opacity(0.35), radius: 12, y: 4)
        }.buttonStyle(.plain)
    }
}
private func cnCuerpo<C: View>(@ViewBuilder _ c: () -> C) -> some View {
    ScrollView(showsIndicators: false) { VStack(alignment: .leading, spacing: 14) { c(); Color.clear.frame(height: 40) }.padding(.horizontal, 16).padding(.top, 14) }.background(CNC.scr.ignoresSafeArea())
}

/// CUALQUIER detalle —cuenta, tarjeta, préstamo, meta o categoría— en la misma
/// forma. Lo calcula la web; aquí solo se dibuja, y por eso las cinco
/// pantallas se leen igual.
struct CNDetalle {
    struct Chip: Identifiable { var id: Int { indice }; var indice = 0; var label = ""; var puesta = false }
    /// Editar y eliminar, para el ⋯ de arriba.
    ///
    /// El menú repetía los dos botones que ya se ven debajo, así que no servía
    /// para nada, y editar una tarjeta o un préstamo no estaba en ningún sitio
    /// de la app.
    struct Accion: Identifiable { var id: Int; var label = ""; var peligro = false }
    struct Hero {
        var iconoPath = ""; var iconoColor = ""; var iconoBg = ""
        var rotulo = ""; var valor = ""; var color = ""
        /// −1 = sin barra.
        var pct: Double = -1
        var colorBarra = ""; var pieIzq = ""; var pieDer = ""; var nota = ""
    }
    struct Cifra: Identifiable { var id: Int; var label = ""; var valor = ""; var color = "" }
    /// Un botón del detalle.
    ///
    /// `abre` dice que esa hoja la dibuja el TELÉFONO: la suya pregunta solo
    /// el monto y de dónde sale, en vez de volver a preguntar el nombre, el
    /// sentido y a quién le debes, que ya están en el préstamo. Vacío = el
    /// toque vuelve a la web, como siempre.
    struct Boton: Identifiable {
        var id: Int; var label = ""; var estilo = "contorno"
        var abre = ""; var cual = 0; var monto: Double = 0
        /// Para «movCat» y «movMedio»: la categoría o el medio que ya se sabe.
        var conQue = ""
    }
    struct Dato: Identifiable { var id: Int; var label = ""; var valor = ""; var color = "" }
    struct Columna: Identifiable { var id: Int; var label = ""; var pct: Double = 0; var fuerte = false; var color = ""; var colorMes = "" }
    struct Barras { var titulo = ""; var tope = ""; var columnas: [Columna] = [] }
    struct Item: Identifiable {
        var id: Int; var concepto = ""; var sub = ""; var montoFmt = ""
        var color = ""; var iconoPath = ""; var catColor = ""; var iconoBg = ""
    }
    struct Tramo: Identifiable { var id: Int; var label = ""; var total = ""; var items: [Item] = [] }

    var titulo = ""
    var chips: [Chip] = []
    var hero = Hero()
    var cifras: [Cifra] = []
    var botones: [Boton] = []
    var acciones: [Accion] = []
    var datos: [Dato] = []
    var barras: Barras? = nil
    var rotuloLista = ""; var vacioTexto = ""
    var tramos: [Tramo] = []

    static func desde(json: String) -> CNDetalle? {
        guard let d = json.data(using: .utf8),
              let r = (try? JSONSerialization.jsonObject(with: d)) as? [String: Any] else { return nil }
        func s(_ o: [String: Any]?, _ k: String) -> String { (o?[k] as? String) ?? "" }
        func n(_ o: [String: Any]?, _ k: String) -> Double { ((o?[k] as? NSNumber)?.doubleValue) ?? 0 }
        func b(_ o: [String: Any]?, _ k: String) -> Bool { (o?[k] as? Bool) ?? false }
        func l(_ o: [String: Any]?, _ k: String) -> [[String: Any]] { (o?[k] as? [[String: Any]]) ?? [] }
        var m = CNDetalle()
        m.titulo = s(r, "titulo")
        m.chips = l(r, "chips").map { Chip(indice: Int(n($0, "indice")), label: s($0, "label"), puesta: b($0, "puesta")) }
        let h = r["hero"] as? [String: Any]
        m.hero = Hero(iconoPath: s(h, "iconoPath"), iconoColor: s(h, "iconoColor"), iconoBg: s(h, "iconoBg"),
                      rotulo: s(h, "rotulo"), valor: s(h, "valor"), color: s(h, "color"),
                      pct: (h?["pct"] as? NSNumber)?.doubleValue ?? -1,
                      colorBarra: s(h, "colorBarra"), pieIzq: s(h, "pieIzq"), pieDer: s(h, "pieDer"),
                      nota: s(h, "nota"))
        m.cifras = l(r, "cifras").enumerated().map { Cifra(id: $0.offset, label: s($0.element, "label"), valor: s($0.element, "valor"), color: s($0.element, "color")) }
        m.acciones = l(r, "acciones").enumerated().map {
            Accion(id: Int(n($0.element, "indice")), label: s($0.element, "label"),
                   peligro: ($0.element["peligro"] as? Bool) ?? false)
        }
        m.botones = l(r, "botones").enumerated().map {
            Boton(id: $0.offset, label: s($0.element, "label"), estilo: s($0.element, "estilo"),
                  abre: s($0.element, "abre"), cual: Int(n($0.element, "cual")), monto: n($0.element, "monto"),
                  conQue: s($0.element, "conQue"))
        }
        m.datos = l(r, "datos").enumerated().map { Dato(id: $0.offset, label: s($0.element, "label"), valor: s($0.element, "valor"), color: s($0.element, "color")) }
        if let bb = r["barras"] as? [String: Any] {
            m.barras = Barras(titulo: s(bb, "titulo"), tope: s(bb, "tope"),
                              columnas: l(bb, "columnas").enumerated().map {
                                  Columna(id: $0.offset, label: s($0.element, "label"), pct: n($0.element, "pct"),
                                          fuerte: b($0.element, "fuerte"), color: s($0.element, "color"),
                                          colorMes: s($0.element, "colorMes"))
                              })
        }
        m.rotuloLista = s(r, "rotuloLista"); m.vacioTexto = s(r, "vacioTexto")
        m.tramos = l(r, "tramos").enumerated().map { (i, t) in
            Tramo(id: i, label: s(t, "label"), total: s(t, "total"),
                  items: l(t, "items").enumerated().map { (k, x) in
                      Item(id: k, concepto: s(x, "concepto"), sub: s(x, "sub"), montoFmt: s(x, "montoFmt"),
                           color: s(x, "color"), iconoPath: s(x, "iconoPath"),
                           catColor: s(x, "catColor"), iconoBg: s(x, "iconoBg"))
                  })
        }
        return m
    }
}

struct CNDetalleVista: View {
    @ObservedObject var datos: CNDatos
    var onVolver: () -> Void

    var body: some View {
        let d = datos.detalle ?? CNDetalle()
        // La barra de arriba es la del sistema, la misma que en Movimientos,
        // Cuentas y Plan: así entrar en una cuenta no cambia de idioma visual.
        return NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 13) {
                    if !d.chips.isEmpty { chips(d) }
                    hero(d.hero)
                    if !d.cifras.isEmpty {
                        HStack(spacing: 12) { ForEach(d.cifras) { c in cifra(c) } }
                    }
                    if !d.botones.isEmpty { botones(d) }
                    if !d.datos.isEmpty { tablaDatos(d) }
                    if let b = d.barras { barras(b) }
                    if !d.rotuloLista.isEmpty {
                        Text(d.rotuloLista.uppercased()).font(cnLetra(12, .heavy)).tracking(0.8)
                            .foregroundColor(CNC.pmut).padding(.leading, 4).padding(.top, 4)
                    }
                    if !d.vacioTexto.isEmpty { cnVacioCard("Todavía nada", d.vacioTexto) }
                    ForEach(d.tramos) { t in tramo(t) }
                    Color.clear.frame(height: 40)
                }
                .padding(.horizontal, 16).padding(.top, 4)
            }
            .background(CNC.scr.ignoresSafeArea())
            .navigationTitle(d.titulo)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: onVolver) { Image(systemName: "chevron.left") }
                        .accessibilityLabel(cnT("Volver"))
                }
                // En un GRUPO, no en un `ToolbarItem` suelto: ahí dentro el
                // `if` vale también en iOS 15. Dejarlo con opacidad cero no
                // servía —el sistema le dibujaba igual su cápsula y salía un
                // círculo blanco vacío.
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    // EDITAR Y ELIMINAR. Aquí se repetían los dos botones que
                    // ya están a la vista debajo —el menú no servía para nada—
                    // y editar una tarjeta o un préstamo no estaba en ninguna
                    // parte de la app.
                    if !d.acciones.isEmpty {
                        Menu {
                            ForEach(d.acciones) { a in
                                Button(role: a.peligro ? .destructive : nil) {
                                    datos.onDetalleAccion("menu", a.id)
                                } label: {
                                    Label(a.label, systemImage: a.peligro ? "trash" : "pencil")
                                }
                            }
                        } label: { Image(systemName: "ellipsis") }
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .tint(CNC.pos)
    }

    /// Los periodos de una categoría: pastillas en una fila que rueda.
    private func chips(_ d: CNDetalle) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(d.chips) { c in
                    Button { datos.onDetalleAccion("chip", c.indice) } label: {
                        Text(c.label).font(cnLetra(13.5, c.puesta ? .bold : .semibold))
                            .foregroundColor(c.puesta ? cnSobre(CNC.side) : CNC.ink)
                            .padding(.horizontal, 14).padding(.vertical, 9)
                            .background(c.puesta ? CNC.side : Color.clear, in: Capsule())
                    }.buttonStyle(CNPulsable())
                }
            }
            .padding(4)
        }
        .background(CNC.soft, in: Capsule())
    }

    private func hero(_ h: CNDetalle.Hero) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 14) {
                if !h.iconoPath.isEmpty {
                    CNSVGShape(d: h.iconoPath)
                        .stroke(style: StrokeStyle(lineWidth: 1.9, lineCap: .round, lineJoin: .round))
                        .foregroundColor(h.iconoColor.isEmpty ? CNC.pmut : cnColor(hexString: h.iconoColor))
                        .frame(width: 22, height: 22).frame(width: 46, height: 46)
                        .background(h.iconoBg.isEmpty ? CNC.soft : cnColor(hexString: h.iconoBg))
                        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(h.rotulo.uppercased()).font(cnLetra(11.5, .heavy)).tracking(0.8)
                        .foregroundColor(CNC.pmut).lineLimit(1)
                    Text(h.valor).font(cnLetra(28, .heavy))
                        .foregroundColor(h.color.isEmpty ? CNC.ink : cnColor(hexString: h.color))
                        .lineLimit(1).minimumScaleFactor(0.5)
                }
                Spacer(minLength: 0)
            }
            if h.pct >= 0 {
                CNBarraProgreso(parte: h.pct / 100,
                                color: h.colorBarra.isEmpty ? CNC.pos : cnColor(hexString: h.colorBarra), alto: 8)
            }
            if !h.pieIzq.isEmpty || !h.pieDer.isEmpty {
                HStack {
                    Text(h.pieIzq).font(cnLetra(12.5)).foregroundColor(CNC.pmut)
                    Spacer(minLength: 8)
                    Text(h.pieDer).font(cnLetra(12.5)).foregroundColor(CNC.pmut)
                }
            }
            if !h.nota.isEmpty {
                Text(h.nota).font(cnLetra(12.5)).foregroundColor(CNC.pmut)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16).tarjetaCN()
    }

    private func cifra(_ c: CNDetalle.Cifra) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(c.label).font(cnLetra(12.5)).foregroundColor(CNC.pmut).lineLimit(1)
            Text(c.valor).font(cnLetra(18, .heavy))
                .foregroundColor(c.color.isEmpty ? CNC.ink : cnColor(hexString: c.color))
                .lineLimit(1).minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity, alignment: .leading).padding(14).tarjetaCN()
    }

    /// Las acciones de la pantalla, con los estilos de botón DEL SISTEMA: la
    /// principal rellena y la otra con su fondo suave. Eran dos cápsulas
    /// pintadas a mano —una amarilla— y, con la barra de arriba ya del
    /// teléfono, eran lo único que seguía hablando otro idioma.
    private func botones(_ d: CNDetalle) -> some View {
        HStack(spacing: 12) {
            ForEach(d.botones) { b in
                boton(b)
            }
        }
    }

    @ViewBuilder private func boton(_ b: CNDetalle.Boton) -> some View {
        let etiqueta = Text(b.label).font(cnLetra(15, .semibold))
            .lineLimit(1).minimumScaleFactor(0.75)
            .frame(maxWidth: .infinity).padding(.vertical, 6)
        if b.estilo == "acento" {
            Button { datos.tocaBotonDetalle(b) } label: { etiqueta }
                .buttonStyle(.borderedProminent)
                .tint(CNC.pos)
                .controlSize(.large)
                .clipShape(Capsule())
        } else {
            Button { datos.tocaBotonDetalle(b) } label: { etiqueta }
                .buttonStyle(.bordered)
                .tint(CNC.pos)
                .controlSize(.large)
                .clipShape(Capsule())
        }
    }

    private func tablaDatos(_ d: CNDetalle) -> some View {
        VStack(spacing: 0) {
            ForEach(d.datos) { x in
                HStack {
                    Text(x.label).font(cnLetra(15)).foregroundColor(CNC.pmut)
                    Spacer(minLength: 10)
                    Text(x.valor).font(cnLetra(15, .bold))
                        .foregroundColor(x.color.isEmpty ? CNC.ink : cnColor(hexString: x.color))
                        .multilineTextAlignment(.trailing).lineLimit(2)
                }
                .padding(.horizontal, 16).padding(.vertical, 14)
                .overlay(alignment: .bottom) {
                    if x.id < d.datos.count - 1 {
                        Rectangle().fill(CNC.soft).frame(height: 0.5).padding(.horizontal, 16)
                    }
                }
            }
        }
        .background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    /// Mes a mes: sale cuando el periodo abarca más de un mes.
    private func barras(_ b: CNDetalle.Barras) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(b.titulo.uppercased()).font(cnLetra(11.5, .heavy)).tracking(0.8)
                    .foregroundColor(CNC.pmut)
                Spacer(minLength: 8)
                Text(b.tope).font(cnLetra(11.5)).foregroundColor(CNC.pmut)
            }
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(b.columnas) { c in
                    VStack(spacing: 6) {
                        GeometryReader { g in
                            VStack(spacing: 0) {
                                Spacer(minLength: 0)
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(c.color.isEmpty ? CNC.pos : cnColor(hexString: c.color))
                                    .frame(height: max(4, g.size.height * CGFloat(c.pct / 100)))
                            }
                        }
                        .frame(height: 96)
                        Text(c.label).font(cnLetra(10.5, c.fuerte ? .bold : .regular))
                            .foregroundColor(c.colorMes.isEmpty ? CNC.pmut : cnColor(hexString: c.colorMes))
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(15).tarjetaCN()
    }

    private func tramo(_ t: CNDetalle.Tramo) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            if !t.label.isEmpty || !t.total.isEmpty {
                HStack {
                    Text(t.label).font(cnLetra(12.5)).foregroundColor(CNC.pmut)
                    Spacer(minLength: 8)
                    Text(t.total).font(cnLetra(12.5, .bold)).foregroundColor(CNC.pmut)
                }.padding(.horizontal, 4)
            }
            VStack(spacing: 0) {
                ForEach(t.items) { x in
                    HStack(spacing: 12) {
                        if !x.iconoPath.isEmpty {
                            CNSVGShape(d: x.iconoPath)
                                .stroke(style: StrokeStyle(lineWidth: 1.9, lineCap: .round, lineJoin: .round))
                                .foregroundColor(x.catColor.isEmpty ? CNC.pmut : cnColor(hexString: x.catColor))
                                .frame(width: 17, height: 17).frame(width: 34, height: 34)
                                .background(x.iconoBg.isEmpty ? CNC.soft : cnColor(hexString: x.iconoBg))
                                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(x.concepto).font(cnLetra(14.5, .bold)).foregroundColor(CNC.ink).lineLimit(1)
                            if !x.sub.isEmpty {
                                Text(x.sub).font(cnLetra(11.5)).foregroundColor(CNC.pmut).lineLimit(1)
                            }
                        }
                        Spacer(minLength: 6)
                        Text(x.montoFmt).font(cnLetra(14.5, .bold))
                            .foregroundColor(x.color.isEmpty ? CNC.ink : cnColor(hexString: x.color))
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 14).padding(.vertical, 11)
                    .overlay(alignment: .bottom) {
                        if x.id < t.items.count - 1 {
                            Rectangle().fill(CNC.soft).frame(height: 0.5).padding(.leading, x.iconoPath.isEmpty ? 14 : 60)
                        }
                    }
                }
            }
            .background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

/// La barra de arriba de cualquier detalle: atrás, el título y el menú ⋯.
// La pantalla empujada (el detalle) entra y se va desde UIKit: el gesto de
// volver es un UIScreenEdgePanGestureRecognizer de verdad, en
// ChinolaViewController. Un DragGesture de SwiftUI aquí no llegaba a
// dispararse nunca: el ScrollView de dentro se queda con el dedo.

func cnOscurecer(_ c: Color, _ cuanto: CGFloat = 0.5) -> Color {
    var h: CGFloat = 0, sa: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    guard UIColor(c).getHue(&h, saturation: &sa, brightness: &b, alpha: &a) else { return c }
    return Color(UIColor(hue: h, saturation: min(1, sa * 1.05), brightness: max(0.12, b * (1 - cuanto)), alpha: 1))
}

/// El detalle de un movimiento. El modelo lo arma la web (rótulo, monto, icono
/// de la categoría y la lista de datos), así que esta pantalla y la de la PWA
/// dicen exactamente lo mismo.
struct CNMovDetalle {
    struct Dato: Identifiable { var id: Int; var label = ""; var valor = "" }
    var nombre = ""; var rotulo = ""; var montoFmt = ""; var color = ""
    var iconoPath = ""; var iconoColor = ""; var iconoBg = ""
    var puedeEditar = false; var textoEditar = "Editar"; var textoDuplicar = "Duplicar"
    var datos: [Dato] = []

    static func desde(json: String) -> CNMovDetalle? {
        guard let d = json.data(using: .utf8),
              let r = (try? JSONSerialization.jsonObject(with: d)) as? [String: Any] else { return nil }
        func s(_ o: [String: Any]?, _ k: String) -> String { (o?[k] as? String) ?? "" }
        var m = CNMovDetalle()
        m.nombre = s(r, "nombre"); m.rotulo = s(r, "rotulo"); m.montoFmt = s(r, "montoFmt")
        m.color = s(r, "color"); m.iconoPath = s(r, "iconoPath")
        m.iconoColor = s(r, "iconoColor"); m.iconoBg = s(r, "iconoBg")
        m.puedeEditar = (r["puedeEditar"] as? Bool) ?? false
        m.textoEditar = s(r, "textoEditar").isEmpty ? "Editar" : s(r, "textoEditar")
        m.textoDuplicar = s(r, "textoDuplicar").isEmpty ? "Duplicar" : s(r, "textoDuplicar")
        m.datos = ((r["datos"] as? [[String: Any]]) ?? []).enumerated().map {
            Dato(id: $0.offset, label: s($0.element, "label"), valor: s($0.element, "valor"))
        }
        return m
    }
}

/// EL DETALLE DE UN MOVIMIENTO.
///
/// Barra de navegación del sistema arriba —atrás y el menú de «...»— y el
/// contenido en una lista agrupada de iOS. Antes la barra eran dos círculos
/// grises dibujados a mano y las acciones dos cápsulas, una amarilla: chocaba
/// con el resto de la app, que ya usa las piezas del teléfono.
struct CNDetalleMov: View {
    @ObservedObject var datos: CNDatos
    let movId: String
    var onClose: () -> Void
    @State private var confirmarBorrar = false

    var body: some View {
        let m = datos.movDetalle ?? CNMovDetalle()
        return NavigationView {
            List {
                Section { cabecera(m) }
                if m.puedeEditar {
                    Section {
                        Button { datos.onAccion("editarMov", movId) } label: {
                            Label(m.textoEditar, systemImage: "pencil")
                        }
                        Button { datos.onMovAccion("duplicar") } label: {
                            Label(m.textoDuplicar, systemImage: "plus.square.on.square")
                        }
                    }
                }
                if !m.datos.isEmpty {
                    Section {
                        ForEach(m.datos) { d in
                            HStack {
                                Text(d.label).foregroundColor(CNC.pmut)
                                Spacer(minLength: 10)
                                Text(d.valor).fontWeight(.semibold).foregroundColor(CNC.ink)
                                    .multilineTextAlignment(.trailing).lineLimit(2)
                            }
                        }
                    }
                }
                if m.puedeEditar {
                    Section {
                        Button(role: .destructive) { confirmarBorrar = true } label: {
                            // El tinte de la app pintaba el icono de verde al
                            // lado de un texto rojo. Rojo los dos.
                            Label(cnT("Eliminar"), systemImage: "trash").foregroundColor(.red)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .modifier(CNFondoLista())
            .background(CNC.scr.ignoresSafeArea())
            .font(cnLetra(16))
            .navigationTitle(m.nombre)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: onClose) { Image(systemName: "chevron.left") }
                        .accessibilityLabel(cnT("Volver"))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button { datos.onAccion("editarMov", movId) } label: { Label(m.textoEditar, systemImage: "pencil") }
                        Button { datos.onMovAccion("duplicar") } label: { Label(m.textoDuplicar, systemImage: "plus.square.on.square") }
                        Button(role: .destructive) { confirmarBorrar = true } label: { Label(cnT("Eliminar"), systemImage: "trash") }
                    } label: { Image(systemName: "ellipsis") }
                }
            }
        }
        .navigationViewStyle(.stack)
        .tint(CNC.pos)
        .alert(cnT("¿Eliminar movimiento?"), isPresented: $confirmarBorrar) {
            Button(cnT("Cancelar"), role: .cancel) {}
            Button(cnT("Eliminar"), role: .destructive) { datos.onBorrarMov(movId); onClose() }
        } message: { Text(cnT("Esto revierte su efecto en los saldos. No se puede deshacer.")) }
    }

    /// Cuánto fue y de qué categoría: lo primero que se mira, centrado y
    /// grande, en su propia fila sin adornos.
    private func cabecera(_ m: CNMovDetalle) -> some View {
        VStack(spacing: 10) {
            if !m.iconoPath.isEmpty {
                CNSVGShape(d: m.iconoPath)
                    .stroke(style: StrokeStyle(lineWidth: 1.9, lineCap: .round, lineJoin: .round))
                    .foregroundColor(m.iconoColor.isEmpty ? CNC.pmut : cnColor(hexString: m.iconoColor))
                    .frame(width: 24, height: 24).frame(width: 52, height: 52)
                    .background(m.iconoBg.isEmpty ? CNC.soft : cnColor(hexString: m.iconoBg))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            Text(m.rotulo.uppercased()).font(cnLetra(11.5, .heavy)).tracking(0.8)
                .foregroundColor(CNC.pmut)
            Text(m.montoFmt).font(cnLetra(34, .heavy))
                .foregroundColor(m.color.isEmpty ? CNC.ink : cnColor(hexString: m.color))
                .lineLimit(1).minimumScaleFactor(0.5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
}

// ── Formulario «Nuevo movimiento» NATIVO (guarda a la web) ──────────────────
/// Quitarle a la lista su fondo propio para que se vea el del tema. Desde
/// iOS 16; antes se deja el del sistema, que ya es el gris de siempre.
struct CNFondoLista: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) { content.scrollContentBackground(.hidden) }
        else { content }
    }
}

/// ANOTAR UN MOVIMIENTO.
///
/// Un `Form` de iOS, no una imitación: la barra con «Cancelar» y «Guardar» la
/// pone el sistema (y en iOS 26 les da su cápsula de vidrio), el selector de
/// tipo es un `Picker` segmentado, la fecha un `DatePicker`, la cuenta y la
/// categoría `Picker` de menú y la repetición un `Toggle`. Antes era todo
/// dibujado a mano —círculos amarillos, rótulos en mayúsculas, cuadritos de
/// colores sueltos, fichas que se salían por la derecha— y se notaba que no
/// era del teléfono.
///
/// Del tema solo se toma el color: el fondo, las tarjetas y el acento. La FORMA
/// es siempre la del sistema, que es lo que hace que encaje con el resto.
struct CNNuevoMov: View {
    @ObservedObject var datos: CNDatos
    var onClose: () -> Void
    var editar: CNMov? = nil
    /// Con qué viene puesto cuando se abre desde una pantalla que ya lo sabe.
    ///
    /// «Nuevo gasto aquí» dentro de una categoría y «Nuevo movimiento» dentro
    /// de una cuenta abrían la hoja DE LA WEB para poder dejar eso puesto. Era
    /// de las últimas puertas que quedaban: la app se veía igual —es el mismo
    /// diseño— pero la dibujaba el webview.
    var categoriaInicial: String = ""
    var medioInicial: String = ""
    @State private var tipo = 2
    @State private var monto = ""
    @State private var concepto = ""
    /// EL MEDIO ENTERO —«cuenta:3», «tarjeta:10», «efectivo»— y no el número de
    /// una cuenta. Guardando solo el número, una tarjeta no cabía: no se podía
    /// anotar un gasto con la tarjeta desde aquí, y al EDITAR uno que sí lo era
    /// se reescribía como pagado con la primera cuenta. Eso mueve dinero solo:
    /// la deuda de la tarjeta baja y la cuenta se queda con el cargo.
    @State private var medio = ""
    @State private var categoria = ""
    @State private var fecha = Date()
    @State private var repetir = false
    @FocusState private var montoPuesto: Bool
    /// Rótulos. Los valores que entiende la web son los de `mapa`.
    private var tipos: [String] { ["Ingreso", "Fijo", "Variable", "Ahorro"].map { cnT($0) } }
    private let mapa = ["Ingreso", "Gasto Fijo", "Gasto Variable", "Ahorro"]

    var body: some View {
        // NavigationView y no NavigationStack: la app llega hasta iOS 15 y el
        // Stack es de la 16. En pila, que es como se comporta una hoja.
        NavigationView {
            Form {
                // El monto y el tipo van juntos: son la misma decisión
                // («cuánto y de qué clase»), y separados dejaban dos huecos
                // grandes que partían la hoja por la mitad.
                Section {
                    monto_
                    Picker("", selection: $tipo) {
                        ForEach(tipos.indices, id: \.self) { i in Text(tipos[i]).tag(i) }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 12, trailing: 16))
                }
                Section {
                    TextField(cnT("En qué fue"), text: $concepto)
                        .font(cnLetra(17)).foregroundColor(CNC.ink)
                    Picker(cnT("Categoría"), selection: $categoria) {
                        ForEach(datos.libreta.categorias, id: \.nombre) { c in
                            // Por la regla: una categoría sin icono propio lleva
                            // el de su nombre. Leyendo el campo salía vacío.
                            Label { Text(cnT(c.nombre)) } icon: {
                                cnGlifo(CNCategorias.icono(c.nombre, en: datos.libreta), tam: 15, grosor: 2.2)
                            }
                                .tag(c.nombre)
                        }
                        Text(cnT("Otros")).tag("")
                    }
                    Picker(cnT("Pagado con"), selection: $medio) {
                        ForEach(datos.libreta.cuentas) { c in
                            // Por el diccionario, como en la lista: el nombre de
                            // fábrica es un texto nuestro.
                            Text(cnT(c.nombre)).tag("cuenta:\(c.id)")
                        }
                        // Las tarjetas también: gastar con la tarjeta es como
                        // sube la deuda, y sin esta parte la pantalla de
                        // Tarjetas no podía llenarse desde el teléfono.
                        ForEach(datos.libreta.tarjetas) { t in
                            Text(t.nombre).tag("tarjeta:\(t.id)")
                        }
                        Text(cnT("Efectivo")).tag("efectivo")
                    }
                    DatePicker(cnT("Fecha"), selection: $fecha, displayedComponents: .date)
                }
                Section {
                    Toggle(cnT("Repetir cada mes"), isOn: $repetir)
                } footer: {
                    Text(cnT("Para lo que pagas siempre: renta, luz, colegio"))
                }
            }
            .modifier(CNFondoLista())
            .background(CNC.scr.ignoresSafeArea())
            .font(cnLetra(17))
            .foregroundColor(CNC.ink)
            .tint(CNC.pos)
            .navigationTitle(editar == nil ? cnT("Nuevo movimiento") : cnT("Editar movimiento"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(cnT("Cancelar")) { onClose() }
                }
                // El teclado numérico no trae tecla de retorno: sin esto no
                // hay forma de cerrarlo y tapa media hoja.
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(cnT("Listo")) { montoPuesto = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button { guardar() } label: {
                        Text(cnT("Guardar")).font(cnLetra(17, .semibold))
                    }
                    .disabled(cnMonto(monto) <= 0)
                }
            }
        }
        .navigationViewStyle(.stack)
        .environment(\.locale, Locale(identifier: CNC.fmt.loc))
        .onAppear {
            if let m = editar {
                tipo = mapa.firstIndex(of: m.tipo) ?? 2
                monto = m.monto > 0 ? String(Int(m.monto.rounded())) : ""
                concepto = m.concepto
                categoria = m.categoria
                repetir = m.recurrente
                // Tal cual venga: si se pagó con la tarjeta, se queda con la
                // tarjeta. Leyendo solo «cuenta:» se perdía y al guardar se
                // reescribía como pagado con la primera cuenta.
                medio = m.medio
                let f = CNFormateadores.iso
                if let d = f.date(from: m.fecha) { fecha = d }
            }
            // Lo que ya sabía la pantalla de la que vienes, antes que el resto.
            if medio.isEmpty, !medioInicial.isEmpty { medio = medioInicial }
            if categoria.isEmpty, !categoriaInicial.isEmpty { categoria = categoriaInicial }
            if medio.isEmpty { medio = cnMedioPorDefecto(datos.libreta) }
            // El teclado abierto de entrada: lo primero que se anota es cuánto.
            if editar == nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { montoPuesto = true }
            }
        }
    }

    /// El monto: lo único grande de la hoja, porque es lo único que hay que
    /// escribir de verdad. El símbolo de la moneda queda fijo a la izquierda.
    private var monto_: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(cnSimboloMoneda)
                .font(cnLetra(22, .semibold))
                .foregroundColor(CNC.pmut)
            TextField("0", text: $monto)
                .keyboardType(.decimalPad)
                .focused($montoPuesto)
                .font(cnLetra(40, .bold))
                .foregroundColor(monto.isEmpty ? CNC.pmut.opacity(0.45) : CNC.ink)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }
        .padding(.vertical, 10)
    }

    private func guardar() {
        let n = cnMonto(monto)
        guard n > 0 else { onClose(); return }
        let f = CNFormateadores.iso
        var dict: [String: Any] = [
            "concepto": concepto.isEmpty ? (categoria.isEmpty ? "Movimiento" : categoria) : concepto,
            "categoria": categoria.isEmpty ? "Otros" : categoria,
            "tipo": mapa[tipo], "monto": n, "fecha": f.string(from: fecha),
            "medio": medio, "recurrente": repetir
        ]
        if let m = editar { dict["id"] = m.id; datos.onEditarMov(dict) } else { datos.onCrearMov(dict) }
        onClose()
    }
}

// Esquinas redondeadas selectivas (iOS 15+, sin UnevenRoundedRectangle que es 16+).
struct CNRedondo: Shape {
    var radio: CGFloat
    var esquinas: UIRectCorner
    func path(in rect: CGRect) -> Path {
        Path(UIBezierPath(roundedRect: rect, byRoundingCorners: esquinas, cornerRadii: CGSize(width: radio, height: radio)).cgPath)
    }
}

// ── Pantalla «Cuentas» NATIVA ───────────────────────────────────────────────
// El mismo contenido y el mismo orden que la web: cuentas, tarjetas (con su
// plástico) y préstamos. Lo que cambia es que la navegación, las acciones y los
// menús son de iOS.
/// Lo que enseña la pantalla de Cuentas, ya decorado por la web.
struct CNCuentasModelo {
    struct Fila: Identifiable {
        var id: Int { indice }
        var indice = 0; var nombre = ""; var detalle = ""; var valor = ""; var pie = ""
        var uso: Double = 0; var usoColor = ""
        var iconoPath = ""; var color = ""; var fondo = ""; var tintaValor = ""
        /// Lo que sale al deslizar la fila, y si es la cuenta de siempre.
        var acciones: [CNAccionFila] = []
        var predeterminada = false; var rotuloPred = ""
    }
    struct Patrimonio {
        var titulo = ""; var valor = ""
        var activosLabel = ""; var activos = ""
        var pasivosLabel = ""; var pasivos = ""
        var fondo = ""; var tinta = ""; var gris = ""
        /// El fondo entero (puede ser un degradado, como la cabecera).
        var fondoObj = CNResumenModelo.Fondo()
    }
    struct ColorTarjeta: Identifiable { var id: String; var nombre = ""; var puesta = false }
    var titulo = "Cuentas"; var oculto = false
    var listo = false
    var patrimonio = Patrimonio()
    var rotuloCuentas = "Cuentas"; var rotuloTarjetas = "Tarjetas de crédito"; var rotuloPrestamos = "Préstamos"
    /// Lo que suma cada grupo, dicho en su propio rótulo: «Tienes RD$105,378»,
    /// «Debes RD$44,496». La web lo calcula y aquí solo se escribe.
    struct Total { var rotulo = ""; var valor = ""; var tinta = "" }
    var totalCuentas = Total(); var totalTarjetas = Total(); var totalPrestamos = Total()
    /// Grupos plegados: el rótulo se toca y la lista se esconde. Lo recuerda la
    /// web (es un ajuste más), así que aquí solo se dibuja.
    var plegadoCuentas = false; var plegadoTarjetas = false; var plegadoPrestamos = false
    var cuentas: [Fila] = []; var tarjetas: [Fila] = []; var prestamos: [Fila] = []
    var coloresTarjeta: [ColorTarjeta] = []

    static func desde(json: String) -> CNCuentasModelo? {
        guard let d = json.data(using: .utf8),
              let r = (try? JSONSerialization.jsonObject(with: d)) as? [String: Any] else { return nil }
        func s(_ o: [String: Any]?, _ k: String) -> String { (o?[k] as? String) ?? "" }
        func n(_ o: [String: Any]?, _ k: String) -> Double { ((o?[k] as? NSNumber)?.doubleValue) ?? 0 }
        func l(_ o: [String: Any]?, _ k: String) -> [[String: Any]] { (o?[k] as? [[String: Any]]) ?? [] }
        func filas(_ k: String) -> [Fila] {
            l(r, k).map {
                Fila(indice: Int(n($0, "indice")), nombre: s($0, "nombre"), detalle: s($0, "detalle"),
                     valor: s($0, "valor"), pie: s($0, "pie"), uso: n($0, "uso"), usoColor: s($0, "usoColor"),
                     iconoPath: s($0, "iconoPath"), color: s($0, "color"), fondo: s($0, "fondo"),
                     tintaValor: s($0, "tintaValor"),
                     acciones: (($0["acciones"] as? [[String: Any]]) ?? []).map { a in
                         CNAccionFila(label: (a["label"] as? String) ?? "",
                                      icono: (a["icono"] as? String) ?? "",
                                      peligro: (a["peligro"] as? Bool) ?? false,
                                      accion: ((a["accion"] as? NSNumber)?.intValue) ?? -1)
                     },
                     predeterminada: ($0["predeterminada"] as? Bool) ?? false,
                     rotuloPred: s($0, "rotuloPred"))
            }
        }
        var m = CNCuentasModelo()
        m.listo = (r["listo"] as? Bool) ?? false
        m.titulo = s(r, "titulo").isEmpty ? "Cuentas" : s(r, "titulo")
        m.oculto = (r["oculto"] as? Bool) ?? false
        let p = r["patrimonio"] as? [String: Any]
        m.patrimonio = Patrimonio(titulo: s(p, "titulo"), valor: s(p, "valor"),
                                  activosLabel: s(p, "activosLabel"), activos: s(p, "activos"),
                                  pasivosLabel: s(p, "pasivosLabel"), pasivos: s(p, "pasivos"),
                                  fondo: s(p, "fondo"), tinta: s(p, "tinta"), gris: s(p, "gris"))
        if let f = p?["fondoObj"] as? [String: Any] {
            m.patrimonio.fondoObj = CNResumenModelo.Fondo(
                tipo: s(f, "tipo"), color: s(f, "color"), angulo: n(f, "angulo"),
                paradas: ((f["paradas"] as? [[String: Any]]) ?? []).map {
                    CNResumenModelo.Parada(color: s($0, "color"), pos: n($0, "pos")) })
        }
        m.coloresTarjeta = l(r, "coloresTarjeta").map {
            ColorTarjeta(id: s($0, "id"), nombre: s($0, "nombre"), puesta: ($0["puesta"] as? Bool) ?? false)
        }
        m.rotuloCuentas = s(r, "rotuloCuentas"); m.rotuloTarjetas = s(r, "rotuloTarjetas")
        m.rotuloPrestamos = s(r, "rotuloPrestamos")
        let tt = r["totales"] as? [String: Any]
        func total(_ k: String) -> Total {
            let o = tt?[k] as? [String: Any]
            return Total(rotulo: s(o, "rotulo"), valor: s(o, "valor"), tinta: s(o, "tinta"))
        }
        m.totalCuentas = total("cuentas"); m.totalTarjetas = total("tarjetas"); m.totalPrestamos = total("prestamos")
        let pl = r["plegados"] as? [String: Any]
        m.plegadoCuentas = (pl?["cuentas"] as? Bool) ?? false
        m.plegadoTarjetas = (pl?["tarjetas"] as? Bool) ?? false
        m.plegadoPrestamos = (pl?["prestamos"] as? Bool) ?? false
        m.cuentas = filas("cuentas"); m.tarjetas = filas("tarjetas"); m.prestamos = filas("prestamos")
        return m
    }
}

struct CNCuentas: View {
    @ObservedObject var datos: CNDatos
    /// Qué tarjeta va arriba: «clasica», «apilada», «grafica», «suma»,
    /// «chino», «bloques» o «ninguna». Lo guarda la web con el resto de
    /// ajustes, así que es el mismo en el teléfono, en la web y en la PWA.
    private var tarjetaArriba: String { CNC.fmt.tarjetaCuentas }
    /// A cuánto quieres llegar. Solo la usa la tarjeta de Chino, y si no hay
    /// ninguna puesta esa tarjeta no enseña barra de meta.
    private var metaPatrimonio: Double { CNC.fmt.metaPatrimonio }

    var body: some View {
        let m = datos.cuentas ?? CNCuentasModelo()
        // La barra de arriba la pone iOS, igual que en Movimientos: título
        // grande que encoge al rodar y botones con la cápsula del sistema.
        return NavigationView {
            // Lista agrupada del sistema, la misma que Movimientos y el Perfil.
            List {
                Section {
                    arriba(m)
                        .overlay(alignment: .top) {
                            CNEspiaScroll { CNScrollEstado.shared.mirar($0) }
                                .frame(height: 0).allowsHitTesting(false)
                        }
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 4, trailing: 0))
                // Las cuentas, partidas como en el catálogo de agregar: lo que
                // es para gastar y lo que está guardado. Iban todas bajo un
                // solo rótulo «Cuentas» —el mismo que el título de la
                // pantalla— y ahí dentro el efectivo del bolsillo pesaba igual
                // que un certificado a plazo.
                if !m.plegadoCuentas && !paraGastar(m).isEmpty {
                    Section {
                        ForEach(paraGastar(m)) { f in fila(f, tipo: "cuenta") }
                    } header: {
                        rotulo(cnT("Para gastar"), totalDe(paraGastar(m), como: m),
                               plegado: m.plegadoCuentas, grupo: 0)
                    }
                }
                if !m.plegadoCuentas && !guardado(m).isEmpty {
                    Section {
                        ForEach(guardado(m)) { f in fila(f, tipo: "cuenta") }
                    } header: {
                        rotulo(cnT("Ahorro e inversión"), totalDe(guardado(m), como: m),
                               plegado: m.plegadoCuentas, grupo: 0)
                    }
                }
                if m.plegadoCuentas && !m.cuentas.isEmpty {
                    Section {} header: {
                        rotulo(m.rotuloCuentas, m.totalCuentas, plegado: true, grupo: 0)
                    }
                }
                if !m.tarjetas.isEmpty {
                    Section {
                        if !m.plegadoTarjetas { ForEach(m.tarjetas) { f in fila(f, tipo: "tarjeta") } }
                    } header: {
                        rotulo(m.rotuloTarjetas, m.totalTarjetas, plegado: m.plegadoTarjetas, grupo: 1)
                    }
                }
                if !m.prestamos.isEmpty {
                    Section {
                        if !m.plegadoPrestamos { ForEach(m.prestamos) { f in fila(f, tipo: "prestamo") } }
                    } header: {
                        rotulo(m.rotuloPrestamos, m.totalPrestamos, plegado: m.plegadoPrestamos, grupo: 2)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .modifier(CNFondoLista())
            .background(CNC.scr.ignoresSafeArea())
            .navigationTitle(m.titulo)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) { menu(m) }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { datos.onAgregar() } label: { Image(systemName: "plus") }
                }
            }
        }
        .navigationViewStyle(.stack)
        .tint(CNC.pos)
    }

    /// La tarjeta de arriba, la que se haya elegido. «ninguna» no dibuja nada:
    /// quien solo quiere su lista de cuentas no tiene por qué cargar con una
    /// tarjeta grande encima.
    @ViewBuilder private func arriba(_ m: CNCuentasModelo) -> some View {
        switch tarjetaArriba {
        case "ninguna":
            EmptyView()
        case "apilada":
            CNTarjetaApilada(r: retrato, oculto: m.oculto,
                             onOjo: { datos.onCuentasAccion("ocultar", 0) })
        case "grafica":
            CNTarjetaGrafica(r: retrato, oculto: m.oculto)
        case "suma":
            CNTarjetaSuma(r: retrato, oculto: m.oculto)
        case "chino":
            CNTarjetaChino(r: retrato, oculto: m.oculto,
                           chinolo: datos.mascota?.chinolo ?? "", meta: metaPatrimonio)
        case "bloques":
            CNTarjetaBloques(r: retrato, oculto: m.oculto)
        default:
            patrimonio(m.patrimonio, oculto: m.oculto)
        }
    }

    /// De qué clase es una fila de cuenta. La web no manda la clase en la
    /// fila, así que se busca en la libreta: primero por posición —que es el
    /// orden con el que la web las arma— y, si no cuadra, por nombre.
    /**
     * LA CUENTA DE UNA FILA, POR EL ÍNDICE Y NO POR EL NOMBRE.
     *
     * Dos cuentas se pueden llamar igual —«Cuenta de banco» y «Cuenta de
     * banco»— y buscándolas por el nombre las dos devuelven la primera. El
     * total del grupo lo hacía así y sumaba el saldo de la primera dos veces:
     * con 5.000 y 50.000 enseñaba 10.000 en vez de 55.000, o sea 45.000 de
     * menos en «Tienes». Las cuentas salían bien una por una y el total no
     * cuadraba, que es la peor manera de equivocarse.
     *
     * El índice es el de la lista que manda la web, y la propia web ya cuenta
     * con eso para saber cuál es la predeterminada. El nombre queda solo de
     * respaldo por si algún día llegara una fila sin sitio.
     */
    private func cuentaDe(_ f: CNCuentasModelo.Fila) -> CNCuenta? {
        let cs = datos.libreta.cuentas
        if f.indice >= 0, f.indice < cs.count, cs[f.indice].nombre == f.nombre {
            return cs[f.indice]
        }
        return cs.first { $0.nombre == f.nombre }
    }

    private func claseDe(_ f: CNCuentasModelo.Fila) -> String {
        cuentaDe(f)?.claseParaAgrupar ?? "banco"
    }

    /// Lo que se puede gastar hoy.
    private func paraGastar(_ m: CNCuentasModelo) -> [CNCuentasModelo.Fila] {
        m.cuentas.filter { ["banco", "efectivo", "billetera"].contains(claseDe($0)) }
    }
    /// Lo guardado: ahorro e inversión.
    private func guardado(_ m: CNCuentasModelo) -> [CNCuentasModelo.Fila] {
        m.cuentas.filter { !["banco", "efectivo", "billetera"].contains(claseDe($0)) }
    }

    /// El total de un grupo, sumado de la libreta (la web solo manda el de
    /// todas juntas, y ahora hacen falta dos).
    private func totalDe(_ filas: [CNCuentasModelo.Fila], como m: CNCuentasModelo) -> CNCuentasModelo.Total {
        // Por el índice, no por el nombre: ver `cuentaDe`.
        let suma = filas.reduce(0.0) { acc, f in acc + (cuentaDe(f)?.saldo ?? 0) }
        // El rótulo y el color, los mismos que ya traía el total de la web.
        return CNCuentasModelo.Total(rotulo: m.totalCuentas.rotulo, valor: cnDinero(suma),
                                     tinta: m.totalCuentas.tinta)
    }

    /// El patrimonio desmenuzado, leído de la libreta. Se calcula una vez por
    /// pintado: recorre los movimientos para armar la historia.
    private var retrato: CNCalculo.Retrato { CNCalculo.retrato(datos.libreta) }

    /// EL MENÚ DE LA PANTALLA.
    ///
    /// Lo que se hace a menudo arriba —ver la tendencia, tapar el dinero— y
    /// todo lo de personalizar metido en «Editar la pantalla», abajo. Las
    /// siete formas de la tarjeta ocupaban el menú entero por encima de las
    /// acciones, y eso se elige UNA vez: puesta la pantalla como te gusta, no
    /// se vuelve a tocar.
    private func menu(_ m: CNCuentasModelo) -> some View {
        Menu {
            Button { datos.onTendencia() } label: {
                Label(cnT("Ver la tendencia"), systemImage: "chart.line.uptrend.xyaxis")
            }
            Button { datos.onCuentasAccion("ocultar", 0) } label: {
                Label(m.oculto ? cnT("Enseñar el dinero") : cnT("Ocultar el dinero"),
                      systemImage: m.oculto ? "eye" : "eye.slash")
            }
            Divider()
            Menu {
                Picker(cnT("La tarjeta de arriba"), selection: cnAjuste("tarjetaCuentas", { tarjetaArriba }, { $0 })) {
                    Label(cnT("Clásica"), systemImage: "rectangle.fill").tag("clasica")
                    Label(cnT("Apilada"), systemImage: "square.stack.3d.up.fill").tag("apilada")
                    Label(cnT("Con gráfica"), systemImage: "chart.xyaxis.line").tag("grafica")
                    Label(cnT("La suma"), systemImage: "plusminus").tag("suma")
                    Label(cnT("Con Chino"), systemImage: "face.smiling").tag("chino")
                    Label(cnT("En bloques"), systemImage: "square.grid.2x2.fill").tag("bloques")
                    Label(cnT("Ninguna"), systemImage: "rectangle.slash").tag("ninguna")
                }
                if !m.coloresTarjeta.isEmpty {
                    // El color de la tarjeta de Patrimonio: el del tema, el
                    // mismo de la cabecera del resumen, o uno de sus colores.
                    Menu {
                        ForEach(m.coloresTarjeta.indices, id: \.self) { i in
                            let c = m.coloresTarjeta[i]
                            Button { datos.onCuentasAccion("color", i) } label: {
                                Label(c.nombre, systemImage: c.puesta ? "checkmark.circle.fill" : "circle")
                            }
                        }
                    } label: { Label(cnT("Color de la tarjeta"), systemImage: "paintpalette") }
                }
            } label: {
                Label(cnT("Editar la pantalla"), systemImage: "slider.horizontal.3")
            }
        } label: {
            Image(systemName: "ellipsis")
        }
    }

    private func rotulo(_ t: String, _ total: CNCuentasModelo.Total = .init(),
                        plegado: Bool = false, grupo: Int = -1) -> some View {
        Button {
            guard grupo >= 0 else { return }
            datos.onCuentasAccion("plegar", grupo)
        } label: {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(t).font(cnLetra(13, .semibold)).foregroundColor(CNC.pmut)
                if grupo >= 0 {
                    Image(systemName: plegado ? "chevron.right" : "chevron.down")
                        .font(cnLetra(9.5, .heavy)).foregroundColor(CNC.pmut.opacity(0.7))
                }
                Spacer(minLength: 8)
                if !total.valor.isEmpty {
                    Text(total.rotulo).font(cnLetra(13)).foregroundColor(CNC.pmut)
                    Text(total.valor).font(cnLetra(13, .semibold))
                        .foregroundColor(total.tinta.isEmpty ? CNC.ink : cnColor(hexString: total.tinta))
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(grupo < 0)
        .textCase(nil)
    }

    /// La tarjeta oscura del patrimonio, con el ojo para tapar el dinero y el
    /// atajo a la tendencia.
    private func patrimonio(_ p: CNCuentasModelo.Patrimonio, oculto: Bool) -> some View {
        let tinta = p.tinta.isEmpty ? Color.white : cnColor(hexString: p.tinta)
        return VStack(spacing: 10) {
            HStack {
                Button { datos.onCuentasAccion("ocultar", 0) } label: {
                    Image(systemName: oculto ? "eye.slash" : "eye").font(cnLetra(15, .semibold))
                        .foregroundColor(tinta).frame(width: 34, height: 34)
                        .background(Color.white.opacity(0.13), in: Circle())
                }.buttonStyle(CNPulsable())
                Spacer(minLength: 8)
                Text(p.titulo).font(cnLetra(14, .semibold)).foregroundColor(tinta.opacity(0.9))
                Spacer(minLength: 8)
                Button { datos.onTendencia() } label: {
                    Image(systemName: "chart.line.uptrend.xyaxis").font(cnLetra(15, .semibold))
                        .foregroundColor(tinta).frame(width: 34, height: 34)
                        .background(Color.white.opacity(0.13), in: Circle())
                }.buttonStyle(CNPulsable())
            }
            Text(p.valor).font(cnLetra(32, .heavy)).foregroundColor(tinta)
                .lineLimit(1).minimumScaleFactor(0.5)
            HStack(spacing: 0) {
                VStack(spacing: 2) {
                    Text(p.activosLabel).font(cnLetra(12)).foregroundColor(tinta.opacity(0.75))
                    Text(p.activos).font(cnLetra(15, .bold)).foregroundColor(tinta)
                        .lineLimit(1).minimumScaleFactor(0.7)
                }.frame(maxWidth: .infinity)
                VStack(spacing: 2) {
                    Text(p.pasivosLabel).font(cnLetra(12)).foregroundColor(tinta.opacity(0.75))
                    Text(p.pasivos).font(cnLetra(15, .bold)).foregroundColor(tinta)
                        .lineLimit(1).minimumScaleFactor(0.7)
                }.frame(maxWidth: .infinity)
            }
            .padding(.top, 2)
        }
        .padding(16).frame(maxWidth: .infinity)
        .background(CNFondoCabecera(f: p.fondoObj, respaldo: p.fondo.isEmpty ? CNC.side : cnColor(hexString: p.fondo)))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    /// Una cuenta, una tarjeta o un préstamo. Sin tarjeta ni rayas propias:
    /// las pone la lista, igual que en cualquier pantalla de Ajustes.
    private func fila(_ f: CNCuentasModelo.Fila, tipo: String) -> some View {
        Button { datos.onCuentasAccion(tipo, f.indice) } label: {
            HStack(spacing: 12) {
                CNSVGShape(d: f.iconoPath)
                    .stroke(style: StrokeStyle(lineWidth: 1.9, lineCap: .round, lineJoin: .round))
                    .foregroundColor(f.color.isEmpty ? CNC.pmut : cnColor(hexString: f.color))
                    .frame(width: 19, height: 19).frame(width: 38, height: 38)
                    .background(f.fondo.isEmpty ? CNC.soft : cnColor(hexString: f.fondo))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                VStack(alignment: .leading, spacing: 3) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(f.nombre).font(cnLetra(15.5, .semibold))
                            .foregroundColor(CNC.ink).lineLimit(1)
                        Spacer(minLength: 6)
                        Text(f.valor).font(cnLetra(15.5, .semibold))
                            .foregroundColor(f.tintaValor.isEmpty ? CNC.ink : cnColor(hexString: f.tintaValor))
                            .lineLimit(1)
                    }
                    if !f.detalle.isEmpty {
                        Text(f.detalle).font(cnLetra(12)).foregroundColor(CNC.pmut).lineLimit(1)
                    }
                    if !f.pie.isEmpty {
                        CNBarraProgreso(parte: f.uso / 100,
                                        color: f.usoColor.isEmpty ? CNC.pos : cnColor(hexString: f.usoColor),
                                        alto: 5)
                            .padding(.top, 1)
                        Text(f.pie).font(cnLetra(11.5)).foregroundColor(CNC.pmut).lineLimit(1)
                    }
                }
                Image(systemName: "chevron.right").font(cnLetra(12, .semibold))
                    .foregroundColor(CNC.pmut.opacity(0.5))
            }
            .padding(.vertical, 5).contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// ── Pantalla «Plan» NATIVA (presupuesto y metas) ────────────────────────────
/// Lo que enseña el Plan, ya calculado por la web.
struct CNPlanModelo {
    struct Tab: Identifiable { var id: Int { indice }; var indice = 0; var label = ""; var puesta = false }
    struct Fila: Identifiable {
        var id: Int { indice }
        var indice = 0; var nombre = ""; var queda = ""; var pie = ""
        var pct: Double = 0; var color = ""
        var iconoPath = ""; var catColor = ""; var iconoBg = ""
        /// Lo que sale al deslizar la fila.
        var acciones: [CNAccionFila] = []
    }
    struct Meta: Identifiable {
        var id: Int { indice }
        var indice = 0; var idm = 0; var nombre = ""; var proyeccion = ""; var pctLabel = ""
        var pct: Double = 0; var color = ""; var iconoPath = ""; var iconoBg = ""
        var pie = ""; var falta = ""; var aportar = ""
    }
    var titulo = "Plan"; var tab = "presupuesto"
    /// ¿Viene de verdad? (la web solo lo arma entero estando en su pestaña)
    var listo = false
    var tabs: [Tab] = []
    var puedeEditar = true; var puedeRegistrar = true
    var presGastado = ""; var presDe = "de"; var presTotal = ""
    var presPct: Double = 0; var presColor = ""
    var presNota = ""; var presAvisoTinta = ""
    var tituloCategorias = ""; var rotuloNuevaCat = ""
    var tituloTusMetas = ""; var rotuloNuevaMeta = ""
    var filas: [Fila] = []; var metas: [Meta] = []

    static func desde(json: String) -> CNPlanModelo? {
        guard let d = json.data(using: .utf8),
              let r = (try? JSONSerialization.jsonObject(with: d)) as? [String: Any] else { return nil }
        func s(_ o: [String: Any]?, _ k: String) -> String { (o?[k] as? String) ?? "" }
        func n(_ o: [String: Any]?, _ k: String) -> Double { ((o?[k] as? NSNumber)?.doubleValue) ?? 0 }
        func b(_ o: [String: Any]?, _ k: String) -> Bool { (o?[k] as? Bool) ?? false }
        func l(_ o: [String: Any]?, _ k: String) -> [[String: Any]] { (o?[k] as? [[String: Any]]) ?? [] }
        var m = CNPlanModelo()
        m.listo = b(r, "listo")
        m.titulo = s(r, "titulo").isEmpty ? "Plan" : s(r, "titulo")
        m.tab = s(r, "tab"); m.puedeEditar = b(r, "puedeEditar"); m.puedeRegistrar = b(r, "puedeRegistrar")
        m.tabs = l(r, "tabs").map { Tab(indice: Int(n($0, "indice")), label: s($0, "label"), puesta: b($0, "puesta")) }
        m.presGastado = s(r, "presGastado"); m.presDe = s(r, "presDe"); m.presTotal = s(r, "presTotal")
        m.presPct = n(r, "presPct"); m.presColor = s(r, "presColor")
        m.presNota = s(r, "presNota"); m.presAvisoTinta = s(r, "presAvisoTinta")
        m.tituloCategorias = s(r, "tituloCategorias"); m.rotuloNuevaCat = s(r, "rotuloNuevaCat")
        m.tituloTusMetas = s(r, "tituloTusMetas"); m.rotuloNuevaMeta = s(r, "rotuloNuevaMeta")
        m.filas = l(r, "filas").map {
            Fila(indice: Int(n($0, "indice")), nombre: s($0, "nombre"), queda: s($0, "queda"),
                 pie: s($0, "pie"), pct: n($0, "pct"), color: s($0, "color"),
                 iconoPath: s($0, "iconoPath"), catColor: s($0, "catColor"), iconoBg: s($0, "iconoBg"),
                 acciones: (($0["acciones"] as? [[String: Any]]) ?? []).map { a in
                     CNAccionFila(label: (a["label"] as? String) ?? "",
                                  icono: (a["icono"] as? String) ?? "",
                                  peligro: (a["peligro"] as? Bool) ?? false,
                                  accion: ((a["accion"] as? NSNumber)?.intValue) ?? -1)
                 })
        }
        m.metas = l(r, "metas").map {
            Meta(indice: Int(n($0, "indice")), idm: Int(n($0, "idm")), nombre: s($0, "nombre"), proyeccion: s($0, "proyeccion"),
                 pctLabel: s($0, "pctLabel"), pct: n($0, "pct"), color: s($0, "color"),
                 iconoPath: s($0, "iconoPath"), iconoBg: s($0, "iconoBg"),
                 pie: s($0, "pie"), falta: s($0, "falta"), aportar: s($0, "aportar"))
        }
        return m
    }
}

struct CNPlan: View {
    @ObservedObject var datos: CNDatos
    /// En barra o en aro. Es cosa del teléfono —cómo prefieres mirarlo—, así
    /// que se guarda aquí y no hace falta ir a la web ni volver.
    private var enAro: Bool { CNC.fmt.planAro }
    /// Cómo se ven las pestañas: «sistema», «subrayado» o «pastillas».
    private var estiloPestanas: String { CNC.fmt.planPestanas }
    var body: some View {
        let m = datos.plan ?? CNPlanModelo()
        // Barra de arriba del sistema, como en Movimientos y Cuentas.
        return NavigationView {
            // Lista agrupada del sistema, como Movimientos, Cuentas y Perfil.
            List {
                if m.tab != "metas" {
                    Section {
                        resumenPres(m)
                            .overlay(alignment: .top) {
                                CNEspiaScroll { CNScrollEstado.shared.mirar($0) }
                                    .frame(height: 0).allowsHitTesting(false)
                            }
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 4, trailing: 0))
                }
                if m.tab == "metas" { metas(m) } else { presupuesto(m) }
            }
            .listStyle(.insetGrouped)
            .modifier(CNFondoLista())
            .background(CNC.scr.ignoresSafeArea())
            // Presupuesto o Metas se queda ARRIBA, pegado bajo la barra, como
            // el filtro de la biblioteca de Apple Music. Siendo una fila más de
            // la lista parecía un segundo título de la pantalla y se iba con
            // el scroll; así se lee por lo que es: un filtro de lo de abajo.
            .safeAreaInset(edge: .top, spacing: 0) {
                pestanas(m)
                    .padding(.horizontal, 16)
                    .padding(.top, 4).padding(.bottom, 10)
                    .background(.bar)
            }
            // Título en la barra, no grande: con el filtro pegado debajo, el
            // título grande dejaba una banda vacía entre los botones y las
            // pestañas (y llegó a no dibujarse). Es el mismo patrón que usa
            // Apple cuando una pantalla tiene un filtro fijo arriba.
            .navigationTitle(m.titulo)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { datos.onCalendario() } label: { Image(systemName: "calendar") }
                }
                // Cómo enseñar el presupuesto: en barra o en aro. Van las dos
                // y se elige, que cada una cuenta lo mismo de otra manera.
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Group {
                        // Igual que en Cuentas: todo lo de personalizar
                        // dentro de «Editar la pantalla». Se elige una vez y,
                        // puesta la pantalla como te gusta, no se vuelve a
                        // tocar; no tiene por qué estar a un toque.
                        Menu {
                            Menu {
                                Picker(cnT("El presupuesto"), selection: cnAjuste("planAro", { enAro }, { $0 })) {
                                    Label(cnT("En barra"), systemImage: "chart.bar.fill").tag(false)
                                    Label(cnT("En aro"), systemImage: "circle.dashed").tag(true)
                                }
                                Picker(cnT("Las pestañas"), selection: cnAjuste("planPestanas", { estiloPestanas }, { $0 })) {
                                    Label(cnT("Pastillas"), systemImage: "capsule.fill").tag("pastillas")
                                    Label(cnT("Subrayadas"), systemImage: "underline").tag("subrayado")
                                    Label(cnT("Del sistema"), systemImage: "switch.2").tag("sistema")
                                }
                            } label: {
                                Label(cnT("Editar la pantalla"), systemImage: "slider.horizontal.3")
                            }
                        } label: { Image(systemName: "ellipsis") }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { datos.onPlanAccion(m.tab == "metas" ? "nuevaMeta" : "nuevaCat", 0) } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .tint(CNC.pos)
    }

    /// Las dos pestañas: un carril con una pastilla que se desliza, como los
    /// segmentados del teléfono. Dos botones enteros competían entre sí y
    /// costaba ver cuál estaba puesto.
    /// PRESUPUESTO O METAS, DE TRES MANERAS.
    ///
    /// El segmentado del sistema es correcto pero se queda corto aquí: es una
    /// cápsula fina con dos palabras y no dice NADA de lo que hay detrás. Las
    /// otras dos sí: cuántas categorías se te fueron y por dónde van las
    /// metas, sin entrar a mirar. Se elige en el menú de la pantalla.
    @ViewBuilder private func pestanas(_ m: CNPlanModelo) -> some View {
        switch estiloPestanas {
        case "subrayado": pestanasSubrayado(m)
        case "pastillas": pestanasPastillas(m)
        default: pestanasSistema(m)
        }
    }

    /// Lo que cada pestaña tiene que contar: el presupuesto, cuántas
    /// categorías se pasaron; las metas, cuántas hay y por dónde van.
    private func avisoTab(_ i: Int, _ m: CNPlanModelo) -> (texto: String, alerta: Bool) {
        if i == 0 {
            let n = CNCalculo.presupuesto(datos.libreta, datos.periodoCalculo).excedidas
            return (n > 0 ? String(n) : "", n > 0)
        }
        guard !m.metas.isEmpty else { return ("", false) }
        let media = m.metas.reduce(0.0) { $0 + $1.pct } / Double(m.metas.count)
        return ("\(Int(media.rounded()))%", false)
    }

    private func ponerTab(_ t: CNPlanModelo.Tab) {
        UISelectionFeedbackGenerator().selectionChanged()
        datos.ponerPestanaPlan(t.indice)
        datos.onPlanAccion("tab", t.indice)
    }

    /// El del sistema, tal cual.
    private func pestanasSistema(_ m: CNPlanModelo) -> some View {
        Picker("", selection: Binding(
            get: { m.tabs.firstIndex { $0.puesta } ?? 0 },
            // Y sin repetir: al llegar la pestaña de la web, SwiftUI vuelve a
            // llamar al `set` con el mismo índice y se pedía otra vez.
            set: { i in
                guard i >= 0, i < m.tabs.count else { return }
                guard i != (m.tabs.firstIndex { $0.puesta } ?? 0) else { return }
                ponerTab(m.tabs[i])
            })) {
                ForEach(m.tabs.indices, id: \.self) { i in Text(m.tabs[i].label).tag(i) }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
    }

    /// SUBRAYADO: el nombre con su cifra al lado y una raya debajo del puesto.
    private func pestanasSubrayado(_ m: CNPlanModelo) -> some View {
        HStack(spacing: 24) {
            ForEach(m.tabs.indices, id: \.self) { i in
                let t = m.tabs[i]
                let aviso = avisoTab(i, m)
                Button { ponerTab(t) } label: {
                    VStack(spacing: 7) {
                        HStack(spacing: 7) {
                            Text(t.label)
                                .font(cnLetra(16, t.puesta ? .bold : .semibold))
                                .foregroundColor(t.puesta ? CNC.ink : CNC.pmut)
                            if !aviso.texto.isEmpty {
                                Text(aviso.texto)
                                    .font(cnLetra(11.5, .bold))
                                    .foregroundColor(aviso.alerta ? .white : CNC.pmut)
                                    .padding(.horizontal, aviso.alerta ? 6 : 0)
                                    .padding(.vertical, aviso.alerta ? 2.5 : 0)
                                    .background(aviso.alerta ? AnyView(Capsule().fill(CNC.neg))
                                                             : AnyView(Color.clear))
                            }
                        }
                        Capsule()
                            .fill(t.puesta ? CNC.ink : Color.clear)
                            .frame(height: 2.5)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            Spacer(minLength: 0)
        }
    }

    /// PASTILLAS: la puesta rellena, con su icono, y la otra al lado apagada.
    private func pestanasPastillas(_ m: CNPlanModelo) -> some View {
        HStack(spacing: 8) {
            ForEach(m.tabs.indices, id: \.self) { i in
                let t = m.tabs[i]
                let aviso = avisoTab(i, m)
                Button { ponerTab(t) } label: {
                    HStack(spacing: 7) {
                        Image(systemName: i == 0 ? "chart.pie.fill" : "target")
                            .font(cnLetra(13, .semibold))
                        Text(t.label).font(cnLetra(15, .semibold))
                        if !aviso.texto.isEmpty {
                            if aviso.alerta {
                                // Solo el punto: el número ya está en la lista
                                // de abajo, aquí basta con «mira esto».
                                Circle().fill(CNC.neg).frame(width: 7, height: 7)
                            } else {
                                Text(aviso.texto).font(cnLetra(13))
                                    .foregroundColor(t.puesta ? Color.white.opacity(0.75) : CNC.pmut)
                            }
                        }
                    }
                    .foregroundColor(t.puesta ? .white : CNC.pmut)
                    .padding(.horizontal, 15).padding(.vertical, 10)
                    .background(t.puesta ? AnyView(Capsule().fill(CNC.pos))
                                         : AnyView(Capsule().fill(CNC.card)))
                    .contentShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            Spacer(minLength: 0)
        }
    }

    /// LO GASTADO CONTRA EL PRESUPUESTO.
    ///
    /// Los números los saca Swift de la libreta (`CNCalculo`), no la web: ya
    /// estaban ahí y así se puede decir cuánto te pasaste, a qué ritmo ibas y
    /// a cuál vas, que con los textos ya formateados que manda la web no se
    /// podía.
    private func resumenPres(_ m: CNPlanModelo) -> some View {
        let c = cuentasPres()
        return Group {
            if enAro { tarjetaAro(c) } else { tarjetaBarra(c) }
        }
    }

    /// EN BARRA: el número grande y la barra de dos tramos debajo.
    private func tarjetaBarra(_ c: CuentasPres) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text(rotuloGastado()).font(cnLetra(13)).foregroundColor(CNC.pmut)
                Spacer(minLength: 8)
                if c.hayLimite {
                    Text("\(c.pct)%")
                        .font(cnLetra(13, .heavy)).foregroundColor(c.tinta)
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(c.tinta.opacity(0.12), in: Capsule())
                }
            }
            Text(cnDinero(c.gastado)).font(cnLetra(34, .heavy)).foregroundColor(CNC.ink)
                .lineLimit(1).minimumScaleFactor(0.5)
            CNBarraPresupuesto(parte: c.parteVerde, excedido: c.excedido, tinta: c.tinta)
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(cnT("Tu límite")).font(cnLetra(12)).foregroundColor(CNC.pmut)
                    Text(c.hayLimite ? cnDinero(c.limite) : "—")
                        .font(cnLetra(14, .semibold)).foregroundColor(CNC.ink)
                }
                Spacer(minLength: 8)
                VStack(alignment: .trailing, spacing: 2) {
                    Text(c.excedido ? cnT("Te pasaste") : cnT("Te queda"))
                        .font(cnLetra(12)).foregroundColor(CNC.pmut)
                    Text(c.hayLimite ? cnDinero(abs(c.limite - c.gastado)) : "—")
                        .font(cnLetra(14, .semibold))
                        .foregroundColor(c.excedido ? CNC.neg : CNC.pos)
                }
            }
            if let nota = notaPres(c) {
                HStack(alignment: .top, spacing: 9) {
                    Image(systemName: c.excedido ? "arrow.up.right" : "arrow.right")
                        .font(cnLetra(12, .bold)).foregroundColor(c.tinta)
                        .padding(.top, 1)
                    Text(nota).font(cnLetra(12.5)).foregroundColor(CNC.ink.opacity(0.75))
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 11).padding(.vertical, 10)
                .background(CNC.soft, in: RoundedRectangle(cornerRadius: 11, style: .continuous))
            }
        }
        .padding(16).tarjetaCN()
    }

    /// EN ARO: el porcentaje de un vistazo y las cifras al lado.
    private func tarjetaAro(_ c: CuentasPres) -> some View {
        // Los textos, armados ANTES. Encadenados con `+` dentro del cuerpo, el
        // compilador de Swift se atraganta intentando deducir los tipos.
        let rotulo: String = c.excedido ? cnT("Te pasaste por") : cnT("Te queda")
        let cifra: String = c.hayLimite ? cnDinero(abs(c.limite - c.gastado)) : "—"
        let limiteTxt: String = c.hayLimite ? cnDinero(c.limite) : "—"
        let detalle: String = cnT("Gastaste") + " " + cnDinero(c.gastado) + " " + cnT("de") + " " + limiteTxt
        let quedanTxt: String = String(c.diasQuedan) + " " + cnT("días")
        let veces: Double = c.hayLimite ? c.gastado / c.limite : 0
        return VStack(spacing: 14) {
            HStack(alignment: .center, spacing: 16) {
                CNAroPresupuesto(veces: veces, tinta: c.tinta)
                VStack(alignment: .leading, spacing: 3) {
                    Text(rotulo).font(cnLetra(13)).foregroundColor(CNC.pmut)
                    Text(cifra)
                        .font(cnLetra(27, .heavy))
                        .foregroundColor(c.excedido ? CNC.neg : CNC.pos)
                        .lineLimit(1).minimumScaleFactor(0.5)
                    Text(detalle)
                        .font(cnLetra(12)).foregroundColor(CNC.pmut)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            Divider()
            HStack(alignment: .top, spacing: 8) {
                pie(cnT("Límite"), limiteTxt)
                Spacer(minLength: 0)
                pie(cnT("Gastado"), cnDinero(c.gastado))
                Spacer(minLength: 0)
                pie(cnT("Quedan"), quedanTxt)
            }
        }
        .padding(16).tarjetaCN()
    }

    private func pie(_ t: String, _ v: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(t).font(cnLetra(12)).foregroundColor(CNC.pmut)
            Text(v).font(cnLetra(15, .semibold)).foregroundColor(CNC.ink)
                .lineLimit(1).minimumScaleFactor(0.7)
        }
    }

    /// Lo que enseña la tarjeta, sacado de la libreta.
    private struct CuentasPres {
        var limite: Double = 0
        var gastado: Double = 0
        var pct: Int = 0
        var hayLimite: Bool { limite > 0 }
        var excedido: Bool { limite > 0 && gastado > limite }
        /// Cuánto de la barra va en verde. Pasado el tope, el verde ocupa la
        /// parte que SÍ cabía y el resto es el exceso.
        var parteVerde: Double = 0
        var tinta: Color = CNC.pos
        /// Ritmo: lo que podías gastar al día y lo que llevas gastando.
        var porDiaLimite: Double = 0
        var porDiaReal: Double = 0
        var diasQuedan: Int = 0
        /// Las dos categorías que más se pasaron y qué parte del exceso son.
        var culpables: [String] = []
        var pctCulpa: Int = 0
    }

    private func cuentasPres() -> CuentasPres {
        var c = CuentasPres()
        let p = datos.periodoCalculo
        let pres = CNCalculo.presupuesto(datos.libreta, p)
        c.limite = pres.limiteTotal
        c.gastado = pres.gastadoTotal
        guard c.limite > 0 else { return c }
        c.pct = Int((c.gastado / c.limite * 100).rounded())
        c.parteVerde = c.gastado > c.limite ? c.limite / c.gastado : c.gastado / c.limite
        c.tinta = c.gastado > c.limite ? CNC.neg : (c.pct >= 85 ? CNC.acc : CNC.pos)

        // El ritmo. Los días salen del período: de un mes pasado se cuenta
        // entero, del que corre solo hasta hoy.
        let (total, pasados) = diasDelPeriodo(p)
        c.diasQuedan = max(0, total - pasados)
        c.porDiaLimite = c.limite / Double(max(1, total))
        c.porDiaReal = c.gastado / Double(max(1, pasados))

        // Quién explica el exceso: las dos que más se pasaron de SU tope.
        let exceso = c.gastado - c.limite
        if exceso > 0 {
            let pasadas = pres.filas
                .filter { $0.limite > 0 && $0.gastado > $0.limite }
                .sorted { ($0.gastado - $0.limite) > ($1.gastado - $1.limite) }
                .prefix(2)
            if !pasadas.isEmpty {
                c.culpables = pasadas.map { cnT($0.categoria) }
                let suyo = pasadas.reduce(0.0) { $0 + ($1.gastado - $1.limite) }
                c.pctCulpa = Int((min(1, suyo / exceso) * 100).rounded())
            }
        }
        return c
    }

    /// Cuántos días tiene el período y cuántos van. De un mes que ya pasó van
    /// todos; del que corre, hasta hoy.
    private func diasDelPeriodo(_ p: CNCalculo.Periodo) -> (total: Int, pasados: Int) {
        let cal = Calendar.current
        let f = CNFormateadores.iso
        let hoy = Date()
        if let ds = p.desde, let hs = p.hasta, let d = f.date(from: ds), let h = f.date(from: hs) {
            let total = (cal.dateComponents([.day], from: d, to: h).day ?? 0) + 1
            let vividos = (cal.dateComponents([.day], from: d, to: min(hoy, h)).day ?? 0) + 1
            return (max(1, total), max(1, min(total, vividos)))
        }
        let ym = CNFormateadores.formato("yyyy-MM", loc: "en_US_POSIX")
        guard let ini = ym.date(from: p.mes),
              let rango = cal.range(of: .day, in: .month, for: ini) else { return (30, 30) }
        let total = rango.count
        guard cal.isDate(ini, equalTo: hoy, toGranularity: .month) else { return (total, total) }
        return (total, max(1, min(total, cal.component(.day, from: hoy))))
    }

    /// «Gastado en septiembre», o «Gastado en el período» cuando es a medida.
    private func rotuloGastado() -> String {
        let p = datos.periodoCalculo
        guard !p.aMedida,
              let d = CNFormateadores.formato("yyyy-MM", loc: "en_US_POSIX").date(from: p.mes)
        else { return cnT("Gastado en el período") }
        return cnT("Gastado en") + " " + CNFormateadores.plantilla("MMMM").string(from: d)
    }

    /// La frase de abajo: el ritmo y, si te pasaste, quién lo explica.
    private func notaPres(_ c: CuentasPres) -> String? {
        guard c.hayLimite, c.porDiaLimite > 0 else { return nil }
        var t: String = cnT("Ibas a") + " " + cnDinero(c.porDiaLimite) + " " + cnT("por día") + ". "
        t += cnT("Vas a") + " " + cnDinero(c.porDiaReal) + "."
        if c.culpables.count == 1 {
            t += " " + c.culpables[0] + " " + cnT("explica el") + " " + String(c.pctCulpa) + "% " + cnT("del exceso") + "."
        } else if c.culpables.count > 1 {
            let quienes: String = c.culpables.joined(separator: " " + cnT("y") + " ")
            t += " " + quienes + " " + cnT("explican el") + " " + String(c.pctCulpa) + "% " + cnT("del exceso") + "."
        } else if c.diasQuedan > 0 {
            t += " " + cnT("Quedan") + " " + String(c.diasQuedan) + " " + cnT("días") + "."
        }
        return t
    }

    /// Las categorías del mes, en su sección. Sin botón de «+ Categoría»: el
    /// «+» de arriba ya crea la que toca según la pestaña.
    @ViewBuilder private func presupuesto(_ m: CNPlanModelo) -> some View {
        Section {
            if m.filas.isEmpty {
                cnVacioCard("Sin categorías", "Crea la primera para empezar a repartir el mes.")
            }
            ForEach(m.filas) { f in
                Button { datos.onPlanAccion("categoria", f.indice) } label: {
                    HStack(spacing: 12) {
                        CNSVGShape(d: f.iconoPath)
                            .stroke(style: StrokeStyle(lineWidth: 1.9, lineCap: .round, lineJoin: .round))
                            .foregroundColor(f.catColor.isEmpty ? CNC.pmut : cnColor(hexString: f.catColor))
                            .frame(width: 19, height: 19).frame(width: 38, height: 38)
                            .background(f.iconoBg.isEmpty ? CNC.soft : cnColor(hexString: f.iconoBg))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        VStack(alignment: .leading, spacing: 5) {
                            HStack(spacing: 8) {
                                Text(f.nombre).font(cnLetra(14.5, .semibold))
                                    .foregroundColor(CNC.ink).lineLimit(1)
                                Spacer(minLength: 6)
                                Text(f.queda).font(cnLetra(13, .bold))
                                    .foregroundColor(f.color.isEmpty ? CNC.pmut : cnColor(hexString: f.color))
                                    .lineLimit(1)
                            }
                            CNBarraProgreso(parte: f.pct / 100,
                                            color: f.color.isEmpty ? CNC.pos : cnColor(hexString: f.color), alto: 7)
                            Text(f.pie).font(cnLetra(11.5)).foregroundColor(CNC.pmut).lineLimit(1)
                        }
                        Image(systemName: "chevron.right").font(cnLetra(12, .semibold))
                            .foregroundColor(CNC.pmut.opacity(0.5))
                    }
                    .padding(.vertical, 5).contentShape(Rectangle())
                }.buttonStyle(.plain)
            }
        } header: {
            Text(m.tituloCategorias).font(cnLetra(13, .semibold))
                .foregroundColor(CNC.pmut).textCase(nil)
        }
    }

    @ViewBuilder private func metas(_ m: CNPlanModelo) -> some View {
        Section {
        if m.metas.isEmpty {
            cnVacioCard("Sin metas", "Una meta es un ahorro con nombre y fecha. Toca + para crear la primera.")
        }
        ForEach(m.metas) { g in
            let color = g.color.isEmpty ? CNC.pos : cnColor(hexString: g.color)
            VStack(alignment: .leading, spacing: 10) {
                Button { datos.onPlanAccion("meta", g.indice) } label: {
                    HStack(spacing: 12) {
                        CNSVGShape(d: g.iconoPath)
                            .stroke(style: StrokeStyle(lineWidth: 1.9, lineCap: .round, lineJoin: .round))
                            .foregroundColor(color)
                            .frame(width: 19, height: 19).frame(width: 38, height: 38)
                            .background(g.iconoBg.isEmpty ? color.opacity(0.14) : cnColor(hexString: g.iconoBg))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(g.nombre).font(cnLetra(15, .bold)).foregroundColor(CNC.ink).lineLimit(1)
                            if !g.proyeccion.isEmpty {
                                Text(g.proyeccion).font(cnLetra(11.5)).foregroundColor(CNC.pmut).lineLimit(1)
                            }
                        }
                        Spacer(minLength: 6)
                        Text(g.pctLabel).font(cnLetra(14, .heavy)).foregroundColor(color)
                    }.contentShape(Rectangle())
                }.buttonStyle(CNPulsable())
                CNBarraProgreso(parte: g.pct / 100, color: color, alto: 9)
                HStack {
                    Text(g.pie).font(cnLetra(11.5)).foregroundColor(CNC.pmut)
                    Spacer(minLength: 8)
                    Text(g.falta).font(cnLetra(11.5)).foregroundColor(CNC.pmut)
                }
                if m.puedeRegistrar && !g.aportar.isEmpty {
                    Button { datos.onPlanAccion("aportar", g.indice) } label: {
                        Text(g.aportar).font(cnLetra(13.5, .bold)).foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 12)
                            .background(color, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }.buttonStyle(CNPulsable())
                }
            }
            .padding(.vertical, 6)
        }
        } header: {
            Text(m.tituloTusMetas).font(cnLetra(13, .semibold))
                .foregroundColor(CNC.pmut).textCase(nil)
        }
    }
}

/// LA BARRA DEL PRESUPUESTO, EN DOS TRAMOS.
///
/// Mientras cabe dentro del tope es una barra normal. Cuando te pasas, la
/// barra entera pasa a ser lo GASTADO: el tramo que sí cabía va en color y el
/// resto —el exceso— va rayado, con una marca negra justo donde estaba el
/// límite. Así se ve de un vistazo cuánto te pasaste, que con una barra
/// normal llena hasta el tope no se distinguía «justo justo» de «el doble».
struct CNBarraPresupuesto: View {
    /// 0…1. Dentro del tope, lo gastado sobre el tope. Pasado el tope, la
    /// parte de lo gastado que sí cabía.
    let parte: Double
    let excedido: Bool
    /// El color del exceso (rojo). El tramo que SÍ cabía va siempre en verde:
    /// ese dinero no es el problema.
    let tinta: Color
    var alto: CGFloat = 12

    var body: some View {
        GeometryReader { g in
            let w = g.size.width
            let x = max(0, min(1, parte)) * w
            ZStack(alignment: .leading) {
                // El carril: gris cuando aún cabe, rayado cuando es el exceso.
                if excedido {
                    CNRayas(color: tinta)
                        .frame(width: w, height: alto)
                        .background(tinta.opacity(0.10))
                } else {
                    Rectangle().fill(CNC.soft).frame(width: w, height: alto)
                }
                Rectangle().fill(excedido ? CNC.pos : tinta).frame(width: x, height: alto)
                if excedido {
                    // Dónde estaba el límite.
                    Rectangle().fill(CNC.ink)
                        .frame(width: 2.5, height: alto + 6)
                        .offset(x: max(0, x - 1.25), y: -3)
                }
            }
            .clipShape(Capsule())
            .frame(height: alto)
        }
        .frame(height: alto)
    }
}

/// EL MISMO DATO, EN ARO.
///
/// La otra forma de mirarlo: el aro da el porcentaje de un vistazo y deja
/// sitio al lado para las cifras. Pasado el tope da otra vuelta: la primera
/// queda tenue por detrás y la segunda, el exceso, va en color fuerte.
struct CNAroPresupuesto: View {
    /// Lo gastado sobre el tope. 1 es justo el límite; 1,9 es un 190 %.
    let veces: Double
    let tinta: Color
    var lado: CGFloat = 96
    var grosor: CGFloat = 13

    var body: some View {
        let primera = max(0, min(1, veces))
        let segunda = max(0, min(1, veces - 1))
        return ZStack {
            Circle().stroke(CNC.soft, lineWidth: grosor)
            // La primera vuelta. Si hubo segunda, esta se queda de fondo.
            arco(primera).stroke(tinta.opacity(veces > 1 ? 0.28 : 1),
                                 style: StrokeStyle(lineWidth: grosor, lineCap: .round))
            if segunda > 0 {
                arco(segunda).stroke(tinta, style: StrokeStyle(lineWidth: grosor, lineCap: .round))
            }
            VStack(spacing: 0) {
                Text("\(Int((veces * 100).rounded()))%")
                    .font(cnLetra(19, .heavy)).foregroundColor(tinta)
                    .lineLimit(1).minimumScaleFactor(0.6)
                Text(cnT("del límite")).font(cnLetra(10)).foregroundColor(CNC.pmut)
                    .lineLimit(1).minimumScaleFactor(0.7)
            }
            .padding(.horizontal, grosor + 2)
        }
        .frame(width: lado, height: lado)
    }

    /// El arco se dibuja con sus ángulos, sin rotar la vista: rotándola se
    /// iría también el texto de dentro.
    private func arco(_ parte: Double) -> Path {
        Path { p in
            p.addArc(center: CGPoint(x: lado / 2, y: lado / 2),
                     radius: (lado - grosor) / 2,
                     startAngle: .degrees(-90),
                     endAngle: .degrees(-90 + 360 * parte),
                     clockwise: false)
        }
    }
}

/// Las rayas diagonales del exceso.
struct CNRayas: View {
    let color: Color
    var body: some View {
        GeometryReader { g in
            let paso: CGFloat = 9
            let alto = g.size.height
            Path { p in
                var x = -alto
                while x < g.size.width + alto {
                    p.move(to: CGPoint(x: x, y: alto))
                    p.addLine(to: CGPoint(x: x + alto, y: 0))
                    x += paso
                }
            }
            .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .butt))
        }
        .allowsHitTesting(false)
    }
}

// ── Piezas compartidas de Cuentas y Plan ────────────────────────────────────
/// Barra de progreso con las esquinas del sistema y sin dependencias.
struct CNBarraProgreso: View {
    let parte: Double
    var color: Color = CNC.pos
    var alto: CGFloat = 8
    var body: some View {
        GeometryReader { g in
            ZStack(alignment: .leading) {
                Capsule().fill(CNC.soft)
                Capsule().fill(color).frame(width: max(0, min(1, parte)) * g.size.width)
            }
        }
        .frame(height: alto)
    }
}

/// Segmentado propio (no el de UIKit) para que viva sobre la franja de color.
struct CNSegmentado: View {
    let opciones: [String]
    @Binding var elegida: Int
    var body: some View {
        HStack(spacing: 4) {
            ForEach(opciones.indices, id: \.self) { i in
                let puesta = elegida == i
                Button {
                    UISelectionFeedbackGenerator().selectionChanged()
                    withAnimation(.easeOut(duration: 0.18)) { elegida = i }
                } label: {
                    Text(opciones[i]).font(cnLetra(13.5, .bold))
                        .foregroundColor(puesta ? CNC.sobreAcc : CNC.pmut)
                        .frame(maxWidth: .infinity).padding(.vertical, 10)
                        .background(puesta ? AnyView(Capsule().fill(CNC.acc)) : AnyView(Color.clear))
                }.buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(CNC.soft, in: Capsule())
        .overlay(Capsule().stroke(CNC.line, lineWidth: 1))
    }
}

/// Dos iniciales, como en la web («Cuenta de la casa» → CD).
func cnIniciales(_ s: String) -> String {
    let p = s.split(separator: " ").prefix(2).compactMap { $0.first }
    return String(p).uppercased()
}

/// Tarjeta de «aquí no hay nada todavía», con su porqué.
func cnVacioCard(_ titulo: String, _ texto: String) -> some View {
    VStack(spacing: 5) {
        Text(titulo).font(cnLetra(14.5, .bold)).foregroundColor(CNC.ink)
        Text(texto).font(cnLetra(12.5)).foregroundColor(CNC.pmut)
            .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
    }
    .frame(maxWidth: .infinity).padding(.vertical, 22).padding(.horizontal, 16)
    .background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
}

/// La categoría cuyo presupuesto se está cambiando.
struct CNCatEnEdicion: Identifiable {
    var id: String { nombre }
    let nombre: String
    let limite: Double
}

/// Hoja pequeña para poner el presupuesto mensual de una categoría.
struct CNLimiteHoja: View {
    let nombre: String
    let limite: Double
    var onClose: () -> Void
    var onGuardar: (Double) -> Void
    @State private var texto = ""
    var body: some View {
        CNHoja(titulo: cnT("Presupuesto de {n}", nombre), onClose: onClose,
               onGuardar: { onGuardar(cnMonto(texto)) }) {
            CNMontoCampo(monto: $texto, paso: 500)
            Text(cnT("Cuánto quieres gastar al mes en esta categoría. Déjalo en 0 para dejarla sin presupuesto."))
                .font(cnLetra(12.5)).foregroundColor(CNC.pmut)
                .fixedSize(horizontal: false, vertical: true).padding(.horizontal, 4)
        }
        .onAppear { if limite > 0 { texto = String(Int(limite)) } }
    }
}


// Las filas ya no se deslizan. El arrastre estaba hecho a mano (no con
// `swipeActions`, que es de `List`) y competía con el scroll: se abría sin
// querer y a veces la lista no rodaba. Las mismas acciones siguen estando en
// el menú «...» de la pantalla de cada cuenta o categoría.
struct CNAccionFila: Identifiable {
    var id: Int { accion }
    var label = ""
    var icono = ""
    var peligro = false
    var accion = -1
}

struct CNResumenModelo {
    struct Parada { var color = ""; var pos: Double = 0 }
    struct Fondo { var tipo = "color"; var color = ""; var angulo: Double = 180; var paradas: [Parada] = [] }
    struct MesTira { var indice = 0; var label = ""; var puesto = false; var bg = ""; var fg = "" }
    struct Cabecera {
        var inicial = ""; var nombre = ""; var detalle = ""; var color = ""; var icono = ""
        var mesCorto = ""; var balanceRotulo = ""; var balanceFmt = ""; var balColor = ""
        var ingRotulo = ""; var ingFmt = ""; var gasRotulo = ""; var gasFmt = ""
        /// auto · fina · clara · minima · clasica · detallada
        var diseno = "auto"
        var tarjeta = false
        var fondo = Fondo(); var tinta = ""; var gris = ""; var pastilla = ""; var pastillaFuerte = ""
        var rotulo = ""; var mesLargo = ""; var periodoCorto = ""
        var grande = false
        var entraFmt = ""; var saleFmt = ""
        var hayUso = false; var usado: Double = 0; var usadoLabel = ""; var usadoColor = ""
        var abierta = true
        var positivo = ""; var negativo = ""
        /// El lila del ahorro y el ámbar del aviso, para las tarjetas que se
        /// rehacen aquí: sin ellos, el ahorro sale coral y un recordatorio a
        /// cinco días sale del color de uno a un día.
        var ahorro = ""; var aviso = ""
        var meses: [MesTira] = []
        /// La «viva»: la frase bajo el balance y las cuatro cifras en color.
        var frase = ""
        var fichas: [Ficha] = []
    }
    struct Ficha: Identifiable {
        var id: String { clave }
        var clave = ""; var label = ""; var valor = ""; var nota = ""; var icono = ""
        var color = ""; var fondo = ""
    }
    struct Punto { var x: Double = 0; var y: Double = 0; var color = "" }
    struct Barra { var x: Double = 0; var y: Double = 0; var w: Double = 0; var h: Double = 0; var color = "" }
    struct Guia { var y: Double = 0; var color = "" }
    struct Traza { var puntos = ""; var color = "" }
    struct Serie { var label = ""; var color = ""; var ultimo = "" }
    struct FilaBarra { var label = ""; var valor = ""; var pct: Double = 0; var color = ""; var iconoPath = ""; var iconoBg = "" }
    struct Columna { var label = ""; var a: Double = 0; var b: Double = 0; var peso: Double = 500; var color = "" }
    struct Tramo { var color = ""; var desde: Double = 0; var hasta: Double = 0 }
    struct FilaDona { var label = ""; var valor = ""; var color = "" }
    struct Item {
        var tieneIcono = false; var iconoPath = ""; var color = ""; var fondo = ""
        var sigla = ""; var siglaColor = ""; var titulo = ""; var detalle = ""
        var monto = ""; var montoColor = ""
    }
    struct Opcion { var id = ""; var label = "" }
    struct SerieCfg { var id = ""; var label = ""; var color = ""; var puesta = false }
    struct Widget: Identifiable {
        var id: Int { indice }
        var indice = 0; var titulo = ""; var periodo = ""; var chica = false; var oculta = false
        /// La entrada del panel a la que corresponde (para poder editarla).
        var wid = ""; var ancho = 2; var puedeChica = false
        /// De qué tipo es: «kpi-balance», «lista-recientes». El `wid` es «w1» e
        /// identifica la entrada; esto dice QUÉ enseña, y es lo que deja
        /// recalcular la tarjeta aquí sin preguntarle a la web.
        var tipoPanel = ""
        var cfgGrafico = "linea"; var cfgRango = "12"; var series: [SerieCfg] = []
        /// Las maneras de ver ESTA tarjeta. Vacío = solo tiene una.
        var vistas: [SerieCfg] = []
        var clase = "texto"
        var valor = ""; var nota = ""; var color = ""
        /// El icono de la tarjeta de cifra (para el panel con color).
        var icono = ""
        var texto = ""
        var leyenda: [Serie] = []; var guias: [Guia] = []; var areas: [Traza] = []
        var lineas: [Traza] = []; var barras: [Barra] = []; var puntos: [Punto] = []
        var etiquetas: [String] = []
        var filas: [FilaBarra] = []; var rotuloPresupuesto = ""; var vaAlPresupuesto = false
        var rotuloEntra = ""; var rotuloSale = ""; var hayMedia = false; var media: Double = 0
        var entraColor = ""; var saleColor = ""; var columnas: [Columna] = []
        var total = ""; var tramos: [Tramo] = []; var filasDona: [FilaDona] = []
        var items: [Item] = []
    }
    var cabecera = Cabecera()
    /// ¿El panel viene de verdad? (la web solo lo calcula estando en el resumen)
    var listo = false
    var vacio = false; var vacioTitulo = ""; var vacioTexto = ""; var vacioBoton = ""
    var widgets: [Widget] = []
    var tiposGrafico: [Opcion] = []; var rangosGrafico: [Opcion] = []; var catalogo: [Opcion] = []
    /// nombre de categoría → (trazo del icono, color). Los mismos que la web.
    struct IconoCat { var path = ""; var color = "" }
    var catIconos: [String: IconoCat] = [:]

    // Se lee a mano (no con Decodable): así un campo que falte o que cambie de
    // forma —la dona reusa «filas» con otra— no tira toda la pantalla abajo.
    static func desde(json: String) -> CNResumenModelo? {
        guard let d = json.data(using: .utf8),
              let raiz = (try? JSONSerialization.jsonObject(with: d)) as? [String: Any] else { return nil }
        func s(_ o: [String: Any]?, _ k: String) -> String { (o?[k] as? String) ?? "" }
        func n(_ o: [String: Any]?, _ k: String) -> Double { ((o?[k] as? NSNumber)?.doubleValue) ?? 0 }
        func b(_ o: [String: Any]?, _ k: String) -> Bool { (o?[k] as? Bool) ?? false }
        func lista(_ o: [String: Any]?, _ k: String) -> [[String: Any]] { (o?[k] as? [[String: Any]]) ?? [] }

        var m = CNResumenModelo()
        let c = raiz["cabecera"] as? [String: Any]
        var cab = Cabecera()
        cab.inicial = s(c, "inicial"); cab.nombre = s(c, "nombre"); cab.detalle = s(c, "detalle")
        cab.color = s(c, "color"); cab.icono = s(c, "icono"); cab.mesCorto = s(c, "mesCorto")
        cab.balanceRotulo = s(c, "balanceRotulo"); cab.balanceFmt = s(c, "balanceFmt"); cab.balColor = s(c, "balColor")
        cab.ingRotulo = s(c, "ingRotulo"); cab.ingFmt = s(c, "ingFmt")
        cab.gasRotulo = s(c, "gasRotulo"); cab.gasFmt = s(c, "gasFmt")
        cab.diseno = s(c, "diseno").isEmpty ? "auto" : s(c, "diseno")
        cab.tarjeta = b(c, "tarjeta"); cab.tinta = s(c, "tinta"); cab.gris = s(c, "gris")
        cab.pastilla = s(c, "pastilla"); cab.pastillaFuerte = s(c, "pastillaFuerte")
        cab.rotulo = s(c, "rotulo"); cab.mesLargo = s(c, "mesLargo"); cab.periodoCorto = s(c, "periodoCorto")
        cab.grande = b(c, "grande"); cab.entraFmt = s(c, "entraFmt"); cab.saleFmt = s(c, "saleFmt")
        cab.hayUso = b(c, "hayUso"); cab.usado = n(c, "usado"); cab.usadoLabel = s(c, "usadoLabel")
        cab.usadoColor = s(c, "usadoColor"); cab.abierta = (c?["abierta"] as? Bool) ?? true
        cab.positivo = s(c, "positivo"); cab.negativo = s(c, "negativo")
        cab.ahorro = s(c, "ahorro"); cab.aviso = s(c, "aviso")
        if let f = c?["fondo"] as? [String: Any] {
            cab.fondo = Fondo(tipo: s(f, "tipo"), color: s(f, "color"), angulo: n(f, "angulo"),
                              paradas: ((f["paradas"] as? [[String: Any]]) ?? []).map {
                                  Parada(color: s($0, "color"), pos: n($0, "pos")) })
        }
        cab.meses = ((c?["meses"] as? [[String: Any]]) ?? []).map {
            MesTira(indice: Int(n($0, "indice")), label: s($0, "label"), puesto: b($0, "puesto"),
                    bg: s($0, "bg"), fg: s($0, "fg"))
        }
        cab.frase = s(c, "frase")
        cab.fichas = ((c?["fichas"] as? [[String: Any]]) ?? []).map {
            Ficha(clave: s($0, "clave"), label: s($0, "label"), valor: s($0, "valor"), nota: s($0, "nota"),
                  icono: s($0, "icono"), color: s($0, "color"), fondo: s($0, "fondo"))
        }
        m.cabecera = cab
        m.listo = b(raiz, "listo")
        m.vacio = b(raiz, "vacio"); m.vacioTitulo = s(raiz, "vacioTitulo")
        m.vacioTexto = s(raiz, "vacioTexto"); m.vacioBoton = s(raiz, "vacioBoton")

        if let ic = raiz["catIconos"] as? [String: [String: Any]] {
            for (k, v) in ic { m.catIconos[k] = IconoCat(path: s(v, "path"), color: s(v, "color")) }
        }
        m.tiposGrafico = lista(raiz, "tiposGrafico").map { Opcion(id: s($0, "id"), label: s($0, "label")) }
        m.rangosGrafico = lista(raiz, "rangosGrafico").map { Opcion(id: s($0, "id"), label: s($0, "label")) }
        m.catalogo = lista(raiz, "catalogo").map { Opcion(id: s($0, "id"), label: s($0, "label")) }
        m.widgets = lista(raiz, "widgets").map { w in
            var x = Widget()
            x.indice = Int(n(w, "indice")); x.titulo = s(w, "titulo"); x.periodo = s(w, "periodo")
            x.chica = b(w, "chica"); x.oculta = b(w, "oculta"); x.clase = s(w, "clase")
            x.tipoPanel = s(w, "tipoPanel")
            x.wid = s(w, "wid"); x.ancho = Int(n(w, "ancho")); x.puedeChica = b(w, "puedeChica")
            x.cfgGrafico = s(w, "cfgGrafico"); x.cfgRango = s(w, "cfgRango")
            x.vistas = lista(w, "vistas").map { SerieCfg(id: s($0, "id"), label: s($0, "label"),
                                                        puesta: b($0, "puesta")) }
            x.series = lista(w, "series").map { SerieCfg(id: s($0, "id"), label: s($0, "label"),
                                                        color: s($0, "color"), puesta: b($0, "puesta")) }
            x.valor = s(w, "valor"); x.nota = s(w, "nota"); x.color = s(w, "color"); x.texto = s(w, "texto")
            x.icono = s(w, "icono")
            x.leyenda = lista(w, "leyenda").map { Serie(label: s($0, "label"), color: s($0, "color"), ultimo: s($0, "ultimo")) }
            x.guias = lista(w, "guias").map { Guia(y: n($0, "y"), color: s($0, "color")) }
            x.areas = lista(w, "areas").map { Traza(puntos: s($0, "puntos"), color: s($0, "color")) }
            x.lineas = lista(w, "lineas").map { Traza(puntos: s($0, "puntos"), color: s($0, "color")) }
            x.barras = lista(w, "barras").map { Barra(x: n($0, "x"), y: n($0, "y"), w: n($0, "w"), h: n($0, "h"), color: s($0, "color")) }
            x.puntos = lista(w, "puntos").map { Punto(x: n($0, "x"), y: n($0, "y"), color: s($0, "color")) }
            x.etiquetas = (w["etiquetas"] as? [String]) ?? []
            x.rotuloPresupuesto = s(w, "rotuloPresupuesto"); x.vaAlPresupuesto = b(w, "vaAlPresupuesto")
            x.rotuloEntra = s(w, "rotuloEntra"); x.rotuloSale = s(w, "rotuloSale")
            x.hayMedia = b(w, "hayMedia"); x.media = n(w, "media")
            x.entraColor = s(w, "entraColor"); x.saleColor = s(w, "saleColor")
            x.columnas = lista(w, "columnas").map { Columna(label: s($0, "label"), a: n($0, "a"), b: n($0, "b"), peso: n($0, "peso"), color: s($0, "color")) }
            x.total = s(w, "total")
            x.tramos = lista(w, "tramos").map { Tramo(color: s($0, "color"), desde: n($0, "desde"), hasta: n($0, "hasta")) }
            if x.clase == "dona" {
                x.filasDona = lista(w, "filas").map { FilaDona(label: s($0, "label"), valor: s($0, "valor"), color: s($0, "color")) }
            } else {
                x.filas = lista(w, "filas").map { FilaBarra(label: s($0, "label"), valor: s($0, "valor"), pct: n($0, "pct"), color: s($0, "color"), iconoPath: s($0, "iconoPath"), iconoBg: s($0, "iconoBg")) }
            }
            x.items = lista(w, "items").map {
                Item(tieneIcono: b($0, "tieneIcono"), iconoPath: s($0, "iconoPath"), color: s($0, "color"),
                     fondo: s($0, "fondo"), sigla: s($0, "sigla"), siglaColor: s($0, "siglaColor"),
                     titulo: s($0, "titulo"), detalle: s($0, "detalle"), monto: s($0, "monto"),
                     montoColor: s($0, "montoColor"))
            }
            return x
        }
        return m
    }
}

/// La cabecera de la app. Es la MISMA de la web: sus seis diseños, su paleta
/// (color o degradado), su modo tarjeta y, en la automática, el plegado al
/// rodar. El modelo lo manda la web ya resuelto; lo único que se calcula aquí
/// es lo que depende del scroll, porque el scroll es de esta pantalla.
struct CNCabeceraApp: View {
    let c: CNResumenModelo.Cabecera
    /// 0 = arriba del todo · 1 = plegada. Solo la automática lo usa.
    var progreso: Double = 1
    var onLibreta: () -> Void
    var onMes: (Int) -> Void
    var onCalendario: () -> Void = {}
    var onMesTira: (Int) -> Void = { _ in }
    var onPlegar: () -> Void = {}

    /// LA CABECERA SIGUE AL DEDO, SIN ANIMACIÓN.
    ///
    /// Llevaba `.animation(.easeOut(duration: 0.2), value: progreso)`, y
    /// `progreso` sale del scroll: cambia en CADA fotograma. O sea que cada
    /// fotograma arrancaba una animación nueva de dos décimas sobre la
    /// anterior sin terminar. Eso es lo que hacía que plegarse se sintiera
    /// gomoso y con retraso. Un valor que ya viene del dedo no se anima: se
    /// dibuja donde toca, que es como se pliegan las cabeceras del sistema.
    static let bloqueMeses: CGFloat = 114
    /// Lo que se deja por encima del contenido, ADEMÁS del margen seguro.
    ///
    /// El margen seguro de un iPhone con isla es más alto que la isla: hay unos
    /// diez puntos por debajo de ella que el sistema reserva y nadie usa. Ahí
    /// se veía una franja de color vacía entre la isla y la cápsula. Esto sube
    /// el contenido justo esos puntos —y solo en los aparatos que los tienen,
    /// porque en los de muesca el margen acaba donde acaba la muesca—, dejando
    /// unos pocos de aire para no pegarse a ella.
    private var padArriba: CGFloat {
        if c.tarjeta { return 10 }
        return cnArribaDeLaCabecera()
    }
    private var tinta: Color { c.tinta.isEmpty ? .white : cnColor(hexString: c.tinta) }
    private var gris: Color { c.gris.isEmpty ? tinta.opacity(0.8) : cnColor(hexString: c.gris) }
    private var pastilla: Color { c.pastilla.isEmpty ? Color.white.opacity(0.13) : cnColor(hexString: c.pastilla) }
    private var pastillaFuerte: Color { c.pastillaFuerte.isEmpty ? Color.white.opacity(0.22) : cnColor(hexString: c.pastillaFuerte) }
    private var balColor: Color { c.balColor.isEmpty ? tinta : cnColor(hexString: c.balColor) }

    var body: some View {
        if c.tarjeta {
            // Modo tarjeta: flota con márgenes y esquinas muy redondeadas, y
            // sube a cubrir la isla dinámica.
            contenido
                .background(CNFondoCabecera(f: c.fondo, respaldo: CNC.side))
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .padding(.horizontal, 7).padding(.bottom, 6)
                .shadow(color: Color.black.opacity(0.28), radius: 13, y: 6)
        } else {
            // Pegada: el fondo sube por debajo de la barra de estado. Recortarlo
            // (aunque fuera con radio 0) le devolvía el margen seguro y dejaba
            // una franja del color de la pantalla encima.
            contenido
                .background(CNFondoCabecera(f: c.fondo, respaldo: CNC.side).ignoresSafeArea(edges: .top))
        }
    }

    @ViewBuilder private var contenido: some View {
        switch c.diseno {
        case "viva": viva
        case "detallada": detallada
        case "clasica": clasica
        case "fina": fina
        case "clara": clara
        case "minima": minima
        default: automatica
        }
    }

    // MARK: piezas comunes
    private var cuadroLibreta: some View {
        Group {
            if !c.icono.isEmpty {
                CNSVGShape(d: c.icono)
                    .stroke(style: StrokeStyle(lineWidth: 2.1, lineCap: .round, lineJoin: .round))
                    .foregroundColor(.white).padding(5)
            } else {
                Text(c.inicial).font(cnLetra(11, .bold)).foregroundColor(.white)
            }
        }
    }
    private func capsula<C: View>(alto: CGFloat = 40, @ViewBuilder _ dentro: () -> C) -> some View {
        dentro().padding(.horizontal, 12).frame(height: alto)
            .background(pastilla, in: Capsule())
    }
    private var chevron: some View {
        Image(systemName: "chevron.down").font(cnLetra(12, .bold))
            .foregroundColor(tinta.opacity(0.8))
    }
    private func flechaMes(_ ic: String, _ lado: CGFloat = 36, _ tap: @escaping () -> Void) -> some View {
        Button(action: tap) {
            Image(systemName: ic).font(cnLetra(15, .bold)).foregroundColor(tinta)
                .frame(width: lado, height: lado)
                .background(pastilla, in: Circle())
        }.buttonStyle(CNPulsable())
    }
    private var iconoCalendario: some View {
        Image(systemName: "calendar").font(cnLetra(17, .medium))
            .foregroundColor(tinta.opacity(0.85))
    }

    // MARK: automática (la que se pliega al rodar)
    private var automatica: some View {
        GeometryReader { g in
            // Todo en CGFloat: mezclar Double y CGFloat aquí deja al compilador
            // sin saber qué operador usar.
            let p: CGFloat = CGFloat(max(0.0, min(1.0, progreso)))
            let ancho: CGFloat = g.size.width
            let anchoCap: CGFloat = min(240, 78 + CGFloat(c.nombre.count) * 8)
            let centro: CGFloat = (ancho - anchoCap) / 2
            let capX: CGFloat = centro + (14 - centro) * p
            let capMax: CGFloat = max(110, (ancho - 28) + ((ancho - 164) - (ancho - 28)) * min(1, p * 2))
            let blqAlto: CGFloat = CNCabeceraApp.bloqueMeses * (1 - p)
            let blqOpaco: Double = Double(max(0, 1 - p * 1.5))
            let blqEsc: CGFloat = 1 - 0.18 * p
            let chicoOpaco: Double = Double(max(0, (p - 0.5) / 0.5))
            VStack(spacing: 0) {
                ZStack(alignment: .topLeading) {
                    Color.clear.frame(height: 50)
                    HStack(spacing: 0) {
                        Spacer(minLength: 0)
                        Button(action: onCalendario) {
                            HStack(spacing: 10) {
                                VStack(alignment: .trailing, spacing: 0) {
                                    Text(c.balanceFmt).font(cnLetra(16, .bold)).foregroundColor(balColor)
                                    Text(c.periodoCorto).font(cnLetra(10)).foregroundColor(tinta.opacity(0.75))
                                }
                                iconoCalendario
                            }
                        }
                        .buttonStyle(CNPulsable())
                        .opacity(chicoOpaco).allowsHitTesting(chicoOpaco > 0.6)
                    }
                    .padding(.trailing, 14).frame(height: 56)
                    Button(action: onLibreta) {
                        HStack(spacing: 8) {
                            cuadroLibreta.frame(width: 24, height: 24)
                                .background(pastillaFuerte, in: Circle())
                            Text(c.nombre).font(cnLetra(14, .semibold)).foregroundColor(tinta).cnAncla("libreta")
                                .lineLimit(1)
                            chevron
                        }
                        .padding(.leading, 6).padding(.trailing, 14).padding(.vertical, 8)
                        .background(pastilla, in: Capsule())
                    }
                    .buttonStyle(CNPulsable())
                    .frame(maxWidth: capMax, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .offset(x: capX, y: 1)
                }
                VStack(spacing: 8) {
                    VStack(spacing: 2) {
                        Text(c.balanceFmt).font(cnLetra(36, .bold)).foregroundColor(balColor)
                            .lineLimit(1).minimumScaleFactor(0.5)
                        Text(c.rotulo).font(cnLetra(12)).foregroundColor(tinta.opacity(0.8))
                    }
                    .scaleEffect(blqEsc, anchor: .top)
                    tiraMeses(ancho).cnAncla("meses")
                }
                .frame(maxWidth: .infinity)
                .frame(height: max(0, blqAlto), alignment: .top)
                .opacity(blqOpaco)
                .clipped()
            }
            .padding(.bottom, 10).padding(.top, padArriba)
        }
        .frame(height: 50 + 10 + padArriba
               + CNCabeceraApp.bloqueMeses * CGFloat(1 - max(0.0, min(1.0, progreso))))
    }

    /// La tira de meses. Va centrada mientras quepa, y solo rueda si no cabe;
    /// dentro de un ScrollView horizontal hay que decirle el ancho a mano,
    /// porque ahí `maxWidth: .infinity` no significa «el de la pantalla».
    private func tiraMeses(_ ancho: CGFloat) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(c.meses, id: \.indice) { m in
                    Button { onMesTira(m.indice) } label: {
                        Text(m.label).font(cnLetra(13, m.puesto ? .bold : .semibold))
                            .foregroundColor(m.fg.isEmpty ? tinta : cnColor(hexString: m.fg))
                            .padding(.horizontal, 13).padding(.vertical, 8)
                            .background(m.bg.isEmpty ? pastilla : cnColor(hexString: m.bg), in: Capsule())
                    }.buttonStyle(CNPulsable())
                }
            }
            .padding(.horizontal, 14)
            .frame(minWidth: max(0, ancho), alignment: .center)
        }
    }

    // MARK: viva — el nombre arriba, el balance con su frase, y las cuatro
    // cifras del mes cada una en su color. Al rodar se pliega el balance y se
    // quedan las fichas, que son lo que se consulta.
    static let bloqueViva: CGFloat = 96
    private var viva: some View {
        let p: CGFloat = CGFloat(max(0.0, min(1.0, progreso)))
        let blqAlto: CGFloat = CNCabeceraApp.bloqueViva * (1 - p)
        let blqOpaco: Double = Double(max(0, 1 - p * 1.6))
        return VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Button(action: onLibreta) {
                    HStack(spacing: 6) {
                        Text(c.nombre).font(cnLetra(19, .bold)).foregroundColor(tinta).lineLimit(1).cnAncla("libreta")
                        Image(systemName: "chevron.down").font(cnLetra(12, .bold)).foregroundColor(gris)
                    }
                }.buttonStyle(CNPulsable())
                Spacer(minLength: 8)
                Button(action: onCalendario) {
                    HStack(spacing: 5) {
                        Image(systemName: "calendar").font(cnLetra(13, .semibold))
                        Text(c.periodoCorto).font(cnLetra(13, .semibold))
                    }
                    .foregroundColor(tinta.opacity(0.85))
                    .padding(.horizontal, 11).padding(.vertical, 7)
                    .background(pastilla, in: Capsule())
                }.buttonStyle(CNPulsable())
            }
            .frame(height: 44)
            VStack(alignment: .leading, spacing: 3) {
                Button(action: onCalendario) {
                    HStack(spacing: 4) {
                        Text(c.mesLargo).font(cnLetra(14, .semibold)).foregroundColor(gris)
                        Image(systemName: "chevron.down").font(cnLetra(10, .bold)).foregroundColor(gris.opacity(0.8))
                    }
                }.buttonStyle(CNPulsable())
                Text(c.balanceFmt).font(cnLetra(38, .bold)).foregroundColor(balColor)
                    .lineLimit(1).minimumScaleFactor(0.5)
                Text(c.frase).font(cnLetra(13)).foregroundColor(gris).lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: max(0, blqAlto), alignment: .top)
            .opacity(blqOpaco)
            .clipped()
        }
        .padding(.horizontal, 16).padding(.top, padArriba).padding(.bottom, 10)
        .frame(height: padArriba + 44 + 10 + blqAlto)
    }

    /// Una ficha de la viva: el color le da vida, la nota le da contexto.
    private func ficha(_ f: CNResumenModelo.Ficha) -> some View {
        let color = f.color.isEmpty ? CNC.ink : cnColor(hexString: f.color)
        let fondo = f.fondo.isEmpty ? color.opacity(0.13) : cnColor(hexString: f.fondo)
        return VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 7) {
                ZStack {
                    Circle().fill(color.opacity(0.18)).frame(width: 24, height: 24)
                    cnGlifo(f.icono, tam: 12, grosor: 2.2).foregroundColor(color)
                }
                Text(f.label).font(cnLetra(13, .semibold)).foregroundColor(color).lineLimit(1)
            }
            Text(f.valor).font(cnLetra(21, .heavy)).foregroundColor(color)
                .lineLimit(1).minimumScaleFactor(0.6)
            Text(f.nota).font(cnLetra(11.5)).foregroundColor(color.opacity(0.85)).lineLimit(1)
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 92)
        .background(fondo, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    // MARK: detallada (no se pliega; entera en el resumen, corta en el resto)
    @ViewBuilder private var detallada: some View {
        VStack(alignment: .leading, spacing: 12) {
            if c.grande {
                HStack(spacing: 10) {
                    Button(action: onLibreta) {
                        HStack(spacing: 7) {
                            cuadroLibreta.frame(width: 26, height: 26)
                                .background(cnColor(hexString: c.color), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                            Text(c.nombre).font(cnLetra(15, .bold)).foregroundColor(tinta).lineLimit(1).cnAncla("libreta")
                            chevron
                        }
                        .padding(.leading, 7).padding(.trailing, 11).padding(.vertical, 7)
                        .background(pastilla, in: Capsule())
                    }
                    .buttonStyle(CNPulsable())
                    .fixedSize(horizontal: true, vertical: false)
                    .layoutPriority(1)
                    flechaMes("chevron.left") { onMes(-1) }
                    Button(action: onCalendario) {
                        HStack(spacing: 6) {
                            Text(c.mesLargo).font(cnLetra(14, .semibold)).foregroundColor(tinta).lineLimit(1)
                            chevron
                        }
                        .frame(maxWidth: .infinity).padding(.vertical, 8)
                        .background(pastilla, in: Capsule())
                    }.buttonStyle(CNPulsable())
                    flechaMes("chevron.right") { onMes(1) }
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(c.rotulo.uppercased()).font(cnLetra(11, .bold)).tracking(1.1)
                        .foregroundColor(tinta.opacity(0.72))
                    Text(c.balanceFmt).font(cnLetra(34, .bold)).foregroundColor(balColor)
                        .lineLimit(1).minimumScaleFactor(0.5)
                }
                if c.hayUso {
                    HStack(spacing: 10) {
                        GeometryReader { g in
                            ZStack(alignment: .leading) {
                                Capsule().fill(pastilla)
                                Capsule().fill(c.usadoColor.isEmpty ? CNC.acc : cnColor(hexString: c.usadoColor))
                                    .frame(width: g.size.width * CGFloat(min(100, c.usado) / 100))
                            }
                        }.frame(height: 7)
                        Text(c.usadoLabel).font(cnLetra(12, .semibold))
                            .foregroundColor(tinta.opacity(0.85)).lineLimit(1)
                    }
                }
                HStack(spacing: 18) {
                    flecha("arrow.up", c.positivo, c.entraFmt)
                    flecha("arrow.down", c.negativo, c.saleFmt)
                    Spacer(minLength: 0)
                }
            } else {
                HStack(spacing: 10) {
                    Button(action: onLibreta) {
                        HStack(spacing: 8) {
                            cuadroLibreta.frame(width: 26, height: 26)
                                .background(cnColor(hexString: c.color), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                            Text(c.nombre).font(cnLetra(15, .bold)).foregroundColor(tinta).lineLimit(1).cnAncla("libreta")
                        }
                        .padding(.leading, 7).padding(.trailing, 13).padding(.vertical, 7)
                        .background(pastilla, in: Capsule())
                    }.buttonStyle(CNPulsable())
                    Spacer(minLength: 6)
                    VStack(alignment: .trailing, spacing: 1) {
                        Text(c.balanceFmt).font(cnLetra(19, .bold)).foregroundColor(balColor).lineLimit(1)
                        Text(c.rotulo).font(cnLetra(11)).foregroundColor(tinta.opacity(0.72)).lineLimit(1)
                    }
                }
                HStack(spacing: 8) {
                    flechaMes("chevron.left") { onMes(-1) }
                    Button(action: onCalendario) {
                        HStack(spacing: 8) {
                            Image(systemName: "calendar").font(cnLetra(16, .medium))
                            Text(c.mesLargo).font(cnLetra(14, .bold)).lineLimit(1)
                        }
                        .foregroundColor(tinta)
                        .frame(maxWidth: .infinity).padding(.vertical, 9)
                        .background(pastilla, in: Capsule())
                    }.buttonStyle(CNPulsable())
                    flechaMes("chevron.right") { onMes(1) }
                }
            }
        }
        .padding(.horizontal, 14).padding(.top, padArriba).padding(.bottom, 14)
    }
    private func flecha(_ ic: String, _ color: String, _ texto: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: ic).font(cnLetra(13, .heavy))
                .foregroundColor(color.isEmpty ? tinta : cnColor(hexString: color))
            Text(texto).font(cnLetra(13, .semibold)).foregroundColor(tinta).lineLimit(1)
        }
    }

    // MARK: clásica (se pliega con su flecha)
    private var clasica: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Button(action: onLibreta) {
                    HStack(spacing: 10) {
                        cuadroLibreta.frame(width: 34, height: 34)
                            .background(cnColor(hexString: c.color), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                        Text(c.nombre).font(cnLetra(19, .heavy)).foregroundColor(tinta).lineLimit(1).cnAncla("libreta")
                        chevron
                        Spacer(minLength: 0)
                    }
                }.buttonStyle(CNPulsable())
                HStack(spacing: 0) {
                    flechaMesPlano("chevron.left") { onMes(-1) }
                    Button(action: onCalendario) {
                        Text(c.periodoCorto).font(cnLetra(12, .bold)).foregroundColor(tinta)
                            .frame(minWidth: 66).padding(.vertical, 6)
                    }.buttonStyle(CNPulsable())
                    flechaMesPlano("chevron.right") { onMes(1) }
                }
                .padding(2)
                .background(pastilla, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
            }
            if c.abierta {
                HStack(alignment: .bottom, spacing: 12) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(c.balanceRotulo).font(cnLetra(11)).foregroundColor(gris).lineLimit(1)
                        Text(c.balanceFmt).font(cnLetra(29, .heavy)).foregroundColor(balColor)
                            .lineLimit(1).minimumScaleFactor(0.6)
                    }
                    Spacer(minLength: 8)
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(c.ingRotulo) \(c.ingFmt)").font(cnLetra(10))
                        Text("\(c.gasRotulo) \(c.gasFmt)").font(cnLetra(10))
                    }.foregroundColor(gris).lineLimit(1)
                }
                .padding(.top, 14)
            }
            Button(action: onPlegar) {
                Image(systemName: "chevron.down").font(cnLetra(14, .bold))
                    .foregroundColor(gris)
                    .rotationEffect(.degrees(c.abierta ? 0 : 180))
                    .frame(width: 64, height: 20)
            }.buttonStyle(.plain).padding(.top, 2)
        }
        .padding(.horizontal, 18).padding(.top, padArriba).padding(.bottom, 4)
        .animation(.easeOut(duration: 0.22), value: c.abierta)
    }
    private func flechaMesPlano(_ ic: String, _ tap: @escaping () -> Void) -> some View {
        Button(action: tap) {
            Image(systemName: ic).font(cnLetra(13, .bold)).foregroundColor(tinta)
                .frame(width: 28, height: 34)
        }.buttonStyle(CNPulsable())
    }

    // MARK: fina
    private var fina: some View {
        HStack(spacing: 10) {
            Button(action: onLibreta) {
                HStack(spacing: 9) {
                    cuadroLibreta.frame(width: 26, height: 26)
                        .background(pastillaFuerte, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    Text(c.nombre).font(cnLetra(17, .bold)).foregroundColor(tinta).lineLimit(1).cnAncla("libreta")
                    chevron
                }
            }.buttonStyle(CNPulsable())
            Spacer(minLength: 8)
            Button(action: onCalendario) {
                HStack(spacing: 12) {
                    VStack(alignment: .trailing, spacing: 0) {
                        Text(c.balanceFmt).font(cnLetra(16, .bold)).foregroundColor(balColor)
                        Text(c.periodoCorto).font(cnLetra(10)).foregroundColor(tinta.opacity(0.75))
                    }
                    iconoCalendario
                }
            }.buttonStyle(CNPulsable())
        }
        .padding(.horizontal, 16).frame(height: 56).padding(.top, c.tarjeta ? 8 : 0)
    }

    // MARK: clara
    private var clara: some View {
        HStack(spacing: 10) {
            Button(action: onLibreta) {
                HStack(spacing: 10) {
                    cuadroLibreta.frame(width: 30, height: 30)
                        .background(cnColor(hexString: c.color), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                    Text(c.nombre).font(cnLetra(19, .bold)).foregroundColor(tinta).lineLimit(1).cnAncla("libreta")
                    chevron
                    Spacer(minLength: 0)
                }
            }.buttonStyle(CNPulsable())
            Button(action: onCalendario) {
                Text("\(c.periodoCorto) ›").font(cnLetra(15, .semibold)).foregroundColor(CNC.pos)
            }.buttonStyle(CNPulsable())
        }
        .padding(.horizontal, 16).padding(.vertical, 10).frame(minHeight: 54)
        .padding(.top, c.tarjeta ? 8 : 0)
        .overlay(Rectangle().fill(CNC.line).frame(height: c.tarjeta ? 0 : 1), alignment: .bottom)
    }

    // MARK: mínima
    private var minima: some View {
        HStack(spacing: 10) {
            Button(action: onLibreta) {
                HStack(spacing: 9) {
                    cuadroLibreta.frame(width: 26, height: 26)
                        .background(cnColor(hexString: c.color), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    Text(c.nombre).font(cnLetra(17, .bold)).foregroundColor(tinta).lineLimit(1).cnAncla("libreta")
                    chevron
                    Spacer(minLength: 0)
                }
            }.buttonStyle(CNPulsable())
            HStack(spacing: 2) {
                Button { onMes(-1) } label: {
                    Image(systemName: "chevron.left").font(cnLetra(12, .bold)).frame(width: 26, height: 30)
                }
                Button(action: onCalendario) {
                    Text(c.periodoCorto).font(cnLetra(13, .semibold)).frame(minWidth: 66)
                }
                Button { onMes(1) } label: {
                    Image(systemName: "chevron.right").font(cnLetra(12, .bold)).frame(width: 26, height: 30)
                }
            }
            .foregroundColor(CNC.pos).buttonStyle(CNPulsable())
        }
        .padding(.horizontal, 16).frame(height: 50).padding(.top, c.tarjeta ? 8 : 0)
        .overlay(Rectangle().fill(CNC.line).frame(height: c.tarjeta ? 0 : 1), alignment: .bottom)
    }
}

/// El fondo de la cabecera: color plano o el MISMO degradado de la web (sus
/// paradas vienen ya resueltas, no un color parecido).
struct CNFondoCabecera: View {
    let f: CNResumenModelo.Fondo
    var respaldo: Color = CNC.side
    var body: some View {
        if f.tipo == "grad" && f.paradas.count > 1 {
            // El ángulo de CSS se mide en el sentido del reloj desde «hacia
            // arriba»; SwiftUI quiere los dos extremos.
            let r = (f.angulo - 90) * .pi / 180
            let dx = cos(r) / 2, dy = sin(r) / 2
            LinearGradient(
                stops: f.paradas.map { .init(color: cnColor(hexString: $0.color), location: CGFloat($0.pos)) },
                startPoint: UnitPoint(x: 0.5 - dx, y: 0.5 - dy),
                endPoint: UnitPoint(x: 0.5 + dx, y: 0.5 + dy))
        } else if !f.color.isEmpty {
            cnColor(hexString: f.color)
        } else {
            respaldo
        }
    }
}

/// Cuánto se ha rodado la lista: es lo que pliega la cabecera automática.
/// Mira cuánto se ha rodado, de verdad.
///
/// Medirlo con GeometryReader + preferencias NO funcionaba aquí: la lista se
/// movía y el valor no llegaba nunca a la vista. Esto sube por las vistas hasta
/// dar con el `UIScrollView` que SwiftUI crea por debajo y se apunta a sus
/// cambios de posición, que es el dato que de verdad manda.
/// La sombra de la tarjeta que se arrastra. Puesta o quitada del todo, no
/// puesta con opacidad cero: una sombra transparente sigue costando una pasada
/// de dibujado por cada tarjeta.
struct CNSombraLlevada: ViewModifier {
    let activa: Bool
    func body(content: Content) -> some View {
        if activa { content.shadow(color: .black.opacity(0.22), radius: 16, y: 8) }
        else { content }
    }
}

struct CNEspiaScroll: UIViewRepresentable {
    var alRodar: (CGFloat) -> Void
    func makeUIView(context: Context) -> UIView {
        let v = UIView(frame: .zero)
        v.isUserInteractionEnabled = false
        v.backgroundColor = .clear
        DispatchQueue.main.async { context.coordinator.enganchar(desde: v) }
        return v
    }
    func updateUIView(_ v: UIView, context: Context) {
        context.coordinator.alRodar = alRodar
        if context.coordinator.scroll == nil {
            DispatchQueue.main.async { context.coordinator.enganchar(desde: v) }
        }
    }
    func makeCoordinator() -> Coordinador { Coordinador(alRodar) }

    final class Coordinador: NSObject {
        var alRodar: (CGFloat) -> Void
        weak var scroll: UIScrollView?
        private var obs: NSKeyValueObservation?
        init(_ f: @escaping (CGFloat) -> Void) { alRodar = f }
        func enganchar(desde v: UIView) {
            var p: UIView? = v.superview
            while let actual = p, !(actual is UIScrollView) { p = actual.superview }
            guard let sc = p as? UIScrollView else { return }
            scroll = sc
            obs = sc.observe(\.contentOffset, options: [.new, .initial]) { [weak self] s, _ in
                let y = s.contentOffset.y + s.adjustedContentInset.top
                // Fuera del ciclo de dibujo: tocar el estado desde aquí dentro
                // saca el aviso de «modifying state during view update».
                DispatchQueue.main.async { self?.alRodar(y) }
            }
        }
        deinit { obs?.invalidate() }
    }
}

struct CNResumen: View {
    @ObservedObject var datos: CNDatos
    /// El mismo recorrido que la web (RECORRIDO = 90 px).
    @State private var rodado: CGFloat = 0
    /// Modo «organizar»: cada tarjeta enseña su ⋯ y se puede agregar.
    @State private var organiza = false
    /// La tarjeta que se lleva el dedo, dónde está cada una y cuánto se movió.
    @State private var llevada = ""
    @State private var marcos: [String: CGRect] = [:]
    @State private var desplaza: CGSize = .zero
    @State private var panelGlobal = CGRect.zero
    /// Sube cada vez que agregas una tarjeta. La lista lo mira y baja hasta
    /// ella: la nueva entra AL FINAL, y con el panel lleno cae fuera de la
    /// pantalla. Agregabas, no veías nada, y parecía que no se había agregado.
    @State private var acaboDeAgregar = 0
    /// Solo para el banco de pruebas: arrancar ya organizando.
    var organizaAlEmpezar = false
    /// Solo para el banco de pruebas: rodar la lista sola para ver el plegado.
    var rodarAlEmpezar = false
    private var progreso: Double { Double(max(0, min(1, rodado / 90))) }

    var body: some View {
        let m = datos.resumen ?? CNResumenModelo()
        // Las que se pliegan al rodar: la automática y la viva.
        let auto = m.cabecera.diseno == "auto" || m.cabecera.diseno == "viva"
        // Primero se pliega la cabecera y DESPUÉS sube el contenido, como en la
        // web: mientras se pliega, el contenido se queda pegado a su borde de
        // abajo. Se consigue devolviéndole como relleno lo que se ha rodado
        // (el `empuja` de allá); si no, el contenido sube dos veces —lo que
        // rueda y lo que encoge la cabecera— y a la primera se pierden dos
        // tarjetas.
        //
        // Medir la cabecera no hace falta: al ir en la pila vertical se
        // encoge sola, y como el scroll se lee del UIScrollView (y no de dónde
        // ha quedado el contenido), encogerse ya no se muerde la cola.
        return VStack(spacing: 0) {
            if organiza {
                // Organizando, la cabecera se aparta: lo que importa son las
                // tarjetas, y así entran más en pantalla.
                barraOrganiza(m)
                    .transition(.move(edge: .top).combined(with: .opacity))
            } else {
                CNCabeceraApp(c: m.cabecera, progreso: auto ? progreso : 1,
                              onLibreta: { datos.onSelector() }, onMes: { datos.onMes($0) },
                              onCalendario: { datos.onCalendario() },
                              onMesTira: { datos.onMesTira($0) },
                              onPlegar: { datos.onPlegar() })
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            ScrollView(showsIndicators: false) {
                ScrollViewReader { lector in
                    VStack(spacing: 0) {
                        CNEspiaScroll { y in
                            // `rodado` solo manda hasta los 90 pt que dura el
                            // plegado de la cabecera; pasados esos, seguir
                            // apuntándolo repintaba TODA la pantalla —tarjetas,
                            // gráfica y todos los iconos— en cada fotograma del
                            // scroll sin que cambiara nada. De ahí el tirón.
                            let v = max(0, min(y, 90))
                            if abs(v - rodado) > 0.5 { rodado = v }
                            CNScrollEstado.shared.mirar(y)
                        }
                        .frame(height: 0).id("cnArriba")
                        contenido(m)
                            .padding(.horizontal, 16)
                            .padding(.top, 16 + (auto ? min(rodado, 90) : 0))
                            .onAppear {
                                guard rodarAlEmpezar else { return }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                                    withAnimation(.easeOut(duration: 0.4)) { lector.scrollTo("cnAbajo", anchor: .bottom) }
                                }
                            }
                            // LO QUE ACABAS DE AGREGAR, A LA VISTA.
                            //
                            // La tarjeta nueva entra al final del panel, y con
                            // el panel lleno eso es fuera de la pantalla.
                            // Agregabas, mirabas, no pasaba nada, y lo lógico
                            // es pensar que no se agregó —lo raro sería pensar
                            // «estará abajo»—. Se espera a que la web conteste
                            // y la pinte; antes de eso no hay a dónde bajar.
                            .onChange(of: acaboDeAgregar) { _ in
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
                                    withAnimation(.easeOut(duration: 0.45)) {
                                        lector.scrollTo("cnAbajo", anchor: .bottom)
                                    }
                                }
                            }
                    }
                }
            }
        }
        .background(CNC.scr.ignoresSafeArea())
        .onChange(of: organiza) { on in
            // Por la cuenta compartida: organizar y los ajustes piden lo mismo
            // y pueden solaparse. Llamando directo, el primero que termina le
            // devuelve el menú al otro.
            datos.tapaLaBarra(on)
            // Al entrar, la web se guarda una copia del panel para poder
            // volver a ella con la ×.
            if on { datos.onPanel("editar", "", "empezar") }
        }
        .onChange(of: datos.organizarPanel) { pedido in
            if pedido {
                withAnimation(.easeOut(duration: 0.22)) { organiza = true }
                datos.organizarPanel = false
            }
        }
    }

    /// La barra de arriba mientras se organiza: qué se está haciendo, dónde se
    /// agregan tarjetas y «Listo».
    ///
    /// LOS BOTONES ESTÁN AQUÍ Y NO ABAJO. «Agregar tarjeta» y «Listo» estaban
    /// al final de la lista, así que para terminar había que rodar hasta el
    /// fondo —y arriba ya había otro «Listo», con lo que había dos—. Lo que se
    /// hace con la pantalla va en la barra de la pantalla.
    private func barraOrganiza(_ m: CNResumenModelo) -> some View {
        HStack(spacing: 10) {
            // La ×: deshacer todo lo tocado desde que se entró.
            Button {
                UISelectionFeedbackGenerator().selectionChanged()
                datos.onPanel("editar", "", "cancelar")
                withAnimation(.easeOut(duration: 0.22)) { organiza = false }
            } label: {
                Image(systemName: "xmark").font(cnLetra(16, .bold)).foregroundColor(CNC.ink)
                    .frame(width: 40, height: 40).background(CNC.soft, in: Circle())
            }.buttonStyle(CNPulsable())
            VStack(alignment: .leading, spacing: 2) {
                Text(cnT("Organiza tu panel")).font(cnLetra(16, .heavy)).foregroundColor(CNC.ink).lineLimit(1)
                Text(cnT("Mantén pulsada para mover · pellizca para el tamaño"))
                    .font(cnLetra(11.5)).foregroundColor(CNC.pmut).lineLimit(2)
            }
            Spacer(minLength: 6)
            if !m.catalogo.isEmpty {
                Menu {
                    ForEach(m.catalogo, id: \.id) { o in
                        Button(o.label) {
                            datos.onPanel("agregar", o.id, "")
                            acaboDeAgregar += 1
                        }
                    }
                } label: {
                    Image(systemName: "plus").font(cnLetra(16, .bold)).foregroundColor(CNC.ink)
                        .frame(width: 40, height: 40).background(CNC.soft, in: Circle())
                }
                .accessibilityLabel(cnT("Agregar tarjeta"))
            }
            Button {
                UISelectionFeedbackGenerator().selectionChanged()
                datos.onPanel("editar", "", "listo")
                withAnimation(.easeOut(duration: 0.22)) { organiza = false }
            } label: {
                Text(cnT("Listo")).font(cnLetra(15, .bold)).foregroundColor(CNC.sobreAcc)
                    .padding(.horizontal, 18).padding(.vertical, 10)
                    .background(CNC.acc, in: Capsule())
            }.buttonStyle(CNPulsable())
        }
        // LA MISMA ALTURA QUE LA CABECERA NORMAL. Esto llevaba
        // `8 + max(0, cnMargenArriba() - 44)` —veintitrés puntos en un iPhone
        // con isla— mientras la cabecera lleva `2 - max(0, … - 56)`, que sube.
        // Veinticuatro puntos de diferencia: al entrar en organizar, el título
        // daba un salto hacia abajo.
        .padding(.horizontal, 16).padding(.top, cnArribaDeLaCabecera()).padding(.bottom, 10)
        .frame(maxWidth: .infinity)
        .background(CNC.scr.ignoresSafeArea(edges: .top))
    }

    @ViewBuilder private func contenido(_ m: CNResumenModelo) -> some View {
        VStack(spacing: 13) {
            if m.vacio { tarjetaVacia(m) }
            // Organizando se ven TODAS (las ocultas atenuadas), para poder
            // traerlas de vuelta; fuera de ahí, solo las visibles.
            let vistas = organiza ? m.widgets : m.widgets.filter { !$0.oculta }
            CNRejilla(widgets: vistas) { w in
                CNTarjetaWidget(w: w, modelo: m, organiza: organiza,
                                primera: w.indice == 0,
                                ultima: w.indice == m.widgets.count - 1,
                                datos: datos,
                                onOrganizar: { withAnimation(.easeOut(duration: 0.22)) { organiza = true } })
                    // Dónde está cada tarjeta, para saber encima de cuál se suelta.
                    // Dónde está cada tarjeta SOLO mientras se organiza.
                    //
                    // Esto medía y publicaba la posición de todas las tarjetas
                    // SIEMPRE, y como el marco cambia en cada fotograma del
                    // scroll, `marcos` se reescribía en cada fotograma y con él
                    // se repintaba el Resumen entero. Se pagaba a todas horas
                    // algo que solo sirve para arrastrar.
                    .background(alignment: .center) {
                        if organiza {
                            GeometryReader { g in
                                Color.clear.preference(key: CNMarcosPanel.self,
                                                       value: [w.wid: g.frame(in: .named("panel"))])
                            }
                        }
                    }
                    // El meneo: la señal de «esto se puede mover», como en el
                    // teléfono. Cada tarjeta empieza para un lado distinto.
                    .modifier(CNMeneo(activo: organiza && llevada != w.wid, lado: w.indice % 2 == 0))
                    .offset(llevada == w.wid ? desplaza : .zero)
                    .scaleEffect(llevada == w.wid ? 1.04 : 1)
                    // La sombra, solo en la que se lleva el dedo: puesta en
                    // todas (aunque fuera transparente) es una pasada de
                    // dibujado por tarjeta en cada fotograma.
                    .modifier(CNSombraLlevada(activa: llevada == w.wid))
                    .zIndex(llevada == w.wid ? 10 : 0)
                    .animation(.spring(response: 0.28, dampingFraction: 0.85), value: llevada)
                    // Pellizcar: abrir los dedos la hace ancha, juntarlos la
                    // hace media. Solo las que pueden ser medias.
                    .simultaneousGesture(organiza && w.puedeChica ? pellizco(w) : nil)
            }
            .coordinateSpace(name: "panel")
            .onPreferenceChange(CNMarcosPanel.self) { marcos = $0 }
            // Dónde está el panel en la pantalla, para traducir el dedo (que
            // llega en coordenadas de ventana) a la rejilla.
            // Y dónde está el panel entero, también solo al organizar: en
            // coordenadas de pantalla esto cambia en CADA fotograma del scroll.
            .background(alignment: .center) {
                if organiza {
                    GeometryReader { g in
                        Color.clear.preference(key: CNPanelGlobal.self, value: g.frame(in: .global))
                    }
                }
            }
            .onPreferenceChange(CNPanelGlobal.self) { panelGlobal = $0 }
            .background(organiza ? CNLevantador(
                alEmpezar: { p in levantar(en: p) },
                alMover: { desplaza = $0 },
                alSoltar: { soltar($0, en: vistas) }) : nil)
            // SOLO LA PUERTA DE ENTRADA. «Agregar tarjeta» y «Listo» vivían
            // aquí abajo: para terminar había que rodar hasta el fondo, y
            // arriba ya había otro «Listo». Organizando, estos no salen.
            if !organiza {
                Button {
                    UISelectionFeedbackGenerator().selectionChanged()
                    withAnimation(.easeOut(duration: 0.2)) { organiza = true }
                } label: {
                    HStack(spacing: 7) {
                        Image(systemName: "square.grid.2x2").font(cnLetra(13, .bold))
                        Text(cnT("Organizar el panel")).font(cnLetra(13.5, .bold))
                    }
                    .foregroundColor(CNC.ink).frame(maxWidth: .infinity).padding(.vertical, 12)
                    .background(CNC.soft, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                }.buttonStyle(CNPulsable())
            }
            Color.clear.frame(height: 104).id("cnAbajo")
        }
        .onAppear { if organizaAlEmpezar { organiza = true } }
    }

    /// Mantener pulsada y arrastrar. Al soltar, la tarjeta ocupa el sitio de la
    /// que tenga debajo el dedo (su índice en el panel de la web).
    private func pellizco(_ w: CNResumenModelo.Widget) -> some Gesture {
        MagnificationGesture()
            .onEnded { escala in
                if escala > 1.22 && w.ancho == 1 {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    datos.onPanel("ancho", w.wid, "2")
                } else if escala < 0.82 && w.ancho == 2 {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    datos.onPanel("ancho", w.wid, "1")
                }
            }
    }

    /// Mantener pulsada una tarjeta la levanta. El punto llega en coordenadas
    /// de ventana; se pasa a las del panel y se busca sobre cuál cayó el dedo.
    private func levantar(en p: CGPoint) {
        let local = CGPoint(x: p.x - panelGlobal.minX, y: p.y - panelGlobal.minY)
        guard let wid = marcos.first(where: { $0.value.contains(local) })?.key else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        llevada = wid; desplaza = .zero
    }
    /// Al soltar: si el centro de la tarjeta cayó encima de otra, ocupa su sitio.
    private func soltar(_ t: CGSize, en vistas: [CNResumenModelo.Widget]) {
        let w = llevada
        defer { withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) { llevada = ""; desplaza = .zero } }
        guard !w.isEmpty, let mio = marcos[w] else { return }
        let centro = CGPoint(x: mio.midX + t.width, y: mio.midY + t.height)
        guard let destino = vistas.first(where: { $0.wid != w && (marcos[$0.wid]?.contains(centro) ?? false) })
        else { return }
        UISelectionFeedbackGenerator().selectionChanged()
        datos.onPanel("mover", w, String(destino.indice))
    }

    private func tarjetaVacia(_ m: CNResumenModelo) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(m.vacioTitulo).font(cnLetra(17, .heavy)).foregroundColor(CNC.ink)
            Text(m.vacioTexto).font(cnLetra(13)).foregroundColor(CNC.pmut)
                .fixedSize(horizontal: false, vertical: true)
            Button { datos.onEmpezar() } label: {
                Text(m.vacioBoton).font(cnLetra(15, .heavy)).foregroundColor(CNC.sobreAcc)
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                    .background(CNC.acc, in: Capsule())
            }.buttonStyle(CNPulsable()).padding(.top, 12)
        }
        .padding(.horizontal, 16).padding(.vertical, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

/// Coloca las tarjetas como la web: las anchas ocupan la fila entera y las
/// chicas van de dos en dos, en el orden en que vienen.

// ── Arrastrar las tarjetas del panel con el dedo ────────────────────────────
//
// En «organizar», una tarjeta se mantiene pulsada, se levanta y se suelta
// encima de otra: ocupa su sitio. El orden lo guarda la web (`mover`), aquí
// solo se mide dónde cayó. Sin reflujo en vivo a propósito: levantar, ver y
// soltar es lo que se entiende de un vistazo, y no hace temblar la lista.
/// El meneo de las tarjetas mientras se organiza el panel: un vaivén de un
/// grado, cada una a su ritmo, como los iconos del teléfono.
struct CNMeneo: ViewModifier {
    var activo: Bool
    var lado: Bool
    @State private var vaiven = false
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(activo ? (vaiven ? 1.1 : -1.1) * (lado ? 1 : -1) : 0))
            .onChange(of: activo) { on in
                if on {
                    withAnimation(.easeInOut(duration: 0.13).repeatForever(autoreverses: true)) { vaiven = true }
                } else {
                    withAnimation(.easeOut(duration: 0.15)) { vaiven = false }
                }
            }
            .onAppear {
                if activo { withAnimation(.easeInOut(duration: 0.13).repeatForever(autoreverses: true)) { vaiven = true } }
            }
    }
}

/// Apunta dónde está una vista, para que el tour la pueda señalar.
struct CNAncla: ViewModifier {
    let id: String
    func body(content: Content) -> some View {
        content.background(GeometryReader { g in
            Color.clear
                .onAppear { CNDatos.shared.apuntaAncla(id, g.frame(in: .global)) }
                .onChange(of: g.frame(in: .global)) { r in CNDatos.shared.apuntaAncla(id, r) }
        })
    }
}
extension View {
    func cnAncla(_ id: String) -> some View { modifier(CNAncla(id: id)) }
}

/// Un teléfono en miniatura pintado con lo que la opción propone: el fondo,
/// la franja de arriba, dos tarjetas, la píldora del acento y el menú.
struct CNTelefonoMini: View {
    let o: CNSeccion.Opcion
    private func c(_ css: String, _ siNo: Color) -> Color { css.isEmpty ? siNo : cnColor(hexString: css) }
    var body: some View {
        let fondo = c(o.fondo, CNC.scr)
        let tarjeta = c(o.tarjeta, CNC.card)
        let franja = c(o.franja, CNC.side)
        let acento = c(o.acento, CNC.acc)
        let raya = o.oscuro ? Color.white.opacity(0.22) : Color.black.opacity(0.14)
        ZStack {
            pantalla(fondo: fondo, tarjeta: tarjeta, franja: franja, acento: acento, raya: raya)
            if o.vista == "modo" && o.valor == "auto" && !o.nocheFondo.isEmpty {
                // Automático: la mitad de noche, en diagonal.
                pantalla(fondo: c(o.nocheFondo, .black), tarjeta: c(o.nocheTarjeta, .gray),
                         franja: c(o.nocheFranja, .black), acento: acento, raya: Color.white.opacity(0.22))
                    .clipShape(Diagonal())
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func pantalla(fondo: Color, tarjeta: Color, franja: Color, acento: Color, raya: Color) -> some View {
        VStack(spacing: 0) {
            // La franja de arriba: la cabecera (o solo la isla, si no hay).
            ZStack(alignment: .top) {
                Rectangle().fill(o.vista == "cabecera" || o.vista == "tema" || o.vista == "modo" ? franja : fondo)
                    .frame(height: o.vista == "cabecera" ? max(14, min(46, o.alto * 1.4)) : 34)
                Capsule().fill(Color.black.opacity(0.75)).frame(width: 18, height: 4).padding(.top, 5)
                if o.vista == "cabecera" && o.bulto {
                    RoundedRectangle(cornerRadius: 3, style: .continuous).fill(Color.white.opacity(0.6))
                        .frame(width: 30, height: 6).padding(.top, 16)
                }
            }
            VStack(spacing: 6) {
                if o.vista == "paleta" && o.puntos.count >= 3 {
                    // Las cifras de colores: tres tarjetas, cada una con su color.
                    ForEach(0..<3, id: \.self) { k in
                        HStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 2, style: .continuous).fill(cnColor(hexString: o.puntos[k])).frame(width: 22, height: 5)
                            Spacer(minLength: 0)
                        }
                        .padding(7).frame(maxWidth: .infinity)
                        .background(tarjeta, in: RoundedRectangle(cornerRadius: 5, style: .continuous))
                    }
                } else {
                    VStack(alignment: .leading, spacing: 4) {
                        RoundedRectangle(cornerRadius: 2, style: .continuous).fill(raya).frame(width: 30, height: 4)
                        RoundedRectangle(cornerRadius: 2, style: .continuous).fill(acento).frame(width: 22, height: 5)
                    }
                    .padding(7).frame(maxWidth: .infinity, alignment: .leading)
                    .background(tarjeta, in: RoundedRectangle(cornerRadius: 5, style: .continuous))
                    HStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 5, style: .continuous).fill(tarjeta).frame(height: 22)
                        RoundedRectangle(cornerRadius: 5, style: .continuous).fill(tarjeta).frame(height: 22)
                    }
                    RoundedRectangle(cornerRadius: 5, style: .continuous).fill(tarjeta).frame(height: 26)
                }
                Spacer(minLength: 0)
                // El menú de abajo, con el acento en la pestaña activa.
                HStack(spacing: 5) {
                    Circle().fill(acento).frame(width: 5, height: 5)
                    ForEach(0..<3, id: \.self) { _ in Circle().fill(raya).frame(width: 4, height: 4) }
                }
                .padding(.bottom, 5)
            }
            .padding(6)
        }
        .background(fondo)
    }

    private struct Diagonal: Shape {
        func path(in r: CGRect) -> Path {
            var p = Path()
            p.move(to: CGPoint(x: r.maxX, y: r.minY))
            p.addLine(to: CGPoint(x: r.maxX, y: r.maxY))
            p.addLine(to: CGPoint(x: r.minX, y: r.maxY))
            p.closeSubpath()
            return p
        }
    }
}

struct CNMarcosPanel: PreferenceKey {
    static var defaultValue: [String: CGRect] = [:]
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

struct CNRejilla<C: View>: View {
    let widgets: [CNResumenModelo.Widget]
    @ViewBuilder var celda: (CNResumenModelo.Widget) -> C
    private var filas: [[CNResumenModelo.Widget]] {
        var out: [[CNResumenModelo.Widget]] = []
        for w in widgets {
            if w.chica, var ultima = out.last, ultima.count == 1, ultima[0].chica {
                ultima.append(w); out[out.count - 1] = ultima
            } else {
                out.append([w])
            }
        }
        return out
    }
    var body: some View {
        VStack(spacing: 13) {
            ForEach(filas.indices, id: \.self) { i in
                HStack(alignment: .top, spacing: 13) {
                    ForEach(filas[i]) { w in celda(w).frame(maxWidth: .infinity) }
                    if filas[i].count == 1 && filas[i][0].chica { Color.clear.frame(maxWidth: .infinity) }
                }
            }
        }
    }
}

/// Una tarjeta del panel. Cada clase se dibuja con las medidas de la web.
struct CNTarjetaWidget: View {
    let w: CNResumenModelo.Widget
    let modelo: CNResumenModelo
    var organiza: Bool = false
    var primera: Bool = false
    var ultima: Bool = false
    @ObservedObject var datos: CNDatos
    /// Entrar en «organizar» desde el menú de la propia tarjeta.
    var onOrganizar: () -> Void = {}
    /// Con «tarjetas con color» puesto, las de cifra van del color de su cifra.
    private var conVida: Bool { CNC.fmt.panelVivo && w.clase == "cifra" && !w.color.isEmpty }
    private var tinteVida: Color { cnColor(hexString: w.color) }
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                if conVida {
                    // El chip con el icono: es lo que hace que cada tarjeta se
                    // reconozca de un vistazo antes de leer nada.
                    ZStack {
                        Circle().fill(tinteVida.opacity(0.18)).frame(width: 22, height: 22)
                        cnGlifo(w.icono.isEmpty ? "grafico" : w.icono, tam: 11, grosor: 2.2).foregroundColor(tinteVida)
                    }
                    .alignmentGuide(.firstTextBaseline) { d in d[VerticalAlignment.center] + 5 }
                }
                Text(w.titulo).font(cnLetra(13, conVida ? .semibold : .regular))
                    .foregroundColor(conVida ? tinteVida : CNC.pmut).lineLimit(1)
                Spacer(minLength: 0)
                if !w.periodo.isEmpty {
                    Text(w.periodo).font(cnLetra(12, .semibold)).foregroundColor(CNC.pmut)
                }
                if organiza {
                    Menu { acciones } label: {
                        Image(systemName: "ellipsis").font(cnLetra(13, .bold))
                            .foregroundColor(CNC.pmut).frame(width: 28, height: 24)
                            .background(CNC.soft, in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                    }
                }
            }
            .padding(.bottom, 8)
            cuerpo
        }
        .padding(16).frame(maxWidth: .infinity, alignment: .leading)
        .background(conVida ? tinteVida.opacity(0.13) : CNC.card)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        // Sin contorno, como el resto de las tarjetas. Esta se me escapó en la
        // barrida porque su fondo es condicional —`conVida ? tinte : card`— y
        // busqué por las que llevaban `background(CNC.card)` al lado. Las
        // separaciones de DENTRO de la tarjeta siguen donde estaban.
        .opacity(w.oculta ? 0.42 : 1)
        // Mantener pulsado: lo mismo, sin tener que entrar en «organizar».
        .contextMenu { acciones }
    }

    /// Todo lo que se puede hacer con una tarjeta, en el menú del sistema: lo
    /// mismo que la web deja hacer arrastrando y estirando.
    @ViewBuilder private var acciones: some View {
        if !organiza {
            Button { onOrganizar() } label: {
                Label(cnT("Organizar el panel"), systemImage: "square.grid.2x2")
            }
            Divider()
        }
        // CÓMO SE VE ESTA TARJETA. La misma cifra contada de otra manera: los
        // gastos por categoría en barras, en dona o en lista. Va con la
        // TARJETA y no con el tipo, así que dos iguales en el mismo panel
        // pueden verse distinto, que es media gracia de poder tener dos.
        if !w.vistas.isEmpty {
            Menu(cnT("Cómo se ve")) {
                ForEach(w.vistas, id: \.id) { o in
                    Button { datos.onPanel("vista", w.wid, o.id) } label: {
                        Label(o.label, systemImage: o.puesta ? "checkmark.circle.fill" : "circle")
                    }
                }
            }
            Divider()
        }
        if w.clase == "serie" {
            Menu("Tipo de gráfica") {
                Picker("", selection: Binding(get: { w.cfgGrafico },
                                              set: { datos.onPanel("grafico", w.wid, $0) })) {
                    ForEach(modelo.tiposGrafico, id: \.id) { g in Text(g.label).tag(g.id) }
                }
            }
            Menu("Cuánto tiempo") {
                Picker("", selection: Binding(get: { w.cfgRango },
                                              set: { datos.onPanel("rango", w.wid, $0) })) {
                    ForEach(modelo.rangosGrafico, id: \.id) { r in Text(r.label).tag(r.id) }
                }
            }
            Menu("Qué se compara") {
                ForEach(w.series, id: \.id) { sr in
                    Button { datos.onPanel("serie", w.wid, sr.id) } label: {
                        Label(sr.label, systemImage: sr.puesta ? "checkmark.circle.fill" : "circle")
                    }
                }
            }
            Divider()
        }
        if w.puedeChica {
            Button { datos.onPanel("ancho", w.wid, w.ancho == 1 ? "2" : "1") } label: {
                Label(w.ancho == 1 ? "Hacerla ancha" : "Hacerla media",
                      systemImage: w.ancho == 1 ? "rectangle" : "rectangle.split.2x1")
            }
        }
        if !primera {
            Button { datos.onPanel("mover", w.wid, String(w.indice - 1)) } label: {
                Label(cnT("Subir"), systemImage: "arrow.up")
            }
        }
        if !ultima {
            Button { datos.onPanel("mover", w.wid, String(w.indice + 1)) } label: {
                Label(cnT("Bajar"), systemImage: "arrow.down")
            }
        }
        Button { datos.onPanel("ocultar", w.wid, "") } label: {
            Label(w.oculta ? "Mostrar aquí" : "Ocultar aquí", systemImage: w.oculta ? "eye" : "eye.slash")
        }
        Button(role: .destructive) { datos.onPanel("quitar", w.wid, "") } label: {
            Label(cnT("Quitar del panel"), systemImage: "trash")
        }
    }

    @ViewBuilder private var cuerpo: some View {
        switch w.clase {
        case "cifra":
            VStack(alignment: .leading, spacing: 3) {
                Text(w.valor).font(.system(size: w.chica ? 21 : 26, weight: .heavy))
                    .foregroundColor(w.color.isEmpty ? CNC.ink : cnColor(hexString: w.color))
                    .lineLimit(1).minimumScaleFactor(0.5)
                Text(w.nota).font(cnLetra(11)).foregroundColor(conVida ? tinteVida.opacity(0.85) : CNC.pmut)
                    .fixedSize(horizontal: false, vertical: true)
            }
        case "texto":
            Text(w.texto).font(cnLetra(13)).foregroundColor(CNC.ink)
                .fixedSize(horizontal: false, vertical: true)
        case "serie": serie
        case "barras": barras
        case "columnas": columnas
        case "dona": dona
        default: lista
        }
    }

    // MARK: gráfica de series (mismo lienzo 100×42 de la web)
    private var serie: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !w.leyenda.isEmpty {
                // Arriba, como en la web: punto, nombre y cifra en una línea, de
                // dos en dos; con más series, renglones debajo (al lado no caben).
                CNRejillaFija(columnas: w.leyenda.count == 1 ? 1 : 2, total: w.leyenda.count, alto: 6) { i in
                    let s = w.leyenda[i]
                    HStack(spacing: 6) {
                        Circle().fill(cnColor(hexString: s.color)).frame(width: 8, height: 8)
                        Text(s.label).font(cnLetra(12)).foregroundColor(CNC.pmut).lineLimit(1)
                        Text(s.ultimo).font(cnLetra(12.5, .bold)).foregroundColor(CNC.ink)
                            .lineLimit(1).minimumScaleFactor(0.75)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.bottom, 2)
            }
            CNLienzoSerie(w: w).frame(height: 170)
            if !w.etiquetas.isEmpty {
                // Como mucho seis rótulos en el eje, repartidos: con veinticuatro
                // meses cada uno tenía dos letras de ancho y se partía en tres
                // renglones. Los que se enseñan van en un solo renglón.
                let idx = ejeVisible(w.etiquetas.count)
                HStack(spacing: 0) {
                    ForEach(idx, id: \.self) { i in
                        Text(w.etiquetas[i]).font(cnLetra(10)).foregroundColor(CNC.pmut)
                            .lineLimit(1).minimumScaleFactor(0.7)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }

    /// Qué rótulos del eje se enseñan: todos si son pocos, y si no seis
    /// repartidos (siempre el primero y el último).
    private func ejeVisible(_ n: Int) -> [Int] {
        guard n > 6 else { return Array(0..<n) }
        let paso = Double(n - 1) / 5
        var out = (0..<6).map { Int((Double($0) * paso).rounded()) }
        out[5] = n - 1
        return Array(Set(out)).sorted()
    }

    // MARK: barras por categoría
    private var barras: some View {
        VStack(spacing: 10) {
            ForEach(w.filas.indices, id: \.self) { i in
                let r = w.filas[i]
                HStack(spacing: 11) {
                    if !r.iconoPath.isEmpty {
                        CNSVGShape(d: r.iconoPath)
                            .stroke(style: StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round))
                            .foregroundColor(cnColor(hexString: r.color))
                            .frame(width: 19, height: 19)
                            .frame(width: 34, height: 34)
                            // Sin fondo puesto, el color propio al 15%. Es lo
                            // mismo que la web calcula con `color-mix(… 15%,
                            // transparent)` y lo que se usa cuando la tarjeta
                            // se rehace aquí: leer un `color-mix` en Swift daba
                            // NEGRO, y los cuadros salían negros.
                            .background(r.iconoBg.isEmpty
                                ? cnColor(hexString: r.color).opacity(0.15)
                                : cnColor(hexString: r.iconoBg))
                            .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                    }
                    VStack(spacing: 5) {
                        HStack {
                            Text(r.label).font(cnLetra(12, .semibold)).foregroundColor(CNC.ink).lineLimit(1)
                            Spacer(minLength: 8)
                            Text(r.valor).font(cnLetra(12)).foregroundColor(CNC.pmut)
                        }
                        CNBarraProgreso(parte: r.pct / 100, color: cnColor(hexString: r.color), alto: 8)
                    }
                }
            }
            if w.vaAlPresupuesto {
                Button { datos.onVerPresupuesto() } label: {
                    Text(w.rotuloPresupuesto).font(cnLetra(13, .bold)).foregroundColor(CNC.ink)
                        .frame(maxWidth: .infinity).padding(.vertical, 11)
                        .background(CNC.soft, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                }.buttonStyle(CNPulsable()).padding(.top, 4)
            }
        }
    }

    // MARK: columnas de tendencia
    private var columnas: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 14) {
                punto(w.rotuloEntra, w.entraColor)
                punto(w.rotuloSale, w.saleColor)
                Spacer(minLength: 0)
            }
            .padding(.bottom, 12)
            ZStack(alignment: .bottom) {
                HStack(alignment: .bottom, spacing: 9) {
                    ForEach(w.columnas.indices, id: \.self) { i in
                        let t = w.columnas[i]
                        VStack(spacing: 6) {
                            HStack(alignment: .bottom, spacing: 2) {
                                columna(t.a, w.entraColor)
                                columna(t.b, w.saleColor)
                            }
                            .frame(maxHeight: .infinity, alignment: .bottom)
                            // Sin color puesto, el gris de las etiquetas. La
                            // web no manda ninguno para el mes, y una cadena
                            // vacía se lee como «transparent»: los seis meses
                            // estaban escritos y no se veía ni uno.
                            Text(t.label).font(cnLetra(10, t.peso >= 700 ? .bold : .regular))
                                .foregroundColor(t.color.isEmpty ? CNC.pmut : cnColor(hexString: t.color))
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 118)
                if w.hayMedia {
                    GeometryReader { g in
                        let alto = max(0, g.size.height - 22)
                        Path { p in
                            let y = g.size.height - 22 - alto * CGFloat(w.media / 100)
                            p.move(to: CGPoint(x: 0, y: y)); p.addLine(to: CGPoint(x: g.size.width, y: y))
                        }
                        .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                        .foregroundColor(CNC.pmut.opacity(0.5))
                    }
                    .frame(height: 118)
                    .allowsHitTesting(false)
                }
            }
        }
    }
    private func columna(_ pct: Double, _ color: String) -> some View {
        GeometryReader { g in
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                CNColumnaForma(radio: 4)
                    .fill(cnColor(hexString: color))
                    .frame(height: max(3, g.size.height * CGFloat(pct / 100)))
            }
        }
    }
    private func punto(_ t: String, _ c: String) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 4, style: .continuous).fill(cnColor(hexString: c)).frame(width: 9, height: 9)
            Text(t).font(cnLetra(12, .semibold)).foregroundColor(CNC.pmut)
        }
    }

    // MARK: dona
    private var dona: some View {
        HStack(spacing: 16) {
            ZStack {
                ForEach(w.tramos.indices, id: \.self) { i in
                    let t = w.tramos[i]
                    Circle().trim(from: t.desde / 100, to: max(t.desde, t.hasta) / 100)
                        .stroke(cnColor(hexString: t.color), lineWidth: 20)
                        .rotationEffect(.degrees(-90))
                        .frame(width: 84, height: 84)
                }
                VStack(spacing: 0) {
                    Text(cnT("Total")).font(cnLetra(9)).foregroundColor(CNC.pmut)
                    Text(w.total).font(cnLetra(12, .heavy)).foregroundColor(CNC.ink)
                        .lineLimit(1).minimumScaleFactor(0.6).padding(.horizontal, 4)
                }
                .frame(width: 64, height: 64)
            }
            .frame(width: 104, height: 104)
            VStack(spacing: 7) {
                ForEach(w.filasDona.indices, id: \.self) { i in
                    let r = w.filasDona[i]
                    HStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 3, style: .continuous).fill(cnColor(hexString: r.color)).frame(width: 9, height: 9)
                        Text(r.label).font(cnLetra(12)).foregroundColor(CNC.ink)
                        Spacer(minLength: 6)
                        Text(r.valor).font(cnLetra(12, .bold)).foregroundColor(CNC.ink)
                    }
                }
            }
        }
    }

    // MARK: listas (recientes, recordatorios, metas)
    private var lista: some View {
        VStack(spacing: 0) {
            ForEach(w.items.indices, id: \.self) { i in
                let it = w.items[i]
                HStack(spacing: 10) {
                    if it.tieneIcono && !it.iconoPath.isEmpty {
                        CNSVGShape(d: it.iconoPath)
                            .stroke(style: StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round))
                            .foregroundColor(cnColor(hexString: it.color))
                            .frame(width: 18, height: 18)
                            .frame(width: 34, height: 34)
                            // Sin fondo puesto, el color propio al 15%: lo
                            // mismo que la web resuelve con `color-mix`.
                            .background(it.fondo.isEmpty
                                ? cnColor(hexString: it.color).opacity(0.15)
                                : cnColor(hexString: it.fondo))
                            .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                    } else {
                        Text(it.sigla).font(cnLetra(11, .heavy))
                            .foregroundColor(cnColor(hexString: it.siglaColor))
                            .frame(width: 34, height: 34)
                            .background(cnColor(hexString: it.fondo))
                            .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(it.titulo).font(cnLetra(13, .semibold)).foregroundColor(CNC.ink).lineLimit(1)
                        Text(it.detalle).font(cnLetra(11)).foregroundColor(CNC.pmut).lineLimit(1)
                    }
                    Spacer(minLength: 6)
                    Text(it.monto).font(cnLetra(13, .bold))
                        .foregroundColor(cnColor(hexString: it.montoColor))
                }
                .padding(.vertical, 11)
                if i < w.items.count - 1 { Rectangle().fill(CNC.soft).frame(height: 1) }
            }
        }
    }
}

/// Esquinas superiores redondeadas (las columnas de la tendencia).
struct CNColumnaForma: Shape {
    var radio: CGFloat = 4
    func path(in r: CGRect) -> Path {
        var p = Path()
        let rr = min(radio, r.height / 2, r.width / 2)
        p.move(to: CGPoint(x: r.minX, y: r.maxY))
        p.addLine(to: CGPoint(x: r.minX, y: r.minY + rr))
        p.addQuadCurve(to: CGPoint(x: r.minX + rr, y: r.minY), control: CGPoint(x: r.minX, y: r.minY))
        p.addLine(to: CGPoint(x: r.maxX - rr, y: r.minY))
        p.addQuadCurve(to: CGPoint(x: r.maxX, y: r.minY + rr), control: CGPoint(x: r.maxX, y: r.minY))
        p.addLine(to: CGPoint(x: r.maxX, y: r.maxY))
        p.closeSubpath()
        return p
    }
}

/// El lienzo de la gráfica de series: el mismo viewBox 0 0 100 42 de la web,
/// con sus guías, áreas, líneas, barras y puntos ya calculados allí.
struct CNLienzoSerie: View {
    let w: CNResumenModelo.Widget
    private func pares(_ s: String) -> [CGPoint] {
        s.split(separator: " ").compactMap { par in
            let xy = par.split(separator: ",")
            guard xy.count == 2, let x = Double(xy[0]), let y = Double(xy[1]) else { return nil }
            return CGPoint(x: x, y: y)
        }
    }
    var body: some View {
        GeometryReader { g in
            let ex = g.size.width / 100, ey = g.size.height / 42
            ZStack {
                ForEach(w.guias.indices, id: \.self) { i in
                    Path { p in
                        let y = w.guias[i].y * ey
                        p.move(to: CGPoint(x: 0, y: y)); p.addLine(to: CGPoint(x: g.size.width, y: y))
                    }.stroke(cnColor(hexString: w.guias[i].color), lineWidth: 1)
                }
                ForEach(w.areas.indices, id: \.self) { i in
                    forma(pares(w.areas[i].puntos), ex, ey, cerrada: true)
                        .fill(cnColor(hexString: w.areas[i].color).opacity(0.18))
                }
                ForEach(w.barras.indices, id: \.self) { i in
                    let b = w.barras[i]
                    RoundedRectangle(cornerRadius: 1, style: .continuous)
                        .fill(cnColor(hexString: b.color))
                        .frame(width: max(1, b.w * ex), height: max(1, b.h * ey))
                        .position(x: (b.x + b.w / 2) * ex, y: (b.y + b.h / 2) * ey)
                }
                ForEach(w.lineas.indices, id: \.self) { i in
                    forma(pares(w.lineas[i].puntos), ex, ey, cerrada: false)
                        .stroke(cnColor(hexString: w.lineas[i].color),
                                style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                }
                ForEach(w.puntos.indices, id: \.self) { i in
                    let p = w.puntos[i]
                    Circle().fill(cnColor(hexString: p.color)).frame(width: 4.8, height: 4.8)
                        .position(x: p.x * ex, y: p.y * ey)
                }
            }
        }
    }
    private func forma(_ pts: [CGPoint], _ ex: CGFloat, _ ey: CGFloat, cerrada: Bool) -> Path {
        var p = Path()
        guard let primero = pts.first else { return p }
        p.move(to: CGPoint(x: primero.x * ex, y: primero.y * ey))
        for q in pts.dropFirst() { p.addLine(to: CGPoint(x: q.x * ex, y: q.y * ey)) }
        if cerrada { p.closeSubpath() }
        return p
    }
}

// ── Pantalla «Perfil» NATIVA ────────────────────────────────────────────────
// Lista agrupada, como los Ajustes del teléfono: icono en su cuadro de color,
// título, una línea que dice qué hay dentro y el valor a la derecha. Los grupos
// y sus filas los arma la web (los mismos que ve la PWA); aquí solo se dibujan
// y se disparan por su sitio en la lista.

struct CNAjustes {
    struct Opcion { var id = ""; var label = "" }
    struct Fila {
        var label = ""; var sub = ""; var valor = ""
        var icono = ""; var bg = ""; var fg = ""; var tinta = ""
        var entra = false
        /// Si lleva id de sección, se abre NATIVA en vez de rebotar a la web.
        var sec = ""
        var lista: [Opcion] = []; var listaValor = ""
    }
    struct Grupo { var titulo = ""; var pie = ""; var filas: [Fila] = [] }
    struct Usuario {
        var inicial = ""; var nombre = ""; var correo = ""
        var plan = ""; var planColor = ""
        var modoLabel = ""; var modoBg = ""; var modoFg = ""; var modoPie = ""
        var acento = ""; var sobreAcento = ""
    }
    var usuario = Usuario()
    var grupos: [Grupo] = []

    static func desde(json: String) -> CNAjustes? {
        guard let d = json.data(using: .utf8),
              let raiz = (try? JSONSerialization.jsonObject(with: d)) as? [String: Any] else { return nil }
        func s(_ o: [String: Any]?, _ k: String) -> String { (o?[k] as? String) ?? "" }
        func b(_ o: [String: Any]?, _ k: String) -> Bool { (o?[k] as? Bool) ?? false }
        func lista(_ o: [String: Any]?, _ k: String) -> [[String: Any]] { (o?[k] as? [[String: Any]]) ?? [] }
        var a = CNAjustes()
        let u = raiz["usuario"] as? [String: Any]
        a.usuario = Usuario(inicial: s(u, "inicial"), nombre: s(u, "nombre"), correo: s(u, "correo"),
                            plan: s(u, "plan"), planColor: s(u, "planColor"),
                            modoLabel: s(u, "modoLabel"), modoBg: s(u, "modoBg"), modoFg: s(u, "modoFg"),
                            modoPie: s(u, "modoPie"), acento: s(u, "acento"), sobreAcento: s(u, "sobreAcento"))
        a.grupos = lista(raiz, "grupos").map { g in
            Grupo(titulo: s(g, "titulo"), pie: s(g, "pie"),
                  filas: lista(g, "filas").map { f in
                      Fila(label: s(f, "label"), sub: s(f, "sub"), valor: s(f, "valor"),
                           icono: s(f, "icono"), bg: s(f, "bg"), fg: s(f, "fg"), tinta: s(f, "tinta"),
                           entra: b(f, "entra"), sec: s(f, "sec"),
                           lista: lista(f, "lista").map { Opcion(id: s($0, "id"), label: s($0, "label")) },
                           listaValor: s(f, "listaValor"))
                  })
        }
        return a
    }
}

struct CNPerfil: View {
    @ObservedObject var datos: CNDatos
    var body: some View {
        let ancho = UIScreen.main.bounds.width
        let fuera = datos.seccion == nil ? CGFloat(0) : max(0, 1 - datos.arrastreSec / max(1, ancho))
        // El ZStack va a pantalla completa (sin margen seguro): así la
        // subpantalla se recorta con las esquinas del cristal de verdad, y la
        // raíz se pone su margen de arriba a mano.
        return ZStack {
            // Lo de detrás se retira un poco y se apaga mientras hay otra
            // pantalla encima: es lo que hace que volver se sienta como en el
            // teléfono y no como cambiar una diapositiva.
            raiz
                .padding(.top, cnMargenArriba())
                .offset(x: -ancho * 0.28 * fuera)
                .overlay(Color.black.opacity(0.16 * Double(fuera)).ignoresSafeArea().allowsHitTesting(false))
            // La subpantalla entra desde la derecha, como en el teléfono.
            if let sec = datos.seccion {
                // A pantalla completa (por eso el margen de arriba va a mano) y
                // recortada con el redondeo del cristal: al entrar, al salir y
                // al arrastrarla se ven sus esquinas como las del sistema.
                ZStack(alignment: .top) {
                    CNC.scr
                    // Sin margen de arriba a mano: ahora lleva la barra del
                    // sistema y es ella la que esquiva la isla.
                    CNSeccionVista(sec: sec, datos: datos, onVolver: { cerrar() })
                }
                .clipShape(RoundedRectangle(cornerRadius: cnRadioPantalla(), style: .continuous))
                .offset(x: datos.arrastreSec)
                    .shadow(color: .black.opacity(datos.arrastreSec > 0 ? 0.18 : 0), radius: 14, x: -4)
                    .transition(.move(edge: .trailing))
                    .zIndex(1)
            }
        }
        .ignoresSafeArea()
        // Un muelle corto: entra y sale más rápido que una curva de 0,26 s y
        // se deja interrumpir a mitad, que es lo que hace que se sienta ágil.
        .animation(.spring(response: 0.28, dampingFraction: 0.92), value: datos.seccion?.id)
    }

    private func cerrar() {
        UISelectionFeedbackGenerator().selectionChanged()
        datos.seccion = nil
    }

    private var raiz: some View {
        let a = datos.ajustes ?? CNAjustes()
        // Con la barra de arriba del sistema, como las demás pantallas: el
        // título grande «Chinola» que encoge al rodar. Antes era un Text de
        // 34 pt al lado del logo, y con Movimientos, Cuentas y Plan ya en
        // piezas de iOS, Perfil era la única que seguía imitándolas.
        return NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    CNEspiaScroll { CNScrollEstado.shared.mirar($0) }.frame(height: 0)
                    tarjetaUsuario(a.usuario)
                    ForEach(a.grupos.indices, id: \.self) { gi in
                        grupo(a.grupos[gi], gi)
                    }
                    // Lo que hace falta saber cuando algo no cuadra: qué
                    // compilación es, qué modo tiene el teléfono ahora mismo y
                    // si la app tiene la pareja de paletas para seguirlo.
                    Text(CNDatos.diagnostico()).font(cnLetra(11)).foregroundColor(CNC.pmut.opacity(0.7))
                        .frame(maxWidth: .infinity, alignment: .center).padding(.top, 4)
                    Color.clear.frame(height: 104)
                }
                .padding(.horizontal, 16).padding(.top, 6)
            }
            .background(CNC.scr.ignoresSafeArea())
            .navigationTitle("Chinola")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    /*
                     ACERCA DE, EN VEZ DE UN LOGO QUE NO PARECÍA UN BOTÓN.

                     Aquí estaba la marca —dos círculos— y su única función era
                     abrirse MANTENIÉNDOLA PULSADA. Nadie mantiene pulsado un
                     logo: era una puerta que no existía para quien no la
                     conociera ya, en el sitio donde cualquier app pone la
                     versión y «avisar de un problema».

                     Ahora es eso, y la puerta de Chino sigue estando —ahora
                     dicha con palabras, que es como se encuentra—.
                     */
                    Menu {
                        Section(CNDatos.diagnostico()) {
                            Button {
                                UISelectionFeedbackGenerator().selectionChanged()
                                datos.onPerfilHoja("chino-ayuda")
                            } label: { Label(cnT("Qué sabe hacer Chino"), systemImage: "sparkles") }
                            Button {
                                UISelectionFeedbackGenerator().selectionChanged()
                                datos.onPerfilHoja("chino-aviso")
                            } label: { Label(cnT("Avisar de un problema"), systemImage: "exclamationmark.bubble") }
                            Button {
                                UISelectionFeedbackGenerator().selectionChanged()
                                datos.onMascota()
                            } label: { Label(cnT("Hablar con Chino"), systemImage: "bubble.left.and.text.bubble.right") }
                        }
                    } label: {
                        Image(systemName: "info.circle").font(cnLetra(17, .semibold))
                    }
                    .accessibilityLabel(cnT("Acerca de"))
                }
            }
        }
        .navigationViewStyle(.stack)
        .tint(CNC.pos)
    }

    private func tarjetaUsuario(_ u: CNAjustes.Usuario) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 12) {
                Text(u.inicial).font(cnLetra(17, .heavy))
                    .foregroundColor(u.sobreAcento.isEmpty ? CNC.sobreAcc : cnColor(hexString: u.sobreAcento))
                    .frame(width: 50, height: 50)
                    .background(u.acento.isEmpty ? CNC.acc : cnColor(hexString: u.acento), in: Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text(u.nombre).font(cnLetra(15, .bold)).foregroundColor(CNC.ink).lineLimit(1)
                    if !u.correo.isEmpty {
                        Text(u.correo).font(cnLetra(12)).foregroundColor(CNC.pmut).lineLimit(1)
                    }
                    if !u.plan.isEmpty {
                        Button { datos.onPlan() } label: {
                            HStack(spacing: 5) {
                                Image(systemName: "star.fill").font(cnLetra(10))
                                Text(u.plan).font(cnLetra(11, .heavy))
                                Image(systemName: "chevron.right").font(cnLetra(9, .bold)).opacity(0.6)
                            }
                            .foregroundColor(u.planColor.isEmpty ? CNC.pos : cnColor(hexString: u.planColor))
                        }.buttonStyle(CNPulsable()).padding(.top, 3)
                    }
                }
                Spacer(minLength: 6)
                if !u.modoLabel.isEmpty {
                    Text(u.modoLabel).font(cnLetra(10, .bold))
                        .foregroundColor(u.modoFg.isEmpty ? CNC.pmut : cnColor(hexString: u.modoFg))
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .background(u.modoBg.isEmpty ? CNC.soft : cnColor(hexString: u.modoBg), in: Capsule())
                }
            }
            .padding(15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            if !u.modoPie.isEmpty {
                Text(u.modoPie).font(cnLetra(12)).foregroundColor(CNC.pmut)
                    .fixedSize(horizontal: false, vertical: true).padding(.horizontal, 4)
            }
        }
    }

    private func grupo(_ g: CNAjustes.Grupo, _ gi: Int) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            if !g.titulo.isEmpty {
                Text(g.titulo).font(cnLetra(13)).foregroundColor(CNC.pmut)
                    .padding(.horizontal, 6)
            }
            VStack(spacing: 0) {
                ForEach(g.filas.indices, id: \.self) { fi in
                    fila(g.filas[fi], gi, fi, ultima: fi == g.filas.count - 1)
                }
            }
            .background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            if !g.pie.isEmpty {
                Text(g.pie).font(cnLetra(12)).foregroundColor(CNC.pmut)
                    .fixedSize(horizontal: false, vertical: true).padding(.horizontal, 6)
            }
        }
    }

    @ViewBuilder private func fila(_ f: CNAjustes.Fila, _ gi: Int, _ fi: Int, ultima: Bool) -> some View {
        if f.lista.isEmpty {
            Button {
                // Si la fila tiene su pantalla nativa, se abre aquí; si no, se
                // deja que la web haga lo suyo.
                if f.sec.isEmpty { datos.onAjuste(gi, fi, nil) } else { datos.onAbrirSeccion(f.sec) }
            } label: { cuerpoFila(f, ultima: ultima) }
                .buttonStyle(CNPulsable())
        } else {
            // Una lista (el idioma) se elige en el menú del sistema, no en un
            // desplegable escondido detrás de la fila.
            Menu {
                Picker("", selection: Binding(get: { f.listaValor },
                                              set: { datos.onAjuste(gi, fi, $0) })) {
                    ForEach(f.lista, id: \.id) { o in Text(o.label).tag(o.id) }
                }
            } label: { cuerpoFila(f, ultima: ultima) }
        }
    }

    private func cuerpoFila(_ f: CNAjustes.Fila, ultima: Bool) -> some View {
        let tinta = f.tinta.isEmpty ? CNC.ink : cnColor(hexString: f.tinta)
        return HStack(spacing: 13) {
            // El icono en su cuadro de color, como en los Ajustes del teléfono:
            // la fila se encuentra por el color antes que por el texto. Viene
            // como trazo SVG (el mismo que dibuja la web), no como nombre.
            CNSVGShape(d: f.icono)
                .stroke(style: StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round))
                .foregroundColor(f.fg.isEmpty ? tinta : cnColor(hexString: f.fg))
                .frame(width: 18, height: 18)
                .frame(width: 30, height: 30)
                .background(f.bg.isEmpty ? CNC.soft : cnColor(hexString: f.bg),
                            in: RoundedRectangle(cornerRadius: 9, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(f.label).font(cnLetra(16)).foregroundColor(tinta).lineLimit(1)
                if !f.sub.isEmpty {
                    Text(f.sub).font(cnLetra(12)).foregroundColor(CNC.pmut)
                        .lineLimit(1).truncationMode(.tail)
                }
            }
            .layoutPriority(1)
            Spacer(minLength: 8)
            if !f.valor.isEmpty {
                Text(f.valor).font(cnLetra(14)).foregroundColor(CNC.pmut)
                    .lineLimit(1).truncationMode(.tail).layoutPriority(0)
            }
            if f.entra || !f.lista.isEmpty {
                Image(systemName: f.lista.isEmpty ? "chevron.right" : "chevron.up.chevron.down")
                    .font(cnLetra(12, .semibold)).foregroundColor(CNC.pmut.opacity(0.5))
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 11)
        .contentShape(Rectangle())
        .overlay(alignment: .bottom) {
            if !ultima { Rectangle().fill(CNC.soft).frame(height: 0.5).padding(.leading, 57) }
        }
    }
}

// ── Subpantallas del Perfil, NATIVAS ────────────────────────────────────────
// Cada sección (Mi cuenta, Seguridad, Libretas, Integraciones y los seis
// apartados de Apariencia) llega como una lista de BLOQUES que esta pantalla
// sabe dibujar. Las acciones se disparan por su número: son las mismas
// funciones que ejecuta la web.

struct CNSeccion {
    struct Fila {
        var label = ""; var sub = ""; var valor = ""
        var icono = ""; var bg = ""; var fg = ""; var tinta = ""
        var entra = false; var accion = -1
        /// Una fila puede abrir OTRA sección en vez de disparar una acción.
        var abre = ""
    }
    struct Opcion {
        var label = ""; var sub = ""; var puesta = false
        var color = ""; var fondo = ""; var muestra = ""; var imagen = ""
        /// Un trazo (SVG) para enseñar en vez de una imagen o una muestra.
        var icono = ""
        var accion = -1
        /// La miniatura de la cabecera: franja, cuánto ocupa y si lleva bulto.
        var vista = ""; var franja = ""; var alto: CGFloat = 0; var bulto = false; var papel = ""
        /// El teléfono en miniatura: con qué se pinta (tema, modo, paleta).
        var tarjeta = ""; var acento = ""; var tinta = ""; var oscuro = false; var valor = ""
        var puntos: [String] = []
        /// Para el modo automático: la mitad de noche.
        var nocheFondo = ""; var nocheFranja = ""; var nocheTarjeta = ""
        /// Qué hace al tocarla, DICHO POR SU NOMBRE. Es lo que deja que una
        /// subpantalla la arme el teléfono: `accion` es el número de una lista
        /// que solo tiene sentido si esa lista la hizo la web.
        var abre = ""
    }
    /// Un interruptor dentro de un bloque de varios.
    struct Llave { var label = ""; var sub = ""; var puesto = false; var accion = -1 }
    struct Muestra {
        var nombre = ""; var css = ""; var puesta = false; var accion = -1
        /// Qué hace, dicho por su nombre. Ver `Opcion.abre`.
        var abre = ""
    }
    struct AccionItem { var label = ""; var peligro = false; var accion = -1; var abre = "" }
    /// Un botón chico en la fila del rótulo de una lista («Abrir», «+ Invitar»).
    struct Boton { var label = ""; var estilo = "suave"; var accion = -1; var abre = "" }
    /// Una cosa entre las que una fila deja elegir.
    struct Elegible { var id = ""; var label = "" }
    struct Item {
        var titulo = ""; var detalle = ""; var icono = ""; var color = ""; var fondo = ""
        var chip = ""; var chipFondo = ""; var accion = -1
        /// Si viene, la fila ABRE otra pantalla nativa en vez de disparar una
        /// acción de la web («libreta:3», «hoja:invitar:3»).
        var abre = ""
        var acciones: [AccionItem] = []
        /// SI VIENEN, LA FILA ELIGE ENTRE ELLAS.
        ///
        /// «Libreta por defecto» es la primera: enseñaba cuál estaba puesta y al
        /// tocarla no pasaba nada, porque la fila no tenía ni las opciones ni
        /// acción que disparar. Con esto el toque abre el menú y lo elegido se
        /// manda por `accion` como valor.
        var opciones: [Elegible] = []
        var puesta = ""
    }
    struct Bloque {
        var tipo = "grupo"
        var titulo = ""; var pie = ""; var texto = ""; var label = ""; var estilo = "suave"
        var columnas = 2
        var puesto = false; var accion = -1; var abre = ""
        var filas: [Fila] = []; var opciones: [Opcion] = []
        var colores: [Muestra] = []; var items: [Item] = []
        var llaves: [Llave] = []
        var botones: [Boton] = []
        /// La muestra de la letra: con qué escala y qué tres cosas enseña.
        var escala: Double = 1; var muestraTitulo = ""; var muestraTexto = ""; var muestraCifra = ""
        /// El selector: lo que hay puesto ahora, con nombre.
        var valor = ""
    }
    var id = ""; var titulo = ""; var bloques: [Bloque] = []
    /**
     * QUIÉN ARMÓ ESTO: «nativa» o «web».
     *
     * La sonda del banco decía quién fue el ÚLTIMO en INTENTAR armarla, no
     * quién armó lo que se está viendo. Y son cosas distintas: al entrar, la
     * web manda su modelo, el teléfono arma el suyo, y cualquiera de los dos
     * puede llegar después y pisar al otro. Una sonda que mira el intento y no
     * el resultado puede dar por buena una pantalla que salió de la web.
     */
    var deQuien = "web"
    /// A dónde vuelve la flecha de atrás (otra sección), si no es a Perfil.
    var volverA = ""
    /// El menú ⋯ de la cabecera (editar, invitar, eliminar…), si la pantalla lo tiene.
    var menu: [AccionItem] = []

    static func desde(json: String) -> CNSeccion? {
        guard let d = json.data(using: .utf8),
              let raiz = (try? JSONSerialization.jsonObject(with: d)) as? [String: Any] else { return nil }
        func s(_ o: [String: Any]?, _ k: String) -> String { (o?[k] as? String) ?? "" }
        func n(_ o: [String: Any]?, _ k: String) -> Int { ((o?[k] as? NSNumber)?.intValue) ?? -1 }
        func b(_ o: [String: Any]?, _ k: String) -> Bool { (o?[k] as? Bool) ?? false }
        func l(_ o: [String: Any]?, _ k: String) -> [[String: Any]] { (o?[k] as? [[String: Any]]) ?? [] }
        var x = CNSeccion()
        x.id = s(raiz, "id"); x.titulo = s(raiz, "titulo"); x.volverA = s(raiz, "volverA")
        x.menu = l(raiz, "menu").map {
            AccionItem(label: s($0, "label"), peligro: b($0, "peligro"), accion: n($0, "accion"), abre: s($0, "abre"))
        }
        x.bloques = l(raiz, "bloques").map { bq in
            var q = Bloque()
            q.tipo = s(bq, "tipo"); q.titulo = s(bq, "titulo"); q.pie = s(bq, "pie")
            q.texto = s(bq, "texto"); q.label = s(bq, "label"); q.estilo = s(bq, "estilo")
            q.abre = s(bq, "abre")
            q.columnas = max(1, n(bq, "columnas")); q.puesto = b(bq, "puesto"); q.accion = n(bq, "accion")
            q.valor = s(bq, "valor")
            q.escala = ((bq["escala"] as? NSNumber)?.doubleValue) ?? 1
            q.muestraTitulo = s(bq, "muestraTitulo"); q.muestraTexto = s(bq, "muestraTexto"); q.muestraCifra = s(bq, "muestraCifra")
            q.filas = l(bq, "filas").map {
                Fila(label: s($0, "label"), sub: s($0, "sub"), valor: s($0, "valor"), icono: s($0, "icono"),
                     bg: s($0, "bg"), fg: s($0, "fg"), tinta: s($0, "tinta"), entra: b($0, "entra"),
                     accion: n($0, "accion"), abre: s($0, "abre"))
            }
            q.opciones = l(bq, "opciones").map { o in
                let mini = o["vista"] as? [String: Any]
                let noche = mini?["noche"] as? [String: Any]
                var op = Opcion(label: s(o, "label"), sub: s(o, "sub"), puesta: b(o, "puesta"),
                       color: s(o, "color"), fondo: s(o, "fondo"), muestra: s(o, "muestra"),
                       imagen: s(o, "imagen"), icono: s(o, "icono"), accion: n(o, "accion"),
                       vista: s(mini, "tipo"), franja: s(mini, "franja"),
                       alto: CGFloat(((mini?["alto"] as? NSNumber)?.doubleValue) ?? 0),
                       bulto: b(mini, "bulto"), papel: s(mini, "papel"))
                if let m = mini {
                    if op.fondo.isEmpty { op.fondo = s(m, "fondo") }
                    op.tarjeta = s(m, "tarjeta"); op.acento = s(m, "acento"); op.tinta = s(m, "tinta")
                    op.oscuro = b(m, "oscuro"); op.valor = s(m, "modo")
                    op.puntos = (m["puntos"] as? [String]) ?? []
                    op.nocheFondo = s(noche, "fondo"); op.nocheFranja = s(noche, "franja"); op.nocheTarjeta = s(noche, "tarjeta")
                }
                return op
            }
            q.llaves = l(bq, "items").map {
                Llave(label: s($0, "label"), sub: s($0, "sub"), puesto: b($0, "puesto"), accion: n($0, "accion"))
            }
            q.colores = l(bq, "colores").map {
                Muestra(nombre: s($0, "nombre"), css: s($0, "css"), puesta: b($0, "puesta"), accion: n($0, "accion"))
            }
            q.items = l(bq, "items").map { it in
                Item(titulo: s(it, "titulo"), detalle: s(it, "detalle"), icono: s(it, "icono"),
                     color: s(it, "color"), fondo: s(it, "fondo"), chip: s(it, "chip"),
                     chipFondo: s(it, "chipFondo"), accion: n(it, "accion"),
                     abre: s(it, "abre"),
                     acciones: l(it, "acciones").map {
                         AccionItem(label: s($0, "label"), peligro: b($0, "peligro"), accion: n($0, "accion"))
                     },
                     opciones: l(it, "opciones").map { Elegible(id: s($0, "id"), label: s($0, "label")) },
                     puesta: s(it, "puesta"))
            }
            q.botones = l(bq, "botones").map {
                Boton(label: s($0, "label"), estilo: s($0, "estilo"), accion: n($0, "accion"), abre: s($0, "abre"))
            }
            return q
        }
        return x
    }
}

/**
 * EL TOQUE DE UNA FILA DE LISTA.
 *
 * Como modificador y no como un `if` dentro de la vista porque un `Menu` y un
 * `onTapGesture` son dos vistas distintas, y en SwiftUI eso no se puede decidir
 * con un `if` sin envolver la fila entera en un `AnyView` por cada renglón.
 *
 * Con opciones, el toque despliega el menú y lo elegido se manda por el mismo
 * sitio por el que viaja cualquier otra acción, con el id como valor. Sin
 * opciones, se comporta exactamente como antes.
 */
private struct CNElige: ViewModifier {
    let it: CNSeccion.Item
    let datos: CNDatos
    @ViewBuilder func body(content: Content) -> some View {
        if it.opciones.isEmpty {
            content.onTapGesture {
                if !it.abre.isEmpty { datos.onAbrirSeccion(it.abre) }
                else if it.accion >= 0 { datos.onSeccionAccion(it.accion, nil) }
            }
        } else {
            Menu {
                // Marcada la que está puesta: sin eso el menú no dice cuál es
                // la de ahora, que es justo lo que se va a cambiar.
                ForEach(it.opciones.indices, id: \.self) { k in
                    let o = it.opciones[k]
                    Button {
                        if it.accion >= 0 { datos.onSeccionAccion(it.accion, o.id) }
                    } label: {
                        if o.id == it.puesta { Label(o.label, systemImage: "checkmark") }
                        else { Text(o.label) }
                    }
                }
            } label: { content }
            .buttonStyle(.plain)
        }
    }
}

struct CNSeccionVista: View {
    let sec: CNSeccion
    @ObservedObject var datos: CNDatos
    var onVolver: () -> Void
    var body: some View {
        // Las doce subpantallas del Perfil pasan por aquí, así que la barra de
        // arriba se arregla una vez y valen todas. Era la misma imitación de
        // antes —dos círculos grises y un texto en medio— mientras el resto de
        // la app ya usaba la barra del sistema.
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(sec.bloques.indices, id: \.self) { i in bloque(sec.bloques[i], i) }
                    Color.clear.frame(height: 104)
                }
                .padding(.horizontal, 16).padding(.top, 8)
            }
            .background(CNC.scr.ignoresSafeArea())
            .navigationTitle(sec.titulo)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        if sec.volverA.isEmpty { onVolver() } else { datos.onAbrirSeccion(sec.volverA) }
                    } label: { Image(systemName: "chevron.left") }
                    .accessibilityLabel(cnT("Volver"))
                }
                // Los tres puntos: lo que se hace con esta pantalla entera.
                //
                // Va en un GRUPO y no en un `ToolbarItem` suelto: dentro del
                // grupo el contenido es normal y el `if` vale también en iOS 15
                // (en un `ToolbarItem` los condicionales son de la 16). Dejarlo
                // puesto con opacidad cero no servía: el sistema le dibujaba
                // igual su cápsula de vidrio y salía un círculo blanco vacío
                // arriba a la derecha en las pantallas que no tienen menú.
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if !sec.menu.isEmpty {
                        Menu {
                            ForEach(sec.menu.indices, id: \.self) { k in
                                let a = sec.menu[k]
                                Button(role: a.peligro ? .destructive : nil) {
                                    if a.abre.isEmpty { datos.onSeccionAccion(a.accion, nil) } else { datos.onAbrirSeccion(a.abre) }
                                } label: { Text(a.label) }
                            }
                        } label: { Image(systemName: "ellipsis") }
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .tint(CNC.pos)
    }

    /// Los botones chicos del rótulo de una lista («Abrir», «+ Invitar»), con
    /// los estilos del sistema. Eran dos cápsulas pintadas a mano —una
    /// amarilla— y, con la barra de arriba ya del teléfono, eran lo único que
    /// seguía hablando otro idioma.
    @ViewBuilder private func botonChico(_ bt: CNSeccion.Boton) -> some View {
        let tocar = {
            UISelectionFeedbackGenerator().selectionChanged()
            if bt.abre.isEmpty { datos.onSeccionAccion(bt.accion, nil) } else { datos.onAbrirSeccion(bt.abre) }
        }
        let etiqueta = Text(bt.label).font(cnLetra(14, .semibold))
        if bt.estilo == "acento" {
            Button(action: tocar) { etiqueta }
                .buttonStyle(.borderedProminent).tint(CNC.pos)
                .controlSize(.small).clipShape(Capsule())
        } else {
            Button(action: tocar) { etiqueta }
                .buttonStyle(.bordered).tint(CNC.pos)
                .controlSize(.small).clipShape(Capsule())
        }
    }

    @ViewBuilder private func botonBloque(_ q: CNSeccion.Bloque) -> some View {
        let etiqueta = Text(q.label).font(cnLetra(16, .semibold))
            .frame(maxWidth: .infinity).padding(.vertical, 6)
        let tocar = { if q.abre.isEmpty { datos.onSeccionAccion(q.accion, nil) } else { datos.onAbrirSeccion(q.abre) } }
        if q.estilo == "acento" {
            Button(action: tocar) { etiqueta }
                .buttonStyle(.borderedProminent).tint(CNC.pos)
                .controlSize(.large).clipShape(Capsule())
        } else if q.estilo == "peligro" {
            Button(role: .destructive, action: tocar) { etiqueta }
                .buttonStyle(.bordered).tint(.red)
                .controlSize(.large).clipShape(Capsule())
        } else {
            Button(action: tocar) { etiqueta }
                .buttonStyle(.bordered).tint(CNC.pos)
                .controlSize(.large).clipShape(Capsule())
        }
    }

    @ViewBuilder private func bloque(_ q: CNSeccion.Bloque, _ bi: Int) -> some View {
        switch q.tipo {
        case "texto":
            Text(q.texto).font(cnLetra(14)).foregroundColor(CNC.pmut)
                .fixedSize(horizontal: false, vertical: true).padding(.horizontal, 4)
        case "boton":
            // Los estilos de botón DEL SISTEMA: el principal relleno, el
            // normal con su fondo suave y el de peligro en rojo.
            botonBloque(q)
        case "codigo":
            VStack(alignment: .leading, spacing: 9) {
                if !q.titulo.isEmpty { rotulo(q.titulo) }
                Text(q.texto).font(.system(size: cnPt(13), design: .monospaced)).foregroundColor(CNC.ink)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading).padding(13)
                    .background(CNC.soft, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                Button { tocaBloque(q) } label: {
                    Label(q.label, systemImage: "doc.on.doc").font(cnLetra(14, .semibold))
                        .foregroundColor(CNC.ink)
                }.buttonStyle(CNPulsable())
            }
        case "interruptor":
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(q.label).font(cnLetra(16)).foregroundColor(CNC.ink)
                    if !q.titulo.isEmpty || !q.texto.isEmpty || !q.pie.isEmpty {
                        Text(q.pie.isEmpty ? q.texto : q.pie).font(cnLetra(12)).foregroundColor(CNC.pmut)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer(minLength: 8)
                // EL VALOR NUEVO MANDA, y no «se tocó».
                //
                // Esto ignoraba el valor y disparaba la acción siempre. Al
                // tocar se encendía en el servidor, llegaba la respuesta,
                // `q.puesto` pasaba a puesto, SwiftUI volvía a llamar al `set`
                // con ESE valor… y la acción se disparaba otra vez, apagándolo.
                // Un segundo después de encenderlo. Quedó en la auditoría:
                // «Encendió Chino con IA» y «Apagó Chino con IA» seguidos, una
                // y otra vez, y la IA sin funcionar en la app, en WhatsApp y en
                // Telegram.
                //
                // Con esto, cuando el valor que llega ya coincide con el que
                // hay, no se dispara nada.
                // El apunte se guarda por ACCIÓN y no por clave: un
                // interruptor de sección no dice qué ajuste toca, solo a qué
                // fila pertenece. Basta para lo que hace falta — que se mueva
                // ya— y se tira en cuanto llega la pantalla nueva.
                Toggle("", isOn: Binding(
                    get: { CNRecienTocado.de("sec:" + String(q.accion), Bool.self) ?? q.puesto },
                    set: { nuevo in
                        guard nuevo != (CNRecienTocado.de("sec:" + String(q.accion), Bool.self) ?? q.puesto) else { return }
                        CNRecienTocado.pon("sec:" + String(q.accion), nuevo)
                        tocaBloque(q)
                    }))
                    // Del mismo verde que el resto de lo nativo. En amarillo
                    // era el único control que no seguía el tinte de la app.
                    .labelsHidden().tint(CNC.pos)
            }
            .padding(14).tarjetaCN()
        case "interruptores": llavesVista(q, bi)
        case "previa": previaVista(q)
        case "selector": selectorVista(q, bi)
        case "telefonos": telefonosVista(q, bi)
        case "opciones": opcionesVista(q, bi)
        case "muestras": muestrasVista(q, bi)
        case "lista": listaVista(q)
        default: grupoVista(q)
        }
    }

    /**
     * Qué pasa al tocar una opción.
     *
     * Por NOMBRE si lo trae, y si no por el número de la lista de la web. Las
     * dos maneras conviven a propósito: las subpantallas que arma el teléfono no
     * tienen esa lista —el número no significaría nada— y las que sigue armando
     * la web no tienen nombres.
     */
    /// Lo mismo para un bloque entero —un botón, un interruptor—: por nombre si
    /// lo trae, y si no por el número de la lista de la web.
    private func tocaBloque(_ q: CNSeccion.Bloque) {
        if q.abre.isEmpty { datos.onSeccionAccion(q.accion, nil) } else { datos.onAbrirSeccion(q.abre) }
    }

    private func tocaOpcion(_ o: CNSeccion.Opcion) {
        if o.abre.isEmpty { datos.onSeccionAccion(o.accion, nil) } else { datos.onAbrirSeccion(o.abre) }
    }

    private func rotulo(_ t: String) -> some View {
        Text(t).font(cnLetra(13)).foregroundColor(CNC.pmut).padding(.horizontal, 6)
    }

    private func grupoVista(_ q: CNSeccion.Bloque) -> some View {
        // Si alguna fila del grupo lleva icono, las que no lo llevan RESERVAN
        // su hueco. Si no, el texto de esas se pega al borde de la tarjeta y
        // la columna de nombres da un salto a media lista.
        let conIcono = q.filas.contains { !$0.icono.isEmpty }
        return VStack(alignment: .leading, spacing: 7) {
            if !q.titulo.isEmpty { rotulo(q.titulo) }
            VStack(spacing: 0) {
                ForEach(q.filas.indices, id: \.self) { i in
                    let f = q.filas[i]
                    Button { if f.abre.isEmpty { datos.onSeccionAccion(f.accion, nil) } else { datos.onAbrirSeccion(f.abre) } } label: {
                        HStack(spacing: 13) {
                            if !f.icono.isEmpty {
                                CNSVGShape(d: f.icono)
                                    .stroke(style: StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round))
                                    .foregroundColor(f.fg.isEmpty ? CNC.ink : cnColor(hexString: f.fg))
                                    .frame(width: 18, height: 18).frame(width: 30, height: 30)
                                    .background(f.bg.isEmpty ? CNC.soft : cnColor(hexString: f.bg),
                                                in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                            } else if conIcono {
                                Color.clear.frame(width: 30, height: 30)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(f.label).font(cnLetra(16)).foregroundColor(CNC.ink).lineLimit(1)
                                if !f.sub.isEmpty {
                                    Text(f.sub).font(cnLetra(12)).foregroundColor(CNC.pmut).lineLimit(1)
                                }
                            }.layoutPriority(1)
                            Spacer(minLength: 8)
                            if !f.valor.isEmpty {
                                Text(f.valor).font(cnLetra(14))
                                    .foregroundColor(f.tinta.isEmpty ? CNC.pmut : cnColor(hexString: f.tinta))
                                    .lineLimit(1)
                            }
                            if f.entra {
                                Image(systemName: "chevron.right").font(cnLetra(12, .semibold))
                                    .foregroundColor(CNC.pmut.opacity(0.5))
                            }
                        }
                        .padding(.horizontal, 14).padding(.vertical, 11).contentShape(Rectangle())
                        .overlay(alignment: .bottom) {
                            if i < q.filas.count - 1 {
                                Rectangle().fill(CNC.soft).frame(height: 0.5).padding(.leading, 57)
                            }
                        }
                    }.buttonStyle(CNPulsable())
                }
            }
            .background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            if !q.pie.isEmpty { rotulo(q.pie) }
        }
    }

    /// Elegir entre varias: tarjetas en rejilla, con la puesta marcada en el
    /// color de la marca. Es lo que hace la web, no un menú desplegable.

    /// La miniatura de una cabecera: la franja de arriba con su alto, el bulto
    /// del saldo si lo lleva, y dos rayas de contenido debajo. Sin letras: lo
    /// que se elige es la FORMA.
    private func miniCabecera(_ o: CNSeccion.Opcion) -> some View {
        let papel = o.papel.isEmpty ? CNC.scr : cnColor(hexString: o.papel)
        let alto = max(6, min(30, o.alto))
        return VStack(spacing: 0) {
            ZStack {
                Rectangle().fill(cnColor(hexString: o.franja))
                if o.bulto {
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(Color.white.opacity(0.55))
                        .frame(width: 34, height: 7)
                }
            }
            .frame(height: alto)
            VStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 2, style: .continuous).fill(CNC.pmut.opacity(0.22)).frame(height: 5)
                RoundedRectangle(cornerRadius: 2, style: .continuous).fill(CNC.pmut.opacity(0.14)).frame(height: 5)
            }
            .padding(.horizontal, 7).padding(.top, 7)
            Spacer(minLength: 0)
        }
        .frame(height: 54)
        .background(papel)
        .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 9, style: .continuous).stroke(CNC.line, lineWidth: 1))
    }

    /// Varios interruptores en una sola tarjeta, con su raya entre medias. Cada
    /// uno en la suya ocupaba media pantalla para decir dos cosas.
    private func llavesVista(_ q: CNSeccion.Bloque, _ bi: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if !q.titulo.isEmpty { rotulo(q.titulo) }
            VStack(spacing: 0) {
                ForEach(q.llaves.indices, id: \.self) { i in
                    let k = q.llaves[i]
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 1) {
                            Text(k.label).font(cnLetra(15.5)).foregroundColor(CNC.ink)
                            if !k.sub.isEmpty {
                                Text(k.sub).font(cnLetra(11.5)).foregroundColor(CNC.pmut)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        Spacer(minLength: 8)
                        // El valor nuevo manda, igual que arriba: si ya
                        // coincide, no se vuelve a disparar.
                        Toggle("", isOn: Binding(get: { k.puesto },
                                                 set: { nuevo in
                                                     guard nuevo != k.puesto else { return }
                                                     UISelectionFeedbackGenerator().selectionChanged()
                                                     datos.marcarEnSeccion(bloque: bi, llave: i)
                                                     datos.onSeccionAccion(k.accion, nil)
                                                 }))
                            .labelsHidden().tint(CNC.pos)
                    }
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    if i < q.llaves.count - 1 {
                        Rectangle().fill(CNC.line).frame(height: 0.5).padding(.leading, 14)
                    }
                }
            }
            .tarjetaCN()
        }
    }

    /// Teléfonos en miniatura, en fila: cada opción tal como quedará la app.
    /// El elegido lleva el aro del color de la marca y su nombre en negrita.
    private func telefonosVista(_ q: CNSeccion.Bloque, _ bi: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if !q.titulo.isEmpty { rotulo(q.titulo) }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 10) {
                    ForEach(q.opciones.indices, id: \.self) { i in
                        let o = q.opciones[i]
                        Button {
                            UISelectionFeedbackGenerator().selectionChanged()
                            withAnimation(.easeOut(duration: 0.18)) { datos.marcarEnSeccion(bloque: bi, opcion: i) }
                            tocaOpcion(o)
                        } label: {
                            VStack(spacing: 8) {
                                CNTelefonoMini(o: o)
                                    .frame(width: 74, height: 148)
                                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(o.puesta ? CNC.acc : CNC.line, lineWidth: o.puesta ? 2.5 : 1))
                                Text(o.label).font(cnLetra(12.5, o.puesta ? .bold : .regular))
                                    .foregroundColor(o.puesta ? CNC.ink : CNC.pmut)
                                    .lineLimit(1).minimumScaleFactor(0.8)
                            }
                            .frame(width: 84)
                        }.buttonStyle(CNPulsable())
                    }
                }
                .padding(.horizontal, 14).padding(.vertical, 14)
            }
            .background(CNC.card)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            if !q.pie.isEmpty { rotulo(q.pie) }
        }
    }

    /// La muestra del tamaño de letra: un título, un texto y una cifra a la
    /// escala elegida, dentro de una tarjeta como las del resumen.
    private func previaVista(_ q: CNSeccion.Bloque) -> some View {
        let e = CGFloat(q.escala) / CGFloat(max(0.5, CNC.fmt.letra))   // relativa a la que ya aplica cnLetra
        return VStack(alignment: .leading, spacing: 8) {
            if !q.titulo.isEmpty { rotulo(q.titulo) }
            VStack(alignment: .leading, spacing: 6) {
                Text(q.muestraTitulo).font(cnLetra(13 * e)).foregroundColor(CNC.pmut)
                Text(q.muestraCifra).font(cnLetra(26 * e, .heavy)).foregroundColor(CNC.ink)
                    .lineLimit(1).minimumScaleFactor(0.6)
                Text(q.muestraTexto).font(cnLetra(14 * e)).foregroundColor(CNC.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16).frame(maxWidth: .infinity, alignment: .leading)
            .background(CNC.card)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .animation(.easeOut(duration: 0.18), value: q.escala)
        }
    }

    /// Una lista dentro de un solo botón: el nombre de lo puesto y, al tocar,
    /// el menú del sistema con las opciones (cada una con su pista).
    private func selectorVista(_ q: CNSeccion.Bloque, _ bi: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if !q.titulo.isEmpty { rotulo(q.titulo) }
            Menu {
                ForEach(q.opciones.indices, id: \.self) { i in
                    let o = q.opciones[i]
                    Button {
                        UISelectionFeedbackGenerator().selectionChanged()
                        datos.marcarEnSeccion(bloque: bi, opcion: i)
                        tocaOpcion(o)
                    } label: {
                        if o.puesta {
                            Label(o.sub.isEmpty ? o.label : o.label + " · " + o.sub, systemImage: "checkmark")
                        } else {
                            Text(o.sub.isEmpty ? o.label : o.label + " · " + o.sub)
                        }
                    }
                }
            } label: {
                HStack(spacing: 10) {
                    Text(q.opciones.first { $0.puesta }?.label ?? q.valor)
                        .font(cnLetra(16, .semibold)).foregroundColor(CNC.ink).lineLimit(1)
                    Spacer(minLength: 8)
                    Image(systemName: "chevron.up.chevron.down").font(cnLetra(12, .semibold))
                        .foregroundColor(CNC.pmut.opacity(0.7))
                }
                .padding(.horizontal, 15).padding(.vertical, 14)
                .background(CNC.card)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
    }

    /**
     * ¿ESTO SE ELIGE LEYENDO O MIRANDO?
     *
     * Una moneda, «con centavos» o un idioma se eligen LEYENDO, y para eso una
     * rejilla de cajas con borde es un formulario web y no una pantalla de
     * iPhone: dos columnas de cuadros iguales donde lo único que cambia es la
     * palabra de dentro, con los nombres largos recortados y la selección
     * marcada con un borde en vez de con una palomita.
     *
     * Un color, un tema, un icono o una cabecera se eligen MIRANDO, y ahí la
     * rejilla es justo lo correcto: lo que decide es el dibujo.
     *
     * Así que la forma la decide lo que hay dentro, no quien lo pide. Una lista
     * con palomita para lo que es texto; la rejilla para lo que se ve.
     */
    private func soloTexto(_ q: CNSeccion.Bloque) -> Bool {
        !q.opciones.isEmpty && q.opciones.allSatisfy {
            $0.icono.isEmpty && $0.imagen.isEmpty && $0.color.isEmpty
                && $0.muestra.isEmpty && $0.vista.isEmpty
        }
    }

    @ViewBuilder private func opcionesVista(_ q: CNSeccion.Bloque, _ bi: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if !q.titulo.isEmpty { rotulo(q.titulo) }
            if soloTexto(q) { listaDeOpciones(q, bi) } else { rejillaDeOpciones(q, bi) }
        }
    }

    /// Lo que se elige leyendo: una fila por opción y una palomita en la puesta.
    private func listaDeOpciones(_ q: CNSeccion.Bloque, _ bi: Int) -> some View {
        VStack(spacing: 0) {
            ForEach(q.opciones.indices, id: \.self) { i in
                let o = q.opciones[i]
                Button {
                    UISelectionFeedbackGenerator().selectionChanged()
                    withAnimation(.easeOut(duration: 0.16)) { datos.marcarEnSeccion(bloque: bi, opcion: i) }
                    tocaOpcion(o)
                } label: {
                    HStack(spacing: 10) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(o.label).font(cnLetra(16, o.puesta ? .semibold : .regular))
                                .foregroundColor(CNC.ink).lineLimit(2)
                            if !o.sub.isEmpty {
                                Text(o.sub).font(cnLetra(12.5)).foregroundColor(CNC.pmut).lineLimit(2)
                            }
                        }
                        Spacer(minLength: 8)
                        if o.puesta {
                            Image(systemName: "checkmark").font(cnLetra(15, .bold)).foregroundColor(CNC.pos)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 15).padding(.vertical, 13)
                    .contentShape(Rectangle())
                }.buttonStyle(CNPulsable())
                if i < q.opciones.count - 1 {
                    Rectangle().fill(CNC.line).frame(height: 0.5).padding(.leading, 15)
                }
            }
        }
        .background(CNC.card)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    /// Y lo que se elige mirando: el dibujo manda, así que va en rejilla.
    private func rejillaDeOpciones(_ q: CNSeccion.Bloque, _ bi: Int) -> some View {
        Group {
            CNRejillaFija(columnas: q.columnas, total: q.opciones.count) { i in
                let o = q.opciones[i]
                Button {
                    UISelectionFeedbackGenerator().selectionChanged()
                    withAnimation(.easeOut(duration: 0.16)) { datos.marcarEnSeccion(bloque: bi, opcion: i) }
                    tocaOpcion(o)
                } label: {
                    VStack(spacing: 7) {
                        if o.vista == "cabecera" {
                            miniCabecera(o)
                        } else if !o.imagen.isEmpty, let img = cnImagenDeOpcion(o.imagen) {
                            Image(uiImage: img).resizable().scaledToFit().frame(height: 66)
                                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                        } else if !o.icono.isEmpty {
                            CNSVGShape(d: o.icono)
                                .stroke(style: StrokeStyle(lineWidth: 1.9, lineCap: .round, lineJoin: .round))
                                .foregroundColor(o.puesta ? CNC.pos : CNC.pmut)
                                .frame(width: 34, height: 34).frame(height: 66)
                        } else if !o.muestra.isEmpty {
                            Text(o.muestra).font(cnLetra(22, .bold)).foregroundColor(CNC.ink)
                        } else if !o.color.isEmpty {
                            Circle().fill(cnColor(hexString: o.color)).frame(width: 22, height: 22)
                        }
                        Text(o.label).font(cnLetra(13.5, .semibold)).foregroundColor(CNC.ink)
                            .lineLimit(1).minimumScaleFactor(0.8)
                        // Con la miniatura delante, la frase sobra: ocupaba dos
                        // renglones para decir lo que el dibujo ya dice.
                        if !o.sub.isEmpty && o.vista.isEmpty {
                            Text(o.sub).font(cnLetra(11)).foregroundColor(CNC.pmut).lineLimit(1)
                        }
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 11).padding(.horizontal, 8)
                    // Lo elegido, del verde del tinte. En amarillo eran —con
                    // las muestras de color— los dos únicos sitios que seguían
                    // marcando la selección con el acento de la marca, cuando
                    // todo lo demás (la palomita del periodo, los
                    // interruptores, los botones, la pestaña puesta) ya va en
                    // verde. Cantaba precisamente por ser los únicos.
                    .background(o.puesta ? CNC.pos.opacity(0.10) : CNC.card,
                                in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(o.puesta ? CNC.pos : CNC.line, lineWidth: o.puesta ? 2 : 1))
                }.buttonStyle(CNPulsable())
            }
        }
    }

    private func muestrasVista(_ q: CNSeccion.Bloque, _ bi: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if !q.titulo.isEmpty { rotulo(q.titulo) }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(q.colores.indices, id: \.self) { i in
                        let c = q.colores[i]
                        Button {
                            UISelectionFeedbackGenerator().selectionChanged()
                            withAnimation(.easeOut(duration: 0.16)) { datos.marcarEnSeccion(bloque: bi, muestra: i) }
                            if c.abre.isEmpty { datos.onSeccionAccion(c.accion, nil) }
                            else { datos.onAbrirSeccion(c.abre) }
                        } label: {
                            CNFondoCabecera(f: cnFondoDeCss(c.css), respaldo: CNC.side)
                                .frame(width: 44, height: 44)
                                .clipShape(Circle())
                                // Del verde del tinte, igual que la rejilla.
                                .overlay(Circle().stroke(CNC.pos, lineWidth: c.puesta ? 3 : 0))
                                .overlay(Circle().stroke(CNC.line, lineWidth: 0.5))
                        }.buttonStyle(CNPulsable())
                    }
                }
                .padding(.horizontal, 4).padding(.vertical, 3)
            }
        }
    }

    private func listaVista(_ q: CNSeccion.Bloque) -> some View {
        // Si alguna fila lleva el ⋯, todas reservan su hueco: así las
        // insignias de rol quedan en la misma columna, tenga o no menú la fila.
        let conMenu = q.items.contains { !$0.acciones.isEmpty }
        return VStack(alignment: .leading, spacing: 7) {
            if !q.titulo.isEmpty || !q.botones.isEmpty {
                HStack(alignment: .center, spacing: 8) {
                    if !q.titulo.isEmpty { rotulo(q.titulo) }
                    Spacer(minLength: 8)
                    ForEach(q.botones.indices, id: \.self) { k in
                        botonChico(q.botones[k])
                    }
                }
                .padding(.bottom, q.botones.isEmpty ? 0 : 2)
            }
            VStack(spacing: 0) {
                ForEach(q.items.indices, id: \.self) { i in
                    let it = q.items[i]
                    HStack(spacing: 12) {
                        if !it.icono.isEmpty {
                            CNSVGShape(d: it.icono)
                                .stroke(style: StrokeStyle(lineWidth: 1.7, lineCap: .round, lineJoin: .round))
                                .foregroundColor(it.color.isEmpty ? CNC.ink : cnColor(hexString: it.color))
                                .frame(width: 18, height: 18).frame(width: 32, height: 32)
                                .background(it.fondo.isEmpty ? CNC.soft : cnColor(hexString: it.fondo),
                                            in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                        } else if !it.fondo.isEmpty {
                            // La MISMA regla de siglas que la web: dos letras.
                            Text(CNCategorias.inicial(it.titulo))
                                .font(cnLetra(12, .heavy)).foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(cnColor(hexString: it.fondo),
                                            in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(it.titulo).font(cnLetra(15, .semibold)).foregroundColor(CNC.ink).lineLimit(1)
                            if !it.detalle.isEmpty {
                                Text(it.detalle).font(cnLetra(12)).foregroundColor(CNC.pmut).lineLimit(2)
                            }
                        }
                        Spacer(minLength: 8)
                        if !it.chip.isEmpty {
                            Text(it.chip).font(cnLetra(10.5, .bold)).foregroundColor(CNC.pmut)
                                .padding(.horizontal, 9).padding(.vertical, 5)
                                .background(it.chipFondo.isEmpty ? CNC.soft : cnColor(hexString: it.chipFondo), in: Capsule())
                        }
                        if !it.acciones.isEmpty {
                            Menu {
                                ForEach(it.acciones.indices, id: \.self) { k in
                                    let a = it.acciones[k]
                                    Button(role: a.peligro ? .destructive : nil) {
                                        datos.onSeccionAccion(a.accion, nil)
                                    } label: { Text(a.label) }
                                }
                            } label: {
                                Image(systemName: "ellipsis").font(cnLetra(14, .bold))
                                    .foregroundColor(CNC.pmut).frame(width: 30, height: 30)
                                    .background(CNC.soft, in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                            }
                        } else if conMenu {
                            Color.clear.frame(width: 30, height: 30)
                        }
                    }
                    .padding(.horizontal, 14).padding(.vertical, 11).contentShape(Rectangle())
                    .modifier(CNElige(it: it, datos: datos))
                    .overlay(alignment: .bottom) {
                        if i < q.items.count - 1 {
                            Rectangle().fill(CNC.soft).frame(height: 0.5).padding(.leading, 58)
                        }
                    }
                }
            }
            .background(CNC.card).clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            if !q.pie.isEmpty { rotulo(q.pie) }
        }
    }
}

/// Rejilla de N columnas sin LazyVGrid (que en iOS 15 no reparte igual las
/// alturas cuando las celdas crecen).
struct CNRejillaFija<C: View>: View {
    let columnas: Int
    let total: Int
    var alto: CGFloat = 10
    @ViewBuilder var celda: (Int) -> C
    var body: some View {
        let cols = max(1, columnas)
        let filas = (total + cols - 1) / cols
        VStack(spacing: alto) {
            ForEach(0..<max(0, filas), id: \.self) { f in
                HStack(alignment: .top, spacing: 10) {
                    ForEach(0..<cols, id: \.self) { c in
                        let i = f * cols + c
                        if i < total { celda(i).frame(maxWidth: .infinity) }
                        else { Color.clear.frame(maxWidth: .infinity) }
                    }
                }
            }
        }
    }
}

/// Un PNG en base64 (los dibujos del personaje, que la web rinde por nosotros).
func cnImagenBase64(_ b64: String) -> UIImage? {
    guard let d = Data(base64Encoded: b64, options: .ignoreUnknownCharacters) else { return nil }
    return UIImage(data: d)
}

/// Un color CSS suelto (o un degradado) convertido al fondo que pinta la app.
func cnFondoDeCss(_ css: String) -> CNResumenModelo.Fondo {
    let t = css.trimmingCharacters(in: .whitespaces)
    guard t.contains("gradient") else { return CNResumenModelo.Fondo(tipo: "color", color: t) }
    let dentro = t.drop(while: { $0 != "(" }).dropFirst().prefix(while: { $0 != ")" })
    var trozos = dentro.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    var angulo: Double = 180
    if let primero = trozos.first, primero.hasSuffix("deg") {
        angulo = Double(primero.replacingOccurrences(of: "deg", with: "")) ?? 180
        trozos.removeFirst()
    }
    let paradas = trozos.enumerated().map { (i, x) -> CNResumenModelo.Parada in
        let partes = x.split(separator: " ")
        let color = String(partes.first ?? "")
        var pos = trozos.count > 1 ? Double(i) / Double(trozos.count - 1) : 0
        if partes.count > 1, let p = Double(partes[1].replacingOccurrences(of: "%", with: "")) { pos = p / 100 }
        return CNResumenModelo.Parada(color: color, pos: pos)
    }
    return CNResumenModelo.Fondo(tipo: "grad", color: "", angulo: angulo, paradas: paradas)
}

/// Solo para el banco de pruebas: rueda la lista sola a los dos segundos, para
/// poder capturar cómo queda el buscador fijo arriba.
struct CNRodarSolo: ViewModifier {
    let activo: Bool
    func body(content: Content) -> some View {
        if activo {
            ScrollViewReader { lector in
                content.onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                        withAnimation(.easeOut(duration: 0.5)) { lector.scrollTo("cnAbajo", anchor: .bottom) }
                    }
                }
            }
        } else {
            content
        }
    }
}

// ── Levantar tarjetas del panel (UIKit) ─────────────────────────────────────
//
// Un DragGesture de SwiftUI en cada tarjeta se queda con el dedo y el panel
// deja de hacer scroll mientras se organiza. Aquí el reconocedor de mantener
// pulsado va en el UIScrollView que envuelve el panel: hasta que no se
// mantiene quieto el dedo, el scroll manda; en cuanto se levanta una tarjeta,
// el scroll se apaga hasta soltarla.
struct CNPanelGlobal: PreferenceKey {
    static var defaultValue = CGRect.zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) { value = nextValue() }
}

struct CNLevantador: UIViewRepresentable {
    var alEmpezar: (CGPoint) -> Void
    var alMover: (CGSize) -> Void
    var alSoltar: (CGSize) -> Void

    func makeUIView(context: Context) -> CNLevantadorVista {
        let v = CNLevantadorVista()
        v.coord = context.coordinator
        return v
    }
    func updateUIView(_ v: CNLevantadorVista, context: Context) { context.coordinator.padre = self }
    func makeCoordinator() -> Coord { Coord(self) }
    static func dismantleUIView(_ v: CNLevantadorVista, coordinator: Coord) { v.quitar() }

    final class Coord: NSObject, UIGestureRecognizerDelegate {
        var padre: CNLevantador
        var inicio = CGPoint.zero
        weak var scroll: UIScrollView?
        init(_ p: CNLevantador) { padre = p }
        @objc func mantenido(_ g: UILongPressGestureRecognizer) {
            let p = g.location(in: nil)
            let t = CGSize(width: p.x - inicio.x, height: p.y - inicio.y)
            switch g.state {
            case .began:
                inicio = p
                scroll?.isScrollEnabled = false
                padre.alEmpezar(p)
            case .changed:
                padre.alMover(t)
            case .ended:
                scroll?.isScrollEnabled = true
                padre.alSoltar(t)
            default:
                scroll?.isScrollEnabled = true
                padre.alSoltar(.zero)
            }
        }
        func gestureRecognizer(_ g: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith o: UIGestureRecognizer) -> Bool { true }
    }
}

final class CNLevantadorVista: UIView {
    var coord: CNLevantador.Coord?
    private var reconocedor: UILongPressGestureRecognizer?
    override init(frame: CGRect) { super.init(frame: frame); isUserInteractionEnabled = false; backgroundColor = .clear }
    required init?(coder: NSCoder) { nil }
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard window != nil, reconocedor == nil, let c = coord else { return }
        // El UIScrollView que envuelve el panel: el de la ScrollView de SwiftUI.
        guard let sv = sequence(first: superview, next: { $0?.superview }).compactMap({ $0 as? UIScrollView }).first
        else { return }
        let g = UILongPressGestureRecognizer(target: c, action: #selector(CNLevantador.Coord.mantenido(_:)))
        g.minimumPressDuration = 0.4
        g.allowableMovement = 10
        g.cancelsTouchesInView = false
        g.delegate = c
        sv.addGestureRecognizer(g)
        reconocedor = g
        c.scroll = sv
    }
    override func willMove(toWindow w: UIWindow?) {
        super.willMove(toWindow: w)
        if w == nil { quitar() }
    }
    func quitar() {
        if let g = reconocedor { g.view?.removeGestureRecognizer(g) }
        reconocedor = nil
        coord?.scroll?.isScrollEnabled = true
    }
}

// ── Las tarjetas de arriba de Cuentas ───────────────────────────────────────
//
// El patrimonio es UN número, pero hay cinco maneras razonables de contarlo y
// cada persona lee mejor una. Van las cinco, y también la de no poner ninguna:
// quien solo quiere su lista de cuentas no tiene por qué cargar con una
// tarjeta grande arriba. Se elige en el menú de la pantalla.
//
// Todas sacan sus números de `CNCalculo.retrato`, que lee la libreta: aquí no
// se inventa nada ni se pide nada por el puente.

/// APILADA: un mazo de cartas que se puede girar.
///
/// Cuenta la historia en un gesto: hay cosas debajo, y lo de arriba es lo que
/// sobra después de todas. Pero además se GIRA: se arrastra la de delante
/// hacia abajo, o se toca una de atrás, y esa pasa al frente con su propio
/// detalle. Así el mazo no es un adorno —cada carta se puede leer entera—, y
/// al volver a la pantalla el orden empieza otra vez por el patrimonio, que
/// es lo que se viene a mirar.
struct CNTarjetaApilada: View {
    let r: CNCalculo.Retrato
    var oculto = false
    var onOjo: () -> Void = {}

    /// Cuántas veces se ha pasado la de delante atrás.
    @State private var giro = 0
    @State private var arrastre: CGFloat = 0

    /// Lo que asoma de cada carta de atrás y lo que mide la de delante.
    private let asoma: CGFloat = 38
    private let altoFrente: CGFloat = 132

    private struct Carta: Identifiable {
        var id: String
        var titulo: String
        var corto: String
        var monto: Double
        /// Se escribe con su signo: una deuda es negativa.
        var firmado: Bool
        var color: Color
        var pieIzq: String
        var pieDer: String
    }

    /// Las cartas que hay de verdad. El patrimonio siempre; las demás solo si
    /// existen: una franja vacía puesta para rellenar no cuenta nada.
    private var cartas: [Carta] {
        var c: [Carta] = []
        let tarjetas = r.debes - r.prestamos
        if r.prestamos > 0 || r.porCobrar > 0 {
            var pies: [String] = []
            if r.prestamos > 0 { pies.append(cnT("Debes") + " " + cnDinero(r.prestamos)) }
            if r.porCobrar > 0 { pies.append(cnT("Te deben") + " " + cnDinero(r.porCobrar)) }
            c.append(.init(id: "pre", titulo: cnT("Préstamos y fiados"), corto: cnT("Préstamos"),
                           monto: r.porCobrar - r.prestamos, firmado: true, color: cnColor(0x6f4bc9),
                           pieIzq: pies.joined(separator: " · "), pieDer: ""))
        }
        if tarjetas > 0 {
            c.append(.init(id: "tar", titulo: cnT("Tarjetas y crédito"), corto: cnT("Tarjetas"),
                           monto: -tarjetas, firmado: true, color: cnColor(0xd0463a),
                           pieIzq: r.tarjetas.prefix(2).map { $0.nombre + " " + cnDinero($0.monto) }
                               .joined(separator: " · "), pieDer: ""))
        }
        if r.ahorro > 0 {
            c.append(.init(id: "aho", titulo: cnT("Ahorro e inversión"), corto: cnT("Ahorro"),
                           monto: r.ahorro, firmado: false, color: cnColor(0x2f5bc4),
                           pieIzq: cnT("Guardado, no para gastar mañana"), pieDer: ""))
        }
        c.append(.init(id: "pat", titulo: cnT("Te queda si pagas todo"), corto: cnT("Te queda"),
                       monto: r.queda, firmado: false, color: CNC.side,
                       pieIzq: cnT("Para gastar") + " " + cnDinero(r.paraGastar),
                       pieDer: r.cambioMes == 0 ? ""
                           : (r.cambioMes > 0 ? "↑ " : "↓ ") + cnDinero(r.cambioMes) + " " + cnT("este mes")))
        return c
    }

    /// El mazo en el orden de ahora: la última de la lista es la de delante.
    private var enOrden: [Carta] {
        let c = cartas
        guard c.count > 1 else { return c }
        let n = ((giro % c.count) + c.count) % c.count
        return Array(c[n...] + c[..<n])
    }

    var body: some View {
        let mazo = enOrden
        let atras = mazo.dropLast()
        let frente = mazo.last
        return ZStack(alignment: .top) {
            ForEach(Array(atras.enumerated()), id: \.element.id) { i, carta in
                trasera(carta)
                    .padding(.horizontal, CGFloat(atras.count - 1 - i) * 8)
                    .offset(y: CGFloat(i) * asoma)
                    .zIndex(Double(i))
                    .onTapGesture { girarHasta(carta) }
            }
            if let f = frente {
                delantera(f)
                    .offset(y: CGFloat(atras.count) * asoma + max(0, arrastre))
                    .zIndex(99)
                    .gesture(arrastrar)
            }
        }
        .frame(height: CGFloat(max(0, mazo.count - 1)) * asoma + altoFrente,
               alignment: .top)
        .animation(.spring(response: 0.34, dampingFraction: 0.82), value: giro)
        // Al volver a la pantalla, el mazo empieza otra vez por el patrimonio.
        .onAppear { giro = 0; arrastre = 0 }
    }

    /// Arrastrar la de delante hacia abajo la manda al final del mazo.
    private var arrastrar: some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { g in arrastre = max(0, g.translation.height * 0.6) }
            .onEnded { g in
                let lejos = g.translation.height > 46 || g.predictedEndTranslation.height > 110
                withAnimation(.spring(response: 0.34, dampingFraction: 0.82)) {
                    arrastre = 0
                    if lejos, cartas.count > 1 {
                        UISelectionFeedbackGenerator().selectionChanged()
                        giro -= 1
                    }
                }
            }
    }

    /// Tocar una de atrás la trae al frente.
    private func girarHasta(_ carta: Carta) {
        let c = cartas
        guard c.count > 1, let destino = c.firstIndex(where: { $0.id == carta.id }) else { return }
        UISelectionFeedbackGenerator().selectionChanged()
        withAnimation(.spring(response: 0.34, dampingFraction: 0.82)) {
            giro = destino + 1
        }
    }

    private func trasera(_ c: Carta) -> some View {
        HStack(spacing: 10) {
            Text(c.titulo).font(cnLetra(13.5, .semibold)).lineLimit(1)
            Spacer(minLength: 8)
            Text(oculto ? "•••" : (c.firmado ? cnDineroFirmado(c.monto) : cnDinero(c.monto)))
                .font(cnLetra(13.5, .heavy)).lineLimit(1).minimumScaleFactor(0.7)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 17)
        .frame(height: altoFrente, alignment: .top)
        .padding(.top, 13)
        .frame(maxWidth: .infinity)
        .background(c.color, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.10), radius: 8, y: 3)
        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func delantera(_ c: Carta) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                Text(c.titulo).font(cnLetra(13)).foregroundColor(.white.opacity(0.82))
                Spacer(minLength: 8)
                Button(action: onOjo) {
                    Image(systemName: oculto ? "eye.slash.fill" : "eye.fill")
                        .font(cnLetra(12, .semibold)).foregroundColor(cnSobre(CNC.acc))
                        .frame(width: 28, height: 28).background(CNC.acc, in: Circle())
                }.buttonStyle(.plain)
            }
            Text(oculto ? "•••" : (c.firmado ? cnDineroFirmado(c.monto) : cnDinero(c.monto)))
                .font(cnLetra(32, .heavy)).foregroundColor(.white)
                .lineLimit(1).minimumScaleFactor(0.45)
                .padding(.top, 4)
            Spacer(minLength: 6)
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(c.pieIzq).font(cnLetra(12)).foregroundColor(.white.opacity(0.8))
                    .lineLimit(1).minimumScaleFactor(0.8)
                Spacer(minLength: 8)
                if !c.pieDer.isEmpty {
                    Text(c.pieDer).font(cnLetra(12, .semibold)).foregroundColor(CNC.acc)
                        .lineLimit(1).minimumScaleFactor(0.8)
                }
            }
        }
        // El alto, dicho a las claras. Dejándolo al `Spacer` con un `minHeight`
        // por fuera, la pila se quedaba con su alto natural y el pie no se
        // llegaba a dibujar: quedaba un bloque de color vacío debajo del
        // número.
        .padding(17)
        .frame(maxWidth: .infinity, minHeight: altoFrente, maxHeight: altoFrente, alignment: .topLeading)
        .background(
            ZStack(alignment: .bottomTrailing) {
                c.color
                // El círculo de luz de la esquina: le quita la planicie al
                // bloque de color sin meter una imagen.
                Circle().fill(Color.white.opacity(0.07))
                    .frame(width: 150, height: 150)
                    .offset(x: 46, y: 54)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.16), radius: 14, y: 6)
    }
}

/// SUMA: lo que tienes, menos lo que debes, igual lo que queda. Es la tarjeta
/// que ENSEÑA la cuenta en vez de dar el resultado, con el detalle de dónde
/// sale cada línea.
struct CNTarjetaSuma: View {
    let r: CNCalculo.Retrato
    var oculto = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(cnT("Tu patrimonio este mes")).font(cnLetra(13)).foregroundColor(CNC.pmut)
                .padding(.bottom, 12)
            fila("+", CNC.pos, cnT("Lo que tienes"), r.tienes, detalleTienes, CNC.ink)
            Divider().padding(.vertical, 12)
            fila("−", CNC.neg, cnT("Lo que debes"), r.debes, detalleDebes, CNC.neg)
            Divider().padding(.vertical, 12)
            fila("=", CNC.ink, cnT("Te queda"), r.queda, "", r.queda >= 0 ? CNC.pos : CNC.neg, fuerte: true)
            Text(cnT("Es lo que tendrías si hoy pagaras todas tus deudas."))
                .font(cnLetra(11.5)).foregroundColor(CNC.pmut)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 12)
        }
        .padding(16).tarjetaCN()
    }

    private var detalleTienes: String {
        var p: [String] = []
        if r.paraGastar != 0 { p.append(cnT("Para gastar") + " " + cnDinero(r.paraGastar)) }
        if r.ahorro != 0 { p.append(cnT("Ahorro") + " " + cnDinero(r.ahorro)) }
        if r.porCobrar != 0 { p.append(cnT("Te deben") + " " + cnDinero(r.porCobrar)) }
        return p.joined(separator: " · ")
    }
    private var detalleDebes: String {
        var p: [String] = r.tarjetas.prefix(2).map { $0.nombre + " " + cnDinero($0.monto) }
        if r.prestamos != 0 { p.append(cnT("Préstamos") + " " + cnDinero(r.prestamos)) }
        return p.joined(separator: " · ")
    }

    private func fila(_ signo: String, _ tinte: Color, _ t: String, _ v: Double,
                      _ sub: String, _ tintaValor: Color, fuerte: Bool = false) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(signo).font(cnLetra(15, .heavy))
                .foregroundColor(fuerte ? cnSobre(tinte) : tinte)
                .frame(width: 26, height: 26)
                .background(fuerte ? tinte : tinte.opacity(0.14), in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(t).font(cnLetra(fuerte ? 16 : 15, fuerte ? .bold : .regular)).foregroundColor(CNC.ink)
                if !sub.isEmpty {
                    Text(sub).font(cnLetra(11.5)).foregroundColor(CNC.pmut)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: 8)
            Text(oculto ? "•••" : cnDinero(v))
                .font(cnLetra(fuerte ? 19 : 16, fuerte ? .heavy : .semibold))
                .foregroundColor(tintaValor)
                .lineLimit(1).minimumScaleFactor(0.6)
        }
    }
}

/// GRÁFICA: el patrimonio a lo largo del tiempo, con su periodo a elegir.
/// La única que contesta «¿voy bien?» en vez de «¿cuánto tengo?».
struct CNTarjetaGrafica: View {
    let r: CNCalculo.Retrato
    var oculto = false
    @State private var meses = 12
    private let periodos: [(Int, String)] = [(3, "3M"), (6, "6M"), (12, "1A"), (0, "Todo")]

    private var puntos: [(etiqueta: String, valor: Double)] {
        meses == 0 ? r.serie : Array(r.serie.suffix(meses))
    }
    private var cambio: Double {
        guard let a = puntos.first?.valor, let b = puntos.last?.valor else { return 0 }
        return b - a
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // EL PATRIMONIO VA CON SIGNO. `cnDinero` se lo come, y esto puede ser
            // negativo —se debe más de lo que se tiene—: el mismo número salía
            // «−RD$132,036» en el Resumen y «RD$132,036» aquí. Y al añadir una
            // cuenta de 50.000, esta cifra BAJABA 50.000, porque lo que bajaba
            // era el tamaño de la deuda. Una app de dinero no puede enseñar un
            // número que mejora como si empeorara.
            Text(cnT("Patrimonio")).font(cnLetra(13)).foregroundColor(CNC.pmut)
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(oculto ? "•••" : cnDineroFirmado(r.queda))
                    .font(cnLetra(30, .heavy)).foregroundColor(CNC.ink)
                    .lineLimit(1).minimumScaleFactor(0.5)
                if cambio != 0 && !oculto {
                    Text((cambio > 0 ? "+" : "−") + cnDinero(cambio) + " " + cnT("en") + " " + etiquetaPeriodo())
                        .font(cnLetra(12.5, .semibold))
                        .foregroundColor(cambio > 0 ? CNC.pos : CNC.neg)
                        .lineLimit(1).minimumScaleFactor(0.7)
                }
                Spacer(minLength: 0)
            }
            CNLineaPatrimonio(valores: puntos.map { $0.valor },
                              color: cambio >= 0 ? CNC.pos : CNC.neg)
                .frame(height: 118)
                .opacity(oculto ? 0.25 : 1)
            HStack {
                Text(primeraEtiqueta()).font(cnLetra(11)).foregroundColor(CNC.pmut)
                Spacer(minLength: 8)
                Text(ultimaEtiqueta()).font(cnLetra(11)).foregroundColor(CNC.pmut)
            }
            Picker("", selection: $meses) {
                ForEach(periodos, id: \.0) { p in Text(cnT(p.1)).tag(p.0) }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
        }
        .padding(16).tarjetaCN()
    }

    private func etiquetaPeriodo() -> String {
        switch meses {
        case 3: return "3 " + cnT("meses")
        case 6: return "6 " + cnT("meses")
        case 12: return "1 " + cnT("año")
        default: return cnT("todo")
        }
    }
    private func mes(_ ym: String) -> String {
        guard let d = CNFormateadores.formato("yyyy-MM", loc: "en_US_POSIX").date(from: ym) else { return ym }
        return CNFormateadores.plantilla("MMM yy").string(from: d)
    }
    private func primeraEtiqueta() -> String { puntos.first.map { mes($0.etiqueta) } ?? "" }
    private func ultimaEtiqueta() -> String { cnT("Hoy") }
}

/// La línea con su relleno. Sin dependencias: una `Path` y ya.
struct CNLineaPatrimonio: View {
    let valores: [Double]
    let color: Color

    var body: some View {
        GeometryReader { g in
            let w = g.size.width, h = g.size.height
            let n = valores.count
            if n >= 2 {
                let lo = valores.min() ?? 0, hi = valores.max() ?? 1
                let rango = max(1, hi - lo)
                let punto = { (i: Int) -> CGPoint in
                    CGPoint(x: w * CGFloat(i) / CGFloat(n - 1),
                            y: h - (CGFloat((valores[i] - lo) / rango) * (h - 10)) - 5)
                }
                // Las guías, como en el resto de las gráficas de la app.
                ForEach(1..<4, id: \.self) { k in
                    Rectangle().fill(CNC.line.opacity(0.5))
                        .frame(height: 0.5)
                        .offset(y: h * CGFloat(k) / 4)
                }
                Path { p in
                    p.move(to: CGPoint(x: 0, y: h))
                    p.addLine(to: punto(0))
                    for i in 1..<n { p.addLine(to: punto(i)) }
                    p.addLine(to: CGPoint(x: w, y: h))
                    p.closeSubpath()
                }
                .fill(LinearGradient(colors: [color.opacity(0.22), color.opacity(0.02)],
                                     startPoint: .top, endPoint: .bottom))
                Path { p in
                    p.move(to: punto(0))
                    for i in 1..<n { p.addLine(to: punto(i)) }
                }
                .stroke(color, style: StrokeStyle(lineWidth: 2.4, lineCap: .round, lineJoin: .round))
                Circle().fill(color).frame(width: 8, height: 8)
                    .position(punto(n - 1))
            }
        }
    }
}

/// CHINO: la misma cifra, contada por el personaje. Es la que se lee sin
/// saber de finanzas, y la única que dice «vas bien» o «vas mal» con palabras.
/// La barra de meta solo sale si hay una puesta: inventar un objetivo que
/// nadie eligió sería mentirle a la cara.
struct CNTarjetaChino: View {
    let r: CNCalculo.Retrato
    var oculto = false
    /// El dibujo de Chino, si la web ya lo mandó.
    var chinolo: String = ""
    /// A cuánto quiere llegar. 0 = no ha puesto ninguna.
    var meta: Double = 0

    private var subio: Bool { r.cambioMes >= 0 }
    private var pct: Double { meta > 0 ? max(0, min(1, r.queda / meta)) : 0 }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                if let img = cnImagenBase64(chinolo) {
                    Image(uiImage: img).resizable().scaledToFit().frame(width: 54, height: 54)
                } else {
                    Text(subio ? "🙂" : "😕").font(.system(size: 42))
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(frase).font(cnLetra(14, .semibold))
                        .foregroundColor(cnSobre(CNC.acc))
                        .fixedSize(horizontal: false, vertical: true)
                    Text(oculto ? "•••" : cnDineroFirmado(r.queda))
                        .font(cnLetra(30, .heavy)).foregroundColor(cnSobre(CNC.acc))
                        .lineLimit(1).minimumScaleFactor(0.5)
                }
                Spacer(minLength: 0)
            }
            if meta > 0 {
                VStack(alignment: .leading, spacing: 7) {
                    HStack {
                        Text(cnT("Meta") + ": " + cnDinero(meta))
                            .font(cnLetra(12.5, .semibold)).foregroundColor(cnSobre(CNC.acc))
                        Spacer(minLength: 8)
                        Text("\(Int((pct * 100).rounded()))%")
                            .font(cnLetra(12.5, .heavy)).foregroundColor(cnSobre(CNC.acc))
                    }
                    CNBarraProgreso(parte: pct, color: cnSobre(CNC.acc).opacity(0.85), alto: 8)
                    if let cuando = llegada() {
                        Text(cnT("A este ritmo llegas en") + " " + cuando)
                            .font(cnLetra(11.5)).foregroundColor(cnSobre(CNC.acc).opacity(0.7))
                    }
                }
                .padding(12)
                .background(Color.white.opacity(0.30),
                            in: RoundedRectangle(cornerRadius: 13, style: .continuous))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CNC.acc, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var frase: String {
        guard r.cambioMes != 0 else { return cnT("Si hoy pagas todo, te quedan") }
        let cuanto = cnDinero(r.cambioMes)
        return (subio ? cnT("¡Subiste") + " " + cuanto + "! " : cnT("Bajaste") + " " + cuanto + ". ")
            + cnT("Si hoy pagas todo, te quedan")
    }

    /// Cuándo llegaría a la meta al ritmo de este mes. Sin ritmo —o yendo
    /// hacia atrás— no se dice nada: una fecha inventada no ayuda.
    private func llegada() -> String? {
        guard meta > r.queda, r.cambioMes > 0 else { return nil }
        let faltan = (meta - r.queda) / r.cambioMes
        guard faltan.isFinite, faltan < 600 else { return nil }
        let cal = Calendar(identifier: .gregorian)
        guard let d = cal.date(byAdding: .month, value: Int(faltan.rounded(.up)), to: Date()) else { return nil }
        return CNFormateadores.plantilla("MMMM yyyy").string(from: d)
    }
}

/// BLOQUES: cada pieza del tamaño de lo que pesa. De un vistazo se ve si lo
/// que tienes guardado aguanta lo que debes, que en una lista de números hay
/// que compararlo a mano.
struct CNTarjetaBloques: View {
    let r: CNCalculo.Retrato
    var oculto = false

    private struct Pieza: Identifiable {
        var id: String; var label: String; var monto: Double; var color: Color
    }

    private var piezas: [Pieza] {
        var p: [Pieza] = []
        if r.ahorro > 0 { p.append(.init(id: "aho", label: cnT("Ahorro e inversión"), monto: r.ahorro, color: cnColor(0x2f5bc4))) }
        if r.paraGastar > 0 { p.append(.init(id: "gas", label: cnT("Para gastar"), monto: r.paraGastar, color: cnColor(0x1f7a46))) }
        for (i, t) in r.tarjetas.enumerated() {
            p.append(.init(id: "t\(i)", label: t.nombre, monto: t.monto, color: cnColor(0xd0463a)))
        }
        if r.prestamos > 0 { p.append(.init(id: "pre", label: cnT("Préstamos"), monto: r.prestamos, color: cnColor(0x7a4fd0))) }
        return p.sorted { $0.monto > $1.monto }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(cnT("Patrimonio")).font(cnLetra(13)).foregroundColor(CNC.pmut)
                Spacer(minLength: 8)
                Text(oculto ? "•••" : cnDineroFirmado(r.queda))
                    .font(cnLetra(20, .heavy)).foregroundColor(CNC.ink)
                    .lineLimit(1).minimumScaleFactor(0.6)
            }
            CNMosaico(piezas: piezas.map { (id: $0.id, label: $0.label, peso: $0.monto,
                                            color: $0.color, negativo: $0.color != cnColor(0x2f5bc4) && $0.color != cnColor(0x1f7a46)) },
                      queda: r.queda, oculto: oculto)
                .frame(height: 190)
            HStack(spacing: 14) {
                leyenda(cnT("Para gastar"), cnColor(0x1f7a46))
                leyenda(cnT("Ahorro"), cnColor(0x2f5bc4))
                leyenda(cnT("Deudas"), cnColor(0xd0463a))
                Spacer(minLength: 0)
            }
        }
        .padding(16).tarjetaCN()
    }

    private func leyenda(_ t: String, _ c: Color) -> some View {
        HStack(spacing: 5) {
            Circle().fill(c).frame(width: 7, height: 7)
            Text(t).font(cnLetra(11)).foregroundColor(CNC.pmut)
        }
    }
}

/// El mosaico: dos filas, lo que suma arriba y lo que resta abajo, cada pieza
/// de un ancho proporcional a lo que pesa dentro de su fila.
struct CNMosaico: View {
    let piezas: [(id: String, label: String, peso: Double, color: Color, negativo: Bool)]
    let queda: Double
    var oculto = false

    var body: some View {
        let suman = piezas.filter { !$0.negativo }
        let restan = piezas.filter { $0.negativo }
        // Las alturas, a mano. Repartiéndolas con prioridades de disposición
        // la fila de abajo quedaba aplastada y se salía de la tarjeta.
        return GeometryReader { g in
            let h = g.size.height
            let hueco: CGFloat = 7
            let alto1 = restan.isEmpty ? h : (h - hueco) * 0.58
            let alto2 = suman.isEmpty ? h : (h - hueco) * 0.42
            VStack(spacing: hueco) {
                if !suman.isEmpty {
                    fila(suman, ancho: g.size.width).frame(height: alto1)
                }
                if !restan.isEmpty {
                    fila(restan, ancho: g.size.width, conQueda: true).frame(height: alto2)
                }
            }
        }
    }

    private func fila(_ ps: [(id: String, label: String, peso: Double, color: Color, negativo: Bool)],
                      ancho: CGFloat, conQueda: Bool = false) -> some View {
        let total = max(1, ps.reduce(0) { $0 + $1.peso })
        // El hueco de «te queda» ocupa lo que le toca al lado de las deudas.
        let extra = conQueda && queda > 0 ? queda : 0
        let todo = total + extra
        let cuantos = ps.count + (extra > 0 ? 1 : 0)
        let libre = max(0, ancho - CGFloat(max(0, cuantos - 1)) * 6)
        return HStack(spacing: 6) {
            ForEach(ps, id: \.id) { p in
                bloque(p.label, p.peso, p.color, p.negativo)
                    .frame(width: max(58, libre * CGFloat(p.peso / todo)))
            }
            if extra > 0 {
                elHueco().frame(width: max(72, libre * CGFloat(extra / todo)))
            }
        }
        .frame(width: ancho, alignment: .leading)
    }

    private func bloque(_ t: String, _ v: Double, _ c: Color, _ neg: Bool) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(t).font(cnLetra(11, .semibold)).foregroundColor(.white.opacity(0.9))
                .lineLimit(2).minimumScaleFactor(0.8)
            Spacer(minLength: 0)
            Text(oculto ? "•••" : (neg ? "−" : "") + cnDinero(v))
                .font(cnLetra(15, .heavy)).foregroundColor(.white)
                .lineLimit(1).minimumScaleFactor(0.5)
        }
        .padding(9)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(c, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func elHueco() -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(cnT("Te queda")).font(cnLetra(11)).foregroundColor(CNC.pmut)
                .lineLimit(2).minimumScaleFactor(0.8)
            Spacer(minLength: 0)
            Text(oculto ? "•••" : cnDinero(queda))
                .font(cnLetra(15, .heavy)).foregroundColor(CNC.pos)
                .lineLimit(1).minimumScaleFactor(0.5)
        }
        .padding(9)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
            .strokeBorder(style: StrokeStyle(lineWidth: 1.4, dash: [5, 4]))
            .foregroundColor(CNC.line))
    }
}

// ── El botón de Chino, flotando ─────────────────────────────────────────────
//
// Un botón que se arrastra a donde estorbe menos y abre la conversación de un
// toque. Va por encima de todo —también de la barra del menú— porque la gracia
// es poder hablarle sin salir de donde estés.
//
// Se queda pegado al borde más cercano al soltarlo, como la burbuja de una
// videollamada: en medio de la pantalla tapa lo que estás mirando, y dejarlo
// donde el dedo lo soltó acaba siempre estorbando.

/// Dónde vive el botón y si está puesto. Lo manda la web (es un ajuste más) y
/// la posición se guarda ahí mismo, que es lo que sobrevive a cerrar la app.
final class CNFlotante: ObservableObject {
    static let shared = CNFlotante()
    /// Puesto o no. Falso de partida hasta que la web diga lo suyo.
    @Published var puesto = false
    /// Dónde quedó, en proporción de la pantalla (0…1), para que sobreviva a
    /// girar el teléfono o cambiar de aparato.
    @Published var x: CGFloat = 1
    @Published var y: CGFloat = 0.72
    /// Cómo se ve: «cara» (Chino) o «aro» (la marca). En la CHARLA sale
    /// siempre la cara, elijas lo que elijas: ahí es quien te está hablando, y
    /// un aro no habla.
    ///
    /// El aro de partida, como en la web: lo manda ella en cuanto arranca,
    /// pero en los primeros fotogramas manda esto, y que no cambie delante de
    /// los ojos vale más que el valor en sí.
    @Published var como = "aro"
    /// DÓNDE ESTÁ DIBUJADO, en coordenadas de la ventana.
    ///
    /// Lo escribe el propio botón al colocarse. No es `@Published` a propósito:
    /// solo lo lee la caja de los toques, y publicarlo volvería a dibujar en
    /// mitad de un dibujo.
    ///
    /// Antes la caja lo adivinaba preguntándole a SwiftUI, y SwiftUI contesta
    /// siempre lo mismo esté donde esté el dedo, así que el botón se quedaba
    /// sin recibir un solo toque. Que lo diga quien lo sabe.
    var marco: CGRect = .zero
    /// Qué hacer al tocarlo.
    var alTocar: () -> Void = {}
    /// Dónde ha quedado, para que la web lo guarde.
    var alMover: (CGFloat, CGFloat) -> Void = { _, _ in }
    /// Cuándo lo movió la persona por última vez.
    private var movidoEn = Date.distantPast

    /// Apunta que lo acaba de mover el dedo. Lo llama el propio botón al soltar.
    func loMovioElDedo() { movidoEn = Date() }

    /**
     * LO QUE MANDA LA WEB, SIN PISAR EL DEDO.
     *
     * Al soltar el botón pasa esto: avisa a la web, la web lo guarda y se lo
     * devuelve al nativo. Esa vuelta reescribía `x` e `y` de golpe y sin
     * animación, justo encima del muelle que lo estaba llevando al borde — y
     * desde fuera se veía como un salto. El botón aparecía donde levantaste el
     * dedo en vez de deslizarse.
     *
     * Así que durante un rato después de moverlo, el sitio lo manda el dedo y
     * no la web. Puesto o no sí se obedece siempre: eso no lo decide el dedo.
     */
    func ponDesdeLaWeb(puesto p: Bool, x nx: CGFloat, y ny: CGFloat) {
        puesto = p
        if Date().timeIntervalSince(movidoEn) < 2.5 { return }
        x = max(0, min(1, nx))
        y = max(0, min(1, ny))
    }
}

/// Dónde ha quedado dibujado el botón. Sube por preferencia porque escribirlo
/// desde dentro del `GeometryReader` es escribir en mitad del dibujado, y eso
/// le cuesta a SwiftUI otra pasada de distribución por cada cambio: durante un
/// arrastre deja de pintar los pasos intermedios.
struct CNMarcoDelBoton: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        let n = nextValue()
        if !n.isEmpty { value = n }
    }
}

struct CNBotonFlotante: View {
    @ObservedObject var mando = CNFlotante.shared
    @ObservedObject var datos: CNDatos
    @State private var arrastre: CGSize = .zero
    @State private var llevando = false
    /// Si el dedo está encima ahora mismo, sin haberse movido todavía.
    @State private var apretado = false
    /// Los dos movimientos de fondo, a distinto compás.
    @State private var alienta = false
    @State private var ladea = false
    /// Dormido = translúcido y arrimado al borde. Vuelve entero al tocarlo.
    @State private var dormido = false
    @State private var siesta: Timer?

    private let lado: CGFloat = 56
    private let margen: CGFloat = 14

    var body: some View {
        GeometryReader { g in
            if mando.puesto {
                let libre = CGRect(x: margen, y: g.safeAreaInsets.top + margen,
                                   width: max(0, g.size.width - margen * 2 - lado),
                                   height: max(0, g.size.height - g.safeAreaInsets.top - margen * 2 - lado))
                boton
                    // EL BOTÓN DICE DÓNDE ESTÁ, POR PREFERENCIA.
                    //
                    // Se mide AQUÍ, antes de `.position`: esa devuelve una vista
                    // que ocupa todo el hueco y coloca el contenido dentro, así
                    // que medida después el botón apuntaría la pantalla entera
                    // como suya y la caja se quedaría hasta el último toque.
                    //
                    // Y va por preferencia y no escribiendo en el mando desde
                    // dentro del `GeometryReader`. Escribir ahí es escribir en
                    // mitad del dibujado: SwiftUI encadena otra pasada de
                    // distribución con cada cambio y el arrastre deja de pintar
                    // los pasos intermedios — el botón se quedaba clavado y solo
                    // aparecía en su sitio nuevo al levantar el dedo. La
                    // preferencia se recoge fuera, cuando la pasada ya terminó.
                    .background(GeometryReader { p in
                        Color.clear.preference(key: CNMarcoDelBoton.self, value: p.frame(in: .global))
                    })
                    .position(x: libre.minX + libre.width * mando.x + lado / 2 + arrastre.width,
                              y: libre.minY + libre.height * mando.y + lado / 2 + arrastre.height)
                    .gesture(
                        // DESDE EL PRIMER PUNTO, NO A LOS CUATRO.
                        //
                        // Con `minimumDistance: 4` el gesto no decía nada hasta
                        // haber andado cuatro puntos, y entonces el primer aviso
                        // los traía andados: un brinco seco al empezar. Se
                        // guardaba ese tramo y se restaba, que arreglaba el
                        // brinco pero no el retraso — los cuatro primeros puntos
                        // el botón seguía clavado.
                        //
                        // A cero no hay retraso ni tramo que restar: el botón
                        // sale con el dedo desde el primer milímetro. El toque
                        // no se pierde porque se decide al soltar, por lo poco
                        // que se movió, que es lo que un toque es de verdad.
                        DragGesture(minimumDistance: 0)
                            .onChanged { v in
                                if !apretado { apretado = true; despierta() }
                                let anda = hypot(v.translation.width, v.translation.height)
                                // Cuatro puntos para considerarlo un arrastre: por
                                // debajo es el temblor normal de un dedo quieto, y
                                // moverlo por eso se ve como un tic.
                                if !llevando && anda > 4 {
                                    llevando = true
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                }
                                if llevando { arrastre = v.translation }
                            }
                            .onEnded { v in
                                apretado = false
                                let anda = hypot(v.translation.width, v.translation.height)
                                // Soltar sin haberse movido ES el toque.
                                guard llevando || anda > 4 else {
                                    UISelectionFeedbackGenerator().selectionChanged()
                                    despierta()
                                    mando.alTocar()
                                    return
                                }
                                // Al soltar, al borde más cercano: en medio de
                                // la pantalla tapa justo lo que estás mirando.
                                let px = libre.minX + libre.width * mando.x + v.translation.width
                                let py = libre.minY + libre.height * mando.y + v.translation.height
                                let nx: CGFloat = px + lado / 2 < g.size.width / 2 ? 0 : 1
                                let ny = max(0, min(1, libre.height > 0 ? (py - libre.minY) / libre.height : 0.5))
                                // TODO DENTRO DE LA MISMA ANIMACIÓN.
                                //
                                // `arrastre` se ponía a cero FUERA: en ese mismo
                                // fotograma el botón saltaba de golpe a la
                                // posición nueva y la animación no se veía.
                                llevando = false
                                withAnimation(.spring(response: 0.34, dampingFraction: 0.78)) {
                                    arrastre = .zero
                                    mando.x = nx; mando.y = ny
                                }
                                // Antes de avisar a la web: que lo movió el
                                // dedo. Lo que vuelva de allá no puede pisar
                                // esto mientras el muelle está corriendo.
                                mando.loMovioElDedo()
                                mando.alMover(nx, ny)
                                despierta()
                            }
                    )
            } else {
                // Sin botón puesto no hay marco: si se quedara el de antes, la
                // caja seguiría quedándose los toques de un botón que ya no
                // está, y ese trozo de pantalla se moriría.
                Color.clear.onAppear { mando.marco = .zero }
            }
        }
        .ignoresSafeArea()
        .onPreferenceChange(CNMarcoDelBoton.self) { nuevo in mando.marco = nuevo }
        .animation(.spring(response: 0.3, dampingFraction: 0.85), value: mando.puesto)
    }

    /// Se duerme solo: translúcido y arrimado al borde mientras no lo tocas.
    private func despierta() {
        if dormido { withAnimation(.easeOut(duration: 0.22)) { dormido = false } }
        siesta?.invalidate()
        siesta = Timer.scheduledTimer(withTimeInterval: 4.5, repeats: false) { _ in
            DispatchQueue.main.async { dormido = true }
        }
    }

    private var boton: some View {
        // NI UN `Button`, NI UN GESTO A SECAS.
        //
        // Era un `Button` con el arrastre colgado encima, y ahí estaba lo de
        // «solo se mueve cuando levanto el dedo». Un `Button` se QUEDA el dedo
        // mientras decide si aquello fue un toque; hasta que no suelta, el
        // arrastre no ve nada. Por eso la primera mitad del gesto no pintaba
        // nada y el botón aparecía de golpe al final.
        //
        // Sin `Button`: el dibujo, un arrastre que lo lleva, y el toque como lo
        // que de verdad es —soltar sin haberse movido—. Así el dedo manda desde
        // el primer punto.
        ZStack {
            ZStack {
                // SIN PLATO DETRÁS DEL PERSONAJE.
                //
                // Aquí había un círculo amarillo relleno y el dibujo encima. El
                // personaje ya es una forma redonda con su propio color y su
                // propia luz: ponerle otro círculo detrás le hace un halo que
                // no pinta nada y le quita el aire.
                //
                // El círculo se queda SOLO para el icono de respaldo, que es un
                // trazo suelto y sin él no se vería sobre la pantalla.
                if mando.como == "aro" {
                    // EL ARO DE LA MARCA. Es el que estaba arriba en Perfil, y
                    // no se perdió: se mudó aquí, que es donde se usa.
                    Circle().fill(CNC.side)
                    Circle().fill(CNC.acc).frame(width: lado * 0.38, height: lado * 0.38)
                } else if let img = cnImagenBase64(datos.mascota?.chinolo ?? "") {
                    Image(uiImage: img).resizable().scaledToFit()
                } else {
                    Circle().fill(CNC.acc)
                    Image(systemName: "bubble.left.and.text.bubble.right.fill")
                        .font(.system(size: 21, weight: .semibold))
                        .foregroundColor(cnSobre(CNC.acc))
                }
            }
            .frame(width: lado, height: lado)
            // LA VIDA DEL BOTÓN.
            //
            // El dibujo que llega es una estampa: no parpadea ni mira. Si
            // además se queda completamente quieto, un botón redondo flotando
            // es un adhesivo pegado a la pantalla. Lo que lo hace estar ahí son
            // dos movimientos muy pequeños y a distinto compás —respira en 3,7
            // segundos y se ladea en 6,1—, que al no coincidir nunca no se
            // dejan pillar el patrón. Grande se notaría; así solo se nota que
            // está vivo.
            .scaleEffect(alienta ? 1.028 : 0.985)
            .rotationEffect(.degrees(ladea ? 2.2 : -2.2))
            // Y SE APARTA SOLO CUANDO LO DEJAS EN PAZ.
            //
            // Es lo que hace que el botón de iPhone no estorbe nunca: pasados
            // unos segundos sin tocarlo se vuelve translúcido y se arrima al
            // borde, y vuelve entero en cuanto lo rozas. Sin esto, un botón
            // opaco en medio de tus cifras es algo que tapa; con esto es algo
            // que espera.
            .opacity(dormido ? 0.42 : 1)
            .offset(x: dormido ? (mando.x > 0.5 ? lado * 0.22 : -lado * 0.22) : 0)
            .animation(.easeInOut(duration: 0.45), value: dormido)
            // Y al agarrarlo crece y la sombra se despega: es lo que dice que
            // lo tienes cogido.
            .scaleEffect(llevando ? 1.1 : (apretado ? 0.93 : 1))
            .shadow(color: .black.opacity(llevando ? 0.22 : 0.13),
                    radius: llevando ? 14 : 7, y: llevando ? 6 : 3)
            .animation(.spring(response: 0.26, dampingFraction: 0.62), value: llevando)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: apretado)
            .onAppear {
                withAnimation(.easeInOut(duration: 3.7).repeatForever(autoreverses: true)) { alienta = true }
                withAnimation(.easeInOut(duration: 6.1).repeatForever(autoreverses: true)) { ladea = true }
                despierta()
            }
        }
        .contentShape(Circle())
        .accessibilityLabel(cnT("Hablar con Chino"))
        .accessibilityAddTraits(.isButton)
    }
}

/// Un contenedor que solo se queda con los toques que caen en algo suyo.
///
/// El botón flotante ocupa la pantalla entera para poder colocarse donde sea,
/// pero si se quedara con todos los toques no se podría usar nada de lo que
/// hay debajo. Esto deja pasar todo lo que no dé en el botón.
/// EL BOTÓN DE CHINO, SIN ROBAR LOS TOQUES DE LA PANTALLA.
///
/// Esto sobreescribía `loadView` con una `UIView` normal:
///
///     override func loadView() { view = CNPasaToques() }
///
/// Y ahí estaba el fallo. `UIHostingController` crea en su `loadView` la vista
/// especial que ALOJA Y DIBUJA el SwiftUI; cambiándola por una vista corriente,
/// el contenido se queda sin nada que lo pinte. El contenedor existía, ocupaba
/// la pantalla entera, estaba visible y por encima de todo —lo dijo la sonda,
/// `frame=(0,0,402,874) alpha=1 oculta=false enPantalla=true indice=3 de 4`— y
/// estaba VACÍO. El botón nunca se vio, por más vueltas que se le diera al lado
/// de la web.
///
/// Es el mismo error que hace Capacitor con `view = webView`, y cuesta verlo
/// por lo mismo: todo lo que se mide dice que está bien.
///
/// Ahora el hospedaje es el de siempre —el que dibuja— y los toques se
/// arreglan FUERA, con una caja alrededor.
///
/// Y hace falta: di por hecho que una vista de SwiftUI transparente no recibe
/// toques donde no hay nada dibujado, y es falso. La vista que aloja el SwiftUI
/// ocupa la pantalla entera y se los quedaba TODOS: la app se veía bien y no
/// respondía a nada salvo al propio botón. No se podía ni cambiar de pestaña.
final class CNPasaToquesHost: UIHostingController<AnyView> {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.isOpaque = false
    }
}

/// LA CAJA QUE DEJA PASAR LOS TOQUES.
///
/// Esta capa está a pantalla completa por encima del webview, así que quedarse
/// un toque de más mata la app entera y quedarse uno de menos mata el botón.
/// Las dos cosas han pasado ya.
///
/// La primera versión le preguntaba a SwiftUI —«¿hay algo tuyo en este
/// punto?»— dando por hecho que contestar con su propia vista significaba
/// «aquí no hay nada». Falso: SwiftUI dibuja el botón en el lienzo de esa misma
/// vista y contesta lo mismo esté el dedo donde esté. Resultado: «aquí no hay
/// nada» siempre, y el botón sin recibir un solo toque.
///
/// Ahora no se adivina: el botón apunta su propio marco al colocarse y aquí
/// solo se mira si el punto cae dentro. Sin marco —botón sin poner, o todavía
/// sin dibujar— pasa todo, que es lo que menos daño hace.
final class CNPasaToques: UIView {
    override func point(inside punto: CGPoint, with evento: UIEvent?) -> Bool {
        let m = CNFlotante.shared.marco
        guard CNFlotante.shared.puesto, !m.isEmpty else { return false }
        // Un marco más grande que el botón es un marco mal medido, y creerlo
        // cuesta la app entera. De los dos fallos posibles este se queda con el
        // barato: se pierde el botón, no la pantalla.
        guard m.width < 120, m.height < 120 else { return false }
        return m.contains(convert(punto, to: nil))
    }
}
