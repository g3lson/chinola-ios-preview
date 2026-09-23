import Foundation
import AppIntents

// Siri y Atajos: «Anota en Chinola 500 de comida», «Pregúntale a Chinola cómo
// va el mes». La frase entera va al mismo asistente que usan Telegram, WhatsApp
// y Alexa (/api/asistente), con la sesión que la app dejó guardada. No abre la
// app: Siri lee la respuesta.
@available(iOS 16.0, *)
struct CNHablarIntent: AppIntent {
    static var title: LocalizedStringResource = "Hablar con Chinola"
    static var description = IntentDescription("Anota un gasto o pregunta por tu dinero, en tus palabras.")
    static var openAppWhenRun = false

    @Parameter(title: "Qué", requestValueDialog: "¿Qué anoto o qué quieres saber?")
    var texto: String

    static var parameterSummary: some ParameterSummary {
        Summary("Dile a Chinola \(\.$texto)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let token = UserDefaults.standard.string(forKey: "cnSesion"), !token.isEmpty else {
            return .result(dialog: "Primero entra en Chinola en el teléfono.")
        }
        var req = URLRequest(url: URL(string: "https://chinola.fente.com.do/api/asistente")!)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "content-type")
        req.setValue("Bearer " + token, forHTTPHeaderField: "authorization")
        req.timeoutInterval = 25
        req.httpBody = try? JSONSerialization.data(withJSONObject: ["texto": texto, "canal": "siri"])
        do {
            let (datos, resp) = try await URLSession.shared.data(for: req)
            let j = (try? JSONSerialization.jsonObject(with: datos)) as? [String: Any] ?? [:]
            let estado = (resp as? HTTPURLResponse)?.statusCode ?? 0
            if estado >= 300 {
                let e = (j["error"] as? String) ?? "No pude hablar con Chinola."
                return .result(dialog: IntentDialog(stringLiteral: e))
            }
            let dicho = (j["texto"] as? String) ?? "Listo."
            return .result(dialog: IntentDialog(stringLiteral: dicho))
        } catch {
            return .result(dialog: "No pude conectar con Chinola. Prueba en un momento.")
        }
    }
}

@available(iOS 16.0, *)
struct CNAtajos: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CNHablarIntent(),
            // Las frases de Siri no admiten texto libre dentro: se dice «Anota en
            // Chinola» y Siri pregunta «¿Qué anoto?»; ahí va la frase entera.
            phrases: [
                "Anota en \(.applicationName)",
                "Dile a \(.applicationName)",
                "Pregúntale a \(.applicationName)",
                "Habla con \(.applicationName)"
            ],
            shortTitle: "Hablar con Chinola",
            systemImageName: "bubble.left.and.text.bubble.right"
        )
    }
}
