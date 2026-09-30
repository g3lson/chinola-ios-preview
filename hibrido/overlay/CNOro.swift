import Foundation

/**
 * EL FICHERO DE ORO, EJECUTADO DE VERDAD CONTRA EL SWIFT.
 *
 * `test/calculo-oro.json` lleva tiempo en el repositorio y su propia nota dice
 * qué tenía que pasar: «Si cambia la web, se regenera y el Swift tiene que
 * seguir cuadrando». Lo que no había es nadie que lo comprobara. El oro fija la
 * WEB —una prueba en Node la ejecuta contra él— y el Swift se comprobaba
 * leyendo su texto con expresiones regulares.
 *
 * ESA ES LA DIFERENCIA QUE IMPORTA. Una expresión regular confirma que el
 * código dice lo que dice, no que la cuenta salga bien. Por ahí se colaron, en
 * un solo día: una serie llamada `neto` donde la web la llama `patrimonio` —así
 * que la serie que eligieras no se dibujaba nunca—, la forma «barras» hecha
 * como «columnas», y cinco cifras que perdían el signo, de modo que un mes en
 * rojo salía en positivo. Las tres pruebas pasaban.
 *
 * Esto es la prueba de contrato: el MISMO fichero de entrada pasa por las dos
 * implementaciones y tiene que salir lo mismo. Es lo que hace soportable una
 * duplicación que no se puede evitar.
 *
 * CÓMO CORRE: solo en el banco, con `CN_ORO=1`. En un teléfono de verdad esa
 * variable no existe y nada de esto se ejecuta. El resultado sale por el log
 * como `CNORO: {...}` y el banco lo compara con el fichero.
 */
enum CNOro {

    /// ¿Toca? Solo en el banco.
    static var pedido: Bool { ProcessInfo.processInfo.environment["CN_ORO"] == "1" }

    /**
     * Corre las cuentas sobre la libreta del oro y las escupe por el log.
     *
     * El fichero viaja dentro del paquete, en `public/` —lo que Capacitor mete
     * del `webDir`—, porque el banco ya copia esa carpeta entera y así no hay
     * que tocar el proyecto de Xcode para añadir un recurso.
     */
    static func correr() {
        guard let datos = leer() else {
            NSLog("CNORO: {\"error\":\"no encuentro calculo-oro.json en el paquete\"}")
            return
        }
        guard let raiz = (try? JSONSerialization.jsonObject(with: datos)) as? [String: Any],
              let libretaJSON = raiz["libreta"],
              let bruto = try? JSONSerialization.data(withJSONObject: libretaJSON),
              let l = try? JSONDecoder().decode(CNLibreta.self, from: bruto) else {
            NSLog("CNORO: {\"error\":\"no puedo leer la libreta del oro\"}")
            return
        }

        var salida: [String: Any] = [:]

        // Los totales de cada mes que el oro tenga apuntado.
        if let meses = raiz["totales"] as? [String: Any] {
            var out: [String: Any] = [:]
            for mes in meses.keys {
                let t = CNCalculo.totales(l, CNCalculo.Periodo(mes: mes))
                out[mes] = ["ing": t.ing, "gas": t.gas, "fij": t.fij,
                            "vari": t.vari, "aho": t.aho, "bal": t.bal]
            }
            salida["totales"] = out
        }

        // Los saldos: lo que hay, lo que debes, lo que te deben y el patrimonio.
        salida["saldos"] = [
            "enCuentas": CNCalculo.saldoCuentas(l),
            "deudaTC": CNCalculo.deudaTarjetas(l),
            "deudaPr": CNCalculo.deudaPrestamos(l),
            "porCobrarPr": CNCalculo.porCobrarPrestamos(l),
            "pendienteTodos": CNCalculo.pendientePrestamos(l),
            "patrimonio": CNCalculo.patrimonio(l)
        ]

        // El presupuesto de cada mes apuntado.
        if let meses = raiz["presupuesto"] as? [String: Any] {
            var out: [String: Any] = [:]
            for mes in meses.keys {
                let p = CNCalculo.presupuesto(l, CNCalculo.Periodo(mes: mes))
                out[mes] = [
                    "filas": p.filas.map { ["categoria": $0.categoria, "limite": $0.limite,
                                            "gastado": $0.gastado, "pct": $0.pct,
                                            "excedida": $0.excedida] },
                    "limiteTotal": p.limiteTotal, "gastadoTotal": p.gastadoTotal,
                    "pctTotal": p.pctTotal, "excedidas": p.excedidas
                ]
            }
            salida["presupuesto"] = out
        }

        // El gasto por categoría, en su orden.
        if let meses = raiz["porCategoria"] as? [String: Any] {
            var out: [String: Any] = [:]
            for mes in meses.keys {
                out[mes] = CNCalculo.porCategoria(l, CNCalculo.Periodo(mes: mes))
                    .map { ["categoria": $0.categoria, "gastado": $0.gastado] }
            }
            salida["porCategoria"] = out
        }

        // Los días hasta un día del mes, contando desde la fecha que diga el
        // oro: sin fijarla, esto contestaría distinto cada día.
        if let dias = raiz["diasHastaElDia"] as? [String: Any],
           let desde = dias["desde"] as? String,
           let d = CNFormateadores.iso.date(from: desde) {
            var out: [String: Any] = ["desde": desde]
            for k in dias.keys where k != "desde" {
                if let n = Int(k) { out[k] = CNCalculo.diasHastaElDia(n, desde: d) }
            }
            salida["diasHastaElDia"] = out
        }

        if let j = try? JSONSerialization.data(withJSONObject: salida),
           let texto = String(data: j, encoding: .utf8) {
            NSLog("CNORO: %@", texto)
        }
    }

    private static func leer() -> Data? {
        for sub in ["public", "www", nil] {
            if let u = Bundle.main.url(forResource: "calculo-oro", withExtension: "json", subdirectory: sub),
               let d = try? Data(contentsOf: u) { return d }
        }
        return nil
    }
}
