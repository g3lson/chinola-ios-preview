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
        /// El ámbar del «ya casi»: lo usa la barra del presupuesto de una
        /// categoría, que tiene tres estados y no dos.
        var aviso = ""
        /// El lila del ahorro, que es el color de fábrica de las metas. Viene
        /// de la paleta y no escrito aquí: el lila de un tema no es el de otro,
        /// y una meta sin color propio salía morada en el teléfono mientras en
        /// la web seguía la paleta puesta.
        var lila = ""
    }

    /// Los cinco: los tres de Cuentas y los dos que se abren desde el Plan.
    ///
    /// La categoría no va por número —se abre por su NOMBRE—, así que `arma`
    /// recibe el identificador como texto y cada uno lo lee como le toca.
    static func sabeArmar(_ tipo: String) -> Bool {
        ["cuenta", "tarjeta", "prestamo", "meta", "categoria"].contains(tipo)
    }

    /// Los que se abren por número. La categoría no.
    static func porNumero(_ tipo: String) -> Bool { tipo != "categoria" }

    static func arma(_ tipo: String, id: String, libreta l: CNLibreta,
                     periodo p: CNCalculo.Periodo, meses: Int, tinte t: Tinte) -> CNDetalle? {
        if tipo == "categoria" { return deCategoria(id, l, meses, t) }
        guard let n = Int(id) else { return nil }
        switch tipo {
        case "cuenta":   return deCuenta(n, l, p, t)
        case "tarjeta":  return deTarjeta(n, l, t)
        case "prestamo": return dePrestamo(n, l, t)
        case "meta":     return deMeta(n, l, t)
        default: return nil
        }
    }

    // MARK: - Cuenta

    private static func deCuenta(_ id: Int, _ l: CNLibreta,
                                 _ p: CNCalculo.Periodo, _ t: Tinte) -> CNDetalle? {
        guard let c = l.cuentas.first(where: { $0.id == id }) else { return nil }
        var d = CNDetalle()
        d.titulo = c.nombre
        let suTipo = CNTipoAgregar.deLaCuenta(c)
        // CÓMO SE LLAMA ESA CIFRA EN SU FICHA. Decía «Saldo disponible» sobre
        // el dinero de un certificado, que es justamente el que no está
        // disponible, y sobre el valor de un apartamento.
        d.hero = CNDetalle.Hero(
            iconoPath: CNCuentasFilas.glifoDeCuenta(c), iconoColor: c.color,
            iconoBg: CNCuentasFilas.tinte(c.color),
            rotulo: cnT(suTipo?.rotuloSaldo ?? "Saldo disponible"),
            valor: cnDineroFirmado(c.saldo), color: t.tinta)
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
        /*
         * LAS FILAS DE DATOS, LAS DE SU TIPO.
         *
         * Decía «Banco · Sin banco» en una cuenta de EFECTIVO, que no tiene
         * banco ni puede tenerlo. Y a un certificado no le enseñaba su tasa, ni
         * a unas acciones cuántas son, porque no se le preguntaban: los
         * diecinueve del catálogo iban al mismo formulario de tres campos.
         *
         * Ahora cada tipo dice cómo se llama su «dónde» —«Servicio», «Casa de
         * bolsa», «Dónde está»— y trae sus campos propios. La fila solo sale si
         * hay algo que poner: un hueco con «Sin banco» dentro parece un dato
         * que falta, y lo que pasa es que no lo hay.
         */
        var filas: [CNDetalle.Dato] = []
        if let donde = suTipo?.donde, !donde.isEmpty, !c.banco.isEmpty {
            filas.append(CNDetalle.Dato(id: filas.count, label: cnT(sinElParentesis(donde)), valor: c.banco))
        } else if suTipo == nil, !c.banco.isEmpty {
            filas.append(CNDetalle.Dato(id: filas.count, label: cnT("Banco"), valor: c.banco))
        }
        for campo in suTipo?.campos ?? [] {
            guard let v = c.extra[campo.clave], !v.isEmpty else { continue }
            filas.append(CNDetalle.Dato(id: filas.count, label: cnT(campo.label),
                                        valor: valorDelCampo(campo, v)))
        }
        filas.append(CNDetalle.Dato(id: filas.count, label: cnT("Movimientos"),
                                    valor: String(l.tx.filter { medioDe($0) == id }.count)))
        d.datos = filas
        d.botones = [
            CNDetalle.Boton(id: 0, label: cnT("Nuevo movimiento"), estilo: "acento",
                            abre: "movMedio", conQue: "cuenta:" + String(id)),
            CNDetalle.Boton(id: 1, label: cnT("Transferir"), estilo: "contorno")
        ]
        d.rotuloLista = cnT("Movimientos de esta cuenta")
        d.tramos = porMeses(l.tx.filter { medioDe($0) == id }, l, t)
        // SOLO SI NO HAY NADA. Puesto siempre, la ficha enseñaba «Todavía
        // nada · aquí saldrá todo lo que anotes» Y DEBAJO los quince
        // movimientos de la cuenta. Lo cazó la foto del banco; el fichero de
        // oro lo decía desde el principio y la prueba no miraba ese campo.
        d.vacioTexto = d.tramos.isEmpty ? cnT("Aquí saldrá todo lo que anotes con esta cuenta.") : ""
        return d
    }

    /// «Banco (opcional)» es la pregunta; el dato se llama «Banco». El
    /// paréntesis es para quien rellena, no para quien lee después.
    static func sinElParentesis(_ t: String) -> String {
        guard let i = t.firstIndex(of: "(") else { return t }
        return String(t[t.startIndex..<i]).trimmingCharacters(in: .whitespaces)
    }

    /// Cómo se escribe cada campo propio al enseñarlo: el dinero con su
    /// moneda, un porcentaje con su signo, una fecha en largo, y lo demás tal
    /// como se escribió.
    static func valorDelCampo(_ c: CNTipoAgregar.Campo, _ v: String) -> String {
        switch c.tipo {
        case "dinero": return cnDinero(cnMonto(v))
        case "porciento": return v + " %"
        case "fecha": return cnFechaLargaDeDia(v)
        default: return v
        }
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
        d.tramos = deCorrido(l.tx.filter { CNCalculo.idDe($0.medio, "tarjeta:") == id }, l, t)
        d.vacioTexto = d.tramos.isEmpty ? cnT("Aquí saldrá todo lo que pagues con esta tarjeta.") : ""
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
        d.tramos = deCorrido(l.tx.filter { $0.prestamo == id }, l, t)
        d.vacioTexto = d.tramos.isEmpty ? cnT("Aquí saldrán los pagos que vayas anotando.") : ""
        return d
    }

    // MARK: - Meta

    /**
     * UNA META POR DENTRO.
     *
     * Lo que más fácil se pierde: **el dinero que ya estaba apartado**. Una
     * meta puede llevar ahorrado sin un solo aporte anotado —porque venía así
     * de la libreta, porque se editó a mano, o porque se aportó antes de que
     * los aportes quedaran ligados a su meta—. Decir «todavía no has anotado
     * ningún aporte» encima de RD$32,000 parece un fallo, así que se dice lo
     * que es: eso venía de antes, y va como una fila más al final.
     */
    private static func deMeta(_ id: Int, _ l: CNLibreta, _ t: Tinte) -> CNDetalle? {
        guard let g = l.metas.first(where: { $0.id == id }) else { return nil }
        var d = CNDetalle()
        d.titulo = g.nombre
        let objetivo = g.meta, llevo = g.ahorrado
        let falta = max(0, objetivo - llevo)
        let cuota = g.mensual
        let meses = cuota > 0 ? Int((falta / cuota).rounded(.up)) : 0
        let pct = objetivo > 0 ? Double(min(100, Int((llevo / objetivo * 100).rounded()))) : 0
        // El lila de la PALETA, y solo si la meta no trae color suyo. Escrito
        // aquí a fuego, una meta sin color salía morada en el teléfono
        // mientras en la web seguía el tema que tuvieras puesto.
        let color = g.color.isEmpty ? t.lila : g.color
        let pieIzq: String = String(Int(pct)) + "% · " + cnT("Te falta") + " " + cnDinero(falta)
        let cuantoAparta: String = cuota > 0 ? cnDinero(cuota) : cnT("Sin cuota")
        let pieDer: String = cnT("Apartas cada mes") + " " + cuantoAparta
        // «15 meses a este ritmo» solo cuando hay ritmo y queda algo.
        var ritmo = ""
        if cuota > 0, falta > 0 {
            ritmo = cnT("{n} meses a este ritmo").replacingOccurrences(of: "{n}", with: String(meses))
        }
        d.hero = CNDetalle.Hero(
            iconoPath: glifoDeMeta(g), iconoColor: color,
            iconoBg: CNCuentasFilas.tinte(color),
            rotulo: cnT("Llevas ahorrado"), valor: cnDinero(llevo), color: color,
            pct: pct, colorBarra: color,
            pieIzq: pieIzq, pieDer: pieDer, nota: ritmo)
        // La meta NO lleva filas de datos en el teléfono: la web las manda
        // vacías a propósito, porque el bloque de arriba ya las dice.
        d.datos = []
        // El botón dice cuánto se va a aportar: así se toca sin tener que
        // mirar antes la fila del aporte mensual.
        let rotuloAportar: String = cuota > 0 ? cnT("Aportar") + " " + cnDinero(cuota) : cnT("Aportar")
        d.botones = [
            // El botón dice cuánto se va a aportar: así se toca sin tener que
            // mirar antes la fila del aporte mensual.
            CNDetalle.Boton(id: 0, label: rotuloAportar,
                            estilo: "acento", abre: "aporte", cual: id, monto: cuota),
            CNDetalle.Boton(id: 1, label: cnT("Editar la meta"), estilo: "contorno")
        ]
        d.rotuloLista = cnT("Aportes")
        let aportes = l.tx.filter { $0.meta == id }
            .sorted { $0.fecha != $1.fecha ? $0.fecha > $1.fecha : $0.id > $1.id }
        let sumado = aportes.reduce(0.0) { $0 + abs($1.monto) }
        let previo = max(0, llevo - sumado)
        d.vacioTexto = aportes.isEmpty && previo == 0
            ? cnT("Todavía no has anotado ningún aporte a esta meta.") : ""
        var items: [CNDetalle.Item] = aportes.enumerated().map { i, x in
            CNDetalle.Item(id: i, concepto: cnFechaLargaDeDia(x.fecha), sub: "",
                           montoFmt: cnDinero(abs(x.monto)), color: "")
        }
        if previo > 0 {
            items.append(CNDetalle.Item(id: items.count, concepto: cnT("Ya lo tenías apartado"),
                                        sub: "", montoFmt: cnDinero(previo), color: t.gris))
        }
        d.tramos = items.isEmpty ? [] : [CNDetalle.Tramo(id: 0, label: "", total: "", items: items)]
        return d
    }

    /// El glifo de una meta: el que eligió quien la creó y, si no, el que se
    /// adivina por el nombre —un viaje lleva maleta, una casa lleva casa—. La
    /// lista de nombres la genera `npm run sync` de la misma que usa la web,
    /// para que la misma meta no salga con dos iconos distintos.
    static func glifoDeMeta(_ g: CNMeta) -> String {
        if !g.icono.isEmpty, let p = CNCatalogos.iconos[g.icono] { return p }
        let n = g.nombre.lowercased()
        for caso in CNCatalogos.iconoDeMeta where caso.trozos.contains(where: { n.contains($0) }) {
            return CNCatalogos.iconos[caso.icono] ?? CNCatalogos.iconos["hucha"] ?? ""
        }
        return CNCatalogos.iconos["hucha"] ?? ""
    }

    // MARK: - Categoría

    /**
     * UNA CATEGORÍA POR DENTRO: cuánto llevas, contra qué, y mes a mes.
     *
     * Tres cosas que de memoria salen mal:
     *
     *  · **el límite solo cuenta mirando ESTE mes.** El presupuesto es
     *    mensual: comparar lo de seis meses contra el tope de uno daría un
     *    400 % que no significa nada. Con cualquier otro rango, la barra
     *    desaparece —`pct: -1`— y en su sitio va «al mes de media»;
     *  · **con un solo mes no hay gráfica.** Una barra sola no compara nada;
     *    vuelve en cuanto se eligen tres o más;
     *  · **el icono de arriba va en GRIS, siempre.** No en el color de la
     *    categoría: es lo que hace la web, y ponerle el suyo cambiaría la cara
     *    de la pantalla.
     */
    private static func deCategoria(_ nombre: String, _ l: CNLibreta,
                                    _ meses: Int, _ t: Tinte) -> CNDetalle? {
        var d = CNDetalle()
        d.titulo = nombre
        let hoy = String(cnHoy().prefix(7))
        // `meses == 0` es «Todo»: desde antes de que existiera nada.
        let desde = meses > 0 ? CNCabecera.mesVecino(hoy, -(meses - 1)) + "-01" : "0000-00-00"
        let dentro = l.tx.filter { $0.categoria == nombre && $0.fecha >= desde }
            .sorted { $0.fecha != $1.fecha ? $0.fecha > $1.fecha : $0.id > $1.id }
        let total = dentro.reduce(0.0) { $0 + abs($1.monto) }

        // Un cubo por mes, del más viejo al más nuevo. Con «Todo» son doce,
        // que es lo que cabe en la gráfica.
        let cuantos = meses > 0 ? meses : 12
        // Con las etiquetas puestas y el cero en coma flotante: sin ellas, Swift
        // lee `(String, Int)` y no encaja con lo declarado.
        var cubos: [(ym: String, monto: Double)] = (0..<cuantos).reversed().map {
            (ym: CNCabecera.mesVecino(hoy, -$0), monto: 0.0)
        }
        for x in dentro {
            let ym = String(x.fecha.prefix(7))
            if let i = cubos.firstIndex(where: { $0.ym == ym }) { cubos[i].monto += abs(x.monto) }
        }
        let tope = max(1, cubos.map { $0.monto }.max() ?? 0)
        let media = cubos.isEmpty ? 0 : total / Double(cubos.count)

        // La fila del presupuesto: solo la tienen las categorías de gasto que
        // no sean «Ahorro». Sin ella no hay icono ni color propios.
        let cat = l.categorias.first { $0.nombre == nombre && !$0.ingreso && $0.nombre != "Ahorro" }
        let color = (cat?.color.isEmpty == false) ? cat!.color : t.tinta
        let esMesActual = meses == 1
        let limite = l.presupuesto[nombre] ?? 0
        let hayLimite = esMesActual && limite > 0
        let pct = limite > 0 ? Int((total / limite * 100).rounded()) : 0
        let queda = limite - total

        // CADA TROZO EN SU VARIABLE, con el tipo escrito. Todo junto dentro del
        // constructor son doce ternarios anidados y el compilador se rinde.
        let glifo: String = cat != nil ? (CNCatalogos.iconos[CNCategorias.icono(nombre, en: l)] ?? "") : ""
        let colorIcono: String = (cat?.color.isEmpty == false) ? cat!.color : color
        let rotuloCifra: String = esMesActual ? cnT("Gastado este mes") : cnT("Gastado en el periodo")
        let barra: Double = hayLimite ? Double(min(100, pct)) : -1
        let colorBarra: String
        if total > limite { colorBarra = t.negativo }
        else if pct > 85 { colorBarra = t.aviso }
        else { colorBarra = t.positivo }
        var izq = "", der = ""
        if hayLimite {
            // El porcentaje SIN recortar: la barra no puede pasar de llena,
            // pero el texto tiene que poder decir «300 %». Con el recortado en
            // los dos sitios, pasarse por poco y pasarse por mucho se leen
            // igual.
            izq = cnT("{n}% del presupuesto").replacingOccurrences(of: "{n}", with: String(pct))
            der = cnT("Presupuesto {p}").replacingOccurrences(of: "{p}", with: cnDinero(limite))
        }
        var resumen = cnT("Nada anotado en este periodo")
        if !dentro.isEmpty {
            // EN SINGULAR CUANDO ES UNO. «1 movimientos» canta, y esta frase
            // sale en la ficha de cualquier categoría con un solo gasto
            // apuntado, que es el caso más normal del mundo al empezar.
            let plantilla = dentro.count == 1
                ? cnT("1 movimiento · {p} al mes de media")
                : cnT("{n} movimientos · {p} al mes de media")
                    .replacingOccurrences(of: "{n}", with: String(dentro.count))
            resumen = plantilla.replacingOccurrences(of: "{p}", with: cnDinero(media.rounded()))
        }
        d.hero = CNDetalle.Hero(
            iconoPath: glifo,
            // EN GRIS, SIEMPRE. La web manda aquí un campo que no existe en su
            // propio modelo y cae en el gris del tema; con el color de la
            // categoría, la pantalla cambia de cara.
            iconoColor: t.gris,
            iconoBg: CNCuentasFilas.tinte(colorIcono),
            rotulo: rotuloCifra, valor: cnDinero(total), color: t.tinta,
            pct: barra, colorBarra: colorBarra,
            pieIzq: izq, pieDer: der, nota: resumen)

        var filas: [CNDetalle.Dato] = [
            CNDetalle.Dato(id: 0, label: cnT("Movimientos"), valor: String(dentro.count), color: t.tinta),
            CNDetalle.Dato(id: 1, label: cnT("Promedio por movimiento"),
                           valor: cnDinero(dentro.isEmpty ? 0 : (total / Double(dentro.count)).rounded()),
                           color: t.tinta)
        ]
        if hayLimite {
            filas.append(CNDetalle.Dato(id: 2, label: cnT("Te queda"),
                                        valor: queda < 0 ? "\u{2212}" + cnDinero(-queda) : cnDinero(queda),
                                        color: queda < 0 ? t.negativo : t.positivo))
        } else {
            filas.append(CNDetalle.Dato(id: 2, label: cnT("Al mes de media"),
                                        valor: cnDinero(media.rounded()), color: t.tinta))
        }
        d.datos = filas
        d.botones = [
            CNDetalle.Boton(id: 0, label: cnT("Nuevo gasto aquí"), estilo: "acento",
                            abre: "movCat", conQue: nombre),
            CNDetalle.Boton(id: 1, label: cnT("Cambiar presupuesto"), estilo: "contorno")
        ]
        // EN DOS PASOS, con el tipo escrito. Con el ternario doble dentro del
        // constructor, el compilador se rinde: «unable to type-check this
        // expression in reasonable time». No falla la cuenta, falla la
        // compilación entera, y aquí no hay Xcode para enterarse antes.
        func rotuloDelChip(_ n: Int) -> String {
            if n == 1 { return cnT("Este mes") }
            if n <= 0 { return cnT("Todo") }
            return cnT("{n} meses").replacingOccurrences(of: "{n}", with: String(n))
        }
        let rangos: [Int] = [1, 3, 6, 12, 0]
        d.chips = rangos.enumerated().map { i, n -> CNDetalle.Chip in
            CNDetalle.Chip(indice: i, label: rotuloDelChip(n), puesta: n == meses)
        }
        if !esMesActual, cubos.contains(where: { $0.monto > 0 }) {
            // El tope se dice UNA vez arriba y no bajo cada barra: con doce
            // meses las cifras no caben, se empujan y sacan la gráfica de la
            // tarjeta.
            var b = CNDetalle.Barras(
                titulo: cnT("Mes a mes"),
                tope: cnT("máx {p}").replacingOccurrences(of: "{p}", with: cnDinero(tope)))
            // Con más de ocho meses el nombre no cabe bajo cada barra, así que
            // se rotula uno sí y uno no, CONTANDO DESDE EL FINAL para que el
            // mes en curso lleve siempre el suyo.
            let paso = cubos.count > 8 ? 2 : 1
            b.columnas = cubos.enumerated().map { i, c in
                let rotula = (cubos.count - 1 - i) % paso == 0
                let esHoy = c.ym == hoy
                return CNDetalle.Columna(
                    id: i,
                    // Espacio duro en los meses sin rótulo: un hueco vacío mide
                    // cero y dejaría esas barras más largas que las demás.
                    label: rotula ? String(CNCabecera.nombreDeMes(c.ym, largo: false).prefix(3)) : "\u{00A0}",
                    pct: (c.monto / tope * 100).rounded(),
                    fuerte: esHoy,
                    color: esHoy ? color : CNCuentasFilas.tinte(color, 0.40),
                    colorMes: esHoy ? t.tinta : t.gris)
            }
            d.barras = b
        }
        d.rotuloLista = cnT("Movimientos de la categoría")
        d.vacioTexto = dentro.isEmpty ? cnT("Aquí saldrá todo lo que anotes en esta categoría.") : ""
        d.tramos = porMeses(dentro, l, t)
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
