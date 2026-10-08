import Foundation

/**
 * LA LISTA DE PERFIL, ARMADA AQUÍ.
 *
 * Es la pantalla de Perfil entera: la tarjeta de arriba y los seis grupos de
 * filas. Se le pedía a la web (`__chinolaAjustesJSON`) y, salvo tres cosas,
 * todo sale de lo que el teléfono ya tiene: la copia con la sesión y los
 * ajustes, y los catálogos que genera `npm run sync`.
 *
 * LO IMPORTANTE NO ES LA LISTA: ES CÓMO SE DISPARA CADA FILA.
 *
 * La web las disparaba por su POSICIÓN —grupo 2, fila 3—, y esa posición solo
 * vale si la lista la hizo ella: con sesión hay filas que con cuenta local no
 * existen, y al revés. Armándola aquí, cada fila lleva QUÉ ES (`sec`) y el
 * teléfono la atiende por su nombre. Es la tercera vez en este trabajo que un
 * «por dónde está» se cambia por un «qué es», y las tres veces era lo mismo:
 * una lista que no siempre trae las mismas filas.
 *
 * TRES COSAS QUE SIGUEN SIENDO DE LA WEB, y por eso son filas con su llave:
 * exportar (arma el CSV), el paseo de bienvenida y entrar o salir de la
 * cuenta. Lo demás abre una subpantalla nativa o mueve un ajuste.
 */
enum CNAjustesArma {

    /// El color de cada fila, por su tono. Los tonos los genera `sync`.
    private static func tono(_ id: String) -> String { CNCatalogos.tonos[id] ?? "" }
    /// El mismo color al 14 %, que es el fondo del cuadrito del icono.
    private static func fondo(_ id: String) -> String {
        CNCuentasFilas.tinte(tono(id), 0.14)
    }
    private static func icono(_ id: String) -> String { CNCatalogos.iconosDeAjuste[id] ?? "" }

    private static func fila(_ label: String, sub: String = "", valor: String = "",
                             icono ic: String, tono t: String, sec: String,
                             entra: Bool = true, tinta: String = "") -> CNAjustes.Fila {
        var f = CNAjustes.Fila()
        f.label = cnT(label)
        f.sub = sub.isEmpty ? "" : cnT(sub)
        f.valor = valor
        f.icono = icono(ic)
        f.bg = fondo(t); f.fg = tono(t)
        f.tinta = tinta
        f.entra = entra
        f.sec = sec
        return f
    }

    /**
     * LOS OCHO APARTADOS DE APARIENCIA, con lo que tienen puesto a la derecha.
     *
     * Estaban detrás de una fila «Personalización», así que para cambiar la
     * letra había que adivinar que estaba ahí dentro. El valor de la derecha no
     * es decoración: es lo que deja ver de un vistazo qué tienes puesto sin
     * entrar en los ocho.
     */
    static func apariencia(_ f: CNFormato) -> [CNAjustes.Fila] {
        let nombreTema = CNCatalogos.temas[CNTemaArma.cual(CNAlmacen.ajustes(), deNoche: CNC.tema.oscuro)]?.nombre ?? ""
        let nombreLetra = CNCatalogos.letras.first { $0.id == f.letraId }?.nombre ?? ""
        let nombreCab = CNCatalogos.cabeceras.first { $0.id == f.cabecera }?.nombre ?? ""
        let nombreIcono = CNCatalogos.iconosDeLaApp.first {
            $0.id == (f.iconoApp.isEmpty ? CNCatalogos.iconoPrincipal : f.iconoApp)
        }?.nombre ?? ""
        var fuera: [CNAjustes.Fila] = [
            fila("Panel del resumen", sub: "Qué tarjetas hay y en qué orden",
                 icono: "panelIco", tono: "verde", sec: "panel"),
            fila("Cabecera", sub: "Qué se ve arriba y de qué color", valor: cnT(nombreCab),
                 icono: "cabeceraIco", tono: "indigo", sec: "cabecera"),
            fila("Menú de abajo", sub: "Nombres e icono de Perfil",
                 icono: "barraIco", tono: "azul", sec: "menu"),
            fila("Letra", sub: "Tipografía y tamaño del texto", valor: cnT(nombreLetra),
                 icono: "letraIco", tono: "morado", sec: "letra"),
            fila("Colores", sub: "El tema de toda la app", valor: cnT(nombreTema),
                 icono: "coloresIco", tono: "rojo", sec: "colores"),
            fila("Dinero", sub: "Moneda y cómo se escriben las cifras", valor: f.moneda,
                 icono: "dineroIco", tono: "oro", sec: "dinero"),
            fila("Tu personaje", sub: "La chinola que te acompaña",
                 icono: "personajeIco", tono: "oliva", sec: "personaje")
        ]
        // El icono de la app solo existe dentro de la app: en el navegador no
        // hay pantalla de inicio que cambiar.
        fuera.append(fila("El icono de la app", sub: "Cuál se ve en la pantalla de inicio",
                          valor: cnT(nombreIcono), icono: "appIco", tono: "indigo", sec: "icono-app"))
        return fuera
    }

    static func arma(perfil p: CNPerfilInfo, formato f: CNFormato) -> CNAjustes {
        var a = CNAjustes()
        let haySesion = !p.local
        a.usuario = tarjeta(p)

        // CUENTA: quién eres, cómo entras y tus libretas.
        var cuenta: [CNAjustes.Fila] = []
        if haySesion {
            cuenta.append(fila("Mi cuenta", sub: p.email.isEmpty ? "Nombre, correo y contraseña" : "",
                               valor: "", icono: "perfil", tono: "verde", sec: "cuenta"))
            if !p.email.isEmpty { cuenta[cuenta.count - 1].sub = p.email }
            cuenta.append(fila("Seguridad", sub: "Dos pasos y aparatos conectados",
                               icono: "escudo", tono: "indigo", sec: "seguridad"))
        } else {
            cuenta.append(fila("Mi nombre", sub: "Sin cuenta: todo se queda en este aparato",
                               valor: p.nombre, icono: "perfil", tono: "verde", sec: "nombre"))
            // SIN CUENTA TAMBIÉN SE PUEDE PONER EL CANDADO. Dentro viven los
            // aparatos conectados y los dos pasos, que son de la cuenta, pero
            // también el bloqueo con la cara, que es del APARATO —no sube a
            // ningún sitio— y justo en modo local es cuando más hace falta: los
            // datos están solo en este teléfono.
            cuenta.append(fila("Seguridad", sub: "Pedir tu cara o tu huella al abrir la app",
                               icono: "escudo", tono: "indigo", sec: "seguridad"))
        }
        cuenta.append(fila("Libretas y permisos", sub: "Quién ve y quién edita cada libreta",
                           valor: String(p.libretas), icono: "libretas", tono: "azul", sec: "libretas"))

        // APP: lo que cambia cómo se comporta, no cómo se ve.
        var app: [CNAjustes.Fila] = [idioma(f)]
        var avisos = fila("Avisos de pago", sub: "Aviso antes de cada pago",
                          icono: "notis", tono: "naranja", sec: "pon:notis", entra: false)
        avisos.valor = ((CNAlmacen.ajustes()["notis"] as? Bool) ?? false) ? cnT("Activados") : cnT("Apagados")
        app.append(avisos)

        // DATOS: sacar y meter movimientos, y con qué se conecta.
        var datos: [CNAjustes.Fila] = [
            fila("Exportar", sub: "Movimientos, cuentas, categorías… lo que marques",
                 icono: "exportar", tono: "oliva", sec: "web:exportar", entra: false),
            fila("Importar", sub: "Un archivo de Chinola (.json) o un CSV del banco",
                 icono: "importar", tono: "azul", sec: "importar", entra: false)
        ]
        // Las integraciones son de la cuenta: sin sesión no hay nada que
        // conectar, y la fila llevaría a una pantalla vacía.
        if haySesion {
            datos.append(fila("Integraciones", sub: "Conectar Chinola con otras apps",
                              icono: "integraciones", tono: "morado", sec: "integraciones"))
        }

        // AYUDA: el paseo, la guía y lo legal, con la versión al pie.
        let sobre: [CNAjustes.Fila] = [
            fila("Ver el paseo otra vez", sub: "Repasar cómo funciona la app",
                 icono: "tour", tono: "verde", sec: "web:tour", entra: false),
            fila("Ayuda y guía", sub: "Preguntas frecuentes y cómo se usa",
                 icono: "ayuda", tono: "verde", sec: "abrir:/guia.html"),
            fila("Privacidad y términos", sub: "Qué se guarda y qué no",
                 icono: "privacidad", tono: "verde", sec: "abrir:/legal/privacidad.html")
        ]

        a.grupos = [
            CNAjustes.Grupo(titulo: cnT("Cuenta"), filas: cuenta),
            CNAjustes.Grupo(titulo: cnT("Apariencia"), filas: apariencia(f)),
            CNAjustes.Grupo(titulo: cnT("App"), filas: app),
            CNAjustes.Grupo(titulo: cnT("Datos"), filas: datos),
            CNAjustes.Grupo(titulo: cnT("Ayuda"), pie: pieDeVersion(), filas: sobre)
        ]
        // Entrar o salir, que es de la web: tiene la sesión.
        a.grupos.append(CNAjustes.Grupo(filas: [
            haySesion
                ? fila("Cerrar sesión", icono: "salir", tono: "rojo", sec: "web:salir",
                       entra: false, tinta: tono("rojo"))
                : fila("Crear cuenta y sincronizar", icono: "salir", tono: "verde",
                       sec: "web:salir", entra: false)
        ]))
        // Y sin cuenta, borrarlo todo: es lo único que hay, y no hay copia en
        // ningún sitio.
        if !haySesion {
            a.grupos.append(CNAjustes.Grupo(filas: [
                fila("Borrar todos mis datos", sub: "No se puede deshacer",
                     icono: "baja", tono: "rojo", sec: "hoja:borrarLocal",
                     entra: true, tinta: tono("rojo"))
            ]))
        }
        return a
    }

    /// La tarjeta de arriba: quién eres, con qué plan y si esto se sincroniza.
    static func tarjeta(_ p: CNPerfilInfo) -> CNAjustes.Usuario {
        var u = CNAjustes.Usuario()
        u.inicial = CNCategorias.inicial(p.nombre)
        u.nombre = p.nombre
        // SIN CUENTA AQUÍ NO VA UN CORREO, va una frase. Dejarlo vacío deja un
        // hueco donde se espera un dato.
        u.correo = p.local ? cnT("Datos solo en este equipo") : p.email
        u.plan = p.plan
        u.modoLabel = p.local ? cnT("Local") : cnT("Sincronizado")
        u.modoBg = p.local ? CNC.hexSoft : CNCuentasFilas.tinte(cnHexDe(CNC.pos), 0.14)
        u.modoFg = p.local ? cnHexDe(CNC.pmut) : cnHexDe(CNC.pos)
        u.acento = cnHexDe(CNC.acc)
        u.sobreAcento = cnHexDe(cnSobre(CNC.acc))
        return u
    }

    /// El idioma, con su lista. Es el único ajuste de esta pantalla que se
    /// elige aquí mismo en vez de entrar en otra.
    static func idioma(_ f: CNFormato) -> CNAjustes.Fila {
        let cuales = [("es", "Español"), ("en", "English"), ("fr", "Français")]
        let puesto = String(f.loc.prefix(2))
        var x = CNAjustes.Fila()
        x.label = cnT("Idioma")
        x.icono = icono("idioma")
        x.bg = fondo("azul"); x.fg = tono("azul")
        x.entra = true
        x.lista = cuales.map { CNAjustes.Opcion(id: $0.0, label: $0.1) }
        x.listaValor = cuales.first { $0.0 == puesto }?.1 ?? "Español"
        x.valor = x.listaValor
        // La lista escribe el ajuste por su nombre, como los demás.
        x.sec = "pon:idioma"
        return x
    }

    /// «Versión 1.4 (218)». Sale del paquete, que es lo que de verdad está
    /// instalado: escrita en el código diría la de cuando se escribió.
    static func pieDeVersion() -> String {
        let v = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "?"
        let b = (Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? "?"
        return cnT("Versión {v} · {f}")
            .replacingOccurrences(of: "{v}", with: v)
            .replacingOccurrences(of: "{f}", with: b)
    }
}
