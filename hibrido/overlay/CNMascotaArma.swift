import Foundation

/**
 * LA HOJA DE CHINO, ARMADA AQUÍ.
 *
 * Es lo que se abre al tocarlo: su cara y, debajo, LO QUE VIENE —los pagos
 * cercanos—. El dibujo ya lo hace el teléfono (`CNChino`) y la cara que pone la
 * decide él (`CNAnimo`); lo único que seguía viniendo de la web era esta lista,
 * y es la misma que el panel ya calcula aquí.
 *
 * DOS COSAS QUE NO SE VEN SI SE REHACE DE MEMORIA:
 *
 *  · **el detalle NO lleva el corte.** La fila del panel dice «RD$3,200 · corte
 *    día 15» porque allí se está mirando la tarjeta; aquí dice «RD$3,200 · en 4
 *    d», que es lo que se pregunta al tocar a Chino: cuánto y cuándo;
 *  · **el tono va por cercanía** —rojo esta semana corta, ámbar la que viene,
 *    verde si aún queda—, que es lo que deja barrer la lista sin leer los días.
 *
 * Y DOCE COMO MÁXIMO, como la web. Sin tope, una libreta con veinte tarjetas
 * deja la hoja más alta que la pantalla y el personaje fuera de vista.
 */
enum CNMascotaArma {

    /// Los colores que cambian con la paleta.
    struct Tinte {
        var positivo = ""; var negativo = ""; var aviso = ""
    }

    /// Cuántos caben. Los demás no se pierden: están en el panel entero.
    static let tope = 12

    static func arma(_ l: CNLibreta, tinte t: Tinte, desde: Date = Date()) -> CNMascota {
        var m = CNMascota()
        m.tituloAvisos = cnT("Lo que viene")
        m.verAvisos = cnT("Tócame para ver los pagos")
        m.volver = cnT("Toca para volver")
        m.nadaTexto = cnT("No tienes pagos cerca. Todo tranquilo.")
        m.avisos = CNCalculo.pagosQueVienen(l, desde: desde).prefix(tope).enumerated().map { i, p in
            let av = CNTarjetasLista.avisoDe(p.dias)
            let plazo = av.esHoy
                ? cnT("hoy")
                : cnT("en {n} d").replacingOccurrences(of: "{n}", with: String(p.dias))
            // «Pago Visa» y «Cuota Carro»: el título dice QUÉ es y no solo el
            // nombre, que con tres filas seguidas «Visa» y «Visa» no se
            // distinguen si una es el corte y otra la cuota de un préstamo.
            let que = p.tipo == "tarjeta" ? cnT("Pago") : cnT("Cuota")
            let color = av.tono == "negativo" ? t.negativo : (av.tono == "ambar" ? t.aviso : t.positivo)
            return CNMascota.Aviso(id: i, titulo: que + " " + p.nombre,
                                   detalle: cnDinero(p.monto) + " · " + plazo,
                                   color: color)
        }
        return m
    }
}
