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
        "candado": "M6 11h12v10H6zM9 11V8a3 3 0 0 1 6 0v3M12 15v3"
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
        "moneda": "Efectivo",
        "cripto": "Cripto",
        "candado": "Fondo bloqueado"
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
        "monitor": "M3 4h18v12H3zM8 20h8M12 16v4"
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
    static let coloresDeCabecera: [(id: String, nombre: String, css: String)] = [
        (id: "chinola", nombre: "Chinola", css: "linear-gradient(150deg, #f7c948, #ec9a2e 55%, #3f9d54)"),
        (id: "mango", nombre: "Mango", css: "linear-gradient(150deg, #f9c04b, #ef8a2c)"),
        (id: "durazno", nombre: "Durazno", css: "linear-gradient(150deg, #f8b370, #f4845f)"),
        (id: "lima", nombre: "Lima", css: "linear-gradient(150deg, #cfe95f, #85bb3e)"),
        (id: "pino", nombre: "Pino", css: "linear-gradient(150deg, #33a565, #14683b)"),
        (id: "bosque", nombre: "Bosque", css: "linear-gradient(150deg, #2c8f5a, #15412c)"),
        (id: "oceano", nombre: "Oceano", css: "linear-gradient(150deg, #3f8ad0, #1f4f89)"),
        (id: "medianoche", nombre: "Medianoche", css: "linear-gradient(150deg, #3d4f96, #1f2550)"),
        (id: "ciruela", nombre: "Ciruela", css: "linear-gradient(150deg, #834fa6, #47256e)"),
        (id: "uva", nombre: "Uva", css: "linear-gradient(150deg, #9a5cc7, #5c3096)"),
        (id: "coral", nombre: "Coral", css: "linear-gradient(150deg, #ea6a52, #c0343c)"),
        (id: "cacao", nombre: "Cacao", css: "linear-gradient(150deg, #7d4b30, #472a1b)"),
        (id: "carbon", nombre: "Carbon", css: "linear-gradient(150deg, #2a2e2b, #141714)"),
        (id: "noche", nombre: "Noche", css: "linear-gradient(150deg, #27313b, #12181e)")
    ]
}
