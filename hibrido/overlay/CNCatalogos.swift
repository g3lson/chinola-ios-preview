// GENERADO por `npm run sync` desde la web — no editar a mano.
//
// Lo que tiene que existir en la web Y en el teléfono no se escribe dos
// veces: se escribe una y se genera la otra. Estos glifos estaban copiados
// a mano en Swift y uno ya se había desviado —`banco` dibujaba una casa en
// el teléfono y un banco en la web—, que es la clase de fallo que no se
// encuentra buscándola: son ochenta y cinco cadenas de texto y la que se
// desvíe solo hace que un iconito sea otro.

import Foundation

enum CNCatalogos {

    /// El trazo de cada glifo, por su nombre. Los mismos que la web.
    static let iconos: [String: String] = [
        "banco": "M12 3l9 5H3zM5 11v7M9.5 11v7M14.5 11v7M19 11v7M3 21h18",
        "billete": "M2 6h20v12H2zM12 9.4a2.6 2.6 0 1 0 0 5.2 2.6 2.6 0 0 0 0-5.2M5.5 9.5h0M18.5 14.5h0",
        "casa": "M3 11l9-7 9 7v9a1 1 0 0 1-1 1h-5v-6H9v6H4a1 1 0 0 1-1-1z",
        "carrito": "M3 4h2l2 11h12M7 8h14l-2 7H8M8 19a1 1 0 1 0 2 0 1 1 0 1 0-2 0M16 19a1 1 0 1 0 2 0 1 1 0 1 0-2 0",
        "comida": "M6 3v8a3 3 0 0 0 6 0V3M9 11v10M17 3c-2 2-2 6 0 8v10",
        "cafe": "M4 8h13v5a4 4 0 0 1-4 4H8a4 4 0 0 1-4-4zM17 9h2a2 2 0 0 1 0 4h-2M4 21h13",
        "rayo": "M13 2 4 14h6l-1 8 9-12h-6z",
        "wifi": "M4 8a14 14 0 0 1 16 0M7 12a9 9 0 0 1 10 0M10 16a4 4 0 0 1 4 0M12 20h.01",
        "auto": "M4 16v-4l2-5h12l2 5v4M4 16h16M7 19a1 1 0 1 0 2 0M15 19a1 1 0 1 0 2 0",
        "gasolina": "M5 21V5a2 2 0 0 1 2-2h5v18M5 12h7M14 8h3a2 2 0 0 1 2 2v7a2 2 0 0 0 2 2",
        "birrete": "M2 9l10-4 10 4-10 4zM6 11v5c0 2 3 3 6 3s6-1 6-3v-5",
        "libro": "M4 5h7v14H4zM13 5h7v14h-7z",
        "salud": "M12 7v10M7 12h10M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18",
        "iglesia": "M12 3v6M9 6h6M6 21V11l6-4 6 4v10z",
        "regalo": "M3 9h18v3H3zM4 12v9h16v-9M12 9v12M8 9a2 2 0 1 1 4-2 2 2 0 1 1 4 2",
        "cine": "M3 6h18v10H3zM8 20h8M8 6v10M16 6v10",
        "musica": "M9 18V6l10-2v12M9 18a3 3 0 1 1-3-3 3 3 0 0 1 3 3M19 16a2 2 0 1 1-2-2 2 2 0 0 1 2 2",
        "tarjeta": "M2 6h20v12H2zM2 10h20M6 15h4",
        "usuario": "M12 11a4 4 0 1 0 0-8 4 4 0 0 0 0 8M4 21a8 8 0 0 1 16 0",
        "familia": "M8 10a3 3 0 1 0 0-6 3 3 0 0 0 0 6M17 11a2.5 2.5 0 1 0 0-5 2.5 2.5 0 0 0 0 5M2 20a6 6 0 0 1 12 0M15 20a5 5 0 0 1 7-4",
        "hucha": "M4 13a6 6 0 0 1 6-6h4a6 6 0 0 1 6 6v3H4zM7 18v2M17 18v2M16 11h1",
        "grafico": "M4 20V10M10 20V4M16 20v-7M22 20H2",
        "maleta": "M4 8h16v12H4zM9 8V5h6v3M4 14h16",
        "avion": "M2 13l20-6-8 14-2-5z",
        "mascota": "M6 9a2 2 0 1 0 0-4 2 2 0 0 0 0 4M18 9a2 2 0 1 0 0-4 2 2 0 0 0 0 4M9 20a3 3 0 0 1-3-3c0-2 2-3 3-5h6c1 2 3 3 3 5a3 3 0 0 1-3 3z",
        "ropa": "M9 4l3 2 3-2 5 4-3 3v9H7v-9L4 8z",
        "gym": "M4 9v6M20 9v6M7 7v10M17 7v10M7 12h10",
        "herramienta": "M14 4a4 4 0 0 1 6 6l-9 9-4 1 1-4z",
        "telefono": "M7 3h10v18H7zM10 19h4",
        "puntos": "M6 12h.01M12 12h.01M18 12h.01",
        "alquiler": "M4 21V9l8-6 8 6v12M9 21v-6h6v6M14 12h.01",
        "llave": "M14 7a4 4 0 1 1-3.5 5.9L4 19v-3h3v-3h3l.5-1A4 4 0 0 1 14 7",
        "sofa": "M4 11V8a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v3M2 12a2 2 0 0 1 4 0v5h12v-5a2 2 0 0 1 4 0v7H2z",
        "bombilla": "M9 18h6M10 21h4M12 3a6 6 0 0 1 4 10.5V17H8v-3.5A6 6 0 0 1 12 3",
        "agua": "M12 3s6 6.5 6 11a6 6 0 0 1-12 0c0-4.5 6-11 6-11",
        "basura": "M4 7h16M9 7V4h6v3M6 7l1 14h10l1-14M10 11v6M14 11v6",
        "bus": "M4 6h16v9H4zM4 15v3h2v-3M18 15v3h2v-3M7 9h10M6 19a1 1 0 1 0 2 0M16 19a1 1 0 1 0 2 0",
        "taxi": "M5 16v-4l2-5h10l2 5v4M5 16h14M9 7V5h6v2M7 19a1 1 0 1 0 2 0M15 19a1 1 0 1 0 2 0",
        "moto": "M5 18a3 3 0 1 0 0-6 3 3 0 0 0 0 6M19 18a3 3 0 1 0 0-6 3 3 0 0 0 0 6M8 15h5l3-6h2M11 9h4",
        "bici": "M6 19a3 3 0 1 0 0-6 3 3 0 0 0 0 6M18 19a3 3 0 1 0 0-6 3 3 0 0 0 0 6M9 16l3-8h3M8 8h4",
        "parking": "M8 18V6h4a3 3 0 0 1 0 6H8M4 3h16v18H4z",
        "taller": "M3 18h18M6 18V9l6-4 6 4v9M9 18v-4h6v4",
        "peaje": "M5 20V8h6v12M13 20V4h6v16M8 12h.01M16 8h.01",
        "supermercado": "M3 9l2-5h14l2 5M3 9h18v11H3zM9 13h6",
        "panaderia": "M4 12a5 5 0 0 1 5-5h6a5 5 0 0 1 0 10H9a5 5 0 0 1-5-5M9 9v6M13 9v6",
        "restaurante": "M4 4v6a3 3 0 0 0 6 0V4M7 10v10M14 4h5a1 1 0 0 1 1 1v6h-6z",
        "pizza": "M12 3 4 20l16-5zM11 11h.01M13 15h.01",
        "bebida": "M6 4h12l-2 6H8zM8 10l1 10h6l1-10M10 14h4",
        "farmacia": "M12 6v12M6 12h12M6 6h12v12H6z",
        "medico": "M8 3h8v4h4v10H4V7h4zM12 10v4M10 12h4",
        "dentista": "M8 3c2 0 2 2 4 2s2-2 4-2 3 3 2 8c-1 4-2 8-3 8s-1-4-3-4-2 4-3 4-2-4-3-8C5 6 6 3 8 3",
        "gafas": "M6 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6M18 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6M9 12h6",
        "peluqueria": "M6 4l12 12M18 4 6 16M6 20a2 2 0 1 0 0-4 2 2 0 0 0 0 4M18 20a2 2 0 1 0 0-4 2 2 0 0 0 0 4",
        "cuna": "M4 10v9M20 10v9M4 14h16M6 10a6 6 0 0 1 12 0",
        "colegio": "M12 3l8 4v3H4V7zM6 10v11M18 10v11M10 21v-6h4v6",
        "laptop": "M4 6h16v9H4zM2 18h20M9 18h6",
        "suscripcion": "M4 6h16v12H4zM8 10h8M8 14h5M17 14h.01",
        "juego": "M7 12h4M9 10v4M15 12h.01M17 14h.01M4 8h16v8H4z",
        "deporte": "M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18M12 3v18M3 12h18",
        "playa": "M12 12a7 7 0 0 1 10-4c-2 5-6 5-10 4M12 12v9M4 21h16",
        "hotel": "M4 20V6h16v14M8 10h.01M8 14h.01M12 10h.01M12 14h.01M16 10h.01M16 14h.01",
        "concierto": "M4 20V10l7-5v15M11 12h9v8M15 16h.01",
        "iglesia2": "M12 2v5M9 5h6M5 21V10l7-4 7 4v11M10 21v-6h4v6",
        "mano": "M8 12V5a2 2 0 0 1 4 0v6M12 11V4a2 2 0 0 1 4 0v8M16 9a2 2 0 0 1 4 0v6a6 6 0 0 1-6 6H10a6 6 0 0 1-6-6v-3a2 2 0 0 1 4 0",
        "impuesto": "M6 3h12v18H6zM9 8h6M9 12h6M9 16h3",
        "seguro": "M12 3l8 3v6c0 5-4 8-8 9-4-1-8-4-8-9V6z M9 12l2 2 4-4",
        "nomina": "M4 5h16v14H4zM8 9h8M8 13h5M15 15a2 2 0 1 0 4 0 2 2 0 0 0-4 0",
        "propina": "M12 3v18M8 7h6a3 3 0 0 1 0 6h-4a3 3 0 0 0 0 6h6",
        "bolsa": "M6 8h12l-1 12H7zM9 8V5a3 3 0 0 1 6 0v3",
        "camion": "M3 7h11v9H3zM14 11h4l3 3v2h-7M6 19a1 1 0 1 0 2 0M16 19a1 1 0 1 0 2 0",
        "caja": "M4 8l8-4 8 4v9l-8 4-8-4zM4 8l8 4 8-4M12 12v9",
        "factura": "M6 3h12v18l-3-2-3 2-3-2-3 2zM9 8h6M9 12h6",
        "reloj": "M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18M12 7v5l4 2",
        "estrella": "M12 3l3 6 6 1-4.5 4.5L18 21l-6-3-6 3 1.5-6.5L3 10l6-1z",
        "corazon": "M12 20s-8-4.5-8-10a4.5 4.5 0 0 1 8-3 4.5 4.5 0 0 1 8 3c0 5.5-8 10-8 10",
        "planta": "M12 21V9M12 9C9 9 7 7 7 4c3 0 5 2 5 5M12 9c3 0 5-2 5-5-3 0-5 2-5 5M6 21h12",
        "limpieza": "M6 21h12l-1-9H7zM9 12V4h6v8M12 15v3",
        "mudanza": "M3 17h18M5 17V9l7-5 7 5v8M10 17v-5h4v5",
        "perro": "M5 11l2-5 3 2h4l3-2 2 5v6a3 3 0 0 1-3 3H8a3 3 0 0 1-3-3zM9 13h.01M15 13h.01M11 16h2",
        "gato": "M5 20V9l3-5 2 3h4l2-3 3 5v11zM9 13h.01M15 13h.01M10 16h4",
        "libro2": "M4 6a4 4 0 0 1 8 0 4 4 0 0 1 8 0v12a4 4 0 0 0-8 0 4 4 0 0 0-8 0z",
        "premio": "M8 3h8v6a4 4 0 0 1-8 0zM12 13v5M9 21h6M5 5H3v2a4 4 0 0 0 4 4M19 5h2v2a4 4 0 0 1-4 4",
        "moneda": "M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18M12 7v10M9.5 9.5h5M9.5 14.5h5",
        "cripto": "M9 4v16M7 8h5a2 2 0 0 1 0 4H7h5a2 2 0 0 1 0 4H7M12 4v2M12 18v2",
        "candado": "M6 11h12v10H6zM9 11V8a3 3 0 0 1 6 0v3M12 15v3",
        "paypal": "M7 18V3h4.5a4.5 4.5 0 0 1 0 9H7M13 21V6h2.5a4.5 4.5 0 0 1 0 9H13",
        "billetera": "M3 8h16a1 1 0 0 1 1 1v8a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2zM3 8V6a2 2 0 0 1 2-2h11v4M15 13.5h3",
        "transferencia": "M4 9h13M14 6l3 3-3 3M20 15H7M10 12l-3 3 3 3",
        "qr": "M4 4h6v6H4zM14 4h6v6h-6zM4 14h6v6H4zM14.5 14.5h2v2h-2zM18 18h2v2h-2zM14 20h2M18 14h2",
        "contactless": "M5 9a5 5 0 0 1 0 6M9 6.5a9 9 0 0 1 0 11M13 4a13 13 0 0 1 0 16",
        "cajero": "M5 3h14a1 1 0 0 1 1 1v16a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1V4a1 1 0 0 1 1-1zM7 6.5h10v5H7zM8.5 15h7M9.5 18h5",
        "cheque": "M3 6h18v12H3zM6.5 14.5c1.2-2 2.4-2 3.2 0 .8 2 2 2 3.2 0M6.5 10h6M16 10h2M16 14.5h2",
        "remesa": "M3 8h12v8H3zM9 12h.01M17 4h4v4M21 4l-5 5M6 20h10"
    ]

    /**
     * Y EN QUÉ ORDEN SE ENSEÑAN, que un diccionario no lo guarda.
     *
     * La rejilla de «elige un icono» los enseña en el orden del
     * catálogo, que es el que los agrupa por familias —casa, comida,
     * transporte—. Recorriendo el diccionario salen en un orden
     * distinto cada vez que se abre la hoja.
     */
    static let ordenDeIconos: [String] = [
        "banco",
        "billete",
        "casa",
        "carrito",
        "comida",
        "cafe",
        "rayo",
        "wifi",
        "auto",
        "gasolina",
        "birrete",
        "libro",
        "salud",
        "iglesia",
        "regalo",
        "cine",
        "musica",
        "tarjeta",
        "usuario",
        "familia",
        "hucha",
        "grafico",
        "maleta",
        "avion",
        "mascota",
        "ropa",
        "gym",
        "herramienta",
        "telefono",
        "puntos",
        "alquiler",
        "llave",
        "sofa",
        "bombilla",
        "agua",
        "basura",
        "bus",
        "taxi",
        "moto",
        "bici",
        "parking",
        "taller",
        "peaje",
        "supermercado",
        "panaderia",
        "restaurante",
        "pizza",
        "bebida",
        "farmacia",
        "medico",
        "dentista",
        "gafas",
        "peluqueria",
        "cuna",
        "colegio",
        "laptop",
        "suscripcion",
        "juego",
        "deporte",
        "playa",
        "hotel",
        "concierto",
        "iglesia2",
        "mano",
        "impuesto",
        "seguro",
        "nomina",
        "propina",
        "bolsa",
        "camion",
        "caja",
        "factura",
        "reloj",
        "estrella",
        "corazon",
        "planta",
        "limpieza",
        "mudanza",
        "perro",
        "gato",
        "libro2",
        "premio",
        "moneda",
        "cripto",
        "candado",
        "paypal",
        "billetera",
        "transferencia",
        "qr",
        "contactless",
        "cajero",
        "cheque",
        "remesa"
    ]

    /**
     * LOS SIETE COLORES QUE SE OFRECEN PARA UNA CATEGORÍA.
     *
     * Son los de la web (`SWATCH`), en su orden. No son los mismos que
     * los de las cuentas: estos van en oklch y los otros en hexadecimal,
     * y mezclarlos deja la hoja de categoría con una paleta y la libreta
     * guardada con otra.
     */
    static let coloresDeCategoria: [String] = [
        "oklch(0.42 0.10 155)",
        "oklch(0.46 0.11 255)",
        "oklch(0.56 0.16 30)",
        "oklch(0.50 0.14 300)",
        "oklch(0.60 0.13 95)",
        "oklch(0.46 0.11 200)",
        "oklch(0.32 0.03 155)"
    ]

    /// Cómo se llama cada uno cuando hay que enseñarlo para elegirlo.
    static let nombreDelIcono: [String: String] = [
        "banco": "Banco",
        "billete": "Efectivo",
        "casa": "Vivienda",
        "carrito": "Compras",
        "comida": "Comida",
        "cafe": "Café",
        "rayo": "Servicios",
        "wifi": "Internet",
        "auto": "Transporte",
        "gasolina": "Combustible",
        "birrete": "Educación",
        "libro": "Libros",
        "salud": "Salud",
        "iglesia": "Donaciones",
        "regalo": "Regalos",
        "cine": "Entretenimiento",
        "musica": "Música",
        "tarjeta": "Deudas",
        "usuario": "Personal",
        "familia": "Familia",
        "hucha": "Ahorro",
        "grafico": "Inversión",
        "maleta": "Viajes",
        "avion": "Vuelos",
        "mascota": "Mascotas",
        "ropa": "Ropa",
        "gym": "Gimnasio",
        "herramienta": "Hogar y arreglos",
        "telefono": "Teléfono",
        "puntos": "Otros",
        "alquiler": "Alquiler",
        "llave": "Hipoteca",
        "sofa": "Muebles",
        "bombilla": "Luz",
        "agua": "Agua",
        "basura": "Basura",
        "bus": "Transporte público",
        "taxi": "Taxi",
        "moto": "Motor",
        "bici": "Bicicleta",
        "parking": "Parqueo",
        "taller": "Taller",
        "peaje": "Peaje",
        "supermercado": "Supermercado",
        "panaderia": "Panadería",
        "restaurante": "Restaurante",
        "pizza": "Comida rápida",
        "bebida": "Bebidas",
        "farmacia": "Farmacia",
        "medico": "Médico",
        "dentista": "Dentista",
        "gafas": "Óptica",
        "peluqueria": "Belleza",
        "cuna": "Bebé",
        "colegio": "Colegio",
        "laptop": "Tecnología",
        "suscripcion": "Suscripciones",
        "juego": "Videojuegos",
        "deporte": "Deporte",
        "playa": "Playa",
        "hotel": "Hotel",
        "concierto": "Eventos",
        "iglesia2": "Iglesia",
        "mano": "Ayuda familiar",
        "impuesto": "Impuestos",
        "seguro": "Seguros",
        "nomina": "Nómina",
        "propina": "Propinas",
        "bolsa": "Ventas",
        "camion": "Envíos",
        "caja": "Inventario",
        "factura": "Facturas",
        "reloj": "Recurrentes",
        "estrella": "Favoritos",
        "corazon": "Cuidado personal",
        "planta": "Jardín",
        "limpieza": "Limpieza",
        "mudanza": "Mudanza",
        "perro": "Perro",
        "gato": "Gato",
        "libro2": "Cursos",
        "premio": "Metas",
        "moneda": "Monedas",
        "cripto": "Cripto",
        "candado": "Fondo bloqueado",
        "paypal": "PayPal",
        "billetera": "Billetera",
        "transferencia": "Transferencia",
        "qr": "Código QR",
        "contactless": "Pago sin contacto",
        "cajero": "Cajero",
        "cheque": "Cheque",
        "remesa": "Remesa"
    ]

    /// El icono que le toca a cada categoría de fábrica, por su nombre.
    ///
    /// Los nombres van en español porque así se crean: una libreta en inglés
    /// las tiene igual por dentro y traducidas solo al enseñarlas.
    static let iconoPorCategoria: [String: String] = [
        "Ingresos": "grafico",
        "Vivienda": "casa",
        "Alimentación": "comida",
        "Servicios": "rayo",
        "Transporte": "auto",
        "Educación": "birrete",
        "Salud": "salud",
        "Donaciones": "iglesia",
        "Entretenimiento": "cine",
        "Deudas": "tarjeta",
        "Personal": "usuario",
        "Ahorro": "hucha",
        "Otros": "puntos"
    ]

    /**
     * EL ICONO QUE LE TOCA A UNA META POR SU NOMBRE, en orden.
     *
     * «Viaje a Punta Cana» lleva maleta y «Casa nueva» lleva casa. Gana el
     * PRIMERO que casa, así que el orden es parte de la respuesta: «ahorro»
     * casaría con media lista si no fuera el último.
     *
     * Los trozos van sueltos y se comparan con `contains`, no con una
     * expresión regular: son las mismas alternativas de la web partidas por
     * la barra, y así no hay dos motores de patrones que entiendan distinto
     * el mismo texto.
     */
    static let iconoDeMeta: [(trozos: [String], icono: String)] = [
        (["viaj", "vacacion", "turism", "playa"], "maleta"),
        (["avion", "avión", "vuelo", "pasaje"], "avion"),
        (["casa", "hogar", "cocina", "apartament", "mudan", "remodel", "reforma", "mueble"], "casa"),
        (["carro", "auto", "vehiculo", "vehículo", "guagua", "moto"], "auto"),
        (["estudi", "universi", "curso", "colegio", "maestr", "beca", "carrera"], "birrete"),
        (["boda", "anillo", "matrimoni", "regalo"], "regalo"),
        (["salud", "medic", "médic", "dentist", "cirug"], "salud"),
        (["negocio", "empresa", "emprend", "local"], "grafico"),
        (["telefono", "teléfono", "celular", "laptop", "computad"], "telefono"),
        (["ropa", "vestid", "zapat"], "ropa"),
        (["gym", "gimnasio", "bici", "deport"], "gym"),
        (["mascota", "perr", "gat"], "mascota"),
        (["emergencia", "fondo", "ahorro"], "hucha")
    ]

    /**
     * LOS DOCE DIBUJOS Y LOS OCHO COLORES DE UNA LIBRETA.
     *
     * Son los suyos y no los del catálogo general: la casa de una
     * libreta no es la misma casa que la de una categoría. Vivían solo
     * en la web y el teléfono tenía que pedirle hasta la lista para
     * poder enseñar «elige un dibujo».
     */
    static let iconosDeLibreta: [(id: String, nombre: String, path: String)] = [
        (id: "casa", nombre: "Casa", path: "M3 10.5L12 3l9 7.5M5 9.5V21h14V9.5M10 21v-6h4v6"),
        (id: "gente", nombre: "Familia", path: "M9 11a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7M2 21a7 7 0 0 1 14 0M17 11a3 3 0 1 0 0-6M18 21a6.5 6.5 0 0 0-2-4.7"),
        (id: "maletin", nombre: "Negocio", path: "M3 8h18v12H3zM9 8V5h6v3M3 13h18"),
        (id: "carrito", nombre: "Compras", path: "M3 4h2l2.4 11h10.2L20 7H6M9 20a1 1 0 1 0 0-2 1 1 0 0 0 0 2M17 20a1 1 0 1 0 0-2 1 1 0 0 0 0 2"),
        (id: "corazon", nombre: "Pareja", path: "M12 20s-7.5-4.6-7.5-9.6A4.4 4.4 0 0 1 12 7a4.4 4.4 0 0 1 7.5 3.4C19.5 15.4 12 20 12 20z"),
        (id: "avion", nombre: "Viaje", path: "M2 13l8-2 3-8 2 1-1.4 6.6L21 9l1 2-7.6 2.4L12 21l-2-1 .6-6.4L3 15z"),
        (id: "carro", nombre: "Vehículo", path: "M3 15v-3l2-5h14l2 5v3M3 15h18v3H3zM7 18v2M17 18v2M6.5 12h11"),
        (id: "libro", nombre: "Estudio", path: "M4 4h11a3 3 0 0 1 3 3v13H7a3 3 0 0 1-3-3zM18 7h2v13H7"),
        (id: "estrella", nombre: "Metas", path: "M12 3l2.7 5.6 6.3.9-4.5 4.4 1 6.1-5.5-2.9-5.5 2.9 1-6.1L3 9.5l6.3-.9z"),
        (id: "cartera", nombre: "Ahorro", path: "M3 7h15a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2zM3 7l2.5-3H16M16 13h3"),
        (id: "regalo", nombre: "Regalos", path: "M3 11h18v10H3zM3 7h18v4H3zM12 7v14M12 7S9.5 3 7.5 4.5 9 7 12 7M12 7s2.5-4 4.5-2.5S15 7 12 7"),
        (id: "pata", nombre: "Mascota", path: "M6.5 11a2 2 0 1 0 0-4 2 2 0 0 0 0 4M17.5 11a2 2 0 1 0 0-4 2 2 0 0 0 0 4M10 7.5a2 2 0 1 0 0-4 2 2 0 0 0 0 4M14 7.5a2 2 0 1 0 0-4 2 2 0 0 0 0 4M12 12c3.5 0 5.5 2.4 5.5 4.6S15.4 20 12 20s-5.5-1.2-5.5-3.4S8.5 12 12 12z")
    ]

    static let coloresDeLibreta: [String] = [
        "oklch(0.42 0.13 152)",
        "oklch(0.50 0.16 258)",
        "oklch(0.52 0.19 300)",
        "oklch(0.58 0.19 28)",
        "oklch(0.58 0.15 65)",
        "oklch(0.48 0.12 200)",
        "oklch(0.46 0.14 340)",
        "oklch(0.38 0.06 155)"
    ]

    /**
     * CHINO: LO QUE DISTINGUE A CADA UNO DE SUS SEIS ÁNIMOS.
     *
     * El cuerpo es el mismo en los seis; lo que cambia es la CARA. Son
     * treinta y seis números —cuánto gira cada ceja, cuánto se abre el
     * ojo, cuánto rubor— y escritos dos veces se separan en cuanto
     * alguien afine uno.
     *
     * `conCeja` en vez de una pareja opcional: el ánimo de todos los días
     * va SIN cejas a propósito —es el de la portada y el de la barra, y
     * ahí las cejas solo lo hacen mayor—, y un cero no es lo mismo que no
     * tenerlas.
     */
    static let animosDeChino: [(id: String, conCeja: Bool, cejaIzq: Double, cejaDer: Double, cejaY: Double, ojo: Double, boca: String, rubor: Double, extras: [String])] = [
        (id: "feliz", conCeja: false, cejaIzq: 0, cejaDer: 0, cejaY: 0, ojo: 1, boca: "sonrisa", rubor: 0.62, extras: []),
        (id: "fiesta", conCeja: true, cejaIzq: -14, cejaDer: 14, cejaY: -2, ojo: 0.55, boca: "risa", rubor: 0.85, extras: ["chispas"]),
        (id: "fuerte", conCeja: true, cejaIzq: -9, cejaDer: -9, cejaY: 0, ojo: 0.9, boca: "ladeada", rubor: 0.45, extras: ["subida"]),
        (id: "estudiosa", conCeja: true, cejaIzq: 4, cejaDer: -4, cejaY: 1, ojo: 1, boca: "recta", rubor: 0.35, extras: ["gafas"]),
        (id: "rota", conCeja: true, cejaIzq: 16, cejaDer: -16, cejaY: 3, ojo: 0.9, boca: "triste", rubor: 0.3, extras: ["sudor"]),
        (id: "jugo", conCeja: true, cejaIzq: -6, cejaDer: 6, cejaY: 1, ojo: 0.28, boca: "sonrisa", rubor: 0.7, extras: ["burbujas"])
    ]

    /// Sus bocas: un trazo y su grosor. Una sonrisa es un arco y no un
    /// rectángulo redondeado: el grosor constante y las puntas hacia
    /// arriba es lo que la hace leerse como sonrisa.
    static let bocasDeChino: [String: (d: String, color: String, grosor: Double)] = [
        "sonrisa": (d: "M47 74q13 12 26 0", color: "#2a1f10", grosor: 4.5),
        "firme": (d: "M49 76h22", color: "#2a1f10", grosor: 4.5),
        "ladeada": (d: "M48 75q13 8 25 -5", color: "#2a1f10", grosor: 4.5),
        "recta": (d: "M51 76h18", color: "#2a1f10", grosor: 4),
        "triste": (d: "M47 79q13 -11 26 0", color: "#2a1f10", grosor: 4.5)
    ]

    /**
     * Y LAS CINCO REGLAS QUE DECIDEN QUÉ CARA PONE.
     *
     * `pronto`: a cuántos días se considera que un pago está encima.
     * `pocos`: por debajo de cuántos movimientos el mes está tranquilo.
     * `activo`: a partir de cuántos ya no lo está —es lo que separa
     * «tranquilo» de «vas bien», y sin él «vas bien» no salía NUNCA—.
     * `yaCasi`: desde qué día del mes tiene sentido celebrar.
     * `holgado`: cuánto de lo que entró tiene que quedar libre.
     */
    static let reglasDelAnimo: (pronto: Int, pocos: Int, activo: Int, yaCasi: Int, holgado: Double) = (
        pronto: 5,
        pocos: 3,
        activo: 10,
        yaCasi: 24,
        holgado: 0.25
    )

    /**
     * EL ORBE: LA SEGUNDA FAMILIA DE CHINO, en figuras.
     *
     * Siete caras, tres pieles y sus degradados, traducidos de
     * `src/orbe.js` —que a su vez es la transcripción de unos cuadros del
     * diseño—. No es una copia del dibujo: es EL dibujo, pasado a datos
     * por la construcción. Rehacerlo mirándolo sale parecido y no igual,
     * y además serían dos dibujos que un día dirían cosas distintas.
     */
    static let carasDelOrbe: [String: CNOrbeCara] = [
        "orbe": .init(fondo: "normal", detras: [], cara: [
                .init(forma: "rect", x: 34, y: 42, w: 9, h: 14, rx: 4.5, relleno: "#12331f"),
                .init(forma: "rect", x: 57, y: 42, w: 9, h: 14, rx: 4.5, relleno: "#12331f")
            ]),
        "ojazos": .init(fondo: "normal", detras: [], cara: [
                .init(forma: "elipse", x: 21, y: 30, w: 25, h: 32, relleno: "#ffffff"),
                .init(forma: "elipse", x: 28.5, y: 37.68, w: 15.5, h: 19.84, relleno: "#12331f"),
                .init(forma: "elipse", x: 34, y: 38.96, w: 6, h: 7.68, relleno: "#ffffff"),
                .init(forma: "elipse", x: 54, y: 30, w: 25, h: 32, relleno: "#ffffff"),
                .init(forma: "elipse", x: 56, y: 37.68, w: 15.5, h: 19.84, relleno: "#12331f"),
                .init(forma: "elipse", x: 60, y: 38.96, w: 6, h: 7.68, relleno: "#ffffff"),
                .init(forma: "trazo", w: 43, h: 70, d: "M43 70a7 6 0 0 0 14 0z", relleno: "#12331f")
            ]),
        "contento": .init(fondo: "normal", brinca: true, chispas: true, detras: [], cara: [
                .init(forma: "trazo", w: 24, h: 54, d: "M24 54a10 14 0 0 1 20 0", trazo: "#12331f", grosor: 6),
                .init(forma: "trazo", w: 56, h: 54, d: "M56 54a10 14 0 0 1 20 0", trazo: "#12331f", grosor: 6),
                .init(forma: "elipse", x: 13, y: 55, w: 17, h: 9, relleno: "rgba(230,90,60,0.45)"),
                .init(forma: "elipse", x: 70, y: 55, w: 17, h: 9, relleno: "rgba(230,90,60,0.45)"),
                .init(forma: "trazo", w: 38, h: 58, d: "M38 58a12 13 0 0 0 24 0z", relleno: "#12331f")
            ]),
        "pensando": .init(fondo: "normal", quieto: true, orbita: true, detras: [
                .init(forma: "elipse", x: -9, y: -9, w: 118, h: 118, trazo: "rgba(29,122,69,0.45)", grosor: 2, raya: 5)
            ], cara: [
                .init(forma: "elipse", x: 22, y: 32, w: 23, h: 28, relleno: "#ffffff"),
                .init(forma: "elipse", x: 32.12, y: 34.8, w: 12.42, h: 15.12, relleno: "#12331f"),
                .init(forma: "elipse", x: 55, y: 32, w: 23, h: 28, relleno: "#ffffff"),
                .init(forma: "elipse", x: 55.46, y: 34.8, w: 12.42, h: 15.12, relleno: "#12331f"),
                .init(forma: "rect", x: 22, y: 26, w: 23, h: 5, rx: 2.5, relleno: "#1f5231", gira: -6, giraX: 33.5, giraY: 28.5),
                .init(forma: "rect", x: 44, y: 70, w: 12, h: 5, rx: 2.5, relleno: "#12331f")
            ]),
        "escuchando": .init(fondo: "normal", quieto: true, detras: [], cara: [
                .init(forma: "elipse", x: 22, y: 32, w: 24, h: 30, relleno: "#ffffff"),
                .init(forma: "elipse", x: 27.76, y: 40.4, w: 14.4, h: 18, relleno: "#12331f"),
                .init(forma: "elipse", x: 54, y: 32, w: 24, h: 30, relleno: "#ffffff"),
                .init(forma: "elipse", x: 57.84, y: 40.4, w: 14.4, h: 18, relleno: "#12331f"),
                .init(forma: "rect", x: 44, y: 70, w: 12, h: 6, rx: 3, relleno: "#12331f")
            ]),
        "pasado": .init(fondo: "calida", quieto: true, detras: [], cara: [
                .init(forma: "elipse", x: 22, y: 34, w: 24, h: 28, relleno: "#ffffff"),
                .init(forma: "elipse", x: 27.76, y: 44.08, w: 13.44, h: 15.68, relleno: "#3a0e08"),
                .init(forma: "elipse", x: 54, y: 34, w: 24, h: 28, relleno: "#ffffff"),
                .init(forma: "elipse", x: 58.8, y: 44.08, w: 13.44, h: 15.68, relleno: "#3a0e08"),
                .init(forma: "rect", x: 20, y: 26, w: 26, h: 5, rx: 2.5, relleno: "#6b1a10", gira: 14, giraX: 33, giraY: 28.5),
                .init(forma: "rect", x: 54, y: 26, w: 26, h: 5, rx: 2.5, relleno: "#6b1a10", gira: -14, giraX: 67, giraY: 28.5),
                .init(forma: "trazo", w: 38, h: 78, d: "M38 78a12 8 0 0 1 24 0z", relleno: "#3a0e08")
            ]),
        "calma": .init(fondo: "normal", lento: true, detras: [], cara: [
                .init(forma: "trazo", w: 24, h: 54, d: "M24 54a10 14 0 0 1 20 0", trazo: "#12331f", grosor: 6),
                .init(forma: "trazo", w: 56, h: 54, d: "M56 54a10 14 0 0 1 20 0", trazo: "#12331f", grosor: 6),
                .init(forma: "trazo", w: 43, h: 70, d: "M43 70a7 6 0 0 0 14 0z", relleno: "#12331f")
            ])
    ]

    /// De qué está hecho: la piel la elige la persona, el ánimo lo elige el mes.
    static let pielesDelOrbe: [String: CNOrbePiel] = [
        "clara": .init(nombre: "Orbe", fondoPropio: "", encima: [], delante: [], caraPropia: false, propiaNormal: [], propiaCalida: []),
        "chinola": .init(nombre: "Orbe chinola", fondoPropio: "", encima: [
                .init(forma: "rect", x: 48, y: -12, w: 6, h: 18, rx: 4, relleno: "#1f5231", gira: 8, giraX: 51, giraY: -3),
                .init(forma: "trazo", w: 52, h: 82, d: "M52 2A30 18 0 0 1 82 -16A30 18 0 0 1 52 2Z", relleno: "#5fb672", gira: -18, giraX: 67, giraY: -7)
            ], delante: [
                .init(forma: "trazo", x: 80, y: 8, w: 26, h: 26, d: "M93 8L95.86 18.14L106 21L95.86 23.86L93 34L90.14 23.86L80 21L90.14 18.14Z", relleno: "#ffffff")
            ], caraPropia: false, propiaNormal: [], propiaCalida: []),
        "semilla": .init(nombre: "Semilla que mira", fondoPropio: "semilla", encima: [], delante: [], caraPropia: true, propiaNormal: [
                .init(forma: "elipse", x: 22, y: 34, w: 22, h: 26, relleno: "grad:osem"),
                .init(forma: "elipse", x: 56, y: 34, w: 22, h: 26, relleno: "grad:osem"),
                .init(forma: "elipse", x: 28, y: 16, w: 16, h: 10, relleno: "rgba(255,255,255,0.14)", gira: -30, giraX: 36, giraY: 21)
            ], propiaCalida: [
                .init(forma: "elipse", x: 22, y: 34, w: 22, h: 26, relleno: "grad:osem"),
                .init(forma: "elipse", x: 56, y: 34, w: 22, h: 26, relleno: "grad:osem"),
                .init(forma: "elipse", x: 28, y: 16, w: 16, h: 10, relleno: "rgba(255,255,255,0.14)", gira: -30, giraX: 36, giraY: 21)
            ])
    ]

    /// Y en qué orden se ofrecen, que un diccionario no tiene orden.
    static let ordenDePieles: [String] = ["clara", "chinola", "semilla"]

    /// Qué cara pone cada ánimo, y los dos estados que van encima.
    static let animosDelOrbe: [String: String] = ["feliz": "orbe", "fiesta": "contento", "fuerte": "ojazos", "estudiosa": "pensando", "rota": "pasado", "jugo": "calma"]

    static let estadosDelOrbe: [String: String] = ["escuchando": "escuchando", "pensando": "pensando"]

    static let gradientesDelOrbe: [String: CNOrbeGrad] = [
        "esfera:normal": .init(tipo: "radial", cx: 30, cy: 25, r: 102.5914, paradas: [(off: 0, color: "#fff3a8", alfa: 1), (off: 0.3, color: "#ffd426", alfa: 1), (off: 0.7, color: "#6cc287", alfa: 1), (off: 1, color: "#1f6b3e", alfa: 1)]),
        "halo:normal": .init(tipo: "radial", cx: 50, cy: 50, r: 50, paradas: [(off: 0.62, color: "#6cc287", alfa: 0.5), (off: 1, color: "#6cc287", alfa: 0)]),
        "esfera:calida": .init(tipo: "radial", cx: 30, cy: 25, r: 102.5914, paradas: [(off: 0, color: "#ffe0b0", alfa: 1), (off: 0.35, color: "#ffb45c", alfa: 1), (off: 0.8, color: "#e0574e", alfa: 1), (off: 1, color: "#9e2a20", alfa: 1)]),
        "halo:calida": .init(tipo: "radial", cx: 50, cy: 50, r: 50, paradas: [(off: 0.62, color: "#e0574e", alfa: 0.5), (off: 1, color: "#e0574e", alfa: 0)]),
        "esfera:semilla": .init(tipo: "radial", cx: 32, cy: 26, r: 100.4988, paradas: [(off: 0, color: "#3a3222", alfa: 1), (off: 0.55, color: "#1e1a10", alfa: 1), (off: 1, color: "#0a0804", alfa: 1)]),
        "halo:semilla": .init(tipo: "radial", cx: 50, cy: 50, r: 50, paradas: [(off: 0.62, color: "#ffbe00", alfa: 0.5), (off: 1, color: "#ffbe00", alfa: 0)]),
        "ohoja": .init(tipo: "lineal", x1: 14.6447, y1: 85.3553, x2: 85.3553, y2: 14.6447, paradas: [(off: 0, color: "#1e6d3a", alfa: 1), (off: 1, color: "#5fb672", alfa: 1)]),
        "osem:normal": .init(tipo: "radial", cx: 50, cy: 50, r: 70.7107, paradas: [(off: 0, color: "#fff6b8", alfa: 1), (off: 0.55, color: "#ffd426", alfa: 1), (off: 1, color: "#f5a500", alfa: 1)]),
        "osem:calida": .init(tipo: "radial", cx: 50, cy: 50, r: 70.7107, paradas: [(off: 0, color: "#ffd9b8", alfa: 1), (off: 0.55, color: "#ff9a5c", alfa: 1), (off: 1, color: "#e0574e", alfa: 1)])
    ]

    static let haloDelOrbe: [CNOrbePieza] = [
        .init(forma: "elipse", x: -18, y: -18, w: 136, h: 136, relleno: "grad:halo")
    ]

    static let esferaDelOrbe: [CNOrbePieza] = [
        .init(forma: "elipse", w: 100, h: 100, relleno: "grad:esfera")
    ]

    static let aroDelOrbe: [CNOrbePieza] = [
        .init(forma: "elipse", x: -3, y: -3, w: 106, h: 106, trazo: "#ffd426", grosor: 6, opacidad: 0.2)
    ]

    static let chispasDelOrbe: [CNOrbePieza] = [
        .init(forma: "trazo", x: 84, y: 4, w: 20, h: 20, d: "M94 4L96.2 11.8L104 14L96.2 16.2L94 24L91.8 16.2L84 14L91.8 11.8Z", relleno: "#ffffff"),
        .init(forma: "trazo", x: -2, y: 10, w: 13, h: 13, d: "M4.5 10L5.93 15.07L11 16.5L5.93 17.93L4.5 23L3.07 17.93L-2 16.5L3.07 15.07Z", relleno: "#ffd426"),
        .init(forma: "trazo", x: 92, y: 34, w: 10, h: 10, d: "M97 34L98.1 37.9L102 39L98.1 40.1L97 44L95.9 40.1L92 39L95.9 37.9Z", relleno: "#ffd426")
    ]

    static let orbitaDelOrbe: [CNOrbePieza] = [
        .init(forma: "trazo", x: 90, y: -4, w: 22, h: 22, d: "M101 -4L103.42 4.58L112 7L103.42 9.42L101 18L98.58 9.42L90 7L98.58 4.58Z", relleno: "#ffd426"),
        .init(forma: "trazo", x: -8, y: 82, w: 12, h: 12, d: "M-2 82L-0.68 86.68L4 88L-0.68 89.32L-2 94L-3.32 89.32L-8 88L-3.32 86.68Z", relleno: "#1d7a45")
    ]

    static let orbitaSolaDelOrbe: [CNOrbePieza] = [
        .init(forma: "trazo", x: 90, y: -4, w: 22, h: 22, d: "M101 -4L103.42 4.58L112 7L103.42 9.42L101 18L98.58 9.42L90 7L98.58 4.58Z", relleno: "#ffd426")
    ]

    static let puntosDelOrbe: [CNOrbePieza] = [
        .init(forma: "elipse", x: 36.6, y: 108.6, w: 6.8, h: 6.8),
        .init(forma: "elipse", x: 46.6, y: 108.6, w: 6.8, h: 6.8),
        .init(forma: "elipse", x: 56.6, y: 108.6, w: 6.8, h: 6.8)
    ]

    static let hojaDelOrbe: [CNOrbePieza] = [
        .init(forma: "rect", x: 48, y: -12, w: 6, h: 18, rx: 4, relleno: "#1f5231", gira: 8, giraX: 51, giraY: -3),
        .init(forma: "trazo", w: 52, h: 82, d: "M52 2A30 18 0 0 1 82 -16A30 18 0 0 1 52 2Z", relleno: "grad:ohoja", gira: -18, giraX: 67, giraY: -7)
    ]

    /// El aire de alrededor: para el resplandor y las chispas, que se
    /// salen de la esfera. Recortado es menos, que en un icono ese aire lo
    /// hace verse más chico que los iconos de al lado.
    static let aireDelOrbe: (normal: Double, ajustado: Double) = (normal: 16, ajustado: 4)

    /**
     * LOS DIEZ PASOS DEL RECORRIDO.
     *
     * Viajaban ENTEROS por el puente: el teléfono le pedía a la web
     * hasta el texto de cada globo. Son datos fijos.
     *
     * `vista` es en qué pestaña se cuenta cada uno y `ancla` qué señala
     * el aro —vacío en el último, que ya no hay que mirar a ningún
     * sitio—. El texto es el del TELÉFONO cuando el paso tiene uno
     * propio: aquí no hay «+» flotante, y el paso que lo explicaba
     * señalaba la pestaña de Movimientos mientras el globo hablaba de
     * «este botón».
     */
    static let pasosDelTour: [(vista: String, animo: String, ancla: String, titulo: String, texto: String)] = [
        (vista: "resumen", animo: "feliz", ancla: "tab-perfil", titulo: "Hola, soy Chino", texto: "Vivo aquí abajo y voy cambiando de cara según cómo te vaya el mes. Te enseño la casa en un minuto; si prefieres mirar por tu cuenta, sáltatelo."),
        (vista: "resumen", animo: "feliz", ancla: "libreta", titulo: "Una libreta por cada bolsillo", texto: "Este es el nombre de la libreta que estás mirando. Tócalo para cambiar: lo de la casa no se mezcla con lo del negocio."),
        (vista: "resumen", animo: "estudiosa", ancla: "meses", titulo: "El mes que tienes delante", texto: "Esta tira son los meses de alrededor: tócalos para saltar. Y en «Rango…» pides los últimos tres meses, el año, o dos fechas a tu medida."),
        (vista: "resumen", animo: "estudiosa", ancla: "tab-resumen", titulo: "El resumen, a tu manera", texto: "Esta pantalla son tarjetas: lo que entró, lo que salió, lo que te queda, las gráficas. Mantén una pulsada para moverlas de sitio, y en Personalización eliges cuáles quieres ver."),
        (vista: "resumen", animo: "fuerte", ancla: "fab", titulo: "Todo se anota desde aquí", texto: "Mantén pulsada esta pestaña y se abre directamente el formulario para anotar. Y dentro de Movimientos tienes el «+» arriba a la derecha."),
        (vista: "movs", animo: "estudiosa", ancla: "tab-movs", titulo: "Todo lo que anotas, por días", texto: "Aquí sale cada movimiento con su día y su total. Arriba buscas —sin tildes, como te salga— y con el embudo dejas solo ingresos, fijos, variables o ahorro."),
        (vista: "cuentas", animo: "fuerte", ancla: "tab-cuentas", titulo: "Dónde está tu dinero", texto: "Tus cuentas, tus tarjetas y tus préstamos, con lo que tienes y lo que debes arriba del todo. Entra en cualquiera y verás sus movimientos y sus fechas."),
        (vista: "plan", animo: "fiesta", ancla: "tab-plan", titulo: "Ponte presupuestos y metas", texto: "Aquí le pones un presupuesto a cada categoría y guardas para lo que viene. Entra en una meta y verás cuánto llevas y cuándo la alcanzas a este ritmo."),
        (vista: "perfil", animo: "jugo", ancla: "tab-perfil", titulo: "Ponla como te guste", texto: "En Personalización tienes treinta y un temas, la letra, los colores de las cifras y el orden de las tarjetas del resumen. Y cuando se acerque un pago, te lo marco encima de mi cara."),
        (vista: "perfil", animo: "fiesta", ancla: "", titulo: "Y ya está", texto: "Eso es todo lo que hay que saber para empezar. Si algo se te olvida, vuelve a Perfil y toca «Ver el tour otra vez»: estoy aquí siempre que hagas falta.")
    ]

    /// Y la risa, que es la única RELLENA: la boca abierta y la lengua.
    static let risaDeChino: [(d: String, color: String)] = [
        (d: "M45 71q15 20 30 0z", color: "#2a1f10"),
        (d: "M52 79q8 7 16 0z", color: "#e0736b")
    ]

    /// Los de las filas de ajustes, que son otros y viven aparte.
    static let iconosDeAjuste: [String: String] = [
        "notis": "M18 8a6 6 0 1 0-12 0c0 7-3 9-3 9h18s-3-2-3-9M13.7 21a2 2 0 0 1-3.4 0",
        "tour": "M12 22a10 10 0 1 0 0-20 10 10 0 0 0 0 20M10 8l6 4-6 4z",
        "exportar": "M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4M7 10l5 5 5-5M12 15V3",
        "salir": "M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4M16 17l5-5-5-5M21 12H9",
        "perfil": "M12 11a4 4 0 1 0 0-8 4 4 0 0 0 0 8M4 21a8 8 0 0 1 16 0",
        "correo": "M3 6h18v12H3zM3 7l9 6 9-6",
        "clave": "M5 11h14v10H5zM8 11V7a4 4 0 0 1 8 0v4",
        "plan": "M12 3l2.7 5.6 6.3.9-4.5 4.4 1 6.1-5.5-2.9-5.5 2.9 1-6.1L3 9.5l6.3-.9z",
        "ayuda": "M12 22a10 10 0 1 0 0-20 10 10 0 0 0 0 20M9.1 9a3 3 0 0 1 5.8 1c0 2-3 3-3 3M12 17h.01",
        "privacidad": "M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z",
        "baja": "M3 6h18M8 6V4h8v2M6 6l1 14h10l1-14M10 11v6M14 11v6",
        "libretas": "M4 4h11a3 3 0 0 1 3 3v13H7a3 3 0 0 1-3-3zM18 7h2v13H7",
        "panelIco": "M4 4h7v7H4zM13 4h7v4h-7zM13 10h7v10h-7zM4 13h7v7H4z",
        "cuentaIco": "M4 7h16a1 1 0 0 1 1 1v9a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V8a1 1 0 0 1 1-1zM3 11h18M7 15h3",
        "prestamoIco": "M3 8h13l-3-3M21 16H8l3 3",
        "metaIco": "M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18M12 16a4 4 0 1 0 0-8 4 4 0 0 0 0 8M12 12h.01",
        "cabeceraIco": "M4 5h16a1 1 0 0 1 1 1v3H3V6a1 1 0 0 1 1-1zM3 9v9a1 1 0 0 0 1 1h16a1 1 0 0 0 1-1V9",
        "letraIco": "M5 20l6.2-16h1.6L19 20M8 14h8",
        "coloresIco": "M12 21a9 9 0 1 1 0-18c4.9 0 9 3.4 9 7.5 0 2.5-2 4.5-4.5 4.5H15a2 2 0 0 0-1.6 3.2c.3.4.4.8.4 1.2 0 .9-.8 1.6-1.8 1.6M7.5 10.5h.01M11 7.5h.01M15.5 9h.01",
        "dineroIco": "M12 2v20M17 6.5c0-1.9-2.2-3-5-3s-5 1.1-5 3 2.2 2.8 5 3.4 5 1.5 5 3.6-2.2 3-5 3-5-1.1-5-3",
        "personajeIco": "M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18M9 10h.01M15 10h.01M8.5 14.5a4.5 4.5 0 0 0 7 0",
        "personaliza": "M12 3a9 9 0 1 0 0 18c1.1 0 2-.9 2-2 0-.5-.2-1-.6-1.4-.3-.4-.5-.8-.5-1.3 0-1.1.9-2 2-2H17a4 4 0 0 0 4-4c0-4-4-7.3-9-7.3M7.5 12.5h.01M10 8.5h.01M14.5 8h.01",
        "datos": "M4 6c0-1.7 3.6-3 8-3s8 1.3 8 3-3.6 3-8 3-8-1.3-8-3M4 6v12c0 1.7 3.6 3 8 3s8-1.3 8-3V6M4 12c0 1.7 3.6 3 8 3s8-1.3 8-3",
        "importar": "M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4M7 9l5-5 5 5M12 4v12",
        "sincronizar": "M20 16.6A7.5 7.5 0 0 0 17 3a7.5 7.5 0 0 0-13.9 3.5A5 5 0 0 0 5 20h2M12 21v-8M9 16l3-3 3 3",
        "integraciones": "M10 13a5 5 0 0 0 7 0l3-3a5 5 0 0 0-7-7l-1.5 1.5M14 11a5 5 0 0 0-7 0l-3 3a5 5 0 0 0 7 7l1.5-1.5",
        "sesiones": "M12 3a9 9 0 1 0 0 18 9 9 0 0 0 0-18M12 7v5l3 2",
        "idioma": "M4 5h11M9 3v2c0 5-2.4 8.5-6 10M6 10c0 2.6 3 5.5 8 6M13 21l4.5-10 4.5 10M15 17.5h5",
        "escudo": "M12 3l8 3v6c0 5-4 8-8 9-4-1-8-4-8-9V6zM9 12l2 2 4-4",
        "dosPasos": "M3 6h18v12H3zM3 8l9 6 9-6M12 20v2",
        "telefono": "M7 2h10a2 2 0 0 1 2 2v16a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2M10 19h4",
        "monitor": "M3 4h18v12H3zM8 20h8M12 16v4",
        "telegram": "M22 2 11 13M22 2l-7 20-4-9-9-4z",
        "whatsapp": "M20.5 11.5a8.5 8.5 0 0 1-12.4 7.6L3.5 20.5l1.4-4.6a8.5 8.5 0 1 1 15.6-4.4zM9 10c0 2.8 2.2 5 5 5l.9-1.6-2-.8-.8.8A4 4 0 0 1 11 11.6l.8-.8-.8-2z",
        "alexa": "M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18M12 16.5a4.5 4.5 0 1 0 0-9 4.5 4.5 0 0 0 0 9",
        "siri": "M4 11v2M8 8v8M12 4.5v15M16 8v8M20 11v2",
        "autenticador": "M7 2h10a2 2 0 0 1 2 2v16a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2M8.5 9h2M13.5 9h2M8.5 13h2M13.5 13h2M10 17h4",
        "codigos": "M4 5h16v14H4zM7.5 9.5h3M13.5 9.5h3M7.5 14h3M13.5 14h3",
        "appIco": "M6 2h12a4 4 0 0 1 4 4v12a4 4 0 0 1-4 4H6a4 4 0 0 1-4-4V6a4 4 0 0 1 4-4zM12 7.3l1.7 3.5 3.8.5-2.8 2.7.7 3.8-3.4-1.8-3.4 1.8.7-3.8-2.8-2.7 3.8-.5z",
        "barraIco": "M6 2h12a2 2 0 0 1 2 2v16a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2M4 17h16M8 20h.01M12 20h.01M16 20h.01",
        "etiquetaIco": "M20.6 13.3 13 21a1.4 1.4 0 0 1-2 0l-8-8V4a1 1 0 0 1 1-1h9l7.6 7.6a1.9 1.9 0 0 1 0 2.7zM7.5 7.5h.01"
    ]

    /// El color de cada fila de ajustes, por su tono.
    static let tonos: [String: String] = [
        "verde": "oklch(0.44 0.11 155)",
        "azul": "oklch(0.48 0.12 255)",
        "indigo": "oklch(0.44 0.12 250)",
        "morado": "oklch(0.48 0.14 300)",
        "rosa": "oklch(0.50 0.14 320)",
        "naranja": "oklch(0.55 0.13 70)",
        "oro": "oklch(0.52 0.13 95)",
        "oliva": "oklch(0.44 0.12 130)",
        "rojo": "var(--negativo)"
    ]

    /// Cómo se llama cada plan.
    static let nombreDelPlan: [String: String] = [
        "gratis": "Gratis",
        "pro": "Pro",
        "negocio": "Negocio"
    ]

    /// Y qué da cada uno. El servidor es quien manda (`api/src/planes.js`);
    /// esto solo lo cuenta, para que la app no calle lo que no deja hacer.
    static let queDaElPlan: [String: String] = [
        "gratis": "Una libreta, sin compartir ni integraciones",
        "pro": "Libretas sin límite, compartidas y con integraciones",
        "negocio": "Todo lo de Pro, pensado para un equipo"
    ]

    /// Las monedas, EN ORDEN. El orden no es alfabético: el peso
    /// dominicano primero porque es el de casi todo el mundo que usa
    /// esto, y ordenarlas por nombre lo mandaría al medio de la lista.
    static let monedas: [(id: String, nombre: String)] = [
        (id: "DOP", nombre: "Peso dominicano (RD$)"),
        (id: "USD", nombre: "Dólar (US$)"),
        (id: "EUR", nombre: "Euro (€)"),
        (id: "MXN", nombre: "Peso mexicano"),
        (id: "COP", nombre: "Peso colombiano"),
        (id: "ARS", nombre: "Peso argentino"),
        (id: "CLP", nombre: "Peso chileno"),
        (id: "PEN", nombre: "Sol peruano"),
        (id: "GTQ", nombre: "Quetzal"),
        (id: "HNL", nombre: "Lempira"),
        (id: "CRC", nombre: "Colón"),
        (id: "BRL", nombre: "Real")
    ]

    /// Los tamaños de letra, de menor a mayor. La escala es la de la
    /// web dividida por 1,07: allí «normal» es 1,07 porque el diseño
    /// venía de una maqueta, y aquí 1 es 1.
    static let letras: [(id: String, nombre: String, escala: Double)] = [
        (id: "chica", nombre: "Pequeña", escala: 0.8785),
        (id: "normal", nombre: "Normal", escala: 1.0000),
        (id: "grande", nombre: "Grande", escala: 1.1028),
        (id: "mayor", nombre: "Muy grande", escala: 1.1963)
    ]

    /// Las tipografías, con la pista que las distingue de un vistazo.
    static let tipografias: [(id: String, nombre: String, pista: String)] = [
        (id: "sistema", nombre: "Del sistema", pista: "La del aparato"),
        (id: "jakarta", nombre: "Plus Jakarta", pista: "La de siempre"),
        (id: "inter", nombre: "Inter", pista: "Neutra"),
        (id: "nunito", nombre: "Nunito", pista: "Redondeada"),
        (id: "source", nombre: "Source Serif", pista: "Con serifa")
    ]

    /// Las cabeceras que se pueden elegir, en su orden. «auto» primera
    /// porque no es una forma fija: es la grande que se encoge al bajar.
    static let cabeceras: [(id: String, nombre: String, pista: String)] = [
        (id: "auto", nombre: "Automática", pista: "Grande en el resumen, fina al bajar"),
        (id: "fina", nombre: "Fina", pista: "Una línea verde con el balance al lado"),
        (id: "clara", nombre: "Clara", pista: "Del color del papel, sin franja"),
        (id: "minima", nombre: "Mínima", pista: "Lo justo: libreta y mes"),
        (id: "clasica", nombre: "Clásica", pista: "La franja verde de siempre"),
        (id: "detallada", nombre: "Detallada", pista: "Con lo gastado del mes y el mes en un botón"),
        (id: "viva", nombre: "Viva", pista: "Las cuatro cifras del mes, cada una con su color")
    ]

    /// Y sus colores. Todos oscuros o de tono medio a propósito: la
    /// tinta de la cabecera es clara, así que sobre estos se lee.
    static let coloresDeCabecera: [(id: String, nombre: String, css: String, tinta: String, sobre: String)] = [
        (id: "chinola", nombre: "Chinola", css: "linear-gradient(150deg, #f7c948, #ec9a2e 55%, #3f9d54)", tinta: "#2b2010", sobre: "oscuro"),
        (id: "mango", nombre: "Mango", css: "linear-gradient(150deg, #f9c04b, #ef8a2c)", tinta: "#33230b", sobre: "oscuro"),
        (id: "durazno", nombre: "Durazno", css: "linear-gradient(150deg, #f8b370, #f4845f)", tinta: "#3a2214", sobre: "oscuro"),
        (id: "lima", nombre: "Lima", css: "linear-gradient(150deg, #cfe95f, #85bb3e)", tinta: "#243409", sobre: "oscuro"),
        (id: "pino", nombre: "Pino", css: "linear-gradient(150deg, #33a565, #14683b)", tinta: "#f1fbf5", sobre: "claro"),
        (id: "bosque", nombre: "Bosque", css: "linear-gradient(150deg, #2c8f5a, #15412c)", tinta: "#e9f8ef", sobre: "claro"),
        (id: "oceano", nombre: "Oceano", css: "linear-gradient(150deg, #3f8ad0, #1f4f89)", tinta: "#ecf5fd", sobre: "claro"),
        (id: "medianoche", nombre: "Medianoche", css: "linear-gradient(150deg, #3d4f96, #1f2550)", tinta: "#eef0fc", sobre: "claro"),
        (id: "ciruela", nombre: "Ciruela", css: "linear-gradient(150deg, #834fa6, #47256e)", tinta: "#f6effb", sobre: "claro"),
        (id: "uva", nombre: "Uva", css: "linear-gradient(150deg, #9a5cc7, #5c3096)", tinta: "#f6effc", sobre: "claro"),
        (id: "coral", nombre: "Coral", css: "linear-gradient(150deg, #ea6a52, #c0343c)", tinta: "#fdece7", sobre: "claro"),
        (id: "cacao", nombre: "Cacao", css: "linear-gradient(150deg, #7d4b30, #472a1b)", tinta: "#f6ece2", sobre: "claro"),
        (id: "carbon", nombre: "Carbon", css: "linear-gradient(150deg, #2a2e2b, #141714)", tinta: "#eef0e8", sobre: "claro"),
        (id: "noche", nombre: "Noche", css: "linear-gradient(150deg, #27313b, #12181e)", tinta: "#eef2f6", sobre: "claro")
    ]

    /// Los colores de las cifras: lo que entra, lo que sale y lo que
    /// apartas. Una de las cuatro se distingue con daltonismo.
    static let paletas: [(id: String, nombre: String, pista: String,
                          positivo: String, negativo: String, ahorro: String,
                          aviso: String)] = [
        (id: "clasica", nombre: "Clásica", pista: "La de siempre", positivo: "oklch(0.52 0.13 152)", negativo: "oklch(0.62 0.16 30)", ahorro: "oklch(0.56 0.14 300)", aviso: "oklch(0.66 0.14 70)"),
        (id: "semaforo", nombre: "Semáforo", pista: "Verde y rojo francos", positivo: "oklch(0.55 0.17 145)", negativo: "oklch(0.55 0.21 27)", ahorro: "oklch(0.55 0.16 285)", aviso: "oklch(0.72 0.16 80)"),
        (id: "sobria", nombre: "Sobria", pista: "Los mismos, más callados", positivo: "oklch(0.48 0.07 152)", negativo: "oklch(0.52 0.09 30)", ahorro: "oklch(0.50 0.07 290)", aviso: "oklch(0.58 0.07 75)"),
        (id: "daltonica", nombre: "Azul y naranja", pista: "Se distinguen con daltonismo", positivo: "oklch(0.52 0.14 245)", negativo: "oklch(0.63 0.16 55)", ahorro: "oklch(0.50 0.10 285)", aviso: "oklch(0.58 0.10 200)"),
        (id: "fria", nombre: "Fría", pista: "Del azul al violeta", positivo: "oklch(0.55 0.13 195)", negativo: "oklch(0.52 0.16 315)", ahorro: "oklch(0.50 0.13 260)", aviso: "oklch(0.60 0.11 230)"),
        (id: "calida", nombre: "Cálida", pista: "Oliva y terracota", positivo: "oklch(0.54 0.11 125)", negativo: "oklch(0.53 0.13 40)", ahorro: "oklch(0.55 0.10 60)", aviso: "oklch(0.63 0.12 85)"),
        (id: "chinola", nombre: "Chinola", pista: "Los de la marca", positivo: "oklch(0.46 0.12 152)", negativo: "oklch(0.58 0.17 35)", ahorro: "oklch(0.52 0.14 300)", aviso: "oklch(0.70 0.15 88)"),
        (id: "contraste", nombre: "Alto contraste", pista: "Lo más separado posible", positivo: "oklch(0.44 0.18 148)", negativo: "oklch(0.46 0.23 25)", ahorro: "oklch(0.42 0.20 295)", aviso: "oklch(0.62 0.18 75)"),
        (id: "menta", nombre: "Menta y rosa", pista: "Suave, sin gritar", positivo: "oklch(0.56 0.12 175)", negativo: "oklch(0.58 0.15 5)", ahorro: "oklch(0.56 0.11 320)", aviso: "oklch(0.66 0.12 90)"),
        (id: "sin_color", nombre: "Sin color", pista: "Para los temas sombríos", positivo: "oklch(0.42 0 0)", negativo: "oklch(0.62 0 0)", ahorro: "oklch(0.52 0 0)", aviso: "oklch(0.70 0 0)")
    ]

    /**
     * CADA TEMA, ENTERO.
     *
     * Antes solo llevaba lo de su miniatura —fondo, tarjeta, suave,
     * tinta y franja— y faltaban el BORDE, el GRIS y el patrón, que es
     * justo lo que hace falta para pintar la app con él sin pedírselo a
     * la web. Sin el borde, todas las rayas de la app salen del color de
     * fábrica sobre un tema oscuro.
     */
    static let temas: [String: (nombre: String, bg: String, card: String,
                                suave: String, borde: String, tinta: String,
                                gris: String, side: String, patron: String)] = [
        "oceano": (nombre: "Océano", bg: "oklch(0.97 0.02 240)", card: "#fff", suave: "oklch(0.96 0.03 240)", borde: "oklch(0.90 0.03 240)", tinta: "oklch(0.24 0.04 250)", gris: "oklch(0.48 0.04 250)", side: "oklch(0.32 0.09 250)", patron: "none"),
        "menta": (nombre: "Menta", bg: "oklch(0.97 0.03 175)", card: "#fff", suave: "oklch(0.96 0.04 175)", borde: "oklch(0.89 0.04 175)", tinta: "oklch(0.24 0.04 180)", gris: "oklch(0.46 0.04 180)", side: "oklch(0.34 0.08 178)", patron: "none"),
        "cacao": (nombre: "Cacao", bg: "oklch(0.96 0.02 60)", card: "#fff", suave: "oklch(0.96 0.03 60)", borde: "oklch(0.89 0.03 60)", tinta: "oklch(0.26 0.04 50)", gris: "oklch(0.47 0.04 55)", side: "oklch(0.33 0.06 50)", patron: "none"),
        "uva": (nombre: "Uva", bg: "oklch(0.97 0.02 300)", card: "#fff", suave: "oklch(0.96 0.03 300)", borde: "oklch(0.90 0.03 300)", tinta: "oklch(0.25 0.05 305)", gris: "oklch(0.47 0.05 305)", side: "oklch(0.33 0.10 300)", patron: "none"),
        "carbon": (nombre: "Carbón", bg: "oklch(0.21 0.005 250)", card: "oklch(0.26 0.006 250)", suave: "oklch(0.30 0.008 250)", borde: "oklch(0.35 0.01 250)", tinta: "oklch(0.94 0.005 250)", gris: "oklch(0.72 0.01 250)", side: "oklch(0.17 0.005 250)", patron: "none"),
        "medianoche": (nombre: "Medianoche", bg: "oklch(0.20 0.03 260)", card: "oklch(0.25 0.035 260)", suave: "oklch(0.29 0.04 260)", borde: "oklch(0.34 0.04 260)", tinta: "oklch(0.94 0.02 250)", gris: "oklch(0.74 0.03 250)", side: "oklch(0.16 0.03 262)", patron: "none"),
        "claro": (nombre: "Claro", bg: "oklch(0.995 0 0)", card: "#fff", suave: "oklch(0.975 0.002 95)", borde: "oklch(0.925 0.003 95)", tinta: "oklch(0.22 0.01 155)", gris: "oklch(0.52 0.01 155)", side: "oklch(0.34 0.01 155)", patron: "none"),
        "chinola": (nombre: "Chinola", bg: "oklch(0.975 0.015 95)", card: "#fff", suave: "oklch(0.97 0.02 95)", borde: "oklch(0.91 0.02 95)", tinta: "oklch(0.24 0.03 155)", gris: "oklch(0.48 0.03 155)", side: "oklch(0.255 0.038 156)", patron: "none"),
        "jugo": (nombre: "Jugo", bg: "oklch(0.97 0.04 88)", card: "#fff", suave: "oklch(0.97 0.05 88)", borde: "oklch(0.90 0.05 88)", tinta: "oklch(0.26 0.05 70)", gris: "oklch(0.48 0.05 75)", side: "oklch(0.42 0.12 68)", patron: "none"),
        "hoja": (nombre: "Hoja", bg: "oklch(0.96 0.03 150)", card: "#fff", suave: "oklch(0.96 0.03 150)", borde: "oklch(0.89 0.04 150)", tinta: "oklch(0.22 0.05 155)", gris: "oklch(0.44 0.05 155)", side: "oklch(0.34 0.09 152)", patron: "none"),
        "noche": (nombre: "Noche", bg: "oklch(0.20 0.02 155)", card: "oklch(0.25 0.025 155)", suave: "oklch(0.29 0.03 155)", borde: "oklch(0.34 0.03 155)", tinta: "oklch(0.94 0.02 95)", gris: "oklch(0.72 0.02 110)", side: "oklch(0.16 0.02 155)", patron: "none"),
        "sistema": (nombre: "Sistema claro", bg: "oklch(0.957 0.004 286)", card: "#fff", suave: "oklch(0.925 0.005 286)", borde: "oklch(0.87 0.004 286)", tinta: "oklch(0.22 0.004 286)", gris: "oklch(0.53 0.005 286)", side: "oklch(0.34 0.08 155)", patron: "none"),
        "sistema_noche": (nombre: "Sistema oscuro", bg: "oklch(0 0 0)", card: "oklch(0.22 0.004 286)", suave: "oklch(0.29 0.004 286)", borde: "oklch(0.36 0.004 286)", tinta: "oklch(0.957 0.004 286)", gris: "oklch(0.68 0.008 286)", side: "oklch(0.20 0.05 155)", patron: "none"),
        "sombrio": (nombre: "Sombrío", bg: "oklch(0.175 0 0)", card: "oklch(0.225 0 0)", suave: "oklch(0.275 0 0)", borde: "oklch(0.325 0 0)", tinta: "oklch(0.94 0 0)", gris: "oklch(0.68 0 0)", side: "oklch(0.125 0 0)", patron: "none"),
        "tinta": (nombre: "Tinta", bg: "oklch(0.985 0 0)", card: "#fff", suave: "oklch(0.955 0 0)", borde: "oklch(0.885 0 0)", tinta: "oklch(0.17 0 0)", gris: "oklch(0.46 0 0)", side: "oklch(0.16 0 0)", patron: "none"),
        "niebla": (nombre: "Niebla", bg: "oklch(0.955 0.004 250)", card: "#fff", suave: "oklch(0.945 0.005 250)", borde: "oklch(0.885 0.006 250)", tinta: "oklch(0.22 0.008 250)", gris: "oklch(0.50 0.008 250)", side: "oklch(0.30 0.012 250)", patron: "none"),
        "flor": (nombre: "Flor de chinola", bg: "oklch(0.97 0.02 310)", card: "#fff", suave: "oklch(0.965 0.028 310)", borde: "oklch(0.90 0.03 310)", tinta: "oklch(0.24 0.05 310)", gris: "oklch(0.48 0.05 312)", side: "oklch(0.34 0.11 308)", patron: "none"),
        "pulpa": (nombre: "Pulpa", bg: "oklch(0.975 0.03 78)", card: "#fff", suave: "oklch(0.965 0.04 78)", borde: "oklch(0.90 0.045 78)", tinta: "oklch(0.27 0.05 55)", gris: "oklch(0.49 0.05 60)", side: "oklch(0.44 0.13 55)", patron: "none"),
        "cascara": (nombre: "Cáscara", bg: "oklch(0.965 0.035 118)", card: "#fff", suave: "oklch(0.958 0.045 118)", borde: "oklch(0.89 0.05 118)", tinta: "oklch(0.24 0.05 135)", gris: "oklch(0.46 0.05 132)", side: "oklch(0.36 0.10 125)", patron: "none"),
        "arena": (nombre: "Arena", bg: "oklch(0.965 0.018 70)", card: "#fff", suave: "oklch(0.955 0.025 70)", borde: "oklch(0.89 0.028 70)", tinta: "oklch(0.26 0.03 60)", gris: "oklch(0.49 0.03 62)", side: "oklch(0.36 0.055 62)", patron: "none"),
        "coral": (nombre: "Coral", bg: "oklch(0.97 0.025 20)", card: "#fff", suave: "oklch(0.962 0.033 20)", borde: "oklch(0.90 0.035 20)", tinta: "oklch(0.26 0.05 20)", gris: "oklch(0.49 0.05 22)", side: "oklch(0.42 0.13 22)", patron: "none"),
        "indigo": (nombre: "Índigo", bg: "oklch(0.965 0.02 268)", card: "#fff", suave: "oklch(0.955 0.028 268)", borde: "oklch(0.89 0.03 268)", tinta: "oklch(0.23 0.05 268)", gris: "oklch(0.47 0.05 268)", side: "oklch(0.32 0.11 266)", patron: "none"),
        "salvia": (nombre: "Salvia", bg: "oklch(0.962 0.015 145)", card: "#fff", suave: "oklch(0.952 0.02 145)", borde: "oklch(0.885 0.022 145)", tinta: "oklch(0.24 0.028 150)", gris: "oklch(0.47 0.028 150)", side: "oklch(0.38 0.055 148)", patron: "none"),
        "pizarra": (nombre: "Pizarra", bg: "oklch(0.955 0.008 230)", card: "#fff", suave: "oklch(0.945 0.012 230)", borde: "oklch(0.88 0.014 230)", tinta: "oklch(0.23 0.02 232)", gris: "oklch(0.48 0.02 232)", side: "oklch(0.35 0.04 232)", patron: "none"),
        "papel": (nombre: "Papel", bg: "oklch(0.972 0.012 88)", card: "oklch(0.995 0.004 88)", suave: "oklch(0.958 0.016 88)", borde: "oklch(0.895 0.018 88)", tinta: "oklch(0.235 0.022 90)", gris: "oklch(0.47 0.022 90)", side: "oklch(0.31 0.035 90)", patron: "none"),
        "chinola_noche": (nombre: "Chinola de noche", bg: "oklch(0.185 0.022 155)", card: "oklch(0.235 0.026 155)", suave: "oklch(0.275 0.03 155)", borde: "oklch(0.325 0.032 155)", tinta: "oklch(0.95 0.02 95)", gris: "oklch(0.73 0.025 110)", side: "oklch(0.145 0.022 155)", patron: "none"),
        "ciruela": (nombre: "Ciruela", bg: "oklch(0.195 0.035 315)", card: "oklch(0.245 0.04 315)", suave: "oklch(0.285 0.045 315)", borde: "oklch(0.335 0.048 315)", tinta: "oklch(0.945 0.02 310)", gris: "oklch(0.73 0.03 312)", side: "oklch(0.155 0.035 315)", patron: "none"),
        "cafe_noche": (nombre: "Café", bg: "oklch(0.195 0.022 55)", card: "oklch(0.245 0.026 55)", suave: "oklch(0.285 0.03 55)", borde: "oklch(0.335 0.032 55)", tinta: "oklch(0.945 0.018 78)", gris: "oklch(0.73 0.022 70)", side: "oklch(0.155 0.022 55)", patron: "none"),
        "bosque": (nombre: "Bosque", bg: "oklch(0.175 0.028 145)", card: "oklch(0.225 0.032 145)", suave: "oklch(0.265 0.036 145)", borde: "oklch(0.315 0.038 145)", tinta: "oklch(0.945 0.025 130)", gris: "oklch(0.72 0.03 135)", side: "oklch(0.135 0.028 145)", patron: "none"),
        "tinta_azul": (nombre: "Tinta azul", bg: "oklch(0.185 0.035 258)", card: "oklch(0.235 0.04 258)", suave: "oklch(0.275 0.045 258)", borde: "oklch(0.325 0.048 258)", tinta: "oklch(0.945 0.02 255)", gris: "oklch(0.73 0.028 255)", side: "oklch(0.145 0.035 258)", patron: "none"),
        "brasa": (nombre: "Brasa", bg: "oklch(0.19 0.03 30)", card: "oklch(0.24 0.035 30)", suave: "oklch(0.28 0.04 30)", borde: "oklch(0.33 0.042 30)", tinta: "oklch(0.945 0.022 40)", gris: "oklch(0.73 0.028 35)", side: "oklch(0.15 0.03 30)", patron: "none")
    ]

    /// El acento de cada tema, cuando no es el amarillo de la marca.
    static let acentos: [String: String] = [
        "oceano": "oklch(0.66 0.15 245)",
        "menta": "oklch(0.72 0.14 172)",
        "cacao": "oklch(0.72 0.13 62)",
        "uva": "oklch(0.66 0.17 300)",
        "carbon": "oklch(0.80 0.02 250)",
        "medianoche": "oklch(0.74 0.12 258)",
        "claro": "oklch(0.62 0.13 155)",
        "jugo": "oklch(0.76 0.16 70)",
        "hoja": "oklch(0.66 0.16 148)",
        "sombrio": "oklch(0.82 0 0)",
        "tinta": "oklch(0.34 0 0)",
        "niebla": "oklch(0.58 0.03 250)",
        "flor": "oklch(0.62 0.19 308)",
        "pulpa": "oklch(0.72 0.17 58)",
        "cascara": "oklch(0.72 0.16 122)",
        "arena": "oklch(0.68 0.10 68)",
        "coral": "oklch(0.68 0.17 24)",
        "indigo": "oklch(0.62 0.17 266)",
        "salvia": "oklch(0.64 0.09 148)",
        "pizarra": "oklch(0.56 0.06 232)",
        "papel": "oklch(0.60 0.10 92)",
        "ciruela": "oklch(0.74 0.15 312)",
        "cafe_noche": "oklch(0.78 0.13 68)",
        "bosque": "oklch(0.74 0.16 135)",
        "tinta_azul": "oklch(0.74 0.14 255)",
        "brasa": "oklch(0.74 0.16 38)"
    ]

    /// Cuál es el icono de fábrica de la app.
    static let iconoPrincipal = "1d"

    /// Los nueve, con su nombre y por qué es distinto. El dibujo NO va
    /// aquí: el teléfono enseña el de verdad —`Chinola-1e`, dentro del
    /// paquete—, que es el que se va a instalar. Una copia rasterizada
    /// podría parecerse y no ser el mismo.
    static let iconosDeLaApp: [(id: String, nombre: String, nota: String)] = [
        (id: "1a", nombre: "Chino", nota: "El personaje es la marca. Cálido, se recuerda."),
        (id: "1c", nombre: "Monograma C", nota: "La C de Chinola con su semilla. Más de fintech."),
        (id: "1d", nombre: "Tu logo actual", nota: "El punto de la marca, sin cambios. El más sobrio."),
        (id: "1e", nombre: "Moneda", nota: "Moneda con hoja: dice «dinero» sin palabras."),
        (id: "3a", nombre: "Chino, protagonista", nota: "Llena el icono. Ojos con brillo, cejas seguras, risa."),
        (id: "3b", nombre: "Chino guiña", nota: "Asoma desde abajo y te guiña. Pícaro, muy dominicano."),
        (id: "3c", nombre: "La C que mira", nota: "La semilla se vuelve un ojo. Serio y con guiño a la vez."),
        (id: "3d", nombre: "C de oro", nota: "Amarillo sobre verde noche con relieve. El más imponente."),
        (id: "3h", nombre: "Pila de monedas", nota: "Tres monedas en relieve: ahorro que crece. Muy premium.")
    ]

    /// Qué puede hacer cada papel de una libreta compartida. Es lo que
    /// se lee debajo de cada opción al invitar a alguien.
    static let pistaDelRol: [String: String] = [
        "Editor": "Puede anotar y cambiarlo todo",
        "Registrador": "Solo puede anotar movimientos",
        "Lector": "Solo mira, no toca nada"
    ]

    /// Qué oscuro le toca a cada claro. Sirve para las dos direcciones:
    /// al pasar a noche y al volver.
    static let oscuroDe: [String: String] = [
        "sistema": "sistema_noche",
        "chinola": "chinola_noche",
        "semillas": "noche_semillas",
        "hoja": "noche",
        "claro": "carbon",
        "tinta": "sombrio",
        "niebla": "carbon",
        "oceano": "medianoche",
        "menta": "bosque",
        "cacao": "cafe_noche",
        "uva": "ciruela",
        "jugo": "brasa",
        "flor": "ciruela",
        "pulpa": "cafe_noche",
        "cascara": "bosque",
        "arena": "cafe_noche",
        "coral": "brasa",
        "indigo": "tinta_azul",
        "salvia": "bosque",
        "pizarra": "tinta_azul",
        "papel": "cafe_noche"
    ]

    /// Y al revés. Un oscuro puede ser la pareja de varios claros; se
    /// queda con el PRIMERO, que es como lo hace la web al construir su
    /// mapa: la última entrada de una clave repetida gana allí, así que
    /// aquí se invierte el orden para que gane la misma.
    static let claroDe: [String: String] = [
        "cafe_noche": "papel",
        "tinta_azul": "pizarra",
        "bosque": "salvia",
        "brasa": "coral",
        "ciruela": "flor",
        "medianoche": "oceano",
        "carbon": "niebla",
        "sombrio": "tinta",
        "noche": "hoja",
        "noche_semillas": "semillas",
        "chinola_noche": "chinola",
        "sistema_noche": "sistema"
    ]

    /// Cómo se dibuja cada tipo de tarjeta del panel. Sacado de lo que la
    /// web dibuja de verdad (`test/panel-oro.json`), no del catálogo.
    struct TarjetaDePanel {
        var tipo: String; var titulo: String; var clase: String
        var periodo: String; var puedeChica: Bool
    }
    static let tarjetasDePanel: [String: TarjetaDePanel] = [
        "kpi-balance": TarjetaDePanel(tipo: "kpi-balance", titulo: "Balance del mes", clase: "cifra", periodo: "", puedeChica: true),
        "kpi-ingresos": TarjetaDePanel(tipo: "kpi-ingresos", titulo: "Ingresos del mes", clase: "cifra", periodo: "", puedeChica: true),
        "kpi-gastos": TarjetaDePanel(tipo: "kpi-gastos", titulo: "Gastos del mes", clase: "cifra", periodo: "", puedeChica: true),
        "kpi-deuda": TarjetaDePanel(tipo: "kpi-deuda", titulo: "Deuda total", clase: "cifra", periodo: "", puedeChica: true),
        "kpi-patrimonio": TarjetaDePanel(tipo: "kpi-patrimonio", titulo: "Patrimonio", clase: "cifra", periodo: "", puedeChica: true),
        "texto-consejo": TarjetaDePanel(tipo: "texto-consejo", titulo: "Consejo de Chino", clase: "texto", periodo: "", puedeChica: true),
        "barras-categorias": TarjetaDePanel(tipo: "barras-categorias", titulo: "Gastos por categoría", clase: "barras", periodo: "", puedeChica: false),
        "columnas-tendencia": TarjetaDePanel(tipo: "columnas-tendencia", titulo: "Ingresos y gastos", clase: "columnas", periodo: "6 meses", puedeChica: false),
        "dona-mezcla": TarjetaDePanel(tipo: "dona-mezcla", titulo: "Mezcla de gastos", clase: "dona", periodo: "", puedeChica: false),
        "serie-tiempo": TarjetaDePanel(tipo: "serie-tiempo", titulo: "Evolución en el tiempo", clase: "serie", periodo: "", puedeChica: false),
        "lista-recientes": TarjetaDePanel(tipo: "lista-recientes", titulo: "Últimos movimientos", clase: "lista", periodo: "", puedeChica: false),
        "lista-recordatorios": TarjetaDePanel(tipo: "lista-recordatorios", titulo: "Recordatorios de pago", clase: "lista", periodo: "", puedeChica: false),
        "lista-metas": TarjetaDePanel(tipo: "lista-metas", titulo: "Avance de metas", clase: "lista", periodo: "", puedeChica: false),
        "kpi-ahorro": TarjetaDePanel(tipo: "kpi-ahorro", titulo: "Ahorro del mes", clase: "cifra", periodo: "", puedeChica: true),
        "kpi-diario": TarjetaDePanel(tipo: "kpi-diario", titulo: "Gasto por día", clase: "cifra", periodo: "", puedeChica: true),
        "kpi-vs-mes": TarjetaDePanel(tipo: "kpi-vs-mes", titulo: "Frente al mes pasado", clase: "cifra", periodo: "", puedeChica: true),
        "kpi-presupuesto": TarjetaDePanel(tipo: "kpi-presupuesto", titulo: "Presupuesto usado", clase: "cifra", periodo: "", puedeChica: true),
        "kpi-cuotas": TarjetaDePanel(tipo: "kpi-cuotas", titulo: "Cuotas fijas", clase: "cifra", periodo: "", puedeChica: true),
        "kpi-racha": TarjetaDePanel(tipo: "kpi-racha", titulo: "Racha anotando", clase: "cifra", periodo: "", puedeChica: true),
        "barras-presupuesto": TarjetaDePanel(tipo: "barras-presupuesto", titulo: "Presupuesto por categoría", clase: "barras", periodo: "", puedeChica: false),
        "barras-medios": TarjetaDePanel(tipo: "barras-medios", titulo: "Gastos por medio de pago", clase: "barras", periodo: "", puedeChica: false),
        "lista-top": TarjetaDePanel(tipo: "lista-top", titulo: "Mayores gastos del mes", clase: "lista", periodo: "", puedeChica: false),
        "lista-cuentas": TarjetaDePanel(tipo: "lista-cuentas", titulo: "Saldo por cuenta", clase: "lista", periodo: "", puedeChica: false),
        "lista-tarjetas": TarjetaDePanel(tipo: "lista-tarjetas", titulo: "Cupo de las tarjetas", clase: "lista", periodo: "", puedeChica: false),
        "kpi-queda-dia": TarjetaDePanel(tipo: "kpi-queda-dia", titulo: "Te queda por día", clase: "cifra", periodo: "", puedeChica: true),
        "kpi-cierre": TarjetaDePanel(tipo: "kpi-cierre", titulo: "A este ritmo cierras en", clase: "cifra", periodo: "", puedeChica: true),
        "kpi-proximo": TarjetaDePanel(tipo: "kpi-proximo", titulo: "Próximo pago", clase: "cifra", periodo: "", puedeChica: true),
        "kpi-sin-gastar": TarjetaDePanel(tipo: "kpi-sin-gastar", titulo: "Días sin gastar", clase: "cifra", periodo: "", puedeChica: true),
        "kpi-comprometido": TarjetaDePanel(tipo: "kpi-comprometido", titulo: "Fijo frente a variable", clase: "cifra", periodo: "", puedeChica: true),
        "kpi-ahorro-ano": TarjetaDePanel(tipo: "kpi-ahorro-ano", titulo: "Ahorrado este año", clase: "cifra", periodo: "", puedeChica: true),
        "kpi-ano-pasado": TarjetaDePanel(tipo: "kpi-ano-pasado", titulo: "Frente al año pasado", clase: "cifra", periodo: "", puedeChica: true),
        "lista-suscripciones": TarjetaDePanel(tipo: "lista-suscripciones", titulo: "Lo que se repite cada mes", clase: "lista", periodo: "", puedeChica: false)
    ]

    /// El panel de fábrica: lo que se ve recién instalada la app.
    struct EntradaDePanel { var id: String; var tipo: String; var ancho: Int }
    static let panelDeFabrica: [EntradaDePanel] = [
        EntradaDePanel(id: "w1", tipo: "kpi-ingresos", ancho: 1),
        EntradaDePanel(id: "w2", tipo: "kpi-gastos", ancho: 1),
        EntradaDePanel(id: "w3", tipo: "kpi-deuda", ancho: 1),
        EntradaDePanel(id: "w4", tipo: "kpi-patrimonio", ancho: 1),
        EntradaDePanel(id: "w0", tipo: "serie-tiempo", ancho: 4),
        EntradaDePanel(id: "w6", tipo: "columnas-tendencia", ancho: 2),
        EntradaDePanel(id: "w5", tipo: "barras-categorias", ancho: 2),
        EntradaDePanel(id: "w7", tipo: "lista-recientes", ancho: 2),
        EntradaDePanel(id: "w8", tipo: "lista-recordatorios", ancho: 2),
        EntradaDePanel(id: "w9", tipo: "texto-consejo", ancho: 2),
        EntradaDePanel(id: "w10", tipo: "dona-mezcla", ancho: 2),
        EntradaDePanel(id: "w11", tipo: "lista-suscripciones", ancho: 2)
    ]

    /// Qué dibujo lleva una libreta según de qué es, cuando no trae uno
    /// propio. Es lo que decide la pastilla de arriba del Resumen.
    static let iconoPorTipoDeLibreta: [String: String] = [
        "Personal": "casa",
        "Familiar": "gente",
        "Negocio": "maletin",
        "Proyecto": "estrella"
    ]
}
