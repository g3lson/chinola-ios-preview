import SwiftUI

/**
 * CHINO, DIBUJADO AQUÍ.
 *
 * Era lo último que no se podía traer. El personaje lo genera la web con un
 * guion que escribe un SVG, y el teléfono lo recibía ya convertido en imagen
 * por el puente. De ahí colgaban SEIS sitios —su mascota, su cara en la charla,
 * la bienvenida, el aviso del plan, los avisos del servidor y la subpantalla
 * del personaje—, todos esperando a que la web arrancara, dibujara y mandara un
 * PNG.
 *
 * Se dibuja con las mismas medidas, y el lienzo es el mismo: 120×120. Todo va
 * en esas coordenadas, así que los números son los mismos a los dos lados y se
 * pueden comparar uno a uno con `src/chinolo.js`. Lo que distingue a un ánimo
 * de otro —treinta y seis números— lo genera `npm run sync` de allí: escritos
 * dos veces se separan en cuanto alguien afine uno.
 *
 * LO QUE HACE QUE SEA UN PERSONAJE Y NO UN CÍRCULO CON DOS PUNTOS, que es
 * exactamente lo que se pierde al rehacerlo de memoria:
 *
 *  · **dos luces en el cuerpo**, una elipse girada y un punto al lado. Dos se
 *    leen como algo redondo; una sola, como una mancha;
 *  · **el reflejo del ojo**, que es lo que lo hace estar vivo;
 *  · **el rubor**, con su opacidad por ánimo;
 *  · **la sombra en el suelo**, que dice a qué altura está. Sin ella el dibujo
 *    flota en la nada.
 *
 * Y LA CARA ES LO ÚNICO QUE CAMBIA: el cuerpo es el mismo en los seis. Por eso
 * se distinguen por las cejas, la boca y cuánto se abre el ojo, y no por
 * colores distintos.
 *
 * La VIDA —parpadear, respirar, ladearse— se queda fuera a propósito: la del
 * SVG son animaciones CSS dentro del propio archivo, y aquí se haría con el
 * reloj de SwiftUI. Es otro trabajo y va aparte; esto es el dibujo.
 */
struct CNChino: View {
    /// feliz · fiesta · fuerte · estudiosa · rota · jugo
    var animo: String = "feliz"
    /// A qué tamaño sale. Dentro siempre se dibuja a 120 y se escala al final:
    /// así los grosores de los trazos se escalan con el dibujo y no hay que
    /// multiplicar cada uno a mano.
    var tam: CGFloat = 120
    /// La sombra del suelo. Fuera donde el dibujo va dentro de algo redondo
    /// —su cara en la charla—: ahí una sombra ovalada se ve como una mancha
    /// pegada al borde.
    var conSombra: Bool = true
    /// Recorta el aire de alrededor. El dibujo deja sitio para las chispas, los
    /// galones y el brinco, y en un icono ese aire lo hace verse más pequeño
    /// que los iconos de al lado, que sí llegan a sus bordes.
    var ajustado: Bool = false

    /// El lienzo, que es el de la web.
    private static let lienzo: CGFloat = 120

    /// Lo que distingue a este ánimo. Si no existe, el de todos los días: mejor
    /// una cara conocida que ninguna.
    private var cara: (id: String, conCeja: Bool, cejaIzq: Double, cejaDer: Double,
                       cejaY: Double, ojo: Double, boca: String, rubor: Double, extras: [String]) {
        let tabla = CNCatalogos.animosDeChino
        return tabla.first { $0.id == animo } ?? tabla[0]
    }

    var body: some View {
        dibujo
            .frame(width: Self.lienzo, height: Self.lienzo)
            // EL RECORTE: la caja del dibujo ajustado es «14 8 92 104», y su
            // centro —(60, 60)— es el mismo centro del lienzo. Por eso basta
            // con agrandarlo desde el centro; y manda el LADO LARGO (104), como
            // en el SVG, que si no la fruta sale estirada.
            .scaleEffect(ajustado ? Self.lienzo / 104 : 1)
            .frame(width: Self.lienzo, height: Self.lienzo)
            .clipped()
            .scaleEffect(tam / Self.lienzo)
            .frame(width: tam, height: tam)
    }

    private var dibujo: some View {
        ZStack {
            if conSombra { suelo }
            cuerpo
            if cara.conCeja { cejas }
            ojo(42); ojo(78)
            boca
            // Las gafas van DENTRO del cuerpo —se las pone en la cara—, y las
            // demás alrededor. En el SVG es el mismo orden.
            if cara.extras.contains("gafas") { gafas }
            extras
        }
        .frame(width: Self.lienzo, height: Self.lienzo)
    }

    // MARK: - Las piezas

    private var suelo: some View {
        Ellipse()
            .fill(RadialGradient(colors: [Color.black.opacity(0.22), Color.black.opacity(0)],
                                 center: .center, startRadius: 0, endRadius: 30))
            .frame(width: 60, height: 14)
            .position(x: 60, y: 110)
    }

    private var cuerpo: some View {
        ZStack {
            // El tallo y la hoja, DETRÁS del cuerpo para que la fruta los tape
            // por abajo.
            trazo("M60 27c-1-6 1-11 4-14")
                .stroke(cnColor(hexString: "#5b4420"), style: StrokeStyle(lineWidth: 4.6, lineCap: .round))
            trazo("M64 20c9-9 21-9 26-4-3 10-15 15-26 4z")
                .fill(LinearGradient(colors: [cnColor(hexString: "#1e6d3a"), cnColor(hexString: "#39a15a")],
                                     startPoint: .bottomLeading, endPoint: .topTrailing))
            trazo("M67 18c7-3 14-3 19 0")
                .stroke(cnColor(hexString: "#0f5c30").opacity(0.55),
                        style: StrokeStyle(lineWidth: 1.6, lineCap: .round))
            // El halo: el mismo amarillo muy apagado, que separa la fruta del
            // fondo sin dibujarle un borde.
            Circle()
                .fill(RadialGradient(stops: [.init(color: cnColor(hexString: "#f3d054").opacity(0.30), location: 0.62),
                                             .init(color: cnColor(hexString: "#f3d054").opacity(0), location: 1)],
                                     center: .center, startRadius: 0, endRadius: 56))
                .frame(width: 112, height: 112)
                .position(x: 60, y: 66)
            // EL CUERPO, con la luz arriba a la izquierda, como una fruta de
            // verdad. Es el amarillo de la marca y no un naranja: con el naranja
            // competía con el rojo de los gastos.
            Circle()
                .fill(RadialGradient(stops: [.init(color: cnColor(hexString: "#fdeeae"), location: 0),
                                             .init(color: cnColor(hexString: "#f3d054"), location: 0.45),
                                             .init(color: cnColor(hexString: "#e5b435"), location: 0.82),
                                             .init(color: cnColor(hexString: "#c99220"), location: 1)],
                                     center: UnitPoint(x: 0.34, y: 0.26),
                                     startRadius: 0, endRadius: 64))
                .frame(width: 82, height: 82)
                .position(x: 60, y: 66)
            // LAS DOS LUCES. Dos se leen como algo redondo; una sola, como una
            // mancha.
            Ellipse().fill(Color.white.opacity(0.42))
                .frame(width: 26, height: 16)
                .rotationEffect(.degrees(-32))
                .position(x: 42, y: 43)
            Circle().fill(Color.white.opacity(0.5))
                .frame(width: 5.2, height: 5.2)
                .position(x: 55, y: 35)
            // El rubor, con su opacidad por ánimo.
            mejilla(33); mejilla(87)
        }
        .frame(width: Self.lienzo, height: Self.lienzo)
    }

    private func mejilla(_ x: CGFloat) -> some View {
        Ellipse().fill(cnColor(hexString: "#ef8878").opacity(cara.rubor))
            .frame(width: 20, height: 12.8)
            .position(x: x, y: 73)
    }

    /// Las cejas, cada una girada sobre SU punto: la izquierda sobre (39.5, cy)
    /// y la derecha sobre (80.5, cy). Girarlas sobre el centro del lienzo las
    /// pondría en la frente.
    private var cejas: some View {
        let cy = 47 + cara.cejaY
        let tinta = cnColor(hexString: "#2f2718")
        let grosor = StrokeStyle(lineWidth: 4, lineCap: .round)
        // Los dos puntos de giro, con su tipo escrito: dentro de la expresión
        // entera, una cuenta que mezcla Double y CGFloat es de las que hacen
        // que Swift se rinda sin compilar nada.
        let alto = CGFloat(cy) / Self.lienzo
        let porIzq = UnitPoint(x: 39.5 / Self.lienzo, y: alto)
        let porDer = UnitPoint(x: 80.5 / Self.lienzo, y: alto)
        return ZStack {
            trazo("M33 \(numero(cy))q6 -4 13 -1")
                .stroke(tinta, style: grosor)
                .rotationEffect(.degrees(cara.cejaIzq), anchor: porIzq)
            trazo("M74 \(numero(cy))q6 -3 13 1")
                .stroke(tinta, style: grosor)
                .rotationEffect(.degrees(cara.cejaDer), anchor: porDer)
        }
        .frame(width: Self.lienzo, height: Self.lienzo)
    }

    /**
     * UN OJO CON SU REFLEJO. El punto de luz es lo que lo hace estar vivo.
     *
     * Aquí el ojo entero ES la pupila —no hay blanco—, y lo que cambia con el
     * ánimo es cuánto se abre: entornado de gusto en la fiesta, casi cerrado en
     * el relajado, abierto del todo en el de todos los días.
     */
    private func ojo(_ x: Double) -> some View {
        let abre = cara.ojo
        let alto = 12.6 * abre
        let brillo = 3 * min(1, abre + 0.35)
        return ZStack {
            Ellipse().fill(cnColor(hexString: "#231a0e"))
                .frame(width: 15.2, height: CGFloat(alto) * 2)
                .position(x: CGFloat(x), y: 60)
            Circle().fill(Color.white.opacity(0.95))
                .frame(width: CGFloat(brillo) * 2, height: CGFloat(brillo) * 2)
                .position(x: CGFloat(x + 2.6), y: CGFloat(60 - 4 * abre))
            Circle().fill(Color.white.opacity(0.6))
                .frame(width: 2.7, height: 2.7)
                .position(x: CGFloat(x - 2.8), y: CGFloat(60 + 3.4 * abre))
        }
        .frame(width: Self.lienzo, height: Self.lienzo)
    }

    @ViewBuilder private var boca: some View {
        if cara.boca == "risa" {
            // La risa es la única RELLENA: la boca abierta y la lengua dentro.
            ZStack {
                ForEach(Array(CNCatalogos.risaDeChino.enumerated()), id: \.offset) { _, r in
                    trazo(r.d).fill(cnColor(hexString: r.color))
                }
            }
            .frame(width: Self.lienzo, height: Self.lienzo)
        } else if let b = CNCatalogos.bocasDeChino[cara.boca] ?? CNCatalogos.bocasDeChino["sonrisa"] {
            trazo(b.d)
                .stroke(cnColor(hexString: b.color),
                        style: StrokeStyle(lineWidth: CGFloat(b.grosor), lineCap: .round))
                .frame(width: Self.lienzo, height: Self.lienzo)
        }
    }

    /// Dos cristales redondeados con su puente. Van en la cara, encima del ojo:
    /// el relleno es casi transparente para que el ojo se siga viendo dentro.
    private var gafas: some View {
        let tinta = cnColor(hexString: "#2f2718")
        return ZStack {
            cristal(42, tinta); cristal(78, tinta)
            trazo("M54 59h12").stroke(tinta, lineWidth: 3)
        }
        .frame(width: Self.lienzo, height: Self.lienzo)
    }

    private func cristal(_ x: CGFloat, _ tinta: Color) -> some View {
        RoundedRectangle(cornerRadius: 9, style: .continuous)
            .fill(Color.white.opacity(0.22))
            .overlay(RoundedRectangle(cornerRadius: 9, style: .continuous).stroke(tinta, lineWidth: 3))
            .frame(width: 24, height: 20)
            .position(x: x, y: 60)
    }

    @ViewBuilder private var extras: some View {
        ZStack {
            if cara.extras.contains("chispas") {
                // Con el COLOR PUESTO y no con un `fill` al grupo: en el SVG el
                // color va en el `<g>` y los trazos lo heredan, y en SwiftUI un
                // apilado no se puede rellenar —no compila—. Una forma sin
                // rellenar usa el color de delante, así que se pone ahí.
                ZStack {
                    trazo("M18 26l2.1 5.4 5.4 2.1-5.4 2.1L18 41l-2.1-5.4L10.5 33.5l5.4-2.1z")
                    trazo("M101 34l1.7 4.3 4.3 1.7-4.3 1.7-1.7 4.3-1.7-4.3-4.3-1.7 4.3-1.7z")
                    trazo("M96 16l1.3 3.3 3.3 1.3-3.3 1.3-1.3 3.3-1.3-3.3-3.3-1.3 3.3-1.3z")
                }.foregroundColor(cnColor(hexString: "#ffd84d"))
            }
            if cara.extras.contains("subida") {
                // Dos galones subiendo por detrás: no hay que sostenerlos, son
                // el movimiento de ir para arriba. Llevaba unas pesas, y una
                // chinola no tiene brazos: nadie las sostenía y se leían como
                // dos objetos pegados al dibujo. Verdes, que aquí el verde ya
                // quiere decir que vas bien.
                // Cada uno con SU trazo: a un apilado no se le puede poner un
                // borde, y el `<g stroke=…>` del SVG no tiene equivalente.
                let verde = cnColor(hexString: "#2f9a54")
                let pluma = StrokeStyle(lineWidth: 5, lineCap: .round)
                ZStack {
                    trazo("M96 62l9-9 9 9").stroke(verde, style: pluma)
                    trazo("M98 78l7-7 7 7").stroke(verde, style: pluma)
                }
            }
            if cara.extras.contains("sudor") {
                // La gota de la sien: punta arriba, panza abajo, con su brillo.
                // Va en el BORDE de la cara, que es donde se lee como sudor y
                // no como una lágrima.
                ZStack {
                    trazo("M95 40c4 5 6 8 6 10.6a6 6 0 0 1-12 0c0-2.6 2-5.6 6-10.6z")
                        .fill(cnColor(hexString: "#7fc6e8"))
                    Ellipse().fill(Color.white.opacity(0.65))
                        .frame(width: 3.2, height: 4.8)
                        .position(x: 93, y: 49)
                }
            }
            if cara.extras.contains("burbujas") {
                // A los lados: el cuerpo llega hasta x=101, así que dentro de
                // ese ancho quedaban tapadas.
                ZStack {
                    burbuja(8, 13, 84); burbuja(6, 107, 78); burbuja(4.4, 110, 94)
                }.foregroundColor(cnColor(hexString: "#7fd3a8").opacity(0.75))
            }
        }
        .frame(width: Self.lienzo, height: Self.lienzo)
    }

    private func burbuja(_ d: CGFloat, _ x: CGFloat, _ y: CGFloat) -> some View {
        Circle().frame(width: d, height: d).position(x: x, y: y)
    }

    /// Un trazo del dibujo, leído en el lienzo de 120. El intérprete de trazos
    /// viene con 24 puesto —el de los iconos—, y con ese todo el personaje
    /// saldría cinco veces más grande y fuera de la pantalla.
    private func trazo(_ d: String) -> CNSVGShape { CNSVGShape(d: d, viewBox: Self.lienzo) }

    /// Un número dentro de un trazo, sin el «.0» de más: «47» y no «47.0», que
    /// el lector de trazos separa los números por el punto y leería dos.
    private func numero(_ v: Double) -> String {
        v == v.rounded() ? String(Int(v)) : String(format: "%.1f", v)
    }
}

/**
 * LOS SEIS, UNO AL LADO DEL OTRO.
 *
 * Es para el BANCO: aquí no hay compilador de Swift ni simulador, y un dibujo
 * no se comprueba con una expresión regular. Las pruebas de `npm test` miran
 * que los trazos y los números sean los mismos que los de la web; que la cara
 * se vea como una cara solo lo dice una foto.
 *
 * Los seis juntos y no uno: lo que distingue un ánimo de otro es la diferencia
 * entre ellos, y eso en seis fotos sueltas no se ve.
 */
struct CNChinoMuestra: View {
    var body: some View {
        let seis = CNCatalogos.animosDeChino
        return ZStack {
            CNC.scr.ignoresSafeArea()
            VStack(spacing: 10) {
                Text("Chino, dibujado en el teléfono")
                    .font(cnLetra(15, .heavy)).foregroundColor(CNC.ink)
                // Por su SITIO en la lista y no recorriendo tuplas: una tupla
                // no es `Identifiable` y un `ForEach` sobre un trozo de lista
                // de tuplas es justo la clase de expresión con la que Swift se
                // rinde sin compilar nada.
                ForEach(0..<2, id: \.self) { f in
                    HStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { c in
                            let i = f * 3 + c
                            if i < seis.count {
                                VStack(spacing: 2) {
                                    CNChino(animo: seis[i].id, tam: 108)
                                    Text(seis[i].id).font(cnLetra(11)).foregroundColor(CNC.pmut)
                                }
                            }
                        }
                    }
                }
                // Y el RECORTADO, que es el que va en la barra de pestañas: con
                // el aire quitado y pequeño, que es donde se ve si el recorte
                // le come la hoja.
                HStack(spacing: 14) {
                    CNChino(animo: "feliz", tam: 40, conSombra: false, ajustado: true)
                    CNChino(animo: "fiesta", tam: 40, conSombra: false, ajustado: true)
                    CNChino(animo: "feliz", tam: 88, conSombra: false, ajustado: true)
                }
                Text("ajustado · sin sombra").font(cnLetra(11)).foregroundColor(CNC.pmut)
            }
            .padding(.top, 54)
            .frame(maxHeight: .infinity, alignment: .top)
        }
    }
}
