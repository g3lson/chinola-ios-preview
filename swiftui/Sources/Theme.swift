import SwiftUI

// Tema «Chinola» (claro), calcado del que trae la app por defecto. Los valores
// vienen de TEMAS.chinola en el diseño (oklch convertido a sRGB), para que el
// nativo se vea igual que el web sin rediseñar nada.
extension Color {
    init(hex: UInt) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xff) / 255,
                  green: Double((hex >> 8) & 0xff) / 255,
                  blue: Double(hex & 0xff) / 255,
                  opacity: 1)
    }

    static let scr   = Color(hex: 0xfaf7ec)  // fondo de pantalla (crema)
    static let card  = Color(hex: 0xffffff)  // tarjetas
    static let soft  = Color(hex: 0xf9f5e6)  // relleno suave (botón secundario)
    static let line  = Color(hex: 0xe5e1d3)  // bordes
    static let ink   = Color(hex: 0x132419)  // texto principal (verde tinta)
    static let pmut  = Color(hex: 0x516356)  // texto secundario
    static let side  = Color(hex: 0x093a20)  // banda de la cabecera (verde oscuro)
    static let acc   = Color(hex: 0xefcb4c)  // acento chinola (amarillo)
    static let pos   = Color(hex: 0x137d41)  // ingreso
    static let neg   = Color(hex: 0xd55948)  // gasto
    static let sav   = Color(hex: 0x825eb9)  // ahorro
    static let info  = Color(hex: 0x398ad6)  // categoría azul
}
