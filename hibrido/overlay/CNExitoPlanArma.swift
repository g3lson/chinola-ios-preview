import Foundation

/**
 * «YA ERES PRO», ARMADA AQUÍ.
 *
 * La pantalla que sale justo después de pagar: cuál plan tienes ahora, qué te
 * da, y tres cosas por las que empezar. La dibujaba el teléfono y el contenido
 * se lo mandaba la web, entero, por el puente.
 *
 * No hay nada que preguntar: todo sale del PLAN. Lo que cambia entre uno y
 * otro son tres frases y tres atajos, y la lista de ellos la genera
 * `npm run sync` del mismo sitio que la lee la web.
 *
 * LOS TRES PRIMEROS PASOS NO SON LOS MISMOS. En Negocio lo primero es meter a
 * tu equipo y repartir permisos; en Pro, abrir otra libreta. Darle a alguien
 * de Negocio «Crear otra libreta» como primer paso es no haber entendido para
 * qué pagó.
 */
enum CNExitoPlanArma {

    /// Lo que se ofrece hacer primero, por plan. Son atajos del mismo
    /// vocabulario que entiende `irA`: «seccion:libretas», «chino».
    private static func primeros(_ plan: String) -> [(texto: String, icono: String, ir: String)] {
        plan == "negocio"
            ? [(cnT("Invitar a tu equipo"), "familia", "seccion:libretas"),
               (cnT("Elegir quién ve qué"), "candado", "seccion:libretas"),
               (cnT("Crear tu primera clave de API"), "llave", "seccion:integraciones")]
            : [(cnT("Crear otra libreta"), "libro", "seccion:libretas"),
               (cnT("Invitar a alguien de la casa"), "familia", "seccion:libretas"),
               (cnT("Anotar hablando"), "telefono", "chino")]
    }

    static func arma(_ plan: String) -> CNExitoPlan {
        let cual = plan.isEmpty ? "pro" : plan
        var x = CNExitoPlan()
        x.plan = cual
        x.titulo = cnT("¡Ya eres {plan}!")
            .replacingOccurrences(of: "{plan}",
                                  with: cnT(CNCatalogos.nombreDelPlan[cual] ?? cual))
        x.texto = cual == "negocio"
            ? cnT("Tu equipo ya puede entrar a tus libretas, cada quien con sus permisos.")
            : cnT("Chino ya no cuenta tus mensajes, y puedes abrir todas las libretas que necesites.")
        x.boton = cnT("Empezar")
        x.animo = "fiesta"
        x.primeros = primeros(cual).enumerated().map { i, p in
            CNExitoPlan.Primero(id: i, texto: p.texto,
                                iconoPath: CNCatalogos.iconos[p.icono] ?? "",
                                ir: p.ir)
        }
        return x
    }
}
