import SwiftUI

// SwiftUI no entiende SVG, y los iconos del menú de Chinola son paths SVG
// (contorno, viewBox 24). Este intérprete mínimo dibuja esos mismos paths tal
// cual —M/L/H/V, y arcos circulares A— para que el nativo use los iconos
// exactos de la app, no aproximaciones con SF Symbols.
struct SVGShape: Shape {
    let d: String
    var viewBox: CGFloat = 24

    func path(in rect: CGRect) -> Path {
        let s = min(rect.width, rect.height) / viewBox
        let ox = rect.minX + (rect.width - viewBox * s) / 2
        let oy = rect.minY + (rect.height - viewBox * s) / 2
        var p = Path()
        var cur = CGPoint.zero
        var start = CGPoint.zero
        let pt = { (x: CGFloat, y: CGFloat) in CGPoint(x: ox + x * s, y: oy + y * s) }

        let toks = tokenize(d)
        var i = 0
        func num() -> CGFloat { let v = toks[i].num; i += 1; return v }
        while i < toks.count {
            let t = toks[i]
            guard t.isCmd else { i += 1; continue }
            let c = t.cmd; i += 1
            switch c {
            case "M", "m":
                var x = num(); var y = num()
                if c == "m" { x += cur.x; y += cur.y }
                cur = CGPoint(x: x, y: y); start = cur
                p.move(to: pt(cur.x, cur.y))
                // pares extra tras M se tratan como L
                while i < toks.count, !toks[i].isCmd {
                    var lx = num(); var ly = num()
                    if c == "m" { lx += cur.x; ly += cur.y }
                    cur = CGPoint(x: lx, y: ly); p.addLine(to: pt(cur.x, cur.y))
                }
            case "L", "l":
                while i < toks.count, !toks[i].isCmd {
                    var x = num(); var y = num()
                    if c == "l" { x += cur.x; y += cur.y }
                    cur = CGPoint(x: x, y: y); p.addLine(to: pt(cur.x, cur.y))
                }
            case "H", "h":
                while i < toks.count, !toks[i].isCmd {
                    var x = num(); if c == "h" { x += cur.x }
                    cur.x = x; p.addLine(to: pt(cur.x, cur.y))
                }
            case "V", "v":
                while i < toks.count, !toks[i].isCmd {
                    var y = num(); if c == "v" { y += cur.y }
                    cur.y = y; p.addLine(to: pt(cur.x, cur.y))
                }
            case "A", "a":
                while i < toks.count, !toks[i].isCmd {
                    let rx = num(); _ = num() /* ry */; _ = num() /* rot */
                    let large = num() != 0; let sweep = num() != 0
                    var x = num(); var y = num()
                    if c == "a" { x += cur.x; y += cur.y }
                    addArc(&p, from: cur, to: CGPoint(x: x, y: y), r: rx,
                           large: large, sweep: sweep, pt: pt)
                    cur = CGPoint(x: x, y: y)
                }
            case "Z", "z":
                p.addLine(to: pt(start.x, start.y)); cur = start
            default: break
            }
        }
        return p
    }

    // Arco circular (rx == ry): centro por los dos extremos y flags, aplanado en
    // segmentos. Alcanza para los iconos, cuyos arcos son todos circulares.
    private func addArc(_ p: inout Path, from a: CGPoint, to b: CGPoint, r: CGFloat,
                        large: Bool, sweep: Bool, pt: (CGFloat, CGFloat) -> CGPoint) {
        let d = hypot(b.x - a.x, b.y - a.y)
        if d < 0.0001 { return }
        let rr = max(r, d / 2)
        let mx = (a.x + b.x) / 2, my = (a.y + b.y) / 2
        let ux = -(b.y - a.y) / d, uy = (b.x - a.x) / d
        let h = (rr * rr - d * d / 4).squareRoot()
        let sign: CGFloat = (large == sweep) ? -1 : 1
        let cx = mx + sign * ux * h, cy = my + sign * uy * h
        let a1 = atan2(a.y - cy, a.x - cx)
        var a2 = atan2(b.y - cy, b.x - cx)
        if sweep { if a2 < a1 { a2 += 2 * .pi } } else { if a2 > a1 { a2 -= 2 * .pi } }
        let steps = max(2, Int(abs(a2 - a1) / (.pi / 24)))
        for k in 1...steps {
            let ang = a1 + (a2 - a1) * CGFloat(k) / CGFloat(steps)
            p.addLine(to: pt(cx + rr * cos(ang), cy + rr * sin(ang)))
        }
    }

    private struct Tok { var isCmd = false; var cmd: Character = " "; var num: CGFloat = 0 }

    private func tokenize(_ s: String) -> [Tok] {
        var out: [Tok] = []
        var numBuf = ""
        func flush() {
            if !numBuf.isEmpty { out.append(Tok(isCmd: false, cmd: " ", num: CGFloat(Double(numBuf) ?? 0))); numBuf = "" }
        }
        for ch in s {
            if ch.isLetter {
                flush(); out.append(Tok(isCmd: true, cmd: ch, num: 0))
            } else if ch == "-" {
                // signo: nuevo número salvo que sea exponente
                if !numBuf.isEmpty && (numBuf.last == "e" || numBuf.last == "E") { numBuf.append(ch) }
                else { flush(); numBuf.append(ch) }
            } else if ch == "." {
                if numBuf.contains(".") { flush() }
                numBuf.append(ch)
            } else if ch.isNumber || ch == "e" || ch == "E" {
                numBuf.append(ch)
            } else { // espacio o coma
                flush()
            }
        }
        flush()
        return out
    }
}

// Iconos del menú, con los paths exactos de ICONOS_TAB (src/movil/app.js).
enum TabIcono {
    static let resumen =
        "M5 3h3a2 2 0 0 1 2 2v3a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2z"
      + "M16 3h3a2 2 0 0 1 2 2v1a2 2 0 0 1-2 2h-3a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2z"
      + "M16 12h3a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-3a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2z"
      + "M5 14h3a2 2 0 0 1 2 2v3a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-3a2 2 0 0 1 2-2z"
    static let movs = "M7 4.5v15M7 19.5l-3-3M7 19.5l3-3M17 19.5v-15M17 4.5l-3 3M17 4.5l3 3"
    static let cuentas = "M7.5 5.5h9a4 4 0 0 1 4 4v5a4 4 0 0 1-4 4h-9a4 4 0 0 1-4-4v-5a4 4 0 0 1 4-4zM3.5 10h17M7 14.5h3.5"
    static let plan = "M12 3a9 9 0 1 0 0 18 9 9 0 0 0 0-18M12 3.4v7.6a1 1 0 0 0 1 1h7.6"
    static let perfil = "M12 11a4 4 0 1 0 0-8 4 4 0 0 0 0 8M4 21a8 8 0 0 1 16 0"
}

// El icono ya estilizado como en la app: contorno, grosor 2.3, tapas redondas.
struct IconoTab: View {
    let d: String
    var body: some View {
        SVGShape(d: d)
            .stroke(style: StrokeStyle(lineWidth: 2.3, lineCap: .round, lineJoin: .round))
            .frame(width: 24, height: 24)
    }
}
