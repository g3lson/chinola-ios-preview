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

        // Cómo va cada tope: el porcentaje, si se pasó, si avisa y cuánto
        // queda. Con las mismas parejas que apunte el oro.
        if let casos = raiz["comoVaElTope"] as? [String: Any] {
            var out: [String: Any] = [:]
            for k in casos.keys {
                let p = k.split(separator: "/").map { Double($0) ?? 0 }
                guard p.count == 2 else { continue }
                let v = CNPlanCuentas.comoVaElTope(p[0], p[1])
                out[k] = ["crudo": v.crudo, "pct": v.pct, "excedida": v.excedida,
                          "agotada": v.agotada, "avisa": v.avisa,
                          "queda": v.queda, "pasado": v.pasado]
            }
            salida["comoVaElTope"] = out
        }

        // Las cinco tarjetas de cifra, con los meses que apunte el oro.
        if let casos = raiz["cifraDelPanel"] as? [String: Any] {
            let deuda = CNCalculo.deudaTarjetas(l) + CNCalculo.pendientePrestamos(l)
            let pat = CNCalculo.patrimonio(l)
            var out: [String: Any] = [:]
            for k in casos.keys {
                let p = k.split(separator: "|", maxSplits: 1).map(String.init)
                guard p.count == 2 else { continue }
                // «sinIngresos» no es un mes: es el caso inventado en el que la
                // nota de gastos dividiría por cero.
                let t = p[0] == "sinIngresos"
                    ? { var x = CNCalculo.Totales(); x.gas = 5000; x.bal = -5000; return x }()
                    : CNCalculo.totales(l, CNCalculo.Periodo(mes: p[0]))
                guard let d = CNTarjetasCifra.decision(p[1], t, deuda: deuda, patrimonio: pat) else { continue }
                out[k] = ["monto": d.monto, "nota": d.nota, "pct": d.pct, "tono": d.tono]
            }
            salida["cifraDelPanel"] = out
        }

        // Los totales de Cuentas, en los tres sentidos: con deuda, solo lo que
        // te deben, y ninguna de las dos.
        if raiz["cuentas"] != nil {
            func sentido(_ ps: [CNPrestamo]) -> [String: Any] {
                let v = CNCuentasTotales.sentidoDeLosPrestamos(ps)
                return ["debo": v.debo, "meDeben": v.meDeben,
                        "soloMeDeben": v.soloMeDeben, "cuanto": v.cuanto]
            }
            salida["cuentas"] = [
                "conDeuda": sentido(l.prestamos),
                "soloMeDeben": sentido(l.prestamos.filter { $0.sentido == "meDeben" }),
                "ninguno": sentido([])
            ]
        }

        // Cuánto se usa del límite de una tarjeta. Sin límite puesto, 0 y no una
        // división rota.
        if let casos = raiz["usoDelLimite"] as? [String: Any] {
            var out: [String: Any] = [:]
            for k in casos.keys {
                let p = k.split(separator: "/").map { Double($0) ?? 0 }
                guard p.count == 2 else { continue }
                out[k] = CNCuentasTotales.usoDelLimite(saldo: p[0], limite: p[1])
            }
            salida["usoDelLimite"] = out
        }

        // Las barras de gastos por categoría: la lista entera, con su
        // porcentaje contra la mayor. El corte en cinco lo hace la pantalla.
        if let meses = raiz["barrasDeCategorias"] as? [String: Any] {
            var out: [String: Any] = [:]
            for mes in meses.keys {
                out[mes] = CNTarjetasGrafico.barrasCrudas(l, CNCalculo.Periodo(mes: mes))
                    .map { c -> [String: Any] in
                        ["categoria": c.categoria, "gastado": c.gastado, "pct": c.pct]
                    }
            }
            salida["barrasDeCategorias"] = out
        }

        // La tendencia: la escala y las dos alturas de cada mes. La clave del oro
        // es «mes/cuántos meses».
        if let casos = raiz["tendencia"] as? [String: Any] {
            var out: [String: Any] = [:]
            for k in casos.keys {
                let p = k.split(separator: "/").map(String.init)
                guard p.count == 2, let cuantos = Int(p[1]) else { continue }
                let t = CNTarjetasGrafico.tendenciaCruda(l, hasta: p[0], meses: cuantos)
                let columnas: [[String: Any]] = t.columnas.map {
                    ["mes": $0.mes, "ing": $0.ing, "gas": $0.gas, "a": $0.a, "b": $0.b]
                }
                out[k] = ["tope": t.tope, "columnas": columnas]
            }
            salida["tendencia"] = out
        }

        // La dona: el reparto sobre gastos MÁS ahorro.
        if let meses = raiz["mezcla"] as? [String: Any] {
            var out: [String: Any] = [:]
            for mes in meses.keys {
                let r = CNTarjetasGrafico.reparto(CNCalculo.totales(l, CNCalculo.Periodo(mes: mes)))
                out[mes] = ["total": r.total, "fijos": r.fijos, "variables": r.variables,
                            "ahorro": r.ahorro, "a": r.a, "c": r.c, "hasta": r.hasta]
            }
            salida["mezcla"] = out
        }

        // LA SERIE DE TIEMPO. La clave del oro es «mes|forma|series|rango», y las
        // coordenadas se redondean a cuatro decimales en los dos lados: son
        // divisiones, y un bit de diferencia no es el fallo que se busca.
        if let casos = raiz["serie"] as? [String: Any] {
            func r4(_ v: Double) -> Double { (v * 10000).rounded() / 10000 }
            func pts(_ t: CNSerieTiempo.Trazo) -> [String: Any] {
                ["serie": t.serie.rawValue,
                 "puntos": t.puntos.map { ["x": r4($0.x), "y": r4($0.y)] }]
            }
            var out: [String: Any] = [:]
            for k in casos.keys {
                let p = k.split(separator: "|", omittingEmptySubsequences: false).map(String.init)
                guard p.count == 4, let forma = CNSerieTiempo.Forma(rawValue: p[1]),
                      let rango = Int(p[3]) else { continue }
                let series = p[2].split(separator: ",").compactMap { CNSerieTiempo.Serie(rawValue: String($0)) }
                let d = CNSerieTiempo.dibujo(l, hasta: p[0], meses: rango,
                                             series: series, forma: forma)
                out[k] = [
                    "alto": CNSerieTiempo.ALTO,
                    "meses": d.meses,
                    "cadaCuantas": d.cadaCuantas,
                    // El oro guarda QUÉ meses llevan rótulo, no el rótulo: el
                    // texto depende del idioma que tenga puesto cada quien.
                    "rotula": d.etiquetas.map { !$0.isEmpty },
                    "minV": d.minV, "maxV": d.maxV,
                    "trazos": d.trazos.map { pts($0) },
                    "areas": d.areas.map { pts($0) },
                    "barras": d.barras.map { b -> [String: Any] in
                        ["serie": b.serie.rawValue, "x": r4(b.x), "y": r4(b.y),
                         "w": r4(b.w), "h": r4(b.h)]
                    },
                    "leyenda": d.leyenda.map { g -> [String: Any] in
                        ["serie": g.serie.rawValue, "ultimo": g.valor]
                    }
                ]
            }
            salida["serie"] = out
        }

        // Los pagos que vienen, desde la fecha que fije el oro.
        if let pagos = raiz["pagos"] as? [String: Any],
           let desde = pagos["desde"] as? String,
           let d = CNFormateadores.iso.date(from: desde) {
            let lista = CNCalculo.pagosQueVienen(l, desde: d).map { p -> [String: Any] in
                let av = CNTarjetasLista.avisoDe(p.dias)
                return ["tipo": p.tipo, "nombre": p.nombre, "monto": p.monto,
                        "corte": p.corte, "dia": p.dia, "dias": p.dias,
                        "plazo": av.plazo, "tono": av.tono]
            }
            salida["pagos"] = ["desde": desde, "lista": lista]
        }

        // El consejo de Chino: cuál de las tres frases toca, y con qué números.
        if let casos = raiz["consejo"] as? [String: Any] {
            var out: [String: Any] = [:]
            for k in casos.keys {
                let c: CNTarjetasLista.Consejo
                switch k {
                // Un mes en rojo, inventado: es la única de las tres que pide
                // hacer algo hoy.
                case "corto":
                    var t = CNCalculo.Totales(); t.ing = 1000; t.gas = 5000; t.bal = -4000
                    c = CNTarjetasLista.consejoDeChino(l, t)
                // Y una libreta sin préstamos, que es la tercera.
                case "sinCuotas":
                    var sinPr = l; sinPr.prestamos = []
                    c = CNTarjetasLista.consejoDeChino(sinPr, CNCalculo.totales(l, CNCalculo.Periodo(mes: "2026-09")))
                default:
                    c = CNTarjetasLista.consejoDeChino(l, CNCalculo.totales(l, CNCalculo.Periodo(mes: k)))
                }
                out[k] = ["clave": c.clave, "monto": c.monto, "pct": c.pct]
            }
            salida["consejo"] = out
        }

        // El avance de cada meta, por su identificador.
        if let casos = raiz["metas"] as? [String: Any] {
            var out: [String: Any] = [:]
            for g in l.metas where casos[String(g.id)] != nil {
                let a = CNTarjetasLista.avanceDeMeta(g)
                out[String(g.id)] = ["pct": a.pct, "restante": a.restante,
                                     "meses": a.meses, "completada": a.completada]
            }
            salida["metas"] = out
        }

        // Los movimientos que se ven, en su orden. La clave es
        // «mes|filtro|búsqueda» y lo que se compara son los identificadores:
        // los mismos movimientos en otro orden se ven bien y están mal.
        if let casos = raiz["visibles"] as? [String: Any] {
            var out: [String: Any] = [:]
            for k in casos.keys {
                let p = k.split(separator: "|", maxSplits: 2, omittingEmptySubsequences: false).map(String.init)
                guard p.count == 3,
                      let filtro = CNMovimientos.Filtro(rawValue: p[1]) else { continue }
                out[k] = CNMovimientos.visibles(l, periodo: CNCalculo.Periodo(mes: p[0]),
                                                filtro: filtro, buscando: p[2]).map { $0.id }
            }
            salida["visibles"] = out
        }

        // El total de cada día, con la transferencia fuera.
        if let meses = raiz["porDias"] as? [String: Any] {
            var out: [String: Any] = [:]
            for mes in meses.keys {
                let vis = CNMovimientos.visibles(l, periodo: CNCalculo.Periodo(mes: mes))
                out[mes] = CNMovimientos.porDias(vis).map { d -> [String: Any] in
                    ["fecha": d.fecha, "total": CNMovimientos.totalDelDia(d.movimientos)]
                }
            }
            salida["porDias"] = out
        }

        // El icono, el color y la sigla de cada categoría.
        if let casos = raiz["categorias"] as? [String: Any] {
            var out: [String: Any] = [:]
            for nombre in casos.keys {
                out[nombre] = ["icono": CNCategorias.icono(nombre, en: l),
                               "color": CNCategorias.color(nombre, en: l),
                               "inicial": CNCategorias.inicial(nombre)]
            }
            salida["categorias"] = out
        }

        // LA GRÁFICA DEL PATRIMONIO, CON Y SIN FOTOS. La serie se reconstruye
        // hacia atrás, y eso solo vale si todo lo que mueve el patrimonio es un
        // movimiento —crear una cuenta con saldo no lo es—. Por eso ahora manda
        // la foto guardada de cada mes, y donde hay foto se vuelve a anclar el
        // tramo anterior.
        if let casos = raiz["serieCasos"] as? [String: Any] {
            var out: [String: Any] = [:]
            for (nombre, caso) in casos {
                guard let c = caso as? [String: Any] else { continue }
                var conFotos = l
                conFotos.historia = (c["historia"] as? [String: Double]) ?? [:]
                let meses = Int(((c["meses"] as? NSNumber)?.intValue) ?? 6)
                let cuando = CNFormateadores.iso.date(from: (c["hoy"] as? String) ?? "") ?? Date()
                let r = CNCalculo.retrato(conFotos, meses: meses, hoy: cuando)
                out[nombre] = ["puntos": r.serie.map { ["mes": $0.etiqueta, "valor": $0.valor] }]
            }
            salida["serie2"] = out
        }

        // CUÁNTO CAMBIÓ EL PATRIMONIO CON CADA MOVIMIENTO. Es lo que dibuja
        // la gráfica de Cuentas, y era lo único de esa pantalla que NO estaba
        // comparado: por eso las dos implementaciones podían decir lo mismo y
        // estar las dos equivocadas. Lo estaban.
        if let casos = raiz["patrimonioCasos"] as? [String: Any] {
            var out: [String: Any] = [:]
            for (nombre, caso) in casos {
                guard let c = caso as? [String: Any],
                      let d = c["item"] as? [String: Any] else { continue }
                var item = CNMov()
                item.id = "x"
                item.tipo = (d["tipo"] as? String) ?? ""
                item.monto = ((d["monto"] as? NSNumber)?.doubleValue) ?? 0
                item.medio = (d["medio"] as? String) ?? ""
                item.destino = (d["destino"] as? String) ?? ""
                item.meta = ((d["meta"] as? NSNumber)?.intValue) ?? 0
                item.prestamo = ((d["prestamo"] as? NSNumber)?.intValue) ?? 0
                item.tarjeta = ((d["tarjeta"] as? NSNumber)?.intValue) ?? 0
                out[nombre] = ["cambio": CNCalculo.efectoEnPatrimonio(l, item)]
            }
            salida["patrimonio"] = out
        }

        // ESCRIBIR UN MOVIMIENTO: crear, cambiar y borrar. Se compara la
        // libreta ENTERA que sale —los saldos incluidos—, porque que la lista de
        // movimientos cuadre no dice nada si el dinero se movió a otro sitio.
        if let casos = raiz["escribirCasos"] as? [String: Any] {
            func resumen(_ x: CNLibreta) -> [String: Any] {
                ["cuentas": x.cuentas.map { ["id": $0.id, "saldo": $0.saldo] },
                 "tarjetas": x.tarjetas.map { ["id": $0.id, "saldo": $0.saldo] },
                 "tx": x.tx.map { ["id": $0.id, "tipo": $0.tipo, "monto": $0.monto,
                                   "medio": $0.medio, "fecha": $0.fecha] }]
            }
            var out: [String: Any] = [:]
            for (nombre, caso) in casos {
                guard let c = caso as? [String: Any], let que = c["que"] as? String else { continue }
                let sale: CNLibreta
                switch que {
                case "nuevo":
                    sale = CNEscribir.movimientoNuevo(l, (c["dato"] as? [String: Any]) ?? [:])
                case "cambiado":
                    sale = CNEscribir.movimientoCambiado(l, (c["dato"] as? [String: Any]) ?? [:])
                default:
                    sale = CNEscribir.movimientoBorrado(l, (c["dato"] as? String) ?? "")
                }
                out[nombre] = ["sale": resumen(sale)]
            }
            salida["escribir"] = out
        }

        // LA LIBRETA, IDA Y VUELTA.
        //
        // Cuando el teléfono escribe, le devuelve a la web la libreta entera
        // montada desde este modelo. Un campo que el modelo SERIALICE pero no
        // DECODIFIQUE —o al revés— se pierde ahí, y no se pierde con un error:
        // se pierde en silencio, la primera vez que se toca esa tarjeta o ese
        // préstamo. Así se perdían los cuatro dígitos de la tarjeta y el banco
        // del préstamo.
        //
        // No hace falta oro para esto: se compara el Swift CONTRA SÍ MISMO. Se
        // empaqueta, se vuelve a leer y se empaqueta otra vez; si el viaje no
        // pierde nada, los dos paquetes son idénticos.
        if let d = try? JSONSerialization.data(withJSONObject: l.aDiccionario()),
           let otra = try? JSONDecoder().decode(CNLibreta.self, from: d) {
            salida["vuelta"] = ["antes": l.aDiccionario(), "despues": otra.aDiccionario()]
        }

        // LAS HOJAS DE DINERO: aportar, abonar y los dos ajustes a mano. Cada
        // una toca DOS sitios —el saldo y el avance—, que es lo que se pierde
        // al rehacerlas. La fecha y el identificador salen del reloj y no se
        // comparan: lo que importa es a dónde fue el dinero.
        // Con `if let` y no con `guard … else { return }`: un `return` aquí
        // saldría de TODA la función y se llevaría por delante lo que queda,
        // incluida la línea que lo escupe todo. Sin metas ni préstamos
        // simplemente no hay nada que comparar en este apartado.
        if let casos = raiz["dineroCasos"] as? [String: Any],
           let meta = l.metas.first, let prestamo = l.prestamos.first {
            func resumen(_ x: CNLibreta, _ item: CNMov?) -> [String: Any] {
                var fuera: [String: Any] = [
                    "cuentas": x.cuentas.map { ["id": $0.id, "saldo": $0.saldo] },
                    "tarjetas": x.tarjetas.map { ["id": $0.id, "saldo": $0.saldo] },
                    "metas": x.metas.map { ["id": $0.id, "ahorrado": $0.ahorrado] },
                    "prestamos": x.prestamos.map { ["id": $0.id, "pagado": $0.pagado] }
                ]
                if let i = item {
                    fuera["item"] = ["tipo": i.tipo, "categoria": i.categoria, "monto": i.monto,
                                     "medio": i.medio, "meta": i.meta, "prestamo": i.prestamo]
                } else {
                    fuera["item"] = NSNull()
                }
                return fuera
            }
            var out: [String: Any] = [:]
            for nombre in casos.keys {
                var hecho: CNEscribir.Hecho?
                var suelta: CNLibreta?
                switch nombre {
                case "aportar a una meta":
                    hecho = CNEscribir.aporteAMeta(l, meta: meta, monto: 5000, medio: "cuenta:1", texto: "Aporte")
                case "aportar sin decir de dónde":
                    hecho = CNEscribir.aporteAMeta(l, meta: meta, monto: 1000, medio: "", texto: "Aporte")
                case "aportar cero no hace nada":
                    hecho = CNEscribir.aporteAMeta(l, meta: meta, monto: 0, medio: "cuenta:1", texto: "Aporte")
                case "abonar a un préstamo":
                    hecho = CNEscribir.abonoAPrestamo(l, prestamo: prestamo, monto: 10000, medio: "cuenta:1", texto: "Pago")
                case "abonar más de lo que falta":
                    hecho = CNEscribir.abonoAPrestamo(l, prestamo: prestamo, monto: 999999, medio: "cuenta:1", texto: "Pago")
                case "abonar con la tarjeta":
                    hecho = CNEscribir.abonoAPrestamo(l, prestamo: prestamo, monto: 4000, medio: "tarjeta:10", texto: "Pago")
                case "pasar de una cuenta a otra":
                    hecho = CNEscribir.transferencia(l, desde: "cuenta:1", hasta: "cuenta:2",
                                                     monto: 8000, texto: "De aquí a allá")
                case "pagar la tarjeta desde la cuenta":
                    hecho = CNEscribir.transferencia(l, desde: "cuenta:1", hasta: "tarjeta:10",
                                                     monto: 6000, texto: "De aquí a allá")
                case "al mismo sitio no se pasa nada":
                    hecho = CNEscribir.transferencia(l, desde: "cuenta:1", hasta: "cuenta:1",
                                                     monto: 5000, texto: "De aquí a allá")
                case "subir lo ahorrado de una meta":
                    suelta = CNEscribir.ajusteDeMeta(l, id: meta.id, delta: 7000)
                case "bajar lo ahorrado sin pasar de cero":
                    suelta = CNEscribir.ajusteDeMeta(l, id: meta.id, delta: -999999)
                case "subir lo pagado de un préstamo":
                    suelta = CNEscribir.ajusteDePrestamo(l, id: prestamo.id, delta: 5000)
                case "no se paga más de lo que se debe":
                    suelta = CNEscribir.ajusteDePrestamo(l, id: prestamo.id, delta: 999999)
                // PAGAR LA TARJETA DESDE SU HOJA. No es la transferencia: aquí
                // la deuda baja y la cuenta NO se toca, porque esto no pasa por
                // `aplica`. El apunte se da hecho —con su fecha y su medio—
                // porque el de la web sale del reloj y del mes que se mire.
                case "pagar la tarjeta desde su hoja", "pagar más de lo que se debe",
                     "pagar cero no hace nada", "sin tarjeta no se paga nada":
                    var apunte = CNMov()
                    apunte.id = "pt1"; apunte.concepto = "Pago Visa"
                    apunte.categoria = "Deudas"; apunte.tipo = "Gasto Fijo"
                    apunte.fecha = "2026-09-20"; apunte.medio = "cuenta:1"
                    let cuanto: Double = nombre == "pagar más de lo que se debe" ? 999999
                        : (nombre == "pagar cero no hace nada" ? 0 : 5000)
                    apunte.monto = cuanto
                    hecho = CNEscribir.pagoDeTarjeta(
                        l, tarjeta: nombre == "sin tarjeta no se paga nada" ? nil : l.tarjetas.first,
                        monto: cuanto, item: apunte)
                default: continue
                }
                if let x = suelta {
                    out[nombre] = ["sale": resumen(x, nil)]
                } else if let h = hecho {
                    out[nombre] = ["sale": resumen(h.libreta, h.item)]
                } else {
                    // No había nada que hacer: el oro guarda un nulo.
                    let nada: Any = NSNull()
                    out[nombre] = ["sale": nada]
                }
            }
            salida["dinero"] = out
        }

        // CREAR Y EDITAR: cuenta, tarjeta, préstamo y meta. Aquí no se mueve
        // dinero, pero sí se recortan valores —un corte el 45 no llega nunca,
        // lo pagado no pasa del total— y editar no puede borrar lo que no se
        // tocó.
        if let casos = raiz["crearCasos"] as? [String: Any] {
            func resumen(_ x: CNLibreta) -> [String: Any] {
                ["cuentas": x.cuentas.map { ["id": $0.id, "nombre": $0.nombre, "saldo": $0.saldo,
                                             "clase": $0.claseParaAgrupar] },
                 "tarjetas": x.tarjetas.map { ["id": $0.id, "nombre": $0.nombre, "saldo": $0.saldo,
                                               "limite": $0.limite, "corte": $0.corte, "pago": $0.pago] },
                 "prestamos": x.prestamos.map { ["id": $0.id, "nombre": $0.nombre, "total": $0.total,
                                                 "pagado": $0.pagado, "dia": $0.dia, "sentido": $0.sentido] },
                 "metas": x.metas.map { ["id": $0.id, "nombre": $0.nombre, "meta": $0.meta,
                                         "ahorrado": $0.ahorrado, "mensual": $0.mensual] },
                 "categorias": x.categorias.map { ["id": $0.id, "nombre": $0.nombre, "ingreso": $0.ingreso] },
                 "presupuesto": x.presupuesto,
                 // Con qué categoría se quedó cada movimiento: es lo que se
                 // pierde al renombrar una sin arrastrarlos.
                 "categoriasDeTx": x.tx.map { $0.categoria }]
            }
            var out: [String: Any] = [:]
            for (nombre, caso) in casos {
                guard let c = caso as? [String: Any], let que = c["que"] as? String,
                      let f = c["f"] as? [String: Any] else { continue }
                let antes = c["antes"] as? Int
                let sale: CNLibreta
                switch que {
                case "cuenta": sale = CNEscribir.guardarCuenta(l, f, antes: antes)
                case "tarjeta": sale = CNEscribir.guardarTarjeta(l, f, antes: antes)
                case "prestamo": sale = CNEscribir.guardarPrestamo(l, f, antes: antes)
                case "categoria": sale = CNEscribir.guardarCategoria(l, f, antes: antes)
                default: sale = CNEscribir.guardarMeta(l, f, antes: antes)
                }
                out[nombre] = ["sale": resumen(sale)]
            }
            salida["crear"] = out
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

        // LA FUSIÓN A TRES, caso por caso.
        //
        // Va en su propio fichero —`fusion-oro.json`— porque la genera otro
        // guion: los cálculos salen de la lógica de la pantalla y esto de la capa
        // de nube. El banco junta los dos y compara el árbol entero.
        if let bruto = leer("fusion-oro"),
           let raizF = (try? JSONSerialization.jsonObject(with: bruto)) as? [String: Any],
           let casos = raizF["fusionCasos"] as? [String: Any] {
            var out: [String: Any] = [:]
            for (nombre, caso) in casos {
                guard let c = caso as? [String: Any] else { continue }
                let sale = CNFusion.fusiona(c["base"] as? [String: Any],
                                            c["mia"] as? [String: Any],
                                            c["suya"] as? [String: Any])
                // El oro guarda el caso entero —base, mía, suya y el porqué— y
                // aquí solo se devuelve lo que SALE: es lo único que se compara.
                let valor: Any = sale ?? NSNull()
                out[nombre] = ["sale": valor]
            }
            salida["fusion"] = out
        }

        // LAS DOS DECISIONES DEL EMPUJE: qué se sube y qué significa cada
        // rechazo. Vienen del mismo fichero que la fusión.
        if let bruto = leer("fusion-oro"),
           let raizF = (try? JSONSerialization.jsonObject(with: bruto)) as? [String: Any] {
            if let casos = raizF["subirCasos"] as? [String: Any] {
                var out: [String: Any] = [:]
                for (nombre, caso) in casos {
                    guard let c = caso as? [String: Any],
                          let libretas = c["libretas"] as? [[String: Any]] else { continue }
                    var versiones: [String: Int] = [:]
                    for (k, v) in (c["versiones"] as? [String: Any]) ?? [:] {
                        versiones[k] = (v as? Int) ?? 0
                    }
                    // Solo la llave y la versión: el resto de la libreta va tal
                    // cual y no dice nada de la decisión.
                    out[nombre] = ["sale": CNSincro.queSeSube(libretas, versiones: versiones).map {
                        ["id": $0["id"] ?? "", "__version": $0["__version"] ?? 0]
                    }]
                }
                salida["subir"] = out
            }
            // GZIP: el teléfono comprime un texto conocido y el banco lo
            // descomprime. Si la cabecera, el deflate o el CRC están mal, no se
            // puede descomprimir — y ese fallo solo aparecería con las libretas
            // grandes, o sea con quien más tiempo lleva usando la app.
            if let g = raizF["gzip"] as? [String: Any], let texto = g["texto"] as? String,
               let d = texto.data(using: .utf8), let apretado = CNGzip.comprime(d) {
                salida["gzip"] = ["base64": apretado.base64EncodedString(),
                                  "crudo": d.count, "apretado": apretado.count]
            }

            if let casos = raizF["rechazoCasos"] as? [String: Any] {
                var out: [String: Any] = [:]
                for (nombre, caso) in casos {
                    guard let c = caso as? [String: Any] else { continue }
                    let r = CNSincro.comoClasificar(
                        (c["conflictos"] as? [[String: Any]]) ?? [],
                        (c["libretas"] as? [[String: Any]]) ?? [],
                        (c["yo"] as? String) ?? "",
                        segundaVuelta: (c["segundaVuelta"] as? Bool) ?? false)
                    out[nombre] = ["sale": ["desactualizadas": r.desactualizadas,
                                            "limite": r.limite, "ajenas": r.ajenas,
                                            "rescatables": r.rescatables,
                                            "sinPermiso": r.sinPermiso]]
                }
                salida["rechazo"] = out
            }
        }

        if let j = try? JSONSerialization.data(withJSONObject: salida),
           let texto = String(data: j, encoding: .utf8) {
            escupe(texto)
        }
    }

    /**
     * EL RESULTADO, POR TROZOS, PORQUE EL LOG CORTA.
     *
     * Iba en una sola línea —`NSLog("CNORO: %@", texto)`— y funcionó mientras el
     * fichero de oro tenía cinco apartados. Con los catorce, el JSON pasa de mil
     * caracteres y `os_log` lo corta ahí: el banco leía media línea, no era JSON
     * válido y decía «no entiendo lo que dijo el Swift».
     *
     * Y ese es el fallo peor de los dos posibles, aunque parezca el mejor: se
     * queja. El que asusta es el contrario —que cortara justo en un sitio donde
     * el JSON siguiera siendo válido— porque entonces el banco compararía media
     * verdad y diría que cuadra.
     *
     * Van numerados para poder pegarlos en orden y saber si falta alguno.
     */
    private static func escupe(_ texto: String) {
        // EN BASE64, y no el JSON tal cual.
        //
        // `log show` no saca el mensaje tal como se escribió: los caracteres no
        // ASCII los reescribe, y las BARRAS INVERTIDAS también —`\u2212` salía
        // como `\134u2212`—, así que escaparlos yo tampoco valía: el log
        // escapaba mi escape. En base64 no hay ni barras invertidas ni nada
        // fuera del ASCII, solo letras, números y `+/=`, y el log no toca nada.
        //
        // Van numerados para poder pegarlos en orden y saber si falta alguno:
        // os_log corta cerca de los mil caracteres.
        guard let d = texto.data(using: .utf8) else { return }
        let b = Array(d.base64EncodedString())
        let tamano = 500
        let partes = stride(from: 0, to: b.count, by: tamano).map {
            String(b[$0..<min($0 + tamano, b.count)])
        }
        for (i, parte) in partes.enumerated() {
            NSLog("CNORO %d/%d %@", i + 1, partes.count, parte)
        }
    }

    private static func leer(_ nombre: String = "calculo-oro") -> Data? {
        for sub in ["public", "www", nil] {
            if let u = Bundle.main.url(forResource: nombre, withExtension: "json", subdirectory: sub),
               let d = try? Data(contentsOf: u) { return d }
        }
        return nil
    }
}
