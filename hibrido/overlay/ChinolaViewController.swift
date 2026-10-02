import UIKit
import SwiftUI
import Capacitor
import UniformTypeIdentifiers
import LocalAuthentication

/**
 * Base: la WEB de Capacitor. Encima, lo NATIVO:
 *  - La barra de menú (Liquid Glass).
 *  - La pestaña Movimientos (CNMovs).
 *  - Todas las HOJAS y DETALLES: nuevo movimiento, editar, detalles de cuenta /
 *    tarjeta / préstamo / meta, agregar (cuenta/tarjeta/préstamo), nueva meta,
 *    abono, aporte, pago de tarjeta y transferencia.
 *
 * Los datos se LEEN del webview (`traerDatos`), que es a prueba de fallos; el
 * guardado reusa la lógica de la web (`window.__chinola…`), así el dinero se
 * calcula exactamente igual que siempre.
 */
class ChinolaViewController: CAPBridgeViewController {
    let menuEstado = CNMenuEstado.shared
    let datos = CNDatos.shared
    private let nativo = NativoPlugin()
    private let barra = CNBarraNativa()
    private var contenedorNativo: UIView?

    /// Las pestañas que se dibujan en NATIVO.
    ///
    /// Todas menos Resumen. Y la razón es distinta para cada una, no una regla
    /// general:
    ///
    /// · **Movs** es la mejor resuelta en nativo: lee la libreta en Swift, sin
    ///   puente, y trae su buscador, sus filtros y sus hojas del sistema.
    ///   Pasarla a web fue un error — se perdían la barra de arriba, el
    ///   buscador, las transiciones y la hoja de nuevo movimiento.
    /// · **Cuentas** y **Plan** dibujan lo que la web calcula, pero sus filas
    ///   se deslizan, sus menús son del sistema y sus formularios también.
    /// · **Perfil** son subpantallas nativas encadenadas.
    /// · **Resumen** sí se queda en web: la web calcula toda la geometría del
    ///   panel —los puntos de las líneas, los tramos de la dona, las paradas
    ///   de los degradados— y el nativo solo la dibujaba. Ahí el puente se
    ///   pagaba entero sin ganar nada, y encima el panel es configurable con
    ///   su configuración en la web.
    ///
    /// Las cinco puertas del plugin (hoja, formulario, selector, hojaPeriodo,
    /// periodo) siguen valiendo: el Resumen en web pide los menús, los
    /// formularios y las hojas al sistema en vez de dibujarlos él.
    // Las CINCO son nativas. Resumen se había dejado en web porque la web ya
    // calcula la geometría del panel y lo nativo solo la dibujaba; el problema
    // es que se NOTABA: al volver de otra pestaña salía la pantalla de la PWA,
    // con su botón de «+» flotando en medio y una franja arriba entre la isla y
    // la cabecera. La vista nativa ya estaba hecha y completa (cabecera,
    // panel, modo organizar), así que el puente se paga y se acabó el salto.
    private let nativas: Set<String> = ["resumen", "movs", "cuentas", "plan", "perfil"]

    override func capacitorDidLoad() {
        if sin("plugins") { return }
        nativo.store = datos
        nativo.menuEstado = menuEstado
        bridge?.registerPluginInstance(CobroPlugin())
        bridge?.registerPluginInstance(nativo)
        // La IA del propio teléfono. Se registra siempre; ella misma dice si
        // este aparato puede usarla.
        bridge?.registerPluginInstance(IALocalPlugin())
    }

    /// El teléfono cambió de claro a oscuro (o al revés).
    ///
    /// El webview no siempre vuelve a evaluar `prefers-color-scheme` al volver
    /// del segundo plano, y había que reiniciar la app para ver el cambio. Se
    /// le dice aquí, en cuanto pasa, y también al volver a primer plano.
    override func traitCollectionDidChange(_ previo: UITraitCollection?) {
        super.traitCollectionDidChange(previo)
        guard traitCollection.userInterfaceStyle != previo?.userInterfaceStyle else { return }
        avisarDelModo()
    }
    /// El modo del teléfono DE VERDAD: el de la pantalla.
    ///
    /// La ventana no vale: la app le fuerza el estilo al del tema puesto (para
    /// que las alertas y hojas del sistema vayan a juego), así que su trait
    /// siempre coincide con el tema y nunca avisa de nada. Era justo por eso
    /// por lo que había que reiniciar: la ventana —y con ella el webview y su
    /// `prefers-color-scheme`— no veían el cambio del teléfono.
    private var sistemaOscuro: Bool {
        UIScreen.main.traitCollection.userInterfaceStyle == .dark
    }
    /// Y por si ningún aviso llega: cada dos segundos se comprueba que la
    /// paleta puesta sea la del modo del teléfono. Es una comparación, no
    /// cuesta nada, y cierra la puerta a «hay que reiniciar».
    ///
    /// Lo intenté quitar escuchando a la pantalla, que es la única que ve el
    /// modo de verdad —la ventana no, porque la app le fuerza el estilo del
    /// tema—. No se puede: `UIScreen` NO admite `registerForTraitChanges`, no
    /// conforma a `UITraitChangeObservable` (sí lo hacen UIView,
    /// UIViewController y UIPresentationController, que están todos dentro de
    /// la ventana forzada y por eso no sirven). Si algún día hay a quién
    /// escuchar, este reloj sobra; hasta entonces, se queda.
    private var vigiaModo: Timer?
    private func vigilarModo() {
        // El reloj corre SOLO mientras la app está delante. Antes seguía
        // despertando al teléfono cada dos segundos con la app en segundo
        // plano y hasta con la pantalla apagada, sin nada que mirar: puro
        // gasto de batería. Y al volver se comprueba de una vez, que es
        // justamente cuando suele haber cambiado el modo.
        NotificationCenter.default.addObserver(self, selector: #selector(modoDelante),
                                               name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(modoDetras),
                                               name: UIApplication.didEnterBackgroundNotification, object: nil)
        arrancarVigiaModo()
    }

    /// CLARO U OSCURO, SEGÚN LA PALETA PUESTA.
    ///
    /// Va en el propio controlador ADEMÁS de en la ventana. La ventana no
    /// siempre existe cuando esto hace falta —en `viewDidLoad` todavía es
    /// nula— y entonces el ajuste se perdía: con un tema oscuro, las listas
    /// nativas seguían pidiéndole al sistema sus colores de modo claro y las
    /// filas salían BLANCAS sobre un fondo negro. Puesto en el controlador
    /// baja solo a todo lo que cuelga de él.
    private func ponerModoDeLaPaleta() {
        let modo: UIUserInterfaceStyle = CNC.tema.oscuro ? .dark : .light
        overrideUserInterfaceStyle = modo
        view.window?.overrideUserInterfaceStyle = modo
        // Y lo que se enseña encima (hojas, detalles) va por su cuenta.
        presentedViewController?.overrideUserInterfaceStyle = modo
        hojaVC?.overrideUserInterfaceStyle = modo
        detalleVC?.overrideUserInterfaceStyle = modo
    }

    @objc private func modoDelante() {
        if CNC.pareja.oscuro != nil, sistemaOscuro != CNC.tema.oscuro { avisarDelModo() }
        arrancarVigiaModo()
    }

    @objc private func modoDetras() {
        vigiaModo?.invalidate(); vigiaModo = nil
    }

    private func arrancarVigiaModo() {
        vigiaModo?.invalidate()
        // Cada tres segundos basta: es una red de seguridad para el cambio de
        // modo mientras la app está abierta, no algo que haya que pillar al
        // vuelo.
        vigiaModo = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            guard let s = self, CNC.pareja.oscuro != nil else { return }
            if s.sistemaOscuro != CNC.tema.oscuro { s.avisarDelModo() }
        }
        vigiaModo?.tolerance = 1.0
    }
    @objc private func avisarDelModo() {
        let oscuro = sistemaOscuro
        // PRIMERO se pinta, con la paleta que la web ya mandó. Esperar a que la
        // web reaccione era lo que obligaba a reiniciar la app: el webview no
        // siempre vuelve a mirar `prefers-color-scheme`, y si no reacciona, no
        // hay tema nuevo que mandar.
        if datos.aplicarModo(oscuro: oscuro) {
            barra.pintar(activa: menuEstado.activa, titulos: menuEstado.titulos)
            contenedorNativo?.backgroundColor = UIColor(CNC.scr)
            view.backgroundColor = UIColor(CNC.scr)
        }
        // Y se le dice a la web, que también tiene que cambiar lo suyo.
        eval("window.__chinolaSistemaOscuro && window.__chinolaSistemaOscuro(\(oscuro))")
        // Antes se pedía el tema tres veces seguidas por si la web tardaba.
        // Se pide una, y sólo se insiste si para entonces la paleta todavía no
        // es la del modo nuevo.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in self?.traerTema() }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            guard let s = self, CNC.tema.oscuro != oscuro else { return }
            s.traerTema()
        }
    }

    /// UN INTERRUPTOR PARA BUSCAR AL CULPABLE.
    ///
    /// La app abre en blanco y el JavaScript de la web nunca llega a correr,
    /// pero con un Capacitor de fábrica sí corre: es algo que hace ESTE
    /// controlador al arrancar. Con esto se puede apagar pieza por pieza en el
    /// simulador —`CN_SIN=flotante,barra,nativo`— y ver con cuál vuelve a
    /// funcionar, en vez de adivinar a base de compilaciones.
    ///
    /// Solo lee una variable de entorno, que en un teléfono de verdad no
    /// existe: fuera de las pruebas, esto siempre devuelve falso.
    private static let apagadas: Set<String> = Set(
        (ProcessInfo.processInfo.environment["CN_SIN"] ?? "")
            .split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty })
    private func sin(_ que: String) -> Bool {
        if Self.apagadas.contains(que) { NSLog("CNSIN: apagado «\(que)»"); return true }
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Partir por la mitad: con esto el controlador no hace NADA más que lo
        // que hace el de fábrica. Si aun así la web no arranca, el problema no
        // está en lo que hace sino en lo que ES: sus propiedades o el registro
        // de plugins. Y si arranca, está aquí dentro y se busca a la mitad.
        if sin("todo") { return }
        // En iOS 17 y más, `traitCollectionDidChange` ya no se llama: hay que
        // apuntarse al cambio. Sin esto, poner el teléfono en oscuro no movía
        // la app hasta reiniciarla.
        if #available(iOS 17.0, *), !sin("traits") {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (vc: ChinolaViewController, _) in
                vc.avisarDelModo()
            }
        }
        // Las tipografías de la marca, antes de pintar nada.
        if !sin("fuentes") { CNFuentes.registrar() }
        // LO DE LA ÚLTIMA VEZ, YA. Antes de preguntarle nada a la web: así la
        // app se ve con datos desde el primer fotograma, y si la web tarda —o
        // no llega— sigues viendo tus cifras en vez de una pantalla vacía.
        if !sin("guardado") { CNDatos.shared.pintaLoDeLaUltimaVez() }
        // Y el tema de la última vez: la primera pantalla sale ya con sus
        // colores, su letra y su moneda.
        if !sin("tema") { datos.temaGuardado() }
        if !sin("acciones") { conectarAcciones() }
        if !sin("avisos") {
        NotificationCenter.default.addObserver(self, selector: #selector(avisarDelModo),
                                               name: UIApplication.didBecomeActiveNotification, object: nil)
        }
        if !sin("orilla") { montarOrilla() }
        // El bloqueo con Face ID: se tapa al irse, se pide al volver.
        NotificationCenter.default.addObserver(self, selector: #selector(alIrse),
                                               name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(alFondo),
                                               name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(alVolver),
                                               name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(bloqueoCambiado(_:)),
                                               name: Notification.Name("cnBloqueoCambiado"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(abrirHojaDeLaWeb),
                                               name: Notification.Name("cnAbrirHoja"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(abrirSelectorDeLaWeb),
                                               name: Notification.Name("cnAbrirSelector"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(abrirPeriodoDeLaWeb),
                                               name: Notification.Name("cnAbrirPeriodo"), object: nil)
        if bloqueoPuesto {
            bloqueada = true
            taparPantalla()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in self?.pedirDesbloqueo() }
        }

        menuEstado.alTocar = { [weak self] id in
            guard let self = self else { return }
            self.menuEstado.activa = id
            self.barra.pintar(activa: id, titulos: self.menuEstado.titulos)
            // A la web SIEMPRE, aunque la pantalla sea nativa: es ella la que
            // calcula el modelo, y solo lo calcula de la vista en la que está.
            // Sin esto, entrar al Resumen nativo viniendo de otra pestaña
            // dejaba el panel vacío, porque la web seguía en la otra.
            self.eval("window.__chinolaMenu && window.__chinolaMenu('\(id)')")
            // Nativa SOLO si hay con qué pintarla: si la web nunca mandó nada,
            // la pantalla nativa es un rectángulo vacío tapando la web que sí
            // está pintada. Ver `redDeSeguridad`.
            if self.nativas.contains(id), CNDatos.shared.llegoAlgo {
                self.mostrarNativo(id)
                self.refrescarPantalla(id)
            } else {
                self.volviendo = false
                // La web se enseña UN POCO DESPUÉS de avisarle de la pestaña.
                // Enseñándola en el mismo instante se veía un momento con lo
                // de la pantalla anterior todavía puesto: arriba salía una
                // franja del color de antes entre la isla y la cabecera, y
                // parecía que la cabecera no llegaba al borde. Mientras tanto
                // se queda lo nativo, que ya está pintado.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { [weak self] in
                    guard let s = self, s.menuEstado.activa == id else { return }
                    s.mostrarWeb()
                }
            }
        }

        if !sin("barra") { montarBarra() }
        // El botón flotante NO se monta al arrancar. Ver `montarFlotante`.
        NotificationCenter.default.addObserver(
            self, selector: #selector(pidenElFlotante),
            name: Notification.Name("cnFlotantePuesto"), object: nil)
        // Si la web no da señales en diez segundos, avisar: la app en blanco no
        // le dice nada a nadie, y su propio cartel queda debajo de lo nativo.
        // Qué tiene dentro el webview cuando no da señales. Distingue «no
        // cargó nada» de «cargó su página y su código falló», que es la
        // diferencia entre buscar en el empaquetado o en el JavaScript.
        CNAvisoDeFallo.shared.estadoDeLaWeb = { [weak self] contar in
            guard let w = self?.bridge?.webView else { contar("no hay webview"); return }
            w.callAsyncJavaScript("try{var e=document.documentElement;var t=document.querySelector('script[src]');var l=['url: '+location.href,'estado: '+document.readyState,'scripts: '+document.scripts.length,'html: '+(e?e.innerHTML.length:-1)+' car.','raiz: '+(document.getElementById('raiz')?'si':'no'),'Capacitor: '+(window.Capacitor?'si':'no'),'por donde va: '+((window.__chinolaEtapas||['NI UNA LINEA']).join(' · '))];if(!t){l.push('script: NINGUNO con src');return l.join('\\n')}l.push('script: '+(t.type||'clasico')+' '+t.src);try{var r=await fetch(t.src);var txt=await r.text();l.push('al pedirlo: '+r.status+' '+(r.headers.get('content-type')||'sin tipo'));l.push('mide: '+txt.length+' car.');}catch(err){l.push('al pedirlo FALLO: '+err)}return l.join('\\n')}catch(e){return 'no se pudo mirar: '+e}", arguments: [:], in: nil, in: .page) { r in
                switch r {
                case .success(let v): contar((v as? String) ?? "contestó algo que no es texto")
                case .failure(let e): contar("no contestó: " + e.localizedDescription)
                }
            }
        }
        CNAvisoDeFallo.shared.laWebSePinto = { [weak self] contar in
            guard let w = self?.bridge?.webView else { contar(false); return }
            w.evaluateJavaScript("(function(){var r=document.getElementById('raiz');return !!(r&&r.children.length)})()") { v, _ in
                contar((v as? Bool) ?? false)
            }
        }
        if !sin("vigia") { CNAvisoDeFallo.shared.vigilar() }
        // Los ajustes de pantalla (la tarjeta de Cuentas, el presupuesto en aro,
        // el estilo de las pestañas) los guarda la WEB, que es lo que hace que
        // sean los mismos en el teléfono, en la web y en la PWA. Antes eran
        // @AppStorage y vivían solo aquí dentro.
        CNC.alPoner = { [weak self] clave, valor in
            guard let s = self else { return }
            let js: String
            switch valor {
            case let b as Bool: js = b ? "true" : "false"
            case let n as Double: js = String(n)
            case let n as Int: js = String(n)
            case let t as String: js = s.comillas(t)
            default: js = s.comillas(String(describing: valor))
            }
            s.eval("window.__chinolaPon && window.__chinolaPon(\(s.comillas(clave)), \(js))")
        }
        if !sin("modo") { vigilarModo() }
        // Lo NATIVO desde el primer fotograma. Sin esto, al abrir se veía el
        // tablero de la WEB hasta que se tocaba una pestaña: la app empezaba
        // enseñando justo lo que ya no usa.
        if !sin("nativo") { mostrarNativo(menuEstado.activa) }
        if !sin("cortina") { montarCortina() }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in self?.traerDatos() }
        // EL PASEO POR LAS PESTAÑAS, PARA EL BANCO DE PRUEBAS.
        //
        // El fallo que dejó la app en blanco vivía en `avisaTemaNativo`, que
        // corre en CADA repintado: o sea, en cada cambio de pantalla. Que la
        // primera pantalla abra no demuestra que navegar funcione, y el
        // simulador no sabe dar toques. Con `CN_CON=paseo` la app se recorre
        // sus cinco pestañas sola y se deja fotografiar.
        //
        // Lee una variable de entorno que en un teléfono de verdad no existe.
        // UNA pantalla por lanzamiento, con `CN_IR=movs`. El paseo por las cinco
        // seguidas obligaba a adivinar cuándo disparar cada foto, y las fotos
        // caían entre medias: salía «Cuentas» donde tenía que salir
        // «Movimientos» y parecía un fallo de la app. Una sola pantalla, quieta,
        // no deja lugar a dudas.
        // QUIÉN SINCRONIZA. A partir de aquí, el teléfono —si tiene con qué—.
        //
        // «Con qué» son dos cosas y las mira `CNAlmacen`: la copia que la web
        // deja escrita en el teléfono y el vale de sesión. Recién instalada la
        // app no hay ninguna de las dos, así que sincroniza la web como siempre;
        // en cuanto entras y la web guarda su copia, el siguiente arranque ya lo
        // lleva el teléfono. El traspaso se hace solo y sin borrar nada.
        //
        // La web lo pregunta una vez (`Nativo.nubeManda`) y deja de hablar con
        // el servidor. El interruptor es UNO: dos escritores de la misma libreta
        // la corrompen en silencio.
        CNNube.encendido = true

        // EL FICHERO DE ORO, ejecutado contra este Swift. Solo en el banco.
        if CNOro.pedido {
            DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) { CNOro.correr() }
        }
        // Y EL CICLO DE SINCRONIZACIÓN ENTERO, contra el servidor del banco.
        //
        // Solo con `CN_SINCRO=1`, que en un teléfono no existe. Mientras la web
        // siga sincronizando, encender esto aquí serían DOS escritores de la
        // misma libreta, y eso la corrompe en silencio: uno sube su versión, el
        // otro sube la suya encima y lo del primero desaparece sin que falle
        // nada. El día que se encienda hay que apagar la web en el mismo cambio.
        if CNNube.pedido {
            DispatchQueue.main.asyncAfter(deadline: .now() + 7.0) {
                Task { await CNNube.correrEnElBanco() }
            }
        }
        if let ir = ProcessInfo.processInfo.environment["CN_IR"], !ir.isEmpty {
            // Y CON DOS PUNTOS, UNA SUBPANTALLA: `CN_IR=perfil:colores`.
            //
            // Perfil tiene TRECE subpantallas y el banco solo sabía cambiar de
            // pestaña, así que ninguna de las trece se fotografiaba nunca. Todo
            // lo que se rompiera dentro —una lista vacía, un bloque que no se
            // dibuja, unos datos que nadie pidió— se quedaba sin ver.
            //
            // Y con arroba, UNA HOJA: `CN_IR=perfil@clave`. Las cinco hojas de
            // Perfil —cambiar el correo, la contraseña, darse de baja— se
            // dibujan nativas y no se habían fotografiado nunca, porque solo se
            // abren tocando su fila.
            if ir.contains("@") {
                let t = ir.split(separator: "@", maxSplits: 1).map(String.init)
                DispatchQueue.main.asyncAfter(deadline: .now() + 9.0) { [weak self] in
                    guard let s = self else { return }
                    NSLog("CNIR: \(t[0]) · hoja \(t[1])")
                    s.menuEstado.alTocar(t[0])
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        s.eval("window.__chinolaAccion && window.__chinolaAccion('hoja',\(s.comillas(t[1])))")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { s.webTemporal() }
                    }
                }
                return
            }
            let partes = ir.split(separator: ":", maxSplits: 1).map(String.init)
            DispatchQueue.main.asyncAfter(deadline: .now() + 9.0) { [weak self] in
                NSLog("CNIR: \(ir)")
                self?.menuEstado.alTocar(partes[0])
                guard partes.count > 1 else { return }
                // Después de la pestaña, para que la subpantalla se abra sobre
                // ella y no sobre la que hubiera antes.
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    NSLog("CNIR: subpantalla \(partes[1])")
                    CNDatos.shared.onAbrirSeccion(partes[1])
                }
            }
        }
        // LA SONDA DEL BOTÓN DE CHINO, para el banco.
        //
        // Con `CN_CON=sonda` se le pregunta a la web, pasados unos segundos,
        // las tres cosas que deciden si el botón está: si la IA está
        // encendida, si el ajuste lo permite y si ya se entró a la app. Sin
        // esto, «no sale el botón» no se puede distinguir de «la web no lo
        // pide» ni de «lo pide y no se monta», que son tres problemas
        // distintos.
        if ProcessInfo.processInfo.environment["CN_CON"]?.contains("sonda") == true {
            // En el banco no se entra a la app, así que el botón nunca llega a
            // ponerse y la mitad de la prueba de los toques —que el botón SÍ
            // reciba los suyos— se quedaba sin hacer. Aquí se pone a mano.
            if ProcessInfo.processInfo.environment["CN_CON"]?.contains("flota") == true {
                DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
                    CNFlotante.shared.puesto = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 12.0) { [weak self] in
                self?.bridge?.webView?.evaluateJavaScript(
                    "(function(){try{var e=window.__chinolaEtapas||[];"
                    + "return JSON.stringify({etapas:e.slice(-4),"
                    + "flotante:(window.__chinolaSondaFlotante&&window.__chinolaSondaFlotante())||'sin sonda'})}"
                    + "catch(x){return 'no se pudo: '+x}})()") { r, _ in
                        NSLog("CNSONDA: \((r as? String) ?? "sin respuesta")")
                        // Y el lado NATIVO: que la web lo pida y que se monte
                        // no basta; puede estar montado y no verse. Esto dice
                        // dónde está, de qué tamaño y si el mando lo da por
                        // puesto.
                        let f = self?.flotanteVista
                        NSLog("CNFLOTA2: vista=\(f == nil ? "NO EXISTE" : "sí") "
                            + "puesto=\(CNFlotante.shared.puesto) "
                            + "x=\(CNFlotante.shared.x) y=\(CNFlotante.shared.y) "
                            + "frame=\(f?.frame ?? .zero) alpha=\(f?.alpha ?? -1) "
                            + "oculta=\(f?.isHidden ?? true) "
                            + "enPantalla=\(f?.window != nil) "
                            + "indice=\(f.flatMap { self?.view.subviews.firstIndex(of: $0) } ?? -1) "
                            + "de=\(self?.view.subviews.count ?? 0)")
                        // Y AHORA LO QUE DE VERDAD IMPORTA: ¿PASAN LOS TOQUES?
                        //
                        // Que compile y que el botón se monte no dice nada de
                        // esto. La capa del botón está a pantalla completa por
                        // encima del webview, así que si se queda los toques
                        // donde no hay nada dibujado, la app entera queda
                        // muerta y solo responde el botón. Ya pasó una vez, y
                        // el banco lo dio por bueno porque compilaba.
                        //
                        // No hace falta un dedo: se le pregunta al propio
                        // sistema de toques quién contestaría en cada punto. Si
                        // contesta la capa del botón donde no hay botón, está
                        // roto.
                        if let yo = self, let caja = f {
                            let ancho = yo.view.bounds.width, alto = yo.view.bounds.height
                            // El centro del botón, calculado como lo calcula la
                            // vista (`CNBotonFlotante`): lado 56, margen 14 y el
                            // hueco de arriba. `ancho * x` caía en el borde de
                            // la pantalla, que no es donde está el botón.
                            let lado: CGFloat = 56, margen: CGFloat = 14
                            let arriba = yo.view.safeAreaInsets.top
                            let bx = margen + (ancho - margen * 2 - lado) * CNFlotante.shared.x + lado / 2
                            let by = arriba + margen + (alto - arriba - margen * 2 - lado) * CNFlotante.shared.y + lado / 2
                            let sitios: [(String, CGPoint)] = [
                                ("centro", CGPoint(x: ancho / 2, y: alto / 2)),
                                ("arriba-izq", CGPoint(x: 40, y: 120)),
                                ("abajo-der", CGPoint(x: ancho - 40, y: alto - 120)),
                                ("donde-el-boton", CGPoint(x: bx, y: by))
                            ]
                            var parte = ""
                            for (nombre, punto) in sitios {
                                let quien = yo.view.hitTest(punto, with: nil)
                                // ¿La respuesta sale de dentro de la caja del
                                // botón, o del webview que hay debajo?
                                var deLaCaja = false
                                var v: UIView? = quien
                                while let x = v { if x === caja { deLaCaja = true; break }; v = x.superview }
                                parte += "\(nombre)=\(deLaCaja ? "CAJA" : "web") "
                            }
                            NSLog("CNTOQUE: boton-puesto=\(CNFlotante.shared.puesto) marco=\(CNFlotante.shared.marco) \(parte)"
                                + "| se espera: web en los tres primeros"
                                + "\(CNFlotante.shared.puesto ? " y CAJA en el del botón" : "")")
                        }
                    }
            }
        }
        // LA RED: que la app NUNCA se quede en una pantalla vacía.
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) { [weak self] in self?.redDeSeguridad() }
        // La puerta (bienvenida, acceso, nombre, plan) también es nativa.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in self?.mirarPuerta() }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if sin("layout") { return }
        barra.ajustar()
        apuntarPestanas()
        avisarAltoBarra()
    }

    /// Dónde está cada pestaña, para que el tour las señale. Los botones de
    /// la UITabBar no tienen nombre público: se cogen por su clase y se
    /// ordenan de izquierda a derecha, que es el orden de las pestañas.
    private func apuntarPestanas() {
        let botones = barra.barra.subviews
            .filter { String(describing: type(of: $0)).contains("TabBarButton") }
            .sorted { $0.frame.minX < $1.frame.minX }
        guard botones.count == CNTabs.todas.count else { return }
        for (i, b) in botones.enumerated() {
            let r = view.convert(b.frame, from: barra.barra)
            CNDatos.shared.apuntaAncla("tab-" + CNTabs.todas[i].id, r)
        }
    }

    // MARK: acciones de las pantallas nativas
    private func conectarAcciones() {
        // Formularios y detalles: NATIVOS (se presentan encima).
        datos.onNuevoMov = { [weak self] in guard let s = self else { return }
            s.presentar(AnyView(CNNuevoMov(datos: s.datos, onClose: { s.cerrar() }))) }
        datos.onDetalleMov = { [weak self] id in
            guard let s = self else { return }
            s.traerMov(id)
            s.presentar(AnyView(CNDetalleMov(datos: s.datos, movId: id, onClose: { s.cerrar() })))
        }
        datos.onMovAccion = { [weak self] tipo in
            guard let s = self else { return }
            s.eval("window.__chinolaMovAccion && window.__chinolaMovAccion(\(s.comillas(tipo)))")
            s.refrescarPronto()
            if tipo == "duplicar" { s.cerrar() }
        }
        datos.onCuentasAccion = { [weak self] tipo, i in
            guard let s = self else { return }
            if tipo == "cuenta" || tipo == "tarjeta" || tipo == "prestamo" {
                // Los detalles ya son nativos: no hace falta pasar por la web.
                let lb = s.datos.libreta
                if tipo == "cuenta", i < lb.cuentas.count { s.datos.onAbrirCuenta(lb.cuentas[i].id); return }
                if tipo == "tarjeta", i < lb.tarjetas.count { s.datos.onAbrirTarjeta(lb.tarjetas[i].id); return }
                if tipo == "prestamo", i < lb.prestamos.count { s.datos.onAbrirPrestamo(lb.prestamos[i].id); return }
                return
            }
            s.eval("window.__chinolaCuentasAccion && window.__chinolaCuentasAccion(\(s.comillas(tipo)),\(i))")
            s.refrescarPronto()
        }
        // Lo que sale al deslizar una fila: marcar la cuenta de siempre,
        // editar o eliminar. Cada una es la MISMA función de la web.
        datos.onFilaAccion = { [weak self] i, donde in
            guard let s = self else { return }
            s.eval("window.__chinolaFilaAccion && window.__chinolaFilaAccion(\(i),\(s.comillas(donde)))")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                // Si lo que se abrió es una hoja (editar), se dibuja nativa.
                s.webTemporal()
                s.traerCuentas(); s.traerPlan(); s.traerDatos(intentos: 3)
            }
        }
        datos.onAbrirCuenta = { [weak self] id in self?.mostrarDetalle("cuenta", "\(id)") }
        datos.onAbrirTarjeta = { [weak self] id in self?.mostrarDetalle("tarjeta", "\(id)") }
        datos.onAbrirPrestamo = { [weak self] id in self?.mostrarDetalle("prestamo", "\(id)") }
        datos.onAbrirMeta = { [weak self] id in self?.mostrarDetalle("meta", "\(id)") }
        // Abonar, aportar y pagar la tarjeta DESDE EL DETALLE, con la hoja del
        // teléfono. Iban por la hoja genérica de la web, que vuelve a
        // preguntar el nombre del préstamo, el sentido y a quién le debes
        // —todo lo que ya está en el préstamo que estás mirando—.
        datos.onHojaDeMonto = { [weak self] que, cual, monto in
            guard let s = self else { return }
            let lb = CNDatos.shared.libreta
            let nombre: String
            switch que {
            case "abono": nombre = lb.prestamos.first { $0.id == cual }?.nombre ?? ""
            case "aporte": nombre = lb.metas.first { $0.id == cual }?.nombre ?? ""
            default: nombre = lb.tarjetas.first { $0.id == cual }?.nombre ?? ""
            }
            var extra: [String: Any] = ["id": cual, "nombre": nombre]
            if que == "pagoTarjeta" { extra["saldo"] = lb.tarjetas.first { $0.id == cual }?.saldo ?? 0 }
            s.presentar(AnyView(CNMontoHoja(datos: s.datos, tipo: que, extra: extra,
                                            onClose: { s.cerrar() }, montoInicial: monto)))
        }
        // «Nuevo gasto aquí» y «Nuevo movimiento» desde un detalle: la hoja del
        // teléfono con lo que esa pantalla ya sabe. Abrían la de la web solo
        // para poder dejarlo puesto.
        datos.onNuevoMovCon = { [weak self] que, valor in
            guard let s = self else { return }
            s.presentar(AnyView(CNNuevoMov(
                datos: s.datos, onClose: { s.cerrar() },
                categoriaInicial: que == "movCat" ? valor : "",
                medioInicial: que == "movMedio" ? valor : "")))
        }
        datos.onDetalleAccion = { [weak self] tipo, i in
            guard let s = self else { return }
            // El chip se marca AQUÍ, sin esperar a la web: tocar un periodo y
            // que no pase nada durante medio segundo es lo que hace que la
            // pantalla se sienta lenta.
            if tipo == "chip" {
                CNDatos.shared.marcarChip(i)
                s.eval("window.__chinolaDetalleAccion && window.__chinolaDetalleAccion(\(s.comillas(tipo)),\(i))")
                for t in [0.12, 0.45] {
                    DispatchQueue.main.asyncAfter(deadline: .now() + t) { s.refrescarDetalle() }
                }
                return
            }
            s.eval("window.__chinolaDetalleAccion && window.__chinolaDetalleAccion(\(s.comillas(tipo)),\(i))")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                // Cambiar de periodo repinta la misma pantalla. Un botón abre
                // una hoja: se dibuja NATIVA y encima del detalle, que se queda
                // donde estaba. Antes se cerraba el detalle y se enseñaba la
                // web de debajo: la pantalla cambiaba de cara y volvía sola al
                // cerrar la hoja.
                if tipo == "chip" { s.refrescarDetalle(); return }
                s.webTemporal(alIrALaWeb: { s.cerrarDetalle() })
            }
        }
        // El Plan: cambiar de pestaña repinta; ver una categoría o una meta
        // abre su detalle NATIVO; crear una sigue en la web.
        datos.onPlanAccion = { [weak self] tipo, i in
            guard let s = self else { return }
            if tipo == "categoria", let f = CNDatos.shared.plan?.filas.first(where: { $0.indice == i }) {
                s.eval("window.__chinolaPlanAccion && window.__chinolaPlanAccion(\(s.comillas(tipo)),\(i))")
                s.mostrarDetalle("categoria", f.nombre)
                return
            }
            if tipo == "meta", let g = CNDatos.shared.plan?.metas.first(where: { $0.indice == i }) {
                s.mostrarDetalle("meta", "\(g.idm)")
                return
            }
            s.eval("window.__chinolaPlanAccion && window.__chinolaPlanAccion(\(s.comillas(tipo)),\(i))")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                s.traerPlan(intentos: 6)
                if tipo != "tab" { s.webTemporal() }
            }
        }
        datos.onAgregar = { [weak self] in guard let s = self else { return }
            s.presentar(AnyView(CNAgregar(datos: s.datos, onClose: { s.cerrar() }))) }
        datos.onNuevaMeta = { [weak self] in guard let s = self else { return }
            s.presentar(AnyView(CNFormMeta(datos: s.datos, onClose: { s.cerrar() }))) }
        datos.onTendencia = { [weak self] in guard let s = self else { return }
            s.presentar(AnyView(CNTendencia(libreta: s.datos.libreta, onClose: { s.cerrar() }))) }

        datos.onAccion = { [weak self] tipo, id in
            guard let s = self else { return }
            let lb = s.datos.libreta
            switch tipo {
            case "nuevo":
                s.presentar(AnyView(CNNuevoMov(datos: s.datos, onClose: { s.cerrar() })))
            case "abono":
                let p = lb.prestamos.first { "\($0.id)" == id }
                s.presentar(AnyView(CNMontoHoja(datos: s.datos, tipo: "abono", extra: ["id": p?.id ?? (Int(id) ?? 0), "nombre": p?.nombre ?? ""], onClose: { s.cerrar() })))
            case "aporte":
                let m = lb.metas.first { "\($0.id)" == id }
                s.presentar(AnyView(CNMontoHoja(datos: s.datos, tipo: "aporte", extra: ["id": m?.id ?? (Int(id) ?? 0), "nombre": m?.nombre ?? ""], onClose: { s.cerrar() })))
            case "pagoTarjeta":
                let t = lb.tarjetas.first { "\($0.id)" == id }
                s.presentar(AnyView(CNMontoHoja(datos: s.datos, tipo: "pagoTarjeta", extra: ["id": t?.id ?? (Int(id) ?? 0), "nombre": t?.nombre ?? "", "saldo": t?.saldo ?? 0], onClose: { s.cerrar() })))
            case "editarMov":
                if let m = lb.tx.first(where: { $0.id == id }) {
                    s.presentar(AnyView(CNNuevoMov(datos: s.datos, onClose: { s.cerrar() }, editar: m)))
                }
            case "transferir":
                s.presentar(AnyView(CNFormTransferencia(datos: s.datos, origen: "cuenta:\(id)", onClose: { s.cerrar() })))
            default:
                s.webTemporal(); s.eval("window.__chinolaAccion && window.__chinolaAccion('\(tipo)','\(id)')")
            }
        }

        // Guardado: reusa la lógica de la web y vuelve a leer los datos.
        datos.onGuardarHoja = { [weak self] tipo, form, extra in
            guard let s = self else { return }
            // Once de las doce las escribe el teléfono. La que devuelve `nil`
            // —el perfil, el correo, los dos pasos, importar, exportar, pagar
            // la tarjeta— sigue siendo de la web, que es donde está su lógica.
            var payload: [String: Any] = ["tipo": tipo, "form": form]
            if let e = extra { payload["extra"] = e }
            if s.telefonoEscribe,
               let nueva = CNEscribir.hoja(CNDatos.shared.libreta, tipo, form, extra,
                                           mes: CNDatos.shared.mesActivo) {
                s.adopta(nueva) { s.aWeb("window.__chinolaGuardarHoja", payload) }
                return
            }
            s.aWeb("window.__chinolaGuardarHoja", payload)
        }
        datos.onCrearMov = { [weak self] dict in
            guard let s = self else { return }
            guard s.telefonoEscribe else { s.aWeb("window.__chinolaCrearMov", dict); return }
            s.adopta(CNEscribir.movimientoNuevo(CNDatos.shared.libreta, dict)) {
                s.aWeb("window.__chinolaCrearMov", dict)
            }
        }
        // Los tres puntos de la charla. Las tres cosas las hace la web, que ya
        // las tenía montadas; aquí solo se le dice cuál.
        datos.onCharlaAccion = { [weak self] que in
            self?.eval("window.__chinolaCharlaMenu && window.__chinolaCharlaMenu(" + (self?.comillas(que) ?? "''") + ")")
        }
        datos.onInvitar = { [weak self] dict in
            guard let s = self else { return }
            s.aWeb("window.__chinolaInvitar", dict)
            // La lista de miembros cambia en cuanto el servidor responde.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                if let id = CNDatos.shared.seccion?.id { s.traerSeccion(id) }
            }
        }
        datos.onCrearLibreta = { [weak self] dict in
            guard let s = self else { return }
            s.aWeb("window.__chinolaCrearLibreta", dict)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                s.traerDatos(intentos: 3); s.traerTema(); s.traerResumen(intentos: 4)
            }
        }
        datos.onMes = { [weak self] dir in
            self?.eval("window.__chinolaMes && window.__chinolaMes(\(dir))")
            self?.refrescarPronto()
        }
        datos.onEmpezar = { [weak self] in self?.webTemporal(); self?.eval("window.__chinolaEmpezar && window.__chinolaEmpezar()") }
        // Organizar el panel es nativo: se va al resumen y entra en «organizar».
        datos.onEditarPanel = { [weak self] in self?.irAOrganizar() }
        // Mientras se organiza, el menú de abajo se atenúa y no responde: lo
        // que hay en pantalla es el panel, y solo el panel.
        datos.onOrganizando = { [weak self] on in
            guard let s = self else { return }
            // EL MENÚ SE VA DEL TODO. Se quedaba al 35 %: translúcido, visible
            // y sin responder, que es lo peor de las dos cosas —parece que la
            // app se ha colgado—. Organizando, la pantalla es el panel y nada
            // más.
            UIView.animate(withDuration: 0.2) { s.barra.barra.alpha = on ? 0 : 1 }
            s.barra.barra.isUserInteractionEnabled = !on
        }
        // Perfil: la fila se dispara por su sitio en la lista.
        //
        // Las filas que abren una SUBPANTALLA no pasan por aquí: llevan su `sec`
        // y van derechas a la de SwiftUI. Por aquí pasan solo las que hacen otra
        // cosa —cambiar el correo, el plan, borrar la cuenta—, y `webTemporal`
        // mira qué dejó abierto: una hoja y una puerta se dibujan nativas, y si
        // no dejó nada, no se enseña la web. El comentario que había aquí decía
        // que abrir una sección enseñaba la web; dejó de ser verdad cuando se
        // mudaron, y un comentario viejo manda buscar el fallo donde no está.
        datos.onAjuste = { [weak self] g, f, valor in
            guard let s = self else { return }
            if let v = valor {
                s.eval("window.__chinolaAjuste && window.__chinolaAjuste(\(g),\(f),\(s.comillas(v)))")
            } else {
                s.webTemporal()
                s.eval("window.__chinolaAjuste && window.__chinolaAjuste(\(g),\(f))")
            }
            s.refrescarPronto()
        }
        // Subpantallas del perfil: se le pide el modelo a la web y se dibuja
        // aquí. La web no cambia de pantalla; solo entrega los datos.
        datos.onAbrirSeccion = { [weak self] id in
            guard let s = self else { return }
            // Una «sección» que empieza por «hoja:» no es una pantalla de
            // ajustes: es un formulario nativo. Hoy solo invitar.
            if id == "importar" { s.pedirCsv(); return }

            // LO QUE PIDEN LAS SUBPANTALLAS ARMADAS AQUÍ.
            //
            // Van por NOMBRE y no por el número de una lista: ese número solo
            // vale si la lista la hizo la web, y estas las hace el teléfono.

            // El bloqueo con Face ID es del aparato: no hay nada que preguntar
            // ni a la web ni al servidor. Se le avisa a la web para que su
            // propia pantalla diga lo mismo.
            // PONER UN AJUSTE POR SU NOMBRE: `pon:panelVivo`, `pon:moneda=EUR`.
            //
            // Sin el `=` es un interruptor y se da la vuelta; con él, un valor.
            // El que manda sigue siendo la web —es la que los guarda y los
            // sincroniza—, así que esto NO escribe nada aquí: se lo dice, y lo
            // que vuelva por el tema es lo que se pinta. Guardando también aquí
            // habría dos copias del mismo ajuste discrepando, que es justo lo
            // que ya pasó una vez.
            // Cambiar el papel de alguien, o quitarlo. Toca la LIBRETA, que
            // tiene un solo dueño —la copia que la web sincroniza—, así que se
            // le pide a ella: aquí no se escribe.
            // El modo de color. Va aparte de `pon:` porque no es UN ajuste:
            // «Automático» toca cuatro a la vez y cada uno tiene su respaldo.
            // Lo decide la MISMA función que usa la web.
            // El icono de la app: se guarda cuál Y se le pide a iOS que lo
            // cambie. Lo segundo es lo único que de verdad lo mueve, y si el
            // teléfono no puede hay que decirlo — antes fallaba en silencio y
            // parecía que el selector no hacía nada.
            if id.hasPrefix("icono:") {
                s.eval("window.__chinolaIconoApp && window.__chinolaIconoApp("
                       + s.comillas(String(id.dropFirst(6))) + ")")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    if let hecha = CNSecciones.arma("icono-app") { s.ponSeccion(hecha, si: "icono-app") }
                }
                return
            }
            if id.hasPrefix("modo:") {
                s.eval("window.__chinolaModoColor && window.__chinolaModoColor("
                       + s.comillas(String(id.dropFirst(5))) + ")")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    if let hecha = CNSecciones.arma("colores") { s.ponSeccion(hecha, si: "colores") }
                }
                return
            }
            if id.hasPrefix("rol:") || id.hasPrefix("quitar:") {
                let quitar = id.hasPrefix("quitar:")
                let resto = String(id.dropFirst(quitar ? 7 : 4))
                let p = resto.split(separator: ":", maxSplits: 2).map(String.init)
                guard p.count >= 2 else { return }
                let rol = p.count > 2 ? p[2] : ""
                s.eval("window.__chinolaMiembro && window.__chinolaMiembro("
                       + s.comillas(quitar ? "quitar" : "rol") + ","
                       + s.comillas(p[0]) + "," + s.comillas(p[1]) + "," + s.comillas(rol) + ")")
                // Y se vuelve a pedir la lista: acaba de cambiar.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    s.refrescarLibretas()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        guard let cual = s.datos.seccion?.id else { return }
                        if let hecha = CNSecciones.arma(cual) { s.ponSeccion(hecha, si: cual) }
                    }
                }
                return
            }
            if id.hasPrefix("pon:") {
                let partes = String(id.dropFirst(4)).split(separator: "=", maxSplits: 1).map(String.init)
                let clave = partes[0]
                // Sin `=` es un interruptor —se pide el contrario del que se
                // está enseñando— y con `=`, un valor. El que se enseña viene
                // del bloque, así que no hay que ir a buscarlo a ningún sitio.
                let valor: String = partes.count > 1
                    ? s.comillas(partes[1])
                    : (CNSecciones.puestoAhora(clave) ? "false" : "true")
                s.eval("window.__chinolaPon && window.__chinolaPon(\(s.comillas(clave)),\(valor))")
                // Y se rearma LA QUE SE ESTÁ MIRANDO en cuanto la web conteste
                // con el tema nuevo. Adivinar cuál es por el nombre del ajuste
                // funciona hasta el día que dos secciones toquen el mismo.
                if let cual = s.datos.seccion?.id {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        if let hecha = CNSecciones.arma(cual) { s.ponSeccion(hecha, si: cual) }
                    }
                }
                return
            }
            if id == "bloqueoBio" {
                let on = !UserDefaults.standard.bool(forKey: "cnBloqueo")
                UserDefaults.standard.set(on, forKey: "cnBloqueo")
                // Puente propio: NO es una preferencia de la cuenta, es del
                // aparato. No sube a la nube ni sigue a nadie de su iPhone a su
                // iPad, y meterlo con las demás sería prometer justo eso.
                s.eval("window.__chinolaBloqueoPuesto && window.__chinolaBloqueoPuesto(" + (on ? "true" : "false") + ")")
                if let hecha = CNSecciones.arma("seguridad") { s.ponSeccion(hecha, si: "seguridad") }
                return
            }

            // Cerrar la sesión de OTRO aparato. Es un dato del servidor y es
            // suyo: aquí sí se escribe, y la libreta sigue sin tocarse.
            if id.hasPrefix("cerrarSesion:") {
                let cual = String(id.dropFirst("cerrarSesion:".count))
                Task { @MainActor in
                    _ = await CNApi.intenta("/sesiones/" + cual, metodo: "DELETE")
                    // Y se vuelve a preguntar: la lista de aparatos acaba de
                    // cambiar, y dejar el que se cerró en pantalla es peor que
                    // esperar medio segundo.
                    CNSecciones.olvida("/sesiones")
                    if let r = await CNApi.intenta("/sesiones") {
                        CNSecciones.delServidor["/sesiones"] = r
                        if let hecha = CNSecciones.arma("seguridad") { s.ponSeccion(hecha, si: "seguridad") }
                    }
                }
                return
            }
            if id == "organizar" { s.irAOrganizar(); return }
            if id == "charla" { s.abrirCharla(); return }
            // Cambiar de plan: es la puerta, que ya se dibuja nativa. Se le pide
            // a la web que se ponga en ese paso y se abre.
            if id == "plan" {
                s.eval("window.__chinolaPlan && window.__chinolaPlan()")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { s.webTemporal() }
                return
            }
            // Nueva libreta desde «Libretas y permisos»: el mismo camino que el
            // «+» del selector (aviso de plan incluido).
            if id == "hoja:libreta-nueva" { s.datos.onLibreta("nueva", 0); return }
            // Editar una libreta: la web la deja preparada y el mismo
            // formulario de «nueva» se abre con sus valores.
            if id.hasPrefix("hoja:libreta:") {
                let lid = String(id.dropFirst("hoja:libreta:".count))
                s.eval("window.__chinolaEditarLibreta && window.__chinolaEditarLibreta(\(s.comillas(lid)))")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    s.bridge?.webView?.evaluateJavaScript("(window.__chinolaLibretaNuevaJSON && window.__chinolaLibretaNuevaJSON()) || ''") { res, _ in
                        if let json = res as? String, json.count > 2 { CNDatos.shared.cargarLibretaNueva(json: json) }
                        s.presentar(AnyView(CNFormLibreta(datos: s.datos, onClose: {
                            // Al cerrar (guardado o no) la web suelta la edición y
                            // la pantalla de la libreta se repinta con lo nuevo.
                            s.eval("window.__chinolaEditarLibreta && window.__chinolaEditarLibreta('')")
                            s.cerrar()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                if let sid = CNDatos.shared.seccion?.id { s.traerSeccion(sid) }
                                s.traerDatos(intentos: 2)
                            }
                        })))
                    }
                }
                return
            }
            // CUALQUIER OTRA HOJA, POR SU NOMBRE: «hoja:clave», «hoja:perfil».
            //
            // Las subpantallas que arma el teléfono abren hojas —cambiar la
            // contraseña, el correo, darse de baja— y aquí solo se entendían
            // tres formas concretas. Las demás caían en el camino genérico y
            // pedían una SUBPANTALLA llamada «hoja:clave», que no existe: la
            // pantalla se quedaba en blanco y no había error en ninguna parte.
            //
            // Va después de las tres concretas a propósito: esas abren
            // formularios nativos y tienen su propio camino.
            if id.hasPrefix("hoja:") && !id.hasPrefix("hoja:invitar:")
                && !id.hasPrefix("hoja:libreta") {
                let cual = String(id.dropFirst(5))
                guard !cual.isEmpty else { return }
                s.eval("window.__chinolaAccion && window.__chinolaAccion('hoja',\(s.comillas(cual)))")
                // Y se enseña lo que la web haya abierto: una hoja se dibuja
                // nativa con `CNHojaWebViva`, y la puerta con la suya.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { s.webTemporal() }
                return
            }
            if id.hasPrefix("hoja:invitar:") {
                let lid = String(id.dropFirst("hoja:invitar:".count))
                s.bridge?.webView?.evaluateJavaScript("(window.__chinolaInvitarJSON && window.__chinolaInvitarJSON()) || ''") { res, _ in
                    if let json = res as? String, json.count > 2 { CNDatos.shared.cargarInvitar(json: json) }
                    s.presentar(AnyView(CNFormInvitar(datos: s.datos, libreta: lid, onClose: { s.cerrar() })))
                }
                return
            }
            // LO DE LA VEZ PASADA, MIENTRAS LLEGA LO DE AHORA.
            //
            // Esto se vaciaba: la subpantalla se enseña en cuanto `seccion`
            // deja de ser nula, y dejando la anterior puesta se veía ESA hasta
            // que llegaba la nueva — la de otra pantalla, que es peor. Pero
            // vaciar deja la pantalla en blanco mientras la web arma, y eso es
            // el salto raro al entrar.
            //
            // La tercera opción es la buena: si esta subpantalla ya se vio, se
            // pone la suya de la vez pasada. Es la misma pantalla con los
            // mismos valores, así que la transición tiene qué animar y lo que
            // llega encima no se nota. Si no se vio nunca, se vacía como antes.
            // Y ANTES DE NADA, QUE NO QUEDE UNA HOJA FANTASMA EN LA WEB.
            //
            // Una subpantalla se abre desde la lista de ajustes, donde no puede
            // haber ninguna hoja puesta. Si la web cree que sí —porque se
            // cerró deslizándola y no se enteró— pasan dos cosas, las dos
            // malas: cualquier toque la vuelve a enseñar, y `vigilarVuelta` deja
            // de devolver a lo nativo porque siempre le dicen que hay algo
            // abierto. Es la misma hoja fantasma, y esto la barre.
            if s.presentedViewController == nil {
                s.eval("window.__chinolaHojaCerrar && window.__chinolaHojaCerrar()")
            }
            if s.datos.seccion?.id != id { s.datos.seccion = s.datos.seccionesVistas[id] }
            s.datos.seccionPedida = id
            s.traerSeccion(id)
            // Y LO QUE ESTA SUBPANTALLA LE PIDE AL SERVIDOR.
            //
            // Eso vivía dentro de `irSeccion`, que es la navegación de la WEB y
            // aquí no se llama nunca: «Seguridad», «Integraciones» y «Dos
            // pasos» salían con lo que hubiera de antes, y recién abierta la app
            // eso es NADA. Se veía «no tienes ninguna clave» teniendo tres.
            //
            // Va aquí y no en `traerSeccion` porque ese se llama también al
            // refrescar y al precargar las doce de golpe: sería una llamada al
            // servidor por cada interruptor que alguien toque.
            // ¿ESTA LA SABE ARMAR EL TELÉFONO? Entonces se le pide al servidor
            // directamente, que es como funciona una app normal: lo que vive
            // solo en el servidor no tiene por qué pasar por la web.
            if CNSecciones.sabeArmar(id) {
                // «Libretas y permisos» se arma con la lista de libretas, y esa
                // solo se pedía al abrir el SELECTOR. Entrando por Perfil no la
                // pedía nadie, así que la sección nativa se quedaba sin datos y
                // caía a la de la web — escrita, probada y sin usarse jamás.
                if id == "libretas" || id.hasPrefix("libreta:") { s.refrescarLibretas() }
                Task { @MainActor in
                    // Lo que ya se supiera se enseña mientras llega lo nuevo: es
                    // la misma pantalla con los mismos valores, así que lo que
                    // llegue encima no se nota.
                    if let ya = CNSecciones.arma(id) { s.ponSeccion(ya, si: id) }
                    // Las rutas A LA VEZ. En serie, «Seguridad» —que pide tres—
                    // tardaría el triple sin ganar nada.
                    let rutas = CNSecciones.rutasDe(id)
                    await withTaskGroup(of: (String, [String: Any]?).self) { grupo in
                        for r in rutas { grupo.addTask { (r, await CNApi.intenta(r)) } }
                        for await (r, datos) in grupo where datos != nil {
                            CNSecciones.delServidor[r] = datos
                        }
                    }
                    if let hecha = CNSecciones.arma(id) { s.ponSeccion(hecha, si: id) }
                }
            }
            s.eval("window.__chinolaSeccionEntrar && window.__chinolaSeccionEntrar(\(s.comillas(id)))")
            // Cuando el servidor conteste, la web rearma la sección: se vuelve
            // a pedir el modelo para recogerlo. Dos veces, porque la respuesta
            // puede tardar más que la primera.
            for espera in [0.5, 1.4] {
                DispatchQueue.main.asyncAfter(deadline: .now() + espera) { [weak s] in
                    guard let s = s, s.datos.seccion?.id == id else { return }
                    s.traerSeccion(id)
                }
            }
        }
        datos.onSeccionAccion = { [weak self] i, valor in
            guard let s = self, let id = CNDatos.shared.seccion?.id else { return }
            // Con el id de la sección: la web guarda las acciones por sección
            // y así el número apunta a la fila que se tocó, no a la de la
            // última sección que se pidió.
            let arg = valor.map { s.comillas($0) } ?? "undefined"
            // LA RESPUESTA VIENE EN LA MISMA LLAMADA.
            //
            // Esto esperaba un cuarto de segundo y preguntaba después si se
            // había abierto una hoja, porque no había forma de saberlo en el
            // momento. Un cuarto de segundo muerto en CADA toque de Perfil, se
            // abriera hoja o no — y eso, tocando ajustes seguidos, es lo que
            // hace que la pantalla se sienta pegajosa.
            //
            // Ahora la propia acción contesta si dejó una hoja abierta, así que
            // el caso normal —un interruptor, una opción— se resuelve sin
            // esperar nada.
            s.eval("window.__chinolaSeccionAccion ? window.__chinolaSeccionAccion(\(i),\(arg),\(s.comillas(id))) : false") { r in
                if (r as? Bool) == true {
                    // La sección se queda debajo: si lo que se abrió es una
                    // hoja, se dibuja nativa encima y al guardar se vuelve.
                    s.webTemporal()
                    return
                }
                s.traerSeccion(id)
                s.traerAjustes(); s.traerTema(); s.traerSeccionesDePerfil()
                // «Mi plan» cambia de paso sin abrir hoja: es la puerta.
                s.mirarPuerta(intentos: 2)
                // Y UN REPASO TARDÍO, solo para las que tardan. Las que hablan
                // con el servidor abren su hoja después de contestar, y sin
                // esto se quedarían sin enseñarla.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    s.bridge?.webView?.evaluateJavaScript("!!(window.__chinolaHayHoja && window.__chinolaHayHoja())") { r2, _ in
                        if (r2 as? Bool) == true { s.webTemporal() } else { s.traerSeccion(id) }
                    }
                }
            }
        }
        datos.onHojaCampo = { [weak self] i, valor, que in
            guard let s = self else { return }
            s.eval("window.__chinolaHojaCampo && window.__chinolaHojaCampo(\(i),\(s.comillas(valor)),\(s.comillas(que)))")
            // Al elegir color, icono u opción la hoja cambia de aspecto; al
            // escribir no hace falta repintar (el campo ya lleva lo escrito).
            if !que.isEmpty || valor.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { s.refrescarHojaWeb() }
            }
        }
        datos.onHojaEnviar = { [weak self] in
            guard let s = self else { return }
            s.eval("window.__chinolaHojaEnviar && window.__chinolaHojaEnviar()")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { s.refrescarHojaWeb() }
        }
        datos.onPlan = { [weak self] in self?.webTemporal(); self?.eval("window.__chinolaPlan && window.__chinolaPlan()") }
        datos.onPanel = { [weak self] op, id, valor in
            self?.aWeb("window.__chinolaPanel", ["op": op, "id": id, "valor": valor])
        }
        // El periodo tiene su propia hoja NATIVA: se abre en la web (para que
        // su estado sea el de siempre) y se dibuja aquí.
        datos.onCalendario = { [weak self] in
            guard let s = self else { return }
            s.eval("window.__chinolaCalendario && window.__chinolaCalendario()")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { s.abrirPeriodo() }
        }
        datos.onPeriodo = { [weak self] tipo, i in
            guard let s = self else { return }
            s.eval("window.__chinolaPeriodo && window.__chinolaPeriodo(\(s.comillas(tipo)),\(i))")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                if tipo == "aplicar" || tipo == "cerrar" {
                    s.cerrarPeriodo()
                } else {
                    s.refrescarPeriodo()
                }
            }
        }
        datos.onMesTira = { [weak self] i in
            guard let s = self else { return }
            s.eval("window.__chinolaMesTira && window.__chinolaMesTira(\(i))")
            s.refrescarPronto()
            // «Rango…» no cambia de mes: abre el calendario. Si la web lo abrió,
            // se dibuja la hoja NATIVA del periodo. Antes no pasaba nada.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                s.bridge?.webView?.evaluateJavaScript("(window.__chinolaPeriodoJSON && window.__chinolaPeriodoJSON()) || ''") { res, _ in
                    guard let json = res as? String, json.count > 2, let p = CNPeriodo.desde(json: json), p.abierto else { return }
                    CNDatos.shared.cargarPeriodo(json: json)
                    s.abrirPeriodo()
                }
            }
        }
        datos.onPlegar = { [weak self] in
            self?.eval("window.__chinolaPliega && window.__chinolaPliega()")
            self?.refrescarPronto()
        }
        datos.onVerPresupuesto = { [weak self] in
            guard let s = self else { return }
            s.menuEstado.activa = "plan"; s.barra.pintar(activa: "plan", titulos: s.menuEstado.titulos)
            s.mostrarNativo("plan")
        }
        datos.onLimiteCategoria = { [weak self] nombre, limite in
            self?.aWeb("window.__chinolaLimiteCategoria", ["nombre": nombre, "limite": limite])
        }
        // Editar uno: por aquí el teléfono lo hace MEJOR que la web, no solo
        // igual. `guardarTx` rehace el movimiento entero, así que un aporte o
        // un abono editado pierde su marca —`meta`, `prestamo`— y borrarlo
        // luego devuelve el dinero sin bajar lo ahorrado. `movimientoCambiado`
        // deja quieto lo que no se dice.
        datos.onEditarMov = { [weak self] dict in
            guard let s = self else { return }
            guard s.telefonoEscribe else { s.aWeb("window.__chinolaEditarMov", dict); return }
            s.adopta(CNEscribir.movimientoCambiado(CNDatos.shared.libreta, dict)) {
                s.aWeb("window.__chinolaEditarMov", dict)
            }
        }
        datos.onBorrarMov = { [weak self] id in
            guard let s = self else { return }
            guard s.telefonoEscribe else {
                s.eval("window.__chinolaBorrarMov && window.__chinolaBorrarMov('\(id)')")
                s.refrescarPronto()
                return
            }
            // Borrar uno que no existe devuelve la misma libreta: no se manda
            // nada, que es distinto de mandar una libreta igual.
            let nueva = CNEscribir.movimientoBorrado(CNDatos.shared.libreta, id)
            guard nueva.tx.count != CNDatos.shared.libreta.tx.count else { return }
            s.adopta(nueva) {
                s.eval("window.__chinolaBorrarMov && window.__chinolaBorrarMov('\(id)')")
                s.refrescarPronto()
            }
        }
        // Lo que aún vive en la web.
        datos.onNuevaCategoria = { [weak self] in self?.webTemporal(); self?.eval("window.__chinolaNuevaCategoria && window.__chinolaNuevaCategoria()") }
        datos.onPerfil = { [weak self] id in self?.webTemporal(); self?.eval("window.__chinolaPerfil && window.__chinolaPerfil('\(id)')") }
        // Las hojas de «Acerca de». Van por el mismo camino que las demás
        // hojas de la web, que es quien las sabe dibujar.
        datos.onPerfilHoja = { [weak self] cual in
            guard let s = self else { return }
            s.webTemporal()
            s.eval("window.__chinolaAccion && window.__chinolaAccion('hoja',\(s.comillas(cual)))")
        }
        // El selector de libretas ya no enseña la web por detrás: se pide la
        // lista y se dibuja en una hoja nativa encima de la pantalla que había.
        datos.onSelector = { [weak self] in
            guard let s = self else { return }
            s.abrirLibretas()
            // Red de seguridad: si la lista no llegó (la web aún no publicó el
            // puente), se hace lo de siempre en vez de quedarse en nada.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                guard s.libretasVC == nil || CNDatos.shared.libretas == nil else { return }
                s.cerrarLibretas()
                s.eval("window.__chinolaSelector && window.__chinolaSelector()")
                s.webTemporal()
            }
        }
        datos.onLibreta = { [weak self] que, i in
            guard let s = self else { return }
            if que == "nueva" {
                // Nueva libreta, en nativo: se cierra el selector y se abre la
                // hoja con los tipos, colores e iconos que manda la web. Si el
                // plan no da para otra, la web contesta «plan» y lo que se
                // abre es la pantalla de planes, con su aviso.
                s.cerrarLibretas()
                s.bridge?.webView?.evaluateJavaScript("(window.__chinolaLibretaAccion && window.__chinolaLibretaAccion('nueva',0)) || ''") { r, _ in
                    if (r as? String) == "plan" {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { s.mirarPuerta(intentos: 3) }
                        return
                    }
                    s.bridge?.webView?.evaluateJavaScript("(window.__chinolaLibretaNuevaJSON && window.__chinolaLibretaNuevaJSON()) || ''") { res, _ in
                        if let json = res as? String, json.count > 2 { CNDatos.shared.cargarLibretaNueva(json: json) }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            s.presentar(AnyView(CNFormLibreta(datos: s.datos, onClose: { s.cerrar() })))
                        }
                    }
                }
                return
            }
            s.eval("window.__chinolaLibretaAccion && window.__chinolaLibretaAccion(\(s.comillas(que)),\(i))")
            if que == "elegir" {
                s.cerrarLibretas()
                s.traerDatos(intentos: 3); s.traerTema()
                s.traerResumen(intentos: 4); s.traerCuentas(); s.traerPlan()
            } else {
                s.cerrarLibretas()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    s.mostrarNativo("perfil")
                    s.traerSeccion("libretas")
                }
            }
        }
    }

    /// Llama a una función de la web con un objeto y luego relee los datos.
    /**
     * ¿ESCRIBE EL TELÉFONO?
     *
     * Hasta ahora el nativo dibujaba el formulario y la web escribía: los
     * campos iban por el puente y era `app.js` quien tocaba la libreta. Es la
     * atadura que impide quitar el webview, porque mientras el que escribe sea
     * la web, la web tiene que estar viva.
     *
     * Con esto escribe el teléfono. La web sigue GUARDANDO —el almacén y la
     * nube son suyos— y sigue volviendo a dibujar las pantallas nativas: lo que
     * cambia es quién CALCULA, que es lo que está comparado contra ella en
     * `test/calculo-oro.json`.
     *
     * Y una condición: la libreta nativa tiene que haber LLEGADO. Escribir
     * sobre una vacía la vaciaría de verdad, y esa es la única forma de perder
     * datos por aquí.
     */
    private var telefonoEscribe: Bool {
        let l = CNDatos.shared.libreta
        return !sin("escribir") && !l.sinLlegar && !l.dudoso
    }

    /// Lo que escribió el teléfono, de vuelta a la web.
    ///
    /// Se devuelve la libreta ENTERA y no la operación: así un solo camino vale
    /// para las once, y quien la recibe no tiene que saber qué tocó cada una.
    /// Al otro lado se adoptan las listas UNA POR UNA, porque la libreta lleva
    /// cosas que aquí no se leen —el panel, los miembros, las invitaciones— y
    /// mandar un JSON hecho desde este modelo las borraría.
    private func adopta(_ l: CNLibreta, siNo: @escaping () -> Void) {
        // PRIMERO SE EMPAQUETA Y LUEGO SE PINTA, aunque parezca al revés.
        //
        // `JSONSerialization` se niega con un número que no es número —un saldo
        // que saliera NaN— y devolvería aquí sin avisar. Pintando antes, la
        // pantalla enseñaría un movimiento que la web no tiene y que se
        // desvanece en el siguiente refresco. Así, si no se puede empaquetar,
        // no ha pasado nada.
        guard let d = try? JSONSerialization.data(withJSONObject: l.aDiccionario()),
              let json = String(data: d, encoding: .utf8) else { siNo(); return }
        // Y SOBRE QUÉ SE ESCRIBIÓ. Esto es lo que evita borrar sin enterarse.
        //
        // El teléfono calcula encima de la copia que se trajo la última vez. Si
        // la web tiene algo que esa copia no —Chino anota por el servidor, otro
        // equipo sincroniza— mandarle la libreta entera se lo lleva por
        // delante. Y no se ve: al sincronizar, un movimiento que está arriba y
        // no abajo cuenta como que LO BORRASTE TÚ, y la fusión lo quita también
        // del servidor.
        //
        // Así que va la huella de la copia sobre la que se calculó, y la web
        // solo adopta si sigue siendo la suya. Si no, escribe ella sobre lo
        // suyo, que es exactamente lo que se hacía antes de todo esto.
        let base = huellaLibreta
        eval("(window.__chinolaAdoptaLibreta && window.__chinolaAdoptaLibreta(\(comillas(json)), \(comillas(base)))) || ''") { [weak self] r in
            guard let s = self else { return }
            guard let nueva = r as? String, !nueva.isEmpty else {
                NSLog("CNADOPTA: la web tenía algo que el teléfono no · escribe ella")
                siNo()
                return
            }
            // Aceptada: en pantalla al momento y la huella al día, porque la
            // próxima escritura se compara contra esta.
            CNDatos.shared.libreta = l
            s.huellaLibreta = nueva
            s.refrescarPronto()
        }
    }

    private func aWeb(_ fn: String, _ obj: [String: Any]) {
        guard let d = try? JSONSerialization.data(withJSONObject: obj),
              let json = String(data: d, encoding: .utf8) else { return }
        eval("\(fn) && \(fn)(\(json))")
        refrescarPronto()
    }
    /// El dibujo de Chino y los pagos que vienen, para el icono del perfil.
    /// EL SELLO DEL DIBUJO. Dice qué Chino toca sin mandar el dibujo.
    private var selloMascota = ""

    /// Los avisos de Chino, y su dibujo SOLO si cambió.
    ///
    /// El dibujo son 49 KB en base64 y esto se llama en cada refresco —y otra
    /// vez un segundo después—. El personaje cambia cuando lo cambias tú o
    /// cuando cambia el ánimo del mes: no en cada toque de pestaña. Se pregunta
    /// primero cuál toca (unos caracteres) y solo se pide el dibujo cuando de
    /// verdad es otro.
    fileprivate func traerMascota() {
        bridge?.webView?.evaluateJavaScript("(window.__chinolaMascotaSello && window.__chinolaMascotaSello()) || ''") { [weak self] res, _ in
            guard let s = self else { return }
            let sello = (res as? String) ?? ""
            // Sin sello (una web vieja) se pide con dibujo, como siempre.
            let conDibujo = sello.isEmpty || sello != s.selloMascota || CNDatos.shared.mascota?.chinolo.isEmpty != false
            if !sello.isEmpty { s.selloMascota = sello }
            s.bridge?.webView?.evaluateJavaScript("(window.__chinolaMascotaJSON && window.__chinolaMascotaJSON(\(conDibujo))) || ''") { r2, _ in
                guard let json = r2 as? String, json.count > 2 else { return }
                CNDatos.shared.cargarMascota(json: json)
                // Y al menú: el icono de Perfil es Chino.
                s.barra.ponerChinolo(CNDatos.shared.mascota?.chinolo ?? "")
            }
        }
    }

    /// El modelo de UNA pantalla, en cuanto se entra en ella. La web tarda un
    /// pintado en tener listo lo suyo, así que se pide dos veces.
    /// ¿Ya tiene el nativo el modelo de esa pantalla? El resumen lo dice él
    /// mismo con su `listo` (la web lo marca cuando sus tarjetas están); las
    /// demás, con haberlo recibido.
    private func pantallaLista(_ id: String) -> Bool {
        switch id {
        case "resumen": return CNDatos.shared.resumen?.listo == true
        case "cuentas": return CNDatos.shared.cuentas?.listo == true
        case "plan": return CNDatos.shared.plan?.listo == true
        case "perfil": return CNDatos.shared.ajustes != nil
        default: return false
        }
    }

    private func refrescarPantalla(_ id: String) {
        let pedir = { [weak self] in
            guard let s = self else { return }
            switch id {
            case "resumen": s.traerResumen(intentos: 6)
            case "cuentas": s.traerCuentas()
            case "plan": s.traerPlan(intentos: 6)
            case "perfil": s.traerAjustes(); s.traerMascota(); s.traerSeccionesDePerfil()
            default: s.traerDatos(intentos: 3)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12, execute: pedir)
        // La segunda sólo si la primera no trajo nada. Antes salía siempre, y
        // eso serializaba el modelo entero de la pantalla dos veces en cada
        // toque de pestaña, también cuando la primera ya lo había traído todo.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            guard let s = self, !s.pantallaLista(id) else { return }
            pedir()
        }
    }

    private func refrescarPronto() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            self?.traerDatos(intentos: 3)
            self?.traerResumen(intentos: 4)
            self?.traerAjustes()
            self?.traerCuentas()
            self?.traerPlan()
            self?.traerMascota()
            // Y LA PANTALLA QUE ESTÁS MIRANDO.
            //
            // Se refrescaban las cinco de siempre y NO el detalle abierto, así
            // que abonabas a un préstamo, el abono se guardaba bien… y la
            // pantalla seguía enseñando lo de antes hasta que salías y volvías
            // a entrar. Lo que se queda sin refrescar es justo lo que tienes
            // delante.
            self?.refrescarDetalle()
            // ¿Se cerró la sesión? La web lo sabe; lo nativo tiene que
            // enterarse o se queda con pantallas vacías y sin salida. Pasó:
            // cerrar sesión dejaba la app por dentro, sin puerta.
            self?.mirarPuerta(intentos: 1)
        }
    }

    /// Un texto listo para meter en una llamada de JavaScript.
    private func comillas(_ t: String) -> String {
        (try? JSONSerialization.data(withJSONObject: [t])).flatMap {
            String(data: $0, encoding: .utf8).map { String($0.dropFirst().dropLast()) }
        } ?? "\"\""
    }

    private func eval(_ js: String) {
        // Sospechoso: el controlador habla con el webview MUY pronto —desde
        // `viewDidLayoutSubviews`, que dispara antes de que la página haya
        // corrido nada—. Con el interruptor se puede callar del todo y ver si
        // el módulo arranca entonces.
        if sin("eval") { return }
        bridge?.webView?.evaluateJavaScript(js, completionHandler: nil)
    }

    /// El mismo, pero esperando lo que conteste. Es lo que deja resolver en una
    /// sola llamada lo que antes costaba una espera a ciegas y una pregunta.
    private func eval(_ js: String, _ luego: @escaping (Any?) -> Void) {
        if sin("eval") { luego(nil); return }
        guard let w = bridge?.webView else { luego(nil); return }
        w.evaluateJavaScript(js) { r, _ in DispatchQueue.main.async { luego(r) } }
    }

    /// LEE los datos directamente del webview (sin plugin). El empuje por el
    /// plugin puede perderse en silencio; esto los trae y los carga seguro.
    /// La huella de la última libreta traída. Si no cambió, no hay nada que
    /// volver a traer.
    private var huellaLibreta = ""

    /// LA LIBRETA, SOLO SI CAMBIÓ.
    ///
    /// `traerDatos` convierte a texto la libreta ENTERA al otro lado, la manda
    /// por el puente y la vuelve a leer aquí, y además encadena otras seis
    /// llamadas. Eso pasaba en cada toque de pestaña, justo mientras entraba
    /// la pantalla nueva y con el hilo principal ocupado: era la causa de que
    /// las transiciones se sintieran pesadas. Ahora se pregunta primero por una
    /// huella barata —largos de lista y un par de ids— y solo se trae la
    /// libreta si de verdad es otra.
    private func traerDatosSiCambio() { traerDatos() }

    /// LA LIBRETA, SOLO SI CAMBIÓ.
    ///
    /// `traerDatos` se llama desde veinte sitios —cambiar de pestaña, volver de
    /// una hoja, despertar la app, guardar algo— y cada llamada serializaba la
    /// libreta ENTERA, la mandaba por el puente en texto y la decodificaba
    /// aquí. Medido con dos años de movimientos: 153 KB por viaje. Serializar
    /// cuesta poco (0,26 ms); lo caro es el viaje y el decodificado, y se hacía
    /// aunque no hubiera cambiado ni una coma.
    ///
    /// La huella ya existía y cuesta 0,1 KB, pero solo la usaban dos de las
    /// veinte llamadas. Ahora la usan todas: se pregunta primero, y los 153 KB
    /// solo viajan cuando de verdad hay algo nuevo. Lo demás —el tema, el
    /// resumen, las cuentas, el plan— se refresca igual, porque eso sí cambia
    /// sin que cambie la libreta (al cambiar de mes, por ejemplo) y es barato.
    private func traerDatos(intentos: Int = 8) {
        bridge?.webView?.evaluateJavaScript("(window.__chinolaHuella && window.__chinolaHuella()) || ''") { [weak self] res, _ in
            guard let s = self else { return }
            let h = (res as? String) ?? ""
            // Sin huella (una web vieja, o todavía arrancando) se hace lo de
            // siempre: más vale traerla de más que quedarse sin ella.
            if !h.isEmpty, h == s.huellaLibreta, CNDatos.shared.llegoAlgo {
                if ProcessInfo.processInfo.environment["CN_CON"]?.contains("cronometro") == true {
                    NSLog("CNRELOJ: la libreta no cambió · 0 KB por el puente")
                }
                s.refrescarLoDeLaPantalla()
                return
            }
            s.traerLibretaEntera(intentos: intentos)
        }
    }

    /// Uno a la vez: al arrancar, `traerDatos` se llama desde varios sitios
    /// casi a la vez y la huella se fija DESPUÉS de que llegue la libreta, así
    /// que dos llamadas veían la huella vieja y la libreta entera hacía el
    /// viaje dos veces. Medido en el simulador: 139 ms y 220 ms para traer lo
    /// mismo.
    private var pidiendoLibreta = false

    /// Los 153 KB. Solo lo llama `traerDatos`, y solo cuando hace falta.
    private func traerLibretaEntera(intentos: Int = 8) {
        guard !pidiendoLibreta else { return }
        pidiendoLibreta = true
        // Y con salida: si el webview no contesta nunca, esta bandera se
        // quedaría puesta para siempre y la libreta no volvería a pedirse. Hoy
        // ya me costó un día una espera que no vencía nunca.
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in self?.pidiendoLibreta = false }
        let t0 = Date()
        // La huella VIENE EN EL MISMO VIAJE, delante y separada por un carácter
        // que no aparece en JSON. Pedirla aparte dejaba un hueco en el que la
        // siguiente llamada la veía vieja y se traía la libreta otra vez.
        let js = "(function(){var h=(window.__chinolaHuella&&window.__chinolaHuella())||'';"
            + "var d=(window.__chinolaDatosJSON&&window.__chinolaDatosJSON())||'';"
            + "return h+String.fromCharCode(1)+d})()"
        bridge?.webView?.evaluateJavaScript(js) { [weak self] res, _ in
            guard let self = self else { return }
            self.pidiendoLibreta = false
            let crudo = (res as? String) ?? ""
            let corte = crudo.firstIndex(of: "\u{1}")
            let huella = corte.map { String(crudo[crudo.startIndex..<$0]) } ?? ""
            let json = corte.map { String(crudo[crudo.index(after: $0)...]) } ?? crudo
            if ProcessInfo.processInfo.environment["CN_CON"]?.contains("cronometro") == true {
                NSLog("CNRELOJ: la libreta entera · %.0f ms · %d KB", Date().timeIntervalSince(t0) * 1000, json.count / 1024)
            }
            if json.count > 2, let l = CNLibreta.desde(json: json) {
                CNDatos.shared.libreta = l
                CNDatos.shared.guardaLaLibreta(json)
                CNDatos.shared.apuntaQueLlego()
                if !huella.isEmpty { self.huellaLibreta = huella }
                self.bridge?.webView?.evaluateJavaScript("(window.__chinolaPerfilJSON && window.__chinolaPerfilJSON()) || ''") { p, _ in
                    if let ps = p as? String, ps.count > 2 { CNDatos.shared.cargarPerfil(json: ps) }
                }
                self.quitarCortina()
                self.refrescarLoDeLaPantalla()
                // El dibujo de Chino tarda un poco en estar en PNG: se pide
                // ahora y otra vez un segundo después.
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { self.traerMascota() }
                return
            }
            guard intentos > 1 else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { self.traerLibretaEntera(intentos: intentos - 1) }
        }
    }

    /// Lo que cambia sin que cambie la libreta: el mes elegido, los colores,
    /// los ajustes. Todo esto son modelos ya calculados y pequeños —entre 3 y
    /// 9 KB—, así que pedirlos siempre no cuesta nada.
    ///
    /// Solo el de la pantalla que se está viendo. Antes se pedían los cinco en
    /// cada refresco —29 KB— aunque cuatro no se fueran a enseñar; con este
    /// corte quedan entre 6 y 15 KB. Las demás se piden solas al entrar en
    /// ellas, que para eso está `refrescarPantalla`.
    ///
    /// El tema sí va siempre: lo usan la barra de abajo y el modo claro u
    /// oscuro del sistema, que se ven estés donde estés.
    private func refrescarLoDeLaPantalla() {
        traerTema()
        traerMascota()          // barato: solo el sello si el dibujo no cambió
        switch menuEstado.activa {
        case "resumen": traerResumen(intentos: 6)
        case "cuentas": traerCuentas()
        case "plan": traerPlan()
        case "perfil": traerAjustes()
        default: break          // «movs» pinta con la libreta, que ya está
        }
    }

    /// El TEMA que tiene puesto el usuario, leído del webview. Al llegar, la
    /// barra y las pantallas nativas se repintan con esos colores.
    private func traerTema() {
        bridge?.webView?.evaluateJavaScript("(window.__chinolaTemaJSON && window.__chinolaTemaJSON()) || ''") { [weak self] res, _ in
            guard let self = self, let json = res as? String, json.count > 2 else { return }
            CNDatos.shared.cargarTema(json: json)
            self.barra.pintar(activa: self.menuEstado.activa, titulos: self.menuEstado.titulos)
            // Claro u oscuro de sistema según el tema: así el vidrio, las hojas
            // y los menús del sistema acompañan a la paleta de la app.
            self.ponerModoDeLaPaleta()
            self.contenedorNativo?.backgroundColor = UIColor(CNC.scr)
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }

    /// El panel del Resumen, ya calculado por la web (títulos, cifras, puntos de
    /// las gráficas y colores). Aquí solo se dibuja.
    ///
    /// Se reintenta: la web solo calcula las tarjetas del panel estando EN el
    /// resumen, y al cambiar de pestaña el repintado tarda un instante. Leerlo
    /// antes devolvía un panel vacío y la pantalla salía en blanco.
    private func traerResumen(intentos: Int = 1) {
        bridge?.webView?.evaluateJavaScript("(window.__chinolaResumenJSON && window.__chinolaResumenJSON()) || ''") { [weak self] res, _ in
            guard let s = self else { return }
            guard let json = res as? String, json.count > 2 else {
                if intentos > 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { s.traerResumen(intentos: intentos - 1) }
                }
                return
            }
            CNDatos.shared.cargarResumen(json: json)
            if intentos > 1, CNDatos.shared.resumen?.listo != true {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { s.traerResumen(intentos: intentos - 1) }
            }
        }
    }

    // MARK: el periodo (atajos + calendario), en hoja nativa
    private weak var periodoVC: UIViewController?
    // MARK: el selector de libretas, nativo
    private var libretasVC: UIViewController?
    private func abrirLibretas() {
        refrescarLibretas()
        guard libretasVC == nil else { return }
        // Hoja propia, de orilla a orilla y pegada al pie: la del sistema sale
        // flotando con márgenes en iOS 26.
        let d = datos
        let host = UIHostingController(rootView: CNHojaAbajo(onClose: { [weak self] in self?.cerrarLibretas() }) {
            CNLibretasHoja(datos: d, onClose: { [weak self] in self?.cerrarLibretas() })
        })
        host.view.backgroundColor = .clear
        host.modalPresentationStyle = .overFullScreen
        libretasVC = host
        if let actual = presentedViewController {
            actual.dismiss(animated: true) { [weak self] in self?.present(host, animated: false) }
        } else {
            present(host, animated: false)
        }
    }
    private func refrescarLibretas(intentos: Int = 4) {
        bridge?.webView?.evaluateJavaScript("(window.__chinolaLibretasJSON && window.__chinolaLibretasJSON()) || ''") { [weak self] res, _ in
            if let json = res as? String, json.count > 2 {
                CNDatos.shared.cargarLibretas(json: json)
                // Y si se está mirando una subpantalla que se arma con esto,
                // se rehace: acaba de llegar lo que le faltaba.
                if let s = self, let cual = s.datos.seccion?.id,
                   cual == "libretas" || cual.hasPrefix("libreta:"),
                   let hecha = CNSecciones.arma(cual) {
                    s.ponSeccion(hecha, si: cual)
                }
                return
            }
            // La web puede estar a medio pintar: se vuelve a pedir en vez de
            // dejar la hoja vacía.
            guard intentos > 1 else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { self?.refrescarLibretas(intentos: intentos - 1) }
        }
    }
    private func cerrarLibretas() {
        // La hoja ya se ha ido animando sola; aquí solo se retira.
        libretasVC?.dismiss(animated: false)
        libretasVC = nil
    }

    private func abrirPeriodo() {
        refrescarPeriodo()
        guard periodoVC == nil else { return }
        // La misma hoja propia que el selector de libretas: de orilla a orilla,
        // pegada al pie y con el estilo de la app.
        let d = datos
        let cerrar: () -> Void = { [weak self] in
            self?.eval("window.__chinolaPeriodo && window.__chinolaPeriodo('cerrar',0)")
            self?.cerrarPeriodo()
        }
        let host = UIHostingController(rootView: CNHojaAbajo(onClose: cerrar) {
            CNPeriodoHoja(datos: d, onClose: cerrar)
                .frame(maxHeight: UIScreen.main.bounds.height * 0.86)
        })
        host.view.backgroundColor = .clear
        host.modalPresentationStyle = .overFullScreen
        periodoVC = host
        if let actual = presentedViewController {
            actual.dismiss(animated: true) { [weak self] in self?.present(host, animated: false) }
        } else {
            present(host, animated: false)
        }
    }
    private func refrescarPeriodo() {
        bridge?.webView?.evaluateJavaScript("(window.__chinolaPeriodoJSON && window.__chinolaPeriodoJSON()) || ''") { res, _ in
            guard let json = res as? String, json.count > 2 else { return }
            CNDatos.shared.cargarPeriodo(json: json)
        }
    }
    private func cerrarPeriodo() {
        periodoVC?.dismiss(animated: false) { [weak self] in
            guard let s = self else { return }
            CNDatos.shared.periodo = nil
            s.traerDatos(intentos: 3); s.traerResumen(intentos: 4)
        }
        periodoVC = nil
    }

    // MARK: volver arrastrando desde la orilla, en las subpantallas de Perfil
    //
    // El detalle tiene el suyo propio en su vista; estas viven dentro de una
    // pantalla de SwiftUI, así que el reconocedor va en la raíz y lo único que
    // hace es mover un número que la vista mira. Solo empieza cuando hay una
    // subpantalla abierta: si no, no le quita el dedo a nadie.
    private func montarOrilla() {
        let g = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(arrastrarSeccion(_:)))
        g.edges = .left
        g.delegate = self
        view.addGestureRecognizer(g)
    }

    @objc private func arrastrarSeccion(_ g: UIScreenEdgePanGestureRecognizer) {
        guard datos.seccion != nil, detalleVC == nil else { return }
        let ancho = view.bounds.width
        let dx = max(0, g.translation(in: view).x)
        switch g.state {
        case .began, .changed:
            datos.arrastreSec = dx
        case .ended, .cancelled, .failed:
            let prisa = g.velocity(in: view).x
            if dx > ancho * 0.33 || prisa > 800 {
                withAnimation(.easeOut(duration: 0.2)) { self.datos.arrastreSec = ancho }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.19) { [weak self] in
                    guard let self = self else { return }
                    UISelectionFeedbackGenerator().selectionChanged()
                    self.datos.seccion = nil
                    self.datos.arrastreSec = 0
                }
            } else {
                withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.86)) { self.datos.arrastreSec = 0 }
            }
        default: break
        }
    }

    // MARK: un detalle cualquiera, empujado encima
    private var detalleVC: UIViewController?
    private var detalleQue = ("", "")
    fileprivate func mostrarDetalle(_ tipo: String, _ id: String) {
        detalleQue = (tipo, id)
        refrescarDetalle()
        guard detalleVC == nil else { return }
        let host = UIHostingController(
            rootView: CNDetalleVista(datos: CNDatos.shared, onVolver: { [weak self] in self?.cerrarDetalle() }))
        host.view.backgroundColor = UIColor(CNC.scr)
        addChild(host); view.addSubview(host.view); host.didMove(toParent: self)
        host.view.frame = view.bounds
        host.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        host.view.transform = CGAffineTransform(translationX: view.bounds.width, y: 0)
        // La sombra del filo, la misma que enseña iOS al empujar una pantalla.
        // Solo se ve mientras está corrida, que es cuando hay algo detrás.
        host.view.layer.shadowColor = UIColor.black.cgColor
        host.view.layer.shadowOpacity = 0.18
        host.view.layer.shadowRadius = 14
        host.view.layer.shadowOffset = CGSize(width: -4, height: 0)
        // Y las esquinas: mientras se arrastra, la pantalla es una tarjeta con
        // las esquinas del teléfono, no un rectángulo cortado a escuadra.
        host.view.layer.cornerRadius = 0
        host.view.layer.cornerCurve = .continuous
        // Volver arrastrando desde la orilla izquierda. Tiene que ser un
        // reconocedor de UIKit: es el mismo que usa UINavigationController y
        // por eso gana al desplazamiento de la lista que hay dentro. El
        // DragGesture de SwiftUI que había aquí no llegaba a empezar nunca.
        let orilla = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(arrastrarDetalle(_:)))
        orilla.edges = .left
        host.view.addGestureRecognizer(orilla)
        detalleVC = host
        // Lo de detrás se va un poco y se apaga, como en cualquier app del
        // teléfono: sin eso, la pantalla nueva parece pegada encima de una foto.
        montarSombraAtras()
        atras(0)
        UIView.animate(withDuration: 0.34, delay: 0, usingSpringWithDamping: 0.92, initialSpringVelocity: 0,
                       options: [.curveEaseOut, .allowUserInteraction]) {
            host.view.transform = .identity
            self.atras(1)
        }
    }

    /// El telón que apaga la pantalla de debajo mientras hay otra encima.
    private var sombraAtras: UIView?
    private func montarSombraAtras() {
        guard sombraAtras == nil, let debajo = contenedorNativo else { return }
        let v = UIView(frame: view.bounds)
        v.backgroundColor = .black
        v.alpha = 0
        v.isUserInteractionEnabled = false
        v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(v, aboveSubview: debajo)
        sombraAtras = v
    }
    /// `p` va de 0 (la de atrás en su sitio) a 1 (la de atrás retirada del todo).
    private func atras(_ p: CGFloat) {
        let q = max(0, min(1, p))
        contenedorNativo?.transform = CGAffineTransform(translationX: -view.bounds.width * 0.28 * q, y: 0)
        sombraAtras?.alpha = 0.16 * q
    }
    private func soltarAtras() {
        contenedorNativo?.transform = .identity
        sombraAtras?.removeFromSuperview()
        sombraAtras = nil
    }
    /// El arrastre desde la orilla: la pantalla sigue al dedo y se va o vuelve
    /// según lo que se haya recorrido o con qué prisa se suelte, como en iOS.
    @objc private func arrastrarDetalle(_ g: UIScreenEdgePanGestureRecognizer) {
        guard let host = detalleVC else { return }
        let ancho = view.bounds.width
        let dx = max(0, g.translation(in: view).x)
        switch g.state {
        case .began, .changed:
            if host.view.layer.cornerRadius == 0 {
                host.view.layer.cornerRadius = 30
                host.view.layer.masksToBounds = true
            }
            host.view.transform = CGAffineTransform(translationX: dx, y: 0)
            atras(1 - dx / max(1, ancho))
        case .ended, .cancelled, .failed:
            let prisa = g.velocity(in: view).x
            if dx > ancho * 0.33 || prisa > 800 {
                cerrarDetalle()
            } else {
                UIView.animate(withDuration: 0.28, delay: 0, usingSpringWithDamping: 0.9,
                               initialSpringVelocity: 0, options: [.allowUserInteraction]) {
                    host.view.transform = .identity
                    self.atras(1)
                } completion: { _ in
                    // De vuelta en su sitio, las esquinas a escuadra otra vez.
                    host.view.layer.cornerRadius = 0
                    host.view.layer.masksToBounds = false
                }
            }
        default: break
        }
    }

    fileprivate func cerrarDetalle() {
        guard let host = detalleVC else { return }
        detalleVC = nil
        UIView.animate(withDuration: 0.26, delay: 0, options: [.curveEaseOut, .allowUserInteraction]) {
            host.view.transform = CGAffineTransform(translationX: self.view.bounds.width, y: 0)
            self.atras(0)
        } completion: { _ in
            host.willMove(toParent: nil); host.view.removeFromSuperview(); host.removeFromParent()
            CNDatos.shared.detalle = nil
            // Cerrado: ya no hay nada que refrescar. Sin esto, cada refresco
            // seguiría pidiendo el modelo del último detalle que se abrió.
            self.detalleQue = ("", "")
            self.soltarAtras()
        }
        traerDatos(intentos: 3); traerCuentas(); traerPlan()
    }
    private func refrescarDetalle() {
        // SOLO MIRANDO `detalleQue`, y no si la vista existe ya.
        //
        // Puse aquí un `guard detalleVC != nil` para no refrescar un detalle
        // cerrado, y dejé la pantalla EN BLANCO: `mostrarDetalle` llama a esto
        // ANTES de crear la vista —para que el modelo esté puesto cuando
        // aparezca— así que con ese guardián no se cargaba nunca y el detalle
        // salía vacío, con su botón de volver y nada más.
        //
        // Lo que había que hacer era lo otro: vaciar `detalleQue` al cerrar.
        // Así «hay algo que refrescar» y «la vista ya existe» dejan de ser la
        // misma pregunta, que es de donde venía el lío.
        let (tipo, id) = detalleQue
        guard !tipo.isEmpty else { return }
        bridge?.webView?.evaluateJavaScript("(window.__chinolaDetalleJSON && window.__chinolaDetalleJSON(\(comillas(tipo)),\(comillas(id)))) || ''") { res, _ in
            guard let json = res as? String, json.count > 2 else { return }
            CNDatos.shared.cargarDetalle(json: json)
        }
    }

    /// La pantalla de Cuentas, armada por la web.
    private func traerCuentas() {
        bridge?.webView?.evaluateJavaScript("(window.__chinolaCuentasJSON && window.__chinolaCuentasJSON()) || ''") { res, _ in
            guard let json = res as? String, json.count > 2 else { return }
            CNDatos.shared.cargarCuentas(json: json)
        }
    }

    /// El Plan, armado por la web.
    private func traerPlan(intentos: Int = 1) {
        bridge?.webView?.evaluateJavaScript("(window.__chinolaPlanJSON && window.__chinolaPlanJSON()) || ''") { [weak self] res, _ in
            guard let s = self else { return }
            if let json = res as? String, json.count > 2 { CNDatos.shared.cargarPlan(json: json) }
            if intentos > 1, CNDatos.shared.plan?.listo != true {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { s.traerPlan(intentos: intentos - 1) }
            }
        }
    }

    /// El detalle de un movimiento, armado por la web.
    private func traerMov(_ id: String) {
        bridge?.webView?.evaluateJavaScript("(window.__chinolaMovJSON && window.__chinolaMovJSON(\(comillas(id)))) || ''") { res, _ in
            guard let json = res as? String, json.count > 2 else { return }
            CNDatos.shared.cargarMovDetalle(json: json)
        }
    }

    /// El modelo de una subpantalla del perfil.
    /**
     * Pone una subpantalla SOLO si sigue siendo la que se está mirando.
     *
     * Entre que se le pregunta al servidor y contesta, la persona puede haber
     * salido o haber entrado en otra. Sin esta comprobación, la respuesta tardía
     * pisaría la pantalla nueva con la vieja — y eso, tocando ajustes seguidos,
     * es de lo que peor se entiende: la pantalla cambia sola.
     */
    @MainActor private func ponSeccion(_ x: CNSeccion, si id: String) {
        guard datos.seccionPedida == id || datos.seccion?.id == id else { return }
        datos.seccion = x
    }

    private func traerSeccion(_ id: String) {
        bridge?.webView?.evaluateJavaScript("(window.__chinolaSeccionJSON && window.__chinolaSeccionJSON(\(comillas(id)))) || ''") { res, _ in
            guard let json = res as? String, json.count > 2 else { return }
            CNDatos.shared.cargarSeccion(json: json)
        }
    }

    /**
     * LAS OCHO DE PERSONALIZACIÓN, ANTES DE QUE LAS PIDAN.
     *
     * Entrar en una subpantalla ya no deja la pantalla en blanco SI se vio
     * antes; la primera vez seguía en blanco, que es justo cuando peor sienta.
     * Con las ocho traídas de golpe, no hay primera vez: la primera entrada ya
     * tiene su contenido.
     *
     * Se pide al arrancar y cada vez que cambia un ajuste, porque un ajuste
     * cambia lo que enseñan las demás —el tema cambia los colores de todas, la
     * letra cambia su muestra—. Son ocho pantallas de texto: rearmarlas cuesta
     * mucho menos que una sola espera en blanco.
     */
    private func traerSeccionesDePerfil() {
        bridge?.webView?.evaluateJavaScript(
            "(window.__chinolaSeccionesPerfil && window.__chinolaSeccionesPerfil()) || ''") { res, _ in
            guard let json = res as? String, json.count > 4,
                  let d = json.data(using: .utf8),
                  let lista = (try? JSONSerialization.jsonObject(with: d)) as? [[String: Any]] else { return }
            for sec in lista {
                guard let uno = try? JSONSerialization.data(withJSONObject: sec),
                      let texto = String(data: uno, encoding: .utf8) else { continue }
                CNDatos.shared.guardaSeccionVista(json: texto)
            }
        }
    }

    /// Los ajustes del Perfil, armados por la web (los mismos que ve la PWA).
    private func traerAjustes() {
        bridge?.webView?.evaluateJavaScript("(window.__chinolaAjustesJSON && window.__chinolaAjustesJSON()) || ''") { res, _ in
            guard let json = res as? String, json.count > 2 else { return }
            CNDatos.shared.cargarAjustes(json: json)
        }
    }

    // MARK: pantalla nativa (Movimientos) encima del webview
    fileprivate func mostrarNativo(_ id: String) {
        // Si estábamos esperando a que un flujo de la web terminara, ya da
        // igual: el usuario ha cambiado de pantalla.
        volviendo = false
        // Al cambiar de pantalla la barra vuelve entera: la nueva empieza arriba.
        CNScrollEstado.shared.reiniciar()
        contenedorNativo?.removeFromSuperview()
        let host: UIHostingController<AnyView>
        switch id {
        case "resumen": host = UIHostingController(rootView: AnyView(CNResumen(datos: datos)))
        case "movs": host = UIHostingController(rootView: AnyView(CNMovs(datos: datos)))
        case "cuentas": host = UIHostingController(rootView: AnyView(CNCuentas(datos: datos)))
        case "plan": host = UIHostingController(rootView: AnyView(CNPlan(datos: datos)))
        case "perfil": host = UIHostingController(rootView: AnyView(CNPerfil(datos: datos)))
        default: return
        }
        // Fondo OPACO: tapa el webview sin esconderlo (esconderlo = pantalla negra,
        // porque el webView es la vista raíz del VC).
        host.view.backgroundColor = UIColor(CNC.scr)
        addChild(host); view.addSubview(host.view); host.didMove(toParent: self)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        contenedorNativo = host.view
        ajustarHueco(host)
        view.bringSubviewToFront(barra.barra)
        // Y el botón de Chino con ella. Se monta una vez y cada pantalla
        // nativa que entra después se le pone ENCIMA y lo tapa: se montaba
        // bien, la web lo pedía bien, y no se veía. La barra ya se subía aquí;
        // el botón no, y es el único que va por encima de la barra.
        if let f = flotanteVista { view.bringSubviewToFront(f) }
        // La libreta solo si cambió, y DESPUÉS de que entre la pantalla: si se
        // pide aquí mismo, el puente se come los primeros fotogramas de la
        // animación y el cambio se siente pesado.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) { [weak self] in
            self?.traerDatosSiCambio()
        }
        // La web se entera igual de en qué pestaña estamos: así sus hojas y su
        // botón de atrás siguen cuadrando con lo que se ve.
        eval("window.__chinolaMenu && window.__chinolaMenu('\(id)')")
        // Y de que ya no se la ve: queda debajo, tapada por esta pantalla, así
        // que para de animarse y de sincronizar. Seguía componiendo el
        // personaje flotando y las transiciones de algo invisible.
        eval("window.__chinolaQuieto && window.__chinolaQuieto(true)")
        eval("window.__chinolaPush && window.__chinolaPush()")
        // Y se vuelve a pedir el modelo cuando la web ya haya repintado con la
        // pestaña nueva puesta.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let s = self else { return }
            s.traerResumen(intentos: 6); s.traerCuentas(); s.traerPlan(intentos: 6); s.traerAjustes()
            s.traerSeccionesDePerfil()
        }
    }

    /// SI LO NATIVO NO TIENE NADA QUE PINTAR, MANDA LA WEB.
    ///
    /// Las pantallas nativas se ponen encima del webview con un fondo OPACO, y
    /// se ponen desde el primer fotograma, antes de que la web haya mandado
    /// nada. Mientras los datos llegan eso no se nota; si NO llegan —la web
    /// tarda más de la cuenta, el puente no contesta, la libreta está vacía—,
    /// lo que queda delante es un rectángulo del color del tema y nada más:
    /// una app en blanco, sin barra, sin texto y sin salida, con la web
    /// perfectamente pintada justo debajo.
    ///
    /// Esto es el último recurso: pasados seis segundos, si lo nativo sigue
    /// sin haber recibido una sola cosa, se le devuelve el sitio a la web.
    /// Vale más la app con su diseño de siempre que una pantalla vacía.
    private func redDeSeguridad() {
        guard puertaVC == nil, hojaVC == nil, detalleVC == nil else { return }
        guard !CNDatos.shared.llegoAlgo else { return }
        NSLog("CNRED: lo nativo no recibió nada en seis segundos; se le devuelve el sitio a la web")
        quitarCortina()
        mostrarWeb()   // la barra se queda: sigue sirviendo para cambiar de pestaña
        // Y se sigue mirando: en cuanto la web conteste, lo nativo vuelve.
        traerDatos()
        mirarPuerta()
    }

    private func mostrarWeb() {
        // Vuelve a verse: se despierta antes de destapar, para que no aparezca
        // con las animaciones congeladas.
        eval("window.__chinolaQuieto && window.__chinolaQuieto(false)")
        contenedorNativo?.removeFromSuperview()
        contenedorNativo = nil
    }

    /// Enseñar la web para un flujo SUYO (una hoja, el calendario, el selector
    /// de libreta) y volver a lo nativo en cuanto ese flujo termina.
    ///
    /// Sin esto la app se quedaba en la pantalla WEB de la pestaña —la copia
    /// vieja de la que ya es nativa—, y navegando salía una u otra sin motivo
    /// aparente. Ahora la web solo se ve mientras tiene algo que enseñar.
    private var volviendo = false
    /// `alIrALaWeb` corre SOLO si al final hay que enseñar la web. Así una
    /// pantalla nativa que abre una hoja se queda donde está —la hoja se dibuja
    /// encima— y solo se aparta cuando lo que la web abrió no sabemos dibujarlo.
    private func webTemporal(alIrALaWeb: (() -> Void)? = nil) {
        // Primero se mira si lo que la web abrió es una HOJA: esas se dibujan
        // nativas y el webview no se enseña. Solo lo que no sabemos dibujar
        // (el calendario del periodo, el selector de libreta) pasa a la web.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            guard let s = self else { return }
            // ¿El recorrido? Se dibuja nativo, encima de la pantalla de verdad.
            s.bridge?.webView?.evaluateJavaScript("(window.__chinolaTourJSON && window.__chinolaTourJSON()) || ''") { r0, _ in
                if let j = r0 as? String, j.count > 2 {
                    CNDatos.shared.cargarTour(json: j)
                    s.mostrarTour()
                    return
                }
                // ¿La categoría? También tiene su hoja nativa.
                s.bridge?.webView?.evaluateJavaScript("(window.__chinolaCatJSON && window.__chinolaCatJSON()) || ''") { rc, _ in
                    if let j = rc as? String, j.count > 2 {
                        CNDatos.shared.cargarCategoria(json: j)
                        s.presentar(AnyView(CNFormCategoria(datos: s.datos, onClose: {
                            s.eval("window.__chinolaCat && window.__chinolaCat('cerrar','')")
                            s.cerrar()
                            s.traerPlan(intentos: 4); s.traerDatos(intentos: 3)
                        })))
                        return
                    }
            s.bridge?.webView?.evaluateJavaScript("(window.__chinolaHojaJSON && window.__chinolaHojaJSON()) || ''") { res, _ in
                if let json = res as? String, json.count > 2 {
                    CNDatos.shared.cargarHojaWeb(json: json)
                    s.presentarHojaWeb()
                    return
                }
                // ¿La puerta (cambiar de plan, poner el nombre, cerrar sesión)?
                s.bridge?.webView?.evaluateJavaScript("(window.__chinolaPuertaJSON && window.__chinolaPuertaJSON()) || ''") { rp, _ in
                    if let j = rp as? String, j.count > 2, let m = CNPuerta.desde(json: j), m.paso != "app" {
                        CNDatos.shared.cargarPuerta(json: j)
                        s.abrirPuerta()
                        return
                    }
                    // Nada de eso. Solo si la web tiene de verdad algo abierto
                    // que no sabemos dibujar se enseña la web; si la acción no
                    // abrió nada (un interruptor, exportar, un aviso), nos
                    // quedamos en nativo. Antes se enseñaba la web por defecto,
                    // y eso era «todo es web» y los cuelgues.
                    s.bridge?.webView?.evaluateJavaScript("!!(window.__chinolaHayHoja && window.__chinolaHayHoja())") { rh, _ in
                        guard (rh as? Bool) == true else { return }
                        alIrALaWeb?()
                        s.mostrarWeb()
                        guard !s.volviendo else { return }
                        s.volviendo = true
                        s.vigilarVuelta(200)
                    }
                }
            }
            }
            }
        }
    }

    // MARK: importar un CSV con el selector de archivos del sistema
    //
    // El <input type=file> de la web no abre nada desde una llamada nuestra
    // (WKWebView exige un toque de verdad). El selector lo abre el sistema y el
    // texto se le pasa a la MISMA función de la web que lo lee.
    fileprivate func pedirCsv() {
        let tipos: [UTType] = [.commaSeparatedText, .plainText, .text, .json]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: tipos, asCopy: true)
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }

    // MARK: avisos cortos («Guardado», «Avisos puestos»)
    //
    // Los de la web no los veía nadie: está tapada por las pantallas nativas.
    // Este baja desde arriba, se lee y se va solo.
    private var avisoVista: UIView?
    private func mostrarAviso(_ titulo: String, _ texto: String) {
        avisoVista?.removeFromSuperview()
        let tarjeta = UIView()
        tarjeta.backgroundColor = UIColor(CNC.card)
        tarjeta.layer.cornerRadius = 18
        tarjeta.layer.cornerCurve = .continuous
        tarjeta.layer.borderWidth = 1
        tarjeta.layer.borderColor = UIColor(CNC.line).cgColor
        tarjeta.layer.shadowColor = UIColor.black.cgColor
        tarjeta.layer.shadowOpacity = 0.16
        tarjeta.layer.shadowRadius = 14
        tarjeta.layer.shadowOffset = CGSize(width: 0, height: 6)
        let t = UILabel()
        t.text = titulo; t.font = cnUIFuente(15, .bold); t.textColor = UIColor(CNC.ink); t.numberOfLines = 2
        let x = UILabel()
        x.text = texto; x.font = cnUIFuente(13, .regular); x.textColor = UIColor(CNC.pmut); x.numberOfLines = 3
        x.isHidden = texto.isEmpty
        let pila = UIStackView(arrangedSubviews: [t, x])
        pila.axis = .vertical; pila.spacing = 3
        pila.translatesAutoresizingMaskIntoConstraints = false
        tarjeta.addSubview(pila)
        tarjeta.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tarjeta)
        NSLayoutConstraint.activate([
            pila.topAnchor.constraint(equalTo: tarjeta.topAnchor, constant: 12),
            pila.bottomAnchor.constraint(equalTo: tarjeta.bottomAnchor, constant: -12),
            pila.leadingAnchor.constraint(equalTo: tarjeta.leadingAnchor, constant: 16),
            pila.trailingAnchor.constraint(equalTo: tarjeta.trailingAnchor, constant: -16),
            tarjeta.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tarjeta.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tarjeta.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8)
        ])
        avisoVista = tarjeta
        tarjeta.alpha = 0
        tarjeta.transform = CGAffineTransform(translationX: 0, y: -24)
        UIView.animate(withDuration: 0.32, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0) {
            tarjeta.alpha = 1; tarjeta.transform = .identity
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) { [weak self, weak tarjeta] in
            guard let tj = tarjeta, self?.avisoVista === tj else { return }
            UIView.animate(withDuration: 0.25, animations: { tj.alpha = 0; tj.transform = CGAffineTransform(translationX: 0, y: -16) }) { _ in
                tj.removeFromSuperview()
                if self?.avisoVista === tj { self?.avisoVista = nil }
            }
        }
    }

    // MARK: la cortina del arranque
    //
    // Un telón del color del tema mientras no se sabe qué toca: la app o la
    // puerta. Dura lo que tarde la web en contestar, y como mucho tres
    // segundos y medio —si algo fallara, es preferible una pantalla de más que
    // una app tapada para siempre.
    private var cortina: UIView?
    private func montarCortina() {
        let v = UIView(frame: view.bounds)
        v.backgroundColor = UIColor(CNC.scr)
        v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(v)
        cortina = v
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { [weak self] in self?.quitarCortina() }
    }
    private func quitarCortina() {
        guard let v = cortina else { return }
        cortina = nil
        UIView.animate(withDuration: 0.2) { v.alpha = 0 } completion: { _ in v.removeFromSuperview() }
    }

    // MARK: la puerta — lo de antes de entrar
    //
    // Bienvenida, acceso, nombre, plan y el «listo». La lógica sigue siendo la
    // de la web (la misma que en el navegador); aquí se dibuja y se le dice qué
    // han tocado. Mientras está puesta, el menú de abajo no pinta nada.
    private var puertaVC: UIViewController?
    fileprivate func mirarPuerta(intentos: Int = 12) {
        bridge?.webView?.evaluateJavaScript("(window.__chinolaPuertaJSON && window.__chinolaPuertaJSON()) || ''") { [weak self] res, _ in
            guard let s = self else { return }
            let json = (res as? String) ?? ""
            if s.puertaRendida {
                // Ya se pasó a la web: solo queda mirar si ya entró.
                if let m = CNPuerta.desde(json: json), m.paso == "app" {
                    s.puertaRendida = false
                    s.cerrarPuerta()
                } else if intentos > 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { s.mirarPuerta(intentos: intentos - 1) }
                }
                return
            }
            if json.count > 2 {
                if let m = CNPuerta.desde(json: json), m.paso == "app" {
                    s.cerrarPuerta()
                } else {
                    // Fuera de la app: o es alguien nuevo o alguien que cerró
                    // sesión. Lo guardado es de la persona de antes y no puede
                    // salir en el próximo arranque.
                    CNDatos.shared.olvidaLoGuardado()
                    CNDatos.shared.cargarPuerta(json: json)
                    CNDatos.shared.apuntaQueLlego()
                    s.abrirPuerta()
                }
                return
            }
            // Todavía no hay modelo: la web puede estar arrancando.
            guard intentos > 1 else {
                // Se acabó la espera. Si además no hay datos, lo que hay
                // delante es una pantalla vacía: mejor la web, que siempre
                // sabe qué enseñar.
                if CNDatos.shared.resumen == nil && CNDatos.shared.puerta == nil && s.puertaVC == nil {
                    s.puertaALaWeb()
                }
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { s.mirarPuerta(intentos: intentos - 1) }
        }
    }
    private func abrirPuerta() {
        barra.barra.isHidden = true
        quitarCortina()
        guard puertaVC == nil else { return }
        let host = UIHostingController(rootView: CNPuertaVista(datos: datos, onAccion: { [weak self] que, valor in
            guard let s = self else { return }
            // Salida de emergencia: si algo de la puerta nativa fallara, la de
            // la web sigue ahí y es la de siempre. Que nadie se quede fuera.
            if que == "web" { s.puertaALaWeb(); return }
            s.puertaAccion(que, valor)
        }))
        host.view.backgroundColor = UIColor(CNC.scr)
        addChild(host); view.addSubview(host.view); host.didMove(toParent: self)
        host.view.frame = view.bounds
        host.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        host.view.layer.cornerCurve = .continuous
        // Volver deslizando desde la orilla, como en los detalles: el mismo
        // reconocedor de UIKit, que gana a la lista de dentro.
        let orilla = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(arrastrarPuerta(_:)))
        orilla.edges = .left
        host.view.addGestureRecognizer(orilla)
        puertaVC = host
        // Y se vuelve a mirar cada poco mientras esté puesta: la web cambia de
        // paso por su cuenta (la caja de Apple que se cierra, el correo que se
        // verifica, un error) y antes solo se miraba unas veces tras un toque;
        // lo que pasara después se quedaba sin pintar («Un momento…» eterno).
        puertaReloj?.invalidate()
        puertaReloj = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: true) { [weak self] _ in
            guard let s = self, s.puertaVC != nil, !s.puertaRendida else { return }
            s.mirarPuerta(intentos: 1)
        }
    }
    private var puertaReloj: Timer?

    /// El arrastre desde la orilla en la puerta: la pantalla sigue al dedo y,
    /// si se suelta lejos o con prisa, hace lo mismo que la flecha de atrás
    /// del paso (si el paso no tiene atrás, solo vuelve a su sitio).
    @objc private func arrastrarPuerta(_ g: UIScreenEdgePanGestureRecognizer) {
        guard let host = puertaVC else { return }
        let ancho = view.bounds.width
        let dx = max(0, g.translation(in: view).x)
        let volver = CNDatos.shared.puerta?.volver ?? ""
        switch g.state {
        case .began, .changed:
            guard !volver.isEmpty else { return }
            if host.view.layer.cornerRadius == 0 {
                host.view.layer.cornerRadius = 30
                host.view.layer.masksToBounds = true
            }
            host.view.transform = CGAffineTransform(translationX: dx, y: 0)
        case .ended, .cancelled, .failed:
            guard !volver.isEmpty else { return }
            let prisa = g.velocity(in: view).x
            if dx > ancho * 0.33 || prisa > 800 {
                UISelectionFeedbackGenerator().selectionChanged()
                UIView.animate(withDuration: 0.18, delay: 0, options: [.curveEaseOut]) {
                    host.view.transform = CGAffineTransform(translationX: ancho, y: 0)
                } completion: { _ in
                    // Se le pide a la web el paso de antes y, en cuanto lo
                    // dibuja, la pantalla entra desde la izquierda.
                    self.puertaAccion(volver, "")
                    host.view.transform = CGAffineTransform(translationX: -ancho * 0.25, y: 0)
                    host.view.alpha = 0
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { self.mirarPuerta(intentos: 3) }
                    UIView.animate(withDuration: 0.26, delay: 0.3, options: [.curveEaseOut, .allowUserInteraction]) {
                        host.view.transform = .identity
                        host.view.alpha = 1
                    } completion: { _ in
                        host.view.layer.cornerRadius = 0
                        host.view.layer.masksToBounds = false
                    }
                }
            } else {
                UIView.animate(withDuration: 0.28, delay: 0, usingSpringWithDamping: 0.9,
                               initialSpringVelocity: 0, options: [.allowUserInteraction]) {
                    host.view.transform = .identity
                } completion: { _ in
                    host.view.layer.cornerRadius = 0
                    host.view.layer.masksToBounds = false
                }
            }
        default: break
        }
    }
    // MARK: bloqueo con Face ID / Touch ID
    //
    // Quien lo enciende no quiere que nadie que coja el teléfono vea sus
    // finanzas: al irse la app se tapa (también en el selector de apps) y al
    // volver pide la cara, la huella o el código del teléfono.
    private var bloqueoPuesto: Bool { UserDefaults.standard.bool(forKey: "cnBloqueo") }
    private var bloqueada = false
    private var pidiendo = false
    private var cortinaBloqueo: UIView?
    private var enPrimerPlano = true

    @objc private func alIrse() {
        enPrimerPlano = false
        guard bloqueoPuesto else { return }
        taparPantalla()
    }
    @objc private func alFondo() {
        guard bloqueoPuesto else { return }
        bloqueada = true
    }
    @objc private func alVolver() {
        enPrimerPlano = true
        guard bloqueoPuesto else { quitarCortinaBloqueo(); return }
        if bloqueada { pedirDesbloqueo() } else { quitarCortinaBloqueo() }
    }

    /// Al encenderlo se pide la cara ahí mismo: así se ve que funciona y, si
    /// el teléfono no tiene nada con qué bloquear, se dice y se deja apagado.
    @objc private func bloqueoCambiado(_ n: Notification) {
        guard (n.userInfo?["on"] as? Bool) == true else { return }
        let ctx = LAContext()
        var error: NSError?
        guard ctx.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            UserDefaults.standard.set(false, forKey: "cnBloqueo")
            let a = UIAlertController(title: cnT("Sin nada con qué bloquear"),
                                      message: cnT("Tu teléfono no tiene Face ID, huella ni código. Ponle uno en Ajustes y vuelve a encenderlo."),
                                      preferredStyle: .alert)
            a.addAction(UIAlertAction(title: "OK", style: .default))
            (presentedViewController ?? self).present(a, animated: true)
            eval("window.__chinolaBloqueoFallo && window.__chinolaBloqueoFallo()")
            return
        }
        ctx.localizedCancelTitle = cnT("Ahora no")
        ctx.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: cnT("Así se pedirá cada vez que vuelvas a Chinola")) { ok, _ in
            DispatchQueue.main.async {
                if ok { UINotificationFeedbackGenerator().notificationOccurred(.success) }
            }
        }
    }

    private func taparPantalla() {
        guard cortinaBloqueo == nil else { return }
        let fondo = UIVisualEffectView(effect: UIBlurEffect(style: CNC.tema.oscuro ? .dark : .light))
        fondo.frame = view.bounds
        fondo.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let capa = UIView(frame: view.bounds)
        capa.backgroundColor = UIColor(CNC.scr).withAlphaComponent(0.85)
        capa.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        fondo.contentView.addSubview(capa)

        let pila = UIStackView()
        pila.axis = .vertical; pila.alignment = .center; pila.spacing = 14
        pila.translatesAutoresizingMaskIntoConstraints = false
        let marca = UIImageView(image: UIImage(named: "AppIcon") ?? UIImage(systemName: "lock.fill"))
        marca.contentMode = .scaleAspectFit
        marca.layer.cornerRadius = 18; marca.layer.cornerCurve = .continuous; marca.clipsToBounds = true
        marca.widthAnchor.constraint(equalToConstant: 76).isActive = true
        marca.heightAnchor.constraint(equalToConstant: 76).isActive = true
        let titulo = UILabel()
        titulo.text = cnT("Chinola está bloqueada")
        titulo.font = cnUIFuente(19, .bold); titulo.textColor = UIColor(CNC.ink)
        let boton = UIButton(type: .system)
        boton.setTitle(cnT("Desbloquear"), for: .normal)
        boton.titleLabel?.font = cnUIFuente(16, .bold)
        boton.setTitleColor(UIColor(CNC.sobreAcc), for: .normal)
        boton.backgroundColor = UIColor(CNC.acc)
        boton.contentEdgeInsets = UIEdgeInsets(top: 13, left: 26, bottom: 13, right: 26)
        boton.layer.cornerRadius = 22
        boton.addTarget(self, action: #selector(tocarDesbloquear), for: .touchUpInside)
        boton.isHidden = true
        boton.tag = 77
        pila.addArrangedSubview(marca); pila.addArrangedSubview(titulo); pila.addArrangedSubview(boton)
        fondo.contentView.addSubview(pila)
        NSLayoutConstraint.activate([
            pila.centerXAnchor.constraint(equalTo: fondo.contentView.centerXAnchor),
            pila.centerYAnchor.constraint(equalTo: fondo.contentView.centerYAnchor, constant: -20)
        ])
        view.addSubview(fondo)
        cortinaBloqueo = fondo
    }
    private func quitarCortinaBloqueo() {
        guard let c = cortinaBloqueo else { return }
        cortinaBloqueo = nil
        UIView.animate(withDuration: 0.22, animations: { c.alpha = 0 }) { _ in c.removeFromSuperview() }
    }
    @objc private func tocarDesbloquear() { pedirDesbloqueo() }

    private func pedirDesbloqueo() {
        guard bloqueada, !pidiendo, enPrimerPlano else { return }
        taparPantalla()
        let ctx = LAContext()
        ctx.localizedCancelTitle = cnT("Ahora no")
        var error: NSError?
        // Cara o huella y, si no hay o falla, el código del teléfono.
        guard ctx.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            // Sin nada que pedir (teléfono sin código): no se puede bloquear.
            bloqueada = false; quitarCortinaBloqueo(); return
        }
        pidiendo = true
        ctx.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: cnT("Desbloquea Chinola para ver tus finanzas")) { [weak self] ok, _ in
            DispatchQueue.main.async {
                guard let s = self else { return }
                s.pidiendo = false
                if ok {
                    s.bloqueada = false
                    s.quitarCortinaBloqueo()
                } else {
                    // Se queda tapada, con el botón para volver a intentarlo.
                    s.cortinaBloqueo?.viewWithTag(77)?.isHidden = false
                }
            }
        }
    }

    // MARK: hablar con Chino
    //
    // La charla vive en la web (es quien habla con el servidor); aquí se
    // dibuja y, mientras Chino piensa, se vuelve a pedir cada medio segundo.
    private var charlaReloj: Timer?
    private func abrirCharla() {
        traerCharla()
        datos.onCharla = { [weak self] texto in
            guard let s = self else { return }
            s.eval("window.__chinolaCharla && window.__chinolaCharla(\(s.comillas(texto)))")
            s.vigilarCharla()
        }
        datos.onCharlaLimpiar = { [weak self] in
            self?.eval("window.__chinolaCharlaLimpiar && window.__chinolaCharlaLimpiar()")
            self?.traerCharla()
        }
        presentar(AnyView(CNCharlaVista(datos: datos, onClose: { [weak self] in
            self?.charlaReloj?.invalidate(); self?.charlaReloj = nil
            self?.cerrar()
            self?.traerDatos(intentos: 2); self?.traerResumen(intentos: 2)
        })))
    }
    private func traerCharla() {
        bridge?.webView?.evaluateJavaScript("(window.__chinolaCharlaJSON && window.__chinolaCharlaJSON()) || ''") { res, _ in
            if let json = res as? String, json.count > 2 { CNDatos.shared.cargarCharla(json: json) }
        }
    }
    private func vigilarCharla() {
        charlaReloj?.invalidate()
        var vueltas = 0
        charlaReloj = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] t in
            guard let s = self else { t.invalidate(); return }
            vueltas += 1
            s.traerCharla()
            if (CNDatos.shared.charla?.pensando == false && vueltas > 1) || vueltas > 120 { t.invalidate(); s.charlaReloj = nil }
        }
    }

    /**
     * AGREGAR UNA TARJETA, EN EL BANCO.
     *
     * «Agrego una tarjeta y no se agrega» no se puede perseguir leyendo: el
     * camino de la web ejecutado a mano SÍ la añade, así que lo que falla está
     * entre el dedo y ahí, o entre ahí y la pantalla. Con `CN_CON=agrega` el
     * banco entra en organizar, agrega una y dice cuántas había y cuántas hay.
     *
     * Si el número sube, lo que falla es el dibujo. Si no sube, no llegó.
     */
    private func bancoAgregaUna() {
        guard ProcessInfo.processInfo.environment["CN_CON"]?.contains("agrega") == true else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            guard let s = self else { return }
            let antes = CNDatos.shared.resumen?.widgets.count ?? -1
            let cual = CNDatos.shared.resumen?.catalogo.first?.id ?? "kpi-diario"
            NSLog("CNAGREGA: antes \(antes) · catalogo \(CNDatos.shared.resumen?.catalogo.count ?? -1) · agrego \(cual)")
            CNDatos.shared.onPanel("agregar", cual, "")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                let ahora = CNDatos.shared.resumen?.widgets.count ?? -1
                NSLog("CNAGREGA: despues \(ahora) · \(ahora > antes ? "SUBIÓ" : "NO SUBIÓ")")
                // Y lo que dice la web que tiene la libreta, para saber si se
                // guardó y lo que falla es el dibujo.
                s.bridge?.webView?.evaluateJavaScript("String(((window.__chinolaDatosJSON && JSON.parse(window.__chinolaDatosJSON()||'{}').panel)||[]).length)") { r, _ in
                    NSLog("CNAGREGA: la libreta dice \((r as? String) ?? "?") tarjetas en su panel")
                }
            }
        }
    }

    /// Al resumen, organizando: desde Perfil o desde donde sea.
    private func irAOrganizar() {
        menuEstado.activa = "resumen"; barra.pintar(activa: "resumen", titulos: menuEstado.titulos)
        eval("window.__chinolaMenu && window.__chinolaMenu('resumen')")
        mostrarNativo("resumen")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { CNDatos.shared.organizarPanel = true }
        bancoAgregaUna()
    }

    private func puertaAccion(_ que: String, _ valor: String) {
        // Los DOS argumentos, en su sitio. Mandarlos dentro de un objeto —que
        // es lo que hace `aWeb`— dejaba `que` como un objeto y ningún botón de
        // la puerta hacía nada: no se podía ni entrar.
        eval("window.__chinolaPuerta && window.__chinolaPuerta(\(comillas(que)),\(comillas(valor)))")
        // Escribir en un campo no cambia de pantalla; lo demás sí.
        guard que != "campo" && que != "nombre" else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { [weak self] in
            self?.mirarPuerta(intentos: 4)
            // Entrar con Apple o Google tarda lo que tarde su ventana.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) { self?.mirarPuerta(intentos: 3) }
        }
    }
    /// Dejar la puerta nativa y seguir en la de la web.
    private func puertaALaWeb() {
        barra.barra.isHidden = true
        quitarCortina()
        puertaReloj?.invalidate(); puertaReloj = nil
        if let host = puertaVC {
            puertaVC = nil
            host.willMove(toParent: nil); host.view.removeFromSuperview(); host.removeFromParent()
        }
        CNDatos.shared.puerta = nil
        puertaRendida = true
        mostrarWeb()
        // Y se sigue mirando: en cuanto entre, se monta lo nativo.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in self?.mirarPuerta(intentos: 300) }
    }
    /// Una vez que se ha ido a la web, la puerta nativa no vuelve a asomar en
    /// esta sesión: quien está entrando no necesita que le cambien la pantalla
    /// debajo de los dedos.
    private var puertaRendida = false

    private func cerrarPuerta() {
        barra.barra.isHidden = false
        quitarCortina()
        puertaReloj?.invalidate(); puertaReloj = nil
        guard let host = puertaVC else { return }
        puertaVC = nil
        UIView.animate(withDuration: 0.25) { host.view.alpha = 0 } completion: { _ in
            host.willMove(toParent: nil); host.view.removeFromSuperview(); host.removeFromParent()
            CNDatos.shared.puerta = nil
        }
        traerDatos(intentos: 8)
        mostrarNativo(menuEstado.activa)
    }

    // MARK: Chino en grande (mantener pulsado en Perfil)
    private var mascotaVC: UIViewController?
    fileprivate func abrirMascota() {
        bridge?.webView?.evaluateJavaScript("(window.__chinolaMascotaJSON && window.__chinolaMascotaJSON()) || ''") { [weak self] res, _ in
            guard let s = self else { return }
            if let json = res as? String, json.count > 2 { CNDatos.shared.cargarMascota(json: json) }
            guard s.mascotaVC == nil else { return }
            let host = UIHostingController(rootView: CNMascotaVista(datos: s.datos, onClose: { [weak self] in
                self?.cerrarMascota()
            }))
            host.view.backgroundColor = .clear
            s.addChild(host); s.view.addSubview(host.view); host.didMove(toParent: s)
            host.view.frame = s.view.bounds
            host.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            host.view.alpha = 0
            s.mascotaVC = host
            UIView.animate(withDuration: 0.2) { host.view.alpha = 1 }
        }
    }
    private func cerrarMascota() {
        guard let host = mascotaVC else { return }
        mascotaVC = nil
        UIView.animate(withDuration: 0.18) { host.view.alpha = 0 } completion: { _ in
            host.willMove(toParent: nil); host.view.removeFromSuperview(); host.removeFromParent()
        }
    }

    // MARK: el recorrido de bienvenida
    private var tourVC: UIViewController?
    private func mostrarTour() {
        // La pantalla de la que habla el paso, detrás del globo.
        if let v = CNDatos.shared.tour?.vista, nativas.contains(v) {
            menuEstado.activa = v
            barra.pintar(activa: v, titulos: menuEstado.titulos)
            mostrarNativo(v)
        }
        guard tourVC == nil else { return }
        let host = UIHostingController(rootView: CNTourVista(datos: datos, onPaso: { [weak self] que in
            self?.pasoDelTour(que)
        }))
        host.view.backgroundColor = .clear
        addChild(host); view.addSubview(host.view); host.didMove(toParent: self)
        host.view.frame = view.bounds
        host.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        host.view.alpha = 0
        tourVC = host
        UIView.animate(withDuration: 0.22) { host.view.alpha = 1 }
    }
    private func pasoDelTour(_ que: String) {
        eval("window.__chinolaTour && window.__chinolaTour(\(comillas(que)))")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
            guard let s = self else { return }
            s.bridge?.webView?.evaluateJavaScript("(window.__chinolaTourJSON && window.__chinolaTourJSON()) || ''") { res, _ in
                if let j = res as? String, j.count > 2 {
                    CNDatos.shared.cargarTour(json: j)
                    if let v = CNDatos.shared.tour?.vista, s.nativas.contains(v) {
                        s.menuEstado.activa = v
                        s.barra.pintar(activa: v, titulos: s.menuEstado.titulos)
                        s.mostrarNativo(v)
                        s.view.bringSubviewToFront(s.tourVC?.view ?? UIView())
                    }
                    return
                }
                s.cerrarTour()
            }
        }
    }
    private func cerrarTour() {
        guard let host = tourVC else { return }
        tourVC = nil
        UIView.animate(withDuration: 0.2) { host.view.alpha = 0 } completion: { _ in
            host.willMove(toParent: nil); host.view.removeFromSuperview(); host.removeFromParent()
            CNDatos.shared.tour = nil
        }
        mostrarNativo(menuEstado.activa)
        traerDatos(intentos: 3); traerResumen(intentos: 4)
    }

    /// La hoja de la web, dibujada en nativo y encima de todo.
    /// La web abrió una hoja: se pide su descripción y se dibuja NATIVA.
    ///
    /// Hasta ahora este camino solo lo abría una vista nativa. Con las
    /// pantallas en web hacía falta que lo pudiera pedir la web, o los
    /// formularios se quedaban dibujados por ella. Es el mismo mecanismo de
    /// siempre —la web describe los campos, el nativo los pinta—, solo que
    /// ahora la puerta está en los dos lados.
    /// El selector de libretas y la hoja del período, pedidos por la web.
    ///
    /// Los disparaba una vista nativa; con el contenido en web hacía falta que
    /// los pudiera pedir ella, o se quedaban dibujados por la web.
    @objc func abrirSelectorDeLaWeb() { refrescarLibretas(); abrirLibretas() }
    @objc func abrirPeriodoDeLaWeb() { abrirPeriodo() }

    @objc func abrirHojaDeLaWeb() {
        bridge?.webView?.evaluateJavaScript("(window.__chinolaHojaJSON && window.__chinolaHojaJSON()) || ''") { [weak self] res, _ in
            guard let s = self, let json = res as? String, json.count > 2 else { return }
            CNDatos.shared.cargarHojaWeb(json: json)
            s.presentarHojaWeb()
        }
    }

    private weak var hojaWebVC: UIViewController?
    private func presentarHojaWeb() {
        guard hojaWebVC == nil else { refrescarHojaWeb(); return }
        let host = UIHostingController(rootView: CNHojaWebViva(datos: datos, onClose: { [weak self] in
            self?.eval("window.__chinolaHojaCerrar && window.__chinolaHojaCerrar()")
            self?.cerrarHojaWeb()
        }))
        host.modalPresentationStyle = .pageSheet
        if let hoja = host.sheetPresentationController {
            hoja.detents = [.large()]
            hoja.prefersGrabberVisible = false
            hoja.preferredCornerRadius = 28
        }
        // Y SI SE CIERRA DESLIZÁNDOLA, que es como se cierra una hoja en iOS.
        //
        // El aviso a la web salía solo del botón de cerrar. Deslizándola hacia
        // abajo nadie se lo decía, así que la web se quedaba creyendo que la
        // hoja seguía abierta — y a partir de ahí, CUALQUIER toque en ajustes
        // preguntaba «¿hay algo abierto?», le decían que sí, y se volvía a
        // enseñar esa hoja vieja. Cambiabas de moneda y se te abría «Editar mi
        // perfil», que era la última que habías mirado.
        host.presentationController?.delegate = self
        hojaWebVC = host
        if let actual = presentedViewController {
            actual.dismiss(animated: true) { [weak self] in self?.present(host, animated: true) }
        } else {
            present(host, animated: true)
        }
    }
    private func cerrarHojaWeb() {
        hojaWebVC?.dismiss(animated: true) { [weak self] in
            guard let s = self else { return }
            CNDatos.shared.hojaWeb = nil
            s.traerDatos(intentos: 3); s.traerResumen(intentos: 4); s.traerAjustes(); s.traerTema()
            // Si había una subpantalla del perfil debajo, se repinta con lo
            // que acabe de cambiar.
            if let id = CNDatos.shared.seccion?.id { s.traerSeccion(id) }
            // Y el detalle que quedó debajo, también: se acaba de abonar, de
            // aportar o de pagar, y la cifra de arriba tiene que cambiar.
            if s.detalleVC != nil {
                s.refrescarDetalle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { s.refrescarDetalle() }
            }
            s.traerCuentas(); s.traerPlan()
        }
        hojaWebVC = nil
    }
    /// Tras escribir o guardar, la web devuelve el modelo nuevo (con su error o
    /// su «listo»); si ya no hay hoja, se cierra.
    private func refrescarHojaWeb() {
        bridge?.webView?.evaluateJavaScript("(window.__chinolaHojaJSON && window.__chinolaHojaJSON()) || ''") { [weak self] res, _ in
            guard let s = self else { return }
            if let json = res as? String, json.count > 2 {
                CNDatos.shared.cargarHojaWeb(json: json)
            } else {
                s.cerrarHojaWeb()
            }
        }
    }
    private func vigilarVuelta(_ intentos: Int) {
        guard volviendo, intentos > 0 else { volviendo = false; return }
        bridge?.webView?.evaluateJavaScript("!!(window.__chinolaHayHoja && window.__chinolaHayHoja())") { [weak self] r, _ in
            guard let s = self, s.volviendo else { return }
            if (r as? Bool) == false {
                s.volviendo = false
                let id = s.menuEstado.activa
                if s.nativas.contains(id) { s.mostrarNativo(id); s.refrescarPantalla(id) }
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { s.vigilarVuelta(intentos - 1) }
        }
    }

    // MARK: hojas y detalles nativos (presentados encima)
    private weak var hojaVC: UIViewController?
    private func presentar(_ vista: AnyView) {
        let mostrar = { [weak self] in
            guard let self = self else { return }
            let host = UIHostingController(rootView: vista)
            // Hoja del sistema: tirador, esquinas, atenuado y arrastre elástico
            // los pone iOS, como en cualquier app de Apple.
            host.modalPresentationStyle = .pageSheet
            if let hoja = host.sheetPresentationController {
                hoja.detents = [.large()]
                hoja.prefersGrabberVisible = false
                hoja.preferredCornerRadius = 28
            }
            // También con el arrastre: ver `presentarHojaWeb`.
            host.presentationController?.delegate = self
            self.hojaVC = host
            self.present(host, animated: true)
        }
        // Si ya hay algo encima (p.ej. el detalle al tocar «abonar»), se cierra
        // primero y se abre la nueva cuando termine.
        if let actual = presentedViewController {
            actual.dismiss(animated: true, completion: mostrar)
        } else {
            mostrar()
        }
    }
    private func cerrar() {
        hojaVC?.dismiss(animated: true) { [weak self] in self?.traerDatos(intentos: 3) }
    }

    // MARK: barra de menú nativa
    /// Un `UITabBar` de VERDAD: en iOS 26 trae el Liquid Glass del sistema (la
    /// lente que se desliza a la pestaña elegida, el brillo de los bordes). Una
    /// barra dibujada a mano se ve como cristal, pero está quieta.
    /// Cuánto ocupa la barra nativa de abajo, dicho a la web.
    ///
    /// Cuando una pantalla se dibuja en web (el modelo de Batuta: navegación y
    /// menús nativos, contenido web), la web necesita saber cuánto hueco
    /// dejarle a la barra o el contenido se le mete debajo. Batuta hace lo
    /// mismo con el alto de su cabecera (`--cabecera-alto`).
    ///
    /// Se manda el alto REAL, que cambia: la barra se encoge al bajar por la
    /// pantalla, y el margen seguro de abajo varía entre aparatos.
    fileprivate func avisarAltoBarra() {
        let alto = barra.barra.frame.height + view.safeAreaInsets.bottom
        guard alto > 0 else { return }
        eval("document.documentElement.style.setProperty('--menu-alto','\(Int(alto.rounded()))px')")
    }

    /// EL BOTÓN DE CHINO, POR ENCIMA DE TODO.
    ///
    /// Va en su propio contenedor transparente, colocado después de la barra
    /// del menú: la gracia es poder hablarle sin salir de donde estés, también
    /// desde encima de la barra. El contenedor no recibe toques salvo en el
    /// botón: una vista de SwiftUI transparente no recibe toques donde no hay
    /// nada dibujado, así que el resto de la pantalla sigue respondiendo sola.
    private weak var flotanteVista: UIView?

    /// La web dice que quiere el botón. Solo entonces se monta.
    @objc private func pidenElFlotante() {
        if !sin("flotante") { montarFlotante() }
    }

    /// EL BOTÓN DE CHINO, MONTADO SOLO CUANDO HACE FALTA.
    ///
    /// Esto se montaba en cada arranque, aunque el botón estuviera apagado. Y
    /// no es un detalle: Capacitor hace `view = webView`, así que añadir aquí
    /// un huésped de SwiftUI a pantalla completa es meterlo DENTRO del propio
    /// WKWebView, en el primer fotograma y antes de que la página haya corrido
    /// nada. Es lo único que el controlador ganó entre la última versión que
    /// abría bien y la primera que abría en blanco.
    ///
    /// Ahora no se monta hasta que la web lo pide —y solo lo pide con la IA
    /// encendida y el botón puesto—, así que al arrancar la app hace
    /// exactamente lo mismo que hacía cuando funcionaba.
    private func montarFlotante() {
        guard flotanteVista == nil else { return }
        CNFlotante.shared.alTocar = { [weak self] in self?.abrirCharla() }
        // Y la misma charla cuando se entra por Perfil, que antes abría la de
        // la web: dos caras para lo mismo y la de Perfil se sentía prestada.
        NotificationCenter.default.addObserver(forName: Notification.Name("cnAbrirCharla"),
                                               object: nil, queue: .main) { [weak self] _ in
            self?.abrirCharla()
        }
        CNFlotante.shared.alMover = { [weak self] x, y in
            // Dónde quedó se guarda en la web, que es lo que sobrevive a
            // cerrar la app.
            self?.eval("window.__chinolaFlotante && window.__chinolaFlotante(\(x), \(y))")
        }
        // DENTRO DE UNA CAJA que deja pasar los toques.
        //
        // La vista que aloja el SwiftUI ocupa la pantalla entera y se queda con
        // TODOS los toques: con ella suelta, la app se veía bien y no respondía
        // a nada salvo al propio botón —ni cambiar de pestaña—. La caja
        // pregunta punto por punto si ahí hay algo dibujado, y si no, el toque
        // sigue hacia abajo. Ver `CNPasaToques`.
        let host = CNPasaToquesHost(rootView: AnyView(CNBotonFlotante(datos: datos)))
        host.view.backgroundColor = .clear
        host.view.isOpaque = false
        let caja = CNPasaToques()
        caja.backgroundColor = .clear
        caja.isOpaque = false
        addChild(host)
        caja.addSubview(host.view)
        view.addSubview(caja)
        host.didMove(toParent: self)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        caja.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            caja.topAnchor.constraint(equalTo: view.topAnchor),
            caja.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            caja.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            caja.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            host.view.topAnchor.constraint(equalTo: caja.topAnchor),
            host.view.leadingAnchor.constraint(equalTo: caja.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: caja.trailingAnchor),
            host.view.bottomAnchor.constraint(equalTo: caja.bottomAnchor)
        ])
        flotanteVista = caja
        // Arriba del todo desde ya: si entra con una pantalla nativa puesta,
        // sin esto nace debajo.
        view.bringSubviewToFront(caja)
        NSLog("CNFLOTA: el botón de Chino, montado")
    }

    private func montarBarra() {
        guard barra.barra.superview == nil else { return }
        barra.alTocar = { [weak self] id in self?.menuEstado.alTocar(id) }
        barra.montar(en: view)
        barra.pintar(activa: menuEstado.activa, titulos: menuEstado.titulos)
        // La barra se encoge al bajar por cualquier pantalla y vuelve al subir.
        CNScrollEstado.shared.alCambiar = { [weak self] compacto in
            self?.barra.compactar(compacto)
            // La barra cambió de alto: la web tiene que reajustar su hueco.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) { self?.avisarAltoBarra() }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in self?.avisarAltoBarra() }
        // Mantener pulsado un botón del menú: el atajo de esa pestaña, desde
        // donde sea. Anotar es el más usado, así que está en dos.
        datos.onMascota = { [weak self] in self?.abrirMascota() }
        datos.onCategoria = { [weak self] que, valor in
            guard let s = self else { return }
            s.eval("window.__chinolaCat && window.__chinolaCat(\(s.comillas(que)),\(s.comillas(valor)))")
            // Elegir icono, color o tipo cambia cómo se ve la hoja.
            if que == "icono" || que == "color" || que == "tipo" {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    s.bridge?.webView?.evaluateJavaScript("(window.__chinolaCatJSON && window.__chinolaCatJSON()) || ''") { r, _ in
                        if let j = r as? String, j.count > 2 { CNDatos.shared.cargarCategoria(json: j) }
                    }
                }
            }
        }
        barra.alMantener = { [weak self] id in
            guard let s = self else { return }
            switch id {
            case "movs", "resumen": s.datos.onNuevoMov()
            case "cuentas": s.datos.onAgregar()
            case "plan": s.datos.onPlanAccion(CNDatos.shared.plan?.tab == "metas" ? "nuevaMeta" : "nuevaCat", 0)
            case "perfil": s.abrirMascota()
            default: break
            }
        }
        menuEstado.alAviso = { [weak self] titulo, texto in self?.mostrarAviso(titulo, texto) }
        menuEstado.alSeccion = { [weak self] in
            guard let s = self, let id = CNDatos.shared.seccion?.id else { return }
            s.traerSeccion(id)
        }
        menuEstado.alRepintar = { [weak self] in
            guard let s = self else { return }
            s.barra.pintar(activa: s.menuEstado.activa, titulos: s.menuEstado.titulos)
            // El icono de Perfil (Chino o la silueta) se vuelve a poner con el
            // tema: es aquí donde llega el cambio de ajuste, y antes no se veía
            // hasta cambiar de pestaña.
            s.barra.ponerChinolo(CNDatos.shared.mascota?.chinolo ?? "")
            // Y el modo claro/oscuro del sistema (vidrio, menús, barra de
            // estado) en la MISMA pasada que los colores: antes llegaba por
            // otro camino, un rato después, y el cambio de tema se veía en dos
            // tiempos.
            s.ponerModoDeLaPaleta()
            s.contenedorNativo?.backgroundColor = UIColor(CNC.scr)
            s.setNeedsStatusBarAppearanceUpdate()
        }
    }

    /// Deja hueco abajo para que la lista no quede tapada por la barra flotante.
    private func ajustarHueco(_ host: UIViewController) {
        view.layoutIfNeeded()
        let alto = max(barra.alto, 56) + 6
        host.additionalSafeAreaInsets.bottom = max(0, alto - view.safeAreaInsets.bottom)
    }

}

/**
 * CUANDO UNA HOJA SE CIERRA DESLIZÁNDOLA.
 *
 * En iOS una hoja se cierra arrastrándola hacia abajo, y eso NO pasa por el
 * botón de cerrar. El aviso a la web salía solo del botón, así que deslizándola
 * la web se quedaba creyendo que seguía abierta.
 *
 * Y a partir de ahí, cualquier toque en ajustes preguntaba «¿hay algo
 * abierto?», le decían que sí, y se volvía a enseñar ESA hoja vieja: cambiabas
 * de moneda y se te abría «Editar mi perfil», que era la última que habías
 * mirado. Parecía caché y era una hoja que nadie había cerrado.
 */
extension ChinolaViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ p: UIPresentationController) {
        // La de la web hay que contársela a ella; la nativa solo se olvida.
        if p.presentedViewController === hojaWebVC {
            eval("window.__chinolaHojaCerrar && window.__chinolaHojaCerrar()")
            hojaWebVC = nil
            CNDatos.shared.hojaWeb = nil
            traerDatos(intentos: 3); traerResumen(intentos: 4); traerAjustes()
        } else if p.presentedViewController === hojaVC {
            hojaVC = nil
            traerDatos(intentos: 3)
        }
    }
}

extension ChinolaViewController: UIGestureRecognizerDelegate {
    /// El gesto de la orilla solo entra cuando hay una subpantalla de Perfil
    /// abierta. Así la web y las listas siguen recibiendo el dedo como siempre.
    func gestureRecognizerShouldBegin(_ g: UIGestureRecognizer) -> Bool {
        guard g is UIScreenEdgePanGestureRecognizer else { return true }
        return datos.seccion != nil && detalleVC == nil
    }
}

extension ChinolaViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let u = urls.first else { return }
        let acceso = u.startAccessingSecurityScopedResource()
        defer { if acceso { u.stopAccessingSecurityScopedResource() } }
        guard let datos = try? Data(contentsOf: u) else { return }
        // UTF-8 o, si no, Latin-1: los bancos exportan de las dos maneras.
        let texto = String(data: datos, encoding: .utf8) ?? String(data: datos, encoding: .isoLatin1) ?? ""
        guard !texto.isEmpty else { return }
        eval("window.__chinolaImportaCsv && window.__chinolaImportaCsv(\(comillas(texto)))")
        // Un archivo de Chinola abre la hoja de «qué traer»: se dibuja nativa.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            guard let s = self else { return }
            s.bridge?.webView?.evaluateJavaScript("!!(window.__chinolaHayHoja && window.__chinolaHayHoja())") { r, _ in
                if (r as? Bool) == true { s.presentarHojaWeb() } else { s.refrescarPronto() }
            }
        }
    }
}
