import Foundation
import Capacitor
import SwiftUI

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
        CAPPluginMethod(name: "datos", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "tema", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "aviso", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "seccion", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "bloqueo", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "sesion", returnType: CAPPluginReturnPromise)
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

    // La web manda el tema puesto (31 temas): las pantallas nativas pintan con él.
    @objc func tema(_ call: CAPPluginCall) {
        let json = call.getString("json") ?? ""
        DispatchQueue.main.async {
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
}
