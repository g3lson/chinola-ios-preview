import SwiftUI

// Colores de Chinola (tema oscuro), a juego con la app web.
extension Color {
    init(hex: UInt) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xff) / 255,
                  green: Double((hex >> 8) & 0xff) / 255,
                  blue: Double(hex & 0xff) / 255,
                  opacity: 1)
    }

    static let scr   = Color(hex: 0x0c0e0c)  // fondo pantalla
    static let card  = Color(hex: 0x181c18)  // tarjetas
    static let line  = Color(hex: 0x262b25)  // bordes
    static let ink   = Color(hex: 0xeef0e8)  // texto
    static let pmut  = Color(hex: 0x8a9284)  // texto secundario
    static let acc   = Color(hex: 0xe9c24a)  // acento chinola
    static let pos   = Color(hex: 0x57b06e)  // ingreso
    static let neg   = Color(hex: 0xdd6b50)  // gasto
    static let sav   = Color(hex: 0x9d8ae6)  // ahorro
    static let info  = Color(hex: 0x5f92db)  // categoría azul
    static let navbg = Color(hex: 0x0f130f)  // barra inferior
}

// Degradado de la cabecera (el "Chinola").
extension LinearGradient {
    static let chinola = LinearGradient(
        colors: [Color(hex: 0xf7c948), Color(hex: 0xec9a2e), Color(hex: 0x3f9d54)],
        startPoint: .topLeading, endPoint: .bottomTrailing)
}
