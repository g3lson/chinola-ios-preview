import Foundation

/**
 * EL DETALLE DE UNA CUENTA, UNA TARJETA O UN PRÉSTAMO, ARMADO AQUÍ.
 *
 * Era lo último que ataba la pantalla de Cuentas a la web: tocabas una fila y
 * el modelo entero —el bloque grande de arriba, las cifras, los botones y la
 * lista de movimientos— se le pedía a ella.
 *
 * NO SE DEDUJO NADA. Cada campo se sacó leyendo lo que la web manda de verdad,
 * con la app en marcha, para los cinco tipos (`test/detalle-oro.json`). Y ahí
 * están las decisiones que de memoria salen mal:
 *
 *  · **Solo la cuenta lleva las dos cifras** «Entró este mes» y «Salió este
 *    mes». La tarjeta, el préstamo y la meta no llevan ninguna: ya lo dicen su
 *    barra y su bloque de arriba.
 *  · **Cada tipo tiene su propio rótulo de lista** —«Movimientos de esta
 *    cuenta», «Consumos con esta tarjeta», «Pagos registrados»—, y no es
 *    decoración: en la de la tarjeta no salen pagos, salen consumos.
 *  · **El botón sabe qué hoja abre.** Va pegado al botón a propósito: cuando
 *    estuvieron separados, «Abonar otro monto» abría el formulario de EDITAR
 *    el préstamo. Guardabas, y no habías abonado nada.
 *  · **Los movimientos se agrupan por MES**, con el total del mes en la
 *    cabecera, no por día como en la pestaña de Movimientos.
 */
enum CNDetallePantalla {

    /// Los colores que cambian con la paleta.
    struct Tinte {
        var tinta = ""; var positivo = ""; var negativo = ""; var gris = ""
    }

    /// Los tres que salen de la pantalla de Cuentas. La meta y la categoría se
    /// abren desde el Plan y siguen viniendo de la web.
    static func sabeArmar(_ tipo: String) -> Bool {
        ["cuenta", "tarjeta", "prestamo"].contains(tipo)
    }

    static func arma(_ tipo: String, id: Int, libreta l: CNLibreta,
                     periodo p: CNCalculo.Periodo, tinte t: Tinte) -> CNDetalle? {
        switch tipo {
        case "cuenta":   return deCuenta(id, l, p, t)
        case "tarjeta":  return deTarjeta(id, l, t)
        case "prestamo": return dePrestamo(id, l, t)
        default: return nil
        }
    }

    // MARK: - Cuenta

    private static func deCuenta(_ id: Int, _ l: CNLibreta,
                                 _ p: CNCalculo.Periodo, _ t: Tinte) -> CNDetalle? {
        guard let c = l.cuentas.first(where: { $0.id == id }) else { return nil }
        var d = CNDetalle()
        d.titulo = c.nombre
        d.hero = CNDetalle.Hero(
            iconoPath: CNCuentasFilas.glifoDeCuenta(c), iconoColor: c.color,
            iconoBg: CNCuentasFilas.tinte(c.color),
            rotulo: cnT("Saldo disponible"), valor: cnDineroFirmado(c.saldo),
            color: t.tinta)
        // Lo que entró y lo que salió POR ESTA CUENTA en el periodo que se
        // esté mirando, no en el mes natural: si arriba hay un rango puesto,
        // las dos cifras tienen que hablar de ese rango.
        let suyos = l.tx.filter { medioDe($0) == id && CNCalculo.enPeriodo($0.fecha, p) }
        let entro = suyos.filter { $0.tipo == "Ingreso" }.reduce(0.0) { $0 + $1.monto }
        let salio = suyos.filter { $0.tipo == "Gasto Fijo" || $0.tipo == "Gasto Variable" }
            .reduce(0.0) { $0 + $1.monto }
        d.cifras = [
            CNDetalle.Cifra(id: 0, label: cnT("Entró este mes"), valor: cnDinero(entro), color: t.positivo),
            CNDetalle.Cifra(id: 1, label: cnT("Salió este mes"), valor: cnDinero(salio), color: t.negativo)
        ]
        d.datos = [
            CNDetalle.Dato(id: 0, label: cnT("Banco"),
                           valor: c.banco.isEmpty ? cnT("Sin banco") : c.banco),
            CNDetalle.Dato(id: 1, label: cnT("Movimientos"),
                           valor: String(l.tx.filter { medioDe($0) == id }.count))
        ]
        d.botones = [
            CNDetalle.Boton(id: 0, label: cnT("Nuevo movimiento"), estilo: "acento",
                            abre: "movMedio", conQue: "cuenta:" + String(id)),
            CNDetalle.Boton(id: 1, label: cnT("Transferir"), estilo: "contorno")
        ]
        d.rotuloLista = cnT("Movimientos de esta cuenta")
        d.vacioTexto = cnT("Aquí saldrá todo lo que anotes con esta cuenta.")
        d.tramos = porMeses(l.tx.filter { medioDe($0) == id }, l, t)
        return d
    }

    /// La cuenta que toca un movimiento: la suya o, en una transferencia, la de
    /// destino. Es la misma regla que cuenta los «movs» de la fila.
    private static func medioDe(_ m: CNMov) -> Int? {
        if let i = CNCalculo.idDe(m.medio, "cuenta:") { return i }
        if m.tipo == "Transferencia", let i = CNCalculo.idDe(m.destino, "cuenta:") { return i }
        return nil
    }

    // MARK: - Tarjeta

    private static func deTarjeta(_ id: Int, _ l: CNLibreta, _ t: Tinte) -> CNDetalle? {
        guard let c = l.tarjetas.first(where: { $0.id == id }) else { return nil }
        var d = CNDetalle()
        d.titulo = c.nombre
        let uso = (CNCuentasTotales.usoDelLimite(c) * 100).rounded()
        // La cifra va en ROJO —es deuda— y la barra en VERDE: la barra no mide
        // lo malo, mide cuánto del límite llevas, y a medio llenar eso no es
        // una alarma. Puestas del mismo color, la tarjeta parece en apuros
        // siempre.
        d.hero = CNDetalle.Hero(
            iconoPath: CNCatalogos.iconos["tarjeta"] ?? "", iconoColor: c.color,
            iconoBg: CNCuentasFilas.tinte(c.color),
            rotulo: cnT("Debes ahora"), valor: cnDinero(c.saldo), color: t.negativo,
            pct: uso, colorBarra: t.positivo,
            pieIzq: String(Int(uso)) + "% " + cnT("del límite"),
            pieDer: cnT("Límite") + " " + cnDinero(c.limite))
        let dias = CNCalculo.diasHastaElDia(c.pago)
        d.datos = [
            CNDetalle.Dato(id: 0, label: cnT("Banco"),
                           valor: c.banco.isEmpty ? cnT("Sin banco") : c.banco, color: t.tinta),
            CNDetalle.Dato(id: 1, label: cnT("Día de corte"),
                           valor: diaTexto(c.corte), color: t.tinta),
            CNDetalle.Dato(id: 2, label: cnT("Día de pago"),
                           valor: diaTexto(c.pago) + " · " + enTantosDias(dias), color: t.tinta),
            // Lo que QUEDA, que es la pregunta de verdad al mirar una tarjeta.
            CNDetalle.Dato(id: 3, label: cnT("Disponible"),
                           valor: cnDinero(max(0, c.limite - c.saldo)), color: t.positivo)
        ]
        d.botones = [
            CNDetalle.Boton(id: 0, label: cnT("Registrar pago"), estilo: "acento",
                            abre: "pagoTarjeta", cual: id, monto: c.saldo),
            CNDetalle.Boton(id: 1, label: cnT("Gasto con ella"), estilo: "contorno",
                            abre: "movMedio", conQue: "tarjeta:" + String(id))
        ]
        d.rotuloLista = cnT("Consumos con esta tarjeta")
        d.vacioTexto = cnT("Aquí saldrá todo lo que pagues con esta tarjeta.")
        d.tramos = deCorrido(l.tx.filter { CNCalculo.idDe($0.medio, "tarjeta:") == id }, l, t)
        return d
    }

    // MARK: - Préstamo

    private static func dePrestamo(_ id: Int, _ l: CNLibreta, _ t: Tinte) -> CNDetalle? {
        guard let p = l.prestamos.first(where: { $0.id == id }) else { return nil }
        var d = CNDetalle()
        d.titulo = p.nombre
        let falta = max(0, p.total - p.pagado)
        let pct = p.total > 0 ? (min(1, p.pagado / p.total) * 100).rounded() : 0
        // EL SENTIDO MANDA. Un préstamo que te deben no es una deuda: ni el
        // rótulo ni el color son los mismos, y de memoria sale todo en rojo.
        let meDeben = p.sentido == "meDeben"
        d.hero = CNDetalle.Hero(
            iconoPath: CNCatalogos.iconos[meDeben ? "usuario" : "banco"] ?? "",
            iconoColor: p.color, iconoBg: CNCuentasFilas.tinte(p.color),
            rotulo: meDeben ? cnT("Te falta cobrar") : cnT("Te falta pagar"),
            valor: cnDinero(falta), color: t.negativo,
            pct: pct, colorBarra: p.color,
            pieIzq: cnT("Pagado") + " " + cnDinero(p.pagado) + " (" + String(Int(pct)) + "%)",
            pieDer: cnT("Total") + " " + cnDinero(p.total))
        let diasP = CNCalculo.diasHastaElDia(p.dia)
        var filas: [CNDetalle.Dato] = []
        if p.cuota > 0 {
            filas.append(CNDetalle.Dato(id: filas.count, label: cnT("Cuota mensual"),
                                        valor: cnDinero(p.cuota), color: t.tinta))
        }
        if p.dia > 0 {
            // En rojo cuando ya aprieta: a tres días el dato deja de ser un
            // dato y pasa a ser un aviso.
            filas.append(CNDetalle.Dato(id: filas.count, label: cnT("Día de pago"),
                                        valor: diaTexto(p.dia) + " · " + enTantosDias(diasP),
                                        color: diasP <= 3 ? t.negativo : t.tinta))
        }
        if p.cuota > 0 {
            let total = Int((p.total / p.cuota).rounded(.up))
            let quedan = Int((falta / p.cuota).rounded(.up))
            filas.append(CNDetalle.Dato(id: filas.count, label: cnT("Cuotas restantes"),
                                        valor: String(quedan) + " " + cnT("de") + " " + String(total),
                                        color: t.tinta))
        }
        d.datos = filas
        d.botones = [
            CNDetalle.Boton(id: 0, label: cnT("Registrar cuota"), estilo: "acento",
                            abre: "abono", cual: id, monto: p.cuota),
            CNDetalle.Boton(id: 1, label: cnT("Abonar otro monto"), estilo: "contorno",
                            abre: "abono", cual: id)
        ]
        d.rotuloLista = cnT("Pagos registrados")
        d.vacioTexto = cnT("Aquí saldrán los pagos que vayas anotando.")
        d.tramos = deCorrido(l.tx.filter { $0.prestamo == id }, l, t)
        return d
    }

    // MARK: - La lista

    /**
     * LOS MOVIMIENTOS, AGRUPADOS POR MES.
     *
     * Por mes y no por día, que es como los agrupa la pestaña de Movimientos:
     * aquí se mira el histórico de UNA cuenta, y por días serían treinta
     * cabeceras para tres gastos.
     *
     * Cada mes lleva su total, y el total es la SUMA CON SIGNO —lo que entró
     * menos lo que salió—, no la suma de los importes: un mes con un sueldo y
     * un gasto no movió la suma de los dos.
     */
    static func porMeses(_ movs: [CNMov], _ l: CNLibreta, _ t: Tinte) -> [CNDetalle.Tramo] {
        let orden = movs.sorted { $0.fecha != $1.fecha ? $0.fecha > $1.fecha : $0.id > $1.id }
        var fuera: [CNDetalle.Tramo] = []
        var mesAhora = ""
        for m in orden {
            let mes = String(m.fecha.prefix(7))
            if mes != mesAhora {
                mesAhora = mes
                fuera.append(CNDetalle.Tramo(id: fuera.count, label: nombreDeMes(mes), total: ""))
            }
            let esGasto = m.tipo == "Gasto Fijo" || m.tipo == "Gasto Variable"
            let cat = l.categorias.first { $0.nombre == m.categoria }
            fuera[fuera.count - 1].items.append(CNDetalle.Item(
                id: fuera[fuera.count - 1].items.count,
                concepto: m.concepto,
                sub: [m.categoria, cnFechaLargaDeDia(m.fecha)].filter { !$0.isEmpty }.joined(separator: " · "),
                montoFmt: (esGasto ? "\u{2212}" : "") + cnDinero(m.monto),
                color: esGasto ? t.negativo : t.positivo,
                iconoPath: CNCategorias.icono(m.categoria, en: l),
                catColor: cat?.color ?? t.gris,
                iconoBg: CNCuentasFilas.tinte(cat?.color ?? t.gris, 0.15)))
        }
        // Y el total de cada mes, con signo.
        for i in fuera.indices {
            let suma = orden.filter { String($0.fecha.prefix(7)) == mesDeTramo(fuera[i].label, orden) }
                .reduce(0.0) { a, m in
                    a + ((m.tipo == "Gasto Fijo" || m.tipo == "Gasto Variable") ? -m.monto : m.monto)
                }
            fuera[i].total = cnDineroFirmado(suma)
        }
        return fuera
    }

    /// El mes que corresponde a un rótulo ya escrito. Se busca en los propios
    /// movimientos para no tener que volver a formatear al revés.
    private static func mesDeTramo(_ label: String, _ movs: [CNMov]) -> String {
        for m in movs where nombreDeMes(String(m.fecha.prefix(7))) == label {
            return String(m.fecha.prefix(7))
        }
        return ""
    }

    /**
     * UNA SOLA TANDA, SIN CABECERAS.
     *
     * Solo la cuenta agrupa por meses. La tarjeta y el préstamo van de
     * corrido: son listas cortas de una sola cosa —consumos, pagos— y
     * partirlas por meses añade cabeceras que no dicen nada.
     */
    static func deCorrido(_ movs: [CNMov], _ l: CNLibreta, _ t: Tinte) -> [CNDetalle.Tramo] {
        let todos = porMeses(movs, l, t).flatMap { $0.items }
        guard !todos.isEmpty else { return [] }
        var uno = CNDetalle.Tramo(id: 0, label: "", total: "")
        uno.items = todos.enumerated().map { i, x in var y = x; y.id = i; return y }
        return [uno]
    }

    /// «día 15». La palabra y el número, que un «15» suelto en una fila de
    /// datos no dice que sea un día del mes.
    static func diaTexto(_ d: Int) -> String {
        cnT("día {d}").replacingOccurrences(of: "{d}", with: String(d))
    }

    /// «en 29 d», o «hoy» si es hoy.
    static func enTantosDias(_ n: Int) -> String {
        n == 0 ? cnT("hoy") : cnT("en {n} d").replacingOccurrences(of: "{n}", with: String(n))
    }

    /// «Octubre de 2026», con la primera letra en mayúscula y en el idioma de
    /// la app.
    static func nombreDeMes(_ mes: String) -> String {
        guard let d = CNFormateadores.iso.date(from: mes + "-01") else { return mes }
        let f = CNFormateadores.plantilla("MMMM y")
        let t = f.string(from: d)
        return t.isEmpty ? t : t.prefix(1).uppercased() + t.dropFirst()
    }

    /// «5 oct de 2026»: el día de un movimiento dentro de su fila.
    static func cnFechaLargaDeDia(_ iso: String) -> String {
        guard let d = CNFormateadores.iso.date(from: iso) else { return iso }
        return CNFormateadores.plantilla("d MMM y").string(from: d)
    }
}
