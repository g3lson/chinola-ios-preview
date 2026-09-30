import Foundation
import Compression

/**
 * GZIP, PARA SUBIR LA LIBRETA SIN GASTARSE LOS DATOS.
 *
 * La sincronización manda la libreta ENTERA en cada guardado —así es como el
 * servidor sabe que no se perdió nada por el camino— y con años de movimientos
 * son megas por cada gasto anotado. La web lo comprime desde siempre; cuando la
 * sincronización pasó al teléfono, esa parte se quedaba atrás y anotar un café
 * con datos móviles subía medio mega.
 *
 * Foundation trae `Compression`, pero da DEFLATE a secas: sin la cabecera ni la
 * suma de comprobación que lleva un gzip de verdad. Eso es lo que se añade aquí,
 * que son diez bytes delante y ocho detrás. Si se mandara el deflate pelado con
 * la cabecera `content-encoding: gzip`, el servidor lo rechazaría —y sería un
 * fallo de los malos: solo aparece con libretas grandes, o sea con la gente que
 * más tiempo lleva usando la app—.
 */
enum CNGzip {

    /// La tabla del CRC-32, hecha una vez.
    private static let tabla: [UInt32] = (0..<256).map { i -> UInt32 in
        var c = UInt32(i)
        for _ in 0..<8 { c = (c & 1) != 0 ? (0xEDB8_8320 ^ (c >> 1)) : (c >> 1) }
        return c
    }

    /// El CRC-32 que gzip pone al final, sobre los bytes SIN comprimir.
    static func crc32(_ d: Data) -> UInt32 {
        var c: UInt32 = 0xFFFF_FFFF
        for b in d { c = tabla[Int((c ^ UInt32(b)) & 0xFF)] ^ (c >> 8) }
        return c ^ 0xFFFF_FFFF
    }

    /**
     * Los bytes en gzip, o `nil` si no se pudo.
     *
     * Devolver `nil` es una respuesta válida y quien llama la usa: manda el
     * cuerpo sin comprimir, que es más pesado pero correcto. Comprimir mal sería
     * peor que no comprimir.
     */
    static func comprime(_ datos: Data) -> Data? {
        guard !datos.isEmpty else { return nil }
        let destino = UnsafeMutablePointer<UInt8>.allocate(capacity: datos.count + 4096)
        defer { destino.deallocate() }
        let n = datos.withUnsafeBytes { origen -> Int in
            guard let base = origen.bindMemory(to: UInt8.self).baseAddress else { return 0 }
            return compression_encode_buffer(destino, datos.count + 4096,
                                             base, datos.count, nil, COMPRESSION_ZLIB)
        }
        guard n > 0 else { return nil }

        // La cabecera de gzip: marca, método DEFLATE, sin banderas, sin fecha,
        // y «sistema desconocido». Son siempre estos diez bytes.
        var fuera = Data([0x1F, 0x8B, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF])
        fuera.append(destino, count: n)
        // Y al final, el CRC y el tamaño original, los dos en little-endian.
        var suma = crc32(datos).littleEndian
        var largo = UInt32(truncatingIfNeeded: datos.count).littleEndian
        withUnsafeBytes(of: &suma) { fuera.append(contentsOf: $0) }
        withUnsafeBytes(of: &largo) { fuera.append(contentsOf: $0) }
        return fuera
    }
}
