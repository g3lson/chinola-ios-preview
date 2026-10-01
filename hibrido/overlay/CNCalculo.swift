import Foundation

/// LOS CÁLCULOS, EN NATIVO.
///
/// Hasta ahora las cifras las sacaba la web y el nativo se las pedía por el
/// puente. Aquí están en Swift, sobre la misma libreta que el nativo ya tiene
/// (`CNDatos.shared.libreta`), sin cruzar nada.
///
/// Es un espejo deliberado de `src/movil/logica.js`: mismos nombres, mismo
/// orden de operaciones y mismas rarezas, para que las dos den siempre lo
/// mismo. Donde la web tiene una decisión que no se adivina —la deuda de una
/// tarjeta va al revés, el día de pago se recorta a 28— queda dicho aquí.
/// Si cambias una regla, cámbiala en los dos sitios.
enum CNCalculo {

    // MARK: - Períodos

    /// Un período: o un mes («2026-09») o un rango de fechas a medida.
    struct Periodo: Equatable {
        var mes: String
        var desde: String?
        var hasta: String?
        init(mes: String, desde: String? = nil, hasta: String? = nil) {
            self.mes = mes; self.desde = desde; self.hasta = hasta
        }
        var aMedida: Bool { desde != nil && hasta != nil }
    }

    /// ¿Cae esta fecha dentro del período? Con rango a medida se compara la
    /// fecha entera; si no, basta con que el mes coincida. Las fechas son
    /// «yyyy-MM-dd», así que comparar textos ordena bien y no hace falta
    /// convertir a fecha ninguna de las dos.
    static func enPeriodo(_ fecha: String, _ p: Periodo) -> Bool {
        guard let desde = p.desde, let hasta = p.hasta else { return fecha.hasPrefix(p.mes) }
        return fecha >= desde && fecha <= hasta
    }

    // MARK: - Totales del período

    struct Totales: Equatable {
        var ing: Double = 0      // ingresos
        var gas: Double = 0      // gastos (fijos + variables)
        var fij: Double = 0      // gastos fijos
        var vari: Double = 0     // gastos variables = gas − fij
        var aho: Double = 0      // ahorro
        var bal: Double = 0      // balance = ing − gas − aho
    }

    /// Ingresos, gastos, ahorro y balance de un período.
    ///
    /// El ahorro NO es un gasto, pero sí sale del balance: guardar dinero no
    /// empobrece, pero tampoco queda disponible. Así lo hace la web y así se
    /// queda.
    static func totales(_ l: CNLibreta, _ p: Periodo) -> Totales {
        var t = Totales()
        for x in l.tx where enPeriodo(x.fecha, p) {
            switch x.tipo {
            case "Ingreso": t.ing += x.monto
            case "Gasto Fijo": t.gas += x.monto; t.fij += x.monto
            case "Gasto Variable": t.gas += x.monto
            case "Ahorro": t.aho += x.monto
            default: break      // Transferencia: mueve dinero, no lo crea ni lo gasta
            }
        }
        t.vari = t.gas - t.fij
        t.bal = t.ing - t.gas - t.aho
        return t
    }

    /// Los totales de varios meses seguidos, hacia atrás desde uno dado.
    /// El más viejo primero, que es como se dibuja la tendencia.
    static func porMeses(_ l: CNLibreta, hasta mes: String, cuantos: Int) -> [(mes: String, t: Totales)] {
        mesesAtras(desde: mes, cuantos: cuantos).map { ($0, totales(l, Periodo(mes: $0))) }
    }

    /// «2026-09», «2026-08», … del más viejo al más nuevo.
    static func mesesAtras(desde mes: String, cuantos: Int) -> [String] {
        guard cuantos > 0, let (a, m) = anioMes(mes) else { return [] }
        var salida: [String] = []
        for i in stride(from: cuantos - 1, through: 0, by: -1) {
            let total = a * 12 + (m - 1) - i
            salida.append(String(format: "%04d-%02d", total / 12, total % 12 + 1))
        }
        return salida
    }

    private static func anioMes(_ mes: String) -> (Int, Int)? {
        let p = mes.split(separator: "-")
        guard p.count >= 2, let a = Int(p[0]), let m = Int(p[1]), (1...12).contains(m) else { return nil }
        return (a, m)
    }

    // MARK: - Por categoría

    /**
     * Lo que salió en cada categoría del período, de más a menos.
     *
     * NO ES SOLO `esGasto`, y esto se decidió mirando la web en vez de
     * suponerlo: lo que no entra son los ingresos y las transferencias. El
     * AHORRO SÍ CUENTA, porque también salió del mes y la gente tiene su
     * categoría «Ahorro» como cualquier otra. Con `esGasto` —que es solo
     * «Gasto Fijo» y «Gasto Variable»— el gráfico de categorías se quedaba sin
     * el ahorro y no cuadraba con la web.
     *
     * El plan es otra cosa y ahí el ahorro SÍ se excluye: allí se compara
     * contra un tope que te pusiste, y apartar dinero a propósito no es pasarse
     * de ningún tope. Que las dos pantallas no cuenten igual no es un descuido:
     * responden a preguntas distintas.
     */
    static func porCategoria(_ l: CNLibreta, _ p: Periodo) -> [(categoria: String, gastado: Double)] {
        var suma: [String: Double] = [:]
        for x in l.tx where x.tipo != "Ingreso" && !x.esTransfer && enPeriodo(x.fecha, p) {
            suma[x.categoria, default: 0] += abs(x.monto)
        }
        return suma.map { (categoria: $0.key, gastado: $0.value) }
            .sorted { $0.gastado != $1.gastado ? $0.gastado > $1.gastado : $0.categoria < $1.categoria }
    }

    // MARK: - Presupuesto

    struct FilaPresupuesto {
        var categoria = ""
        var limite: Double = 0
        var gastado: Double = 0
        /// 0…100, recortado arriba como en la web (`pct`).
        var pct: Int = 0
        var excedida = false
    }

    struct Presupuesto {
        var filas: [FilaPresupuesto] = []
        var limiteTotal: Double = 0
        var gastadoTotal: Double = 0
        var pctTotal: Int = 0
        var excedidas: Int = 0
    }

    /// El presupuesto del período: cada categoría de gasto con su tope y lo
    /// que lleva gastado.
    ///
    /// Espejo de `presRows` en src/movil/logica.js, con sus dos reglas:
    /// se saltan las categorías de ingreso y se salta «Ahorro» (que tiene su
    /// propia pantalla). El tope sale de `libreta.presupuesto[nombre]`, NO de
    /// `categoria.limite`, que la web no manda.
    static func presupuesto(_ l: CNLibreta, _ p: Periodo) -> Presupuesto {
        let gasto = Dictionary(porCategoria(l, p).map { ($0.categoria, $0.gastado) },
                               uniquingKeysWith: { a, _ in a })
        var r = Presupuesto()
        for c in l.categorias where !c.ingreso && c.nombre != "Ahorro" {
            let limite = l.presupuesto[c.nombre] ?? 0
            let gastado = gasto[c.nombre] ?? 0
            var f = FilaPresupuesto(categoria: c.nombre, limite: limite, gastado: gastado)
            f.pct = limite > 0 ? min(100, Int((gastado / limite * 100).rounded())) : 0
            f.excedida = limite > 0 && gastado > limite
            r.filas.append(f)
            r.limiteTotal += limite
            r.gastadoTotal += gastado
            if f.excedida { r.excedidas += 1 }
        }
        r.pctTotal = r.limiteTotal > 0 ? min(100, Int((r.gastadoTotal / r.limiteTotal * 100).rounded())) : 0
        return r
    }

    // MARK: - Saldos

    /// Lo que un movimiento le hace a las cuentas y a las tarjetas.
    ///
    /// Ojo: los saldos NO se recalculan sumando todos los movimientos. Se
    /// mantienen: cada alta suma (`signo` +1) y cada baja resta (−1). Esto es
    /// un espejo de `aplica` en la web y tiene que aplicarse en los mismos
    /// momentos, o los saldos se van.
    ///
    /// Tres reglas que no se adivinan:
    /// · En una TARJETA lo que se mueve es la deuda, no el saldo, y va al
    ///   revés: gastar la sube, pagar la baja.
    /// · La deuda nunca baja de cero.
    /// · Un ingreso a una tarjeta no hace nada (se ignora), porque cobrar en
    ///   una tarjeta de crédito no existe.
    @discardableResult
    static func aplica(_ l: inout CNLibreta, _ mov: CNMov, signo: Double = 1) -> Bool {
        let medio = mov.medio

        if mov.esTransfer {
            // Sale de `medio` y entra en `destino`. Se hace a mano por los dos
            // lados: en una cuenta el saldo sube o baja; en una tarjeta baja la
            // deuda, que es lo que significa pagarla.
            let salio = mueve(&l, medio, -mov.monto * signo)
            let entro = mueve(&l, mov.destino, mov.monto * signo)
            return salio || entro
        }

        if let id = idDe(medio, "cuenta:"), let i = l.cuentas.firstIndex(where: { $0.id == id }) {
            let delta = mov.monto * (mov.tipo == "Ingreso" ? 1 : -1) * signo
            l.cuentas[i].saldo += delta
            return true
        }

        if let id = idDe(medio, "tarjeta:"), mov.tipo != "Ingreso",
           let i = l.tarjetas.firstIndex(where: { $0.id == id }) {
            l.tarjetas[i].saldo = max(0, l.tarjetas[i].saldo + mov.monto * signo)
            return true
        }

        return false
    }

    @discardableResult
    private static func mueve(_ l: inout CNLibreta, _ donde: String, _ delta: Double) -> Bool {
        guard !donde.isEmpty, delta != 0 else { return false }
        if let id = idDe(donde, "cuenta:"), let i = l.cuentas.firstIndex(where: { $0.id == id }) {
            l.cuentas[i].saldo += delta
            return true
        }
        if let id = idDe(donde, "tarjeta:"), let i = l.tarjetas.firstIndex(where: { $0.id == id }) {
            // Al revés a propósito: meter dinero en una tarjeta baja la deuda.
            l.tarjetas[i].saldo = max(0, l.tarjetas[i].saldo - delta)
            return true
        }
        return false
    }

    /// «cuenta:7» → 7. Devuelve nil si no lleva ese prefijo.
    static func idDe(_ medio: String, _ prefijo: String) -> Int? {
        guard medio.hasPrefix(prefijo) else { return nil }
        return Int(medio.dropFirst(prefijo.count))
    }

    /// Lo que suman todas las cuentas, y lo que se debe en todas las tarjetas.
    static func saldoCuentas(_ l: CNLibreta) -> Double { l.cuentas.reduce(0) { $0 + $1.saldo } }
    static func deudaTarjetas(_ l: CNLibreta) -> Double { l.tarjetas.reduce(0) { $0 + $1.saldo } }

    private static func pendiente(_ p: CNPrestamo) -> Double { max(0, p.total - p.pagado) }

    /// Lo que DEBES en préstamos. Resta del patrimonio.
    static func deudaPrestamos(_ l: CNLibreta) -> Double {
        l.prestamos.filter { $0.sentido != "meDeben" }.reduce(0) { $0 + pendiente($1) }
    }

    /// Lo que TE DEBEN. Suma al patrimonio: es dinero tuyo que está fuera.
    static func porCobrarPrestamos(_ l: CNLibreta) -> Double {
        l.prestamos.filter { $0.sentido == "meDeben" }.reduce(0) { $0 + pendiente($1) }
    }

    /// Lo pendiente de todos los préstamos, sin mirar el sentido. Es lo que se
    /// enseña como total del grupo «Préstamos», que ahí sí se listan los dos.
    static func pendientePrestamos(_ l: CNLibreta) -> Double {
        l.prestamos.reduce(0) { $0 + pendiente($1) }
    }

    /// El patrimonio: lo que hay, menos lo que debes, más lo que te deben.
    ///
    /// La web restaba TODOS los préstamos, así que uno a tu favor te bajaba el
    /// patrimonio. Se arregló en los dos sitios a la vez (src/movil/logica.js y
    /// src/logica.js); si cambias uno, cambia el otro o las cifras se separan.
    static func patrimonio(_ l: CNLibreta) -> Double {
        saldoCuentas(l) - deudaTarjetas(l) - deudaPrestamos(l) + porCobrarPrestamos(l)
    }

    // MARK: - Lo que viene

    /// Cuántos días faltan para el próximo día N del mes.
    ///
    /// Se recorta a 1…28 como en la web: así no hay que decidir qué pasa con
    /// el 31 en febrero. Si ya pasó este mes, cuenta para el que viene; si es
    /// hoy, devuelve 0.
    static func diasHastaElDia(_ dia: Int, desde: Date = Date()) -> Int {
        let cal = Calendar(identifier: .gregorian)
        let hoy = cal.startOfDay(for: desde)
        let d = min(max(dia, 1), 28)
        var c = cal.dateComponents([.year, .month], from: hoy)
        c.day = d
        guard var objetivo = cal.date(from: c) else { return 0 }
        if objetivo < hoy {
            objetivo = cal.date(byAdding: .month, value: 1, to: objetivo) ?? objetivo
        }
        return cal.dateComponents([.day], from: hoy, to: objetivo).day ?? 0
    }

    struct Pago: Identifiable {
        var id: String { tipo + ":" + String(referencia) }
        var tipo: String        // "tarjeta" | "prestamo"
        var referencia: Int
        var nombre: String
        var monto: Double
        var dias: Int
        /// El día del corte de la tarjeta. La web lo enseña en el detalle —«RD$X
        /// · corte día 15»— y sin él la fila dice cuánto y cuándo hay que pagar
        /// pero no desde cuándo cuenta. En un préstamo no hay corte: va en 0.
        var corte: Int = 0
        /// El día del mes en que se paga. En un préstamo es lo que la web enseña
        /// en el detalle —«RD$8,500 · día 10»—, y sin él la fila dice cuánto
        /// falta pero no cuándo toca.
        var dia: Int = 0
    }

    /// Los pagos que vienen, del más cercano al más lejano: el corte de cada
    /// tarjeta con deuda y la cuota de cada préstamo que se debe.
    static func pagosQueVienen(_ l: CNLibreta, desde: Date = Date()) -> [Pago] {
        var salida: [Pago] = []
        for t in l.tarjetas where t.saldo > 0 {
            salida.append(Pago(tipo: "tarjeta", referencia: t.id, nombre: t.nombre,
                               monto: t.saldo, dias: diasHastaElDia(t.pago, desde: desde),
                               corte: t.corte, dia: t.pago))
        }
        for p in l.prestamos where p.sentido != "meDeben" {
            let pendiente = max(0, p.total - p.pagado)
            guard pendiente > 0 else { continue }
            // Lo que se recuerda de un préstamo es la CUOTA del mes y el día en
            // que vence, no lo que falta por pagar entero. Aquí iba `dias: 0`,
            // así que TODAS las cuotas salían como «hoy», en rojo y arriba: el
            // recordatorio decía que hoy vence todo lo que debes. Y el monto era
            // el pendiente completo, que en un préstamo a tres años es una cifra
            // que no tiene nada que ver con lo que hay que pagar este mes.
            salida.append(Pago(tipo: "prestamo", referencia: p.id, nombre: p.nombre,
                               monto: p.cuota > 0 ? p.cuota : pendiente,
                               dias: diasHastaElDia(p.dia, desde: desde), dia: p.dia))
        }
        return salida.sorted { $0.dias != $1.dias ? $0.dias < $1.dias : $0.monto > $1.monto }
    }

    // MARK: - Dinero
    //
    // No hay formateador aquí a propósito: ya está `cnDinero` (magnitudes) y
    // `cnDineroFirmado` (lo que puede ser negativo) en ChinolaNativo.swift,
    // con la moneda y los decimales del perfil. Tener dos es justo la manera
    // de que un día enseñen cosas distintas.

    // MARK: - El patrimonio, desmenuzado

    /// El patrimonio partido en las piezas que lo explican, para las tarjetas
    /// de arriba de Cuentas: lo que tienes, lo que debes, de dónde sale cada
    /// parte y cómo ha ido cambiando.
    struct Retrato {
        /// Cuentas + lo que te deben.
        var tienes: Double = 0
        /// Tarjetas + préstamos que debes.
        var debes: Double = 0
        /// El patrimonio: tienes − debes.
        var queda: Double = 0
        /// Lo que hay para gastar hoy (banco, efectivo, billeteras).
        var paraGastar: Double = 0
        /// Lo guardado (ahorro e inversión).
        var ahorro: Double = 0
        /// Lo que te deben, aparte.
        var porCobrar: Double = 0
        /// Cada tarjeta con lo que debe, de mayor a menor.
        var tarjetas: [(nombre: String, monto: Double)] = []
        /// Lo que debes en préstamos.
        var prestamos: Double = 0
        /// Cuánto subió o bajó este mes.
        var cambioMes: Double = 0
        /// El patrimonio al cierre de cada mes, del más viejo al de hoy.
        var serie: [(etiqueta: String, valor: Double)] = []
    }

    /// Las clases de cuenta que son dinero disponible hoy. Las demás
    /// —ahorro, inversión— también son tuyas, pero no se gastan mañana.
    private static let clasesGasto: Set<String> = ["banco", "efectivo", "billetera"]

    /**
     * CUÁNTO CAMBIÓ TU PATRIMONIO CON ESTE MOVIMIENTO.
     *
     * No es «ingreso menos gasto», y esa confusión es la que hacía bajar la
     * gráfica justo cuando mejorabas: pagar una tarjeta o abonar a un préstamo
     * SALE como gasto y no te empobrece —el dinero sale de la cuenta y la
     * deuda baja lo mismo, así que te quedas igual—. Bajabas tu deuda y la
     * línea bajaba. Y apartar para una meta contaba cero cuando el dinero sí
     * sale de tu cuenta de verdad.
     *
     * No se adivina por la etiqueta: se APLICA el movimiento y se mide la
     * diferencia. Así vale para todas, también para las que el tipo no
     * distingue, y el día que cambie `aplica` esto cambia con ella.
     */
    static func efectoEnPatrimonio(_ l: CNLibreta, _ item: CNMov) -> Double {
        var despues = l
        // Pagar la tarjeta desde su hoja NO pasa por `aplica`: no toca la
        // cuenta, la app lo hace así desde el primer día. Ahí solo la marca.
        if item.tarjeta == 0 { _ = aplica(&despues, item, signo: 1) }
        marca(&despues, item)
        return despues.patrimonio - l.patrimonio
    }

    /// Lo que el movimiento hace APARTE de mover un saldo: subir lo pagado de
    /// un préstamo, o bajar la deuda de una tarjeta pagada desde su hoja.
    /// `aplica` no lo sabe, porque eso no está en el movimiento sino en su marca.
    private static func marca(_ l: inout CNLibreta, _ item: CNMov) {
        let m = abs(item.monto)
        if item.prestamo != 0 {
            l.prestamos = l.prestamos.map { p in
                guard p.id == item.prestamo else { return p }
                var x = p; x.pagado = min(p.total, p.pagado + m); return x
            }
            return
        }
        if item.tarjeta != 0 {
            l.tarjetas = l.tarjetas.map { t in
                guard t.id == item.tarjeta else { return t }
                var x = t; x.saldo = max(0, t.saldo - m); return x
            }
        }
    }

    static func retrato(_ l: CNLibreta, meses: Int = 12, hoy: Date = Date()) -> Retrato {
        var r = Retrato()
        r.paraGastar = l.cuentas.filter { clasesGasto.contains($0.clase) }.reduce(0) { $0 + $1.saldo }
        r.ahorro = l.cuentas.filter { !clasesGasto.contains($0.clase) }.reduce(0) { $0 + $1.saldo }
        r.porCobrar = porCobrarPrestamos(l)
        r.tienes = saldoCuentas(l) + r.porCobrar
        r.prestamos = deudaPrestamos(l)
        r.debes = deudaTarjetas(l) + r.prestamos
        r.queda = r.tienes - r.debes
        r.tarjetas = l.tarjetas.map { (nombre: $0.nombre, monto: $0.saldo) }
            .filter { $0.monto > 0 }
            .sorted { $0.monto > $1.monto }

        // Cómo ha ido cambiando. Los saldos que guarda la libreta son los de
        // HOY, así que la historia se reconstruye hacia atrás: el patrimonio
        // al cierre del mes anterior es el de este menos lo que entró y salió
        // durante este. Es una reconstrucción, no un registro: las cuentas y
        // las deudas que se crearon a mitad de camino no se tienen en cuenta.
        let cal = Calendar(identifier: .gregorian)
        let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM"; fmt.locale = Locale(identifier: "en_US_POSIX")
        var valor = r.queda
        var puntos: [(String, Double)] = []
        for atras in 0..<max(1, meses) {
            guard let d = cal.date(byAdding: .month, value: -atras, to: hoy) else { break }
            let ym = fmt.string(from: d)
            // LA FOTO MANDA SOBRE LA RECONSTRUCCIÓN, y además vuelve a anclar
            // la cuenta hacia atrás: los meses sin foto se deducen desde la
            // foto más cercana y no desde hoy. Así, crear una cuenta con saldo
            // —que no es un movimiento y no se puede deducir— deja de torcer
            // todo lo anterior. El mes en curso vale lo de AHORA: su foto es de
            // hace un rato.
            if atras > 0, let f = l.historia[ym] { valor = f }
            puntos.append((ym, valor))
            // Lo que cambió el patrimonio ese mes: la suma de lo que hizo cada
            // movimiento, no ingresos menos gastos.
            let cambio = l.tx.filter { $0.fecha.hasPrefix(ym) }
                .reduce(0.0) { $0 + efectoEnPatrimonio(l, $1) }
            if atras == 0 { r.cambioMes = cambio }
            valor -= cambio
        }
        r.serie = puntos.reversed().map { (etiqueta: $0.0, valor: $0.1) }
        return r
    }
}
