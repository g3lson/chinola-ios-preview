import Foundation

/**
 * LAS LIBRETAS, ARMADAS AQUÍ.
 *
 * Es el selector de arriba y la subpantalla «Libretas y permisos». Se le pedía
 * a la web (`__chinolaLibretasJSON`) y todo estaba ya escrito en el teléfono:
 * la copia que ella deja en `copia.json` lleva las libretas ENTERAS, con sus
 * movimientos y sus miembros.
 *
 * Y el teléfono ya sabe hacer las cuentas: el balance de cada libreta sale de
 * `CNCalculo`, el mismo que usa el Resumen. Lo único que no se puede deducir
 * —quién soy yo— se lee también de la copia.
 *
 * LO QUE NO SE INVENTA: la libreta ACTIVA. Está en la copia (`activa`) y es lo
 * que decide cuál lleva el «En uso». Deducirla por la primera de la lista
 * pondría la marca en la que no es en cuanto alguien cambie de libreta.
 */
enum CNLibretasArma {

    /// Los colores que cambian con la paleta.
    struct Tinte {
        var positivo = ""; var negativo = ""
    }

    /// Una libreta de la copia, leída como libreta de verdad para poder sumarla.
    static func libretaDe(_ crudo: [String: Any]) -> CNLibreta? {
        guard let d = try? JSONSerialization.data(withJSONObject: crudo),
              let l = try? JSONDecoder().decode(CNLibreta.self, from: d) else { return nil }
        return l
    }

    /// Cuál está en uso. En la copia, junto a las libretas.
    static func activa() -> String {
        guard let c = CNAlmacen.copia(), let texto = c[CNAlmacen.LIBRETAS],
              let d = texto.data(using: .utf8),
              let j = (try? JSONSerialization.jsonObject(with: d)) as? [String: Any] else { return "" }
        if let s = j["activa"] as? String { return s }
        // Las de antes tenían el identificador en número.
        if let n = j["activa"] as? NSNumber { return n.stringValue }
        return ""
    }

    static func arma(periodo p: CNCalculo.Periodo, yo correo: String, tinte t: Tinte) -> CNLibretas? {
        let crudas = CNAlmacen.libretas()
        guard !crudas.isEmpty else { return nil }
        var m = CNLibretas()
        m.titulo = cnT("Libretas")
        m.textoGestionar = cnT("Libretas y permisos")
        m.textoNueva = cnT("Nueva libreta")
        m.rotuloOtras = cnT("Cambiar de libreta")
        let cual = activa()
        m.filas = crudas.enumerated().compactMap { i, cruda in
            fila(i, cruda, activa: cual, periodo: p, yo: correo, tinte: t)
        }
        return m.filas.isEmpty ? nil : m
    }

    private static func fila(_ i: Int, _ cruda: [String: Any], activa: String,
                             periodo p: CNCalculo.Periodo, yo correo: String,
                             tinte t: Tinte) -> CNLibretas.Fila? {
        guard let l = libretaDe(cruda) else { return nil }
        let lid = (cruda["id"] as? String) ?? ((cruda["id"] as? NSNumber)?.stringValue ?? "")
        var f = CNLibretas.Fila()
        f.indice = i
        f.lid = lid
        f.nombre = l.nombre
        f.tipo = cnT(l.tipo)
        // «Personal · 3 personas». Lo que de verdad se quiere saber al cambiar
        // de libreta es cuánto hay dentro y cuánta gente la usa; antes solo
        // decía el tipo.
        let gente = l.miembros.count
        f.detalle = gente > 1
            ? cnT(l.tipo) + " · " + cnT("{n} personas").replacingOccurrences(of: "{n}", with: String(gente))
            : cnT(l.tipo)
        let bal = CNCalculo.totales(l, p).bal
        f.cifra = cnDineroFirmado(bal)
        f.cifraTinta = bal < 0 ? t.negativo : t.positivo
        // «1 movimiento» en singular: un «1 movimientos» canta.
        f.pie = l.tx.count == 1 ? cnT("1 movimiento")
            : cnT("{n} movimientos").replacingOccurrences(of: "{n}", with: String(l.tx.count))
        f.iconoPath = glifo(l)
        f.color = l.color
        f.enUso = !lid.isEmpty && lid == activa
        f.rotuloEnUso = cnT("En uso")
        // EL PAPEL DEL SERVIDOR MANDA sobre la lista de miembros, que se queda
        // vieja. Es el mismo con el que decide si te deja escribir.
        f.rol = cnT(CNPapeles.rol(l, yo: correo))
        f.esDueno = CNPapeles.rol(l, yo: correo) == CNPapeles.dueno
        f.compartida = gente > 1
        let mio = correo.trimmingCharacters(in: .whitespaces).lowercased()
        f.miembros = l.miembros.map { x in
            let suyo = x.email.trimmingCharacters(in: .whitespaces).lowercased()
            var y = CNLibretas.Miembro()
            y.nombre = x.nombre; y.email = x.email
            y.rol = cnT(x.rol); y.rolId = x.rol
            y.yo = suyo == mio
            // Al dueño no se le cambia el papel ni se le quita, y a uno mismo
            // tampoco: ese es el botón con el que alguien se saca de su propia
            // libreta sin querer.
            y.editable = !y.yo && x.rol != CNPapeles.dueno
            return y
        }
        return f
    }

    /// El dibujo de una libreta: el que eligió quien la creó y, si no, el de su
    /// tipo. La tabla la genera `npm run sync` de la misma que usa la web.
    static func glifo(_ l: CNLibreta) -> String {
        if !l.icono.isEmpty, let p = CNCatalogos.iconos[l.icono] { return p }
        let clave = CNCatalogos.iconoPorTipoDeLibreta[l.tipo] ?? "casa"
        return CNCatalogos.iconos[clave] ?? CNCatalogos.iconos["casa"] ?? ""
    }
}
