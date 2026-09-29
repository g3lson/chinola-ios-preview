// ¿Y una herramienta, lo mínimo que se puede escribir?
import FoundationModels

@available(iOS 26.0, *)
struct HerramientaMinima: Tool {
    let name = "minima"
    let description = "no hace nada"

    @Generable
    struct Arguments {
        @Guide(description: "el mes, 2026-09")
        var mes: String
    }

    func call(arguments a: Arguments) async throws -> String {
        return "hola " + a.mes
    }
}
