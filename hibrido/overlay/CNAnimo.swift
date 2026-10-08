import Foundation

/**
 * QUÉ CARA PONE CHINO, DECIDIDO AQUÍ.
 *
 * El dibujo ya lo hace el teléfono (`CNChino`), pero QUÉ ánimo dibujar lo
 * decidía la web y llegaba por el puente. Lo que decide son seis reglas sobre
 * números que el teléfono ya tiene —lo que entró, lo que salió, cuántos
 * movimientos lleva el mes, cuándo vence el próximo pago—, así que no hacía
 * falta preguntarle a nadie.
 *
 * Es el mismo orden que `src/animo.js`, y el orden ES la regla:
 *
 *  1. **ir en rojo manda sobre todo lo demás.** Poner cara de estudiosa por un
 *     recibo mientras el mes se hunde es mirar para otro lado;
 *  2. un pago encima, que es lo único que se puede arreglar hoy mismo;
 *  3. algo que celebrar —una meta cumplida, o el mes cerrado en verde—;
 *  4. mes tranquilo;
 *  5. va bien;
 *  6. y la de todos los días.
 *
 * **CELEBRAR TIENE FECHA.** Un balance positivo el día 3 no quiere decir nada:
 * casi todo el mundo cobra a principios y todavía no ha gastado. Por eso la
 * fiesta pide que el mes esté ya avanzado; antes de eso, ir bien es «fuerte»,
 * que dice lo mismo sin echar cohetes.
 *
 * Y las cinco cifras de las reglas las genera `npm run sync` de allí: copiadas
 * a mano, la cara del teléfono y la de la web dirían cosas distintas del mismo
 * mes, que es exactamente lo que pasaba cuando cada lógica tenía su cuenta.
 */
enum CNAnimo {

    /// Los números con los que se decide. Los mismos nombres que en la web.
    struct Datos {
        var ing: Double = 0
        var gas: Double = 0
        var aho: Double = 0
        var bal: Double = 0
        var movimientos: Int = 0
        /// Días hasta el pago más cercano, o `nil` si no hay ninguno. `nil` y
        /// cero no son lo mismo: cero es que vence HOY.
        var diasParaPago: Int?
        var diaDelMes: Int = 1
        var diasDelMes: Int = 30
        var metaCumplida = false
    }

    /// El ánimo que toca.
    static func delMes(_ d: Datos) -> String {
        let r = CNCatalogos.reglasDelAnimo
        // 1. EL MES VA EN ROJO.
        if d.bal < 0 { return "rota" }
        // 2. HAY UN PAGO ENCIMA.
        if let p = d.diasParaPago, p >= 0, p <= r.pronto { return "estudiosa" }
        // 3. HAY ALGO QUE CELEBRAR.
        if d.metaCumplida { return "fiesta" }
        if d.bal > 0, d.diaDelMes >= min(r.yaCasi, d.diasDelMes - 2) { return "fiesta" }
        // 4. MES TRANQUILO: casi sin movimientos, o con mucho margen y poca
        //    actividad. Sin la segunda condición, «vas bien» no salía NUNCA.
        if d.movimientos < r.pocos { return "jugo" }
        if d.ing > 0, d.bal > d.ing * r.holgado, d.movimientos < r.activo { return "jugo" }
        // 5. VA BIEN: en verde y gastando por debajo de lo que tocaría a estas
        //    alturas del mes. Sin lo segundo, el día 5 «va bien» siempre.
        if d.bal > 0, d.ing > 0 {
            let proporcion = min(1, Double(d.diaDelMes) / Double(max(1, d.diasDelMes)))
            if d.gas <= d.ing * proporcion { return "fuerte" }
        }
        // 6. Y la de todos los días.
        return "feliz"
    }

    /**
     * LOS DÍAS QUE FALTAN PARA EL PRÓXIMO PAGO, o `nil`.
     *
     * Las tarjetas por su día de pago y los préstamos que aún deben algo por el
     * suyo. El día se limita a 28 por lo mismo que en el panel: un pago «el 31»
     * no existe en febrero, y quien lo puso quería decir «a fin de mes».
     */
    static func diasParaElProximoPago(_ l: CNLibreta, hoy: Date = Date()) -> Int? {
        let cal = calendario
        let h = cal.startOfDay(for: hoy)
        let p = cal.dateComponents([.year, .month], from: h)
        func faltan(_ dia: Int) -> Int? {
            let d = min(max(dia, 1), 28)
            var c = DateComponents(year: p.year, month: p.month, day: d)
            guard var t = cal.date(from: c) else { return nil }
            if t < h {
                c.month = (p.month ?? 1) + 1
                guard let siguiente = cal.date(from: c) else { return nil }
                t = siguiente
            }
            return cal.dateComponents([.day], from: h, to: t).day
        }
        var dias: [Int] = []
        for c in l.tarjetas { if let n = faltan(c.pago) { dias.append(n) } }
        for x in l.prestamos where x.total - x.pagado > 0 {
            if let n = faltan(x.dia) { dias.append(n) }
        }
        return dias.min()
    }

    /**
     * LOS DATOS DEL ÁNIMO, SACADOS DE UNA LIBRETA.
     *
     * EL DÍA QUE CUENTA ES HOY SOLO SI SE MIRA EL MES DE HOY. En uno pasado el
     * mes está entero: se juzga cerrado y no a medias, que si no un mes de hace
     * un año se juzgaría por el día de hoy y saldría siempre a medio empezar.
     */
    static func datos(_ l: CNLibreta, mes: String, hoy: Date = Date()) -> Datos {
        let m = mes.isEmpty ? Self.mesDe(hoy) : mes
        let tx = l.tx.filter { String($0.fecha.prefix(7)) == m }
        func suma(_ tipos: Set<String>) -> Double {
            tx.filter { tipos.contains($0.tipo) }.reduce(0) { $0 + $1.monto }
        }
        var d = Datos()
        d.ing = suma(["Ingreso"])
        d.gas = suma(["Gasto Fijo", "Gasto Variable"])
        d.aho = suma(["Ahorro"])
        d.bal = d.ing - d.gas - d.aho
        d.movimientos = tx.count
        let esteMes = m == Self.mesDe(hoy)
        let largo = Self.diasDelMes(m)
        d.diasDelMes = largo
        d.diaDelMes = esteMes ? Self.diaDe(hoy) : largo
        d.diasParaPago = esteMes ? diasParaElProximoPago(l, hoy: hoy) : nil
        // Y si alguna meta llegó al 100 %, que es la celebración que no depende
        // del día del mes.
        d.metaCumplida = l.metas.contains { $0.meta > 0 && $0.ahorrado >= $0.meta }
        return d
    }

    /// El ánimo de una libreta en un mes, de una vez.
    static func deLaLibreta(_ l: CNLibreta, mes: String, hoy: Date = Date()) -> String {
        delMes(datos(l, mes: mes, hoy: hoy))
    }

    // MARK: - Fechas, en la hora de AQUÍ

    /**
     * EN LA HORA DE AQUÍ Y NO EN UTC.
     *
     * Las cuentas de la web van en la hora local, y leer las fechas en UTC deja
     * todo en el día de ANTES en cualquier sitio al oeste de Londres: el día
     * del mes sale uno menos y los días hasta el próximo pago, uno más. No
     * falla nada —sale una cara, la que sea— y por eso no se ve.
     */
    private static let calendario = Calendar(identifier: .gregorian)

    static func mesDe(_ d: Date) -> String {
        let c = calendario.dateComponents([.year, .month], from: d)
        return String(format: "%04d-%02d", c.year ?? 2000, c.month ?? 1)
    }

    static func diaDe(_ d: Date) -> Int { calendario.component(.day, from: d) }

    /// Medianoche DE AQUÍ de un «2026-10-31». Para el fichero de oro, que
    /// guarda las fechas escritas.
    static func medianoche(_ ymd: String) -> Date? {
        let p = ymd.split(separator: "-").map(String.init)
        guard p.count == 3, let a = Int(p[0]), let m = Int(p[1]), let d = Int(p[2]) else { return nil }
        return calendario.date(from: DateComponents(year: a, month: m, day: d))
    }

    /// Cuántos días tiene «2026-02». Sin tabla de meses: la de 29 de febrero se
    /// escribe mal una vez cada cuatro años y nadie lo ve hasta entonces.
    static func diasDelMes(_ ym: String) -> Int {
        let p = ym.split(separator: "-").map(String.init)
        guard p.count >= 2, let a = Int(p[0]), let m = Int(p[1]),
              let d = calendario.date(from: DateComponents(year: a, month: m, day: 1)),
              let r = calendario.range(of: .day, in: .month, for: d) else { return 30 }
        return r.count
    }
}

extension CNAnimo {
    /**
     * EL QUE SE ENSEÑA: el elegido, o el que toca si está en automático.
     *
     * «auto» es lo de fábrica, y durante mucho tiempo devolvía `feliz` y ya:
     * los seis ánimos estaban dibujados y cinco no salían NUNCA solos, así que
     * solo se veían eligiéndolos a mano y fuera de contexto. Una cara de
     * preocupación un día que vas bien no significa nada.
     */
    static func puesto(_ elegido: String, libreta l: CNLibreta,
                       mes: String, hoy: Date = Date()) -> String {
        if !elegido.isEmpty, elegido != "auto" { return elegido }
        return deLaLibreta(l, mes: mes, hoy: hoy)
    }
}
