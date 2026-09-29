// La otra mitad: abrir la sesión con instrucciones y herramientas.
import FoundationModels

@available(iOS 26.0, *)
struct HerramientaMinima2: Tool {
    let name = "minima"
    let description = "no hace nada"
    @Generable
    struct Arguments {
        @Guide(description: "el mes, 2026-09")
        var mes: String
    }
    func call(arguments a: Arguments) async throws -> String { return a.mes }
}

@available(iOS 26.0, *)
func pregunta(_ sistema: String, _ entrada: String) async throws -> String {
    switch SystemLanguageModel.default.availability {
    case .available: break
    default: return "no disponible"
    }
    let s = LanguageModelSession(tools: [HerramientaMinima2()], instructions: sistema)
    let r = try await s.respond(to: entrada)
    return r.content
}
