// La misma herramienta SIN los macros: el esquema y la lectura, a mano.
// Si esta pasa y la 2 no, ya sé por dónde salir.
import FoundationModels

@available(iOS 26.0, *)
struct HerramientaAMano: Tool {
    let name = "a_mano"
    let description = "no hace nada"

    struct Arguments: ConvertibleFromGeneratedContent {
        var mes: String
        init(_ contenido: GeneratedContent) throws {
            mes = (try? contenido.value(String.self, forProperty: "mes")) ?? ""
        }
    }

    var parameters: GenerationSchema {
        GenerationSchema(type: Arguments.self, description: "a mano", properties: [
            GenerationSchema.Property(name: "mes", description: "el mes, 2026-09", type: String.self)
        ])
    }

    func call(arguments a: Arguments) async throws -> String {
        return "hola " + a.mes
    }
}
