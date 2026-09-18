import SwiftUI

// Los 14 colores de cabecera con degradado (COLORES_CABECERA de src/movil/app.js),
// para que el selector nativo muestre los mismos que la app.
struct ColorCabecera: Identifiable {
    let id: String
    let nombre: String
    let a: UInt          // color inicial
    let b: UInt          // color final
    let sobreClaro: Bool // true → texto claro encima; false → texto oscuro

    var gradiente: LinearGradient {
        LinearGradient(colors: [Color(hex: a), Color(hex: b)],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

let COLORES_CABECERA: [ColorCabecera] = [
    .init(id: "chinola", nombre: "Chinola", a: 0xf7c948, b: 0x3f9d54, sobreClaro: false),
    .init(id: "mango", nombre: "Mango", a: 0xf9c04b, b: 0xef8a2c, sobreClaro: false),
    .init(id: "durazno", nombre: "Durazno", a: 0xf8b370, b: 0xf4845f, sobreClaro: false),
    .init(id: "lima", nombre: "Lima", a: 0xcfe95f, b: 0x85bb3e, sobreClaro: false),
    .init(id: "pino", nombre: "Pino", a: 0x33a565, b: 0x14683b, sobreClaro: true),
    .init(id: "bosque", nombre: "Bosque", a: 0x2c8f5a, b: 0x15412c, sobreClaro: true),
    .init(id: "oceano", nombre: "Oceano", a: 0x3f8ad0, b: 0x1f4f89, sobreClaro: true),
    .init(id: "medianoche", nombre: "Medianoche", a: 0x3d4f96, b: 0x1f2550, sobreClaro: true),
    .init(id: "ciruela", nombre: "Ciruela", a: 0x834fa6, b: 0x47256e, sobreClaro: true),
    .init(id: "uva", nombre: "Uva", a: 0x9a5cc7, b: 0x5c3096, sobreClaro: true),
    .init(id: "coral", nombre: "Coral", a: 0xea6a52, b: 0xc0343c, sobreClaro: true),
    .init(id: "cacao", nombre: "Cacao", a: 0x7d4b30, b: 0x472a1b, sobreClaro: true),
    .init(id: "carbon", nombre: "Carbon", a: 0x2a2e2b, b: 0x141714, sobreClaro: true),
    .init(id: "noche", nombre: "Noche", a: 0x27313b, b: 0x12181e, sobreClaro: true)
]
