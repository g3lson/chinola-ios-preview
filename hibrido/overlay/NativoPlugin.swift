import Foundation
import Capacitor
import SwiftUI
import UIKit

/**
 * Puente para incrustar pantallas NATIVAS (SwiftUI) dentro de la app Capacitor.
 *
 * La web llama a `Nativo.abrirTendencia({ datos })` pasando el JSON de la libreta
 * activa (el de localStorage). Aquí se decodifica y se presenta la pantalla
 * SwiftUI encima del webview. Cuando el usuario la cierra, se resuelve la promesa
 * y la web sigue como estaba. Así se migra pantalla por pantalla sin romper nada.
 */
@objc(NativoPlugin)
public class NativoPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "NativoPlugin"
    public let jsName = "Nativo"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "abrirTendencia", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "menuActiva", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "menuTitulos", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "abrirCharla", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "iconoApp", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "flotante", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "datos", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "tema", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "aviso", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "seccion", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "bloqueo", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "sesion", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "periodo", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "hoja", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "formulario", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "selector", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "hojaPeriodo", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "fallo", returnType: CAPPluginReturnPromise),
        // La sincronización, cuando la lleva el teléfono.
        CAPPluginMethod(name: "nubeManda", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "nubeTraer", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "nubeEmpujar", returnType: CAPPluginReturnPromise)
    ]

    // Los pone ChinolaViewController; son el estado de la barra y los datos que
    // las pantallas nativas leen.
    weak var menuEstado: CNMenuEstado?
    weak var store: CNDatos?

    // La web empuja el JSON de la libreta activa (y el perfil) cada vez que cambia.
    @objc func datos(_ call: CAPPluginCall) {
        let json = call.getString("json") ?? "{}"
        let perfil = call.getString("perfil")
        DispatchQueue.main.async {
            // Al store COMPARTIDO (esta instancia puede no ser la del VC).
            CNDatos.shared.cargar(json: json)
            if let p = perfil { CNDatos.shared.cargarPerfil(json: p) }
            call.resolve()
        }
    }

    // El período elegido: mes y, si lo hay, el rango a medida.
    //
    // Es lo que le faltaba al nativo para calcular por su cuenta. Con esto y
    // la libreta, CNCalculo saca las cifras sin cruzar el puente.
    @objc func periodo(_ call: CAPPluginCall) {
        let mes = call.getString("mes") ?? ""
        let desde = call.getString("desde") ?? ""
        let hasta = call.getString("hasta") ?? ""
        DispatchQueue.main.async {
            CNDatos.shared.ponPeriodo(mes: mes, desde: desde, hasta: hasta)
            call.resolve()
        }
    }

    /// El selector de libretas, nativo, pedido por la web.
    @objc func selector(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("cnAbrirSelector"), object: nil)
            call.resolve()
        }
    }

    /// La hoja del período (los presets y el calendario), nativa.
    @objc func hojaPeriodo(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("cnAbrirPeriodo"), object: nil)
            call.resolve()
        }
    }

    /// La web acaba de abrir una hoja de formulario: que la dibuje el nativo.
    ///
    /// El mecanismo ya existía —la web describe los campos en
    /// `__chinolaHojaJSON` y CNHojaWeb los pinta—, pero solo lo disparaba una
    /// vista nativa. Con las pantallas en web hacía falta esta puerta.
    @objc func formulario(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("cnAbrirHoja"), object: nil)
            call.resolve()
        }
    }

    /// Una hoja de acciones DEL SISTEMA, pedida por la web.
    ///
    /// La puerta que le faltaba a Chinola. Hasta ahora los menús nativos
    /// vivían dentro de las vistas SwiftUI, así que una pantalla dibujada en
    /// web se quedaba con los menús de la web. Con esto la web puede pedir el
    /// menú de iOS desde donde sea, igual que hace Batuta.
    ///
    /// { titulo, mensaje, opciones: [{ texto, estilo: normal|peligro|cancelar }] }
    /// → { indice }, y -1 si se cancela.
    @objc func hoja(_ call: CAPPluginCall) {
        let titulo = call.getString("titulo") ?? ""
        let mensaje = call.getString("mensaje") ?? ""
        let opciones = call.getArray("opciones", JSObject.self) ?? []
        DispatchQueue.main.async {
            guard var arriba = self.bridge?.viewController else { call.reject("sin vista"); return }
            while let siguiente = arriba.presentedViewController, !siguiente.isBeingDismissed {
                arriba = siguiente
            }
            if arriba is UIAlertController { call.reject("ocupado"); return }
            let alerta = UIAlertController(title: titulo.isEmpty ? nil : titulo,
                                           message: mensaje.isEmpty ? nil : mensaje,
                                           preferredStyle: .actionSheet)
            var respondida = false
            for (i, o) in opciones.enumerated() {
                let estilo: UIAlertAction.Style
                switch o["estilo"] as? String {
                case "peligro": estilo = .destructive
                case "cancelar": estilo = .cancel
                default: estilo = .default
                }
                alerta.addAction(UIAlertAction(title: o["texto"] as? String ?? "", style: estilo) { _ in
                    guard !respondida else { return }
                    respondida = true
                    call.resolve(["indice": estilo == .cancel ? -1 : i])
                })
            }
            // En el iPad una hoja de acciones necesita de dónde nacer.
            if let pop = alerta.popoverPresentationController {
                pop.sourceView = arriba.view
                pop.sourceRect = CGRect(x: arriba.view.bounds.midX, y: arriba.view.bounds.midY, width: 1, height: 1)
                pop.permittedArrowDirections = []
            }
            arriba.present(alerta, animated: true)
        }
    }

    // La web manda el tema puesto (31 temas): las pantallas nativas pintan con él.
    /**
     * LA WEB DICE QUE NO PUDO ARRANCAR.
     *
     * El cartel que pinta la web queda TAPADO por las pantallas nativas, que van
     * encima del webview: quien abre la app ve blanco y no se entera de nada.
     * Esto lo enseña desde el lado nativo, por encima de todo.
     */
    @objc func fallo(_ call: CAPPluginCall) {
        let texto = call.getString("texto") ?? "sin detalle"
        DispatchQueue.main.async {
            CNAvisoDeFallo.shared.mostrar(texto)
            call.resolve()
        }
    }

    @objc func tema(_ call: CAPPluginCall) {
        let json = call.getString("json") ?? ""
        DispatchQueue.main.async {
            // El primer tema es la señal de que la web arrancó: con él se apaga
            // el vigía que avisa cuando no llega nada.
            CNAvisoDeFallo.shared.laWebContesto()
            CNDatos.shared.cargarTema(json: json)
            CNMenuEstado.shared.alRepintar()
            call.resolve()
        }
    }

    // La web avisa qué pestaña quedó activa, para que la barra la resalte.
    @objc func menuActiva(_ call: CAPPluginCall) {
        let id = call.getString("id") ?? "resumen"
        DispatchQueue.main.async { CNMenuEstado.shared.activa = id; CNMenuEstado.shared.alRepintar(); call.resolve() }
    }

    // La sesión, para Siri: el atajo habla con el servidor sin pasar por la web.
    @objc func sesion(_ call: CAPPluginCall) {
        let token = call.getString("token") ?? ""
        DispatchQueue.main.async {
            if token.isEmpty { UserDefaults.standard.removeObject(forKey: "cnSesion") }
            else { UserDefaults.standard.set(token, forKey: "cnSesion") }
            call.resolve()
        }
    }

    // Bloquear con Face ID al volver a la app. Se guarda aquí, en el
    // teléfono: tiene que valer antes de que la web haya arrancado.
    @objc func bloqueo(_ call: CAPPluginCall) {
        let on = call.getBool("on") ?? false
        DispatchQueue.main.async {
            UserDefaults.standard.set(on, forKey: "cnBloqueo")
            NotificationCenter.default.post(name: Notification.Name("cnBloqueoCambiado"), object: nil, userInfo: ["on": on])
            call.resolve()
        }
    }

    // La subpantalla del perfil abierta tiene datos nuevos: se vuelve a pedir.
    @objc func seccion(_ call: CAPPluginCall) {
        DispatchQueue.main.async { CNMenuEstado.shared.alSeccion(); call.resolve() }
    }

    // Un aviso corto de la web, dibujado en nativo.
    @objc func aviso(_ call: CAPPluginCall) {
        let titulo = call.getString("titulo") ?? ""
        let texto = call.getString("texto") ?? ""
        DispatchQueue.main.async { CNMenuEstado.shared.alAviso(titulo, texto); call.resolve() }
    }

    // Mostrar u ocultar los títulos del menú (ajuste de la app).
    @objc func menuTitulos(_ call: CAPPluginCall) {
        let on = call.getBool("on") ?? true
        DispatchQueue.main.async { CNMenuEstado.shared.titulos = on; CNMenuEstado.shared.alRepintar(); call.resolve() }
    }

    /// Abrir la charla de Chino, la nativa. La pide la web cuando alguien entra
    /// por Perfil, para que no haya dos charlas distintas según por dónde
    /// llegues.
    @objc func abrirCharla(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("cnAbrirCharla"), object: nil)
            call.resolve()
        }
    }

    /**
     * EL ICONO DE LA APP, EL QUE SE VE EN LA PANTALLA DE INICIO.
     *
     * iOS deja cambiarlo entre una lista fija declarada en el `Info.plist`: no
     * se puede mandar una imagen nueva, solo elegir una de las que vienen en el
     * paquete. Por eso los nueve se generan al compilar desde `iconos-app.js`,
     * que es donde están dibujados.
     *
     * `nil` vuelve al de siempre. Y el aviso que sale al cambiarlo lo pone el
     * propio sistema: no se puede quitar, y es mejor así — que el icono de una
     * app cambie solo sin decir nada asustaría a cualquiera.
     */
    @objc func iconoApp(_ call: CAPPluginCall) {
        let cual = call.getString("cual") ?? ""
        DispatchQueue.main.async {
            guard UIApplication.shared.supportsAlternateIcons else {
                call.resolve(["ok": false, "motivo": "no-soportado"]); return
            }
            let nombre: String? = cual.isEmpty ? nil : "Chinola-" + cual
            // Pedir el que ya está puesto hace que iOS enseñe el aviso otra vez
            // sin que haya cambiado nada.
            if nombre == UIApplication.shared.alternateIconName {
                call.resolve(["ok": true, "sinCambios": true]); return
            }
            UIApplication.shared.setAlternateIconName(nombre) { error in
                if let e = error {
                    NSLog("CNICONO: no se pudo poner \(nombre ?? "el de siempre"): \(e.localizedDescription)")
                    call.resolve(["ok": false, "motivo": e.localizedDescription])
                } else {
                    call.resolve(["ok": true])
                }
            }
        }
    }

    /// El botón flotante de Chino: puesto o no, y dónde quedó (0…1).
    @objc func flotante(_ call: CAPPluginCall) {
        let puesto = call.getBool("puesto") ?? false
        let x = CGFloat(call.getDouble("x") ?? 1)
        let y = CGFloat(call.getDouble("y") ?? 0.72)
        DispatchQueue.main.async {
            // Por `ponDesdeLaWeb`, que no pisa el sitio mientras el dedo
            // acaba de moverlo: la web devuelve lo que el propio botón le
            // acaba de mandar, y esa vuelta cortaba la animación en seco.
            CNFlotante.shared.ponDesdeLaWeb(puesto: puesto, x: x, y: y)
            // El contenedor del botón se monta AQUÍ, no al arrancar: es una
            // vista que acaba dentro del webview, y meterla antes de que la
            // página corra es lo que dejaba la app en blanco.
            if puesto { NotificationCenter.default.post(name: Notification.Name("cnFlotantePuesto"), object: nil) }
        }
        call.resolve()
    }

    @objc func abrirTendencia(_ call: CAPPluginCall) {
        let datos = call.getString("datos") ?? "{}"
        DispatchQueue.main.async {
            guard let libreta = CNLibreta.desde(json: datos) else {
                call.reject("No pude leer los datos de la libreta.")
                return
            }
            guard let host = self.bridge?.viewController else {
                call.reject("Sin vista donde presentar.")
                return
            }
            var hosting: UIHostingController<CNTendencia>!
            hosting = UIHostingController(rootView: CNTendencia(libreta: libreta, onClose: {
                hosting.dismiss(animated: true) { call.resolve() }
            }))
            hosting.modalPresentationStyle = .fullScreen
            host.present(hosting, animated: true)
        }
    }
    // MARK: - La sincronización, llevada por el teléfono
    //
    // La web deja de hablar con el servidor y pasa a pedírselo aquí. Todo lo
    // que se hace DESPUÉS —adoptar lo conciliado, avisar de que te sacaron de
    // una libreta, aplicar un renombrado— se queda en la web: así sigue habiendo
    // UNA sola mano escribiendo la libreta, y lo que se muda es la red.

    /// ¿Sincroniza el teléfono? Solo si tiene con qué: la copia y el vale.
    @objc func nubeManda(_ call: CAPPluginCall) {
        let si = CNNube.elTelefonoManda
        // Queda dicho en el log: es la única manera de saber DESDE FUERA quién
        // está hablando con el servidor. Si esto no sale, la web ni preguntó —o
        // sea que el puente no está enchufado y sigue sincronizando ella—.
        // Sin acentos: `log show` reescribe lo que no es ASCII y la sonda
        // dejaría de reconocer su propia línea.
        NSLog("CNMANDO: %@ copia=%@ vale=%@", si ? "telefono" : "web",
              CNAlmacen.libretas().isEmpty ? "no" : "si",
              CNAlmacen.vale().isEmpty ? "no" : "si")
        call.resolve(["si": si])
    }

    @objc func nubeTraer(_ call: CAPPluginCall) {
        Task {
            do {
                let libretas = try await CNNube.traer()
                call.resolve(["libretas": libretas])
            } catch {
                call.reject(String(describing: error))
            }
        }
    }

    @objc func nubeEmpujar(_ call: CAPPluginCall) {
        // SI NO SE PUEDEN LEER LAS LIBRETAS, NO SE SUBE NADA.
        //
        // Un empuje va marcado como «completo», y eso le dice al servidor que
        // pode las libretas que no vengan en él. Una lista vacía por un fallo de
        // lectura —un tipo que no casa, un puente a medias— sería decirle al
        // servidor que esta cuenta ya no tiene ninguna, y borrarlas TODAS.
        //
        // Se distingue «no se pudo leer» (nulo) de «de verdad no hay ninguna»
        // (lista vacía), que son dos cosas muy distintas: la primera se rechaza
        // y la web lo reintenta por su cuenta; la segunda es legítima —a quien
        // solo le han compartido libretas de lectura no sube ninguna—.
        guard let libretas = call.getArray("libretas", [String: Any].self) else {
            call.reject("no pude leer las libretas: no subo nada")
            return
        }
        Task {
            do {
                let r = try await CNNube.empujar(libretas)
                var fuera: [String: Any] = [
                    "limite": r.limite,
                    "sinPermiso": r.sinPermiso,
                    "renombradas": r.renombradas.map { ["de": $0.de, "a": $0.a] },
                    "perdidas": r.perdidas
                ]
                // `fusionadas` va como NULO cuando no hizo falta conciliar: la
                // web lo distingue y solo adopta la lista cuando hay algo que
                // adoptar. Mandar una lista vacía sería decirle que se quedó sin
                // libretas.
                if let f = r.fusionadas { fuera["fusionadas"] = f }
                call.resolve(fuera)
            } catch {
                call.reject(String(describing: error))
            }
        }
    }

}
