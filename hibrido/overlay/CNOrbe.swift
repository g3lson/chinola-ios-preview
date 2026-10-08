import SwiftUI

/**
 * EL ORBE: LA SEGUNDA FAMILIA DE CHINO.
 *
 * Chino tiene dos maneras de aparecer: la fruta de `CNChino` y esta esfera. No
 * se sustituyen —conviven, y cada quien elige con cuál quiere que le hablen—,
 * así que el teléfono tiene que saber dibujar las dos. Mientras solo supo la
 * fruta, quien tuviera el orbe elegido veía otra cosa.
 *
 * AQUÍ NO HAY NADA DIBUJADO A MANO. Las figuras las genera `npm run sync`
 * llamando a `src/orbe.js`, que a su vez es la transcripción de unos cuadros
 * del diseño. Su nota lo dice y vale igual aquí: **redibujar un diseño es
 * opinar sobre él.** Rehacerlo mirándolo sale parecido y no igual —una hoja
 * donde no había, un degradado cortado antes de donde acaba— y además serían
 * dos dibujos que un día dirían cosas distintas.
 *
 * Lo que SÍ está aquí es el ORDEN, que es lo que de verdad decide cómo se ve:
 *
 *  · el tallo y la hoja van ENTRE el resplandor y la esfera, para que la esfera
 *    los tape por abajo;
 *  · el aro fino va encima de la esfera y debajo de la cara;
 *  · **la piel manda en el fondo, siempre.** Si alguien eligió el orbe negro
 *    sigue negro aunque el mes vaya en rojo: se volvía naranja y dejaba de ser
 *    el que había elegido. Lo que cambia con el mes son las dos luces de los
 *    ojos, que en un orbe negro es lo que más se ve;
 *  · **el estado manda sobre la cara, pero no sobre el color.** Si el mes va en
 *    rojo y encima está pensando, la luz sigue siendo la del mes: lo que pasa
 *    ahora no borra cómo vas.
 *
 * La VIDA —parpadear, respirar, las chispas que giran— se queda fuera a
 * propósito, igual que en la fruta: son animaciones CSS dentro del SVG y aquí
 * se harían con el reloj de SwiftUI. Es otro trabajo y va aparte.
 */

/// Una figura del dibujo, ya traducida: una elipse, un rectángulo o un trazo,
/// colocados por su CAJA en un lienzo de 0 a 100.
struct CNOrbePieza {
    var forma = ""
    var x: Double = 0
    var y: Double = 0
    var w: Double = 0
    var h: Double = 0
    var rx: Double = 0
    var d = ""
    /// Un color, o «grad:nombre» cuando es un degradado de los de abajo.
    var relleno = ""
    var trazo = ""
    var grosor: Double = 0
    var raya: Double = 0
    var opacidad: Double = 1
    var gira: Double = 0
    var giraX: Double = 50
    var giraY: Double = 50
}

/// Un degradado del diseño. El radio ya viene resuelto como lo resuelve CSS:
/// hasta la esquina más lejana, que es el 103 % del lado y no el 50 %.
struct CNOrbeGrad {
    var tipo = "radial"
    var cx: Double = 50
    var cy: Double = 50
    var r: Double = 50
    var x1: Double = 0
    var y1: Double = 0
    var x2: Double = 0
    var y2: Double = 0
    var paradas: [(off: Double, color: String, alfa: Double)] = []
}

/// Una cara: la del ánimo, o la de uno de los dos estados.
struct CNOrbeCara {
    var fondo = "normal"
    var quieto = false
    var brinca = false
    var lento = false
    var chispas = false
    var orbita = false
    /// Lo que va DETRÁS de la cara y delante del aro: el aro de puntos de
    /// «Pensando».
    var detras: [CNOrbePieza] = []
    var cara: [CNOrbePieza] = []
}

/// De qué está hecho. La piel la elige la persona; el ánimo lo elige el mes.
struct CNOrbePiel {
    var nombre = ""
    /// Vacío = usa el fondo del ánimo. Con nombre, el suyo manda.
    var fondoPropio = ""
    /// Entre el resplandor y la esfera.
    var encima: [CNOrbePieza] = []
    /// Delante de todo: el destello de «Orbe chinola».
    var delante: [CNOrbePieza] = []
    /// La piel oscura pone su propia cara —dos luces y nada más, que es lo que
    /// la hace ser lo que es— y lo que cambia con el mes es su color.
    var caraPropia = false
    var propiaNormal: [CNOrbePieza] = []
    var propiaCalida: [CNOrbePieza] = []
}

struct CNOrbe: View {
    /// feliz · fiesta · fuerte · estudiosa · rota · jugo
    var animo: String = "feliz"
    /// clara · chinola · semilla
    var piel: String = "clara"
    /// Lo que pasa AHORA, encima del ánimo: «escuchando» o «pensando». No dice
    /// cómo va el mes.
    var estado: String = ""
    var tam: CGFloat = 120
    /// Quita el aire de alrededor. El dibujo lo deja para el resplandor y las
    /// chispas, y en un icono ese aire lo hace verse más chico que los iconos
    /// de al lado.
    var ajustado: Bool = false
    /// Los tres puntos de «estoy escribiendo», debajo.
    var conPuntos: Bool = false
    /// El tallo y la hoja, para las pieles que no traen los suyos.
    var conHoja: Bool = false

    private static let lienzo: CGFloat = 100

    private var laPiel: CNOrbePiel {
        CNCatalogos.pielesDelOrbe[piel] ?? CNCatalogos.pielesDelOrbe["clara"] ?? CNOrbePiel()
    }

    /// La cara que toca: la del estado si lo hay, y si no la del ánimo.
    private var laCara: CNOrbeCara {
        let base = CNCatalogos.carasDelOrbe[CNCatalogos.animosDelOrbe[animo] ?? "orbe"]
            ?? CNOrbeCara()
        guard !estado.isEmpty, let cual = CNCatalogos.estadosDelOrbe[estado],
              var x = CNCatalogos.carasDelOrbe[cual] else { return base }
        // EL ESTADO MANDA SOBRE LA CARA, PERO NO SOBRE EL COLOR.
        x.fondo = base.fondo
        return x
    }

    /// De dónde salen los degradados. La piel manda cuando trae el suyo.
    private var cualFondo: String {
        laPiel.fondoPropio.isEmpty ? laCara.fondo : laPiel.fondoPropio
    }

    /// El aire de alrededor, en unidades del lienzo.
    private var aire: CGFloat {
        CGFloat(ajustado ? CNCatalogos.aireDelOrbe.ajustado : CNCatalogos.aireDelOrbe.normal)
    }

    var body: some View {
        let lado = Self.lienzo + aire * 2
        return dibujo
            .frame(width: Self.lienzo, height: Self.lienzo)
            // El lienzo crece por los cuatro lados: el dibujo se queda en el
            // centro y lo de fuera —el resplandor, las chispas— cabe.
            .padding(aire)
            .frame(width: lado, height: lado)
            // Recortado como lo recorta el SVG: las chispas se salen de la
            // esfera —una llega a x=106— y con poco aire asoman por fuera del
            // cuadro, que en una fila de iconos se ve como un borrón.
            .clipped()
            .scaleEffect(tam / lado)
            .frame(width: tam, height: tam)
    }

    private var dibujo: some View {
        let c = laCara
        let p = laPiel
        // Que el mes vaya en rojo es lo que enciende las luces cálidas de la
        // piel oscura. Lo dice el fondo de la CARA, no el de la piel.
        let calida = c.fondo == "calida"
        return ZStack {
            if c.orbita { piezas(conPuntos ? CNCatalogos.orbitaSolaDelOrbe : CNCatalogos.orbitaDelOrbe) }
            piezas(CNCatalogos.haloDelOrbe)
            // El tallo y la hoja ENTRE el resplandor y la esfera: así la esfera
            // los tapa por abajo, que es como están en el diseño.
            if !p.encima.isEmpty { piezas(p.encima) } else if conHoja { piezas(CNCatalogos.hojaDelOrbe) }
            piezas(CNCatalogos.esferaDelOrbe)
            piezas(CNCatalogos.aroDelOrbe)
            if !c.detras.isEmpty { piezas(c.detras) }
            if p.caraPropia {
                piezas(calida ? p.propiaCalida : p.propiaNormal)
            } else {
                piezas(c.cara)
            }
            if !p.delante.isEmpty { piezas(p.delante) }
            // Las chispas no se ponen sobre la piel oscura: ahí la gracia son
            // las dos luces en lo oscuro, y lo demás solo las tapa.
            if c.chispas && !p.caraPropia { piezas(CNCatalogos.chispasDelOrbe) }
            if conPuntos { piezas(CNCatalogos.puntosDelOrbe) }
        }
        .frame(width: Self.lienzo, height: Self.lienzo)
    }

    private func piezas(_ lista: [CNOrbePieza]) -> some View {
        ZStack {
            ForEach(Array(lista.enumerated()), id: \.offset) { _, f in
                una(f)
            }
        }
        .frame(width: Self.lienzo, height: Self.lienzo)
    }

    @ViewBuilder private func una(_ f: CNOrbePieza) -> some View {
        let caja = CGRect(x: f.x, y: f.y, width: f.w, height: f.h)
        let centro = CGPoint(x: caja.midX, y: caja.midY)
        let anclaGiro = UnitPoint(x: CGFloat(f.giraX / 100), y: CGFloat(f.giraY / 100))
        Group {
            if f.forma == "trazo" {
                let forma = CNSVGShape(d: f.d, viewBox: Self.lienzo)
                if !f.trazo.isEmpty {
                    forma.stroke(pinta(f.trazo).opacity(f.opacidad),
                                 style: StrokeStyle(lineWidth: CGFloat(f.grosor), lineCap: .round))
                } else {
                    // UN TRAZO SE DIBUJA SOBRE EL LIENZO ENTERO, así que su
                    // degradado hay que llevarlo a donde está la figura: medido
                    // sobre el lienzo, el de la hoja se estira por todo el
                    // cuadro y sale de otro color.
                    forma.fill(estilo(f.relleno, f, enLienzo: true)).opacity(f.opacidad)
                }
            } else if f.forma == "elipse" {
                conPintura(Ellipse(), f)
                    .frame(width: CGFloat(f.w), height: CGFloat(f.h))
                    .position(x: centro.x, y: centro.y)
            } else {
                conPintura(RoundedRectangle(cornerRadius: CGFloat(f.rx), style: .continuous), f)
                    .frame(width: CGFloat(f.w), height: CGFloat(f.h))
                    .position(x: centro.x, y: centro.y)
            }
        }
        .frame(width: Self.lienzo, height: Self.lienzo)
        // El giro va sobre SU punto, el mismo que trae el diseño: una ceja
        // girada sobre el centro de la esfera acaba en otro sitio.
        .rotationEffect(.degrees(f.gira), anchor: anclaGiro)
    }

    /// Rellena o bordea una forma, según lo que traiga la figura. Un borde con
    /// rayas es el aro de puntos de «Pensando».
    @ViewBuilder private func conPintura<F: Shape>(_ forma: F, _ f: CNOrbePieza) -> some View {
        if !f.trazo.isEmpty {
            let pluma = StrokeStyle(lineWidth: CGFloat(f.grosor),
                                    dash: f.raya > 0 ? [CGFloat(f.raya), CGFloat(f.raya)] : [])
            forma.stroke(pinta(f.trazo).opacity(f.opacidad), style: pluma)
        } else {
            forma.fill(estilo(f.relleno, f, enLienzo: false)).opacity(f.opacidad)
        }
    }

    /**
     * Un color suelto, o el degradado que le toque a este fondo.
     *
     * `enLienzo` dice sobre qué se mide: una elipse y un rectángulo se dibujan
     * en una caja de su tamaño —y ahí el degradado va de 0 a 1 de la caja—,
     * pero un trazo se dibuja sobre el lienzo entero, así que su degradado hay
     * que correrlo hasta donde está la figura.
     */
    private func estilo(_ t: String, _ f: CNOrbePieza, enLienzo: Bool) -> AnyShapeStyle {
        guard t.hasPrefix("grad:") else { return AnyShapeStyle(pinta(t)) }
        let nombre = String(t.dropFirst(5))
        // «esfera» y «halo» son los que cambian con el fondo; «osem» —las dos
        // luces de la piel oscura— cambia con el mes.
        var clave = nombre
        if nombre == "esfera" || nombre == "halo" { clave = nombre + ":" + cualFondo }
        if nombre == "osem" { clave = "osem:" + (laCara.fondo == "calida" ? "calida" : "normal") }
        guard let g = CNCatalogos.gradientesDelOrbe[clave] else { return AnyShapeStyle(pinta(t)) }
        let paradas = g.paradas.map {
            Gradient.Stop(color: cnColor(hexString: $0.color).opacity($0.alfa),
                          location: CGFloat($0.off))
        }
        // Un punto en % de la CAJA de la figura, puesto en el sitio que le toca
        // de lo que se vaya a dibujar.
        func punto(_ px: Double, _ py: Double) -> UnitPoint {
            guard enLienzo else { return UnitPoint(x: CGFloat(px / 100), y: CGFloat(py / 100)) }
            let ancho = Double(Self.lienzo)
            let alto = Double(Self.lienzo)
            let ux = (f.x + f.w * px / 100) / ancho
            let uy = (f.y + f.h * py / 100) / alto
            return UnitPoint(x: CGFloat(ux), y: CGFloat(uy))
        }
        if g.tipo == "lineal" {
            return AnyShapeStyle(LinearGradient(stops: paradas,
                                                startPoint: punto(g.x1, g.y1),
                                                endPoint: punto(g.x2, g.y2)))
        }
        // El radio es un % del LADO DE LA FIGURA, no del lienzo: el resplandor
        // y la esfera no miden lo mismo, y con el mismo número uno de los dos
        // sale cortado.
        return AnyShapeStyle(RadialGradient(stops: paradas, center: punto(g.cx, g.cy),
                                            startRadius: 0,
                                            endRadius: CGFloat(g.r / 100 * max(1, f.w))))
    }

    private func pinta(_ t: String) -> Color {
        t.isEmpty ? .clear : cnColor(hexString: t)
    }
}

/**
 * CHINO, SEA CUAL SEA SU FAMILIA.
 *
 * Son dos dibujos distintos —la fruta y la esfera— y quien los enseña no tiene
 * por qué saber cuál toca: lo elige la persona en «Tu personaje», y de ahí sale
 * también de qué está hecho el orbe. Decidirlo aquí y no en cada sitio que pide
 * un dibujo es lo que garantiza que la cara sea la misma en el botón, en la
 * charla y en la hoja —y lo que deja añadir una familia más sin ir a tocar diez
 * llamadas—. Es lo mismo que hace `dibujoDeChino` en la web.
 *
 * El `estado` solo lo entiende el orbe: la fruta no tiene cara de «escuchando»
 * ni de «pensando», y ponerle una inventada sería dibujar algo que no está en
 * ningún sitio.
 */
struct CNChinoVista: View {
    var animo: String = "feliz"
    var tam: CGFloat = 120
    var conSombra: Bool = true
    var ajustado: Bool = false
    var estado: String = ""

    var body: some View {
        if CNC.fmt.familia == "orbe" {
            CNOrbe(animo: animo, piel: CNC.fmt.pielChino, estado: estado,
                   tam: tam, ajustado: ajustado)
        } else {
            CNChino(animo: animo, tam: tam, conSombra: conSombra, ajustado: ajustado)
        }
    }
}

/**
 * EL ORBE ENTERO, PARA EL BANCO.
 *
 * Seis ánimos por tres pieles y los dos estados. Juntos y no sueltos: lo que
 * distingue una piel de otra es la diferencia entre ellas —la clara, la que
 * lleva tallo y hoja, y la negra con sus dos luces—, y eso en fotos sueltas no
 * se ve. Aquí no hay compilador ni simulador, y un dibujo no se comprueba con
 * una expresión regular.
 */
struct CNOrbeMuestra: View {
    var body: some View {
        let animos = ["feliz", "fiesta", "fuerte", "estudiosa", "rota", "jugo"]
        return ZStack {
            CNC.scr.ignoresSafeArea()
            VStack(spacing: 8) {
                Text("El orbe, dibujado en el teléfono")
                    .font(cnLetra(15, .heavy)).foregroundColor(CNC.ink)
                ForEach(CNCatalogos.ordenDePieles, id: \.self) { piel in
                    VStack(spacing: 1) {
                        HStack(spacing: 0) {
                            ForEach(animos, id: \.self) { a in
                                CNOrbe(animo: a, piel: piel, tam: 62)
                            }
                        }
                        Text(CNCatalogos.pielesDelOrbe[piel]?.nombre ?? piel)
                            .font(cnLetra(11)).foregroundColor(CNC.pmut)
                    }
                }
                // Los dos estados, que no dicen cómo va el mes sino qué pasa
                // ahora: van ENCIMA del ánimo y no borran su color.
                HStack(spacing: 10) {
                    CNOrbe(animo: "feliz", estado: "escuchando", tam: 76)
                    CNOrbe(animo: "rota", estado: "pensando", tam: 76)
                    CNOrbe(animo: "feliz", tam: 44, ajustado: true)
                    CNOrbe(animo: "fiesta", piel: "chinola", tam: 44, ajustado: true)
                }
                Text("escuchando · pensando sobre un mes en rojo · ajustado")
                    .font(cnLetra(11)).foregroundColor(CNC.pmut)
            }
            .padding(.top, 54)
            .frame(maxHeight: .infinity, alignment: .top)
        }
    }
}
