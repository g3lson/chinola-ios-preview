// ¿Existe el módulo y funciona el macro más simple que hay?
import FoundationModels

@available(iOS 26.0, *)
@Generable
struct UnaCosa {
    @Guide(description: "el mes, 2026-09")
    var mes: String
}
