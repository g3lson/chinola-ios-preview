import Foundation
import Capacitor
#if canImport(FoundationModels)
import FoundationModels
#endif

/**
 * CHINO SIN SALIR DEL TELÉFONO.
 *
 * Apple trae desde iOS 26 un modelo dentro del propio aparato
 * (`FoundationModels`). Con él, hablarle a Chino no manda nada a ningún
 * servidor: ni a Chinola, ni a OpenAI, ni a nadie. Tus números no salen del
 * teléfono y no se gasta cuota de nadie.
 *
 * No está en todos los aparatos: hace falta iOS 26, un modelo compatible y que
 * la persona tenga Apple Intelligence encendido en Ajustes. Por eso lo primero
 * que se pregunta es si se puede, y la opción solo se ofrece cuando la
 * respuesta es que sí.
 *
 * Lo que SÍ sale a internet aunque esto esté puesto: lo que llega por
 * WhatsApp, por Telegram o por Siri, porque eso lo recibe el servidor y el
 * modelo vive aquí. Se dice con todas las letras en la pantalla de ajustes;
 * prometer lo contrario sería mentir.
 */
@objc(IALocalPlugin)
public class IALocalPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "IALocalPlugin"
    public let jsName = "IALocal"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "disponible", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "pregunta", returnType: CAPPluginReturnPromise)
    ]

    /// ¿Se puede usar aquí? Y si no, POR QUÉ: no es lo mismo «este iPhone no
    /// puede» que «está apagado en Ajustes», y la segunda tiene arreglo.
    @objc func disponible(_ call: CAPPluginCall) {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            let modelo = SystemLanguageModel.default
            switch modelo.availability {
            case .available:
                call.resolve(["puede": true, "motivo": ""])
            case .unavailable(.deviceNotEligible):
                call.resolve(["puede": false, "motivo": "aparato"])
            case .unavailable(.appleIntelligenceNotEnabled):
                call.resolve(["puede": false, "motivo": "apagado"])
            case .unavailable(.modelNotReady):
                call.resolve(["puede": false, "motivo": "descargando"])
            @unknown default:
                call.resolve(["puede": false, "motivo": "no"])
            }
            return
        }
        #endif
        call.resolve(["puede": false, "motivo": "ios"])
    }

    /// Una vuelta de conversación con el modelo del teléfono.
    ///
    /// Se le pasa la instrucción del sistema y lo dicho hasta ahora, y devuelve
    /// lo que contesta. Las herramientas NO se le dan aquí: las decide la parte
    /// web, que es la que sabe de libretas, y este método se usa para la
    /// conversación. Así el modelo local y los de fuera se usan igual desde
    /// arriba.
    @objc func pregunta(_ call: CAPPluginCall) {
        let sistema = call.getString("sistema") ?? ""
        let entrada = call.getString("entrada") ?? ""
        guard !entrada.isEmpty else { call.reject("No hay nada que preguntar."); return }

        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            Task {
                do {
                    let sesion = LanguageModelSession(instructions: sistema)
                    let r = try await sesion.respond(to: entrada)
                    call.resolve(["texto": r.content])
                } catch {
                    // El motivo tal cual: «la petición es muy larga», «el modelo
                    // se está descargando», «lo rechazó por seguridad». Cada uno
                    // se arregla de una manera y esconderlos no ayuda a nadie.
                    call.reject(String(describing: error))
                }
            }
            return
        }
        #endif
        call.reject("Este teléfono no puede usar la IA de Apple.")
    }
}
