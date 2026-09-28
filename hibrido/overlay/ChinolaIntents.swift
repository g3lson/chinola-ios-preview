import Foundation
import AppIntents

// Siri y Atajos: «Anota en Chinola 500 de comida», «Pregúntale a Chinola cómo
// va el mes». La frase entera va al mismo asistente que usan Telegram, WhatsApp
// y Alexa (/api/asistente), con la sesión que la app dejó guardada. No abre la
// app: Siri lee la respuesta.
@available(iOS 16.0, *)
struct CNHablarIntent: AppIntent {
    // `LocalizedStringResource` se traduce con el catálogo de cadenas de la
    // app, igual que las frases: en inglés y en francés salen en su idioma.
    static var title: LocalizedStringResource = "Hablar con Chinola"
    static var description = IntentDescription("Anota un gasto o pregunta por tu dinero, en tus palabras.")
    static var openAppWhenRun = false

    // Siri pregunta esto cuando la frase no trae el texto dentro (que es
    // siempre: los atajos no admiten texto libre en la frase).
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
        // El idioma del teléfono va con la pregunta: Siri en francés tiene que
        // recibir la respuesta en francés, no en español.
        let idioma = Locale.preferredLanguages.first.map { String($0.prefix(2)) } ?? "es"
        req.httpBody = try? JSONSerialization.data(
            withJSONObject: ["texto": texto, "canal": "siri", "idioma": idioma])
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
            // Estas frases NO son texto suelto: son las claves de los
            // `AppShortcuts.strings` de cada .lproj, donde están sus versiones
            // en inglés y francés. Apple registra los atajos solo para los
            // idiomas en que la app está localizada, así que sin esos archivos
            // Siri en inglés o en francés no casa con ninguna y se limita a
            // abrir la app.
            //
            // En .strings y no en catálogo (.xcstrings): el catálogo pide iOS
            // 17 y Chinola arranca en la 15, y Xcode se niega a compilarlo.
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
