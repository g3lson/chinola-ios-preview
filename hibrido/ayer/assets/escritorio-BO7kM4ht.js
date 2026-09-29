var Yt=Object.defineProperty;var Wt=(j,a,e)=>a in j?Yt(j,a,{enumerable:!0,configurable:!0,writable:!0,value:e}):j[a]=e;var Xe=(j,a,e)=>Wt(j,typeof a!="symbol"?a+"":a,e);import{D as Jt,c as Qt}from"./dc-CfeAgKAK.js";import{n as Xt,p as Ge,U as Ze,l as kt,t as ue,u as wt,w as Zt,y as Kt,z as ke,K as ea,A as ta,B as E,C as ze,E as Ct,H as aa,F as oa,G as ra,L as ia,h as na,$ as sa}from"./app-nYXoC2_m.js";import{i as St,a as la,b as da,c as Ne}from"./dinero-WA3fkxXP.js";import"./client-B4bZkblM.js";const ca={moneda:"DOP",mostrarCentavos:!1},Mt="chinola-datos-v3",jt="chinola-sesion-v3",Ke="chinola-nube-v3",zt=["enero","febrero","marzo","abril","mayo","junio","julio","agosto","septiembre","octubre","noviembre","diciembre"],At=["ene","feb","mar","abr","may","jun","jul","ago","sep","oct","nov","dic"],pa=["Ingreso","Gasto Fijo","Gasto Variable","Ahorro"],re="oklch(0.852 0.147 93)",F="var(--positivo)",O="var(--negativo)",Se="var(--ahorro)",ee="var(--aviso)",C=["oklch(0.42 0.10 155)","oklch(0.46 0.11 255)","oklch(0.56 0.16 30)","oklch(0.50 0.14 300)","oklch(0.60 0.13 95)","oklch(0.46 0.11 200)","oklch(0.32 0.03 155)"],ua="radial-gradient(oklch(0.42 0.06 120 / 0.16) 22%, transparent 23%), radial-gradient(oklch(0.42 0.06 120 / 0.12) 22%, transparent 23%)",ie={oceano:{nombre:"Océano",bg:"oklch(0.97 0.02 240)",card:"#fff",suave:"oklch(0.96 0.03 240)",borde:"oklch(0.90 0.03 240)",tinta:"oklch(0.24 0.04 250)",gris:"oklch(0.48 0.04 250)",side:"oklch(0.32 0.09 250)",patron:"none"},menta:{nombre:"Menta",bg:"oklch(0.97 0.03 175)",card:"#fff",suave:"oklch(0.96 0.04 175)",borde:"oklch(0.89 0.04 175)",tinta:"oklch(0.24 0.04 180)",gris:"oklch(0.46 0.04 180)",side:"oklch(0.34 0.08 178)",patron:"none"},cacao:{nombre:"Cacao",bg:"oklch(0.96 0.02 60)",card:"#fff",suave:"oklch(0.96 0.03 60)",borde:"oklch(0.89 0.03 60)",tinta:"oklch(0.26 0.04 50)",gris:"oklch(0.47 0.04 55)",side:"oklch(0.33 0.06 50)",patron:"none"},uva:{nombre:"Uva",bg:"oklch(0.97 0.02 300)",card:"#fff",suave:"oklch(0.96 0.03 300)",borde:"oklch(0.90 0.03 300)",tinta:"oklch(0.25 0.05 305)",gris:"oklch(0.47 0.05 305)",side:"oklch(0.33 0.10 300)",patron:"none"},carbon:{nombre:"Carbón",bg:"oklch(0.21 0.005 250)",card:"oklch(0.26 0.006 250)",suave:"oklch(0.30 0.008 250)",borde:"oklch(0.35 0.01 250)",tinta:"oklch(0.94 0.005 250)",gris:"oklch(0.72 0.01 250)",side:"oklch(0.17 0.005 250)",patron:"none"},medianoche:{nombre:"Medianoche",bg:"oklch(0.20 0.03 260)",card:"oklch(0.25 0.035 260)",suave:"oklch(0.29 0.04 260)",borde:"oklch(0.34 0.04 260)",tinta:"oklch(0.94 0.02 250)",gris:"oklch(0.74 0.03 250)",side:"oklch(0.16 0.03 262)",patron:"none"},sistema:{nombre:"Sistema claro",bg:"oklch(0.957 0.004 286)",card:"#fff",suave:"oklch(0.925 0.005 286)",borde:"oklch(0.87 0.004 286)",tinta:"oklch(0.22 0.004 286)",gris:"oklch(0.53 0.005 286)",side:"oklch(0.34 0.08 155)",patron:"none"},sistema_noche:{nombre:"Sistema oscuro",bg:"oklch(0 0 0)",card:"oklch(0.22 0.004 286)",suave:"oklch(0.29 0.004 286)",borde:"oklch(0.36 0.004 286)",tinta:"oklch(0.957 0.004 286)",gris:"oklch(0.68 0.008 286)",side:"oklch(0.20 0.05 155)",patron:"none"},sombrio:{nombre:"Sombrío",bg:"oklch(0.175 0 0)",card:"oklch(0.225 0 0)",suave:"oklch(0.275 0 0)",borde:"oklch(0.325 0 0)",tinta:"oklch(0.94 0 0)",gris:"oklch(0.68 0 0)",side:"oklch(0.125 0 0)",patron:"none"},tinta:{nombre:"Tinta",bg:"oklch(0.985 0 0)",card:"#fff",suave:"oklch(0.955 0 0)",borde:"oklch(0.885 0 0)",tinta:"oklch(0.17 0 0)",gris:"oklch(0.46 0 0)",side:"oklch(0.16 0 0)",patron:"none"},niebla:{nombre:"Niebla",bg:"oklch(0.955 0.004 250)",card:"#fff",suave:"oklch(0.945 0.005 250)",borde:"oklch(0.885 0.006 250)",tinta:"oklch(0.22 0.008 250)",gris:"oklch(0.50 0.008 250)",side:"oklch(0.30 0.012 250)",patron:"none"},flor:{nombre:"Flor de chinola",bg:"oklch(0.97 0.02 310)",card:"#fff",suave:"oklch(0.965 0.028 310)",borde:"oklch(0.90 0.03 310)",tinta:"oklch(0.24 0.05 310)",gris:"oklch(0.48 0.05 312)",side:"oklch(0.34 0.11 308)",patron:"none"},pulpa:{nombre:"Pulpa",bg:"oklch(0.975 0.03 78)",card:"#fff",suave:"oklch(0.965 0.04 78)",borde:"oklch(0.90 0.045 78)",tinta:"oklch(0.27 0.05 55)",gris:"oklch(0.49 0.05 60)",side:"oklch(0.44 0.13 55)",patron:"none"},cascara:{nombre:"Cáscara",bg:"oklch(0.965 0.035 118)",card:"#fff",suave:"oklch(0.958 0.045 118)",borde:"oklch(0.89 0.05 118)",tinta:"oklch(0.24 0.05 135)",gris:"oklch(0.46 0.05 132)",side:"oklch(0.36 0.10 125)",patron:"none"},arena:{nombre:"Arena",bg:"oklch(0.965 0.018 70)",card:"#fff",suave:"oklch(0.955 0.025 70)",borde:"oklch(0.89 0.028 70)",tinta:"oklch(0.26 0.03 60)",gris:"oklch(0.49 0.03 62)",side:"oklch(0.36 0.055 62)",patron:"none"},coral:{nombre:"Coral",bg:"oklch(0.97 0.025 20)",card:"#fff",suave:"oklch(0.962 0.033 20)",borde:"oklch(0.90 0.035 20)",tinta:"oklch(0.26 0.05 20)",gris:"oklch(0.49 0.05 22)",side:"oklch(0.42 0.13 22)",patron:"none"},indigo:{nombre:"Índigo",bg:"oklch(0.965 0.02 268)",card:"#fff",suave:"oklch(0.955 0.028 268)",borde:"oklch(0.89 0.03 268)",tinta:"oklch(0.23 0.05 268)",gris:"oklch(0.47 0.05 268)",side:"oklch(0.32 0.11 266)",patron:"none"},salvia:{nombre:"Salvia",bg:"oklch(0.962 0.015 145)",card:"#fff",suave:"oklch(0.952 0.02 145)",borde:"oklch(0.885 0.022 145)",tinta:"oklch(0.24 0.028 150)",gris:"oklch(0.47 0.028 150)",side:"oklch(0.38 0.055 148)",patron:"none"},pizarra:{nombre:"Pizarra",bg:"oklch(0.955 0.008 230)",card:"#fff",suave:"oklch(0.945 0.012 230)",borde:"oklch(0.88 0.014 230)",tinta:"oklch(0.23 0.02 232)",gris:"oklch(0.48 0.02 232)",side:"oklch(0.35 0.04 232)",patron:"none"},papel:{nombre:"Papel",bg:"oklch(0.972 0.012 88)",card:"oklch(0.995 0.004 88)",suave:"oklch(0.958 0.016 88)",borde:"oklch(0.895 0.018 88)",tinta:"oklch(0.235 0.022 90)",gris:"oklch(0.47 0.022 90)",side:"oklch(0.31 0.035 90)",patron:"none"},chinola_noche:{nombre:"Chinola de noche",bg:"oklch(0.185 0.022 155)",card:"oklch(0.235 0.026 155)",suave:"oklch(0.275 0.03 155)",borde:"oklch(0.325 0.032 155)",tinta:"oklch(0.95 0.02 95)",gris:"oklch(0.73 0.025 110)",side:"oklch(0.145 0.022 155)",patron:"none"},ciruela:{nombre:"Ciruela",bg:"oklch(0.195 0.035 315)",card:"oklch(0.245 0.04 315)",suave:"oklch(0.285 0.045 315)",borde:"oklch(0.335 0.048 315)",tinta:"oklch(0.945 0.02 310)",gris:"oklch(0.73 0.03 312)",side:"oklch(0.155 0.035 315)",patron:"none"},cafe_noche:{nombre:"Café",bg:"oklch(0.195 0.022 55)",card:"oklch(0.245 0.026 55)",suave:"oklch(0.285 0.03 55)",borde:"oklch(0.335 0.032 55)",tinta:"oklch(0.945 0.018 78)",gris:"oklch(0.73 0.022 70)",side:"oklch(0.155 0.022 55)",patron:"none"},bosque:{nombre:"Bosque",bg:"oklch(0.175 0.028 145)",card:"oklch(0.225 0.032 145)",suave:"oklch(0.265 0.036 145)",borde:"oklch(0.315 0.038 145)",tinta:"oklch(0.945 0.025 130)",gris:"oklch(0.72 0.03 135)",side:"oklch(0.135 0.028 145)",patron:"none"},tinta_azul:{nombre:"Tinta azul",bg:"oklch(0.185 0.035 258)",card:"oklch(0.235 0.04 258)",suave:"oklch(0.275 0.045 258)",borde:"oklch(0.325 0.048 258)",tinta:"oklch(0.945 0.02 255)",gris:"oklch(0.73 0.028 255)",side:"oklch(0.145 0.035 258)",patron:"none"},brasa:{nombre:"Brasa",bg:"oklch(0.19 0.03 30)",card:"oklch(0.24 0.035 30)",suave:"oklch(0.28 0.04 30)",borde:"oklch(0.33 0.042 30)",tinta:"oklch(0.945 0.022 40)",gris:"oklch(0.73 0.028 35)",side:"oklch(0.15 0.03 30)",patron:"none"},claro:{nombre:"Claro",bg:"oklch(0.995 0 0)",card:"#fff",suave:"oklch(0.975 0.002 95)",borde:"oklch(0.925 0.003 95)",tinta:"oklch(0.22 0.01 155)",gris:"oklch(0.52 0.01 155)",side:"oklch(0.34 0.01 155)",patron:"none"},chinola:{nombre:"Chinola",bg:"oklch(0.975 0.015 95)",card:"#fff",suave:"oklch(0.97 0.02 95)",borde:"oklch(0.91 0.02 95)",tinta:"oklch(0.24 0.03 155)",gris:"oklch(0.48 0.03 155)",side:"oklch(0.255 0.038 156)",patron:"none"},semillas:{nombre:"Semillas",bg:"oklch(0.97 0.03 95)",card:"#fff",suave:"oklch(0.97 0.03 95)",borde:"oklch(0.90 0.03 95)",tinta:"oklch(0.24 0.04 130)",gris:"oklch(0.46 0.04 130)",side:"oklch(0.30 0.08 140)",patron:ua+";background-size:26px 26px, 26px 26px;background-position:0 0, 13px 13px"},jugo:{nombre:"Jugo",bg:"oklch(0.97 0.04 88)",card:"#fff",suave:"oklch(0.97 0.05 88)",borde:"oklch(0.90 0.05 88)",tinta:"oklch(0.26 0.05 70)",gris:"oklch(0.48 0.05 75)",side:"oklch(0.42 0.12 68)",patron:"none"},hoja:{nombre:"Hoja",bg:"oklch(0.96 0.03 150)",card:"#fff",suave:"oklch(0.96 0.03 150)",borde:"oklch(0.89 0.04 150)",tinta:"oklch(0.22 0.05 155)",gris:"oklch(0.44 0.05 155)",side:"oklch(0.34 0.09 152)",patron:"none"},noche:{nombre:"Noche",bg:"oklch(0.20 0.02 155)",card:"oklch(0.25 0.025 155)",suave:"oklch(0.29 0.03 155)",borde:"oklch(0.34 0.03 155)",tinta:"oklch(0.94 0.02 95)",gris:"oklch(0.72 0.02 110)",side:"oklch(0.16 0.02 155)",patron:"none"},noche_semillas:{nombre:"Noche + semillas",bg:"oklch(0.19 0.02 150)",card:"oklch(0.24 0.025 150)",suave:"oklch(0.28 0.03 150)",borde:"oklch(0.33 0.03 150)",tinta:"oklch(0.94 0.03 95)",gris:"oklch(0.74 0.03 110)",side:"oklch(0.15 0.02 150)",patron:"radial-gradient(oklch(0.88 0.14 95 / 0.10) 22%, transparent 23%), radial-gradient(oklch(0.88 0.14 95 / 0.07) 22%, transparent 23%);background-size:26px 26px, 26px 26px;background-position:0 0, 13px 13px"}},ne={auto:{nombre:"Automático",anim:"flota 5s ease-in-out infinite",ojo:10,bocaW:16,bocaH:9,bocaR:"0 0 12px 12px"},fuerte:{nombre:"Chino fuerte",anim:"brinca 1.8s ease-in-out infinite",ojo:8,bocaW:18,bocaH:7,bocaR:"4px",pesas:!0,frase:"Esa deuda cae este mes. ¡Dale!"},estudiosa:{nombre:"Chino estudioso",anim:"none",ojo:9,bocaW:12,bocaH:6,bocaR:"4px",lentes:!0,frase:"Revisemos los números con calma."},rota:{nombre:"Chino roto",anim:"none",ojo:5,bocaW:16,bocaH:5,bocaR:"4px",rota:!0,frase:"Se me salen las semillas con estos gastos."},jugo:{nombre:"Chino jugo",anim:"flota 6s ease-in-out infinite",ojo:9,bocaW:14,bocaH:8,bocaR:"0 0 12px 12px",jugo:!0,vaso:!0,frase:"Mes relajado: hasta me volví jugo."},fiesta:{nombre:"Chino fiesta",anim:"brinca 1.4s ease-in-out infinite",ojo:11,bocaW:22,bocaH:13,bocaR:"0 0 20px 20px",frase:"¡Meta cumplida! Eso se celebra."}},we={casa:["Vivienda","M3 11l9-7 9 7v9a1 1 0 0 1-1 1h-5v-6H9v6H4a1 1 0 0 1-1-1z"],carrito:["Compras","M3 4h2l2 11h12M7 8h14l-2 7H8M8 19a1 1 0 1 0 2 0 1 1 0 1 0-2 0M16 19a1 1 0 1 0 2 0 1 1 0 1 0-2 0"],comida:["Comida","M6 3v8a3 3 0 0 0 6 0V3M9 11v10M17 3c-2 2-2 6 0 8v10"],cafe:["Café","M4 8h13v5a4 4 0 0 1-4 4H8a4 4 0 0 1-4-4zM17 9h2a2 2 0 0 1 0 4h-2M4 21h13"],rayo:["Servicios","M13 2 4 14h6l-1 8 9-12h-6z"],wifi:["Internet","M4 8a14 14 0 0 1 16 0M7 12a9 9 0 0 1 10 0M10 16a4 4 0 0 1 4 0M12 20h.01"],auto:["Transporte","M4 16v-4l2-5h12l2 5v4M4 16h16M7 19a1 1 0 1 0 2 0M15 19a1 1 0 1 0 2 0"],gasolina:["Combustible","M5 21V5a2 2 0 0 1 2-2h5v18M5 12h7M14 8h3a2 2 0 0 1 2 2v7a2 2 0 0 0 2 2"],birrete:["Educación","M2 9l10-4 10 4-10 4zM6 11v5c0 2 3 3 6 3s6-1 6-3v-5"],libro:["Libros","M4 5h7v14H4zM13 5h7v14h-7z"],salud:["Salud","M12 7v10M7 12h10M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18"],iglesia:["Donaciones","M12 3v6M9 6h6M6 21V11l6-4 6 4v10z"],regalo:["Regalos","M3 9h18v3H3zM4 12v9h16v-9M12 9v12M8 9a2 2 0 1 1 4-2 2 2 0 1 1 4 2"],cine:["Entretenimiento","M3 6h18v10H3zM8 20h8M8 6v10M16 6v10"],musica:["Música","M9 18V6l10-2v12M9 18a3 3 0 1 1-3-3 3 3 0 0 1 3 3M19 16a2 2 0 1 1-2-2 2 2 0 0 1 2 2"],tarjeta:["Deudas","M2 6h20v12H2zM2 10h20M6 15h4"],usuario:["Personal","M12 11a4 4 0 1 0 0-8 4 4 0 0 0 0 8M4 21a8 8 0 0 1 16 0"],familia:["Familia","M8 10a3 3 0 1 0 0-6 3 3 0 0 0 0 6M17 11a2.5 2.5 0 1 0 0-5 2.5 2.5 0 0 0 0 5M2 20a6 6 0 0 1 12 0M15 20a5 5 0 0 1 7-4"],hucha:["Ahorro","M4 13a6 6 0 0 1 6-6h4a6 6 0 0 1 6 6v3H4zM7 18v2M17 18v2M16 11h1"],grafico:["Inversión","M4 20V10M10 20V4M16 20v-7M22 20H2"],maleta:["Viajes","M4 8h16v12H4zM9 8V5h6v3M4 14h16"],avion:["Vuelos","M2 13l20-6-8 14-2-5z"],mascota:["Mascotas","M6 9a2 2 0 1 0 0-4 2 2 0 0 0 0 4M18 9a2 2 0 1 0 0-4 2 2 0 0 0 0 4M9 20a3 3 0 0 1-3-3c0-2 2-3 3-5h6c1 2 3 3 3 5a3 3 0 0 1-3 3z"],ropa:["Ropa","M9 4l3 2 3-2 5 4-3 3v9H7v-9L4 8z"],gym:["Gimnasio","M4 9v6M20 9v6M7 7v10M17 7v10M7 12h10"],herramienta:["Hogar y arreglos","M14 4a4 4 0 0 1 6 6l-9 9-4 1 1-4z"],telefono:["Teléfono","M7 3h10v18H7zM10 19h4"],puntos:["Otros","M6 12h.01M12 12h.01M18 12h.01"],alquiler:["Alquiler","M4 21V9l8-6 8 6v12M9 21v-6h6v6M14 12h.01"],llave:["Hipoteca","M14 7a4 4 0 1 1-3.5 5.9L4 19v-3h3v-3h3l.5-1A4 4 0 0 1 14 7"],sofa:["Muebles","M4 11V8a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v3M2 12a2 2 0 0 1 4 0v5h12v-5a2 2 0 0 1 4 0v7H2z"],bombilla:["Luz","M9 18h6M10 21h4M12 3a6 6 0 0 1 4 10.5V17H8v-3.5A6 6 0 0 1 12 3"],agua:["Agua","M12 3s6 6.5 6 11a6 6 0 0 1-12 0c0-4.5 6-11 6-11"],basura:["Basura","M4 7h16M9 7V4h6v3M6 7l1 14h10l1-14M10 11v6M14 11v6"],bus:["Transporte público","M4 6h16v9H4zM4 15v3h2v-3M18 15v3h2v-3M7 9h10M6 19a1 1 0 1 0 2 0M16 19a1 1 0 1 0 2 0"],taxi:["Taxi","M5 16v-4l2-5h10l2 5v4M5 16h14M9 7V5h6v2M7 19a1 1 0 1 0 2 0M15 19a1 1 0 1 0 2 0"],moto:["Motor","M5 18a3 3 0 1 0 0-6 3 3 0 0 0 0 6M19 18a3 3 0 1 0 0-6 3 3 0 0 0 0 6M8 15h5l3-6h2M11 9h4"],bici:["Bicicleta","M6 19a3 3 0 1 0 0-6 3 3 0 0 0 0 6M18 19a3 3 0 1 0 0-6 3 3 0 0 0 0 6M9 16l3-8h3M8 8h4"],parking:["Parqueo","M8 18V6h4a3 3 0 0 1 0 6H8M4 3h16v18H4z"],taller:["Taller","M3 18h18M6 18V9l6-4 6 4v9M9 18v-4h6v4"],peaje:["Peaje","M5 20V8h6v12M13 20V4h6v16M8 12h.01M16 8h.01"],supermercado:["Supermercado","M3 9l2-5h14l2 5M3 9h18v11H3zM9 13h6"],panaderia:["Panadería","M4 12a5 5 0 0 1 5-5h6a5 5 0 0 1 0 10H9a5 5 0 0 1-5-5M9 9v6M13 9v6"],restaurante:["Restaurante","M4 4v6a3 3 0 0 0 6 0V4M7 10v10M14 4h5a1 1 0 0 1 1 1v6h-6z"],pizza:["Comida rápida","M12 3 4 20l16-5zM11 11h.01M13 15h.01"],bebida:["Bebidas","M6 4h12l-2 6H8zM8 10l1 10h6l1-10M10 14h4"],farmacia:["Farmacia","M12 6v12M6 12h12M6 6h12v12H6z"],medico:["Médico","M8 3h8v4h4v10H4V7h4zM12 10v4M10 12h4"],dentista:["Dentista","M8 3c2 0 2 2 4 2s2-2 4-2 3 3 2 8c-1 4-2 8-3 8s-1-4-3-4-2 4-3 4-2-4-3-8C5 6 6 3 8 3"],gafas:["Óptica","M6 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6M18 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6M9 12h6"],peluqueria:["Belleza","M6 4l12 12M18 4 6 16M6 20a2 2 0 1 0 0-4 2 2 0 0 0 0 4M18 20a2 2 0 1 0 0-4 2 2 0 0 0 0 4"],cuna:["Bebé","M4 10v9M20 10v9M4 14h16M6 10a6 6 0 0 1 12 0"],colegio:["Colegio","M12 3l8 4v3H4V7zM6 10v11M18 10v11M10 21v-6h4v6"],laptop:["Tecnología","M4 6h16v9H4zM2 18h20M9 18h6"],suscripcion:["Suscripciones","M4 6h16v12H4zM8 10h8M8 14h5M17 14h.01"],juego:["Videojuegos","M7 12h4M9 10v4M15 12h.01M17 14h.01M4 8h16v8H4z"],deporte:["Deporte","M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18M12 3v18M3 12h18"],playa:["Playa","M12 12a7 7 0 0 1 10-4c-2 5-6 5-10 4M12 12v9M4 21h16"],hotel:["Hotel","M4 20V6h16v14M8 10h.01M8 14h.01M12 10h.01M12 14h.01M16 10h.01M16 14h.01"],concierto:["Eventos","M4 20V10l7-5v15M11 12h9v8M15 16h.01"],iglesia2:["Iglesia","M12 2v5M9 5h6M5 21V10l7-4 7 4v11M10 21v-6h4v6"],mano:["Ayuda familiar","M8 12V5a2 2 0 0 1 4 0v6M12 11V4a2 2 0 0 1 4 0v8M16 9a2 2 0 0 1 4 0v6a6 6 0 0 1-6 6H10a6 6 0 0 1-6-6v-3a2 2 0 0 1 4 0"],impuesto:["Impuestos","M6 3h12v18H6zM9 8h6M9 12h6M9 16h3"],banco:["Banco","M3 10 12 4l9 6M5 10v10h14V10M9 20v-6h6v6"],seguro:["Seguros","M12 3l8 3v6c0 5-4 8-8 9-4-1-8-4-8-9V6z M9 12l2 2 4-4"],nomina:["Nómina","M4 5h16v14H4zM8 9h8M8 13h5M15 15a2 2 0 1 0 4 0 2 2 0 0 0-4 0"],propina:["Propinas","M12 3v18M8 7h6a3 3 0 0 1 0 6h-4a3 3 0 0 0 0 6h6"],bolsa:["Ventas","M6 8h12l-1 12H7zM9 8V5a3 3 0 0 1 6 0v3"],camion:["Envíos","M3 7h11v9H3zM14 11h4l3 3v2h-7M6 19a1 1 0 1 0 2 0M16 19a1 1 0 1 0 2 0"],caja:["Inventario","M4 8l8-4 8 4v9l-8 4-8-4zM4 8l8 4 8-4M12 12v9"],factura:["Facturas","M6 3h12v18l-3-2-3 2-3-2-3 2zM9 8h6M9 12h6"],reloj:["Recurrentes","M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18M12 7v5l4 2"],estrella:["Favoritos","M12 3l3 6 6 1-4.5 4.5L18 21l-6-3-6 3 1.5-6.5L3 10l6-1z"],corazon:["Cuidado personal","M12 20s-8-4.5-8-10a4.5 4.5 0 0 1 8-3 4.5 4.5 0 0 1 8 3c0 5.5-8 10-8 10"],planta:["Jardín","M12 21V9M12 9C9 9 7 7 7 4c3 0 5 2 5 5M12 9c3 0 5-2 5-5-3 0-5 2-5 5M6 21h12"],limpieza:["Limpieza","M6 21h12l-1-9H7zM9 12V4h6v8M12 15v3"],mudanza:["Mudanza","M3 17h18M5 17V9l7-5 7 5v8M10 17v-5h4v5"],perro:["Perro","M5 11l2-5 3 2h4l3-2 2 5v6a3 3 0 0 1-3 3H8a3 3 0 0 1-3-3zM9 13h.01M15 13h.01M11 16h2"],gato:["Gato","M5 20V9l3-5 2 3h4l2-3 3 5v11zM9 13h.01M15 13h.01M10 16h4"],libro2:["Cursos","M4 6a4 4 0 0 1 8 0 4 4 0 0 1 8 0v12a4 4 0 0 0-8 0 4 4 0 0 0-8 0z"],premio:["Metas","M8 3h8v6a4 4 0 0 1-8 0zM12 13v5M9 21h6M5 5H3v2a4 4 0 0 0 4 4M19 5h2v2a4 4 0 0 1-4 4"],moneda:["Efectivo","M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18M12 7v10M9.5 9.5h5M9.5 14.5h5"],cripto:["Cripto","M9 4v16M7 8h5a2 2 0 0 1 0 4H7h5a2 2 0 0 1 0 4H7M12 4v2M12 18v2"],candado:["Fondo bloqueado","M6 11h12v10H6zM9 11V8a3 3 0 0 1 6 0v3M12 15v3"]},et={Ingresos:"grafico",Vivienda:"casa",Alimentación:"comida",Servicios:"rayo",Transporte:"auto",Educación:"birrete",Salud:"salud",Donaciones:"iglesia",Entretenimiento:"cine",Deudas:"tarjeta",Personal:"usuario",Ahorro:"hucha",Otros:"puntos"},ga=[["es","Español"],["en","English"],["fr","Français"]],Tt={es:"es-DO",en:"en-US",fr:"fr-FR"},tt={es:{panel:"Panel",movs:"Movimientos",cuentas:"Cuentas y tarjetas",presupuesto:"Presupuesto",metas:"Metas",libretas:"Libretas",ajustes:"Ajustes",nuevoMov:"+ Nuevo movimiento",personalizar:"Personalizar panel",listo:"Listo",restaurar:"Restaurar por defecto",notificaciones:"Notificaciones",todoTranquilo:"Todo tranquilo",tabCuentas:"Cuentas",tabTarjetas:"Tarjetas",tabPrestamos:"Préstamos",hCuentas:"Cuentas",hTarjetas:"Tarjetas de crédito",hPrestamos:"Préstamos",addCuenta:"+ Agregar cuenta",addTarjeta:"+ Agregar tarjeta",addPrestamo:"+ Agregar préstamo",addMeta:"+ Nueva meta",addCat:"+ Nueva categoría",addLibreta:"+ Nueva libreta",cancelar:"Cancelar",guardar:"Guardar",buscar:"Buscar concepto o categoría…",todos:"Todos",ingresos:"Ingresos",fijos:"Fijos",variables:"Variables",ahorro:"Ahorro",idioma:"Idioma",tema:"Tema",personaje:"Tu personaje",miCuenta:"Mi cuenta",cerrarSesion:"Cerrar sesión",resumenAnio:"Resumen del año",limiteCat:"Presupuesto por categoría",limiteCatSub:"Cada libreta tiene su propio presupuesto y sus propias categorías.",editar:"Editar",duplicar:"Duplicar",eliminar:"Eliminar",concepto:"Concepto",categoria:"Categoría",tipo:"Tipo",pagadoCon:"Pagado con",fecha:"Fecha",monto:"Monto",repetir:"Repetir cada mes",guardarMov:"Guardar movimiento",nuevoMovTitulo:"Nuevo movimiento",editarMov:"Editar movimiento",rolTu:"Tu rol",invitar:"Invitar",soloLectura:"Solo lectura",hoyChip:"Hoy",ayerChip:"Ayer",dia1Chip:"Día 1",balanceMes:"Balance del mes",tasaAhorro:"Tasa de ahorro",deudaActual:"Deuda actual",corteDia:"Corte día",pagoDia:"Pago día",usoLimite:"Uso del límite",abrir:"Abrir",agregarCat:"Agregar categoría",pagadoRing:"pagado",temaDesc:"Incluye el fondo de semillas de chinola, modo noche y variantes de color.",personajeDesc:"Chino te acompaña en la barra lateral. Elige su versión favorita o deja que cambie según cómo va tu mes.",cuota:"Cuota",venceDia:"vence día",meta:"Meta",ahorrado:"Ahorrado",falta:"Falta",aportar:"Aportar",libre:"libre",yo:"(tú)",cuotaLabel:"Cuota mensual",aporteMensual:"Aporte mensual",enUso:"En uso",miembros:"Miembros",correo:"Correo",permisos:"Permisos",libretasAjustes:"Libretas y permisos",copiarCats:"Copiar categorías y presupuesto de la libreta actual"},en:{panel:"Dashboard",movs:"Transactions",cuentas:"Accounts & cards",presupuesto:"Budget",metas:"Goals",libretas:"Books",ajustes:"Settings",nuevoMov:"+ New transaction",personalizar:"Customize dashboard",listo:"Done",restaurar:"Reset to default",notificaciones:"Notifications",todoTranquilo:"All clear",tabCuentas:"Accounts",tabTarjetas:"Cards",tabPrestamos:"Loans",hCuentas:"Accounts",hTarjetas:"Credit cards",hPrestamos:"Loans",addCuenta:"+ Add account",addTarjeta:"+ Add card",addPrestamo:"+ Add loan",addMeta:"+ New goal",addCat:"+ New category",addLibreta:"+ New book",cancelar:"Cancel",guardar:"Save",buscar:"Search by name or category…",todos:"All",ingresos:"Income",fijos:"Fixed",variables:"Variable",ahorro:"Savings",idioma:"Language",tema:"Theme",personaje:"Your character",miCuenta:"My account",cerrarSesion:"Sign out",resumenAnio:"Year summary",limiteCat:"Limit per category",limiteCatSub:"Each book has its own budget and its own categories.",editar:"Edit",duplicar:"Duplicate",eliminar:"Delete",concepto:"Description",categoria:"Category",tipo:"Type",pagadoCon:"Paid with",fecha:"Date",monto:"Amount",repetir:"Repeat monthly",guardarMov:"Save transaction",nuevoMovTitulo:"New transaction",editarMov:"Edit transaction",rolTu:"Your role",invitar:"Invite",soloLectura:"Read only",hoyChip:"Today",ayerChip:"Yesterday",dia1Chip:"1st of month",balanceMes:"Monthly balance",tasaAhorro:"Savings rate",deudaActual:"Current balance",corteDia:"Statement day",pagoDia:"Due day",usoLimite:"Limit usage",abrir:"Open",agregarCat:"Add category",pagadoRing:"paid",temaDesc:"Includes the passion-fruit seed background, night mode and color variants.",personajeDesc:"Chino keeps you company in the sidebar. Pick your favourite version or let it change with how your month is going.",cuota:"Installment",venceDia:"due on day",meta:"Goal",ahorrado:"Saved",falta:"Left",aportar:"Contribute",libre:"left",yo:"(you)",cuotaLabel:"Monthly installment",aporteMensual:"Monthly contribution",enUso:"In use",miembros:"Members",correo:"Email",permisos:"Permissions",libretasAjustes:"Books & permissions",copiarCats:"Copy categories and budget from the current book"},fr:{panel:"Tableau de bord",movs:"Opérations",cuentas:"Comptes et cartes",presupuesto:"Budget",metas:"Objectifs",libretas:"Carnets",ajustes:"Réglages",nuevoMov:"+ Nouvelle opération",personalizar:"Personnaliser",listo:"Terminé",restaurar:"Réinitialiser",notificaciones:"Notifications",todoTranquilo:"Tout va bien",tabCuentas:"Comptes",tabTarjetas:"Cartes",tabPrestamos:"Prêts",hCuentas:"Comptes",hTarjetas:"Cartes de crédit",hPrestamos:"Prêts",addCuenta:"+ Ajouter un compte",addTarjeta:"+ Ajouter une carte",addPrestamo:"+ Ajouter un prêt",addMeta:"+ Nouvel objectif",addCat:"+ Nouvelle catégorie",addLibreta:"+ Nouveau carnet",cancelar:"Annuler",guardar:"Enregistrer",buscar:"Rechercher un libellé ou une catégorie…",todos:"Tout",ingresos:"Revenus",fijos:"Fixes",variables:"Variables",ahorro:"Épargne",idioma:"Langue",tema:"Thème",personaje:"Ton personnage",miCuenta:"Mon compte",cerrarSesion:"Se déconnecter",resumenAnio:"Résumé de l’année",limiteCat:"Limite par catégorie",limiteCatSub:"Chaque carnet a son budget et ses catégories.",editar:"Modifier",duplicar:"Dupliquer",eliminar:"Supprimer",concepto:"Libellé",categoria:"Catégorie",tipo:"Type",pagadoCon:"Payé avec",fecha:"Date",monto:"Montant",repetir:"Répéter chaque mois",guardarMov:"Enregistrer l’opération",nuevoMovTitulo:"Nouvelle opération",editarMov:"Modifier l’opération",rolTu:"Ton rôle",invitar:"Inviter",soloLectura:"Lecture seule",hoyChip:"Aujourd’hui",ayerChip:"Hier",dia1Chip:"1er du mois",balanceMes:"Solde du mois",tasaAhorro:"Taux d’épargne",deudaActual:"Solde actuel",corteDia:"Relevé le",pagoDia:"Paiement le",usoLimite:"Utilisation",abrir:"Ouvrir",agregarCat:"Ajouter une catégorie",pagadoRing:"payé",temaDesc:"Comprend le fond graines de grenadille, le mode nuit et des variantes de couleur.",personajeDesc:"Chino t’accompagne dans la barre latérale. Choisis ta version préférée ou laisse-le changer selon ton mois.",cuota:"Échéance",venceDia:"échéance le",meta:"Objectif",ahorrado:"Épargné",falta:"Reste",aportar:"Contribuer",libre:"libre",yo:"(toi)",cuotaLabel:"Échéance mensuelle",aporteMensual:"Versement mensuel",enUso:"Actif",miembros:"Membres",correo:"E-mail",permisos:"Permissions",libretasAjustes:"Carnets et permissions",copiarCats:"Copier catégories et budget du carnet actuel"}},Ve={"Ingresos del mes":["Monthly income","Revenus du mois"],"Gastos del mes":["Monthly expenses","Dépenses du mois"],"Balance del mes":["Monthly balance","Solde du mois"],"Deuda total":["Total debt","Dette totale"],Patrimonio:["Net worth","Patrimoine"],"Gastos por categoría":["Expenses by category","Dépenses par catégorie"],"Evolución en el tiempo":["Trend over time","Évolution dans le temps"],"Tendencia 6 meses":["6-month trend","Tendance sur 6 mois"],"Mezcla de gastos":["Expense mix","Répartition des dépenses"],"Últimos movimientos":["Latest transactions","Dernières opérations"],"Recordatorios de pago":["Payment reminders","Rappels de paiement"],"Avance de metas":["Goal progress","Progression des objectifs"],"Consejo de Chino":["Chino’s tip","Le conseil de Chino"],"Línea, área, columnas o puntos con los meses y series que elijas.":["Line, area, columns or dots with the months and series you choose.","Ligne, aire, colonnes ou points avec les mois et séries de ton choix."],"Cifra grande con el total de ingresos.":["Large figure with total income.","Grand chiffre avec le total des revenus."],"Cifra grande con el total de gastos.":["Large figure with total expenses.","Grand chiffre avec le total des dépenses."],"Cuánto queda después de gastos y ahorro.":["What is left after expenses and savings.","Ce qui reste après dépenses et épargne."],"Tarjetas más préstamos pendientes.":["Cards plus outstanding loans.","Cartes plus prêts en cours."],"Saldos de cuentas menos deudas.":["Account balances minus debts.","Soldes des comptes moins les dettes."],"Barras horizontales con el top de categorías.":["Horizontal bars with your top categories.","Barres horizontales avec tes principales catégories."],"Columnas de ingresos vs gastos.":["Income vs expenses columns.","Colonnes revenus / dépenses."],"Dona con fijos, variables y ahorro.":["Donut with fixed, variable and savings.","Anneau avec fixes, variables et épargne."],"Lista de los movimientos más recientes.":["List of the most recent transactions.","Liste des opérations les plus récentes."],"Cortes de tarjeta y cuotas próximas.":["Upcoming card statements and installments.","Relevés de carte et échéances à venir."],"Progreso de cada meta de ahorro.":["Progress of each savings goal.","Progression de chaque objectif d’épargne."],"Una lectura corta de tu mes.":["A short read on your month.","Une lecture rapide de ton mois."],"del mes":["this month","du mois"],"tarjetas + préstamos":["cards + loans","cartes + prêts"],"cuentas − deudas":["accounts − debts","comptes − dettes"],disponible:["available","disponible"],déficit:["deficit","déficit"],"dinero en mano":["cash on hand","argent en main"],"Efectivo en mano":["Cash on hand","Argent en main"],"En bancos":["In banks","En banque"],"En efectivo":["In cash","En espèces"],"Deuda de tarjetas":["Card debt","Dette de cartes"],"Deuda de préstamos":["Loan debt","Dette de prêts"],Presupuestado:["Budgeted","Budgété"],Gastado:["Spent","Dépensé"],Disponible:["Available","Disponible"],"presupuesto mensual total":["total monthly budget","budget mensuel total"],"Ahorro acumulado":["Total saved","Épargne cumulée"],"Meta total":["Total goal","Objectif total"],"Aporte mensual":["Monthly contribution","Versement mensuel"],"plan de ahorro":["savings plan","plan d’épargne"],Automático:["Automatic","Automatique"],"Chino fuerte":["Strong Chino","Chino musclé"],"Chino estudioso":["Studious Chino","Chino studieux"],"Chino roto":["Cracked Chino","Chino fissuré"],"Chino jugo":["Juice Chino","Chino en jus"],"Chino fiesta":["Party Chino","Chino en fête"],"Se me salen las semillas: el mes va en rojo.":["My seeds are falling out: the month is in the red.","Mes graines s’échappent : le mois est dans le rouge."],"¡Meta cumplida! Eso se celebra.":["Goal reached! Time to celebrate.","Objectif atteint ! On célèbre."],"Mes tranquilo, hasta me volví jugo.":["Quiet month, I even turned into juice.","Mois tranquille, je me suis même transformé en jus."],"Vamos bien, sigue registrando.":["Going well, keep logging.","Ça va bien, continue à enregistrer."],Dueño:["Owner","Propriétaire"],Editor:["Editor","Éditeur"],Registrador:["Logger","Enregistreur"],Lector:["Viewer","Lecteur"],"Todo: movimientos, cuentas, presupuesto, metas, invitar y eliminar la libreta.":["Everything: transactions, accounts, budget, goals, inviting and deleting the book.","Tout : opérations, comptes, budget, objectifs, inviter et supprimer le carnet."],"Crear y editar todo dentro de la libreta, pero no invitar ni eliminarla.":["Create and edit everything inside the book, but cannot invite or delete it.","Créer et modifier tout dans le carnet, sans inviter ni le supprimer."],"Solo agregar movimientos y pagos; no edita cuentas ni presupuesto.":["Only add transactions and payments; cannot edit accounts or budget.","Seulement ajouter des opérations et paiements ; ne modifie pas comptes ni budget."],"Solo ver: informes, saldos y presupuesto en modo lectura.":["View only: reports, balances and budget in read mode.","Lecture seule : rapports, soldes et budget."],"Notificaciones de pago":["Payment notifications","Notifications de paiement"],"Ver el tour otra vez":["Take the tour again","Revoir la visite"],"Exportar esta libreta a CSV":["Export this book to CSV","Exporter ce carnet en CSV"],"Gestionar categorías":["Manage categories","Gérer les catégories"],"Restaurar panel por defecto":["Reset dashboard to default","Réinitialiser le tableau de bord"],Activas:["On","Activées"],Desactivadas:["Off","Désactivées"],"Incluye el fondo de semillas de chinola, modo noche y variantes de color.":["Includes the passion-fruit seed background, night mode and color variants.","Comprend le fond graines de grenadille, le mode nuit et des variantes de couleur."],"Balance negativo":["Negative balance","Solde négatif"],"Todo tranquilo":["All clear","Tout va bien"],"Sin pagos próximos ni categorías excedidas en esta libreta.":["No upcoming payments and no categories over budget in this book.","Aucun paiement à venir ni catégorie dépassée dans ce carnet."],ahora:["now","maintenant"],límite:["over limit","dépassé"],presupuesto:["budget","budget"],hoy:["today","aujourd’hui"],liquidado:["paid off","soldé"],Liquidado:["Paid off","Soldé"],completada:["completed","terminé"],"Ingresos del año":["Income this year","Revenus de l’année"],"Gastos del año":["Expenses this year","Dépenses de l’année"],Diferencia:["Difference","Différence"],"Promedio de gasto mensual":["Average monthly spending","Dépense mensuelle moyenne"],Línea:["Line","Ligne"],Área:["Area","Aire"],Columnas:["Columns","Colonnes"],"Barras apiladas":["Stacked bars","Barres empilées"],Puntos:["Dots","Points"],"3 meses":["3 months","3 mois"],"6 meses":["6 months","6 mois"],"12 meses":["12 months","12 mois"],"24 meses":["24 meses","24 mois"],Ingresos:["Income","Revenus"],Gastos:["Expenses","Dépenses"],Balance:["Balance","Solde"],Ahorro:["Savings","Épargne"],"Cuenta de banco":["Bank account","Compte bancaire"],Efectivo:["Cash","Espèces"],Personal:["Personal","Personnel"],Familiar:["Family","Famille"],Negocio:["Business","Entreprise"],Proyecto:["Project","Projet"],"Arrastra las tarjetas para reordenarlas, cambia su ancho o el tipo de gráfico":["Drag cards to reorder them, change their width or the chart type","Fais glisser les cartes pour les réordonner, change leur largeur ou le type de graphique"],"Agregar gráfico o tarjeta":["Add a chart or card","Ajouter un graphique ou une carte"],"Editar cuenta":["Edit account","Modifier le compte"],"Nuevo movimiento aquí":["New transaction here","Nouvelle opération ici"],"Transferir a otra cuenta":["Transfer to another account","Transférer vers un autre compte"],"Ver sus movimientos":["See its transactions","Voir ses opérations"],"Eliminar cuenta":["Delete account","Supprimer le compte"],"Registrar un pago":["Log a payment","Enregistrer un paiement"],"Editar tarjeta":["Edit card","Modifier la carte"],"Nuevo gasto con esta tarjeta":["New expense with this card","Nouvelle dépense avec cette carte"],"Marcar como pagada":["Mark as paid","Marquer comme payée"],"Eliminar tarjeta":["Delete card","Supprimer la carte"],"Registrar un abono":["Log a payment","Enregistrer un versement"],"Editar préstamo":["Edit loan","Modifier le prêt"],"Marcar como liquidado":["Mark as paid off","Marquer comme soldé"],"Eliminar préstamo":["Delete loan","Supprimer le prêt"],"Esa deuda cae este mes. ¡Dale!":["That debt goes down this month. Let’s go!","Cette dette baisse ce mois-ci. Allez !"],"Revisemos los números con calma.":["Let’s go through the numbers calmly.","Regardons les chiffres calmement."],"Se me salen las semillas con estos gastos.":["My seeds are falling out with these expenses.","Mes graines s’échappent avec ces dépenses."],"Mes relajado: hasta me volví jugo.":["Relaxed month: I even turned into juice.","Mois tranquille : je me suis même transformé en jus."],"¡Meta cumplida! Eso se celebra.":["Goal reached! Time to celebrate.","Objectif atteint ! On célèbre."],"Qué puede hacer cada rol":["What each role can do","Ce que peut faire chaque rôle"],Rol:["Role","Rôle"],"Tu rol":["Your role","Ton rôle"],"+ Nueva libreta":["+ New book","+ Nouveau carnet"],Cancelar:["Cancel","Annuler"],"+ Agregar cuenta":["+ Add account","+ Ajouter un compte"],"+ Agregar tarjeta":["+ Add card","+ Ajouter une carte"],"+ Agregar préstamo":["+ Add loan","+ Ajouter un prêt"],"+ Nueva meta":["+ New goal","+ Nouvel objectif"],"+ Nueva categoría":["+ New category","+ Nouvelle catégorie"],Claro:["Light","Clair"],Semillas:["Seeds","Graines"],Jugo:["Juice","Jus"],Hoja:["Leaf","Feuille"],Noche:["Night","Nuit"],"Noche + semillas":["Night + seeds","Nuit + graines"],"Nueva cuenta":["New account","Nouveau compte"],"Nueva tarjeta":["New card","Nouvelle carte"],"Nuevo préstamo":["New loan","Nouveau prêt"],"Nueva meta de ahorro":["New savings goal","Nouvel objectif d’épargne"],"Nueva libreta":["New book","Nouveau carnet"],"Nueva categoría":["New category","Nouvelle catégorie"],"Editar categoría":["Edit category","Modifier la catégorie"],"Eliminar categoría":["Delete category","Supprimer la catégorie"],Nombre:["Name","Nom"],"Límite mensual":["Monthly limit","Limite mensuelle"],Icono:["Icon","Icône"],Gasto:["Expense","Dépense"],Ingreso:["Income","Revenu"],"¡Entró plata!":["Money in!","De l’argent est entré !"],"¡Ese ahorro cuenta!":["That saving counts!","Cette épargne compte !"],"Movimiento guardado":["Transaction saved","Opération enregistrée"],"¡Tarjeta en cero!":["Card at zero!","Carte à zéro !"],"Pago registrado":["Payment logged","Paiement enregistré"],"¡Préstamo liquidado!":["Loan paid off!","Prêt soldé !"],"Abono registrado":["Payment logged","Versement enregistré"],"¡Meta cumplida!":["Goal reached!","Objectif atteint !"],"¡Vas subiendo!":["Climbing up!","Ça monte !"],"Mes apretado":["Tight month","Mois serré"],"Ojo con las fechas":["Watch the dates","Attention aux dates"],"¡Celebrando!":["Celebrating!","On célèbre !"],"Todo relajado":["All relaxed","Tout tranquille"],"Buen ritmo":["Good pace","Bon rythme"],Invitación:["Invitation","Invitation"],"Aceptar invitación":["Accept invitation","Accepter l’invitation"],Rechazar:["Decline","Refuser"],"Salir de la libreta":["Leave this book","Quitter le carnet"],"Te invitaron a esta libreta. Acéptala para usarla, o recházala.":["You were invited to this book. Accept it to use it, or decline.","On t’a invité à ce carnet. Accepte-le pour l’utiliser, ou refuse."],"Invitación aceptada":["Invitation accepted","Invitation acceptée"],"Invitación rechazada":["Invitation declined","Invitation refusée"],"Saliste de la libreta":["You left the book","Tu as quitté le carnet"],"Ya puedes usar la libreta.":["You can use the book now.","Tu peux utiliser le carnet."],Aceptar:["Accept","Accepter"],"Invitar a la libreta":["Invite to this book","Inviter au carnet"],"Invitación enviada":["Invitation sent","Invitation envoyée"],"Libretas y permisos":["Books & permissions","Carnets et permissions"],Total:["Total","Total"],Pagado:["Paid","Payé"],Falta:["Left","Reste"],Transferir:["Transfer","Transférer"],Guardar:["Save","Enregistrer"],"Crear meta":["Create goal","Créer l’objectif"],"Crear libreta":["Create book","Créer le carnet"],Abrir:["Open","Ouvrir"],Eliminar:["Delete","Supprimer"],Quitar:["Remove","Retirer"],Listo:["Done","Terminé"],Pagar:["Pay","Payer"],Registrar:["Log","Enregistrer"],Aportar:["Contribute","Contribuer"]},at=[[/^(\d+)% de tus ingresos$/,["$1% of your income","$1 % de tes revenus"]],[/^(\d+) elementos en el panel de esta libreta$/,["$1 items on this book’s dashboard","$1 éléments sur le tableau de bord de ce carnet"]],[/^(\d+) movs\.$/,["$1 txns","$1 opér."]],[/^(\d+) pasos$/,["$1 steps","$1 étapes"]],[/^en (\d+) d$/,["in $1 d","dans $1 j"]],[/^pago en (\d+) d$/,["due in $1 d","paiement dans $1 j"]],[/^pagar en (\d+) d$/,["pay in $1 d","payer dans $1 j"]],[/^paga en (\d+) d$/,["due in $1 d","dans $1 j"]],[/^(\d+) cuenta\(s\)$/,["$1 account(s)","$1 compte(s)"]],[/^(\d+) meta\(s\) activas$/,["$1 active goal(s)","$1 objectif(s) actif(s)"]],[/^(\d+) categoría\(s\) excedida\(s\)$/,["$1 category(ies) over budget","$1 catégorie(s) dépassée(s)"]],[/^(\d+)% del presupuesto$/,["$1% of the budget","$1 % du budget"]],[/^(\d+)% de tus metas$/,["$1% of your goals","$1 % de tes objectifs"]],[/^(\d+)% del límite$/,["$1% of the limit","$1 % de la limite"]],[/^cuotas del mes (.+)$/,["monthly installments $1","échéances du mois $1"]],[/^listo en ~(\d+) meses$/,["ready in ~$1 months","prêt dans ~$1 mois"]],[/^(\d+) cuotas · paga en (\d+) d$/,["$1 installments · due in $2 d","$1 échéances · dans $2 j"]],[/^Llevas (.+) de (.+) presupuestado\.$/,["You have spent $1 of $2 budgeted.","Tu as dépensé $1 sur $2 budgétés."]],[/^(.+) sobre el presupuesto$/,["$1 over budget","$1 dépassé"]],[/^Los gastos de este mes superan lo que entró \((.+) de más\)\.$/,["This month’s expenses exceed income (by $1).","Les dépenses du mois dépassent les revenus (de $1)."]],[/^Pago (.+)$/,["Payment $1","Paiement $1"]],[/^Cuota (.+)$/,["Installment $1","Échéance $1"]],[/^(.+) · corte día (\d+)$/,["$1 · statement day $2","$1 · relevé le $2"]],[/^(.+) · día (\d+) de cada mes$/,["$1 · day $2 each month","$1 · le $2 de chaque mois"]]],ot=["Dueño","Editor","Registrador","Lector"],$e={Dueño:"Todo: movimientos, cuentas, presupuesto, metas, invitar y eliminar la libreta.",Editor:"Crear y editar todo dentro de la libreta, pero no invitar ni eliminarla.",Registrador:"Solo agregar movimientos y pagos; no edita cuentas ni presupuesto.",Lector:"Solo ver: informes, saldos y presupuesto en modo lectura."},rt={ingresos:{label:"Ingresos",color:"oklch(0.52 0.13 152)"},gastos:{label:"Gastos",color:"oklch(0.62 0.16 30)"},balance:{label:"Balance",color:"oklch(0.46 0.11 255)"},ahorro:{label:"Ahorro",color:"oklch(0.56 0.14 300)"},patrimonio:{label:"Patrimonio",color:"oklch(0.60 0.13 95)"}},ma=[["linea","Línea"],["area","Área"],["columnas","Columnas"],["barras","Barras apiladas"],["puntos","Puntos"]],ha=[[3,"3 meses"],[6,"6 meses"],[12,"12 meses"],[24,"24 meses"]],Et=[["serie-tiempo","Evolución en el tiempo","Línea, área, columnas o puntos con los meses y series que elijas."],["kpi-ingresos","Ingresos del mes","Cifra grande con el total de ingresos."],["kpi-gastos","Gastos del mes","Cifra grande con el total de gastos."],["kpi-balance","Balance del mes","Cuánto queda después de gastos y ahorro."],["kpi-deuda","Deuda total","Tarjetas más préstamos pendientes."],["kpi-patrimonio","Patrimonio","Saldos de cuentas menos deudas."],["barras-categorias","Gastos por categoría","Barras horizontales con el top de categorías."],["columnas-tendencia","Tendencia 6 meses","Columnas de ingresos vs gastos."],["dona-mezcla","Mezcla de gastos","Dona con fijos, variables y ahorro."],["lista-recientes","Últimos movimientos","Lista de los movimientos más recientes."],["lista-recordatorios","Recordatorios de pago","Cortes de tarjeta y cuotas próximas."],["lista-metas","Avance de metas","Progreso de cada meta de ahorro."],["texto-consejo","Consejo de Chino","Una lectura corta de tu mes."]],Ue=[{id:"w1",tipo:"kpi-ingresos",ancho:1},{id:"w2",tipo:"kpi-gastos",ancho:1},{id:"w3",tipo:"kpi-deuda",ancho:1},{id:"w4",tipo:"kpi-patrimonio",ancho:1},{id:"w0",tipo:"serie-tiempo",ancho:4,cfg:{grafico:"linea",rango:12,series:["ingresos","gastos"]}},{id:"w5",tipo:"barras-categorias",ancho:2},{id:"w6",tipo:"columnas-tendencia",ancho:2},{id:"w7",tipo:"lista-recientes",ancho:2},{id:"w8",tipo:"lista-recordatorios",ancho:2}],Q=[{t:"Libretas para cada cosa",x:"Arriba a la izquierda cambias entre libretas: personal, familia, negocio. Cada una tiene sus propios números.",v:"panel"},{t:"Tu panel, a tu manera",x:'Pulsa "Personalizar" para agregar o quitar gráficos, cambiar su ancho o restaurar el panel por defecto.',v:"panel"},{t:"Registra en segundos",x:"El botón amarillo abre el registro: tipo, monto, categoría y con qué pagaste.",v:"movs"},{t:"Cuentas y tarjetas reales",x:"Cada tarjeta muestra deuda, uso del límite y sus fechas de corte y pago.",v:"cuentas"},{t:"Comparte con permisos",x:"En Libretas invitas a alguien y decides si es editor, solo registra o solo lee.",v:"libretas"},{t:"Ponle tu cara",x:"En Ajustes cambias el tema (incluido el fondo de semillas y modo noche) y eliges tu versión de Chino.",v:"ajustes"}],fa=[["Nómina Ricarni","Ingresos","Ingreso",12e3],["Nómina Gelson 1","Ingresos","Ingreso",40668],["Nómina Gelson 2","Ingresos","Ingreso",3e4],["Casa","Vivienda","Gasto Fijo",1e4],["Comida","Alimentación","Gasto Fijo",1e4],["Internet","Servicios","Gasto Fijo",1e3],["Luz","Servicios","Gasto Fijo",1e3],["Unicaribe","Educación","Gasto Fijo",4e3],["Iglesia","Donaciones","Gasto Fijo",7e3],["Prest. Banesco","Deudas","Gasto Fijo",17500],["Personal Ricarni","Personal","Gasto Fijo",1e4],["Personal Gelson","Personal","Gasto Fijo",1e4],["Gasolina","Transporte","Gasto Variable",5e3],["Entretenimiento","Entretenimiento","Gasto Variable",6e3]],ba=[["Ingresos",C[0],!0],["Vivienda",C[1],!1],["Alimentación",C[4],!1],["Servicios",C[5],!1],["Transporte",C[2],!1],["Educación",C[3],!1],["Salud","oklch(0.50 0.12 175)",!1],["Donaciones","oklch(0.46 0.12 290)",!1],["Entretenimiento","oklch(0.58 0.14 60)",!1],["Deudas","oklch(0.50 0.15 10)",!1],["Personal","oklch(0.44 0.11 230)",!1],["Ahorro",Se,!1],["Otros",C[6],!1]],xa=[.82,1.18,.94,1.06,.88,1];function Ae(j){return j.getFullYear()+"-"+String(j.getMonth()+1).padStart(2,"0")}function va(j){return j.slice(0,7)}function it(){return new Date().toISOString().slice(0,10)}function Pt(j){return"linear-gradient(135deg,"+j+" 0%, color-mix(in oklab, "+j+" 58%, black) 100%)"}function He(j){const a=new Date;a.setHours(0,0,0,0);const e=Math.min(Math.max(Number(j)||1,1),28);let o=new Date(a.getFullYear(),a.getMonth(),e);return o<a&&(o=new Date(a.getFullYear(),a.getMonth()+1,e)),Math.round((o-a)/864e5)}function se(j){const a=String(j||"").trim().split(/\s+/);return((a[0]||"")[0]||"?").toUpperCase()+((a[1]||"")[0]||"").toUpperCase()}function Ce(){return String(Date.now())+Math.floor(Math.random()*999)}class te extends Jt{constructor(){super(...arguments);Xe(this,"state",te.cargar());Xe(this,"guardarTx",()=>{const e=this.state,o=e.form,i=this.lb();if(!String(o.concepto).trim()||!Number(o.monto))return;const r={id:o.id||Ce(),concepto:String(o.concepto).trim(),categoria:o.categoria,tipo:o.tipo,monto:Math.abs(Number(o.monto)),fecha:o.fecha||it(),recurrente:!!o.recurrente,medio:o.medio,destino:o.tipo==="Transferencia"?o.destino:void 0};let u=i;if(o.id){const g=i.tx.filter(S=>S.id===o.id)[0];g&&(u=Object.assign({},i,this.aplica(i,g,-1)))}const f=this.aplica(u,r,1),l=o.id?u.tx.map(g=>g.id===o.id?r:g):u.tx.concat([r]),y=Object.assign({},u,f,{tx:l});this.guardar({libretas:e.libretas.map(g=>g.id===i.id?y:g),formOpen:!1,mes:va(r.fecha)}),this.festeja(r.tipo==="Ingreso"?"¡Entró plata!":r.tipo==="Ahorro"?"¡Ese ahorro cuenta!":"Movimiento guardado",r.concepto+" · "+this.fmt(r.monto))})}static datosLibreta(e){const o=[],i=new Date;if(e)for(let r=5;r>=0;r--){const u=new Date(i.getFullYear(),i.getMonth()-r,1),f=Ae(u),l=xa[5-r];fa.forEach(function(y,g){const S=y[2]==="Gasto Variable";o.push({id:Ce(),concepto:y[0],categoria:y[1],tipo:y[2],monto:S?Math.round(y[3]*l/100)*100:y[3],fecha:f+"-"+String(3+g%20).padStart(2,"0"),recurrente:!S,medio:"cuenta:1"})})}return{tx:o,categorias:ba.map(function(r,u){return{id:u+1,nombre:r[0],color:r[1],ingreso:r[2]}}),presupuesto:{Vivienda:1e4,Alimentación:12e3,Servicios:2500,Transporte:6e3,Educación:4e3,Salud:2e3,Donaciones:7e3,Entretenimiento:5e3,Deudas:17500,Personal:2e4,Otros:2e3},cuentas:e?[{id:1,nombre:"Cuenta principal",banco:"Banreservas",saldo:48200,color:C[0]},{id:2,nombre:"Ahorros",banco:"Banco Popular",saldo:2e4,color:C[1]},{id:3,nombre:"Efectivo",banco:"En mano",saldo:6500,color:C[4],efectivo:!0}]:[{id:1,nombre:"Efectivo",banco:"En mano",saldo:0,color:C[4],efectivo:!0}],tarjetas:e?[{id:1,nombre:"Visa Clásica",banco:"Banco Popular",limite:8e4,saldo:23400,corte:20,pago:5,color:C[1],last4:"4821",abono:""},{id:2,nombre:"Mastercard Gold",banco:"Banreservas",limite:15e4,saldo:61200,corte:28,pago:15,color:C[3],last4:"7390",abono:""}]:[],prestamos:e?[{id:1,nombre:"Préstamo Banesco",total:35e4,pagado:21e4,cuota:17500,dia:10,color:C[2]},{id:2,nombre:"Préstamo vehículo",total:18e4,pagado:45e3,cuota:6500,dia:25,color:C[5]}]:[],metas:e?[{id:1,nombre:"Fondo de emergencia",meta:15e4,ahorrado:2e4,mensual:4e3,color:F},{id:2,nombre:"Viaje familiar",meta:6e4,ahorrado:5e3,mensual:2500,color:Se}]:[],panel:Ue.map(r=>Object.assign({},r))}}static baseLibretas(e,o){const i=Xt();return[Object.assign({id:i,nombre:"Personal",tipo:"Personal",color:C[0],miembros:[{email:e,nombre:o,rol:"Dueño"}]},te.datosLibreta(!1))]}static ui(){return{paso:"onboarding",slideIdx:0,authModo:"registro",auth:{nombre:"",email:"",pass:""},authError:"",sesion:null,vista:"panel",subvista:"cuentas",mes:Ae(new Date),q:"",filtro:"Todos",libretas:[],activa:null,libretaVista:null,invModal:!1,invForm:{email:"",nombre:"",rol:"Editor"},selectorOpen:!1,editorOpen:!1,tema:"chinola",personaje:"auto",idioma:St(),paleta:"clasica",notis:!1,notisOpen:!1,toast:null,tour:-1,menu:null,agregar:null,arrastra:null,sobre:null,editando:null,transf:null,pagando:null,form:{id:null,concepto:"",categoria:"Otros",tipo:"Gasto Variable",monto:"",fecha:it(),medio:"cuenta:1",recurrente:!1},formOpen:!1,nuevaCuenta:{nombre:"",banco:"",saldo:"",color:C[0],tipo:"Cuenta de banco"},nuevaTarjeta:{nombre:"",banco:"",limite:"",saldo:"",corte:"20",pago:"5",color:C[1]},nuevoPrestamo:{nombre:"",total:"",pagado:"",cuota:"",dia:"10"},nuevaMeta:{nombre:"",meta:"",mensual:""},catModal:!1,catForm:{id:null,nombre:"",color:C[4],icono:"puntos",limite:"",ingreso:!1},nuevaLibreta:{nombre:"",tipo:"Personal",color:C[4],copiar:!0},inv:{}}}static cargar(){const e=te.ui();try{const o=localStorage.getItem(jt);if(o){const i=JSON.parse(o);if(i.sesion){e.sesion=i.sesion,e.paso="app",e.tema=i.tema||"chinola",e.personaje=i.personaje||"auto",e.idioma=i.idioma||St(),e.notis=!!i.notis,e.paleta=i.paleta||"clasica";const r=localStorage.getItem(Mt);if(r){const u=JSON.parse(r);e.libretas=te.conEfectivo(u.libretas||[]),e.activa=u.activa||null}e.libretas.length||(e.libretas=te.baseLibretas(i.sesion.email,i.sesion.nombre)),(!e.activa||!e.libretas.some(u=>u.id===e.activa))&&(e.activa=e.libretas[0].id)}}}catch{}return e}guardar(e){this.setState(e,()=>{const o=this.state;try{localStorage.setItem(Mt,JSON.stringify({libretas:o.libretas,activa:o.activa})),localStorage.setItem(jt,JSON.stringify({sesion:o.sesion,tema:o.tema,personaje:o.personaje,idioma:o.idioma,notis:o.notis,paleta:o.paleta})),o.sesion&&localStorage.setItem(Ke+":"+o.sesion.email,JSON.stringify({libretas:o.libretas,at:Date.now()}))}catch{}})}componentDidMount(){this.onResize=()=>this.forceUpdate(),window.addEventListener("resize",this.onResize)}componentWillUnmount(){window.removeEventListener("resize",this.onResize)}static conEfectivo(e){return(e||[]).map(function(o){if(!o.cuentas||o.cuentas.some(r=>r.efectivo))return o;const i=Math.max.apply(null,o.cuentas.map(r=>r.id).concat([0]))+1;return Object.assign({},o,{cuentas:o.cuentas.concat([{id:i,nombre:"Efectivo",banco:"En mano",saldo:0,color:C[4],efectivo:!0}])})})}festeja(e,o){const i=this;this.toastT&&clearTimeout(this.toastT),this.setState({toast:{titulo:e,texto:o}}),this.toastT=setTimeout(function(){i.setState({toast:null})},3600)}lb(){const e=this.state;return e.libretas.filter(o=>o.id===e.activa)[0]||e.libretas[0]}rol(){const e=this.lb();if(!e||!this.state.sesion)return"Lector";const o=e.miembros.filter(i=>i.email===this.state.sesion.email)[0];return o?o.rol:"Lector"}setLb(e){const o=this.state.activa;this.guardar({libretas:this.state.libretas.map(i=>i.id===o?Object.assign({},i,e):i)})}t(e){return(tt[this.state.idioma||"es"]||tt.es)[e]||tt.es[e]||e}trStr(e){const o=this.state.idioma==="en"?0:this.state.idioma==="fr"?1:-1;return o<0||typeof e!="string"||!e?e:this.trPiece(e,o)}trPiece(e,o){if(Ve[e])return Ve[e][o];for(let l=0;l<at.length;l++){const y=at[l][0];if(y.test(e))return e.replace(y,at[l][1][o])}const i=/^([^:]{2,12}):\s*(.+)$/.exec(e);if(i&&Ve[i[1]])return Ve[i[1]][o]+": "+this.trPiece(i[2],o);if(e.indexOf(" · ")>=0){const l=e.split(" · ");let y=!1;const g=l.map(S=>{const z=this.trPiece(S.trim(),o);return z!==S.trim()&&(y=!0),z});if(y)return g.join(" · ")}const r=/^(\d+) movimientos$/.exec(e);if(r)return r[1]+(o===0?" transactions":" opérations");const u=/^balance del mes (.+)$/.exec(e);if(u)return(o===0?"monthly balance ":"solde du mois ")+u[1];const f=/^(\d+) persona\(s\)$/.exec(e);return f?f[1]+(o===0?" person(s)":" personne(s)"):e}trDeep(e,o){if(o===void 0&&this.state.idioma!=="en"&&this.state.idioma!=="fr"||o>4||e==null)return e;if(typeof e=="string")return this.trStr(e);if(Array.isArray(e))return e.map(i=>this.trDeep(i,o+1));if(typeof e=="object"){if(e.$$typeof||typeof e.then=="function")return e;const i={};for(const r in e){if(r==="nombresCat"||r==="categorias"||r==="nombre"||r==="banco"||r==="concepto"||r==="categoria"||r==="email"||r==="form"||r==="auth"||r==="medios"||r==="id"){i[r]=e[r];continue}i[r]=typeof e[r]=="function"?e[r]:this.trDeep(e[r],o+1)}return i}return e}fmt(e){const o=this.props.mostrarCentavos?2:0;try{return new Intl.NumberFormat(Tt[this.state.idioma||"es"]||"es-DO",{style:"currency",currency:this.props.moneda||"DOP",minimumFractionDigits:o,maximumFractionDigits:o}).format(e||0)}catch{return"$"+Math.round(e||0).toLocaleString("es-DO")}}campo(e,o){return i=>{const r=i.target.type==="checkbox"?i.target.checked:i.target.value;this.setState(u=>({[e]:Object.assign({},u[e],{[o]:r})}))}}swatchList(e,o){const i=ie[this.state.tema]||ie.chinola;return C.map(r=>({color:r,borde:e===r?i.tinta:"transparent",go:()=>o(r)}))}totales(e,o,i){const r=e.tx.filter(g=>this.enPeriodo(g.fecha,o,i)),u=r.filter(g=>g.tipo==="Ingreso").reduce((g,S)=>g+S.monto,0),f=r.filter(g=>g.tipo==="Gasto Fijo"||g.tipo==="Gasto Variable").reduce((g,S)=>g+S.monto,0),l=r.filter(g=>g.tipo==="Gasto Fijo").reduce((g,S)=>g+S.monto,0),y=r.filter(g=>g.tipo==="Ahorro").reduce((g,S)=>g+S.monto,0);return{ing:u,gas:f,fij:l,vari:f-l,aho:y,bal:u-f-y}}aplica(e,o,i){const r=o.medio||"";if(o.tipo==="Transferencia"){const u=(l,y,g)=>{if(!y||!g)return l;if(y.indexOf("cuenta:")===0){const S=Number(y.split(":")[1]);return Object.assign({},l,{cuentas:(l.cuentas||e.cuentas).map(z=>z.id===S?Object.assign({},z,{saldo:z.saldo+g}):z)})}if(y.indexOf("tarjeta:")===0){const S=Number(y.split(":")[1]);return Object.assign({},l,{tarjetas:(l.tarjetas||e.tarjetas).map(z=>z.id===S?Object.assign({},z,{saldo:Math.max(0,z.saldo-g)}):z)})}return l};let f={};return f=u(f,r,-o.monto*i),f=u(f,o.destino,o.monto*i),f}if(r.indexOf("cuenta:")===0){const u=Number(r.split(":")[1]),f=o.monto*(o.tipo==="Ingreso"?1:-1)*i;return{cuentas:e.cuentas.map(l=>l.id===u?Object.assign({},l,{saldo:l.saldo+f}):l)}}if(r.indexOf("tarjeta:")===0&&o.tipo!=="Ingreso"){const u=Number(r.split(":")[1]);return{tarjetas:e.tarjetas.map(f=>f.id===u?Object.assign({},f,{saldo:Math.max(0,f.saldo+o.monto*i)}):f)}}return{}}txAuto(e,o,i,r){const u=this.lb();return{id:Ce(),concepto:e,categoria:o,tipo:i,monto:r,fecha:this.state.mes+"-"+String(new Date().getDate()).padStart(2,"0"),recurrente:!1,medio:u.cuentas.length?"cuenta:"+u.cuentas[0].id:"efectivo"}}entrar(e,o,i){let r=null;try{const u=localStorage.getItem(Ke+":"+e);u&&i&&(r=JSON.parse(u).libretas)}catch{}(!r||!r.length)&&(r=te.baseLibretas(e,o)),this.guardar({sesion:{email:e,nombre:o},libretas:r,activa:r[0].id,paso:"app",authError:"",auth:{nombre:"",email:"",pass:""},tour:0,vista:"panel"})}renderVals(){const e=this.state,o=this,i=t=>o.fmt(t),r=ie[e.tema]||ie.chinola,u={bg:r.bg,card:r.card,suave:r.suave,borde:r.borde,tinta:r.tinta,gris:r.gris,side:r.side,patron:r.patron},f=(t,s)=>s>0?Math.min(100,Math.round(t/s*100)):0,l=t=>o.t(t),y=Tt[e.idioma||"es"]||"es-DO",g=(t,s)=>{try{return new Intl.DateTimeFormat(y,{month:s?"short":"long"}).format(new Date(2020,t,1)).replace(".","")}catch{return s?At[t]:zt[t]}},S=t=>{const s=(p&&p.categorias?p.categorias:[]).filter(b=>b.nombre===t)[0];return we[s&&s.icono||et[t]||"puntos"]||we.puntos},z=t=>we[t.icono||et[t.nombre]||"puntos"]||we.puntos,P=t=>e.menu===t,B=t=>s=>{s&&s.stopPropagation&&s.stopPropagation(),o.setState({menu:e.menu===t?null:t})},I=[0,1,2],W=[{titulo:"Una libreta para cada parte de tu vida",texto:"Personal, familia, negocio: cuentas separadas, cada una con sus movimientos, presupuesto y metas.",fondo:"linear-gradient(150deg, oklch(0.852 0.147 93), oklch(0.62 0.15 115))"},{titulo:"Comparte sin perder el control",texto:"Invita a quien quieras y decide si puede editar, solo registrar gastos o solo mirar.",fondo:"linear-gradient(150deg, oklch(0.66 0.14 150), oklch(0.34 0.08 158))"},{titulo:"Tu panel, como tú lo entiendas",texto:"Agrega y quita gráficos hasta que el resumen tenga sentido para ti. Si lo dañas, se restaura en un clic.",fondo:"linear-gradient(150deg, oklch(0.72 0.14 300), oklch(0.38 0.10 290))"}],U={tema:u,esOnboarding:e.paso==="onboarding",esAuth:e.paso==="auth",esApp:e.paso==="app",slide:W[e.slideIdx],dots:I.map(t=>({w:t===e.slideIdx?26:8,bg:t===e.slideIdx?"oklch(0.28 0.07 155)":"oklch(0.89 0.02 95)",go:()=>o.setState({slideIdx:t})})),demoBarras:[{label:"Vivienda",w:78,c:C[1]},{label:"Alimentación",w:62,c:C[4]},{label:"Deudas",w:88,c:O},{label:"Ahorro",w:34,c:Se}],irCrearCuenta:()=>o.setState({paso:"auth",authModo:"registro",authError:""}),irLogin:t=>{t&&t.preventDefault&&t.preventDefault(),o.setState({paso:"auth",authModo:"login",authError:""})},volverOnboarding:()=>o.setState({paso:e.sesion?"app":"onboarding",authError:""}),esRegistro:e.authModo==="registro",authTitulo:e.authModo==="registro"?"Crea tu cuenta Chinola":"Bienvenido de vuelta",authTexto:e.authModo==="registro"?"Con tu cuenta creas libretas, las compartes y las ves igual en la web y en el celular.":"Entra con tu correo para recuperar tus libretas.",authBoton:e.authModo==="registro"?"Crear cuenta":"Iniciar sesión",authSwitchTexto:e.authModo==="registro"?"¿Ya tienes cuenta?":"¿Aún no tienes cuenta?",authSwitchLink:e.authModo==="registro"?"Iniciar sesión":"Crear una",switchAuth:t=>{t&&t.preventDefault&&t.preventDefault(),o.setState({authModo:e.authModo==="registro"?"login":"registro",authError:""})},auth:e.auth,authError:!!e.authError,authErrorTexto:e.authError,onAuth:{nombre:this.campo("auth","nombre"),email:this.campo("auth","email"),pass:this.campo("auth","pass")},enviarAuth:()=>{const t=e.auth;if(!/.+@.+\..+/.test(String(t.email))){o.setState({authError:"Escribe un correo válido."});return}if(String(t.pass).length<4){o.setState({authError:"La contraseña debe tener al menos 4 caracteres."});return}if(e.authModo==="registro"){if(!String(t.nombre).trim()){o.setState({authError:"Escribe tu nombre."});return}o.entrar(String(t.email).trim().toLowerCase(),String(t.nombre).trim(),!1)}else{const s=String(t.email).trim().toLowerCase();let b=!1;try{b=!!localStorage.getItem(Ke+":"+s)}catch{}if(!b){o.setState({authError:"No hay libretas guardadas para ese correo en este navegador."});return}o.entrar(s,s.split("@")[0],!0)}}};if(e.paso!=="app"||!e.libretas.length)return Object.assign(U,{libreta:{nombre:"",inicial:"",color:re,detalle:""},libretas:[],navItems:[],widgets:[],mascota:ne.auto,balanceFmt:"",balanceColor:re,mesLargo:"",mesCorto:"",viewLabel:"",tourOpen:!1,formOpen:!1});const p=this.lb(),X=this.rol(),_=X==="Dueño"||X==="Editor",Ee=_||X==="Registrador",A=this.totales(p,e.mes,!0),[q,J]=e.mes.split("-").map(Number),ge=t=>{const s=p.categorias.filter(b=>b.nombre===t)[0];return s?s.color:C[6]},Y={};p.tx.filter(t=>o.enPeriodo(t.fecha,e.mes,!0)&&t.tipo!=="Ingreso"&&t.tipo!=="Transferencia").forEach(t=>{Y[t.categoria]=(Y[t.categoria]||0)+t.monto});const me=Object.keys(Y).sort((t,s)=>Y[s]-Y[t]),he=me.length?Y[me[0]]:0,ae=[];for(let t=5;t>=0;t--){const s=new Date(q,J-1-t,1),b=this.totales(p,Ae(s));ae.push({label:At[s.getMonth()],labelLoc:g(s.getMonth(),!0),ing:b.ing,gas:b.gas+b.aho})}const fe=Math.max.apply(null,ae.map(t=>Math.max(t.ing,t.gas)).concat([1])),de=p.cuentas.map(t=>({id:"cuenta:"+t.id,label:t.efectivo?"Efectivo ("+i(t.saldo)+")":t.nombre})).concat(p.tarjetas.map(t=>({id:"tarjeta:"+t.id,label:t.nombre+" ••••"+t.last4}))),_e=t=>{const s=de.filter(b=>b.id===t)[0];return s?s.label:"Efectivo"},Z=e.q.toLowerCase(),Pe=t=>Number(String(t&&t.id||"").replace(/^\D+/,"").slice(0,13))||0,be=p.tx.filter(t=>o.enPeriodo(t.fecha,e.mes,!0)).filter(t=>e.filtro==="Todos"||(e.filtro==="Ingresos"?t.tipo==="Ingreso":e.filtro==="Fijos"?t.tipo==="Gasto Fijo":e.filtro==="Variables"?t.tipo==="Gasto Variable":t.tipo==="Ahorro")).filter(t=>!Z||(t.concepto+" "+t.categoria).toLowerCase().indexOf(Z)>=0).sort((t,s)=>t.fecha!==s.fecha?t.fecha<s.fecha?1:-1:Pe(s)-Pe(t)),Le=t=>{const s=t.tipo==="Ingreso"?F:t.tipo==="Ahorro"?Se:t.tipo==="Transferencia"?r.gris:O,b=new Date(t.fecha+"T00:00:00");return Object.assign({},t,{color:s,tipoCorto:t.tipo==="Ingreso"?l("ingresos"):t.tipo==="Gasto Fijo"?l("fijos"):t.tipo==="Gasto Variable"?l("variables"):t.tipo==="Transferencia"?"Traspaso":l("ahorro"),tipoBg:t.tipo==="Ingreso"?"oklch(0.95 0.05 152)":t.tipo==="Ahorro"?"oklch(0.96 0.04 300)":t.tipo==="Transferencia"?r.suave:"oklch(0.96 0.04 30)",catColor:ge(t.categoria),inicial:se(t.categoria),iconoPath:S(t.categoria)[1],iconoBg:"color-mix(in oklab, "+ge(t.categoria)+" 15%, transparent)",montoFmt:(t.tipo==="Transferencia"?"":t.tipo==="Ingreso"?"+":"−")+i(t.monto),fechaFmt:b.getDate()+" "+g(b.getMonth(),!0),recSuf:t.recurrente?" ↻":"",medioNombre:_e(t.medio||"efectivo"),menuOpen:e.menu==="tx"+t.id,menuBg:e.menu==="tx"+t.id?r.suave:"transparent",onMenu:x=>{x.stopPropagation(),o.setState({menu:e.menu==="tx"+t.id?null:"tx"+t.id})},onEdit:()=>o.setState({formOpen:!0,menu:null,form:Object.assign({},t,{monto:String(t.monto)})}),onDup:()=>o.setLb({tx:p.tx.concat([Object.assign({},t,{id:Ce()})])}),onDelete:()=>{const x=o.aplica(p,t,-1);o.setLb(Object.assign({tx:p.tx.filter(m=>m.id!==t.id)},x)),o.setState({menu:null})}})},n=p.tarjetas.map(t=>({titulo:"Pago "+t.nombre,detalle:i(t.saldo)+" · corte día "+t.corte,d:He(t.pago)})).concat(p.prestamos.filter(t=>t.total-t.pagado>0).map(t=>({titulo:"Cuota "+t.nombre,detalle:i(t.cuota)+" · "+o.t("venceDia")+" "+t.dia,d:He(t.dia)}))).sort((t,s)=>t.d-s.d).map(t=>({titulo:t.titulo,detalle:t.detalle,plazo:t.d===0?"hoy":"en "+t.d+" d",color:t.d<=3?O:t.d<=7?ee:F})),k=p.tarjetas.reduce((t,s)=>t+s.saldo,0),T=p.tarjetas.reduce((t,s)=>t+s.limite,0),v=p.prestamos.reduce((t,s)=>t+Math.max(0,s.total-s.pagado),0),h=p.prestamos.reduce((t,s)=>t+(s.total-s.pagado>0?s.cuota:0),0),H=p.cuentas.reduce((t,s)=>t+s.saldo,0)-k-v,R=p.categorias.filter(t=>!t.ingreso&&t.nombre!=="Ahorro").map(t=>{const s=Number(p.presupuesto[t.nombre]||0),b=Y[t.nombre]||0,x=s>0?Math.round(b/s*100):0,m=s>0&&b>s;return{nombre:t.nombre,catColor:t.color,limite:String(s),limiteFmt:i(s),gastadoFmt:i(b),iconoPath:z(t)[1],iconoBg:"color-mix(in oklab, "+t.color+" 14%, transparent)",menuOpen:e.menu==="cat"+t.id,menuBg:e.menu==="cat"+t.id?r.suave:"transparent",onMenu:d=>{d&&d.stopPropagation&&d.stopPropagation(),o.setState({menu:e.menu==="cat"+t.id?null:"cat"+t.id})},acciones:[{label:o.trStr("Editar categoría"),color:r.tinta,go:()=>o.setState({menu:null,catModal:!0,catForm:{id:t.id,nombre:t.nombre,color:t.color,icono:t.icono||et[t.nombre]||"puntos",limite:String(s),ingreso:!!t.ingreso}})},{label:o.trStr("Ver sus movimientos"),color:r.tinta,go:()=>o.setState({menu:null,vista:"movs",q:t.nombre})},{label:o.trStr("Eliminar categoría"),color:O,go:()=>{o.setLb({categorias:p.categorias.filter(d=>d.id!==t.id),tx:p.tx.map(d=>d.categoria===t.nombre?Object.assign({},d,{categoria:"Otros"}):d)}),o.setState({menu:null})}}],pct:Math.min(100,x),color:m?O:x>85?ee:F,restanteFmt:m?"−"+i(b-s):i(s-b)+" "+o.t("libre"),onChange:d=>o.setLb({presupuesto:Object.assign({},p.presupuesto,{[t.nombre]:Number(d.target.value||0)})}),onDelete:()=>o.setLb({categorias:p.categorias.filter(d=>d.id!==t.id),tx:p.tx.map(d=>d.categoria===t.nombre?Object.assign({},d,{categoria:"Otros"}):d)})}}),xe=R.reduce((t,s)=>t+Number(s.limite),0),Me=R.filter(t=>Number(t.limite)>0&&(Y[t.nombre]||0)>Number(t.limite)),ve=n.filter(t=>t.color===O).length,De=p.metas.map(t=>{const s=Math.max(0,t.meta-t.ahorrado),b=t.mensual>0?Math.ceil(s/t.mensual):0;return Object.assign({},t,{color:t.color||Se,pct:f(t.ahorrado,t.meta),pctLabel:f(t.ahorrado,t.meta)+"%",metaFmt:i(t.meta),ahorradoFmt:i(t.ahorrado),restanteFmt:i(s),mensualFmt:i(t.mensual),proyeccion:s===0?"completada":"listo en ~"+b+" meses",onAportar:()=>{t.mensual&&(o.festeja(t.ahorrado+t.mensual>=t.meta?"¡Meta cumplida!":"¡Vas subiendo!",t.nombre+" · "+i(t.mensual)),o.setLb({metas:p.metas.map(x=>x.id===t.id?Object.assign({},x,{ahorrado:x.ahorrado+t.mensual}):x),tx:p.tx.concat([o.txAuto("Aporte "+t.nombre,"Ahorro","Ahorro",t.mensual)])}))},onDelete:()=>o.setLb({metas:p.metas.filter(x=>x.id!==t.id)})})}),It=t=>{const s=Et.filter(b=>b[0]===t)[0];return s?s[1]:t},Rt=(p.panel||Ue).map((t,s)=>{const b=typeof window<"u"&&window.innerWidth<760?1:typeof window<"u"&&window.innerWidth<1100?2:4,x=e.arrastra===t.id,m={titulo:It(t.tipo),span:Math.min(t.ancho,b),gap:14,borde:e.sobre===t.id&&!x?"2px dashed "+re:"1px solid "+r.borde,opacidad:x?.45:1,cursor:e.editorOpen?"grab":"default",onDragStart:()=>o.setState({arrastra:t.id}),onDragOver:d=>{e.editorOpen&&(d.preventDefault(),e.sobre!==t.id&&o.setState({sobre:t.id}))},onDragEnd:()=>o.setState({arrastra:null,sobre:null}),onDrop:d=>{d&&d.preventDefault&&d.preventDefault();const c=(p.panel||[]).slice(),M=c.findIndex(V=>V.id===e.arrastra),L=c.findIndex(V=>V.id===t.id);if(M<0||L<0||M===L){o.setState({arrastra:null,sobre:null});return}const[G]=c.splice(M,1);c.splice(L,0,G),o.setLb({panel:c}),o.setState({arrastra:null,sobre:null})},anchoLabel:t.ancho===1?"1/4":t.ancho===2?"1/2":"Full",onAncho:()=>{const d=t.ancho===1?2:t.ancho===2?4:1;o.setLb({panel:(p.panel||[]).map(c=>c.id===t.id?Object.assign({},c,{ancho:d}):c)})},onSubir:()=>{const d=(p.panel||[]).slice();if(s<=0)return;const c=d[s-1];d[s-1]=d[s],d[s]=c,o.setLb({panel:d})},onQuitar:()=>o.setLb({panel:(p.panel||[]).filter(d=>d.id!==t.id)})};if(t.tipo.indexOf("kpi-")===0){const c={"kpi-ingresos":[i(A.ing),"del mes",F],"kpi-gastos":[i(A.gas),(A.ing>0?Math.round(A.gas/A.ing*100):0)+"% de tus ingresos",O],"kpi-balance":[i(A.bal),A.bal>=0?"disponible":"déficit",A.bal>=0?r.tinta:O],"kpi-deuda":[i(k+v),"tarjetas + préstamos",ee],"kpi-patrimonio":[i(H),"cuentas − deudas",H>=0?r.tinta:O]}[t.tipo];return Object.assign(m,{esCifra:!0,valor:c[0],nota:c[1],color:c[2],gap:6})}if(t.tipo==="serie-tiempo"){const d=Object.assign({grafico:"linea",rango:12,series:["ingresos","gastos"]},t.cfg||{}),c=w=>o.setLb({panel:(p.panel||[]).map(N=>N.id===t.id?Object.assign({},N,{cfg:Object.assign({},d,w)}):N)}),M=Number(d.rango)||12,L=[];for(let w=M-1;w>=0;w--){const N=new Date(q,J-1-w,1),$=o.totales(p,Ae(N));L.push({label:g(N.getMonth(),!0),anio:String(N.getFullYear()).slice(2),t:$})}const G=(w,N)=>N==="ingresos"?w.ing:N==="gastos"?w.gas:N==="balance"?w.bal:N==="ahorro"?w.aho:w.ing-w.gas-w.aho,V=d.series.length?d.series:["ingresos"];let Qe=1,Oe=0;V.forEach(w=>L.forEach(N=>{const $=G(N.t,w);$>Qe&&(Qe=$),$<Oe&&(Oe=$)}));const Ie=40,Vt=Qe-Oe||1,ut=w=>L.length>1?w*(100/(L.length-1)):50,Re=w=>1+(Ie-2)*(1-(w-Oe)/Vt),gt=[],mt=[],ht=[],ft=[],bt=[];V.forEach((w,N)=>{const $=o.colorSerie(w),qe=L.map((K,je)=>ut(je).toFixed(2)+","+Re(G(K.t,w)).toFixed(2)).join(" ");if(bt.push({label:rt[w].label,color:$,ultimo:i(G(L[L.length-1].t,w))}),d.grafico==="linea"||d.grafico==="area")gt.push({puntos:qe,color:$}),d.grafico==="area"&&mt.push({puntos:"0,"+Ie+" "+qe+" 100,"+Ie,color:$});else if(d.grafico==="puntos")L.forEach((K,je)=>ht.push({x:ut(je).toFixed(2),y:Re(G(K.t,w)).toFixed(2),color:$}));else{const K=100/L.length,je=d.grafico==="barras"?K*.62:K*.62/V.length;L.forEach((Ut,xt)=>{const Ht=G(Ut.t,w),vt=Re(Math.max(0,Oe)),yt=Re(Ht),_t=d.grafico==="barras"?xt*K+K*.19:xt*K+K*.19+N*je;ft.push({x:_t.toFixed(2),y:Math.min(vt,yt).toFixed(2),w:je.toFixed(2),h:Math.max(.6,Math.abs(vt-yt)).toFixed(2),color:$})})}});const $t=Math.max(1,Math.ceil(L.length/8));return Object.assign(m,{esSerie:!0,configurable:e.editorOpen,cfgGrafico:d.grafico,cfgRango:String(d.rango),onGrafico:w=>c({grafico:w.target.value}),onRango:w=>c({rango:Number(w.target.value)}),seriesToggles:Object.keys(rt).map(w=>({label:rt[w].label,color:o.colorSerie(w),bg:d.series.indexOf(w)>=0?r.card:"transparent",fg:d.series.indexOf(w)>=0?r.tinta:r.gris,border:d.series.indexOf(w)>=0?r.tinta:r.borde,go:()=>{const $=d.series.indexOf(w)>=0?d.series.filter(qe=>qe!==w):d.series.concat([w]);c({series:$.length?$:[w]})}})),lineas:gt,areas:mt,puntosSvg:ht,barrasSvg:ft,leyenda:bt,guias:[.25,.5,.75].map(w=>({y:(1+(Ie-2)*w).toFixed(2),color:r.borde})),etiquetas:L.map((w,N)=>N%$t===0||N===L.length-1?w.label+" "+w.anio:""),gap:12})}if(t.tipo==="barras-categorias")return Object.assign(m,{esBarras:!0,filas:me.slice(0,6).map(d=>({label:d,valor:i(Y[d]),pct:f(Y[d],he),color:ge(d)}))});if(t.tipo==="columnas-tendencia")return Object.assign(m,{esColumnas:!0,columnas:ae.map(d=>({label:d.labelLoc||d.label,a:Math.max(3,Math.round(d.ing/fe*100)),b:Math.max(3,Math.round(d.gas/fe*100)),colorA:o.colorSerie("ingresos"),colorB:o.colorSerie("gastos")})),leyenda:[{label:l("ingresos"),color:o.colorSerie("ingresos")},{label:l("gastos"),color:o.colorSerie("gastos")}]});if(t.tipo==="dona-mezcla"){const d=A.gas+A.aho,c=f(A.fij,d),M=f(A.vari,d);return Object.assign(m,{esDona:!0,total:i(d),dona:"conic-gradient("+o.colorSerie("fijos")+" 0% "+c+"%, "+o.colorSerie("gastos")+" "+c+"% "+(c+M)+"%, "+o.colorSerie("ahorro")+" "+(c+M)+"% 100%)",filas:[{label:"Fijos",valor:i(A.fij),color:o.colorSerie("fijos")},{label:"Variables",valor:i(A.vari),color:o.colorSerie("gastos")},{label:"Ahorro",valor:i(A.aho),color:o.colorSerie("ahorro")}]})}return t.tipo==="lista-recientes"?Object.assign(m,{esLista:!0,items:be.slice(0,6).map(d=>{const c=Le(d);return{sigla:c.inicial,color:c.catColor,iconoPath:c.iconoPath,iconoBg:c.iconoBg,tieneIcono:!0,sinIcono:!1,titulo:c.concepto,detalle:c.categoria+" · "+c.fechaFmt,monto:c.montoFmt,montoColor:c.color}})}):t.tipo==="lista-recordatorios"?Object.assign(m,{esLista:!0,items:n.map(d=>({sigla:"!",color:d.color,iconoBg:"color-mix(in oklab, "+d.color+" 15%, transparent)",tieneIcono:!1,sinIcono:!0,titulo:d.titulo,detalle:d.detalle,monto:d.plazo,montoColor:d.color}))}):t.tipo==="lista-metas"?Object.assign(m,{esLista:!0,items:De.map(d=>({sigla:se(d.nombre),color:d.color,iconoBg:"color-mix(in oklab, "+d.color+" 15%, transparent)",tieneIcono:!1,sinIcono:!0,titulo:d.nombre,detalle:d.ahorradoFmt+" · "+d.metaFmt,monto:d.pctLabel,montoColor:d.color}))}):Object.assign(m,{esTexto:!0,texto:A.bal<0?"Este mes va corto: los gastos superan lo que entró. Empieza por los variables, ahí hay más margen.":h>0?"Tus cuotas fijas son "+i(h)+", un "+(A.ing>0?Math.round(h/A.ing*100):0)+"% de tus ingresos. Bajar de 30% te deja aire para ahorrar.":"Sin cuotas de préstamo este mes: buen momento para subir el aporte a tus metas."})});let D=e.personaje;e.personaje==="auto"&&(D=A.bal<0?"rota":ve>0?"estudiosa":De.some(t=>t.pct>=100)?"fiesta":A.bal>A.ing*.25?"jugo":"fuerte");const ye=ne[D]||ne.auto,ct={rota:"Se me salen las semillas: el mes va en rojo.",estudiosa:"Ojo, que vienen pagos. Yo te aviso.",fiesta:"¡Meta cumplida! Eso se celebra.",jugo:"Mes tranquilo, hasta me volví jugo.",fuerte:"Vamos bien, sigue registrando."},qt=e.libretas.filter(t=>t.__estado!=="pendiente").map(t=>{const s=t.miembros.filter(b=>b.email===e.sesion.email)[0];return{nombre:t.nombre,inicial:se(t.nombre),color:t.color,rol:s?s.rol:"Lector",detalle:t.tipo+" · "+t.miembros.length+" persona(s)",bg:t.id===e.activa?r.suave:r.card,go:()=>o.guardar({activa:t.id,selectorOpen:!1,vista:"panel",menu:null})}}),Ye=String(e.form.fecha||it()).split("-"),oe={anio:Ye[0],mes:Ye[1],dia:Ye[2]},Gt=[["panel",l("panel"),"PN",""],["movs",l("movs"),"MV",String(p.tx.filter(t=>o.enPeriodo(t.fecha,e.mes,!0)).length)],["cuentas",l("cuentas"),"CT",String(p.cuentas.length+p.tarjetas.length)],["presupuesto",l("presupuesto"),"PR",Me.length?String(Me.length)+"⚠":""],["metas",l("metas"),"MT",String(p.metas.length)],["libretas",l("libretas"),"LB",String(e.libretas.length)],["ajustes",l("ajustes"),"AJ",""]],We=e.libretas.map(t=>{const s=t.miembros.filter(c=>c.email===e.sesion.email)[0],b=s?s.rol:"Lector",x=b==="Dueño",m=this.totales(t,e.mes,!0),d=t.tarjetas.reduce((c,M)=>c+M.saldo,0)+t.prestamos.reduce((c,M)=>c+Math.max(0,M.total-M.pagado),0);return{id:t.id,nombre:t.nombre,inicial:se(t.nombre),color:t.color,tipo:o.trStr(t.tipo),rol:o.trStr(b),esDueno:x,esActiva:t.id===e.activa,filaBg:t.id===e.libretaVista?r.suave:"transparent",puedeAbrir:t.id!==e.activa,rolBg:x?"oklch(0.95 0.05 152)":r.suave,rolFg:x?F:r.gris,stats:t.tx.length+" movimientos · "+t.miembros.length+" persona(s)",conteoMiembros:t.miembros.length+" persona(s)",avatares:t.miembros.slice(0,3).map(c=>({inicial:se(c.nombre||c.email),bg:c.rol==="Dueño"?"oklch(0.42 0.10 155)":c.rol==="Editor"?C[1]:c.rol==="Registrador"?C[4]:C[6]})),kpis:[{label:o.trStr("Balance del mes"),valor:i(m.bal),color:m.bal>=0?r.tinta:O},{label:o.trStr("Ingresos del mes"),valor:i(m.ing),color:F},{label:o.trStr("Gastos del mes"),valor:i(m.gas),color:O},{label:o.trStr("Deuda total"),valor:i(d),color:ee}],onEntrar:()=>o.setState({libretaVista:t.id}),onAbrir:()=>o.guardar({activa:t.id,vista:"panel",libretaVista:null}),onEliminar:()=>{if(e.libretas.length<2)return;const c=e.libretas.filter(M=>M.id!==t.id);o.guardar({libretas:c,activa:c[0].id})},pendiente:t.__estado==="pendiente"&&!x,compartida:!x&&t.__estado!=="pendiente",puedeAbrir:t.id!==e.activa&&t.__estado!=="pendiente",onSalir:()=>o.salirDeLibreta(t.id),onAceptar:()=>o.aceptaInvitacion(t.id),onRechazar:()=>o.rechazaInvitacion(t.id),miembros:t.miembros.map(c=>({nombre:c.nombre||c.email.split("@")[0],email:c.email,inicial:se(c.nombre||c.email),rol:c.rol,yoSuf:c.email===e.sesion.email?" "+o.t("yo"):"",avatarBg:c.rol==="Dueño"?"oklch(0.42 0.10 155)":c.rol==="Editor"?C[1]:c.rol==="Registrador"?C[4]:C[6],rolLabel:o.trStr(c.rol),permisos:o.trStr($e[c.rol]),editable:x&&c.email!==e.sesion.email,fijo:!(x&&c.email!==e.sesion.email),onRol:M=>{const L=M.target.value;o.guardar({libretas:e.libretas.map(G=>G.id===t.id?Object.assign({},G,{miembros:G.miembros.map(V=>V.email===c.email?Object.assign({},V,{rol:L}):V)}):G)})},onQuitar:()=>o.guardar({libretas:e.libretas.map(M=>M.id===t.id?Object.assign({},M,{miembros:M.miembros.filter(L=>L.email!==c.email)}):M)})}))}}),pe=[];A.bal<0&&pe.push({titulo:"Balance negativo",detalle:"Los gastos de este mes superan lo que entró ("+i(Math.abs(A.bal))+" de más).",plazo:"ahora",color:O,go:()=>o.setState({vista:"movs",notisOpen:!1})}),n.filter(t=>t.color===O||t.color===ee).forEach(t=>{pe.push({titulo:t.titulo,detalle:t.detalle,plazo:t.plazo,color:t.color,go:()=>o.setState({vista:"cuentas",notisOpen:!1})})}),Me.forEach(t=>{pe.push({titulo:t.nombre+" sobre el presupuesto",detalle:"Llevas "+t.gastadoFmt+" de "+t.limiteFmt+" presupuestado.",plazo:"presupuesto",color:O,go:()=>o.setState({vista:"presupuesto",notisOpen:!1})})}),pe.length||pe.push({titulo:"Todo tranquilo",detalle:"Sin pagos próximos ni categorías excedidas en esta libreta.",plazo:"",color:F,go:()=>o.setState({notisOpen:!1})});const pt=p.tx.filter(t=>t.fecha.slice(0,4)===String(q)),Je=pt.filter(t=>t.tipo==="Ingreso").reduce((t,s)=>t+s.monto,0),Fe=pt.filter(t=>t.tipo!=="Ingreso").reduce((t,s)=>t+s.monto,0);return this.trDeep(Object.assign(U,{libreta:{nombre:p.nombre,inicial:se(p.nombre),color:p.color,detalle:p.tipo+" · "+X},libretas:qt,selectorOpen:e.selectorOpen,toggleSelector:()=>o.setState({selectorOpen:!e.selectorOpen}),irLibretas:()=>o.setState({vista:"libretas",selectorOpen:!1,libretaVista:null}),navItems:Gt.map(t=>({label:t[1],sigla:t[2],badge:t[3],bg:e.vista===t[0]?"oklch(1 0 0 / 0.14)":"transparent",fg:e.vista===t[0]?"oklch(0.97 0.03 95)":"oklch(0.84 0.04 110)",icoBg:e.vista===t[0]?re:"oklch(1 0 0 / 0.14)",icoFg:e.vista===t[0]?"oklch(0.24 0.05 155)":"oklch(0.86 0.06 110)",badgeFg:"oklch(0.82 0.05 110)",go:()=>o.setState({vista:t[0],menu:null,agregar:null,selectorOpen:!1,libretaVista:null})})),esPanel:e.vista==="panel",esTx:e.vista==="movs",esCuentas:e.vista==="cuentas",esPresupuesto:e.vista==="presupuesto",esMetas:e.vista==="metas",esAjustes:e.vista==="ajustes",esLibretasLista:e.vista==="libretas"&&!e.libretaVista,esLibretaDetalle:e.vista==="libretas"&&!!e.libretaVista,detalle:We.filter(t=>t.id===e.libretaVista)[0]||We[0]||{},volverLibretas:()=>o.setState({libretaVista:null}),invModal:e.invModal,invForm:e.invForm,tituloInvitar:o.trStr("Invitar a la libreta"),abrirInvitar:()=>o.setState({invModal:!0,invForm:{email:"",nombre:"",rol:"Editor"}}),cerrarInvitar:()=>o.setState({invModal:!1}),onInv:{email:this.campo("invForm","email"),nombre:this.campo("invForm","nombre")},invRoles:ot.filter(t=>t!=="Dueño").map(t=>({label:o.trStr(t),detalle:o.trStr($e[t]),bg:e.invForm.rol===t?"color-mix(in oklab, "+re+" 16%, transparent)":r.suave,border:e.invForm.rol===t?re:"transparent",go:()=>o.setState({invForm:Object.assign({},e.invForm,{rol:t})})})),enviarInvitacion:()=>{const t=String(e.invForm.email).trim().toLowerCase(),s=e.libretas.filter(b=>b.id===e.libretaVista)[0];!s||!/.+@.+\..+/.test(t)||s.miembros.some(b=>b.email===t)||(o.guardar({libretas:e.libretas.map(b=>b.id===s.id?Object.assign({},b,{miembros:b.miembros.concat([{email:t,nombre:String(e.invForm.nombre).trim()||t.split("@")[0],rol:e.invForm.rol}])}):b),invModal:!1}),o.festeja("Invitación enviada",t))},viewLabel:l(e.vista==="movs"?"movs":e.vista),txt:{nuevoMov:l("nuevoMov"),buscar:l("buscar"),hCuentas:l("hCuentas"),hTarjetas:l("hTarjetas"),hPrestamos:l("hPrestamos"),metasTitulo:l("metas"),libretasTitulo:l("libretas"),limiteCat:l("limiteCat"),limiteCatSub:l("limiteCatSub"),notificaciones:l("notificaciones"),idioma:l("idioma"),tema:l("tema"),balanceMes:l("balanceMes"),tasaAhorro:l("tasaAhorro"),personaje:l("personaje"),cerrarSesion:l("cerrarSesion"),resumenAnio:l("resumenAnio"),guardarMov:l("guardarMov"),concepto:l("concepto"),categoria:l("categoria"),pagadoCon:l("pagadoCon"),fecha:l("fecha"),repetir:l("repetir"),enUso:l("enUso"),miembros:l("miembros"),correo:l("correo"),permisos:l("permisos"),libretas:l("libretas"),cuotaLabel:l("cuotaLabel"),aporteMensual:l("aporteMensual"),copiarCats:l("copiarCats"),meta:l("meta"),ahorrado:l("ahorrado"),falta:l("falta"),aportar:l("aportar"),monto:l("monto"),tipo:l("tipo"),deudaActual:l("deudaActual"),corteDia:l("corteDia"),pagoDia:l("pagoDia"),usoLimite:l("usoLimite"),abrir:l("abrir"),agregarCat:l("agregarCat"),pagadoRing:l("pagadoRing"),temaDesc:l("temaDesc"),personajeDesc:l("personajeDesc"),editar:l("editar"),duplicar:l("duplicar"),eliminar:l("eliminar"),invitar:l("invitar"),soloLectura:l("soloLectura"),rolTu:l("rolTu"),libretasSub:e.idioma==="en"?"A book is an independent set of accounts: personal, family, business. Each one has its own transactions, accounts, budget and goals, and you can invite people with different permissions.":e.idioma==="fr"?"Un carnet est un ensemble de comptes indépendant : perso, famille, entreprise. Chacun a ses opérations, comptes, budget et objectifs, et tu peux inviter des personnes avec des permissions différentes.":"Una libreta es un juego de cuentas independiente: personal, familia, negocio. Cada una tiene sus propios movimientos, cuentas, presupuesto y metas, y puedes invitar gente con permisos distintos."},idiomas:ga.map(t=>({id:t[0],label:t[1],bg:(e.idioma||"es")===t[0]?r.side:"transparent",fg:(e.idioma||"es")===t[0]?"oklch(0.96 0.03 95)":r.gris,border:(e.idioma||"es")===t[0]?r.side:r.borde,go:()=>o.guardar({idioma:t[0]})})),mesLargo:function(){const t=g(J-1,!1);return t.charAt(0).toUpperCase()+t.slice(1)+" "+q}(),mesCorto:g(J-1,!0)+" "+q,prevMes:()=>o.setState({mes:Ae(new Date(q,J-2,1)),menu:null}),nextMes:()=>o.setState({mes:Ae(new Date(q,J,1)),menu:null}),irAjustes:()=>o.setState({vista:"ajustes"}),balanceFmt:i(A.bal),balanceColor:A.bal>=0?"oklch(0.90 0.14 110)":"oklch(0.80 0.13 35)",inicialUsuario:se(e.sesion.nombre),nombreUsuario:e.sesion.nombre,correoUsuario:e.sesion.email,rolLabel:"Rol: "+X,rolTexto:$e[X],soloLectura:X==="Lector",puedeEditar:_,puedeRegistrar:Ee,puedeEditarTx:_,mascota:Object.assign({},ye,{frase:o.trStr(e.personaje==="auto"?ct[D]:ye.frase||ct.fuerte),rota:!!ye.rota,jugo:!!ye.jugo,vaso:!!ye.vaso,lentes:!!ye.lentes,pesas:!!ye.pesas,chispas:D==="fiesta"||D==="jugo",saluda:D==="fuerte"||D==="fiesta",ojoG:D==="rota"?7:D==="fiesta"?16:14,bocaGW:D==="fiesta"?26:D==="rota"?18:D==="estudiosa"?14:22,bocaGH:D==="fiesta"?16:D==="rota"?5:D==="estudiosa"?6:11,cejaTop:D==="rota"?18:D==="fiesta"?16:19,cejaIzq:D==="rota"?14:D==="estudiosa"?-8:-6,cejaDer:D==="rota"?-14:D==="estudiosa"?8:6,punto:D==="rota"?O:D==="estudiosa"?ee:F,estado:o.trStr(D==="rota"?"Mes apretado":D==="estudiosa"?"Ojo con las fechas":D==="fiesta"?"¡Celebrando!":D==="jugo"?"Todo relajado":"Buen ritmo")}),toastOpen:!!e.toast,toastTitulo:e.toast?o.trStr(e.toast.titulo):"",toastTexto:e.toast?e.toast.texto:"",hayAlertas:pe.length>0,conteoAlertas:String(pe.length),alertas:pe,notisOpen:e.notisOpen,notisBg:e.notisOpen?r.suave:r.card,toggleNotis:()=>o.setState({notisOpen:!e.notisOpen}),notisPermLabel:e.notis?"Avisos activos":"Activar avisos",notisPermColor:e.notis?F:r.gris,pedirNotis:()=>{if(typeof Notification>"u"){o.guardar({notis:!0});return}Notification.requestPermission().then(function(t){o.guardar({notis:t==="granted"})})},widgets:Rt,editorOpen:e.editorOpen,panelCols:typeof window<"u"&&window.innerWidth<760?1:typeof window<"u"&&window.innerWidth<1100?2:4,tiposGrafico:ma.map(t=>({id:t[0],label:t[1]})),rangosGrafico:ha.map(t=>({id:String(t[0]),label:t[1]})),labelEditor:e.editorOpen?l("listo"):l("personalizar"),labelRestaurar:l("restaurar"),txtAgregarWidget:o.trStr("Agregar gráfico o tarjeta"),editorBg:e.editorOpen?re:r.card,editorFg:e.editorOpen?"oklch(0.24 0.05 155)":r.tinta,toggleEditor:()=>o.setState({editorOpen:!e.editorOpen}),panelResumen:e.editorOpen?"Arrastra las tarjetas para reordenarlas, cambia su ancho o el tipo de gráfico":(p.panel||[]).length+" elementos en el panel de esta libreta",catalogo:Et.map(t=>({nombre:t[1],desc:t[2],go:()=>o.setLb({panel:(p.panel||[]).concat([Object.assign({id:Ce(),tipo:t[0],ancho:t[0]==="serie-tiempo"?4:t[0].indexOf("kpi-")===0?1:2},t[0]==="serie-tiempo"?{cfg:{grafico:"linea",rango:12,series:["ingresos","gastos"]}}:{})])})})),restaurarPanel:()=>o.setLb({panel:Ue.map(t=>Object.assign({},t))}),q:e.q,onQ:t=>o.setState({q:t.target.value}),filtros:[["Todos",l("todos")],["Ingresos",l("ingresos")],["Fijos",l("fijos")],["Variables",l("variables")],["Ahorro",l("ahorro")]].map(t=>{const s=t[0];return{label:t[1],go:()=>o.setState({filtro:s}),bg:e.filtro===s?r.side:r.card,fg:e.filtro===s?"oklch(0.96 0.03 95)":r.gris,border:e.filtro===s?r.side:r.borde}}),txVisibles:be.map(Le),conteoTx:be.length+(e.idioma==="en"?" transaction(s)":e.idioma==="fr"?" opération(s)":" movimiento(s)"),totalFiltrado:i(be.reduce((t,s)=>t+(s.tipo==="Ingreso"?s.monto:-s.monto),0)),formIconoPath:S(e.form.categoria)[1],formIconoColor:ge(e.form.categoria),formIconoBg:"color-mix(in oklab, "+ge(e.form.categoria)+" 15%, transparent)",formOpen:e.formOpen,formTitulo:e.form.id?l("editarMov"):l("nuevoMovTitulo"),form:Object.assign({},e.form,{dia:oe.dia,mes:oe.mes,anio:oe.anio}),nombresCat:p.categorias.map(t=>t.nombre),medios:de,tiposBotones:pa.map(t=>({label:l(t==="Ingreso"?"ingresos":t==="Gasto Fijo"?"fijos":t==="Gasto Variable"?"variables":"ahorro"),go:()=>o.setState({form:Object.assign({},e.form,{tipo:t})}),bg:e.form.tipo===t?r.side:r.card,fg:e.form.tipo===t?"oklch(0.96 0.03 95)":r.gris,border:e.form.tipo===t?r.side:r.borde})),onForm:{concepto:this.campo("form","concepto"),categoria:this.campo("form","categoria"),monto:this.campo("form","monto"),medio:this.campo("form","medio"),recurrente:this.campo("form","recurrente"),dia:t=>o.setState({form:Object.assign({},e.form,{fecha:oe.anio+"-"+oe.mes+"-"+String(t.target.value).padStart(2,"0")})}),mes:t=>o.setState({form:Object.assign({},e.form,{fecha:oe.anio+"-"+t.target.value+"-"+oe.dia})}),anio:t=>o.setState({form:Object.assign({},e.form,{fecha:t.target.value+"-"+oe.mes+"-"+oe.dia})})},diasMes:Array.from({length:31},(t,s)=>String(s+1).padStart(2,"0")),mesesLista:zt.map((t,s)=>({id:String(s+1).padStart(2,"0"),label:function(){const b=g(s,!1);return b.charAt(0).toUpperCase()+b.slice(1)}()})),aniosLista:[q-2,q-1,q,q+1].map(String),fechasRapidas:function(){const t=new Date,s=new Date(Date.now()-864e5),b=x=>x.toISOString().slice(0,10);return[[l("hoyChip"),b(t)],[l("ayerChip"),b(s)],[l("dia1Chip"),e.mes+"-01"]].map(x=>({label:x[0],bg:e.form.fecha===x[1]?r.side:r.card,fg:e.form.fecha===x[1]?"oklch(0.96 0.03 95)":r.gris,border:e.form.fecha===x[1]?r.side:r.borde,go:()=>o.setState({form:Object.assign({},e.form,{fecha:x[1]})})}))}(),nuevaTx:()=>o.setState({formOpen:!0,menu:null,form:{id:null,concepto:"",categoria:"Otros",tipo:"Gasto Variable",monto:"",fecha:e.mes+"-"+String(new Date().getDate()).padStart(2,"0"),medio:p.cuentas.length?"cuenta:"+p.cuentas[0].id:"efectivo",recurrente:!1}}),cerrarForm:()=>o.setState({formOpen:!1}),guardarTx:this.guardarTx,subCuentas:(e.subvista||"cuentas")==="cuentas",subTarjetas:e.subvista==="tarjetas",subPrestamos:e.subvista==="prestamos",subTabs:[["cuentas",l("tabCuentas"),p.cuentas.length],["tarjetas",l("tabTarjetas"),p.tarjetas.length],["prestamos",l("tabPrestamos"),p.prestamos.filter(t=>t.total-t.pagado>0).length]].map(t=>{const s=(e.subvista||"cuentas")===t[0];return{label:t[1],badge:String(t[2]),bg:s?r.side:"transparent",fg:s?"oklch(0.96 0.03 95)":r.gris,badgeBg:s?"oklch(1 0 0 / 0.2)":r.suave,badgeFg:s?"oklch(0.96 0.03 95)":r.gris,go:()=>o.setState({subvista:t[0],menu:null,agregar:null,editando:null,transf:null,pagando:null})}}),kpisCuentas:[{label:"En bancos",valor:i(p.cuentas.filter(t=>!t.efectivo).reduce((t,s)=>t+s.saldo,0)),nota:p.cuentas.filter(t=>!t.efectivo).length+" cuenta(s)",color:F},{label:"En efectivo",valor:i(p.cuentas.filter(t=>t.efectivo).reduce((t,s)=>t+s.saldo,0)),nota:"dinero en mano",color:ee},{label:"Deuda de tarjetas",valor:i(k),nota:f(k,T)+"% del límite",color:O},{label:"Deuda de préstamos",valor:i(v),nota:"cuotas del mes "+i(h),color:ee},{label:"Patrimonio",valor:i(H),nota:"cuentas − deudas",color:H>=0?r.tinta:O}],cuentas:p.cuentas.map(t=>{const s=m=>o.setState({libretas:e.libretas.map(d=>d.id===p.id?Object.assign({},d,{cuentas:d.cuentas.map(c=>c.id===t.id?Object.assign({},c,m):c)}):d)}),b=m=>o.setLb({cuentas:p.cuentas.map(d=>d.id===t.id?Object.assign({},d,m):d)}),x=p.cuentas.filter(m=>m.id!==t.id).map(m=>({id:"cuenta:"+m.id,label:m.nombre})).concat(p.tarjetas.map(m=>({id:"tarjeta:"+m.id,label:"Pagar "+m.nombre})));return{nombre:t.nombre,banco:t.efectivo?o.trStr("Efectivo en mano"):t.banco,color:t.color,inicial:t.efectivo?"$":se(t.nombre),saldoFmt:i(t.saldo),saldo:String(t.saldo),movs:p.tx.filter(m=>m.medio==="cuenta:"+t.id).length+" movs.",menuOpen:P("ct"+t.id),menuBg:P("ct"+t.id)?r.suave:"transparent",onMenu:B("ct"+t.id),editando:e.editando==="ct"+t.id,transfiriendo:e.transf==="ct"+t.id,destino:t.destino||(x[0]?x[0].id:""),destinos:x,montoTr:t.montoTr||"",onDestino:m=>s({destino:m.target.value}),onMontoTr:m=>s({montoTr:m.target.value}),setNombre:m=>s({nombre:m.target.value}),setBanco:m=>s({banco:m.target.value}),setSaldo:m=>s({saldo:Number(m.target.value||0)}),swatches:o.swatchList(t.color,m=>b({color:m})),onCerrar:()=>o.guardar({editando:null}),acciones:[{label:"Editar cuenta",color:r.tinta,go:()=>o.setState({editando:"ct"+t.id,transf:null,menu:null})},{label:"Nuevo movimiento aquí",color:r.tinta,go:()=>o.setState({menu:null,formOpen:!0,form:{id:null,concepto:"",categoria:"Otros",tipo:"Gasto Variable",monto:"",fecha:e.mes+"-"+String(new Date().getDate()).padStart(2,"0"),medio:"cuenta:"+t.id,recurrente:!1}})},{label:"Transferir a otra cuenta",color:r.tinta,go:()=>o.setState({transf:"ct"+t.id,editando:null,menu:null})},{label:"Ver sus movimientos",color:r.tinta,go:()=>o.setState({menu:null,vista:"movs",q:t.nombre})},{label:"Eliminar cuenta",color:O,go:()=>{o.setLb({cuentas:p.cuentas.filter(m=>m.id!==t.id)}),o.setState({menu:null})}}],onTransferir:()=>{const m=Math.abs(Number(t.montoTr||0)),d=t.destino||(x[0]?x[0].id:"");if(!m||!d)return;const c=e.mes+"-"+String(new Date().getDate()).padStart(2,"0"),M=d.indexOf("tarjeta:")===0,L={id:Ce(),concepto:M?"Pago de tarjeta":"Transferencia",categoria:M?"Deudas":"Otros",tipo:"Transferencia",monto:m,fecha:c,recurrente:!1,medio:"cuenta:"+t.id,destino:d},G=o.aplica(p,L,1);o.setLb(Object.assign({},G,{cuentas:(G.cuentas||p.cuentas).map(V=>V.id===t.id?Object.assign({},V,{montoTr:""}):V),tx:p.tx.concat([L])})),o.setState({transf:null})}}}),tarjetas:p.tarjetas.map(t=>{const s=f(t.saldo,t.limite),b=He(t.pago),x=m=>o.setState({libretas:e.libretas.map(d=>d.id===p.id?Object.assign({},d,{tarjetas:d.tarjetas.map(c=>c.id===t.id?Object.assign({},c,m):c)}):d)});return Object.assign({},t,{fondo:Pt(t.color),saldoFmt:i(t.saldo),limiteFmt:i(t.limite),uso:s,usoLabel:s+"%",usoColor:s>80?O:s>50?ee:F,plazo:b<=5?"pagar en "+b+" d":"pago en "+b+" d",abono:t.abono||"",menuOpen:P("tc"+t.id),onMenu:B("tc"+t.id),editando:e.editando==="tc"+t.id,pagando:e.pagando==="tc"+t.id,onAbono:m=>x({abono:m.target.value}),setNombre:m=>x({nombre:m.target.value}),setBanco:m=>x({banco:m.target.value}),setLimite:m=>x({limite:Number(m.target.value||0)}),setSaldo:m=>x({saldo:Number(m.target.value||0)}),setCorte:m=>x({corte:Number(m.target.value||1)}),setPago:m=>x({pago:Number(m.target.value||1)}),swatches:o.swatchList(t.color,m=>o.setLb({tarjetas:p.tarjetas.map(d=>d.id===t.id?Object.assign({},d,{color:m}):d)})),onCerrarEdit:()=>o.guardar({editando:null}),acciones:[{label:"Registrar un pago",color:r.tinta,go:()=>o.setState({pagando:"tc"+t.id,editando:null,menu:null})},{label:"Editar tarjeta",color:r.tinta,go:()=>o.setState({editando:"tc"+t.id,pagando:null,menu:null})},{label:"Nuevo gasto con esta tarjeta",color:r.tinta,go:()=>o.setState({menu:null,formOpen:!0,form:{id:null,concepto:"",categoria:"Otros",tipo:"Gasto Variable",monto:"",fecha:e.mes+"-"+String(new Date().getDate()).padStart(2,"0"),medio:"tarjeta:"+t.id,recurrente:!1}})},{label:"Ver sus movimientos",color:r.tinta,go:()=>o.setState({menu:null,vista:"movs",q:t.nombre})},{label:"Marcar como pagada",color:r.tinta,go:()=>{o.setLb({tarjetas:p.tarjetas.map(m=>m.id===t.id?Object.assign({},m,{saldo:0}):m)}),o.setState({menu:null})}},{label:"Eliminar tarjeta",color:O,go:()=>{o.setLb({tarjetas:p.tarjetas.filter(m=>m.id!==t.id)}),o.setState({menu:null})}}],onPagar:()=>{const m=Math.abs(Number(t.abono||t.saldo));m&&(o.setLb({tarjetas:p.tarjetas.map(d=>d.id===t.id?Object.assign({},d,{saldo:Math.max(0,d.saldo-m),abono:""}):d),tx:p.tx.concat([o.txAuto("Pago "+t.nombre,"Deudas","Gasto Fijo",m)])}),o.setState({pagando:null}),o.festeja(t.saldo-m<=0?"¡Tarjeta en cero!":"Pago registrado",t.nombre+" · "+i(m)))},onDelete:()=>o.setLb({tarjetas:p.tarjetas.filter(m=>m.id!==t.id)})})}),prestamos:p.prestamos.map(t=>{const s=Math.max(0,t.total-t.pagado),b=t.cuota>0?Math.ceil(s/t.cuota):0,x=f(t.pagado,t.total),m=t.color||C[2],d=c=>o.setState({libretas:e.libretas.map(M=>M.id===p.id?Object.assign({},M,{prestamos:M.prestamos.map(L=>L.id===t.id?Object.assign({},L,c):L)}):M)});return Object.assign({},t,{fondo:Pt(m),color:m,anillo:"conic-gradient(#fff 0% "+x+"%, rgba(255,255,255,0.24) "+x+"% 100%)",centro:"color-mix(in oklab, "+m+" 78%, black)",pct:x,pctLabel:x+"%",pagadoFmt:i(t.pagado),restanteFmt:i(s),cuotaFmt:i(t.cuota),plazo:s===0?o.trStr("Liquidado"):b+" "+(e.idioma==="en"?"installments":e.idioma==="fr"?"échéances":"cuotas")+" · "+o.trStr("paga en "+He(t.dia)+" d"),subtitulo:l("cuota")+" "+i(t.cuota)+" · "+l("venceDia")+" "+t.dia,cifras:[{label:"Total",valor:i(t.total),color:r.tinta},{label:"Pagado",valor:i(t.pagado),color:F},{label:"Falta",valor:i(s),color:s>0?O:F}],abono:t.abono||"",onAbono:c=>d({abono:c.target.value}),menuOpen:P("pr"+t.id),onMenu:B("pr"+t.id),editando:e.editando==="pr"+t.id,pagando:e.pagando==="pr"+t.id,setNombre:c=>d({nombre:c.target.value}),setTotal:c=>d({total:Number(c.target.value||0)}),setPagado:c=>d({pagado:Number(c.target.value||0)}),setCuota:c=>d({cuota:Number(c.target.value||0)}),setDia:c=>d({dia:Number(c.target.value||1)}),swatches:o.swatchList(m,c=>o.setLb({prestamos:p.prestamos.map(M=>M.id===t.id?Object.assign({},M,{color:c}):M)})),onCerrar:()=>o.guardar({editando:null}),acciones:[{label:"Registrar un abono",color:r.tinta,go:()=>o.setState({pagando:"pr"+t.id,editando:null,menu:null})},{label:"Pagar la cuota ("+i(t.cuota)+")",color:r.tinta,go:()=>{if(!t.cuota||s===0){o.setState({menu:null});return}o.setLb({prestamos:p.prestamos.map(c=>c.id===t.id?Object.assign({},c,{pagado:Math.min(c.total,c.pagado+t.cuota)}):c),tx:p.tx.concat([o.txAuto("Pago "+t.nombre,"Deudas","Gasto Fijo",t.cuota)])}),o.setState({menu:null})}},{label:"Editar préstamo",color:r.tinta,go:()=>o.setState({editando:"pr"+t.id,pagando:null,menu:null})},{label:"Ver sus movimientos",color:r.tinta,go:()=>o.setState({menu:null,vista:"movs",q:t.nombre})},{label:"Marcar como liquidado",color:r.tinta,go:()=>{o.setLb({prestamos:p.prestamos.map(c=>c.id===t.id?Object.assign({},c,{pagado:c.total}):c)}),o.setState({menu:null})}},{label:"Eliminar préstamo",color:O,go:()=>{o.setLb({prestamos:p.prestamos.filter(c=>c.id!==t.id)}),o.setState({menu:null})}}],onPagar:()=>{const c=Math.abs(Number(t.abono||t.cuota));!c||s===0||(o.setLb({prestamos:p.prestamos.map(M=>M.id===t.id?Object.assign({},M,{pagado:Math.min(M.total,M.pagado+c),abono:""}):M),tx:p.tx.concat([o.txAuto("Pago "+t.nombre,"Deudas","Gasto Fijo",c)])}),o.setState({pagando:null}),o.festeja(t.pagado+c>=t.total?"¡Préstamo liquidado!":"Abono registrado",t.nombre+" · "+i(c)))},onDelete:()=>o.setLb({prestamos:p.prestamos.filter(c=>c.id!==t.id)})})}),addCuenta:e.agregar==="cuenta",addTarjeta:e.agregar==="tarjeta",addPrestamo:e.agregar==="prestamo",addMeta:e.agregar==="meta",addLibreta:e.agregar==="libreta",labelAddCuenta:e.agregar==="cuenta"?"Cancelar":"+ Agregar cuenta",labelAddTarjeta:e.agregar==="tarjeta"?"Cancelar":"+ Agregar tarjeta",labelAddPrestamo:e.agregar==="prestamo"?"Cancelar":"+ Agregar préstamo",labelAddMeta:e.agregar==="meta"?"Cancelar":"+ Nueva meta",labelAddLibreta:e.agregar==="libreta"?"Cancelar":"+ Nueva libreta",toggleAddCuenta:()=>o.setState({agregar:e.agregar==="cuenta"?null:"cuenta"}),toggleAddTarjeta:()=>o.setState({agregar:e.agregar==="tarjeta"?null:"tarjeta"}),toggleAddPrestamo:()=>o.setState({agregar:e.agregar==="prestamo"?null:"prestamo"}),toggleAddMeta:()=>o.setState({agregar:e.agregar==="meta"?null:"meta"}),toggleAddLibreta:()=>o.setState({agregar:e.agregar==="libreta"?null:"libreta"}),nuevaCuenta:e.nuevaCuenta,tiposCuenta:["Cuenta de banco","Efectivo"],onCuenta:{nombre:this.campo("nuevaCuenta","nombre"),banco:this.campo("nuevaCuenta","banco"),saldo:this.campo("nuevaCuenta","saldo"),tipo:this.campo("nuevaCuenta","tipo")},agregarCuenta:()=>{const t=e.nuevaCuenta;if(!String(t.nombre).trim())return;const s=t.tipo==="Efectivo";o.setLb({cuentas:p.cuentas.concat([{id:Date.now(),nombre:String(t.nombre).trim(),banco:String(t.banco).trim()||(s?"En mano":"Banco"),saldo:Number(t.saldo||0),color:s?C[4]:t.color,efectivo:s}])}),o.setState({nuevaCuenta:{nombre:"",banco:"",saldo:"",color:C[0],tipo:"Cuenta de banco"},agregar:null})},nuevaTarjeta:e.nuevaTarjeta,onTarjeta:{nombre:this.campo("nuevaTarjeta","nombre"),banco:this.campo("nuevaTarjeta","banco"),limite:this.campo("nuevaTarjeta","limite"),saldo:this.campo("nuevaTarjeta","saldo"),corte:this.campo("nuevaTarjeta","corte"),pago:this.campo("nuevaTarjeta","pago")},agregarTarjeta:()=>{const t=e.nuevaTarjeta;String(t.nombre).trim()&&(o.setLb({tarjetas:p.tarjetas.concat([{id:Date.now(),nombre:String(t.nombre).trim(),banco:String(t.banco).trim()||"Banco",limite:Number(t.limite||0),saldo:Number(t.saldo||0),corte:Number(t.corte||20),pago:Number(t.pago||5),color:C[Math.floor(Math.random()*C.length)],last4:String(1e3+Math.floor(Math.random()*8999)),abono:""}])}),o.setState({nuevaTarjeta:{nombre:"",banco:"",limite:"",saldo:"",corte:"20",pago:"5",color:C[1]},agregar:null}))},nuevoPrestamo:e.nuevoPrestamo,onPrestamo:{nombre:this.campo("nuevoPrestamo","nombre"),total:this.campo("nuevoPrestamo","total"),pagado:this.campo("nuevoPrestamo","pagado"),cuota:this.campo("nuevoPrestamo","cuota"),dia:this.campo("nuevoPrestamo","dia")},agregarPrestamo:()=>{const t=e.nuevoPrestamo;!String(t.nombre).trim()||!Number(t.total)||(o.setLb({prestamos:p.prestamos.concat([{id:Date.now(),nombre:String(t.nombre).trim(),total:Number(t.total),pagado:Number(t.pagado||0),cuota:Number(t.cuota||0),dia:Number(t.dia||10),color:C[Math.floor(Math.random()*C.length)]}])}),o.setState({nuevoPrestamo:{nombre:"",total:"",pagado:"",cuota:"",dia:"10"},agregar:null}))},metas:De,nuevaMeta:e.nuevaMeta,onMeta:{nombre:this.campo("nuevaMeta","nombre"),meta:this.campo("nuevaMeta","meta"),mensual:this.campo("nuevaMeta","mensual")},agregarMeta:()=>{const t=e.nuevaMeta;!String(t.nombre).trim()||!Number(t.meta)||(o.setLb({metas:p.metas.concat([{id:Date.now(),nombre:String(t.nombre).trim(),meta:Number(t.meta),ahorrado:0,mensual:Number(t.mensual||0),color:[Se,F,C[1]][Math.floor(Math.random()*3)]}])}),o.setState({nuevaMeta:{nombre:"",meta:"",mensual:""},agregar:null}))},presupuestoRows:R,kpisPresupuesto:[{label:"Presupuestado",valor:i(xe),nota:"presupuesto mensual total",color:r.tinta},{label:"Gastado",valor:i(A.gas),nota:f(A.gas,xe)+"% del presupuesto",color:A.gas>xe?O:F},{label:"Disponible",valor:i(xe-A.gas),nota:Me.length+" categoría(s) excedida(s)",color:xe-A.gas>=0?r.tinta:O}],tituloAddCuenta:o.trStr("Nueva cuenta"),tituloAddTarjeta:o.trStr("Nueva tarjeta"),tituloAddPrestamo:o.trStr("Nuevo préstamo"),tituloAddMeta:o.trStr("Nueva meta de ahorro"),tituloAddLibreta:o.trStr("Nueva libreta"),catModal:e.catModal,catForm:e.catForm,catTitulo:o.trStr(e.catForm.id?"Editar categoría":"Nueva categoría"),catNombreLabel:o.trStr("Nombre"),catLimiteLabel:o.trStr("Presupuesto mensual"),catColorLabel:o.trStr("Color"),catIconoLabel:o.trStr("Icono"),catGuardar:l("guardar"),abrirCatNueva:()=>o.setState({catModal:!0,menu:null,catForm:{id:null,nombre:"",color:C[4],icono:"puntos",limite:"",ingreso:!1}}),cerrarCatModal:()=>o.setState({catModal:!1}),onCatForm:{nombre:this.campo("catForm","nombre"),limite:this.campo("catForm","limite")},catTipos:[[!1,o.trStr("Gasto")],[!0,o.trStr("Ingreso")]].map(t=>({label:t[1],bg:!!e.catForm.ingreso===t[0]?r.side:r.card,fg:!!e.catForm.ingreso===t[0]?"oklch(0.96 0.03 95)":r.gris,border:!!e.catForm.ingreso===t[0]?r.side:r.borde,go:()=>o.setState({catForm:Object.assign({},e.catForm,{ingreso:t[0]})})})),iconosLista:Object.keys(we).map(t=>({label:o.trStr(we[t][0]),path:we[t][1],bg:e.catForm.icono===t?"color-mix(in oklab, "+e.catForm.color+" 16%, transparent)":r.suave,border:e.catForm.icono===t?e.catForm.color:"transparent",stroke:e.catForm.icono===t?e.catForm.color:r.gris,go:()=>o.setState({catForm:Object.assign({},e.catForm,{icono:t})})})),guardarCat:()=>{const t=e.catForm,s=String(t.nombre).trim();if(s){if(t.id){const b=p.categorias.filter(m=>m.id===t.id)[0],x=Object.assign({},p.presupuesto);b&&b.nombre!==s&&delete x[b.nombre],x[s]=Number(t.limite||0),o.setLb({categorias:p.categorias.map(m=>m.id===t.id?Object.assign({},m,{nombre:s,color:t.color,icono:t.icono,ingreso:!!t.ingreso}):m),tx:b&&b.nombre!==s?p.tx.map(m=>m.categoria===b.nombre?Object.assign({},m,{categoria:s}):m):p.tx,presupuesto:x})}else o.setLb({categorias:p.categorias.concat([{id:Date.now(),nombre:s,color:t.color,icono:t.icono,ingreso:!!t.ingreso}]),presupuesto:Object.assign({},p.presupuesto,{[s]:Number(t.limite||0)})});o.setState({catModal:!1})}},swatchesCat:this.swatchList(e.catForm.color,t=>o.setState({catForm:Object.assign({},e.catForm,{color:t})})),txtRoles:o.trStr("Qué puede hacer cada rol"),libretasDetalle:We,roles:ot.map(t=>({id:t,label:o.trStr(t)})),tiposLibreta:["Personal","Familiar","Negocio","Proyecto"],tablaRoles:ot.map(t=>({rol:o.trStr(t),detalle:o.trStr($e[t])})),nuevaLibreta:e.nuevaLibreta,onLibreta:{nombre:this.campo("nuevaLibreta","nombre"),tipo:this.campo("nuevaLibreta","tipo"),copiar:this.campo("nuevaLibreta","copiar")},swatchesLibreta:this.swatchList(e.nuevaLibreta.color,t=>o.setState({nuevaLibreta:Object.assign({},e.nuevaLibreta,{color:t})})),agregarLibreta:()=>{const t=e.nuevaLibreta;if(!String(t.nombre).trim())return;const s=te.datosLibreta(!1);t.copiar&&(s.categorias=p.categorias.map(x=>Object.assign({},x)),s.presupuesto=Object.assign({},p.presupuesto));const b=Object.assign({id:Ce(),nombre:String(t.nombre).trim(),tipo:t.tipo,color:t.color,miembros:[{email:e.sesion.email,nombre:e.sesion.nombre,rol:"Dueño"}]},s);o.guardar({libretas:e.libretas.concat([b]),activa:b.id,agregar:null,nuevaLibreta:{nombre:"",tipo:"Personal",color:C[4],copiar:!0},vista:"panel"})},temas:Object.keys(ie).map(t=>({nombre:o.trStr(ie[t].nombre),bg:ie[t].bg,patron:ie[t].patron,side:ie[t].side,borde:e.tema===t?re:"transparent",go:()=>o.guardar({tema:t})})),personajes:["auto","fuerte","estudiosa","rota","jugo","fiesta"].map(t=>({nombre:o.trStr(ne[t].nombre),anim:ne[t].anim,ojo:ne[t].ojo,bocaW:ne[t].bocaW,bocaH:ne[t].bocaH,bocaR:ne[t].bocaR,borde:e.personaje===t?re:"transparent",go:()=>o.guardar({personaje:t})})),ajustes:[{label:"Notificaciones de pago",valor:e.notis?"Activas":"Desactivadas",sigla:"NT",bg:"oklch(0.96 0.04 70)",fg:ee,go:()=>{if(typeof Notification>"u"){o.guardar({notis:!0});return}Notification.requestPermission().then(function(t){o.guardar({notis:t==="granted"})})}},{label:"Libretas y permisos",valor:e.libretas.length+" libretas",sigla:"LB",bg:"oklch(0.96 0.03 152)",fg:F,go:()=>o.setState({vista:"libretas",libretaVista:null})},{label:"Ver el tour otra vez",valor:Q.length+" pasos",sigla:"TR",bg:"oklch(0.96 0.03 255)",fg:C[1],go:()=>o.setState({tour:0,vista:"panel"})},{label:"Exportar esta libreta a CSV",valor:p.tx.length+" movimientos",sigla:"EX",bg:"oklch(0.96 0.02 95)",fg:r.gris,go:()=>{const s=[["Concepto","Categoría","Tipo","Medio","Fecha","Monto"]].concat(p.tx.map(x=>[x.concepto,x.categoria,x.tipo,_e(x.medio||"efectivo"),x.fecha,x.monto])).map(x=>x.map(m=>'"'+String(m).replace(/"/g,'""')+'"').join(",")).join(`
`),b=document.createElement("a");b.href=URL.createObjectURL(new Blob(["\uFEFF"+s],{type:"text/csv"})),b.download="chinola-"+p.nombre+".csv",b.click()}},{label:"Restaurar panel por defecto",valor:"",sigla:"RP",bg:"oklch(0.96 0.03 300)",fg:Se,go:()=>{o.setLb({panel:Ue.map(t=>Object.assign({},t))}),o.setState({vista:"panel"})}}],resumenAnual:[{label:"Ingresos del año",valor:i(Je),color:F},{label:"Gastos del año",valor:i(Fe),color:O},{label:"Diferencia",valor:i(Je-Fe),color:Je-Fe>=0?r.tinta:O},{label:"Promedio de gasto mensual",valor:i(Fe/Math.max(1,new Date().getMonth()+1)),color:r.tinta}],cerrarSesion:()=>o.guardar({sesion:null,paso:"onboarding",libretas:[],activa:null,vista:"panel"}),tourOpen:e.tour>=0&&e.tour<Q.length,tourPaso:"Paso "+(Math.max(0,e.tour)+1)+" de "+Q.length,tourTitulo:(Q[Math.max(0,e.tour)]||Q[0]).t,tourTexto:(Q[Math.max(0,e.tour)]||Q[0]).x,tourDots:Q.map((t,s)=>({bg:s<=e.tour?F:r.borde})),tourBoton:e.tour>=Q.length-1?"Empezar":"Siguiente",tourSiguiente:()=>{const t=e.tour+1;if(t>=Q.length){o.setState({tour:-1,vista:"panel"});return}o.setState({tour:t,vista:Q[t].v})},cerrarTour:()=>o.setState({tour:-1})}))}}const Lt=j=>j==="auto"?"feliz":j,ya=["tema","personaje","idioma","notis","activa","barra","moneda","centavos","paleta"],nt=[{id:"clasica",nombre:"Clásica",pista:"La de siempre",positivo:"oklch(0.52 0.13 152)",negativo:"oklch(0.62 0.16 30)",ahorro:"oklch(0.56 0.14 300)",aviso:"oklch(0.66 0.14 70)",balance:"oklch(0.46 0.11 255)"},{id:"semaforo",nombre:"Semáforo",pista:"Verde y rojo francos",positivo:"oklch(0.55 0.17 145)",negativo:"oklch(0.55 0.21 27)",ahorro:"oklch(0.55 0.16 285)",aviso:"oklch(0.72 0.16 80)",balance:"oklch(0.48 0.15 258)"},{id:"sobria",nombre:"Sobria",pista:"Los mismos, más callados",positivo:"oklch(0.48 0.07 152)",negativo:"oklch(0.52 0.09 30)",ahorro:"oklch(0.50 0.07 290)",aviso:"oklch(0.58 0.07 75)",balance:"oklch(0.48 0.07 255)"},{id:"daltonica",nombre:"Azul y naranja",pista:"Se distinguen con daltonismo",positivo:"oklch(0.52 0.14 245)",negativo:"oklch(0.63 0.16 55)",ahorro:"oklch(0.50 0.10 285)",aviso:"oklch(0.58 0.10 200)",balance:"oklch(0.40 0.09 265)"},{id:"fria",nombre:"Fría",pista:"Del azul al violeta",positivo:"oklch(0.55 0.13 195)",negativo:"oklch(0.52 0.16 315)",ahorro:"oklch(0.50 0.13 260)",aviso:"oklch(0.60 0.11 230)",balance:"oklch(0.48 0.13 265)"},{id:"calida",nombre:"Cálida",pista:"Oliva y terracota",positivo:"oklch(0.54 0.11 125)",negativo:"oklch(0.53 0.13 40)",ahorro:"oklch(0.55 0.10 60)",aviso:"oklch(0.63 0.12 85)",balance:"oklch(0.48 0.09 250)"},{id:"chinola",nombre:"Chinola",pista:"Los de la marca",positivo:"oklch(0.46 0.12 152)",negativo:"oklch(0.58 0.17 35)",ahorro:"oklch(0.52 0.14 300)",aviso:"oklch(0.70 0.15 88)",balance:"oklch(0.44 0.11 255)"},{id:"contraste",nombre:"Alto contraste",pista:"Lo más separado posible",positivo:"oklch(0.44 0.18 148)",negativo:"oklch(0.46 0.23 25)",ahorro:"oklch(0.42 0.20 295)",aviso:"oklch(0.62 0.18 75)",balance:"oklch(0.38 0.18 262)"},{id:"menta",nombre:"Menta y rosa",pista:"Suave, sin gritar",positivo:"oklch(0.56 0.12 175)",negativo:"oklch(0.58 0.15 5)",ahorro:"oklch(0.56 0.11 320)",aviso:"oklch(0.66 0.12 90)",balance:"oklch(0.50 0.11 250)"},{id:"sin_color",nombre:"Sin color",pista:"Para los temas sombríos",positivo:"oklch(0.42 0 0)",negativo:"oklch(0.62 0 0)",ahorro:"oklch(0.52 0 0)",aviso:"oklch(0.70 0 0)",balance:"oklch(0.32 0 0)"}],st="chinola-barra",ka="oklch(0.62 0.16 30)",wa=new Set(["noche","noche_semillas","carbon","medianoche","sombrio","chinola_noche","ciruela","cafe_noche","bosque","tinta_azul","brasa"]),Dt={ingresos:["#1baf7a","#199e70"],gastos:["#eb6834","#d95926"],balance:["#2a78d6","#3987e5"],patrimonio:["#eda100","#c98500"],ahorro:["#4a3aa7","#9085e9"],fijos:["#4a3aa7","#9085e9"]},dt=j=>String(j).padStart(2,"0"),Te=j=>j.getFullYear()+"-"+dt(j.getMonth()+1)+"-"+dt(j.getDate()),le=j=>j.getFullYear()+"-"+dt(j.getMonth()+1),lt=(j,a)=>new Date(j,a+1,0),Ot={es:{esteMes:"Este mes",mesPasado:"Mes pasado",ultimos3:"Últimos 3 meses",ultimos6:"Últimos 6 meses",esteAnio:"Este año",anioPasado:"Año pasado",personalizado:"Rango personalizado",aplicar:"Aplicar",inicio:"Elige la fecha de inicio",fin:"Ahora elige la fecha final",anterior:"Periodo anterior",siguiente:"Periodo siguiente"},en:{esteMes:"This month",mesPasado:"Last month",ultimos3:"Last 3 months",ultimos6:"Last 6 months",esteAnio:"This year",anioPasado:"Last year",personalizado:"Custom range",aplicar:"Apply",inicio:"Pick the start date",fin:"Now pick the end date",anterior:"Previous period",siguiente:"Next period"},fr:{esteMes:"Ce mois-ci",mesPasado:"Le mois dernier",ultimos3:"3 derniers mois",ultimos6:"6 derniers mois",esteAnio:"Cette année",anioPasado:"L’an dernier",personalizado:"Période personnalisée",aplicar:"Appliquer",inicio:"Choisis la date de début",fin:"Choisis la date de fin",anterior:"Période précédente",siguiente:"Période suivante"}},Nt={es:{guia:"Guía",planes:"Planes",terminos:"Términos",privacidad:"Privacidad",soporte:"Soporte",licencias:"Licencias",aceptas:"Al crear tu cuenta aceptas los",y:"y la",aviso:"No es asesoría financiera."},en:{guia:"Guide",planes:"Plans",terminos:"Terms",privacidad:"Privacy",soporte:"Support",licencias:"Licences",aceptas:"By creating your account you accept the",y:"and the",aviso:"Not financial advice."},fr:{guia:"Guide",planes:"Formules",terminos:"Conditions",privacidad:"Confidentialité",soporte:"Assistance",licencias:"Licences",aceptas:"En créant ton compte tu acceptes les",y:"et la",aviso:"Ceci n’est pas un conseil financier."}},Ca=[["DOP","Peso dominicano (RD$)"],["USD","Dólar (US$)"],["EUR","Euro (€)"],["MXN","Peso mexicano"],["COP","Peso colombiano"],["CLP","Peso chileno"],["ARS","Peso argentino"]],Sa=[["perfil","Perfil","M12 11a4 4 0 1 0 0-8 4 4 0 0 0 0 8M4 21a8 8 0 0 1 16 0"],["apariencia","Apariencia","M12 3a9 9 0 1 0 0 18c1 0 1.8-.8 1.8-1.8 0-.5-.2-.9-.5-1.2-.3-.3-.5-.7-.5-1.2 0-1 .8-1.8 1.8-1.8H17a4 4 0 0 0 4-4c0-4.4-4-8-9-8M7.5 12h.01M9.5 8.5h.01M14.5 8h.01"],["libretas","Libretas","M4 5h7v14H4zM13 5h7v14h-7z"],["integraciones","Integraciones","M10 13a5 5 0 0 0 7 0l3-3a5 5 0 0 0-7-7l-1.5 1.5M14 11a5 5 0 0 0-7 0l-3 3a5 5 0 0 0 7 7l1.5-1.5"],["seguridad","Seguridad","M12 3l8 3v6c0 5-4 8-8 9-4-1-8-4-8-9V6zM9 12l2 2 4-4"],["plan","Plan","M4 5h16v6H4zM4 15h10v4H4z"],["datos","Datos","M4 7c0-1.7 3.6-3 8-3s8 1.3 8 3-3.6 3-8 3-8-1.3-8-3M4 7v10c0 1.7 3.6 3 8 3s8-1.3 8-3V7M4 12c0 1.7 3.6 3 8 3s8-1.3 8-3"]],Bt={TR:"M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18M12 16v-5M12 8h.01",EX:"M12 3v12M8 11l4 4 4-4M4 17v3h16v-3",RP:"M3 12a9 9 0 1 0 3-6.7M3 4v5h5"},Ft={PN:"M3 3h7v7H3zM14 3h7v5h-7zM14 12h7v9h-7zM3 14h7v7H3z",MV:"M7 4v15M7 19l-3-3M7 19l3-3M17 20V5M17 5l-3 3M17 5l3 3",CT:"M2 7h20v11H2zM2 11h20M6 15h4",PR:"M21 12a9 9 0 1 1-9-9v9z M21 12h-9l6.4-6.4A9 9 0 0 1 21 12",MT:"M8 3h8v6a4 4 0 0 1-8 0zM12 13v5M9 21h6M5 5H3v2a4 4 0 0 0 4 4M19 5h2v2a4 4 0 0 1-4 4",LB:"M4 5h7v14H4zM13 5h7v14h-7z"},Ma=j=>new Promise(a=>setTimeout(a,j));class Be extends te{constructor(a){super(a);const e=Ge("restablecer"),o=Ge("verificar"),i=Ge("invitacion");this.valeEntrada=Ge("entrar"),this.state={...this.state,pantalla:e?"restablecer":o?"verificar":i?"invitacion":null,tokenExtra:e||o||i||"",extra:{email:"",clave:""},extraError:"",extraOk:"",extraOcupado:!1,barra:(()=>{try{return localStorage.getItem(st)||"fija"}catch{return"fija"}})(),barraSobre:!1,usuario:(()=>{try{return JSON.parse(localStorage.getItem(Ze)||"null")||{}}catch{return{}}})(),tab:"perfil",mensaje:"",mensajeTipo:"ok",ocupado:"",perfil:null,correoForm:{email:"",clave:""},claveForm:{actual:"",nueva:"",repetir:""},bajaClave:"",sesiones:[],actividad:[],mfaAbierto:!1,mfaClave:"",ocupadoMfa:!1,moneda:"DOP",centavos:!1,claves:[],puedeApi:!1,claveNueva:"",nombreClave:"",rango:null,perAbierto:!1,perCustom:!1,calForm:null,cajon:!1,calMes:null,calDesde:null,calHasta:null,selTx:[]},(e||o||i)&&kt(),this.prefsPrevias=this.instantaneaPrefs()}componentDidMount(){super.componentDidMount(),this.state.pantalla==="verificar"&&this.verificarCorreo(),this.state.pantalla==="invitacion"&&ue()&&this.aceptarInvitacion(),this.valeEntrada&&this.canjeaVale(this.valeEntrada),sa(()=>this.caducoLaSesion()),this.alVolver=()=>{document.visibilityState==="visible"&&this.bajar().catch(()=>{})},ue()&&this.state.sesion&&this.aseguraLibretaPropia(this.state.sesion,this.state.libretas||[]).then(e=>{if(e.length===(this.state.libretas||[]).length)return;const o=e.filter(i=>this.papelEn(i,this.state.sesion.email)==="Dueño")[0];this.guardar({libretas:e,activa:o?o.id:this.state.activa})}).catch(()=>{}),this.pintaFondo(),this.pintaPaleta(),this.alScroll=()=>{const e=window.scrollY>6;e!==this.state.desplazado&&this.setState({desplazado:e})},window.addEventListener("scroll",this.alScroll,{passive:!0}),this.alClicFuera=e=>{e.target&&e.target.closest&&e.target.closest("[data-menu]")||this.cierraDesplegables()},this.alEscape=e=>{if(e.key!=="Escape"||this.cierraDesplegables())return;const o=this.state;o.formOpen||o.catModal||o.invModal||o.agregar?this.setState({formOpen:!1,catModal:!1,invModal:!1,agregar:null}):(o.selTx||[]).length&&this.setState({selTx:[]})},this.alAtajo=e=>{if(e.metaKey||e.ctrlKey||e.altKey||this.state.paso!=="app")return;const o=e.target;o&&(/^(INPUT|TEXTAREA|SELECT)$/.test(o.tagName)||o.isContentEditable)||(e.key==="n"||e.key==="N"?(e.preventDefault(),this.nuevoMovimiento()):e.key==="/"?(e.preventDefault(),this.setState({vista:"movs"}),setTimeout(()=>{const i=document.querySelector("[data-buscar-movs]");i&&i.focus()},40)):e.key==="?"&&(e.preventDefault(),this.festeja(this.trStr("Atajos de teclado"),this.trStr("N nuevo movimiento · / buscar · Esc cerrar"))))},document.addEventListener("click",this.alClicFuera),document.addEventListener("keydown",this.alEscape),document.addEventListener("keydown",this.alAtajo),this.alEntrar=e=>{if(e.key!=="Enter"||e.isComposing||this.state.paso!=="auth")return;const o=e.target;!o||o.tagName!=="INPUT"||(e.preventDefault(),!this.state.autenticando&&(this.state.authReto?this.entrarCodigo():this.autenticar()))},document.addEventListener("keydown",this.alEntrar);const a=e=>e.target&&e.target.closest?e.target.closest("[data-csv-zona]"):null;this.alArrastrarCsv=e=>{a(e)&&(e.preventDefault(),e.dataTransfer&&(e.dataTransfer.dropEffect="copy"),this.state.csvSobre!==!0&&this.setState({csvSobre:!0}))},this.alSalirCsv=e=>{a(e)&&this.state.csvSobre&&this.setState({csvSobre:!1})},this.alSoltarCsv=e=>{if(!a(e))return;e.preventDefault(),this.state.csvSobre&&this.setState({csvSobre:!1});const i=e.dataTransfer&&e.dataTransfer.files&&e.dataTransfer.files[0];i&&this.leeArchivoCsv(i)},document.addEventListener("dragover",this.alArrastrarCsv),document.addEventListener("dragleave",this.alSalirCsv),document.addEventListener("drop",this.alSoltarCsv),document.addEventListener("visibilitychange",this.alVolver),window.addEventListener("focus",this.alVolver),this.reloj=setInterval(()=>this.bajar().catch(()=>{}),45e3)}componentDidUpdate(a){super.componentDidUpdate(a),this.pintaFondo(),this.pintaPaleta()}pintaPaleta(){const a=nt.find(o=>o.id===(this.state.paleta||"clasica"))||nt[0];if(this.paletaPuesta===a.id)return;this.paletaPuesta=a.id;const e=document.documentElement.style;e.setProperty("--positivo",a.positivo),e.setProperty("--negativo",a.negativo),e.setProperty("--ahorro",a.ahorro),e.setProperty("--aviso",a.aviso),e.setProperty("--balance",a.balance)}pintaFondo(){this.fondoActual&&this.fondoPuesto!==this.fondoActual&&(this.fondoPuesto=this.fondoActual,document.body.style.background=this.fondoActual)}cierraDesplegables(){const a=this.state;return!a.notisOpen&&!a.selectorOpen&&!a.menu&&!a.perAbierto?!1:(this.setState({notisOpen:!1,selectorOpen:!1,menu:null,perAbierto:!1}),!0)}componentWillUnmount(){super.componentWillUnmount(),window.removeEventListener("scroll",this.alScroll),document.removeEventListener("click",this.alClicFuera),document.removeEventListener("keydown",this.alEscape),document.removeEventListener("keydown",this.alEntrar),document.removeEventListener("visibilitychange",this.alVolver),window.removeEventListener("focus",this.alVolver),document.removeEventListener("dragover",this.alArrastrarCsv),document.removeEventListener("dragleave",this.alSalirCsv),document.removeEventListener("drop",this.alSoltarCsv),document.removeEventListener("keydown",this.alAtajo),clearInterval(this.reloj),clearTimeout(this.tEmpuje)}guardar(a){super.guardar(a),this.programarEmpuje()}instantaneaPrefs(){const a=this.state||{};return ya.reduce((e,o)=>({...e,[o]:a[o]}),{})}programarEmpuje(){!ue()||this.state.paso!=="app"||(clearTimeout(this.tEmpuje),this.tEmpuje=setTimeout(()=>this.empujarAhora(),900))}async empujarAhora(){var a;if(this.empujando){this.pendiente=!0;return}this.empujando=!0;try{const e=await wt(this.state.libretas||[]);if(e.fusionadas){const i=e.fusionadas.some(r=>r.id===this.state.activa)?this.state.activa:((a=e.fusionadas[0])==null?void 0:a.id)||null;this.setState({libretas:e.fusionadas,activa:i})}if(e.renombradas&&e.renombradas.length){const i=new Map(e.renombradas.map(r=>[r.de,r.a]));this.guardar({libretas:(this.state.libretas||[]).map(r=>i.has(r.id)?{...r,id:i.get(r.id)}:r),activa:i.get(this.state.activa)||this.state.activa})}if(e.sinPermiso&&e.sinPermiso.length){const i=new Set(e.sinPermiso),r=(this.state.libretas||[]).filter(u=>!i.has(u.id));this.guardar({libretas:r,activa:i.has(this.state.activa)?r[0]?r[0].id:null:this.state.activa}),this.festeja("Ya no estás en esa libreta","Quien la creó te quitó el acceso. La quitamos de este equipo.")}e.perdidas.length&&this.festeja("No pudimos guardar lo último","Otro aparato escribió a la vez. Revisa lo que acabas de hacer, por si hay que repetirlo."),e.limite.length&&(await this.bajar(!0),this.festeja("Tu plan llega hasta aquí","El plan Gratis lleva una libreta. Mira los planes en /planes."));const o=this.instantaneaPrefs();JSON.stringify(o)!==JSON.stringify(this.prefsPrevias)&&(this.prefsPrevias=o,Zt(o)),this.setState({sinConexion:!1})}catch{this.setState({sinConexion:!0})}finally{this.empujando=!1,this.pendiente&&(this.pendiente=!1,this.programarEmpuje())}}async bajar(a){var u;if(!ue()||this.state.paso!=="app"||this.empujando&&!a)return!1;const e=new Map(Kt),o=await ke();if(!(o.length!==e.size||o.some(f=>e.get(f.id)!==f.__version)))return!1;const r=o.some(f=>f.id===this.state.activa)?this.state.activa:((u=o[0])==null?void 0:u.id)||null;return this.setState({libretas:o,activa:r}),!0}fijarBarra(){const e={fija:"auto",auto:"iconos",iconos:"fija"}[this.state.barra]||"auto";try{localStorage.setItem(st,e)}catch{}this.setState({barra:e,barraSobre:!1}),this.programarEmpuje()}papelEn(a,e){var r;if(!a)return"Lector";if(a.__rol)return a.__rol;const o=String(e||((r=this.state.sesion)==null?void 0:r.email)||"").trim().toLowerCase(),i=(a.miembros||[]).filter(u=>String(u.email||"").trim().toLowerCase()===o)[0];return i?i.rol:"Lector"}rol(){return this.papelEn(this.lb())}async aseguraLibretaPropia(a,e){if(e.some(r=>this.papelEn(r,a.email)==="Dueño"))return e;const o=te.baseLibretas(a.email,a.nombre);await wt(e.concat(o));const i=await ke();return i.length?i:e.concat(o)}async exportaLibreta(){const a=this.lb();if(!a)return;const e=f=>{const l=String(f||"efectivo");if(l==="efectivo")return this.trStr("Efectivo");const[y,g]=l.split(":"),z=((y==="tarjeta"?a.tarjetas:a.cuentas)||[]).filter(P=>String(P.id)===g)[0];return z?z.nombre:l},i="\uFEFF"+[[this.trStr("Concepto"),this.trStr("Categoría"),this.trStr("Tipo"),this.trStr("Medio"),this.trStr("Fecha"),this.trStr("Monto")]].concat(a.tx.map(f=>[f.concepto,f.categoria,f.tipo,e(f.medio),f.fecha,f.monto])).map(f=>f.map(l=>'"'+String(l).replace(/"/g,'""')+'"').join(",")).join(`
`),r="chinola-"+String(a.nombre).replace(/[^\p{L}\p{N}]+/gu,"-").replace(/^-|-$/g,"")+".csv";if(await ea(r,i,"Exportar esta libreta"))return;const u=document.createElement("a");u.href=URL.createObjectURL(new Blob([i],{type:"text/csv"})),u.download=r,u.click(),setTimeout(()=>URL.revokeObjectURL(u.href),1e3)}static aNumero(a){const e=String(a||"").replace(/[^\d.,]/g,"");if(!e)return NaN;const o=e.lastIndexOf(","),i=e.lastIndexOf(".");let r=-1;if(o>=0&&i>=0)r=Math.max(o,i);else{const y=Math.max(o,i);if(y>=0){const g=e.split(e[y]).length-1,S=e.length-y-1;r=g===1&&S!==3?y:-1}}const u=(r<0?e:e.slice(0,r)).replace(/[.,]/g,""),f=r<0?"":"."+e.slice(r+1).replace(/[.,]/g,""),l=Number(u+f);return isFinite(l)?l:NaN}static partirCsv(a){const e=[];let o="",i=!1;for(let r=0;r<a.length;r++){const u=a[r];i?u==='"'&&a[r+1]==='"'?(o+='"',r++):u==='"'?i=!1:o+=u:u==='"'?i=!0:u===","||u===";"?(e.push(o),o=""):o+=u}return e.push(o),e.map(r=>r.trim())}leeArchivoCsv(a){if(!a)return;if(!/\.csv$/i.test(a.name)&&a.type&&!/csv|text|excel/i.test(a.type))return this.festeja(this.trStr("No reconozco el archivo"),this.trStr("Tiene que ser un archivo CSV."));const e=new FileReader;e.onload=()=>this.importaCsv(String(e.result||"")),e.onerror=()=>this.festeja(this.trStr("No pude leer el archivo"),a.name),e.readAsText(a,"utf-8")}pideCsv(){const a=document.createElement("input");a.type="file",a.accept=".csv,text/csv",a.onchange=()=>this.leeArchivoCsv(a.files&&a.files[0]),a.click()}importaCsv(a){const e=this.lb();if(!e)return;if(this.papelEn(e,(this.state.sesion||{}).email)==="Lector")return this.festeja(this.trStr("Solo lectura"),this.trStr("No puedes importar en esta libreta."));const o=a.replace(/^﻿/,"").split(/\r?\n/).filter(I=>I.trim());if(o.length<2)return this.festeja(this.trStr("El archivo está vacío"),this.trStr("No encontré filas que leer."));const i=Be.partirCsv(o[0]).map(I=>I.toLowerCase()),r=(...I)=>{for(const W of I){const U=i.findIndex(p=>p.includes(W));if(U>=0)return U}return-1},u=r("concepto","descripci","detalle"),f=r("monto","importe","cantidad","valor");if(u<0||f<0)return this.festeja(this.trStr("No reconozco el archivo"),this.trStr("Necesito al menos las columnas Concepto y Monto."));const l=r("categor"),y=r("tipo"),g=r("fecha"),S=(e.categorias||[]).map(I=>I.nombre),z=new Date().toISOString().slice(0,10),P=[];let B=0;for(const I of o.slice(1)){const W=Be.partirCsv(I),U=String(W[u]||"").trim(),p=Math.abs(Be.aNumero(W[f]));if(!U||!p||!isFinite(p)){B++;continue}const X=/^\s*-/.test(String(W[f]||"")),_=String(W[y]||"").toLowerCase(),Ee=/ingreso|income|abono|dep/.test(_)?"Ingreso":/fijo|fixed/.test(_)?"Gasto Fijo":/ahorro|saving/.test(_)?"Ahorro":!_&&!X&&y<0?"Ingreso":"Gasto Variable",A=String(W[l]||"").trim(),q=String(W[g]||"").trim();P.push({id:"im"+Date.now().toString(36)+P.length.toString(36),concepto:U,categoria:S.includes(A)?A:"Otros",tipo:Ee,monto:p,fecha:/^\d{4}-\d{2}-\d{2}$/.test(q)?q:z,medio:"efectivo"})}if(!P.length)return this.festeja(this.trStr("No importé nada"),this.trStr("Ninguna fila tenía concepto y monto."));this.setLb({tx:(e.tx||[]).concat(P)}),this.festeja(P.length===1?this.trStr("Un movimiento importado"):this.trStr("{n} movimientos importados").replace("{n}",P.length),B?this.trStr("{n} fila(s) sin concepto o monto se quedaron fuera.").replace("{n}",B):this.trStr("Revísalos en Movimientos."))}alternaSelTx(a){this.setState(e=>{const o=new Set(e.selTx||[]);return o.has(a)?o.delete(a):o.add(a),{selTx:[...o]}})}seleccionaVisibles(a,e){this.setState({selTx:e?[]:a.slice()})}limpiaSeleccion(){this.setState({selTx:[]})}eliminaSeleccion(){const a=this.lb();if(!a)return;const e=new Set(this.state.selTx||[]);if(!e.size)return;let o=Object.assign({},a);for(const i of a.tx)e.has(i.id)&&(o=Object.assign({},o,this.aplica(o,i,-1)));this.setLb({tx:a.tx.filter(i=>!e.has(i.id)),cuentas:o.cuentas,tarjetas:o.tarjetas}),this.festeja(this.trStr(e.size===1?"Un movimiento eliminado":"{n} movimientos eliminados").replace("{n}",e.size),""),this.setState({selTx:[]})}recategorizaSeleccion(a){const e=this.lb();if(!e||!a)return;const o=new Set(this.state.selTx||[]);o.size&&(this.setLb({tx:e.tx.map(i=>o.has(i.id)?Object.assign({},i,{categoria:a}):i)}),this.festeja(this.trStr("Movimientos recategorizados"),""),this.setState({selTx:[]}))}nuevoMovimiento(){const a=this.state,e=this.lb();e&&this.papelEn(e,(a.sesion||{}).email)!=="Lector"&&this.setState({formOpen:!0,menu:null,form:{id:null,concepto:"",categoria:"Otros",tipo:"Gasto Variable",monto:"",fecha:a.mes+"-"+String(new Date().getDate()).padStart(2,"0"),medio:e.cuentas&&e.cuentas.length?"cuenta:"+e.cuentas[0].id:"efectivo",recurrente:!1}})}async entrarConSesion(a,e={},o=!1){let i=await this.aseguraLibretaPropia(a,await ke());ta(a,i,e);const r=["auto","iconos"].includes(e.barra)?e.barra:"fija";try{localStorage.setItem(st,r)}catch{}this.prefsPrevias={tema:e.tema||"chinola",personaje:e.personaje||"auto",idioma:e.idioma||"es",notis:!!e.notis,activa:e.activa,barra:r,moneda:e.moneda||"DOP",centavos:!!e.centavos,paleta:e.paleta||"clasica"},this.guardar({sesion:{email:a.email,nombre:a.nombre},libretas:i,activa:i.some(u=>u.id===e.activa)?e.activa:i[0].id,paso:"app",vista:"panel",pantalla:null,tokenExtra:"",authError:"",auth:{nombre:"",email:"",pass:""},tema:e.tema||"chinola",personaje:e.personaje||"auto",idioma:e.idioma||"es",notis:!!e.notis,barra:r,moneda:e.moneda||"DOP",centavos:!!e.centavos,paleta:e.paleta||"clasica",usuario:a,tab:"perfil",perfil:null,tour:o?0:-1}),this.state.tokenExtra&&this.state.pantalla==="invitacion"&&this.aceptarInvitacion()}async autenticar(){const a=this.state.auth||{},e=this.state.authModo==="registro",o=String(a.email||"").trim().toLowerCase(),i=String(a.pass||""),r=String(a.nombre||"").trim();if(!/^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(o))return this.setState({authError:"Escribe un correo válido."});if(i.length<6)return this.setState({authError:"La contraseña debe tener al menos 6 caracteres."});if(e&&!r)return this.setState({authError:"Escribe tu nombre."});this.setState({authError:"",autenticando:!0});try{const u=e?await E("/registro",{metodo:"POST",cuerpo:{nombre:r,email:o,clave:i,telefono:String(a.telefono||"").trim()}}):await E("/entrar",{metodo:"POST",cuerpo:{email:o,clave:i}});if(u.verificacion){this.setState({autenticando:!1,authError:"Te mandamos un enlace a "+(u.email||o)+". Ábrelo para confirmar tu correo y entrar."});return}if(u.mfa){this.setState({authReto:u.reto,authTipo:u.tipo||"correo",authPista:u.pista||o,authMetodos:u.metodos||[],authCodigo:"",authError:""});return}ze(u.token),await this.entrarConSesion(u.usuario,u.prefs||{},e)}catch(u){this.setState({authError:u.message})}finally{this.setState({autenticando:!1})}}async cambiaMetodo(a){if(!this.state.autenticando){this.setState({autenticando:!0,authError:""});try{const e=await E("/entrar/metodo",{metodo:"POST",cuerpo:{reto:this.state.authReto,tipo:a}});this.setState({authTipo:e.tipo,authPista:e.pista||"",authCodigo:""})}catch(e){const o=/venci|Demasiados/i.test(String(e.message||""));this.setState({authError:e.message,...o?{authReto:"",authCodigo:""}:{}})}finally{this.setState({autenticando:!1})}}}async entrarCodigo(a){const e=String(this.state.authCodigo||"").trim();if(e.replace(/[^a-z0-9]/gi,"").length<6)return this.setState({authError:this.trStr("Escribe el código completo.")});this.setState({authError:"",autenticando:!0});try{const o=await E("/entrar/codigo",{metodo:"POST",cuerpo:{reto:this.state.authReto,codigo:e}});ze(o.token),this.setState({authReto:"",authCodigo:"",authPista:"",authTipo:"",authMetodos:[]}),await this.entrarConSesion(o.usuario,o.prefs||{},!1,a)}catch(o){const i=/venci|Demasiados/i.test(String(o.message||""));this.setState({authError:o.message,...i?{authReto:"",authCodigo:""}:{}})}finally{this.setState({autenticando:!1})}}async canjeaVale(a){kt(),this.setState({autenticando:!0});try{const e=await E("/entrar/canje",{metodo:"POST",cuerpo:{vale:a}});ze(e.token),await this.entrarConSesion(e.usuario,e.prefs||{},!1)}catch(e){this.setState({pantalla:null,paso:"auth",authModo:"login",autenticando:!1,authError:e.message||"No pudimos entrar con esa cuenta. Prueba otra vez."})}finally{this.setState({autenticando:!1})}}caducoLaSesion(){this.state.paso!=="app"||this.yaCaducada||(this.yaCaducada=!0,clearTimeout(this.tEmpuje),this.setState({sesion:null,paso:"auth",authModo:"login",slideIdx:0,authError:"Tu sesión caducó. Entra otra vez para seguir sincronizando.",libretas:[],activa:null,vista:"panel",pantalla:null}))}async salir(){try{await E("/salir",{metodo:"POST"})}catch{}Ct(),clearTimeout(this.tEmpuje),this.setState({sesion:null,paso:"onboarding",slideIdx:0,libretas:[],activa:null,vista:"panel",pantalla:null})}async salirDeLibreta(a){const e=(this.state.libretas||[]).filter(o=>o.id!==a);e.length&&(aa(a).catch(()=>{}),this.guardar({libretas:e,activa:this.state.activa===a?e[0].id:this.state.activa,libretaVista:null}),this.avisar("Saliste de la libreta."))}async aceptaInvitacion(a){try{await oa(a);const e=await ke();this.guardar({libretas:e,activa:a,vista:"panel",libretaVista:null}),this.avisar("Invitación aceptada. Ya puedes usar la libreta.")}catch(e){this.avisar("No pudimos aceptar: "+e.message,"error")}}async rechazaInvitacion(a){const e=(this.state.libretas||[]).filter(o=>o.id!==a);ra(a).catch(()=>{}),this.guardar({libretas:e,activa:this.state.activa===a?(e[0]||{}).id:this.state.activa,libretaVista:null}),this.avisar("Invitación rechazada.")}abrirPantalla(a){var e;this.setState({pantalla:a,extraError:"",extraOk:"",extra:{email:((e=this.state.auth)==null?void 0:e.email)||"",clave:""}})}cerrarPantalla(){this.setState({pantalla:null,extraError:"",extraOk:"",tokenExtra:""})}async pedirEnlace(){const a=String(this.state.extra.email||"").trim().toLowerCase();if(!/^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(a))return this.setState({extraError:"Escribe un correo válido."});this.setState({extraOcupado:!0,extraError:""});try{await E("/olvide",{metodo:"POST",cuerpo:{email:a}}),this.setState({extraOk:"Si esa cuenta existe, te llegó un correo con el enlace. Revisa también el correo no deseado."})}catch(e){this.setState({extraError:e.message})}finally{this.setState({extraOcupado:!1})}}async restablecer(){const a=String(this.state.extra.clave||"");if(a.length<6)return this.setState({extraError:"La contraseña debe tener al menos 6 caracteres."});this.setState({extraOcupado:!0,extraError:""});try{const e=await E("/restablecer",{metodo:"POST",cuerpo:{token:this.state.tokenExtra,clave:a}});ze(e.token),await this.entrarConSesion(e.usuario,e.prefs||{})}catch(e){this.setState({extraError:e.message,extraOcupado:!1})}}async verificarCorreo(){this.setState({extraOcupado:!0});try{const a=await E("/verificar",{metodo:"POST",cuerpo:{token:this.state.tokenExtra}});ze(a.token),this.setState({extraOk:"Correo confirmado. Entrando…"}),await Ma(700),await this.entrarConSesion(a.usuario,a.prefs||{})}catch(a){this.setState({extraError:a.message,extraOcupado:!1})}}async aceptarInvitacion(){if(!ue())return this.setState({extraOk:"",extraError:"",pantalla:"invitacion"});this.setState({extraOcupado:!0});try{const a=await E("/libretas/invitacion/aceptar",{metodo:"POST",cuerpo:{token:this.state.tokenExtra}}),e=await ke();this.guardar({libretas:e,pantalla:null,tokenExtra:"",vista:"libretas",libretaVista:null}),this.festeja("Ya tienes acceso","Libreta “"+a.libreta+"”")}catch(a){this.setState({extraError:a.message})}finally{this.setState({extraOcupado:!1})}}enPeriodo(a,e,o){const i=this.state.rango;return o&&i?a>=i.desde&&a<=i.hasta:String(a).slice(0,7)===e}rejillaMes(a,e,o,i){const[r,u]=String(a).split("-").map(Number),f=new Date(r,u-1,1),l=new Date(r,u-1,1-f.getDay()),y=[];for(let g=0;g<42;g++){const S=new Date(l.getFullYear(),l.getMonth(),l.getDate()+g),z=Te(S),P=o(z);y.push({n:S.getDate(),radio:P==="punta"?"11px":"9px",bg:P==="punta"?"oklch(0.88 0.17 95)":P==="dentro"?"color-mix(in oklab, oklch(0.88 0.17 95) 26%, transparent)":"transparent",fg:P==="punta"?"oklch(0.24 0.05 155)":e.tinta,peso:P==="punta"?800:500,opacidad:S.getMonth()===u-1?1:.4,go:()=>i(z)})}return y}esOscuro(){return wa.has(this.state.tema)}colorSerie(a){return(Dt[a]||Dt.balance)[this.esOscuro()?1:0]}localeActual(){return{es:"es-DO",en:"en-US",fr:"fr-FR"}[this.state.idioma||"es"]||"es-DO"}diasSemana(){return[0,1,2,3,4,5,6].map(a=>{try{return new Intl.DateTimeFormat(this.localeActual(),{weekday:"narrow"}).format(new Date(2024,8,1+a))}catch{return["D","L","M","M","J","V","S"][a]}})}tituloMes(a){const[e,o]=String(a).split("-").map(Number);try{const i=new Intl.DateTimeFormat(this.localeActual(),{month:"long",year:"numeric"}).format(new Date(e,o-1,1));return i.charAt(0).toUpperCase()+i.slice(1)}catch{return a}}mesVecino(a,e){const[o,i]=String(a).split("-").map(Number);return le(new Date(o,i-1+e,1))}txtPeriodo(a){return(Ot[this.state.idioma]||Ot.es)[a]}etiquetaRango(a,e){const o={es:"es-DO",en:"en-US",fr:"fr-FR"}[this.state.idioma||"es"]||"es-DO",i=new Date(a.desde+"T00:00:00"),r=new Date(a.hasta+"T00:00:00"),u=(z,P)=>{try{return new Intl.DateTimeFormat(o,{month:P?"long":"short"}).format(z).replace(".","")}catch{return String(z.getMonth()+1)}},f=i.getFullYear()===r.getFullYear(),l=i.getMonth()===0&&i.getDate()===1&&r.getMonth()===11&&r.getDate()===31;if(f&&l)return String(i.getFullYear());const y=i.getDate()===1,g=r.getDate()===lt(r.getFullYear(),r.getMonth()).getDate();if(f&&y&&g){const z=u(i,!e),P=u(r,!e),B=(z===P?z:z+" – "+P)+" "+i.getFullYear();return e?B:B.charAt(0).toUpperCase()+B.slice(1)}const S=(z,P)=>z.getDate()+" "+u(z,!1)+(P?" "+z.getFullYear():"");return a.desde===a.hasta?S(i,!0):S(i,!f)+" – "+S(r,!0)}fijaPeriodo(a){this.setState({perAbierto:!1,perCustom:!1,menu:null,...a})}preset(a){const e=new Date,o=e.getFullYear(),i=e.getMonth(),r=(u,f)=>({desde:Te(u),hasta:Te(f),clave:a});switch(a){case"esteMes":return this.fijaPeriodo({mes:le(e),rango:null});case"mesPasado":{const u=new Date(o,i-1,1);return this.fijaPeriodo({mes:le(u),rango:null})}case"ultimos3":return this.fijaPeriodo({mes:le(e),rango:r(new Date(o,i-2,1),lt(o,i))});case"ultimos6":return this.fijaPeriodo({mes:le(e),rango:r(new Date(o,i-5,1),lt(o,i))});case"esteAnio":return this.fijaPeriodo({mes:le(e),rango:r(new Date(o,0,1),new Date(o,11,31))});case"anioPasado":return this.fijaPeriodo({mes:o-1+"-12",rango:r(new Date(o-1,0,1),new Date(o-1,11,31))});default:return this.setState({calDesde:null,calHasta:null})}}pasoMes(a){const[e,o]=String(this.state.mes).split("-").map(Number),i=new Date(e,o-1+a,1);this.fijaPeriodo({mes:le(i),rango:null})}fmt(a){const e=this.state.centavos?2:0,o={es:"es-DO",en:"en-US",fr:"fr-FR"}[this.state.idioma||"es"]||"es-DO";try{return new Intl.NumberFormat(o,{style:"currency",currency:this.state.moneda||"DOP",minimumFractionDigits:e,maximumFractionDigits:e}).format(a||0)}catch{return"$"+Math.round(a||0).toLocaleString("es-DO")}}avisar(a,e="ok"){clearTimeout(this.tAviso),this.setState({mensaje:a,mensajeTipo:e}),this.tAviso=setTimeout(()=>this.setState({mensaje:""}),5e3)}formPerfil(){const a=this.state.usuario||{};return this.state.perfil||{nombre:a.nombre||"",usuario:a.usuario||"",telefono:a.telefono||""}}async guardarPerfil(){const a=this.formPerfil();this.setState({ocupado:"perfil"});try{const e=await E("/perfil",{metodo:"PUT",cuerpo:a});try{localStorage.setItem(Ze,JSON.stringify(e.usuario))}catch{}this.setState({usuario:e.usuario,perfil:null});const o=await ke();this.guardar({libretas:o,sesion:{email:e.usuario.email,nombre:e.usuario.nombre}}),this.avisar("Perfil actualizado.")}catch(e){this.avisar(e.message,"error")}finally{this.setState({ocupado:""})}}async cambiarCorreo(){const{email:a,clave:e}=this.state.correoForm;this.setState({ocupado:"correo"});try{const o=await E("/correo",{metodo:"PUT",cuerpo:{email:a,clave:e}});try{localStorage.setItem(Ze,JSON.stringify(o.usuario))}catch{}const i=await ke();this.setState({usuario:o.usuario,correoForm:{email:"",clave:""}}),this.guardar({libretas:i,sesion:{email:o.usuario.email,nombre:o.usuario.nombre}}),this.avisar("Listo: ahora entras con "+o.usuario.email+".")}catch(o){this.avisar(o.message,"error")}finally{this.setState({ocupado:""})}}async cambiarClave(){const{actual:a,nueva:e,repetir:o}=this.state.claveForm;if(e!==o)return this.avisar("Las dos contraseñas nuevas no son iguales.","error");this.setState({ocupado:"clave"});try{const i=await E("/clave",{metodo:"POST",cuerpo:{actual:a,nueva:e}});ze(i.token),this.setState({claveForm:{actual:"",nueva:"",repetir:""}}),this.avisar("Contraseña cambiada. Cerramos las sesiones de otros dispositivos.")}catch(i){this.avisar(i.message,"error")}finally{this.setState({ocupado:""})}}async traerClaves(){try{const a=await E("/claves");this.setState({claves:a.claves||[],puedeApi:!!a.api})}catch{}}async crearClave(){try{const a=await E("/claves",{metodo:"POST",cuerpo:{nombre:this.state.nombreClave}});this.setState({claveNueva:a.clave,nombreClave:""}),this.traerClaves(),this.avisar("Clave creada. Cópiala ahora: no se vuelve a mostrar.")}catch(a){this.avisar(a.message,"error")}}async revocarClave(a,e){if(confirm(`¿Revocar «${e}»? Lo que la use dejará de funcionar.`))try{await E("/claves/"+a,{metodo:"DELETE"}),this.traerClaves(),this.avisar("Clave revocada.")}catch(o){this.avisar(o.message,"error")}}async cerrarOtras(){try{await E("/sesiones/cerrar-otras",{metodo:"POST"}),this.avisar("Listo: solo queda abierta esta sesión.")}catch(a){this.avisar(a.message,"error")}}async cargarSeguridad(){if(!ue())return;const a=r=>E(r).catch(()=>null),[e,o,i]=await Promise.all([a("/sesiones"),a("/actividad"),a("/mfa/metodos")]);this.setState({sesiones:e&&e.sesiones||[],actividad:o&&o.actividad||[],metodos2p:i&&i.metodos||this.state.metodos2p||null,...i&&i.usuario?{usuario:i.usuario}:{}})}abrirDosPasos(a,e){const o=this.state.dp2&&this.state.dp2.tipo===a&&!!this.state.dp2.quitar==!!e;this.setState({dp2:o?null:{tipo:a,quitar:!!e,paso:1,clave:"",codigo:""},dpError:""}),!o&&a==="telegram"&&!e&&((this.state.metodos2p||{}).telegram||{}).disponible===!1&&(this.setState({dp2:null}),this.avisar("El servidor todavía no tiene un bot de Telegram configurado.","error"))}async confirmarDosPasos(){const a=this.state.dp2;if(!a||this.state.ocupadoMfa)return;const e=String(a.clave||"");if(a.paso===1&&!e)return this.setState({dpError:"Escribe tu contraseña para confirmar."});this.setState({ocupadoMfa:!0,dpError:""});const o=async i=>{this.setState({dp2:null}),await this.cargarSeguridad(),this.avisar(i)};try{if(a.tipo==="correo")return await E("/mfa/correo",{metodo:"POST",cuerpo:{activar:!a.quitar,clave:e}}),o(a.quitar?"Código por correo quitado.":"Código por correo activado.");if(a.tipo==="totp"){if(a.quitar)return await E("/mfa/totp",{metodo:"DELETE",cuerpo:{clave:e}}),o("App de autenticación quitada.");if(a.paso===1){const i=await E("/mfa/totp/empezar",{metodo:"POST",cuerpo:{clave:e}});this.setState({dp2:{...a,paso:2,pase:i.pase,secreto:i.secreto,qr:i.qr,codigo:""}});return}return await E("/mfa/totp/confirmar",{metodo:"POST",cuerpo:{pase:a.pase,codigo:String(a.codigo||"")}}),o("App de autenticación activada. Al entrar, escribe el código que te dé la app.")}if(a.tipo==="telegram"){if(a.quitar)return await E("/mfa/telegram",{metodo:"DELETE",cuerpo:{clave:e}}),o("Telegram quitado.");if(a.paso===1){const r=await E("/mfa/telegram/empezar",{metodo:"POST",cuerpo:{clave:e}});this.setState({dp2:{...a,paso:2,enlace:r.enlace,bot:r.bot}}),this.vigilaTelegram();return}return(await E("/mfa/telegram/estado")).listo?o("Telegram enlazado. Al entrar, el código te llegará por Telegram."):this.setState({dpError:"Todavía no: abre el bot en Telegram y toca «Iniciar»."})}if(a.tipo==="respaldo"){if(a.paso===1){const i=await E("/mfa/respaldo",{metodo:"POST",cuerpo:{clave:e}});this.setState({dp2:{...a,paso:2,codigos:i.codigos||[]}}),await this.cargarSeguridad();return}return o("Códigos guardados. Cada uno vale una sola vez.")}}catch(i){this.setState({dpError:i.message})}finally{this.setState({ocupadoMfa:!1})}}vigilaTelegram(){clearInterval(this.tTelegram),this.tTelegram=setInterval(async()=>{const a=this.state.dp2;if(!a||a.tipo!=="telegram"||a.paso!==2){clearInterval(this.tTelegram);return}try{(await E("/mfa/telegram/estado")).listo&&(clearInterval(this.tTelegram),this.setState({dp2:null}),await this.cargarSeguridad(),this.avisar("Telegram enlazado. Al entrar, el código te llegará por Telegram."))}catch{}},2e3)}async solicitarPlan(a){const e=this.state.usuario||{};if(a!==(e.plan||"gratis")){if(a==="gratis"){this.avisar("Para bajar al plan gratis, escríbenos y lo ajustamos.");return}try{await E("/plan/solicitar",{metodo:"POST",cuerpo:{plan:a}}),this.avisar("Pedido registrado. Te escribimos para activarlo en cuanto esté el pago.")}catch(o){this.avisar(o.message,"error")}}}async cerrarSesionDe(a,e){try{await E("/sesiones/"+a,{metodo:"DELETE"}),await this.cargarSeguridad(),this.avisar("Sesión cerrada en "+e+".")}catch(o){this.avisar(o.message,"error")}}async cambiarMfa(){const a=this.state.usuario||{},e=!a.mfa;if(!this.state.mfaClave)return this.avisar("Escribe tu contraseña para confirmar.","error");this.setState({ocupadoMfa:!0});try{const o=await E("/mfa",{metodo:"POST",cuerpo:{activar:e,clave:this.state.mfaClave}});this.setState({usuario:{...a,mfa:o.mfa},mfaAbierto:!1,mfaClave:""}),this.avisar(o.mfa?"Verificación en dos pasos activada.":"Verificación en dos pasos desactivada.")}catch(o){this.avisar(o.message,"error")}finally{this.setState({ocupadoMfa:!1})}}haceCuanto(a){if(!a)return"";const e=Math.floor((Date.now()-Date.parse(a))/6e4);if(!isFinite(e))return"";const o=f=>this.trStr(f),i=(f,l)=>o(l).replace("{n}",f);if(e<2)return o("ahora mismo");if(e<60)return i(e,"hace {n} min");const r=Math.floor(e/60);if(r<24)return i(r,"hace {n} h");const u=Math.floor(r/24);if(u===1)return o("ayer");if(u<7)return i(u,"hace {n} días");try{return new Intl.DateTimeFormat(this.localeActual?this.localeActual():"es-DO",{day:"numeric",month:"short"}).format(new Date(String(a).slice(0,10)+"T00:00:00"))}catch{return String(a).slice(0,10)}}async eliminarCuenta(){if(confirm("¿Eliminar tu cuenta con todas tus libretas? No se puede deshacer.")){this.setState({ocupado:"baja"});try{await E("/cuenta",{metodo:"DELETE",cuerpo:{clave:this.state.bajaClave}}),Ct(),this.setState({sesion:null,paso:"onboarding",libretas:[],activa:null,bajaClave:""})}catch(a){this.avisar(a.message,"error"),this.setState({ocupado:""})}}}decoraMeta(a,e){const o=this,i=this.state,r=this.lb(),u="mt"+a.id,f=g=>o.setLb({metas:r.metas.map(S=>S.id===a.id?{...S,...g}:S)}),l=g=>Math.max(0,Number(g.target.value||0)),y=()=>o.setState({menu:null});return{...a,menuOpen:i.menu===u,menuBg:i.menu===u?e.suave:"transparent",onMenu:g=>{g&&g.stopPropagation&&g.stopPropagation(),o.setState({menu:i.menu===u?null:u})},editando:i.editando===u,setNombre:g=>f({nombre:g.target.value}),setMeta:g=>f({meta:l(g)}),setAhorrado:g=>f({ahorrado:l(g)}),setMensual:g=>f({mensual:l(g)}),swatches:o.swatchList(a.color,g=>f({color:g})),onCerrar:()=>o.setState({editando:null}),acciones:[{label:o.trStr("Editar meta"),color:e.tinta,go:()=>o.setState({editando:u,menu:null})},{label:o.trStr("Aportar")+" "+a.mensualFmt,color:e.tinta,go:()=>{y(),a.onAportar()}},{label:o.trStr("Ver sus movimientos"),color:e.tinta,go:()=>o.setState({menu:null,vista:"movs",q:a.nombre})},{label:o.trStr("Marcar como cumplida"),color:e.tinta,go:()=>{f({ahorrado:a.meta}),y()}},{label:o.trStr("Eliminar meta"),color:ka,go:()=>{a.onDelete(),y()}}]}}aportarAMeta(a,e,o){const i=this.lb(),r=la(i,a,e,o,(u,f,l)=>this.aplica(u,f,l),this.trStr("Aporte a {m}").replace("{m}",a.nombre));return r?(this.setLb(r.parche),r.item):null}abonarAPrestamo(a,e,o){const i=this.lb(),r=da(i,a,e,o,(u,f,l)=>this.aplica(u,f,l),this.trStr("Pago de {p}").replace("{p}",a.nombre));return r?(this.setLb(r.parche),r.item):null}ocultasDe(a){try{const e=JSON.parse(localStorage.getItem("chinola-panel-ocultas")||"{}");return new Set(Array.isArray(e[a])?e[a]:[])}catch{return new Set}}alternaOculta(a,e){let o={};try{o=JSON.parse(localStorage.getItem("chinola-panel-ocultas")||"{}")}catch{}const i=new Set(Array.isArray(o[a])?o[a]:[]);i.has(e)?i.delete(e):i.add(e),o[a]=[...i];try{localStorage.setItem("chinola-panel-ocultas",JSON.stringify(o))}catch{}this.forceUpdate()}renderVals(){var Pe,be,Le;const a=super.renderVals();{const n=this.lb()||{},k=Array.isArray(n.panel)?n.panel:[],T=this.ocultasDe(n.id),v=!!this.state.editorOpen;Array.isArray(a.widgets)&&k.length===a.widgets.length&&(a.widgets=a.widgets.map((h,ce)=>{const H=k[ce],R=!!H&&T.has(H.id);return{...h,oculta:R,visible:!R,opacidad:R&&v?.5:h.opacidad,alternaOculta:H?()=>this.alternaOculta(n.id,H.id):null}}),v||(a.widgets=a.widgets.filter(h=>!h.oculta)))}a.a11y={menu:"Menú",color:"Color",centavos:"Enseñar los centavos",tipoGrafico:"Tipo de gráfico",cuantoTiempo:"Cuánto tiempo",aQueCuenta:"A qué cuenta",limite:"Límite",rol:"Rol",moneda:"Moneda",categoria:"Categoría",medio:"De dónde sale"};const e=this.state;{const n=Lt(a.mascota&&a.mascota.clave||e.personaje||"auto");if(a.portada={...a.portada||{},chinolo:Ne("feliz")},a.slide&&(a.slide={...a.slide,chinolo:Ne("feliz",{conSombra:!1})}),a.mascota={...a.mascota||{},chinoloGrande:Ne(n)},a.toast&&(a.toast={...a.toast,chinolo:Ne("fiesta",{conSombra:!1})}),Array.isArray(a.personajes)){const k=["auto","fuerte","estudiosa","rota","jugo","fiesta"];a.personajes=a.personajes.map((T,v)=>({...T,chinolo:Ne(Lt(k[v]),{conSombra:!1})}))}}Array.isArray(a.metas)&&(a.metas=a.metas.map(n=>({...n,onAportar:()=>{if(!n.mensual)return;this.aportarAMeta(n,n.mensual,null)&&this.festeja(n.ahorrado+n.mensual>=n.meta?"¡Meta cumplida!":"¡Vas subiendo!",n.nombre+" · "+this.fmt(n.mensual))}}))),Array.isArray(a.prestamos)&&(a.prestamos=a.prestamos.map(n=>({...n,onPagar:()=>{const k=Math.abs(Number(n.abono||n.cuota)||0),T=this.abonarAPrestamo(n,k,null);T&&(this.setState({pagando:null}),this.festeja(n.pagado+T.monto>=n.total?"¡Préstamo liquidado!":"Abono registrado",n.nombre+" · "+this.fmt(T.monto)))}})));const o=n=>k=>this.setState({extra:{...e.extra,[n]:k.target.value},extraError:""});if(a.enviarAuth=()=>this.autenticar(),a.onAuth={...a.onAuth,telefono:this.campo("auth","telefono")},a.entrarConApple=()=>{location.href="/api/auth/apple/start"},a.entrarConGoogle=()=>{location.href="/api/auth/google/start"},a.cerrarSesion=()=>this.salir(),a.esCodigo=!!e.authReto,a.noCodigo=!e.authReto,a.authCodigo=e.authCodigo||"",a.onAuthCodigo=n=>this.setState({authCodigo:String(n.target.value||"").replace(/[^a-z0-9-]/gi,"").slice(0,9)}),a.authVolverCodigo=()=>this.setState({authReto:"",authCodigo:"",authError:"",authTipo:"",authMetodos:[]}),a.authLabelCodigo="Código",a.authPhCodigo="Código de 6 dígitos",a.authOtraCuenta="Usar otra cuenta",e.authReto){const n=e.authTipo||"correo",k={correo:"Revisa tu correo",telegram:"Revisa Telegram",totp:"Abre tu app de autenticación"},T={correo:"Te mandamos un código de 6 dígitos a {pista}. Escríbelo para entrar.",telegram:"Te mandamos un código de 6 dígitos por Telegram ({pista}). Escríbelo para entrar.",totp:"Escribe el código de 6 dígitos que te da la app (Google Authenticator, Microsoft Authenticator, Authy…)."};a.authTitulo=k[n]||k.correo,a.authTexto=(T[n]||T.correo).replace("{pista}",e.authPista||""),a.authBoton="Entrar",a.volverOnboarding=a.authVolverCodigo;const v={correo:"Mandarlo al correo",telegram:"Mandarlo por Telegram",totp:"Usar la app de autenticación"};a.authMetodos=(e.authMetodos||[]).filter(h=>h.tipo!==n).map(h=>({label:v[h.tipo]||h.tipo,go:()=>this.cambiaMetodo(h.tipo)})),a.hayOtrosMetodos=a.authMetodos.length>0,a.authOtrosRotulo="¿No te llega? Prueba por otro lado:",a.authRespaldoNota="También puedes escribir uno de tus códigos de respaldo."}a.enviarAuth=()=>e.authReto?this.entrarCodigo():this.autenticar(),a.authBoton=e.autenticando?"Un momento…":a.authBoton,a.mostrarOlvide=e.paso==="auth"&&e.authModo==="login"&&!e.authReto,a.irOlvide=n=>{n&&n.preventDefault&&n.preventDefault(),this.abrirPantalla("olvide")};const i=a.enviarInvitacion;a.enviarInvitacion=()=>{const{email:n,nombre:k,rol:T}=e.invForm||{},v=e.libretaVista;i(),!(!v||!n)&&E("/libretas/"+v+"/invitar",{metodo:"POST",cuerpo:{email:n,nombre:k,rol:T}}).then(h=>{h.correo||this.festeja("Se agregó, pero sin correo",h.error||"Revisa Ajustes → Correo en el portal.")}).catch(h=>this.festeja("No se pudo invitar",h.message))},Array.isArray(a.metas)&&(a.metas=a.metas.map(n=>this.decoraMeta(n,a.tema)));const r=typeof window<"u"&&window.innerWidth<820,u=r||e.barra==="fija"||e.barra==="auto"&&(e.barraSobre||e.selectorOpen),f=()=>this.setState({vista:"ajustes",tab:"libretas",selectorOpen:!1,libretaVista:null,menu:null});if(Array.isArray(a.navItems)&&(a.navItems=a.navItems.filter(n=>n.sigla!=="AJ"&&n.sigla!=="LB").map(n=>({...n,icono:Ft[n.sigla]||Ft.PN,bg:u?n.bg:"transparent",go:()=>{n.go(),r&&this.setState({cajon:!1})}}))),a.irLibretas=f,a.volverLibretas=f,a.detalle&&a.detalle.onEliminar){const n=a.detalle.onEliminar;a.detalle={...a.detalle,onEliminar:()=>{n(),f()}}}a.etiquetaAjustes=this.t("ajustes"),a.ajustesBg=e.vista==="ajustes"?a.tema.suave:a.tema.card;const l=typeof window<"u"&&window.innerWidth<820,y=l?"cajon":e.barra==="iconos"?"iconos":e.barra==="auto"?"auto":"fija",g=u,S=y==="auto"||l;a.barra={col:l?0:y==="fija"?258:72,ancho:l||g?258:72,desplaza:l&&!e.cajon?"translateX(-110%)":"none",pos:S?"fixed":"sticky",z:l?"80":y==="fija"?"auto":"60",sombra:l&&e.cajon||S&&e.barraSobre?"0 22px 48px oklch(0.20 0.05 90 / 0.38)":"none",verModo:l||g?"none":"flex",anchoBoton:g?"100%":"40px",altoBoton:g?"auto":"40px",justificaBoton:g?"flex-start":"center",dropPos:g?"absolute":"fixed",dropTop:g?"58px":(((Pe=e.selectorCoord)==null?void 0:Pe.top)??120)+"px",dropLeft:g?"0":(((be=e.selectorCoord)==null?void 0:be.left)??80)+"px",dropRight:g?"0":"auto",dropAncho:g?"auto":"262px",padSelector:g?"11px":"0",bordeSelector:g?"oklch(1 0 0 / 0.14)":"transparent",fondoSelector:g?"oklch(1 0 0 / 0.08)":"transparent",pad:g?15:10,padBoton:g?12:6,justifica:g?"space-between":"center",chipNav:g?26:40,icoNav:g?15:21,chipTop:g?30:40,puntoLogo:g?11:15,fuenteChip:g?11:14,avatar:g?33:40,masPad:g?13:6,masFuente:g?14:27,masAlto:g?1.4:1,verBloque:g?"block":"none",verFlex:!l&&g?"flex":"none",verFlexCol:g?"flex":"none",alinea:g?"left":"center",nuevo:g&&a.txt&&a.txt.nuevoMov||"+",icono:y==="fija"?"«":y==="auto"?"↔":"»",titulo:this.trStr({fija:"Barra fija · pulsa para que se oculte sola",auto:"Se oculta sola · pulsa para dejarla siempre recogida",iconos:"Siempre recogida · pulsa para fijarla"}[y]),fijar:()=>this.fijarBarra(),onEntra:()=>{y==="auto"&&!e.barraSobre&&this.setState({barraSobre:!0})},onSale:()=>{y==="auto"&&e.barraSobre&&this.setState({barraSobre:!1})}},a.pie=Nt[e.idioma]||Nt.es,a.cabecera={sombra:e.desplazado?"0 10px 26px oklch(0.20 0.05 90 / 0.10)":"none"},a.movil={ver:r?"flex":"none",flexAcciones:r?"0 0 auto":"1",columna:"2",cajonAbierto:r&&e.cajon,abrir:()=>this.setState({cajon:!0}),cerrar:()=>this.setState({cajon:!1}),padMain:r?"16px 14px calc(48px + env(safe-area-inset-bottom))":"24px 30px 60px",padModal:r?"12px":"28px",colsBienvenida:r?"1fr":"1.05fr 0.95fr",padBienvenida:r?"32px 22px 8px":"56px 60px",gapBienvenida:r?"20px":"30px",padEscena:r?"30px 22px 40px":"48px",padAcceso:r?"22px 16px":"40px",padCabecera:r?"14px 14px 12px":"22px 30px 14px",margenCabecera:r?"-16px -14px 14px":"-24px -30px 18px"};const z=a.toggleSelector;z&&(a.toggleSelector=n=>{if(n&&n.currentTarget&&n.currentTarget.getBoundingClientRect){const k=n.currentTarget.getBoundingClientRect(),T=n.currentTarget.closest?n.currentTarget.closest("aside"):null,v=T?T.getBoundingClientRect().right:k.right;this.setState({selectorCoord:{top:Math.round(k.top),left:Math.round(v+10)}})}z()}),this.fondoActual=a.tema&&a.tema.bg;const P={es:"es-DO",en:"en-US",fr:"fr-FR"}[e.idioma||"es"]||"es-DO",B=n=>this.txtPeriodo(n),I=new Date,W=le(I),U=e.calMes||e.mes,[p,X]=String(U).split("-").map(Number),_=e.rango?e.rango.clave:e.mes===W?"esteMes":e.mes===le(new Date(I.getFullYear(),I.getMonth()-1,1))?"mesPasado":"",Ee=n=>({label:B(n),go:()=>this.preset(n),bg:_===n?a.tema.side:"transparent",fg:_===n?"oklch(0.96 0.03 95)":a.tema.tinta}),A=this.rejillaMes(U,a.tema,n=>n===e.calDesde||n===e.calHasta?"punta":e.calDesde&&e.calHasta&&n>e.calDesde&&n<e.calHasta?"dentro":"",n=>{if(!e.calDesde||e.calHasta)return this.setState({calDesde:n,calHasta:null});if(n>=e.calDesde)return this.setState({calHasta:n});this.setState({calDesde:n})});if(a.periodo={abierto:e.perAbierto,custom:!0,bg:e.perAbierto?a.tema.suave:"transparent",corto:_?B(_):a.mesCorto,tituloAntes:B("anterior"),tituloDespues:B("siguiente"),antes:()=>this.pasoMes(-1),despues:()=>this.pasoMes(1),toggle:()=>{const n=e.rango&&e.rango.clave==="personalizado";this.setState({perAbierto:!e.perAbierto,menu:null,calMes:e.rango?e.rango.hasta.slice(0,7):e.mes,calDesde:n?e.rango.desde:null,calHasta:n?e.rango.hasta:null})},opciones:["esteMes","mesPasado","ultimos3","ultimos6","esteAnio","anioPasado","personalizado"].map(Ee),calTitulo:this.tituloMes(U),calAntes:()=>this.setState({calMes:this.mesVecino(U,-1)}),calDespues:()=>this.setState({calMes:this.mesVecino(U,1)}),diasSemana:this.diasSemana(),dias:A,seleccion:e.calDesde?e.calHasta?this.etiquetaRango({desde:e.calDesde,hasta:e.calHasta},!0):B("fin"):B("inicio"),textoAplicar:B("aplicar"),aplicar:()=>{if(!e.calDesde)return;const n={desde:e.calDesde,hasta:e.calHasta||e.calDesde,clave:"personalizado"};this.fijaPeriodo({rango:n,mes:n.hasta.slice(0,7)})}},e.rango){const n=this.etiquetaRango(e.rango,!1);a.mesLargo=n.charAt(0).toUpperCase()+n.slice(1)}if(e.rango&&a.nuevaTx){const n=a.nuevaTx,T=Te(I)>=e.rango.desde&&Te(I)<=e.rango.hasta?Te(I):e.rango.hasta;a.nuevaTx=()=>{n(),this.setState(v=>({form:{...v.form,fecha:T},cajon:!1}))}}const q=String(((Le=e.form)==null?void 0:Le.fecha)||""),J=e.calForm||q.slice(0,7)||e.mes;a.fechaForm={titulo:this.tituloMes(J),antes:()=>this.setState({calForm:this.mesVecino(J,-1)}),despues:()=>this.setState({calForm:this.mesVecino(J,1)}),diasSemana:this.diasSemana(),dias:this.rejillaMes(J,a.tema,n=>n===q?"punta":"",n=>this.setState({form:{...e.form,fecha:n},calForm:n.slice(0,7)}))},Array.isArray(a.fechasRapidas)&&(a.fechasRapidas=a.fechasRapidas.map(n=>({...n,go:()=>{n.go(),this.setState({calForm:null})}})));const ge=e.usuario||{},Y=this.formPerfil(),me=n=>k=>this.setState({perfil:{...Y,[n]:k.target.value}}),he=(n,k)=>T=>this.setState({[n]:{...e[n],[k]:T.target.value}});a.pestanas=Sa.map(n=>({label:n[1],icono:n[2],bg:e.tab===n[0]?a.tema.side:"transparent",fg:e.tab===n[0]?"oklch(0.96 0.03 95)":a.tema.gris,go:()=>{this.setState({tab:n[0],mensaje:""}),n[0]==="integraciones"&&this.traerClaves(),n[0]==="seguridad"&&this.cargarSeguridad()}})),a.tabPerfil=e.tab==="perfil",a.tabApariencia=e.tab==="apariencia",a.tabLibretas=e.tab==="libretas",a.tabSeguridad=e.tab==="seguridad",a.tabIntegraciones=e.tab==="integraciones",a.tabPlan=e.tab==="plan",a.tabDatos=e.tab==="datos",a.puedeApi=e.puedeApi,a.sinApi=!e.puedeApi,a.claveNueva=e.claveNueva,a.copiarClave=()=>{ia(e.claveNueva).then(n=>this.avisar(n?"Clave copiada.":"No pude copiarla: selecciónala y cópiala a mano.")).catch(()=>{})},a.nombreClave=e.nombreClave,a.onNombreClave=n=>this.setState({nombreClave:n.target.value}),a.crearClave=()=>this.crearClave(),a.hayClaves=(e.claves||[]).length>0,a.claves=(e.claves||[]).map(n=>({nombre:n.nombre,prefijo:n.prefijo,uso:n.ultimo_uso?"usada "+new Date(n.ultimo_uso).toLocaleDateString(P):"sin usar todavía",revocar:()=>this.revocarClave(n.id,n.nombre)})),a.ejemploApi="curl -X POST "+location.origin+`/api/v1/movimientos \\
  -H "authorization: Bearer TU_CLAVE" \\
  -H "content-type: application/json" \\
  -d '{"concepto":"Colmado","monto":450,"categoria":"Alimentación"}'`,a.hayMensaje=!!e.mensaje,a.mensaje=e.mensaje,a.mensajeBg=e.mensajeTipo==="error"?"oklch(0.96 0.04 30)":"oklch(0.95 0.05 152)",a.mensajeFg=e.mensajeTipo==="error"?"oklch(0.48 0.15 30)":"oklch(0.38 0.11 152)",a.estadoCuenta=ge.verificado?"correo confirmado":"correo sin confirmar",a.perfil=Y,a.onPerfil={nombre:me("nombre"),usuario:me("usuario"),telefono:me("telefono")},a.guardarPerfil=()=>this.guardarPerfil(),a.botonPerfil=e.ocupado==="perfil"?"Guardando…":"Guardar cambios",a.correoForm=e.correoForm,a.onCorreo={email:he("correoForm","email"),clave:he("correoForm","clave")},a.cambiarCorreo=()=>this.cambiarCorreo(),a.botonCorreo=e.ocupado==="correo"?"Cambiando…":"Cambiar mi correo",a.monedas=Ca.map(n=>({id:n[0],label:n[1]})),a.monedaActual=e.moneda||"DOP",a.onMoneda=n=>this.guardar({moneda:n.target.value}),a.centavosBg=e.centavos?"oklch(0.52 0.13 152)":a.tema.borde,a.centavosKnob=e.centavos?27:3,a.toggleCentavos=()=>this.guardar({centavos:!e.centavos}),a.tituloPaleta=this.trStr("Colores"),a.coloresDesc=this.trStr("Cómo se ven los ingresos, los gastos, el ahorro y los avisos en toda la app."),a.paletas=nt.map(n=>({nombre:this.trStr(n.nombre),pista:this.trStr(n.pista),positivo:n.positivo,negativo:n.negativo,ahorro:n.ahorro,aviso:n.aviso,puesta:(e.paleta||"clasica")===n.id,aro:(e.paleta||"clasica")===n.id?a.tema.tinta:"transparent",bg:(e.paleta||"clasica")===n.id?a.tema.suave:a.tema.card,go:()=>this.guardar({paleta:n.id})}));const ae=e.sinConexion?"sinRed":na()?"pendiente":"aldia";a.syncLabel=this.trStr({sinRed:"Sin conexión",pendiente:"Sin subir",aldia:"Al día"}[ae]),a.syncDot=ae==="aldia"?"oklch(0.80 0.15 145)":ae==="pendiente"?"oklch(0.82 0.14 85)":"oklch(0.72 0.16 25)",a.syncColor=ae==="aldia"?"oklch(0.88 0.07 140)":ae==="pendiente"?"oklch(0.90 0.08 90)":"oklch(0.86 0.09 30)";const fe=(e.usuario||{}).plan||"gratis";a.planPieLabel=this.trStr({gratis:"Gratis",pro:"Pro",negocio:"Negocio"}[fe]||"Gratis"),a.planPieColor=fe==="pro"||fe==="negocio"?"oklch(0.87 0.14 92)":"oklch(0.85 0.05 120)",a.planPieTitulo=fe==="gratis"?this.trStr("Mira los planes"):this.trStr("Tu plan"),a.irAlPlan=()=>this.setState({vista:"ajustes",tab:"plan"}),a.txtSalirLibreta=this.trStr("Salir de la libreta"),a.txtAceptarInv=this.trStr("Aceptar invitación"),a.txtRechazarInv=this.trStr("Rechazar"),a.txtInvitacion=this.trStr("Invitación"),a.txtInvitacionPie=this.trStr("Te invitaron a esta libreta. Acéptala para usarla, o recházala.");const de=new Set(e.selTx||[]);if(Array.isArray(a.txVisibles)){a.txVisibles=a.txVisibles.map(T=>{const v=de.has(T.id);return Object.assign({},T,{sel:v,selBorde:v?"var(--positivo)":a.tema.borde,selBg:v?"var(--positivo)":"transparent",selFila:v?"color-mix(in oklab, var(--positivo) 8%, transparent)":"transparent",onSel:()=>this.alternaSelTx(T.id)})});const n=a.txVisibles.map(T=>T.id),k=n.length>0&&n.every(T=>de.has(T));a.todoSel=k,a.todoSelBorde=k?"var(--positivo)":a.tema.borde,a.todoSelBg=k?"var(--positivo)":"transparent",a.onTodoSel=()=>this.seleccionaVisibles(n,k)}a.haySeleccion=de.size>0,a.selTexto=this.trStr(de.size===1?"{n} seleccionado":"{n} seleccionados").replace("{n}",de.size),a.catsSel=((this.lb()||{}).categorias||[]).map(n=>({nombre:n.nombre})),a.recatLabel=this.trStr("Recategorizar…"),a.cancelarLabel=this.trStr("Cancelar"),a.onRecategoriza=n=>{this.recategorizaSeleccion(n.target.value)},a.eliminaSel=()=>this.eliminaSeleccion(),a.limpiaSel=()=>this.limpiaSeleccion(),a.importarTitulo=this.trStr("Importar movimientos"),a.importarDesc=this.trStr("Desde un CSV de la app o de tu banco. Busca las columnas Concepto y Monto sola."),a.importarCsv=()=>this.pideCsv(),a.csvZonaBorde=e.csvSobre?"var(--positivo)":a.tema.borde,a.csvZonaBg=e.csvSobre?a.tema.suave:"transparent",a.csvZonaColor=e.csvSobre?"var(--positivo)":a.tema.gris,a.csvZonaTexto=e.csvSobre?this.trStr("Suelta para importar"):this.trStr("Arrastra un CSV o haz clic para elegirlo"),a.libretasAjustes=(a.libretasDetalle||[]).map(n=>({nombre:n.nombre,inicial:n.inicial,color:n.color,rol:n.rol,detalle:n.tipo+" · "+n.stats,bg:n.esActiva?a.tema.suave:"transparent",rolBg:n.esDueno?"oklch(0.95 0.05 152)":a.tema.suave,rolFg:n.esDueno?"oklch(0.42 0.12 152)":a.tema.gris,go:()=>this.setState({vista:"libretas",libretaVista:n.id})})),a.claveForm=e.claveForm,a.onClaveForm={actual:he("claveForm","actual"),nueva:he("claveForm","nueva"),repetir:he("claveForm","repetir")},a.cambiarClave=()=>this.cambiarClave(),a.botonClave=e.ocupado==="clave"?"Cambiando…":"Cambiar contraseña",a.cerrarOtras=()=>this.cerrarOtras();{const k=(e.usuario||{}).plan||"gratis",T={gratis:"Gratis",pro:"Pro",negocio:"Negocio"};a.planActualNombre=this.trStr(T[k]||"Gratis"),a.planActualEs=k,a.planActualColor=k==="pro"||k==="negocio"?"oklch(0.80 0.14 80)":a.tema.gris,a.planIntro="El plan Gratis no caduca. En la web el cambio a un plan de pago se pide aquí y lo activamos nosotros; desde la app del teléfono se cobra por la App Store.";const v=[{id:"gratis",nombre:"Gratis",para:"Para ti",precio:"US$0",cada:"siempre",items:["Una libreta","Movimientos, cuentas, tarjetas y préstamos sin límite","Presupuesto, metas y los 31 temas","Todo en este equipo y en la app"]},{id:"pro",nombre:"Pro",para:"Para tu casa",precio:"US$2.99",cada:"al mes",items:["Libretas sin límite: la casa, el negocio, lo tuyo","Compartirlas con quien quieras, con permisos","Integraciones: WhatsApp, Instagram o Telegram","Avisos de corte y de cuota por correo","Soporte prioritario"]},{id:"negocio",nombre:"Negocio",para:"Para tu negocio",precio:"US$9.99",cada:"al mes",items:["Todo lo de Pro","Miembros del equipo sin límite","Informes del año y exportación completa","Claves de API para tus propios sistemas"]}];a.planes=v.map(h=>({nombre:this.trStr(h.nombre),para:this.trStr(h.para),precio:h.precio,cada:this.trStr(h.cada),items:h.items.map(ce=>({texto:this.trStr(ce)})),esActual:h.id===k,borde:h.id===k?"var(--acento)":a.tema.borde,bg:h.id===k?"color-mix(in oklab, var(--acento) 8%, "+a.tema.card+")":a.tema.card,botonLabel:h.id===k?"Tu plan actual":h.id==="gratis"?"Bajar a Gratis":"Pedir "+this.trStr(h.nombre),botonBg:h.id===k?a.tema.suave:"var(--acento)",botonFg:h.id===k?a.tema.gris:"var(--sobre-acento)",deshabilitado:h.id===k,go:()=>this.solicitarPlan(h.id)}))}{const n=e.usuario||{},k=e.sesiones||[],T=e.actividad||[];a.mfaActiva=!!n.mfa,a.mfaEstado=n.mfa?"Activada":"Desactivada",a.mfaColor=n.mfa?"var(--positivo)":a.tema.gris,a.mfaAbierto=e.mfaAbierto,a.mfaBotonAbrir=n.mfa?"Desactivar":"Activar",a.mfaTitulo=n.mfa?"Desactivar la verificación":"Activar la verificación",a.mfaTexto=n.mfa?"Tu contraseña sola no abre la cuenta: hace falta también un código.":"Activa al menos un método: al entrar te pediremos un código además de la contraseña.";{const v=e.metodos2p||{},h=e.dp2||null,ce="var(--positivo)",H=(R,xe,Me,ve,De)=>({tipo:R,label:xe,detalle:Me,valor:De||(ve?"Activo":"No"),color:ve?ce:a.tema.gris,boton:R==="respaldo"?ve?"Generar otros":"Generar":ve?"Quitar":"Activar",abierto:!!h&&h.tipo===R,go:()=>this.abrirDosPasos(R,R!=="respaldo"&&ve)});a.dpFilas=[H("correo","Código por correo","Un código de seis cifras a "+(v.correo&&v.correo.pista?v.correo.pista:"tu correo")+".",!!(v.correo&&v.correo.activo)),H("totp","App de autenticación","Google Authenticator, Microsoft Authenticator, Authy o la del teléfono. Sin correo ni señal.",!!(v.totp&&v.totp.activo)),H("telegram","Telegram","El código te llega por mensaje de un bot.",!!(v.telegram&&v.telegram.activo),v.telegram&&v.telegram.activo?v.telegram.pista||"Activo":v.telegram&&v.telegram.disponible===!1?"No disponible":""),H("respaldo","Códigos de respaldo","Ocho códigos de un solo uso por si no tienes correo ni teléfono a mano.",!!(v.respaldo&&v.respaldo.activo),v.respaldo&&v.respaldo.activo?v.respaldo.quedan+" sin usar":"")],a.dpAbierto=!!h,a.dpQuitar=!!(h&&h.quitar),a.dpPaso1=!!(h&&h.paso===1),a.dpTitulo=h?(h.quitar?"Quitar: ":"Activar: ")+({correo:"código por correo",totp:"app de autenticación",telegram:"Telegram",respaldo:"códigos de respaldo"}[h.tipo]||""):"",a.dpClave=h&&h.clave||"",a.onDpClave=R=>this.setState({dp2:{...this.state.dp2||{},clave:R.target.value}}),a.dpEsTotp2=!!(h&&h.tipo==="totp"&&h.paso===2),a.dpQr=h&&h.qr?h.qr:"",a.dpSecreto=h&&h.secreto?h.secreto:"",a.dpCodigo=h&&h.codigo||"",a.onDpCodigo=R=>this.setState({dp2:{...this.state.dp2||{},codigo:String(R.target.value||"").replace(/\D/g,"").slice(0,6)}}),a.dpEsTelegram2=!!(h&&h.tipo==="telegram"&&h.paso===2),a.dpEnlace=h&&h.enlace?h.enlace:"",a.dpBot=h&&h.bot?"@"+h.bot:"",a.dpEsRespaldo2=!!(h&&h.tipo==="respaldo"&&h.paso===2),a.dpCodigos=h&&h.codigos||[],a.dpCopiarCodigos=()=>{try{navigator.clipboard.writeText((h.codigos||[]).join(`
`)),this.avisar("Códigos copiados.")}catch{}},a.dpDescargarCodigos=()=>za("chinola-codigos-respaldo.txt",ja(h&&h.codigos||[])),a.dpError=e.dpError||"",a.dpConfirmar=()=>this.confirmarDosPasos(),a.dpCancelar=()=>this.setState({dp2:null,dpError:""}),a.dpBoton=e.ocupadoMfa?"Un momento…":h?h.paso===1?h.quitar?"Quitar":h.tipo==="correo"?"Activar":"Seguir":h.tipo==="totp"?"Activar":h.tipo==="telegram"?"Ya lo hice":"Listo":""}a.tituloDispositivos="Dónde tienes la sesión abierta",a.sesiones=k.map((v,h)=>({equipo:this.trStr(v.equipo)+(v.actual?" · "+this.trStr("este equipo"):""),detalle:this.trStr("Entró")+" "+this.haceCuanto(v.creado)+" · "+this.trStr("visto")+" "+this.haceCuanto(v.visto),esMovil:/iPhone|iPad|Android/i.test(v.equipo),tinta:v.actual?"var(--positivo)":a.tema.tinta,cerrable:!v.actual,linea:h===k.length-1?"transparent":a.tema.suave,onCerrar:()=>this.cerrarSesionDe(v.id,v.equipo)})),a.hayActividad=T.length>0,a.tituloActividadSeg="Lo último que pasó",a.actividadSeg=T.slice(0,12).map((v,h,ce)=>({accion:v.accion,cuando:this.haceCuanto(v.creado)+" · "+this.trStr(v.origen),linea:h===ce.length-1?"transparent":a.tema.suave}))}a.bajaClave=e.bajaClave,a.onBajaClave=n=>this.setState({bajaClave:n.target.value}),a.eliminarCuenta=()=>this.eliminarCuenta(),a.botonBaja=e.ocupado==="baja"?"Eliminando…":"Eliminar mi cuenta",Array.isArray(a.ajustes)&&(a.ajustes=a.ajustes.filter(n=>Bt[n.sigla]).map(n=>n.sigla==="EX"?{...n,go:()=>this.exportaLibreta()}:n).map(n=>({...n,icono:Bt[n.sigla]}))),e.pantalla&&(a.esOnboarding=!1,a.esAuth=!1,a.esApp=!1);const Z={olvide:{titulo:"Recuperar tu cuenta",texto:"Escribe tu correo y te mandamos un enlace para crear una contraseña nueva.",boton:"Enviarme el enlace",accion:()=>this.pedirEnlace(),email:!0},restablecer:{titulo:"Nueva contraseña",texto:"Elige una contraseña de al menos 6 caracteres. Se cerrarán las sesiones abiertas en otros dispositivos.",boton:"Guardar y entrar",accion:()=>this.restablecer(),clave:!0},verificar:{titulo:"Confirmando tu correo",texto:"Un segundo, estamos activando tu cuenta.",boton:"",accion:()=>{}},invitacion:{titulo:"Te invitaron a una libreta",texto:ue()?"Aceptando la invitación…":"Entra con tu cuenta o crea una con el mismo correo al que llegó la invitación, y la libreta aparecerá sola.",boton:ue()?"":"Entrar o crear cuenta",accion:()=>this.setState({pantalla:null,paso:"auth",authModo:"login"})}}[e.pantalla]||{};return{...a,pantallaExtra:!!e.pantalla,extraTitulo:Z.titulo||"",extraTexto:Z.texto||"",extraBoton:e.extraOcupado?"Un momento…":Z.boton||"",extraHayBoton:!!Z.boton&&!e.extraOk,extraAccion:Z.accion||(()=>{}),extraCampoEmail:!!Z.email&&!e.extraOk,extraCampoClave:!!Z.clave&&!e.extraOk,extraEmail:e.extra.email,extraClave:e.extra.clave,onExtraEmail:o("email"),onExtraClave:o("clave"),extraHayError:!!e.extraError,extraError:e.extraError,extraHayOk:!!e.extraOk,extraOk:e.extraOk,extraVolver:()=>{this.cerrarPantalla(),this.setState({paso:this.state.sesion?"app":"onboarding"})},sinConexion:!!e.sinConexion}}}function ja(j){return`Códigos de respaldo de Chinola
Cada uno vale una sola vez. Guárdalos donde solo tú los veas.

`+(j||[]).join(`
`)+`
`}function za(j,a){try{const e=URL.createObjectURL(new Blob([a],{type:"text/plain;charset=utf-8"})),o=document.createElement("a");o.href=e,o.download=j,document.body.appendChild(o),o.click(),o.remove(),setTimeout(()=>URL.revokeObjectURL(e),2e3)}catch{}}const Aa=`<sc-if value="{{ esOnboarding }}" hint-placeholder-val="{{ true }}">
  <div style="min-height:100vh;display:grid;grid-template-columns:{{ movil.colsBienvenida }};background:oklch(0.975 0.015 95);color:oklch(0.24 0.03 155)">
    <div style="padding:{{ movil.padBienvenida }};display:flex;flex-direction:column;gap:{{ movil.gapBienvenida }};justify-content:center;width:100%;max-width:672px;margin:0 auto">
      <div style="display:flex;align-items:center;gap:11px">
        <div style="width:40px;height:40px;border-radius:50%;background:oklch(0.28 0.07 155);display:flex;align-items:center;justify-content:center"><div style="width:16px;height:16px;border-radius:50%;background:oklch(0.852 0.147 93)"></div></div>
        <span style="font-family:'Bricolage Grotesque',sans-serif;font-weight:800;font-size:26px;letter-spacing:-0.03em">Chinola</span>
      </div>
      <div style="display:flex;flex-direction:column;gap:15px;animation:entra 0.5s ease both">
        <h1 style="margin:0;font-family:'Bricolage Grotesque',sans-serif;font-weight:800;font-size:clamp(30px,7.5vw,50px);line-height:1.06;letter-spacing:-0.035em">{{ slide.titulo }}</h1>
        <p style="margin:0;font-size:18px;line-height:1.55;color:oklch(0.44 0.03 155);max-width:520px">{{ slide.texto }}</p>
      </div>
      <div style="display:flex;gap:8px">
        <sc-for list="{{ dots }}" as="d" hint-placeholder-count="3">
          <button aria-label="{{ d.titulo }}" onClick="{{ d.go }}" style="width:{{ d.w }}px;height:8px;border-radius:4px;border:none;padding:0;cursor:pointer;background:{{ d.bg }}"></button>
        </sc-for>
      </div>
      <div style="display:flex;flex-direction:column;gap:12px;max-width:430px">
        <button onClick="{{ irCrearCuenta }}" style="padding:17px;border-radius:16px;border:none;background:oklch(0.852 0.147 93);color:oklch(0.24 0.05 155);cursor:pointer;font-size:16px;font-weight:700">Crear mi cuenta gratis</button>
        <button onClick="{{ irLogin }}" style="padding:16px;border-radius:16px;border:1px solid oklch(0.88 0.03 120);background:#fff;cursor:pointer;font-size:15px;font-weight:600;color:oklch(0.32 0.05 155)">Ya tengo cuenta · Iniciar sesión</button>
        <div style="font-size:13px;line-height:1.55;color:oklch(0.44 0.03 155)">La web funciona solo con cuenta: así respaldas tus libretas y puedes compartirlas. Para probar sin registro, usa la app móvil en modo local.<br /><a href="/legal/terminos" target="_blank" rel="noopener">{{ pie.terminos }}</a> · <a href="/legal/privacidad" target="_blank" rel="noopener">{{ pie.privacidad }}</a> · <a href="/legal/soporte" target="_blank" rel="noopener">{{ pie.soporte }}</a></div>
      </div>
    </div>
    <div style="background:{{ slide.fondo }};display:flex;align-items:center;justify-content:center;padding:{{ movil.padEscena }};position:relative;overflow:hidden">
      <div style="position:absolute;top:-90px;right:-90px;width:340px;height:340px;border-radius:50%;border:28px solid oklch(1 0 0 / 0.16)"></div>
      <div style="position:relative;display:flex;flex-direction:column;align-items:center;gap:24px;width:100%;max-width:clamp(400px, 55%, 520px)">
        <div style="animation:flota 5s ease-in-out infinite">
          <img src="{{ portada.chinolo }}" alt="" width="172" height="172" style="width:172px;height:172px;flex:none;pointer-events:none" />
        </div>
        <div style="background:#fff;border-radius:18px;padding:22px;width:100%;box-shadow:0 20px 44px oklch(0.28 0.06 90 / 0.22)">
          <div style="font-size:11px;font-weight:700;letter-spacing:0.1em;text-transform:uppercase;color:oklch(0.50 0.05 130)">Libreta · Familia</div>
          <div style="font-family:'Bricolage Grotesque',sans-serif;font-weight:800;font-size:36px;letter-spacing:-0.03em;margin-top:6px;color:oklch(0.24 0.03 155)">RD$8,168</div>
          <div style="display:flex;flex-direction:column;gap:9px;margin-top:14px">
            <sc-for list="{{ demoBarras }}" as="b" hint-placeholder-count="4">
              <div style="display:flex;align-items:center;gap:10px">
                <span style="font-size:12px;width:96px;color:oklch(0.42 0.03 155)">{{ b.label }}</span>
                <span style="flex:1;height:9px;border-radius:4px;background:oklch(0.94 0.02 95);overflow:hidden"><span style="display:block;height:100%;border-radius:4px;width:{{ b.w }}%;background:{{ b.c }}"></span></span>
              </div>
            </sc-for>
          </div>
        </div>
      </div>
    </div>
  </div>
</sc-if>

<sc-if value="{{ esAuth }}" hint-placeholder-val="{{ false }}">
  <div style="min-height:100vh;display:flex;align-items:center;justify-content:center;padding:{{ movil.padAcceso }};background:oklch(0.975 0.015 95);color:oklch(0.24 0.03 155)">
    <div style="width:100%;max-width:430px;background:#fff;border:1px solid oklch(0.91 0.02 95);border-radius:26px;padding:32px;display:flex;flex-direction:column;gap:14px;animation:entra 0.4s ease both">
      <div style="display:flex;align-items:center;gap:10px">
        <div style="width:32px;height:32px;border-radius:50%;background:oklch(0.28 0.07 155);display:flex;align-items:center;justify-content:center"><div style="width:12px;height:12px;border-radius:50%;background:oklch(0.852 0.147 93)"></div></div>
        <span style="font-family:'Bricolage Grotesque',sans-serif;font-weight:800;font-size:20px;letter-spacing:-0.03em">Chinola</span>
      </div>
      <h1 style="margin:0;font-family:'Bricolage Grotesque',sans-serif;font-weight:800;font-size:27px;letter-spacing:-0.03em">{{ authTitulo }}</h1>
      <p style="margin:0;font-size:14px;line-height:1.5;color:oklch(0.44 0.03 155)">{{ authTexto }}</p>
      <sc-if value="{{ esRegistro }}" hint-placeholder-val="{{ true }}">
        <input aria-label="Tu nombre" value="{{ auth.nombre }}" onChange="{{ onAuth.nombre }}" placeholder="Tu nombre" style="padding:14px;border-radius:13px;border:1px solid oklch(0.90 0.02 95)" />
        <input aria-label="Teléfono (opcional)" value="{{ auth.telefono }}" onChange="{{ onAuth.telefono }}" type="tel" placeholder="Teléfono (opcional)" style="padding:14px;border-radius:13px;border:1px solid oklch(0.90 0.02 95)" />
      </sc-if>
      <sc-if value="{{ esCodigo }}" hint-placeholder-val="{{ false }}"><input aria-label="tucorreo@mail.com" value="{{ authCodigo }}" onChange="{{ onAuthCodigo }}" autocomplete="one-time-code" maxlength="9" placeholder="{{ authPhCodigo }}" style="font-size:18px;letter-spacing:0.25em;padding:14px;border-radius:13px;border:1px solid oklch(0.90 0.02 95)" /><sc-if value="{{ hayOtrosMetodos }}" hint-placeholder-val="{{ false }}"><div style="display:flex;flex-wrap:wrap;gap:8px;align-items:center;font-size:12.5px;color:oklch(0.50 0.03 155)"><span>{{ authOtrosRotulo }}</span><sc-for list="{{ authMetodos }}" as="mt" hint-placeholder-count="2"><button type="button" onClick="{{ mt.go }}" style="padding:7px 12px;border-radius:999px;border:1px solid oklch(0.88 0.02 95);background:transparent;cursor:pointer;font-size:12.5px;font-weight:700;color:inherit">{{ mt.label }}</button></sc-for></div></sc-if><span style="font-size:12px;color:oklch(0.55 0.03 155)">{{ authRespaldoNota }}</span><button onClick="{{ authVolverCodigo }}" style="align-self:flex-start;padding:0;border:none;background:transparent;cursor:pointer;font-size:13px;font-weight:600;color:oklch(0.50 0.03 155);text-decoration:underline">{{ authOtraCuenta }}</button></sc-if><sc-if value="{{ noCodigo }}" hint-placeholder-val="{{ true }}"><input aria-label="tucorreo@mail.com" value="{{ auth.email }}" onChange="{{ onAuth.email }}" type="email" placeholder="tucorreo@mail.com" style="padding:14px;border-radius:13px;border:1px solid oklch(0.90 0.02 95)" />
      <input aria-label="Contraseña" value="{{ auth.pass }}" onChange="{{ onAuth.pass }}" type="password" placeholder="Contraseña" style="padding:14px;border-radius:13px;border:1px solid oklch(0.90 0.02 95)" /></sc-if>
      <sc-if value="{{ authError }}" hint-placeholder-val="{{ false }}">
        <div style="padding:12px 14px;border-radius:13px;background:oklch(0.96 0.04 30);color:oklch(0.48 0.15 30);font-size:13px">{{ authErrorTexto }}</div>
      </sc-if>
      <button onClick="{{ enviarAuth }}" style="padding:16px;border-radius:13px;border:none;background:oklch(0.852 0.147 93);color:oklch(0.24 0.05 155);cursor:pointer;font-size:15px;font-weight:700">{{ authBoton }}</button><div style="display:flex;align-items:center;gap:12px;margin:2px 0"><span style="flex:1;height:1px;background:oklch(0.90 0.02 95)"></span><span style="font-size:11px;font-weight:700;letter-spacing:0.06em;text-transform:uppercase;color:oklch(0.55 0.03 155)">o entra con</span><span style="flex:1;height:1px;background:oklch(0.90 0.02 95)"></span></div><div style="display:flex;gap:10px"><button onClick="{{ entrarConGoogle }}" style="flex:1;display:flex;align-items:center;justify-content:center;gap:8px;padding:13px;border-radius:13px;border:1px solid oklch(0.88 0.02 95);background:#fff;color:oklch(0.24 0.03 155);cursor:pointer;font-size:14px;font-weight:700"><svg viewBox="0 0 48 48" style="width:18px;height:18px" aria-hidden="true"><path fill="#EA4335" d="M24 9.5c3.5 0 6.6 1.2 9.1 3.6l6.8-6.8C35.6 2.4 30.2 0 24 0 14.6 0 6.5 5.4 2.6 13.2l7.9 6.2C12.4 13.7 17.7 9.5 24 9.5z"></path><path fill="#4285F4" d="M46.98 24.55c0-1.6-.15-3.15-.42-4.64H24v9.02h12.94c-.56 2.9-2.2 5.36-4.7 7.02l7.6 5.9c4.44-4.1 7.14-10.15 7.14-17.3z"></path><path fill="#FBBC05" d="M10.49 28.6a14.5 14.5 0 0 1 0-9.2l-7.9-6.2a24 24 0 0 0 0 21.6l7.9-6.2z"></path><path fill="#34A853" d="M24 48c6.2 0 11.5-2.05 15.32-5.58l-7.6-5.9c-2.1 1.42-4.8 2.28-7.72 2.28-6.3 0-11.6-4.2-13.5-9.9l-7.9 6.2C6.5 42.6 14.6 48 24 48z"></path></svg>Google</button><button onClick="{{ entrarConApple }}" style="flex:1;display:flex;align-items:center;justify-content:center;gap:8px;padding:13px;border-radius:13px;border:none;background:oklch(0.16 0 0);color:#fff;cursor:pointer;font-size:14px;font-weight:700"><svg viewBox="0 0 24 24" style="width:17px;height:17px" fill="currentColor" aria-hidden="true"><path d="M16.3 12.6c0-2.4 2-3.6 2.1-3.6-1.1-1.7-2.9-1.9-3.6-1.9-1.5-.2-3 .9-3.7.9-.8 0-2-.9-3.2-.8-1.7 0-3.2 1-4 2.5-1.7 3-.4 7.4 1.2 9.8.8 1.2 1.8 2.5 3 2.4 1.2 0 1.7-.8 3.1-.8 1.4 0 1.8.8 3.1.7 1.3 0 2.1-1.2 2.9-2.4.9-1.3 1.3-2.7 1.3-2.7s-2.4-.9-2.4-3.7zM14 5.4c.7-.8 1.1-1.9 1-3-1 0-2.2.7-2.9 1.5-.6.7-1.2 1.9-1 3 1.1.1 2.2-.6 2.9-1.5z"></path></svg>Apple</button></div>
      <sc-if value="{{ esRegistro }}" hint-placeholder-val="{{ true }}"><p style="margin:0;font-size:12px;line-height:1.5;text-align:center;color:oklch(0.50 0.03 155)">{{ pie.aceptas }} <a href="/legal/terminos" target="_blank" rel="noopener">{{ pie.terminos }}</a> {{ pie.y }} <a href="/legal/privacidad" target="_blank" rel="noopener">{{ pie.privacidad }}</a>.</p></sc-if>
      <div style="text-align:center;font-size:14px;color:oklch(0.46 0.03 155)">{{ authSwitchTexto }} <a href="#" onClick="{{ switchAuth }}" style="font-weight:700">{{ authSwitchLink }}</a></div>
      <sc-if value="{{ mostrarOlvide }}" hint-placeholder-val="{{ false }}"><a href="#" onClick="{{ irOlvide }}" style="text-align:center;font-size:13px;font-weight:600;padding:2px">¿Olvidaste tu contraseña?</a></sc-if>
      <button onClick="{{ volverOnboarding }}" style="padding:10px;border:none;background:transparent;cursor:pointer;font-size:13px;color:oklch(0.50 0.03 155)">Volver</button>
    </div>
  </div>
</sc-if>

<sc-if value="{{ esApp }}" hint-placeholder-val="{{ false }}">
  <div style="display:grid;grid-template-columns:{{ barra.col }}px minmax(0,1fr);min-height:100vh;background:{{ tema.bg }};background-image:{{ tema.patron }};color:{{ tema.tinta }}">
    <aside onMouseEnter="{{ barra.onEntra }}" onMouseLeave="{{ barra.onSale }}" style="background:{{ tema.side }};color:oklch(0.96 0.03 95);padding:20px {{ barra.pad }}px;display:flex;flex-direction:column;gap:16px;position:{{ barra.pos }};top:0;left:0;height:100vh;width:{{ barra.ancho }}px;overflow-x:hidden;overflow-y:auto;z-index:{{ barra.z }};box-shadow:{{ barra.sombra }};transform:{{ barra.desplaza }};transition:width 0.18s ease, transform 0.22s ease">
      <div style="display:flex;align-items:center;gap:10px;padding:0 4px">
        <div style="width:{{ barra.chipTop }}px;height:{{ barra.chipTop }}px;flex:0 0 auto;border-radius:50%;background:oklch(0.852 0.147 93);display:flex;align-items:center;justify-content:center"><div style="width:{{ barra.puntoLogo }}px;height:{{ barra.puntoLogo }}px;border-radius:50%;background:{{ tema.side }}"></div></div>
        <span style="display:{{ barra.verBloque }};font-family:'Bricolage Grotesque',sans-serif;font-weight:800;font-size:19px;letter-spacing:-0.03em">Chinola</span>
        <button onClick="{{ barra.fijar }}" title="{{ barra.titulo }}" style="display:{{ barra.verFlex }};margin-left:auto;flex:0 0 auto;width:26px;height:26px;border-radius:8px;border:none;background:oklch(1 0 0 / 0.10);color:oklch(0.90 0.05 110);cursor:pointer;align-items:center;justify-content:center;font-size:13px;line-height:1">{{ barra.icono }}</button>
      </div>

      <button onClick="{{ barra.fijar }}" title="{{ barra.titulo }}" style="display:{{ barra.verModo }};width:{{ barra.chipTop }}px;height:28px;margin:0 auto;border-radius:8px;border:none;background:oklch(1 0 0 / 0.10);color:oklch(0.90 0.05 110);cursor:pointer;align-items:center;justify-content:center;font-size:13px;line-height:1;flex:0 0 auto">{{ barra.icono }}</button>
        <div data-menu="1" style="position:relative">
        <button onClick="{{ toggleSelector }}" title="{{ libreta.nombre }}" style="width:{{ barra.anchoBoton }};height:{{ barra.altoBoton }};margin:0 auto;display:flex;align-items:center;justify-content:{{ barra.justificaBoton }};gap:10px;padding:{{ barra.padSelector }};border-radius:13px;border:1px solid {{ barra.bordeSelector }};background:{{ barra.fondoSelector }};cursor:pointer;text-align:left">
          <span style="width:{{ barra.chipTop }}px;height:{{ barra.chipTop }}px;flex:0 0 auto;border-radius:13px;background:{{ libreta.color }};display:flex;align-items:center;justify-content:center;font-size:{{ barra.fuenteChip }}px;font-weight:800;color:#fff">{{ libreta.inicial }}</span>
          <span style="display:{{ barra.verBloque }};flex:1;min-width:0">
            <span style="display:block;font-size:13px;font-weight:700;color:oklch(0.96 0.03 95);white-space:nowrap;overflow:hidden;text-overflow:ellipsis">{{ libreta.nombre }}</span>
            <span style="display:block;font-size:10px;color:oklch(0.82 0.05 110)">{{ libreta.detalle }}</span>
          </span>
          <span style="display:{{ barra.verBloque }};font-size:11px;color:oklch(0.84 0.04 110)">▾</span>
        </button>
        <sc-if value="{{ selectorOpen }}" hint-placeholder-val="{{ false }}">
          <div style="position:{{ barra.dropPos }};top:{{ barra.dropTop }};left:{{ barra.dropLeft }};right:{{ barra.dropRight }};width:{{ barra.dropAncho }};z-index:70;background:{{ tema.card }};border-radius:16px;box-shadow:0 18px 38px oklch(0.20 0.05 90 / 0.3);overflow:hidden;display:flex;flex-direction:column;animation:aparece 0.15s ease both">
            <sc-for list="{{ libretas }}" as="l" hint-placeholder-count="3">
              <button onClick="{{ l.go }}" style="display:flex;align-items:center;gap:10px;padding:11px 13px;border:none;border-bottom:1px solid {{ tema.suave }};background:{{ l.bg }};cursor:pointer;text-align:left">
                <span style="width:24px;height:24px;border-radius:8px;background:{{ l.color }};display:flex;align-items:center;justify-content:center;font-size:10px;font-weight:800;color:#fff">{{ l.inicial }}</span>
                <span style="flex:1;min-width:0">
                  <span style="display:block;font-size:13px;font-weight:700;color:{{ tema.tinta }}">{{ l.nombre }}</span>
                  <span style="display:block;font-size:10px;color:{{ tema.gris }}">{{ l.detalle }}</span>
                </span>
                <span style="font-size:10px;font-weight:700;color:{{ tema.gris }}">{{ l.rol }}</span>
              </button>
            </sc-for>
            <button onClick="{{ irLibretas }}" style="padding:11px 13px;border:none;background:{{ tema.suave }};cursor:pointer;font-size:12px;font-weight:700;color:{{ tema.tinta }};text-align:left">Administrar libretas →</button>
          </div>
        </sc-if>
      </div>

      <nav style="display:flex;flex-direction:column;gap:3px">
        <sc-if value="{{ puedeRegistrar }}" hint-placeholder-val="{{ true }}">
          <button onClick="{{ nuevaTx }}" title="{{ txt.nuevoMov }}" style="width:{{ barra.anchoBoton }};height:{{ barra.altoBoton }};margin:0 auto 9px;padding:{{ barra.masPad }}px;border-radius:13px;border:none;display:flex;align-items:center;justify-content:{{ barra.justificaBoton }};background:oklch(0.852 0.147 93);color:oklch(0.24 0.05 155);cursor:pointer;font-size:{{ barra.masFuente }}px;font-weight:700;line-height:1;white-space:nowrap;overflow:hidden">{{ barra.nuevo }}</button>
        </sc-if>
        <sc-for list="{{ navItems }}" as="i" hint-placeholder-count="7">
          <button onClick="{{ i.go }}" title="{{ i.label }}" style="display:flex;align-items:center;justify-content:{{ barra.justifica }};gap:10px;text-align:left;padding:11px {{ barra.padBoton }}px;border-radius:13px;border:none;cursor:pointer;font-size:14px;font-weight:600;background:{{ i.bg }};color:{{ i.fg }}">
            <span style="display:flex;align-items:center;gap:10px"><span style="width:{{ barra.chipNav }}px;height:{{ barra.chipNav }}px;border-radius:8px;background:{{ i.icoBg }};display:flex;align-items:center;justify-content:center;flex:0 0 auto"><svg viewBox="0 0 24 24" style="width:{{ barra.icoNav }}px;height:{{ barra.icoNav }}px" fill="none" stroke="{{ i.icoFg }}" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"><path d="{{ i.icono }}"></path></svg></span><span style="display:{{ barra.verBloque }};white-space:nowrap">{{ i.label }}</span></span>
            <span style="display:{{ barra.verBloque }};font-size:11px;color:{{ i.badgeFg }}">{{ i.badge }}</span>
          </button>
        </sc-for>
      </nav>

      <div style="margin-top:auto;display:flex;flex-direction:column;gap:10px">
        <div style="padding:16px 13px 13px;border-radius:18px;background:oklch(1 0 0 / 0.09);display:{{ barra.verFlexCol }};flex-direction:column;align-items:center;gap:10px">
          <div style="position:relative;width:98px;height:86px;display:flex;align-items:flex-end;justify-content:center;animation:{{ mascota.anim }}">
            <sc-if value="{{ mascota.chispas }}" hint-placeholder-val="{{ false }}">
              <span style="position:absolute;top:0;left:6px;width:10px;height:10px;background:oklch(0.92 0.16 95);clip-path:polygon(50% 0,60% 40%,100% 50%,60% 60%,50% 100%,40% 60%,0 50%,40% 40%);animation:chispa 1.8s ease-in-out infinite"></span>
              <span style="position:absolute;top:12px;right:2px;width:13px;height:13px;background:oklch(0.92 0.16 95);clip-path:polygon(50% 0,60% 40%,100% 50%,60% 60%,50% 100%,40% 60%,0 50%,40% 40%);animation:chispa 2.4s ease-in-out infinite"></span>
            </sc-if>
            <sc-if value="{{ mascota.pesas }}" hint-placeholder-val="{{ false }}">
              <span style="position:absolute;bottom:22px;left:0;width:20px;height:9px;border-radius:4px;background:oklch(0.30 0.04 155);animation:pesa 1.5s ease-in-out infinite"></span>
              <span style="position:absolute;bottom:22px;right:0;width:20px;height:9px;border-radius:4px;background:oklch(0.30 0.04 155);animation:pesa 1.5s ease-in-out infinite"></span>
            </sc-if>
            <img src="{{ slide.chinolo }}" alt="" width="86" height="86" style="width:86px;height:86px;flex:none;pointer-events:none" />
            <sc-if value="{{ mascota.vaso }}" hint-placeholder-val="{{ false }}">
              <span style="position:absolute;bottom:0;left:10px;right:10px;height:50px;border:2.5px solid oklch(1 0 0 / 0.55);border-top:none;border-radius:0 0 18px 18px;background:oklch(1 0 0 / 0.1)"></span>
            </sc-if>
          </div>
          <div style="position:relative;background:oklch(0.99 0.01 95);color:oklch(0.24 0.04 155);border-radius:13px;padding:11px 13px;font-size:12px;line-height:1.45;font-weight:600;text-align:center;animation:burbujaIn 0.35s ease both">
            <span style="position:absolute;top:-5px;left:50%;transform:translateX(-50%) rotate(45deg);width:12px;height:12px;background:oklch(0.99 0.01 95);border-radius:4px"></span>
            {{ mascota.frase }}
          </div>
          <div style="display:flex;align-items:center;gap:6px;font-size:10px;font-weight:800;letter-spacing:0.06em;text-transform:uppercase;color:oklch(0.86 0.10 110)">
            <span style="width:7px;height:7px;border-radius:50%;background:{{ mascota.punto }}"></span>{{ mascota.estado }}
          </div>
        </div>
        <div style="display:{{ barra.verBloque }};padding:13px;border-radius:16px;background:oklch(1 0 0 / 0.09)">
          <div style="font-size:10px;text-transform:uppercase;letter-spacing:0.09em;color:oklch(0.84 0.07 110)">{{ txt.balanceMes }}</div>
          <div style="font-family:'Bricolage Grotesque',sans-serif;font-size:22px;font-weight:800;margin-top:4px;letter-spacing:-0.02em;color:{{ balanceColor }}">{{ balanceFmt }}</div>
        </div>
        <div style="display:flex;align-items:center;gap:8px;padding:0 5px">
          <span style="display:inline-flex;align-items:center;gap:6px;font-size:11px;font-weight:700;color:{{ syncColor }}">
            <span style="width:7px;height:7px;border-radius:50%;background:{{ syncDot }};flex:none"></span>{{ syncLabel }}
          </span>
          <button onClick="{{ irAlPlan }}" title="{{ planPieTitulo }}" style="margin-left:auto;font-size:11px;font-weight:800;letter-spacing:0.03em;padding:4px 11px;border-radius:26px;border:1px solid oklch(1 0 0 / 0.18);background:oklch(1 0 0 / 0.08);color:{{ planPieColor }};cursor:pointer">{{ planPieLabel }}</button>
        </div>
        <button onClick="{{ irAjustes }}" style="display:flex;align-items:center;gap:11px;padding:9px;border-radius:13px;border:none;background:transparent;cursor:pointer;text-align:left">
          <span style="width:{{ barra.avatar }}px;height:{{ barra.avatar }}px;flex:0 0 auto;border-radius:50%;background:oklch(0.852 0.147 93);color:oklch(0.24 0.05 155);display:flex;align-items:center;justify-content:center;font-size:{{ barra.fuenteChip }}px;font-weight:800">{{ inicialUsuario }}</span>
          <span style="display:{{ barra.verBloque }};flex:1;min-width:0">
            <span style="display:block;font-size:13px;font-weight:700;color:oklch(0.96 0.03 95);white-space:nowrap;overflow:hidden;text-overflow:ellipsis">{{ nombreUsuario }}</span>
            <span style="display:block;font-size:11px;color:oklch(0.84 0.10 130)">{{ rolLabel }}</span>
          </span>
        </button>
      </div>
    </aside>

    <sc-if value="{{ movil.cajonAbierto }}" hint-placeholder-val="{{ false }}">
      <div onClick="{{ movil.cerrar }}" style="position:fixed;inset:0;z-index:75;background:oklch(0.20 0.04 155 / 0.45);animation:aparece 0.15s ease both"></div>
    </sc-if>

    <main style="padding:{{ movil.padMain }};width:100%;min-width:0;grid-column:{{ movil.columna }}">
      <header style="position:sticky;top:0;z-index:40;background:{{ tema.bg }};background-image:{{ tema.patron }};box-shadow:{{ cabecera.sombra }};padding:{{ movil.padCabecera }};margin:{{ movil.margenCabecera }};display:flex;align-items:flex-end;justify-content:space-between;gap:18px;flex-wrap:wrap">
        <button aria-label="{{ a11y.menu }}" onClick="{{ movil.abrir }}" title="Menú" style="display:{{ movil.ver }};width:44px;height:44px;flex:0 0 auto;margin-right:2px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit;align-items:center;justify-content:center;cursor:pointer">
            <svg viewBox="0 0 24 24" style="width:20px;height:20px" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M4 7h16M4 12h16M4 17h16"></path></svg>
          </button>
          <div style="flex:1;min-width:200px">
          <div style="display:flex;align-items:center;gap:9px;font-size:11px;text-transform:uppercase;letter-spacing:0.11em;color:{{ tema.gris }};font-weight:700">
            <span style="width:9px;height:9px;border-radius:4px;background:{{ libreta.color }}"></span>{{ libreta.nombre }} · {{ viewLabel }}
          </div>
          <h1 style="margin:6px 0 0;font-family:'Bricolage Grotesque',sans-serif;font-size:32px;font-weight:800;letter-spacing:-0.032em">{{ mesLargo }}</h1>
        </div>
        <!-- Selector de periodo. Sustituye a las dos flechas con el mes del prototipo:
     mantiene el paso de mes a mes y añade un calendario con atajos (este mes,
     mes pasado, últimos 3 y 6, este año, año pasado) y rango a medida. Lo que
     se elija manda sobre todos los datos de la pantalla, no solo el título. -->
<div data-menu="1" style="position:relative;flex:0 0 auto">
          <div style="display:flex;align-items:center;background:{{ tema.card }};border:1px solid {{ tema.borde }};border-radius:13px;overflow:hidden">
            <button onClick="{{ periodo.antes }}" title="{{ periodo.tituloAntes }}" style="padding:11px 13px;border:none;background:transparent;cursor:pointer;color:inherit;font-size:15px">‹</button>
            <button onClick="{{ periodo.toggle }}" style="display:flex;align-items:center;justify-content:center;gap:8px;padding:11px 14px;border:none;border-left:1px solid {{ tema.suave }};border-right:1px solid {{ tema.suave }};background:{{ periodo.bg }};cursor:pointer;color:inherit;font-size:13px;font-weight:700;min-width:170px">
              <svg viewBox="0 0 24 24" style="width:16px;height:16px;flex:0 0 auto" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                <path d="M4 6h16v14H4zM4 10h16M8 3v4M16 3v4"></path>
              </svg>{{ periodo.corto }}
            </button>
            <button onClick="{{ periodo.despues }}" title="{{ periodo.tituloDespues }}" style="padding:11px 13px;border:none;background:transparent;cursor:pointer;color:inherit;font-size:15px">›</button>
          </div>

          <sc-if value="{{ periodo.abierto }}" hint-placeholder-val="{{ false }}">
            <div style="position:absolute;top:54px;left:50%;transform:translateX(-50%);z-index:55;background:{{ tema.card }};border:1px solid {{ tema.borde }};border-radius:18px;box-shadow:0 18px 40px oklch(0.20 0.05 90 / 0.24);padding:12px;display:flex;gap:12px;align-items:flex-start;animation:aparece 0.15s ease both">
              <div style="display:flex;flex-direction:column;gap:3px;min-width:172px">
                <sc-for list="{{ periodo.opciones }}" as="o" hint-placeholder-count="7">
                  <button onClick="{{ o.go }}" style="padding:10px 13px;border-radius:13px;border:none;background:{{ o.bg }};color:{{ o.fg }};cursor:pointer;text-align:left;font-size:13px;font-weight:600;white-space:nowrap">{{ o.label }}</button>
                </sc-for>
              </div>

              <sc-if value="{{ periodo.custom }}" hint-placeholder-val="{{ false }}">
                <div style="border-left:1px solid {{ tema.suave }};padding-left:12px;display:flex;flex-direction:column;gap:9px;width:262px">
                  <div style="display:flex;align-items:center;justify-content:space-between;gap:8px">
                    <button onClick="{{ periodo.calAntes }}" style="width:28px;height:28px;border-radius:8px;border:1px solid {{ tema.borde }};background:transparent;cursor:pointer;color:inherit;font-size:13px">‹</button>
                    <span style="font-size:13px;font-weight:700">{{ periodo.calTitulo }}</span>
                    <button onClick="{{ periodo.calDespues }}" style="width:28px;height:28px;border-radius:8px;border:1px solid {{ tema.borde }};background:transparent;cursor:pointer;color:inherit;font-size:13px">›</button>
                  </div>
                  <div style="display:grid;grid-template-columns:repeat(7,1fr);gap:3px">
                    <sc-for list="{{ periodo.diasSemana }}" as="d" hint-placeholder-count="7">
                      <span style="text-align:center;font-size:10px;font-weight:700;text-transform:uppercase;color:{{ tema.gris }};padding:3px 0">{{ d }}</span>
                    </sc-for>
                    <sc-for list="{{ periodo.dias }}" as="d" hint-placeholder-count="35">
                      <button onClick="{{ d.go }}" style="aspect-ratio:1;border:none;border-radius:{{ d.radio }};background:{{ d.bg }};color:{{ d.fg }};cursor:pointer;font-size:12px;font-weight:{{ d.peso }};padding:0;opacity:{{ d.opacidad }}">{{ d.n }}</button>
                    </sc-for>
                  </div>
                  <div style="display:flex;align-items:center;justify-content:space-between;gap:10px;padding-top:2px">
                    <span style="font-size:11px;line-height:1.4;color:{{ tema.gris }}">{{ periodo.seleccion }}</span>
                    <button onClick="{{ periodo.aplicar }}" style="padding:9px 15px;border-radius:13px;border:none;background:oklch(0.852 0.147 93);color:oklch(0.24 0.05 155);cursor:pointer;font-size:12px;font-weight:700;flex:0 0 auto">{{ periodo.textoAplicar }}</button>
                  </div>
                </div>
              </sc-if>
            </div>
          </sc-if>
        </div>
        <div style="display:flex;align-items:center;gap:10px;flex:{{ movil.flexAcciones }};justify-content:flex-end">
          <div data-menu="1" data-menu="1" style="position:relative">
            <button onClick="{{ toggleNotis }}" style="width:46px;height:46px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ notisBg }};cursor:pointer;color:inherit;display:flex;align-items:center;justify-content:center;position:relative">
              <span style="width:15px;height:13px;border-radius:8px 7px 3px 3px;border:2px solid currentColor;border-bottom:none;position:relative;display:block">
                <span style="position:absolute;left:-4px;right:-4px;bottom:-3px;height:2px;border-radius:4px;background:currentColor"></span>
                <span style="position:absolute;left:50%;transform:translateX(-50%);bottom:-6px;width:5px;height:3px;border-radius:0 0 3px 3px;background:currentColor"></span>
              </span>
              <sc-if value="{{ hayAlertas }}" hint-placeholder-val="{{ false }}">
                <span style="position:absolute;top:6px;right:6px;min-width:17px;height:17px;padding:0 4px;border-radius:8px;background:oklch(0.62 0.16 30);color:#fff;font-size:10px;font-weight:800;display:flex;align-items:center;justify-content:center">{{ conteoAlertas }}</span>
              </sc-if>
            </button>
            <sc-if value="{{ notisOpen }}" hint-placeholder-val="{{ false }}">
              <div style="position:absolute;top:54px;right:0;z-index:50;width:334px;background:{{ tema.card }};border:1px solid {{ tema.borde }};border-radius:18px;box-shadow:0 18px 40px oklch(0.20 0.05 90 / 0.2);overflow:hidden;animation:aparece 0.15s ease both">
                <div style="display:flex;justify-content:space-between;align-items:center;padding:14px 16px;background:{{ tema.suave }}">
                  <span style="font-size:13px;font-weight:800">{{ txt.notificaciones }}</span>
                  <button onClick="{{ pedirNotis }}" style="border:none;background:transparent;cursor:pointer;font-size:11px;font-weight:700;color:{{ notisPermColor }}">{{ notisPermLabel }}</button>
                </div>
                <div style="display:flex;flex-direction:column;max-height:340px;overflow-y:auto">
                  <sc-for list="{{ alertas }}" as="a" hint-placeholder-count="3">
                    <button onClick="{{ a.go }}" style="display:flex;align-items:flex-start;gap:11px;padding:13px 16px;border:none;border-bottom:1px solid {{ tema.suave }};background:transparent;cursor:pointer;text-align:left;color:inherit">
                      <span style="width:9px;height:34px;border-radius:4px;background:{{ a.color }};flex:0 0 auto"></span>
                      <span style="flex:1;min-width:0">
                        <span style="display:block;font-size:13px;font-weight:700">{{ a.titulo }}</span>
                        <span style="display:block;font-size:11px;line-height:1.45;color:{{ tema.gris }};margin-top:2px">{{ a.detalle }}</span>
                      </span>
                      <span style="font-size:11px;font-weight:800;color:{{ a.color }};white-space:nowrap">{{ a.plazo }}</span>
                    </button>
                  </sc-for>
                </div>
              </div>
            </sc-if>
          </div>
          <button aria-label="{{ etiquetaAjustes }}" onClick="{{ irAjustes }}" title="{{ etiquetaAjustes }}" style="width:46px;height:46px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ ajustesBg }};cursor:pointer;color:inherit;display:flex;align-items:center;justify-content:center;flex:0 0 auto">
            <svg viewBox="0 0 24 24" style="width:20px;height:20px" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round">
              <path d="M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6"></path>
              <path d="M19.5 12c0-.5-.05-1-.14-1.46l2-1.55-2-3.46-2.36.95a7.5 7.5 0 0 0-2.53-1.47L14.2 2.5H9.8l-.27 2.51a7.5 7.5 0 0 0-2.53 1.47L4.64 5.53l-2 3.46 2 1.55a7.6 7.6 0 0 0 0 2.92l-2 1.55 2 3.46 2.36-.95a7.5 7.5 0 0 0 2.53 1.47l.27 2.51h4.4l.27-2.51a7.5 7.5 0 0 0 2.53-1.47l2.36.95 2-3.46-2-1.55c.09-.47.14-.95.14-1.46Z"></path>
            </svg>
          </button>
        </div>
      </header>

      <sc-if value="{{ soloLectura }}" hint-placeholder-val="{{ false }}">
        <div style="padding:13px 17px;border-radius:16px;background:{{ tema.card }};border:1px solid {{ tema.borde }};margin-bottom:16px;font-size:13px"><b>{{ txt.soloLectura }}</b> · {{ rolTexto }}</div>
      </sc-if>


      <!-- PANEL PERSONALIZABLE -->
      <sc-if value="{{ esPanel }}" hint-placeholder-val="{{ true }}">
        <div style="display:flex;flex-direction:column;gap:16px">
          <div style="display:flex;justify-content:space-between;align-items:center;gap:12px;flex-wrap:wrap">
            <span style="font-size:13px;color:{{ tema.gris }}">{{ panelResumen }}</span>
            <button onClick="{{ toggleEditor }}" style="padding:11px 16px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ editorBg }};cursor:pointer;font-size:13px;font-weight:700;color:{{ editorFg }}">{{ labelEditor }}</button>
          </div>

          <sc-if value="{{ editorOpen }}" hint-placeholder-val="{{ false }}">
            <div style="background:{{ tema.card }};border:1px dashed {{ tema.borde }};border-radius:18px;padding:18px;animation:entra 0.3s ease both">
              <div style="display:flex;justify-content:space-between;align-items:center;gap:12px;flex-wrap:wrap;margin-bottom:12px">
                <span style="font-size:13px;font-weight:700">{{ txtAgregarWidget }}</span>
                <button onClick="{{ restaurarPanel }}" style="padding:9px 14px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};cursor:pointer;font-size:12px;font-weight:600;color:{{ tema.gris }}">{{ labelRestaurar }}</button>
              </div>
              <div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(210px,1fr));gap:10px">
                <sc-for list="{{ catalogo }}" as="c" hint-placeholder-count="8">
                  <button onClick="{{ c.go }}" style="display:flex;flex-direction:column;gap:5px;align-items:flex-start;padding:13px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.suave }};cursor:pointer;text-align:left">
                    <span style="font-size:13px;font-weight:700;color:{{ tema.tinta }}">{{ c.nombre }}</span>
                    <span style="font-size:11px;line-height:1.45;color:{{ tema.gris }}">{{ c.desc }}</span>
                  </button>
                </sc-for>
              </div>
            </div>
          </sc-if>

          <div style="display:grid;grid-template-columns:repeat({{ panelCols }},minmax(0,1fr));gap:16px;align-items:start;min-width:0">
            <sc-for list="{{ widgets }}" as="w" hint-placeholder-count="6">
              <div draggable="{{ editorOpen }}" onDragStart="{{ w.onDragStart }}" onDragOver="{{ w.onDragOver }}" onDrop="{{ w.onDrop }}" onDragEnd="{{ w.onDragEnd }}" style="grid-column:span {{ w.span }};min-width:0;background:{{ tema.card }};border:{{ w.borde }};border-radius:18px;padding:20px;animation:entra 0.4s ease both;opacity:{{ w.opacidad }};cursor:{{ w.cursor }}">
                <div style="display:flex;justify-content:space-between;align-items:center;gap:10px;margin-bottom:{{ w.gap }}px">
                  <span style="display:flex;align-items:center;gap:8px;min-width:0">
                    <sc-if value="{{ editorOpen }}" hint-placeholder-val="{{ false }}">
                      <span style="display:flex;flex-direction:column;gap:2px;flex:0 0 auto">
                        <span style="display:flex;gap:2px"><span style="width:3px;height:3px;border-radius:4px;background:{{ tema.gris }}"></span><span style="width:3px;height:3px;border-radius:4px;background:{{ tema.gris }}"></span></span>
                        <span style="display:flex;gap:2px"><span style="width:3px;height:3px;border-radius:4px;background:{{ tema.gris }}"></span><span style="width:3px;height:3px;border-radius:4px;background:{{ tema.gris }}"></span></span>
                        <span style="display:flex;gap:2px"><span style="width:3px;height:3px;border-radius:4px;background:{{ tema.gris }}"></span><span style="width:3px;height:3px;border-radius:4px;background:{{ tema.gris }}"></span></span>
                      </span>
                    </sc-if>
                    <span style="font-size:11px;text-transform:uppercase;letter-spacing:0.05em;color:{{ tema.gris }};font-weight:700;line-height:1.3;overflow-wrap:anywhere">{{ w.titulo }}</span>
                  </span>
                  <sc-if value="{{ editorOpen }}" hint-placeholder-val="{{ false }}">
                    <span style="display:flex;gap:5px;flex:0 0 auto">
                      <button onClick="{{ w.onAncho }}" style="padding:5px 9px;border-radius:8px;border:1px solid {{ tema.borde }};background:transparent;cursor:pointer;font-size:10px;font-weight:700;color:{{ tema.gris }}">{{ w.anchoLabel }}</button>
                      <button onClick="{{ w.onSubir }}" style="width:26px;height:26px;border-radius:8px;border:1px solid {{ tema.borde }};background:transparent;cursor:pointer;font-size:11px;color:{{ tema.gris }}">↑</button>
                      <button onClick="{{ w.alternaOculta }}" aria-label="Mostrar u ocultar" style="width:26px;height:26px;border-radius:8px;border:1px solid {{ tema.borde }};background:transparent;cursor:pointer;color:{{ tema.gris }};display:flex;align-items:center;justify-content:center"><sc-if value="{{ w.oculta }}" hint-placeholder-val="{{ false }}"><svg viewBox="0 0 24 24" style="width:15px;height:15px" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9.9 5.1A9 9 0 0 1 21 12a9 9 0 0 1-1.3 2.3M6.6 6.6A9 9 0 0 0 3 12a9 9 0 0 0 9 5 8.7 8.7 0 0 0 3.4-.7"></path><path d="M9.9 9.9a3 3 0 0 0 4.2 4.2"></path><path d="M3 3l18 18"></path></svg></sc-if><sc-if value="{{ w.visible }}" hint-placeholder-val="{{ true }}"><svg viewBox="0 0 24 24" style="width:15px;height:15px" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7-10-7-10-7z"></path><circle cx="12" cy="12" r="3"></circle></svg></sc-if></button>
                    </span>
                  </sc-if>
                </div>

                <sc-if value="{{ w.configurable }}" hint-placeholder-val="{{ false }}">
                  <div style="display:flex;gap:8px;flex-wrap:wrap;margin-bottom:14px;padding:10px;border-radius:13px;background:{{ tema.suave }}">
                    <select aria-label="{{ a11y.tipoGrafico }}" value="{{ w.cfgGrafico }}" onChange="{{ w.onGrafico }}" style="padding:8px 10px;border-radius:8px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit;font-size:12px">
                      <sc-for list="{{ tiposGrafico }}" as="g" hint-placeholder-count="4"><option value="{{ g.id }}">{{ g.label }}</option></sc-for>
                    </select>
                    <select aria-label="{{ a11y.cuantoTiempo }}" value="{{ w.cfgRango }}" onChange="{{ w.onRango }}" style="padding:8px 10px;border-radius:8px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit;font-size:12px">
                      <sc-for list="{{ rangosGrafico }}" as="r" hint-placeholder-count="4"><option value="{{ r.id }}">{{ r.label }}</option></sc-for>
                    </select>
                    <sc-for list="{{ w.seriesToggles }}" as="st" hint-placeholder-count="4">
                      <button onClick="{{ st.go }}" style="display:flex;align-items:center;gap:6px;padding:8px 11px;border-radius:18px;border:1px solid {{ st.border }};background:{{ st.bg }};cursor:pointer;font-size:11px;font-weight:700;color:{{ st.fg }}">
                        <span style="width:8px;height:8px;border-radius:4px;background:{{ st.color }}"></span>{{ st.label }}
                      </button>
                    </sc-for>
                  </div>
                </sc-if>

                <sc-if value="{{ w.esSerie }}" hint-placeholder-val="{{ false }}">
                  <div style="display:flex;flex-direction:column;gap:10px">
                    <div style="display:flex;gap:14px;flex-wrap:wrap">
                      <sc-for list="{{ w.leyenda }}" as="s" hint-placeholder-count="2">
                        <span style="display:flex;align-items:center;gap:7px;font-size:12px;color:{{ tema.gris }}">
                          <span style="width:10px;height:10px;border-radius:4px;background:{{ s.color }}"></span>{{ s.label }} <b style="color:{{ tema.tinta }}">{{ s.ultimo }}</b>
                        </span>
                      </sc-for>
                    </div>
                    <svg viewBox="0 0 100 42" preserveAspectRatio="none" style="width:100%;height:170px;overflow:visible">
                      <sc-for list="{{ w.guias }}" as="g" hint-placeholder-count="3">
                        <line x1="0" y1="{{ g.y }}" x2="100" y2="{{ g.y }}" stroke="{{ g.color }}" stroke-width="0.25" vector-effect="non-scaling-stroke"></line>
                      </sc-for>
                      <sc-for list="{{ w.areas }}" as="a" hint-placeholder-count="2">
                        <polygon points="{{ a.puntos }}" fill="{{ a.color }}" opacity="0.18"></polygon>
                      </sc-for>
                      <sc-for list="{{ w.lineas }}" as="ln" hint-placeholder-count="2">
                        <polyline points="{{ ln.puntos }}" fill="none" stroke="{{ ln.color }}" stroke-width="2" stroke-linejoin="round" stroke-linecap="round" vector-effect="non-scaling-stroke"></polyline>
                      </sc-for>
                      <sc-for list="{{ w.barrasSvg }}" as="bs" hint-placeholder-count="6">
                        <rect x="{{ bs.x }}" y="{{ bs.y }}" width="{{ bs.w }}" height="{{ bs.h }}" rx="0.6" fill="{{ bs.color }}"></rect>
                      </sc-for>
                      <sc-for list="{{ w.puntosSvg }}" as="p" hint-placeholder-count="6">
                        <circle cx="{{ p.x }}" cy="{{ p.y }}" r="2.4" fill="{{ p.color }}" vector-effect="non-scaling-stroke"></circle>
                      </sc-for>
                    </svg>
                    <div style="display:flex;justify-content:space-between;font-size:10px;color:{{ tema.gris }}">
                      <sc-for list="{{ w.etiquetas }}" as="e" hint-placeholder-count="6">
                        <span style="flex:1;text-align:center;white-space:nowrap">{{ e }}</span>
                      </sc-for>
                    </div>
                  </div>
                </sc-if>

                <sc-if value="{{ w.esCifra }}" hint-placeholder-val="{{ false }}">
                  <div style="min-width:0">
                    <div style="font-family:'Bricolage Grotesque',sans-serif;font-size:clamp(17px,2.1vw,29px);font-weight:800;letter-spacing:-0.03em;overflow-wrap:anywhere;color:{{ w.color }}">{{ w.valor }}</div>
                    <div style="font-size:12px;color:{{ tema.gris }};margin-top:4px">{{ w.nota }}</div>
                  </div>
                </sc-if>

                <sc-if value="{{ w.esBarras }}" hint-placeholder-val="{{ false }}">
                  <div style="display:flex;flex-direction:column;gap:12px">
                    <sc-for list="{{ w.filas }}" as="r" hint-placeholder-count="5">
                      <div style="display:flex;flex-direction:column;gap:5px">
                        <div style="display:flex;justify-content:space-between;font-size:13px">
                          <span style="font-weight:600">{{ r.label }}</span>
                          <span style="color:{{ tema.gris }}">{{ r.valor }}</span>
                        </div>
                        <div style="height:9px;border-radius:4px;background:{{ tema.suave }};overflow:hidden"><div style="height:100%;border-radius:4px;width:{{ r.pct }}%;background:{{ r.color }}"></div></div>
                      </div>
                    </sc-for>
                  </div>
                </sc-if>

                <sc-if value="{{ w.esColumnas }}" hint-placeholder-val="{{ false }}">
                  <div style="display:flex;gap:14px;flex-wrap:wrap;margin-bottom:10px">
                    <sc-for list="{{ w.leyenda }}" as="s" hint-placeholder-count="2">
                      <span style="display:flex;align-items:center;gap:7px;font-size:12px;color:{{ tema.gris }}"><span style="width:10px;height:10px;border-radius:4px;background:{{ s.color }}"></span>{{ s.label }}</span>
                    </sc-for>
                  </div>
                  <div style="display:flex;align-items:flex-end;gap:12px;height:150px;padding-top:8px">
                    <sc-for list="{{ w.columnas }}" as="t" hint-placeholder-count="6">
                      <div style="flex:1;display:flex;flex-direction:column;align-items:center;gap:7px;height:100%">
                        <div style="flex:1;display:flex;align-items:flex-end;gap:3px;width:100%">
                          <div style="flex:1;border-radius:4px 4px 0 0;background:{{ t.colorA }};height:{{ t.a }}%"></div>
                          <div style="flex:1;border-radius:4px 4px 0 0;background:{{ t.colorB }};height:{{ t.b }}%"></div>
                        </div>
                        <span style="font-size:11px;color:{{ tema.gris }}">{{ t.label }}</span>
                      </div>
                    </sc-for>
                  </div>
                </sc-if>

                <sc-if value="{{ w.esDona }}" hint-placeholder-val="{{ false }}">
                  <div style="display:flex;align-items:center;gap:20px">
                    <div style="width:132px;height:132px;border-radius:50%;background:{{ w.dona }};display:flex;align-items:center;justify-content:center;flex:0 0 auto">
                      <div style="width:80px;height:80px;border-radius:50%;background:{{ tema.card }};display:flex;flex-direction:column;align-items:center;justify-content:center">
                        <span style="font-size:10px;color:{{ tema.gris }}">Total</span>
                        <span style="font-size:13px;font-weight:800">{{ w.total }}</span>
                      </div>
                    </div>
                    <div style="flex:1;display:flex;flex-direction:column;gap:8px">
                      <sc-for list="{{ w.filas }}" as="r" hint-placeholder-count="4">
                        <div style="display:flex;align-items:center;gap:9px;font-size:13px">
                          <span style="width:10px;height:10px;border-radius:4px;background:{{ r.color }}"></span>
                          <span style="flex:1">{{ r.label }}</span>
                          <span style="font-weight:700">{{ r.valor }}</span>
                        </div>
                      </sc-for>
                    </div>
                  </div>
                </sc-if>

                <sc-if value="{{ w.esLista }}" hint-placeholder-val="{{ false }}">
                  <div style="display:flex;flex-direction:column">
                    <sc-for list="{{ w.items }}" as="r" hint-placeholder-count="5">
                      <div style="display:flex;align-items:center;gap:11px;padding:10px 0;border-bottom:1px solid {{ tema.suave }}">
                        <span style="width:32px;height:32px;border-radius:13px;display:flex;align-items:center;justify-content:center;background:{{ r.iconoBg }};color:#fff;font-size:10px;font-weight:800">
                          <sc-if value="{{ r.tieneIcono }}" hint-placeholder-val="{{ true }}">
                            <svg viewBox="0 0 24 24" style="width:18px;height:18px" fill="none" stroke="{{ r.color }}" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="{{ r.iconoPath }}"></path></svg>
                          </sc-if>
                          <sc-if value="{{ r.sinIcono }}" hint-placeholder-val="{{ false }}">{{ r.sigla }}</sc-if>
                        </span>
                        <div style="flex:1;min-width:0">
                          <div style="font-size:13px;font-weight:600">{{ r.titulo }}</div>
                          <div style="font-size:11px;color:{{ tema.gris }}">{{ r.detalle }}</div>
                        </div>
                        <span style="font-size:13px;font-weight:700;color:{{ r.montoColor }}">{{ r.monto }}</span>
                      </div>
                    </sc-for>
                  </div>
                </sc-if>

                <sc-if value="{{ w.esTexto }}" hint-placeholder-val="{{ false }}">
                  <div style="font-size:14px;line-height:1.6;color:{{ tema.gris }}">{{ w.texto }}</div>
                </sc-if>
              </div>
            </sc-for>
          </div>
        </div>
      </sc-if>

      <!-- MOVIMIENTOS -->
      <sc-if value="{{ esTx }}" hint-placeholder-val="{{ false }}">
        <div style="display:flex;flex-direction:column;gap:14px">
          <div style="display:flex;gap:10px;flex-wrap:wrap;align-items:center">
            <input aria-label="{{ txt.buscar }}" data-buscar-movs value="{{ q }}" onChange="{{ onQ }}" placeholder="{{ txt.buscar }}" style="flex:1;min-width:220px;padding:13px 16px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" />
            <sc-for list="{{ filtros }}" as="f" hint-placeholder-count="5">
              <button onClick="{{ f.go }}" style="padding:11px 15px;border-radius:13px;border:1px solid {{ f.border }};cursor:pointer;font-size:13px;font-weight:600;background:{{ f.bg }};color:{{ f.fg }}">{{ f.label }}</button>
            </sc-for>
          </div>
          <sc-if value="{{ haySeleccion }}" hint-placeholder-val="{{ false }}">
            <div style="display:flex;align-items:center;gap:10px;flex-wrap:wrap;padding:11px 16px;border-radius:13px;background:color-mix(in oklab, var(--positivo) 12%, {{ tema.card }});border:1px solid {{ tema.borde }}">
              <span style="font-size:13px;font-weight:800;color:{{ tema.tinta }}">{{ selTexto }}</span>
              <select aria-label="{{ recatLabel }}" onChange="{{ onRecategoriza }}" class="lista" style="padding:9px 30px 9px 12px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit;font-size:13px;font-weight:600;cursor:pointer">
                <option value="">{{ recatLabel }}</option>
                <sc-for list="{{ catsSel }}" as="c" hint-placeholder-count="6">
                  <option value="{{ c.nombre }}">{{ c.nombre }}</option>
                </sc-for>
              </select>
              <button onClick="{{ eliminaSel }}" style="padding:9px 15px;border-radius:13px;border:1px solid oklch(0.88 0.06 30);background:transparent;color:oklch(0.55 0.16 30);cursor:pointer;font-size:13px;font-weight:700">{{ txt.eliminar }}</button>
              <button onClick="{{ limpiaSel }}" style="margin-left:auto;padding:9px 15px;border-radius:13px;border:1px solid {{ tema.borde }};background:transparent;color:{{ tema.gris }};cursor:pointer;font-size:13px;font-weight:700">{{ cancelarLabel }}</button>
            </div>
          </sc-if>
          <div style="background:{{ tema.card }};border:1px solid {{ tema.borde }};border-radius:18px;overflow-x:auto">
            <div style="display:grid;grid-template-columns:28px 2fr 1.1fr 1fr 1.1fr 0.9fr 1fr 46px;gap:12px;min-width:868px;padding:14px 20px;background:{{ tema.suave }};border-radius:18px 20px 0 0;font-size:11px;text-transform:uppercase;letter-spacing:0.07em;color:{{ tema.gris }};font-weight:700">
              <span style="display:flex;align-items:center;justify-content:center"><sc-if value="{{ puedeEditarTx }}" hint-placeholder-val="{{ true }}"><button onClick="{{ onTodoSel }}" aria-label="Seleccionar todo" style="width:18px;height:18px;border-radius:4px;border:2px solid {{ todoSelBorde }};background:{{ todoSelBg }};cursor:pointer;padding:0"></button></sc-if></span><span>{{ txt.concepto }}</span><span>{{ txt.categoria }}</span><span>{{ txt.tipo }}</span><span>{{ txt.pagadoCon }}</span><span>{{ txt.fecha }}</span><span style="text-align:right">{{ txt.monto }}</span><span></span>
            </div>
            <sc-for list="{{ txVisibles }}" as="t" hint-placeholder-count="8">
              <div style="display:grid;grid-template-columns:28px 2fr 1.1fr 1fr 1.1fr 0.9fr 1fr 46px;gap:12px;min-width:868px;padding:12px 20px;border-top:1px solid {{ tema.suave }};align-items:center;font-size:13px;background:{{ t.selFila }}">
                <span style="display:flex;align-items:center;justify-content:center">
                  <sc-if value="{{ puedeEditarTx }}" hint-placeholder-val="{{ true }}">
                    <button onClick="{{ t.onSel }}" aria-label="Seleccionar" style="width:18px;height:18px;border-radius:4px;border:2px solid {{ t.selBorde }};background:{{ t.selBg }};cursor:pointer;padding:0;display:flex;align-items:center;justify-content:center;flex:none">
                      <sc-if value="{{ t.sel }}" hint-placeholder-val="{{ false }}"><svg viewBox="0 0 24 24" style="width:12px;height:12px" fill="none" stroke="#fff" stroke-width="3.5" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6L9 17l-5-5"></path></svg></sc-if>
                    </button>
                  </sc-if>
                </span>
                <span style="display:flex;align-items:center;gap:10px;min-width:0">
                  <span style="width:32px;height:32px;border-radius:13px;display:flex;align-items:center;justify-content:center;background:{{ t.iconoBg }};flex:0 0 auto">
                    <svg viewBox="0 0 24 24" style="width:18px;height:18px" fill="none" stroke="{{ t.catColor }}" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="{{ t.iconoPath }}"></path></svg>
                  </span>
                  <span style="font-weight:600;white-space:nowrap;overflow:hidden;text-overflow:ellipsis">{{ t.concepto }}{{ t.recSuf }}</span>
                </span>
                <span style="color:{{ tema.gris }}">{{ t.categoria }}</span>
                <span><span style="padding:4px 10px;border-radius:18px;font-size:11px;font-weight:700;background:{{ t.tipoBg }};color:{{ t.color }}">{{ t.tipoCorto }}</span></span>
                <span style="color:{{ tema.gris }};font-size:12px">{{ t.medioNombre }}</span>
                <span style="color:{{ tema.gris }}">{{ t.fechaFmt }}</span>
                <span style="text-align:right;font-weight:700;color:{{ t.color }}">{{ t.montoFmt }}</span>
                <span data-menu="1" style="position:relative;display:flex;justify-content:flex-end">
                  <sc-if value="{{ puedeEditarTx }}" hint-placeholder-val="{{ true }}">
                    <button onClick="{{ t.onMenu }}" style="width:30px;height:30px;border-radius:8px;border:none;background:{{ t.menuBg }};cursor:pointer;color:{{ tema.gris }};font-size:15px">⋯</button>
                  </sc-if>
                  <sc-if value="{{ t.menuOpen }}" hint-placeholder-val="{{ false }}">
                    <div style="position:absolute;top:34px;right:0;z-index:20;background:{{ tema.card }};border:1px solid {{ tema.borde }};border-radius:13px;box-shadow:0 14px 28px oklch(0.20 0.05 90 / 0.2);overflow:hidden;min-width:150px;display:flex;flex-direction:column">
                      <button onClick="{{ t.onEdit }}" style="padding:11px 14px;border:none;background:transparent;text-align:left;cursor:pointer;font-size:13px;font-weight:600;color:inherit">{{ txt.editar }}</button>
                      <button onClick="{{ t.onDup }}" style="padding:11px 14px;border:none;background:transparent;text-align:left;cursor:pointer;font-size:13px;font-weight:600;color:inherit">{{ txt.duplicar }}</button>
                      <button onClick="{{ t.onDelete }}" style="padding:11px 14px;border:none;border-top:1px solid {{ tema.suave }};background:transparent;text-align:left;cursor:pointer;font-size:13px;font-weight:600;color:oklch(0.62 0.16 30)">{{ txt.eliminar }}</button>
                    </div>
                  </sc-if>
                </span>
              </div>
            </sc-for>
            <div style="display:flex;justify-content:space-between;padding:14px 20px;border-top:1px solid {{ tema.borde }};background:{{ tema.suave }};border-radius:0 0 20px 20px;font-size:13px;font-weight:800">
              <span>{{ conteoTx }}</span><span>{{ totalFiltrado }}</span>
            </div>
          </div>
        </div>
      </sc-if>

      <!-- CUENTAS -->
      <sc-if value="{{ esCuentas }}" hint-placeholder-val="{{ false }}">
        <div style="display:flex;flex-direction:column;gap:18px">
          <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(190px,1fr));gap:14px">
            <sc-for list="{{ kpisCuentas }}" as="k" hint-placeholder-count="4">
              <div style="background:{{ tema.card }};border:1px solid {{ tema.borde }};border-radius:18px;padding:18px">
                <div style="font-size:11px;text-transform:uppercase;letter-spacing:0.08em;color:{{ tema.gris }};font-weight:700">{{ k.label }}</div>
                <div style="font-family:'Bricolage Grotesque',sans-serif;font-size:clamp(17px,2vw,25px);font-weight:800;margin-top:8px;letter-spacing:-0.03em;overflow-wrap:anywhere;color:{{ k.color }}">{{ k.valor }}</div>
                <div style="font-size:12px;color:{{ tema.gris }};margin-top:3px">{{ k.nota }}</div>
              </div>
            </sc-for>
          </div>

          <div style="display:flex;gap:8px;flex-wrap:wrap;padding:5px;border-radius:16px;background:{{ tema.card }};border:1px solid {{ tema.borde }};align-self:flex-start">
            <sc-for list="{{ subTabs }}" as="st" hint-placeholder-count="3">
              <button onClick="{{ st.go }}" style="display:flex;align-items:center;gap:8px;padding:11px 17px;border-radius:13px;border:none;cursor:pointer;font-size:13px;font-weight:700;background:{{ st.bg }};color:{{ st.fg }}">
                {{ st.label }}<span style="font-size:11px;padding:2px 8px;border-radius:18px;background:{{ st.badgeBg }};color:{{ st.badgeFg }}">{{ st.badge }}</span>
              </button>
            </sc-for>
          </div>

          <sc-if value="{{ subCuentas }}" hint-placeholder-val="{{ true }}">
          <div style="display:flex;align-items:center">
            <h2 style="margin:0;display:flex;align-items:center;gap:10px;font-family:'Bricolage Grotesque',sans-serif;font-size:18px;font-weight:800;letter-spacing:-0.02em">{{ txt.hCuentas }}
              <sc-if value="{{ puedeEditar }}" hint-placeholder-val="{{ true }}">
                <button onClick="{{ toggleAddCuenta }}" title="{{ labelAddCuenta }}" style="width:30px;height:30px;border-radius:50%;border:1px solid {{ tema.borde }};background:{{ tema.card }};cursor:pointer;color:{{ tema.gris }};font-size:17px;font-weight:700;line-height:1;display:flex;align-items:center;justify-content:center">+</button>
              </sc-if>
            </h2>
          </div>
          <sc-if value="{{ addCuenta }}" hint-placeholder-val="{{ false }}">
            <div style="position:fixed;inset:0;background:oklch(0.22 0 0 / 0.45);display:flex;align-items:center;justify-content:center;z-index:65;padding:{{ movil.padModal }};animation:aparece 0.2s ease both">
              <div style="width:100%;max-width:480px;max-height:calc(100vh - 56px);overflow-y:auto;background:{{ tema.card }};border-radius:26px;padding:24px;display:flex;flex-direction:column;gap:14px;animation:entra 0.3s ease both">
                <div style="display:flex;justify-content:space-between;align-items:center">
                  <h2 style="margin:0;font-family:'Bricolage Grotesque',sans-serif;font-size:21px;font-weight:800;letter-spacing:-0.025em">{{ tituloAddCuenta }}</h2>
                  <button onClick="{{ toggleAddCuenta }}" style="width:34px;height:34px;border:none;border-radius:13px;background:{{ tema.suave }};cursor:pointer;font-size:17px;color:{{ tema.gris }}">×</button>
                </div>
                <label style="display:flex;flex-direction:column;gap:6px;font-size:12px;font-weight:600;color:{{ tema.gris }}">{{ catNombreLabel }}
                  <input value="{{ nuevaCuenta.nombre }}" onChange="{{ onCuenta.nombre }}" placeholder="Cuenta de ahorro" style="padding:13px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" /></label>
                <label style="display:flex;flex-direction:column;gap:6px;font-size:12px;font-weight:600;color:{{ tema.gris }}">{{ txt.tipo }}
                  <select value="{{ nuevaCuenta.tipo }}" onChange="{{ onCuenta.tipo }}" style="padding:13px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit">
                    <sc-for list="{{ tiposCuenta }}" as="x" hint-placeholder-count="2"><option value="{{ x }}">{{ x }}</option></sc-for>
                  </select></label>
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;min-width:0">
                  <label style="display:flex;flex-direction:column;gap:6px;font-size:12px;font-weight:600;color:{{ tema.gris }};min-width:0">Banco
                    <input value="{{ nuevaCuenta.banco }}" onChange="{{ onCuenta.banco }}" style="min-width:0;padding:13px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" /></label>
                  <label style="display:flex;flex-direction:column;gap:6px;font-size:12px;font-weight:600;color:{{ tema.gris }};min-width:0">{{ txt.monto }}
                    <input value="{{ nuevaCuenta.saldo }}" onChange="{{ onCuenta.saldo }}" type="number" style="min-width:0;padding:13px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" /></label>
                </div>
                <div style="display:flex;align-items:center;gap:9px;flex-wrap:wrap">
                  <span style="font-size:12px;font-weight:600;color:{{ tema.gris }}">{{ catColorLabel }}</span>
                  <sc-for list="{{ swatchesCuenta }}" as="sw" hint-placeholder-count="7">
                    <button aria-label="{{ a11y.color }}" onClick="{{ sw.go }}" style="width:28px;height:28px;border-radius:8px;cursor:pointer;background:{{ sw.color }};border:2px solid {{ sw.borde }}"></button>
                  </sc-for>
                </div>
                <button onClick="{{ agregarCuenta }}" style="padding:15px;border-radius:13px;border:none;background:oklch(0.852 0.147 93);color:oklch(0.24 0.05 155);cursor:pointer;font-size:15px;font-weight:700">{{ catGuardar }}</button>
              </div>
            </div>
          </sc-if>
          <div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(270px,1fr));gap:14px">
            <sc-for list="{{ cuentas }}" as="a" hint-placeholder-count="2">
              <div style="background:{{ tema.card }};border:1px solid {{ tema.borde }};border-radius:18px;padding:16px;display:flex;flex-direction:column;gap:12px;min-width:0">
                <div style="display:flex;align-items:center;gap:12px;min-width:0">
                  <span style="width:42px;height:42px;border-radius:13px;background:{{ a.color }};display:flex;align-items:center;justify-content:center;color:#fff;font-size:12px;font-weight:800;flex:0 0 auto">{{ a.inicial }}</span>
                  <div style="flex:1;min-width:0">
                    <div style="font-size:14px;font-weight:700;line-height:1.3;overflow-wrap:anywhere">{{ a.nombre }}</div>
                    <div style="font-size:11px;color:{{ tema.gris }};line-height:1.4;overflow-wrap:anywhere">{{ a.banco }} · {{ a.movs }}</div>
                    <div style="font-family:'Bricolage Grotesque',sans-serif;font-size:20px;font-weight:800;letter-spacing:-0.02em;margin-top:6px;overflow-wrap:anywhere">{{ a.saldoFmt }}</div>
                  </div>
                  <div data-menu="1" style="position:relative;flex:0 0 auto;align-self:flex-start">
                    <button onClick="{{ a.onMenu }}" style="width:32px;height:32px;border-radius:8px;border:none;background:{{ a.menuBg }};cursor:pointer;color:{{ tema.gris }};font-size:15px;line-height:1">⋯</button>
                    <sc-if value="{{ a.menuOpen }}" hint-placeholder-val="{{ false }}">
                      <div style="position:absolute;top:36px;right:0;z-index:25;background:{{ tema.card }};border:1px solid {{ tema.borde }};border-radius:13px;box-shadow:0 14px 30px oklch(0.20 0.05 90 / 0.2);overflow:hidden;min-width:220px;display:flex;flex-direction:column;animation:aparece 0.15s ease both">
                        <sc-for list="{{ a.acciones }}" as="ac" hint-placeholder-count="5">
                          <button onClick="{{ ac.go }}" style="padding:11px 15px;border:none;border-bottom:1px solid {{ tema.suave }};background:transparent;text-align:left;cursor:pointer;font-size:13px;font-weight:600;color:{{ ac.color }}">{{ ac.label }}</button>
                        </sc-for>
                      </div>
                    </sc-if>
                  </div>
                </div>
                <sc-if value="{{ a.editando }}" hint-placeholder-val="{{ false }}">
                  <div style="display:flex;flex-direction:column;gap:10px;padding-top:12px;border-top:1px solid {{ tema.suave }};animation:entra 0.25s ease both">
                    <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(120px,1fr));gap:10px;min-width:0">
                      <label style="display:flex;flex-direction:column;gap:5px;font-size:11px;font-weight:600;color:{{ tema.gris }};min-width:0">Nombre
                        <input value="{{ a.nombre }}" onChange="{{ a.setNombre }}" style="min-width:0;padding:10px;border-radius:8px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" /></label>
                      <label style="display:flex;flex-direction:column;gap:5px;font-size:11px;font-weight:600;color:{{ tema.gris }};min-width:0">Banco
                        <input value="{{ a.banco }}" onChange="{{ a.setBanco }}" style="min-width:0;padding:10px;border-radius:8px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" /></label>
                      <label style="display:flex;flex-direction:column;gap:5px;font-size:11px;font-weight:600;color:{{ tema.gris }};min-width:0">Saldo
                        <input value="{{ a.saldo }}" onChange="{{ a.setSaldo }}" type="number" style="min-width:0;padding:10px;border-radius:8px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" /></label>
                    </div>
                    <div style="display:flex;align-items:center;gap:8px;flex-wrap:wrap">
                      <sc-for list="{{ a.swatches }}" as="sw" hint-placeholder-count="7">
                        <button aria-label="{{ a11y.color }}" onClick="{{ sw.go }}" style="width:24px;height:24px;border-radius:8px;cursor:pointer;background:{{ sw.color }};border:2px solid {{ sw.borde }}"></button>
                      </sc-for>
                      <button onClick="{{ a.onCerrar }}" style="margin-left:auto;padding:9px 15px;border-radius:8px;border:none;background:{{ tema.side }};color:oklch(0.96 0.03 95);cursor:pointer;font-size:12px;font-weight:700">Listo</button>
                    </div>
                  </div>
                </sc-if>
                <sc-if value="{{ a.transfiriendo }}" hint-placeholder-val="{{ false }}">
                  <div style="display:flex;flex-direction:column;gap:10px;padding-top:12px;border-top:1px solid {{ tema.suave }};animation:entra 0.25s ease both">
                    <span style="font-size:12px;font-weight:700">Transferir desde esta cuenta</span>
                    <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(130px,1fr));gap:10px;min-width:0">
                      <select aria-label="{{ a11y.aQueCuenta }}" value="{{ a.destino }}" onChange="{{ a.onDestino }}" style="min-width:0;padding:11px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit">
                        <sc-for list="{{ a.destinos }}" as="d" hint-placeholder-count="3"><option value="{{ d.id }}">{{ d.label }}</option></sc-for>
                      </select>
                      <input aria-label="Monto" value="{{ a.montoTr }}" onChange="{{ a.onMontoTr }}" type="number" placeholder="Monto" style="min-width:0;padding:11px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" />
                      <button onClick="{{ a.onTransferir }}" style="padding:12px 15px;border-radius:13px;border:none;background:{{ tema.side }};color:oklch(0.96 0.03 95);cursor:pointer;font-size:13px;font-weight:700">Transferir</button>
                    </div>
                    <span style="font-size:11px;line-height:1.5;color:{{ tema.gris }}">Se registran dos movimientos: salida aquí y entrada en la cuenta o tarjeta de destino.</span>
                  </div>
                </sc-if>
              </div>
            </sc-for>
          </div>

          </sc-if>

          <sc-if value="{{ subTarjetas }}" hint-placeholder-val="{{ false }}">
          <div style="display:flex;align-items:center">
            <h2 style="margin:0;display:flex;align-items:center;gap:10px;font-family:'Bricolage Grotesque',sans-serif;font-size:18px;font-weight:800;letter-spacing:-0.02em">{{ txt.hTarjetas }}
              <sc-if value="{{ puedeEditar }}" hint-placeholder-val="{{ true }}">
                <button onClick="{{ toggleAddTarjeta }}" title="{{ labelAddTarjeta }}" style="width:30px;height:30px;border-radius:50%;border:1px solid {{ tema.borde }};background:{{ tema.card }};cursor:pointer;color:{{ tema.gris }};font-size:17px;font-weight:700;line-height:1;display:flex;align-items:center;justify-content:center">+</button>
              </sc-if>
            </h2>
          </div>
          <sc-if value="{{ addTarjeta }}" hint-placeholder-val="{{ false }}">
            <div style="position:fixed;inset:0;background:oklch(0.22 0 0 / 0.45);display:flex;align-items:center;justify-content:center;z-index:65;padding:{{ movil.padModal }};animation:aparece 0.2s ease both">
              <div style="width:100%;max-width:520px;max-height:calc(100vh - 56px);overflow-y:auto;background:{{ tema.card }};border-radius:26px;padding:24px;display:flex;flex-direction:column;gap:14px;animation:entra 0.3s ease both">
                <div style="display:flex;justify-content:space-between;align-items:center">
                  <h2 style="margin:0;font-family:'Bricolage Grotesque',sans-serif;font-size:21px;font-weight:800;letter-spacing:-0.025em">{{ tituloAddTarjeta }}</h2>
                  <button onClick="{{ toggleAddTarjeta }}" style="width:34px;height:34px;border:none;border-radius:13px;background:{{ tema.suave }};cursor:pointer;font-size:17px;color:{{ tema.gris }}">×</button>
                </div>
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;min-width:0">
                  <label style="display:flex;flex-direction:column;gap:6px;font-size:12px;font-weight:600;color:{{ tema.gris }};min-width:0">{{ catNombreLabel }}
                    <input value="{{ nuevaTarjeta.nombre }}" onChange="{{ onTarjeta.nombre }}" placeholder="Visa Clásica" style="min-width:0;padding:13px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" /></label>
                  <label style="display:flex;flex-direction:column;gap:6px;font-size:12px;font-weight:600;color:{{ tema.gris }};min-width:0">Banco
                    <input value="{{ nuevaTarjeta.banco }}" onChange="{{ onTarjeta.banco }}" style="min-width:0;padding:13px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" /></label>
                  <label style="display:flex;flex-direction:column;gap:6px;font-size:12px;font-weight:600;color:{{ tema.gris }};min-width:0">{{ txt.usoLimite }}
                    <input value="{{ nuevaTarjeta.limite }}" onChange="{{ onTarjeta.limite }}" type="number" style="min-width:0;padding:13px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" /></label>
                  <label style="display:flex;flex-direction:column;gap:6px;font-size:12px;font-weight:600;color:{{ tema.gris }};min-width:0">{{ txt.deudaActual }}
                    <input value="{{ nuevaTarjeta.saldo }}" onChange="{{ onTarjeta.saldo }}" type="number" style="min-width:0;padding:13px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" /></label>
                  <label style="display:flex;flex-direction:column;gap:6px;font-size:12px;font-weight:600;color:{{ tema.gris }};min-width:0">{{ txt.corteDia }}
                    <input value="{{ nuevaTarjeta.corte }}" onChange="{{ onTarjeta.corte }}" type="number" min="1" max="31" style="min-width:0;padding:13px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" /></label>
                  <label style="display:flex;flex-direction:column;gap:6px;font-size:12px;font-weight:600;color:{{ tema.gris }};min-width:0">{{ txt.pagoDia }}
                    <input value="{{ nuevaTarjeta.pago }}" onChange="{{ onTarjeta.pago }}" type="number" min="1" max="31" style="min-width:0;padding:13px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" /></label>
                </div>
                <button onClick="{{ agregarTarjeta }}" style="padding:15px;border-radius:13px;border:none;background:oklch(0.852 0.147 93);color:oklch(0.24 0.05 155);cursor:pointer;font-size:15px;font-weight:700">{{ catGuardar }}</button>
              </div>
            </div>
          </sc-if>
          <div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(330px,1fr));gap:16px;align-items:start">
            <sc-for list="{{ tarjetas }}" as="c" hint-placeholder-count="2">
              <div style="display:flex;flex-direction:column;gap:11px;animation:entra 0.4s ease both">
                <div style="border-radius:18px;padding:20px;aspect-ratio:1.6;display:flex;flex-direction:column;justify-content:space-between;color:#fff;background:{{ c.fondo }};box-shadow:0 14px 30px oklch(0.24 0.05 90 / 0.24)">
                  <div style="display:flex;justify-content:space-between;align-items:flex-start">
                    <div>
                      <div style="font-family:'Bricolage Grotesque',sans-serif;font-size:17px;font-weight:800;letter-spacing:-0.02em">{{ c.nombre }}</div>
                      <div style="font-size:10px;opacity:0.78;text-transform:uppercase;letter-spacing:0.13em;margin-top:3px">{{ c.banco }}</div>
                    </div>
                    <div style="display:flex;align-items:center;gap:8px;flex:0 0 auto">
                      <span style="font-size:10px;padding:5px 10px;border-radius:18px;background:rgba(255,255,255,0.2);white-space:nowrap">{{ c.plazo }}</span>
                      <div data-menu="1" style="position:relative">
                        <button onClick="{{ c.onMenu }}" style="width:30px;height:30px;border-radius:8px;border:none;background:rgba(255,255,255,0.2);color:#fff;cursor:pointer;font-size:15px;line-height:1">⋯</button>
                        <sc-if value="{{ c.menuOpen }}" hint-placeholder-val="{{ false }}">
                          <div style="position:absolute;top:34px;right:0;z-index:26;background:{{ tema.card }};border-radius:13px;box-shadow:0 14px 30px oklch(0.20 0.05 90 / 0.3);overflow:hidden;min-width:224px;display:flex;flex-direction:column;animation:aparece 0.15s ease both">
                            <sc-for list="{{ c.acciones }}" as="ac" hint-placeholder-count="6">
                              <button onClick="{{ ac.go }}" style="padding:11px 15px;border:none;border-bottom:1px solid {{ tema.suave }};background:transparent;text-align:left;cursor:pointer;font-size:13px;font-weight:600;color:{{ ac.color }}">{{ ac.label }}</button>
                            </sc-for>
                          </div>
                        </sc-if>
                      </div>
                    </div>
                  </div>
                  <div style="display:flex;align-items:center;gap:13px">
                    <span style="width:40px;height:28px;border-radius:8px;background:rgba(255,255,255,0.34)"></span>
                    <span style="font-size:16px;letter-spacing:0.16em;opacity:0.9">•••• {{ c.last4 }}</span>
                  </div>
                  <div style="display:flex;justify-content:space-between;align-items:flex-end;gap:12px">
                    <div style="min-width:0">
                      <div style="font-size:10px;opacity:0.7;text-transform:uppercase;letter-spacing:0.1em">{{ txt.deudaActual }}</div>
                      <div style="font-family:'Bricolage Grotesque',sans-serif;font-size:25px;font-weight:800;white-space:nowrap">{{ c.saldoFmt }}</div>
                    </div>
                    <div style="text-align:right;font-size:11px;opacity:0.85;line-height:1.6;white-space:nowrap">
                      <div>{{ txt.corteDia }} {{ c.corte }}</div>
                      <div>{{ txt.pagoDia }} {{ c.pago }}</div>
                    </div>
                  </div>
                  <div style="display:flex;flex-direction:column;gap:6px">
                    <div style="display:flex;justify-content:space-between;font-size:10px;opacity:0.9">
                      <span>{{ txt.usoLimite }}</span><span style="font-weight:800">{{ c.usoLabel }} · {{ c.limiteFmt }}</span>
                    </div>
                    <div style="height:7px;border-radius:4px;background:rgba(255,255,255,0.24);overflow:hidden"><div style="height:100%;border-radius:4px;width:{{ c.uso }}%;background:#fff"></div></div>
                  </div>
                </div>
                <sc-if value="{{ c.pagando }}" hint-placeholder-val="{{ false }}">
                  <div style="background:{{ tema.card }};border:1px solid {{ tema.borde }};border-radius:18px;padding:16px;display:flex;flex-direction:column;gap:10px;animation:entra 0.25s ease both">
                    <span style="font-size:12px;font-weight:700">Registrar pago de {{ c.nombre }}</span>
                    <div style="display:flex;gap:8px;min-width:0">
                      <input aria-label="Monto a pagar" value="{{ c.abono }}" onChange="{{ c.onAbono }}" type="number" placeholder="Monto a pagar" style="flex:1;min-width:0;padding:11px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" />
                      <button onClick="{{ c.onPagar }}" style="padding:11px 16px;border-radius:13px;border:none;background:{{ tema.side }};color:oklch(0.96 0.03 95);cursor:pointer;font-size:13px;font-weight:700">Pagar</button>
                    </div>
                    <span style="font-size:11px;color:{{ tema.gris }}">Si lo dejas vacío se paga el saldo completo ({{ c.saldoFmt }}).</span>
                  </div>
                </sc-if>
              </div>
            </sc-for>
          </div>

          </sc-if>

          <sc-if value="{{ subPrestamos }}" hint-placeholder-val="{{ false }}">
          <div style="display:flex;align-items:center">
            <h2 style="margin:0;display:flex;align-items:center;gap:10px;font-family:'Bricolage Grotesque',sans-serif;font-size:18px;font-weight:800;letter-spacing:-0.02em">{{ txt.hPrestamos }}
              <sc-if value="{{ puedeEditar }}" hint-placeholder-val="{{ true }}">
                <button onClick="{{ toggleAddPrestamo }}" title="{{ labelAddPrestamo }}" style="width:30px;height:30px;border-radius:50%;border:1px solid {{ tema.borde }};background:{{ tema.card }};cursor:pointer;color:{{ tema.gris }};font-size:17px;font-weight:700;line-height:1;display:flex;align-items:center;justify-content:center">+</button>
              </sc-if>
            </h2>
          </div>
          <sc-if value="{{ addPrestamo }}" hint-placeholder-val="{{ false }}">
            <div style="position:fixed;inset:0;background:oklch(0.22 0 0 / 0.45);display:flex;align-items:center;justify-content:center;z-index:65;padding:{{ movil.padModal }};animation:aparece 0.2s ease both">
              <div style="width:100%;max-width:500px;max-height:calc(100vh - 56px);overflow-y:auto;background:{{ tema.card }};border-radius:26px;padding:24px;display:flex;flex-direction:column;gap:14px;animation:entra 0.3s ease both">
                <div style="display:flex;justify-content:space-between;align-items:center">
                  <h2 style="margin:0;font-family:'Bricolage Grotesque',sans-serif;font-size:21px;font-weight:800;letter-spacing:-0.025em">{{ tituloAddPrestamo }}</h2>
                  <button onClick="{{ toggleAddPrestamo }}" style="width:34px;height:34px;border:none;border-radius:13px;background:{{ tema.suave }};cursor:pointer;font-size:17px;color:{{ tema.gris }}">×</button>
                </div>
                <label style="display:flex;flex-direction:column;gap:6px;font-size:12px;font-weight:600;color:{{ tema.gris }}">{{ catNombreLabel }}
                  <input value="{{ nuevoPrestamo.nombre }}" onChange="{{ onPrestamo.nombre }}" style="padding:13px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" /></label>
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;min-width:0">
                  <label style="display:flex;flex-direction:column;gap:6px;font-size:12px;font-weight:600;color:{{ tema.gris }};min-width:0">Total
                    <input value="{{ nuevoPrestamo.total }}" onChange="{{ onPrestamo.total }}" type="number" style="min-width:0;padding:13px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" /></label>
                  <label style="display:flex;flex-direction:column;gap:6px;font-size:12px;font-weight:600;color:{{ tema.gris }};min-width:0">{{ txt.ahorrado }}
                    <input value="{{ nuevoPrestamo.pagado }}" onChange="{{ onPrestamo.pagado }}" type="number" style="min-width:0;padding:13px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" /></label>
                  <label style="display:flex;flex-direction:column;gap:6px;font-size:12px;font-weight:600;color:{{ tema.gris }};min-width:0">{{ txt.cuotaLabel }}
                    <input value="{{ nuevoPrestamo.cuota }}" onChange="{{ onPrestamo.cuota }}" type="number" style="min-width:0;padding:13px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" /></label>
                  <label style="display:flex;flex-direction:column;gap:6px;font-size:12px;font-weight:600;color:{{ tema.gris }};min-width:0">{{ txt.pagoDia }}
                    <input value="{{ nuevoPrestamo.dia }}" onChange="{{ onPrestamo.dia }}" type="number" min="1" max="31" style="min-width:0;padding:13px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" /></label>
                </div>
                <button onClick="{{ agregarPrestamo }}" style="padding:15px;border-radius:13px;border:none;background:oklch(0.852 0.147 93);color:oklch(0.24 0.05 155);cursor:pointer;font-size:15px;font-weight:700">{{ catGuardar }}</button>
              </div>
            </div>
          </sc-if>
          <div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(360px,1fr));gap:14px;align-items:start">
            <sc-for list="{{ prestamos }}" as="d" hint-placeholder-count="2">
              <div style="background:{{ tema.card }};border:1px solid {{ tema.borde }};border-radius:18px;overflow:hidden;min-width:0;animation:entra 0.4s ease both">
                <div style="padding:20px;background:{{ d.fondo }};color:#fff;display:flex;align-items:center;gap:16px;min-width:0">
                  <div style="width:74px;height:74px;border-radius:50%;background:{{ d.anillo }};display:flex;align-items:center;justify-content:center;flex:0 0 auto">
                    <div style="width:56px;height:56px;border-radius:50%;background:{{ d.centro }};display:flex;flex-direction:column;align-items:center;justify-content:center">
                      <span style="font-family:'Bricolage Grotesque',sans-serif;font-size:16px;font-weight:800;line-height:1">{{ d.pctLabel }}</span>
                      <span style="font-size:8px;opacity:0.8;letter-spacing:0.08em;text-transform:uppercase">{{ txt.pagadoRing }}</span>
                    </div>
                  </div>
                  <div style="flex:1;min-width:0">
                    <div style="font-family:'Bricolage Grotesque',sans-serif;font-size:18px;font-weight:800;letter-spacing:-0.02em;white-space:nowrap;overflow:hidden;text-overflow:ellipsis">{{ d.nombre }}</div>
                    <div style="font-size:11px;opacity:0.86;margin-top:3px">{{ d.subtitulo }}</div>
                    <div style="font-size:11px;opacity:0.9;margin-top:8px;padding:4px 9px;border-radius:18px;background:rgba(255,255,255,0.18);display:inline-block">{{ d.plazo }}</div>
                  </div>
                  <div data-menu="1" style="position:relative;flex:0 0 auto;align-self:flex-start">
                    <button onClick="{{ d.onMenu }}" style="width:30px;height:30px;border-radius:8px;border:none;background:rgba(255,255,255,0.2);color:#fff;cursor:pointer;font-size:15px;line-height:1">⋯</button>
                    <sc-if value="{{ d.menuOpen }}" hint-placeholder-val="{{ false }}">
                      <div style="position:absolute;top:34px;right:0;z-index:26;background:{{ tema.card }};border-radius:13px;box-shadow:0 14px 30px oklch(0.20 0.05 90 / 0.3);overflow:hidden;min-width:224px;display:flex;flex-direction:column;animation:aparece 0.15s ease both">
                        <sc-for list="{{ d.acciones }}" as="ac" hint-placeholder-count="5">
                          <button onClick="{{ ac.go }}" style="padding:11px 15px;border:none;border-bottom:1px solid {{ tema.suave }};background:transparent;text-align:left;cursor:pointer;font-size:13px;font-weight:600;color:{{ ac.color }}">{{ ac.label }}</button>
                        </sc-for>
                      </div>
                    </sc-if>
                  </div>
                </div>
                <div style="padding:16px 20px 18px;display:flex;flex-direction:column;gap:12px">
                  <div style="display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:10px">
                    <sc-for list="{{ d.cifras }}" as="x" hint-placeholder-count="3">
                      <div style="padding:11px;border-radius:13px;background:{{ tema.suave }};min-width:0">
                        <div style="font-size:10px;text-transform:uppercase;letter-spacing:0.07em;color:{{ tema.gris }};font-weight:700">{{ x.label }}</div>
                        <div style="font-size:14px;font-weight:800;margin-top:4px;overflow-wrap:anywhere;color:{{ x.color }}">{{ x.valor }}</div>
                      </div>
                    </sc-for>
                  </div>
                  <div style="height:9px;border-radius:4px;background:{{ tema.suave }};overflow:hidden"><div style="height:100%;border-radius:4px;width:{{ d.pct }}%;background:{{ d.color }}"></div></div>
                  <sc-if value="{{ d.editando }}" hint-placeholder-val="{{ false }}">
                    <div style="display:flex;flex-direction:column;gap:10px;padding-top:10px;border-top:1px solid {{ tema.suave }};animation:entra 0.25s ease both">
                      <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(110px,1fr));gap:10px;min-width:0">
                        <label style="display:flex;flex-direction:column;gap:5px;font-size:11px;font-weight:600;color:{{ tema.gris }};min-width:0">Nombre
                          <input value="{{ d.nombre }}" onChange="{{ d.setNombre }}" style="min-width:0;padding:10px;border-radius:8px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" /></label>
                        <label style="display:flex;flex-direction:column;gap:5px;font-size:11px;font-weight:600;color:{{ tema.gris }};min-width:0">Total
                          <input value="{{ d.total }}" onChange="{{ d.setTotal }}" type="number" style="min-width:0;padding:10px;border-radius:8px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" /></label>
                        <label style="display:flex;flex-direction:column;gap:5px;font-size:11px;font-weight:600;color:{{ tema.gris }};min-width:0">Pagado
                          <input value="{{ d.pagado }}" onChange="{{ d.setPagado }}" type="number" style="min-width:0;padding:10px;border-radius:8px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" /></label>
                        <label style="display:flex;flex-direction:column;gap:5px;font-size:11px;font-weight:600;color:{{ tema.gris }};min-width:0">Cuota
                          <input value="{{ d.cuota }}" onChange="{{ d.setCuota }}" type="number" style="min-width:0;padding:10px;border-radius:8px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" /></label>
                        <label style="display:flex;flex-direction:column;gap:5px;font-size:11px;font-weight:600;color:{{ tema.gris }};min-width:0">Día
                          <input value="{{ d.dia }}" onChange="{{ d.setDia }}" type="number" style="min-width:0;padding:10px;border-radius:8px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" /></label>
                      </div>
                      <div style="display:flex;align-items:center;gap:8px;flex-wrap:wrap">
                        <sc-for list="{{ d.swatches }}" as="sw" hint-placeholder-count="7">
                          <button aria-label="{{ a11y.color }}" onClick="{{ sw.go }}" style="width:24px;height:24px;border-radius:8px;cursor:pointer;background:{{ sw.color }};border:2px solid {{ sw.borde }}"></button>
                        </sc-for>
                        <button onClick="{{ d.onCerrar }}" style="margin-left:auto;padding:9px 15px;border-radius:8px;border:none;background:{{ tema.side }};color:oklch(0.96 0.03 95);cursor:pointer;font-size:12px;font-weight:700">Listo</button>
                      </div>
                    </div>
                  </sc-if>
                  <sc-if value="{{ d.pagando }}" hint-placeholder-val="{{ false }}">
                    <div style="display:flex;gap:8px;min-width:0;padding-top:10px;border-top:1px solid {{ tema.suave }};animation:entra 0.25s ease both">
                      <input aria-label="Monto del abono" value="{{ d.abono }}" onChange="{{ d.onAbono }}" type="number" placeholder="Monto del abono" style="flex:1;min-width:0;padding:11px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" />
                      <button onClick="{{ d.onPagar }}" style="padding:11px 16px;border-radius:13px;border:none;background:{{ tema.side }};color:oklch(0.96 0.03 95);cursor:pointer;font-size:13px;font-weight:700">Registrar</button>
                    </div>
                  </sc-if>
                </div>
              </div>
            </sc-for>
          </div>
          </sc-if>
        </div>
      </sc-if>

      <!-- PRESUPUESTO -->
      <sc-if value="{{ esPresupuesto }}" hint-placeholder-val="{{ false }}">
        <div style="display:flex;flex-direction:column;gap:16px">
          <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(210px,1fr));gap:14px">
            <sc-for list="{{ kpisPresupuesto }}" as="k" hint-placeholder-count="3">
              <div style="background:{{ tema.card }};border:1px solid {{ tema.borde }};border-radius:18px;padding:18px">
                <div style="font-size:11px;text-transform:uppercase;letter-spacing:0.08em;color:{{ tema.gris }};font-weight:700">{{ k.label }}</div>
                <div style="font-family:'Bricolage Grotesque',sans-serif;font-size:clamp(17px,2vw,25px);font-weight:800;margin-top:8px;letter-spacing:-0.03em;overflow-wrap:anywhere;color:{{ k.color }}">{{ k.valor }}</div>
                <div style="font-size:12px;color:{{ tema.gris }};margin-top:3px">{{ k.nota }}</div>
              </div>
            </sc-for>
          </div>
          <div style="background:{{ tema.card }};border:1px solid {{ tema.borde }};border-radius:18px;padding:20px">
            <h2 style="margin:0;display:flex;align-items:center;gap:10px;font-family:'Bricolage Grotesque',sans-serif;font-size:18px;font-weight:800;letter-spacing:-0.02em">{{ txt.limiteCat }}
              <sc-if value="{{ puedeEditar }}" hint-placeholder-val="{{ true }}">
                <button onClick="{{ abrirCatNueva }}" title="{{ txt.agregarCat }}" style="width:30px;height:30px;border-radius:50%;border:1px solid {{ tema.borde }};background:{{ tema.card }};cursor:pointer;color:{{ tema.gris }};font-size:17px;font-weight:700;line-height:1;display:flex;align-items:center;justify-content:center">+</button>
              </sc-if>
            </h2>
            <p style="margin:6px 0 18px;font-size:13px;color:{{ tema.gris }}">{{ txt.limiteCatSub }}</p>
            <div style="display:flex;flex-direction:column;gap:14px">
              <sc-for list="{{ presupuestoRows }}" as="p" hint-placeholder-count="8">
                <div style="display:grid;grid-template-columns:1.2fr 120px 1fr 140px 40px;gap:14px;align-items:center;min-width:0">
                  <span style="display:flex;align-items:center;gap:11px;font-size:13px;font-weight:600;min-width:0">
                    <span style="width:34px;height:34px;border-radius:13px;background:{{ p.iconoBg }};display:flex;align-items:center;justify-content:center;flex:0 0 auto">
                      <svg viewBox="0 0 24 24" style="width:19px;height:19px" fill="none" stroke="{{ p.catColor }}" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="{{ p.iconoPath }}"></path></svg>
                    </span>
                    <span style="overflow-wrap:anywhere">{{ p.nombre }}</span>
                  </span>
                  <input aria-label="{{ a11y.limite }}" value="{{ p.limite }}" onChange="{{ p.onChange }}" type="number" style="padding:10px 11px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit;text-align:right" />
                  <div style="display:flex;flex-direction:column;gap:5px">
                    <div style="height:9px;border-radius:4px;background:{{ tema.suave }};overflow:hidden"><div style="height:100%;border-radius:4px;width:{{ p.pct }}%;background:{{ p.color }}"></div></div>
                    <span style="font-size:11px;color:{{ tema.gris }}">{{ p.gastadoFmt }} · {{ p.limiteFmt }}</span>
                  </div>
                  <span style="text-align:right;font-size:13px;font-weight:700;color:{{ p.color }}">{{ p.restanteFmt }}</span>
                  <span data-menu="1" style="position:relative;display:flex;justify-content:flex-end">
                    <sc-if value="{{ puedeEditar }}" hint-placeholder-val="{{ true }}">
                      <button onClick="{{ p.onMenu }}" style="width:32px;height:32px;border-radius:8px;border:none;background:{{ p.menuBg }};cursor:pointer;color:{{ tema.gris }};font-size:15px;line-height:1">⋯</button>
                    </sc-if>
                    <sc-if value="{{ p.menuOpen }}" hint-placeholder-val="{{ false }}">
                      <div style="position:absolute;top:36px;right:0;z-index:25;background:{{ tema.card }};border:1px solid {{ tema.borde }};border-radius:13px;box-shadow:0 14px 30px oklch(0.20 0.05 90 / 0.2);overflow:hidden;min-width:200px;display:flex;flex-direction:column;animation:aparece 0.15s ease both">
                        <sc-for list="{{ p.acciones }}" as="ac" hint-placeholder-count="3">
                          <button onClick="{{ ac.go }}" style="padding:11px 15px;border:none;border-bottom:1px solid {{ tema.suave }};background:transparent;text-align:left;cursor:pointer;font-size:13px;font-weight:600;color:{{ ac.color }}">{{ ac.label }}</button>
                        </sc-for>
                      </div>
                    </sc-if>
                  </span>
                </div>
              </sc-for>
            </div>

          </div>
        </div>
      </sc-if>

      <!-- METAS -->
      <sc-if value="{{ esMetas }}" hint-placeholder-val="{{ false }}">
        <div style="display:flex;flex-direction:column;gap:16px">
          <div style="display:flex;align-items:center">
            <h2 style="margin:0;display:flex;align-items:center;gap:10px;font-family:'Bricolage Grotesque',sans-serif;font-size:18px;font-weight:800;letter-spacing:-0.02em">{{ txt.metasTitulo }}
              <sc-if value="{{ puedeEditar }}" hint-placeholder-val="{{ true }}">
                <button onClick="{{ toggleAddMeta }}" title="{{ labelAddMeta }}" style="width:30px;height:30px;border-radius:50%;border:1px solid {{ tema.borde }};background:{{ tema.card }};cursor:pointer;color:{{ tema.gris }};font-size:17px;font-weight:700;line-height:1;display:flex;align-items:center;justify-content:center">+</button>
              </sc-if>
            </h2>
          </div>
          <sc-if value="{{ addMeta }}" hint-placeholder-val="{{ false }}">
            <div style="position:fixed;inset:0;background:oklch(0.22 0 0 / 0.45);display:flex;align-items:center;justify-content:center;z-index:65;padding:{{ movil.padModal }};animation:aparece 0.2s ease both">
              <div style="width:100%;max-width:470px;max-height:calc(100vh - 56px);overflow-y:auto;background:{{ tema.card }};border-radius:26px;padding:24px;display:flex;flex-direction:column;gap:14px;animation:entra 0.3s ease both">
                <div style="display:flex;justify-content:space-between;align-items:center">
                  <h2 style="margin:0;font-family:'Bricolage Grotesque',sans-serif;font-size:21px;font-weight:800;letter-spacing:-0.025em">{{ tituloAddMeta }}</h2>
                  <button onClick="{{ toggleAddMeta }}" style="width:34px;height:34px;border:none;border-radius:13px;background:{{ tema.suave }};cursor:pointer;font-size:17px;color:{{ tema.gris }}">×</button>
                </div>
                <label style="display:flex;flex-direction:column;gap:6px;font-size:12px;font-weight:600;color:{{ tema.gris }}">{{ catNombreLabel }}
                  <input value="{{ nuevaMeta.nombre }}" onChange="{{ onMeta.nombre }}" placeholder="Viaje familiar" style="padding:13px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" /></label>
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;min-width:0">
                  <label style="display:flex;flex-direction:column;gap:6px;font-size:12px;font-weight:600;color:{{ tema.gris }};min-width:0">{{ txt.meta }}
                    <input value="{{ nuevaMeta.meta }}" onChange="{{ onMeta.meta }}" type="number" style="min-width:0;padding:13px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" /></label>
                  <label style="display:flex;flex-direction:column;gap:6px;font-size:12px;font-weight:600;color:{{ tema.gris }};min-width:0">{{ txt.aporteMensual }}
                    <input value="{{ nuevaMeta.mensual }}" onChange="{{ onMeta.mensual }}" type="number" style="min-width:0;padding:13px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" /></label>
                </div>
                <button onClick="{{ agregarMeta }}" style="padding:15px;border-radius:13px;border:none;background:oklch(0.852 0.147 93);color:oklch(0.24 0.05 155);cursor:pointer;font-size:15px;font-weight:700">{{ catGuardar }}</button>
              </div>
            </div>
          </sc-if>
          <div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(330px,1fr));gap:14px;align-items:start">
            <sc-for list="{{ metas }}" as="g" hint-placeholder-count="2">
              <div style="background:{{ tema.card }};border:1px solid {{ tema.borde }};border-radius:18px;padding:20px;display:flex;flex-direction:column;gap:12px">
                <div style="display:flex;justify-content:space-between;align-items:flex-start;gap:10px">
                  <div style="display:flex;gap:12px;align-items:flex-start">
                    <span style="width:8px;height:36px;border-radius:4px;background:{{ g.color }}"></span>
                    <div>
                      <div style="font-family:'Bricolage Grotesque',sans-serif;font-size:16px;font-weight:800;letter-spacing:-0.02em">{{ g.nombre }}</div>
                      <div style="font-size:12px;color:{{ tema.gris }}">{{ txt.meta }} {{ g.metaFmt }} · {{ g.proyeccion }}</div>
                    </div>
                  </div>
                  <sc-if value="{{ puedeEditar }}" hint-placeholder-val="{{ true }}">
                    <span data-menu="1" style="position:relative;flex:0 0 auto">
                      <button onClick="{{ g.onMenu }}" style="width:32px;height:32px;border-radius:8px;border:none;background:{{ g.menuBg }};cursor:pointer;color:{{ tema.gris }};font-size:15px;line-height:1">⋯</button>
                      <sc-if value="{{ g.menuOpen }}" hint-placeholder-val="{{ false }}">
                        <div style="position:absolute;top:36px;right:0;z-index:25;background:{{ tema.card }};border:1px solid {{ tema.borde }};border-radius:13px;box-shadow:0 14px 30px oklch(0.20 0.05 90 / 0.2);overflow:hidden;min-width:212px;display:flex;flex-direction:column;animation:aparece 0.15s ease both">
                          <sc-for list="{{ g.acciones }}" as="ac" hint-placeholder-count="5">
                            <button onClick="{{ ac.go }}" style="padding:11px 15px;border:none;border-bottom:1px solid {{ tema.suave }};background:transparent;text-align:left;cursor:pointer;font-size:13px;font-weight:600;color:{{ ac.color }}">{{ ac.label }}</button>
                          </sc-for>
                        </div>
                      </sc-if>
                    </span>
                  </sc-if>
                </div>
                <div style="height:11px;border-radius:8px;background:{{ tema.suave }};overflow:hidden"><div style="height:100%;border-radius:8px;width:{{ g.pct }}%;background:{{ g.color }}"></div></div>
                <div style="display:flex;justify-content:space-between;font-size:12px;color:{{ tema.gris }}">
                  <span>{{ txt.ahorrado }} {{ g.ahorradoFmt }} ({{ g.pctLabel }})</span><span>{{ txt.falta }} {{ g.restanteFmt }}</span>
                </div>
                <sc-if value="{{ puedeRegistrar }}" hint-placeholder-val="{{ true }}">
                  <button onClick="{{ g.onAportar }}" style="padding:11px;border-radius:13px;border:none;background:oklch(0.56 0.14 300);color:#fff;cursor:pointer;font-size:13px;font-weight:700">{{ txt.aportar }} {{ g.mensualFmt }}</button>
                </sc-if>
                <sc-if value="{{ g.editando }}" hint-placeholder-val="{{ false }}">
                  <div style="display:flex;flex-direction:column;gap:10px;padding-top:12px;border-top:1px solid {{ tema.suave }};animation:entra 0.25s ease both">
                    <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(110px,1fr));gap:10px;min-width:0">
                      <label style="display:flex;flex-direction:column;gap:5px;font-size:11px;font-weight:600;color:{{ tema.gris }};min-width:0">Nombre
                        <input value="{{ g.nombre }}" onChange="{{ g.setNombre }}" style="min-width:0;padding:10px;border-radius:8px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" /></label>
                      <label style="display:flex;flex-direction:column;gap:5px;font-size:11px;font-weight:600;color:{{ tema.gris }};min-width:0">{{ txt.meta }}
                        <input value="{{ g.meta }}" onChange="{{ g.setMeta }}" type="number" style="min-width:0;padding:10px;border-radius:8px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" /></label>
                      <label style="display:flex;flex-direction:column;gap:5px;font-size:11px;font-weight:600;color:{{ tema.gris }};min-width:0">{{ txt.ahorrado }}
                        <input value="{{ g.ahorrado }}" onChange="{{ g.setAhorrado }}" type="number" style="min-width:0;padding:10px;border-radius:8px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" /></label>
                      <label style="display:flex;flex-direction:column;gap:5px;font-size:11px;font-weight:600;color:{{ tema.gris }};min-width:0">{{ txt.aporteMensual }}
                        <input value="{{ g.mensual }}" onChange="{{ g.setMensual }}" type="number" style="min-width:0;padding:10px;border-radius:8px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" /></label>
                    </div>
                    <div style="display:flex;align-items:center;gap:8px;flex-wrap:wrap">
                      <sc-for list="{{ g.swatches }}" as="sw" hint-placeholder-count="7">
                        <button aria-label="{{ a11y.color }}" onClick="{{ sw.go }}" style="width:24px;height:24px;border-radius:8px;cursor:pointer;background:{{ sw.color }};border:2px solid {{ sw.borde }}"></button>
                      </sc-for>
                      <button onClick="{{ g.onCerrar }}" style="margin-left:auto;padding:9px 15px;border-radius:8px;border:none;background:{{ tema.side }};color:oklch(0.96 0.03 95);cursor:pointer;font-size:12px;font-weight:700">Listo</button>
                    </div>
                  </div>
                </sc-if>
              </div>
            </sc-for>
          </div>
        </div>
      </sc-if>

      <!-- LIBRETAS: LISTA -->
      <sc-if value="{{ esLibretasLista }}" hint-placeholder-val="{{ false }}">
        <div style="display:flex;flex-direction:column;gap:16px">
          <div style="display:flex;justify-content:space-between;align-items:center;gap:12px;flex-wrap:wrap">
            <p style="margin:0;font-size:13px;line-height:1.6;color:{{ tema.gris }};max-width:640px">{{ txt.libretasSub }}</p>
            <button onClick="{{ toggleAddLibreta }}" title="{{ labelAddLibreta }}" style="width:38px;height:38px;border-radius:50%;border:none;background:oklch(0.852 0.147 93);color:oklch(0.24 0.05 155);cursor:pointer;font-size:20px;font-weight:700;line-height:1;flex:0 0 auto">+</button>
          </div>

          <div style="background:{{ tema.card }};border:1px solid {{ tema.borde }};border-radius:18px;overflow:hidden">
            <sc-for list="{{ libretasDetalle }}" as="l" hint-placeholder-count="3">
              <button onClick="{{ l.onEntrar }}" style="width:100%;display:flex;align-items:center;gap:14px;padding:16px 18px;border:none;border-bottom:1px solid {{ tema.suave }};background:{{ l.filaBg }};cursor:pointer;text-align:left;color:inherit">
                <span style="width:44px;height:44px;border-radius:13px;background:{{ l.color }};display:flex;align-items:center;justify-content:center;color:#fff;font-size:13px;font-weight:800;flex:0 0 auto">{{ l.inicial }}</span>
                <span style="flex:1;min-width:0">
                  <span style="display:flex;align-items:center;gap:9px;flex-wrap:wrap">
                    <span style="font-family:'Bricolage Grotesque',sans-serif;font-size:17px;font-weight:800;letter-spacing:-0.02em">{{ l.nombre }}</span>
                    <sc-if value="{{ l.esActiva }}" hint-placeholder-val="{{ false }}">
                      <span style="font-size:10px;font-weight:800;letter-spacing:0.06em;text-transform:uppercase;padding:4px 9px;border-radius:18px;background:oklch(0.95 0.05 152);color:oklch(0.42 0.12 152)">{{ txt.enUso }}</span>
                    </sc-if>
                  </span>
                  <span style="display:block;font-size:12px;color:{{ tema.gris }};margin-top:3px">{{ l.tipo }} · {{ l.stats }}</span>
                </span>
                <span style="display:flex;align-items:center;gap:10px;flex:0 0 auto">
                  <span style="display:flex;align-items:center">
                    <sc-for list="{{ l.avatares }}" as="av" hint-placeholder-count="2">
                      <span style="width:28px;height:28px;border-radius:50%;background:{{ av.bg }};color:#fff;display:flex;align-items:center;justify-content:center;font-size:10px;font-weight:800;border:2px solid {{ tema.card }};margin-left:-8px">{{ av.inicial }}</span>
                    </sc-for>
                  </span>
                  <span style="font-size:11px;padding:6px 11px;border-radius:18px;font-weight:700;background:{{ l.rolBg }};color:{{ l.rolFg }}">{{ l.rol }}</span>
                  <span style="font-size:17px;color:{{ tema.gris }}">›</span>
                </span>
              </button>
            </sc-for>
          </div>

          <div style="background:{{ tema.card }};border:1px solid {{ tema.borde }};border-radius:18px;padding:20px">
            <h2 style="margin:0 0 14px;font-family:'Bricolage Grotesque',sans-serif;font-size:17px;font-weight:800;letter-spacing:-0.02em">{{ txtRoles }}</h2>
            <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(190px,1fr));gap:12px">
              <sc-for list="{{ tablaRoles }}" as="r" hint-placeholder-count="4">
                <div style="padding:15px;border-radius:16px;background:{{ tema.suave }}">
                  <div style="font-size:13px;font-weight:800">{{ r.rol }}</div>
                  <div style="font-size:12px;line-height:1.55;color:{{ tema.gris }};margin-top:6px">{{ r.detalle }}</div>
                </div>
              </sc-for>
            </div>
          </div>
        </div>
      </sc-if>

      <!-- LIBRETAS: DETALLE -->
      <sc-if value="{{ esLibretaDetalle }}" hint-placeholder-val="{{ false }}">
        <div style="display:flex;flex-direction:column;gap:16px">
          <button onClick="{{ volverLibretas }}" style="align-self:flex-start;display:flex;align-items:center;gap:8px;padding:9px 15px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};cursor:pointer;font-size:13px;font-weight:700;color:inherit">‹ {{ txt.libretas }}</button>

          <div style="background:{{ tema.card }};border:1px solid {{ tema.borde }};border-radius:18px;padding:22px;display:flex;align-items:center;gap:16px;flex-wrap:wrap">
            <span style="width:56px;height:56px;border-radius:18px;background:{{ detalle.color }};display:flex;align-items:center;justify-content:center;color:#fff;font-size:16px;font-weight:800;flex:0 0 auto">{{ detalle.inicial }}</span>
            <div style="flex:1;min-width:180px">
              <div style="font-family:'Bricolage Grotesque',sans-serif;font-size:23px;font-weight:800;letter-spacing:-0.025em">{{ detalle.nombre }}</div>
              <div style="font-size:12px;color:{{ tema.gris }};margin-top:3px">{{ detalle.tipo }} · {{ detalle.stats }}</div>
            </div>
            <span style="font-size:11px;padding:7px 12px;border-radius:18px;font-weight:700;background:{{ detalle.rolBg }};color:{{ detalle.rolFg }}">{{ txt.rolTu }}: {{ detalle.rol }}</span>
            <sc-if value="{{ detalle.puedeAbrir }}" hint-placeholder-val="{{ true }}">
              <button onClick="{{ detalle.onAbrir }}" style="padding:12px 18px;border-radius:13px;border:none;background:oklch(0.852 0.147 93);color:oklch(0.24 0.05 155);cursor:pointer;font-size:13px;font-weight:700">{{ txt.abrir }}</button>
            </sc-if>
            <sc-if value="{{ detalle.esDueno }}" hint-placeholder-val="{{ false }}">
              <button onClick="{{ detalle.onEliminar }}" style="padding:12px 16px;border-radius:13px;border:1px solid oklch(0.90 0.05 30);background:transparent;cursor:pointer;font-size:13px;font-weight:600;color:oklch(0.62 0.16 30)">{{ txt.eliminar }}</button>
            </sc-if>
            <sc-if value="{{ detalle.compartida }}" hint-placeholder-val="{{ false }}">
              <button onClick="{{ detalle.onSalir }}" style="padding:12px 16px;border-radius:13px;border:1px solid oklch(0.90 0.05 30);background:transparent;cursor:pointer;font-size:13px;font-weight:600;color:oklch(0.62 0.16 30)">{{ txtSalirLibreta }}</button>
            </sc-if>
            <sc-if value="{{ detalle.pendiente }}" hint-placeholder-val="{{ false }}">
              <div style="display:flex;flex-direction:column;gap:12px;padding:16px;border-radius:16px;background:{{ tema.card }};border:1px solid {{ tema.borde }}">
                <span style="font-size:13px;line-height:1.5;color:{{ tema.gris }}">{{ txtInvitacionPie }}</span>
                <div style="display:flex;gap:10px">
                  <button onClick="{{ detalle.onAceptar }}" style="padding:12px 18px;border-radius:13px;border:none;background:oklch(0.852 0.147 93);color:oklch(0.24 0.05 155);cursor:pointer;font-size:13px;font-weight:700">{{ txtAceptarInv }}</button>
                  <button onClick="{{ detalle.onRechazar }}" style="padding:12px 18px;border-radius:13px;border:1px solid {{ tema.borde }};background:transparent;color:{{ tema.gris }};cursor:pointer;font-size:13px;font-weight:600">{{ txtRechazarInv }}</button>
                </div>
              </div>
            </sc-if>
          </div>

          <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:14px">
            <sc-for list="{{ detalle.kpis }}" as="k" hint-placeholder-count="4">
              <div style="background:{{ tema.card }};border:1px solid {{ tema.borde }};border-radius:18px;padding:18px">
                <div style="font-size:11px;text-transform:uppercase;letter-spacing:0.08em;color:{{ tema.gris }};font-weight:700">{{ k.label }}</div>
                <div style="font-family:'Bricolage Grotesque',sans-serif;font-size:24px;font-weight:800;margin-top:8px;letter-spacing:-0.03em;color:{{ k.color }}">{{ k.valor }}</div>
              </div>
            </sc-for>
          </div>

          <div style="background:{{ tema.card }};border:1px solid {{ tema.borde }};border-radius:18px;padding:20px">
            <div style="display:flex;align-items:center;justify-content:space-between;gap:12px;margin-bottom:14px">
              <h2 style="margin:0;display:flex;align-items:center;gap:10px;font-family:'Bricolage Grotesque',sans-serif;font-size:17px;font-weight:800;letter-spacing:-0.02em">{{ txt.miembros }}
                <span style="font-size:12px;font-weight:600;color:{{ tema.gris }}">{{ detalle.conteoMiembros }}</span>
              </h2>
              <sc-if value="{{ detalle.esDueno }}" hint-placeholder-val="{{ false }}">
                <button onClick="{{ abrirInvitar }}" title="{{ txt.invitar }}" style="width:32px;height:32px;border-radius:50%;border:1px solid {{ tema.borde }};background:{{ tema.card }};cursor:pointer;color:{{ tema.gris }};font-size:18px;font-weight:700;line-height:1;display:flex;align-items:center;justify-content:center">+</button>
              </sc-if>
            </div>
            <div style="display:flex;flex-direction:column;gap:9px">
              <sc-for list="{{ detalle.miembros }}" as="m" hint-placeholder-count="2">
                <div style="display:flex;align-items:center;gap:12px;padding:12px 14px;border-radius:16px;background:{{ tema.suave }};flex-wrap:wrap">
                  <span style="width:34px;height:34px;border-radius:50%;background:{{ m.avatarBg }};color:#fff;display:flex;align-items:center;justify-content:center;font-size:12px;font-weight:800;flex:0 0 auto">{{ m.inicial }}</span>
                  <div style="flex:1;min-width:150px">
                    <div style="font-size:13px;font-weight:700">{{ m.nombre }}{{ m.yoSuf }}</div>
                    <div style="font-size:11px;color:{{ tema.gris }}">{{ m.email }}</div>
                  </div>
                  <sc-if value="{{ m.editable }}" hint-placeholder-val="{{ false }}">
                    <select aria-label="{{ a11y.rol }}" value="{{ m.rol }}" onChange="{{ m.onRol }}" style="padding:9px 11px;border-radius:8px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit;font-size:12px">
                      <sc-for list="{{ roles }}" as="r" hint-placeholder-count="4"><option value="{{ r.id }}">{{ r.label }}</option></sc-for>
                    </select>
                  </sc-if>
                  <sc-if value="{{ m.fijo }}" hint-placeholder-val="{{ true }}">
                    <span style="font-size:12px;font-weight:700;color:{{ tema.gris }}">{{ m.rolLabel }}</span>
                  </sc-if>
                  <sc-if value="{{ m.editable }}" hint-placeholder-val="{{ false }}">
                    <button onClick="{{ m.onQuitar }}" style="width:30px;height:30px;border:none;background:transparent;cursor:pointer;color:oklch(0.62 0.16 30);font-size:16px">×</button>
                  </sc-if>
                </div>
              </sc-for>
            </div>
          </div>
        </div>
      </sc-if>


      <!-- AJUSTES -->
      <!-- Ajustes rehecho: el prototipo tenía una sola columna con idioma, tema,
     personaje y una lista de accesos. Ahora va por pestañas y con todo lo que
     necesita una cuenta real: perfil, contraseña, sesiones y datos.
     Este bloque sustituye al del diseño (\`npm run sync\` lo reemplaza entero). -->
<sc-if value="{{ esAjustes }}" hint-placeholder-val="{{ false }}">
      <div style="display:flex;flex-direction:column;gap:18px">

        <div style="display:flex;gap:6px;flex-wrap:wrap;padding:5px;border-radius:16px;background:{{ tema.card }};border:1px solid {{ tema.borde }};align-self:flex-start">
          <sc-for list="{{ pestanas }}" as="p" hint-placeholder-count="5">
            <button onClick="{{ p.go }}" style="display:flex;align-items:center;gap:8px;padding:11px 16px;border-radius:13px;border:none;cursor:pointer;font-size:13px;font-weight:700;background:{{ p.bg }};color:{{ p.fg }}">
              <svg viewBox="0 0 24 24" style="width:16px;height:16px" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="{{ p.icono }}"></path></svg>{{ p.label }}
            </button>
          </sc-for>
        </div>

        <sc-if value="{{ hayMensaje }}" hint-placeholder-val="{{ false }}">
          <div style="padding:13px 17px;border-radius:13px;background:{{ mensajeBg }};color:{{ mensajeFg }};font-size:13px;font-weight:600;line-height:1.5;animation:aparece 0.2s ease both">{{ mensaje }}</div>
        </sc-if>

        <!-- PERFIL -->
        <sc-if value="{{ tabPerfil }}" hint-placeholder-val="{{ true }}">
          <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(340px,1fr));gap:16px;align-items:start">
            <div style="background:{{ tema.card }};border:1px solid {{ tema.borde }};border-radius:18px;padding:22px;display:flex;flex-direction:column;gap:14px">
              <div style="display:flex;align-items:center;gap:14px">
                <span style="width:54px;height:54px;border-radius:50%;background:oklch(0.852 0.147 93);color:oklch(0.24 0.05 155);display:flex;align-items:center;justify-content:center;font-size:18px;font-weight:800;flex:0 0 auto">{{ inicialUsuario }}</span>
                <div style="flex:1;min-width:0">
                  <div style="font-family:'Bricolage Grotesque',sans-serif;font-size:20px;font-weight:800;letter-spacing:-0.02em">{{ nombreUsuario }}</div>
                  <div style="font-size:13px;color:{{ tema.gris }}">{{ correoUsuario }} · {{ estadoCuenta }}</div>
                </div>
              </div>
              <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:12px">
                <label style="display:flex;flex-direction:column;gap:6px;font-size:12px;font-weight:600;color:{{ tema.gris }};min-width:0">Nombre completo
                  <input value="{{ perfil.nombre }}" onChange="{{ onPerfil.nombre }}" style="min-width:0;padding:12px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" /></label>
                <label style="display:flex;flex-direction:column;gap:6px;font-size:12px;font-weight:600;color:{{ tema.gris }};min-width:0">Usuario
                  <input value="{{ perfil.usuario }}" onChange="{{ onPerfil.usuario }}" placeholder="opcional" style="min-width:0;padding:12px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" /></label>
                <label style="display:flex;flex-direction:column;gap:6px;font-size:12px;font-weight:600;color:{{ tema.gris }};min-width:0">Teléfono
                  <input value="{{ perfil.telefono }}" onChange="{{ onPerfil.telefono }}" type="tel" placeholder="809 000 0000" style="min-width:0;padding:12px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" /></label>
              </div>
              <button onClick="{{ guardarPerfil }}" style="align-self:flex-start;padding:13px 22px;border-radius:13px;border:none;background:oklch(0.852 0.147 93);color:oklch(0.24 0.05 155);cursor:pointer;font-size:14px;font-weight:700">{{ botonPerfil }}</button>
            </div>

            <div style="background:{{ tema.card }};border:1px solid {{ tema.borde }};border-radius:18px;padding:22px;display:flex;flex-direction:column;gap:14px">
              <div>
                <h2 style="margin:0 0 4px;font-family:'Bricolage Grotesque',sans-serif;font-size:17px;font-weight:800;letter-spacing:-0.02em">Correo de la cuenta</h2>
                <p style="margin:0;font-size:13px;line-height:1.55;color:{{ tema.gris }}">Es con lo que entras y con lo que te invitan a libretas compartidas. Cambiarlo pide tu contraseña.</p>
              </div>
              <label style="display:flex;flex-direction:column;gap:6px;font-size:12px;font-weight:600;color:{{ tema.gris }}">Nuevo correo
                <input value="{{ correoForm.email }}" onChange="{{ onCorreo.email }}" type="email" style="padding:12px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" /></label>
              <label style="display:flex;flex-direction:column;gap:6px;font-size:12px;font-weight:600;color:{{ tema.gris }}">Tu contraseña
                <input value="{{ correoForm.clave }}" onChange="{{ onCorreo.clave }}" type="password" style="padding:12px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" /></label>
              <button onClick="{{ cambiarCorreo }}" style="align-self:flex-start;padding:13px 20px;border-radius:13px;border:1px solid {{ tema.borde }};background:transparent;color:inherit;cursor:pointer;font-size:13px;font-weight:700">{{ botonCorreo }}</button>
            </div>
          </div>
        </sc-if>

        <!-- APARIENCIA -->
        <sc-if value="{{ tabApariencia }}" hint-placeholder-val="{{ false }}">
          <div style="display:flex;flex-direction:column;gap:16px">
            <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(300px,1fr));gap:16px;align-items:start">
              <div style="background:{{ tema.card }};border:1px solid {{ tema.borde }};border-radius:18px;padding:20px">
                <h2 style="margin:0 0 14px;font-family:'Bricolage Grotesque',sans-serif;font-size:17px;font-weight:800;letter-spacing:-0.02em">{{ txt.idioma }}</h2>
                <div style="display:flex;gap:10px;flex-wrap:wrap">
                  <sc-for list="{{ idiomas }}" as="i" hint-placeholder-count="3">
                    <button onClick="{{ i.go }}" style="padding:12px 18px;border-radius:13px;border:1px solid {{ i.border }};background:{{ i.bg }};color:{{ i.fg }};cursor:pointer;font-size:13px;font-weight:700">{{ i.label }}</button>
                  </sc-for>
                </div>
              </div>
              <div style="background:{{ tema.card }};border:1px solid {{ tema.borde }};border-radius:18px;padding:20px">
                <h2 style="margin:0 0 4px;font-family:'Bricolage Grotesque',sans-serif;font-size:17px;font-weight:800;letter-spacing:-0.02em">Moneda</h2>
                <p style="margin:0 0 14px;font-size:13px;color:{{ tema.gris }}">Con la que se muestran todos los montos.</p>
                <div style="display:flex;gap:12px;align-items:center;flex-wrap:wrap">
                  <select aria-label="{{ a11y.moneda }}" value="{{ monedaActual }}" onChange="{{ onMoneda }}" style="flex:1;min-width:150px;padding:12px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit">
                    <sc-for list="{{ monedas }}" as="m" hint-placeholder-count="4"><option value="{{ m.id }}">{{ m.label }}</option></sc-for>
                  </select>
                  <span style="display:flex;align-items:center;gap:9px;font-size:13px;color:{{ tema.gris }}">Centavos
                    <button aria-label="{{ a11y.centavos }}" onClick="{{ toggleCentavos }}" style="width:52px;height:28px;border-radius:18px;border:none;cursor:pointer;background:{{ centavosBg }};position:relative;padding:0">
                      <span style="position:absolute;top:3px;left:{{ centavosKnob }}px;width:22px;height:22px;border-radius:50%;background:#fff"></span>
                    </button>
                  </span>
                </div>
              </div>
            </div>

            <div style="background:{{ tema.card }};border:1px solid {{ tema.borde }};border-radius:18px;padding:20px">
              <h2 style="margin:0 0 4px;font-family:'Bricolage Grotesque',sans-serif;font-size:17px;font-weight:800;letter-spacing:-0.02em">{{ txt.tema }}</h2>
              <p style="margin:0 0 16px;font-size:13px;color:{{ tema.gris }}">{{ txt.temaDesc }}</p>
              <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(190px,1fr));gap:12px">
                <sc-for list="{{ temas }}" as="t" hint-placeholder-count="12">
                  <button onClick="{{ t.go }}" style="padding:0;border-radius:16px;border:2px solid {{ t.borde }};background:transparent;cursor:pointer;overflow:hidden;text-align:left">
                    <span style="display:block;height:74px;background:{{ t.bg }};background-image:{{ t.patron }};position:relative">
                      <span style="position:absolute;left:10px;bottom:10px;width:38px;height:12px;border-radius:4px;background:{{ t.side }}"></span>
                      <span style="position:absolute;left:54px;bottom:10px;width:20px;height:12px;border-radius:4px;background:oklch(0.852 0.147 93)"></span>
                    </span>
                    <span style="display:block;padding:11px 13px;background:{{ tema.card }};font-size:12px;font-weight:700;color:{{ tema.tinta }}">{{ t.nombre }}</span>
                  </button>
                </sc-for>
              </div>
            </div>

            <div style="background:{{ tema.card }};border:1px solid {{ tema.borde }};border-radius:18px;padding:20px">
              <h2 style="margin:0 0 4px;font-family:'Bricolage Grotesque',sans-serif;font-size:17px;font-weight:800;letter-spacing:-0.02em">{{ tituloPaleta }}</h2>
              <p style="margin:0 0 16px;font-size:13px;color:{{ tema.gris }}">{{ coloresDesc }}</p>
              <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(230px,1fr));gap:12px">
                <sc-for list="{{ paletas }}" as="pa" hint-placeholder-count="6">
                  <button onClick="{{ pa.go }}" style="padding:12px 14px;border-radius:13px;border:2px solid {{ pa.aro }};background:{{ pa.bg }};cursor:pointer;color:inherit;display:flex;align-items:center;gap:12px;text-align:left">
                    <span style="display:flex;gap:4px;flex:none">
                      <span style="width:12px;height:28px;border-radius:4px;background:{{ pa.positivo }};display:block"></span>
                      <span style="width:12px;height:28px;border-radius:4px;background:{{ pa.negativo }};display:block"></span>
                      <span style="width:12px;height:28px;border-radius:4px;background:{{ pa.ahorro }};display:block"></span>
                      <span style="width:12px;height:28px;border-radius:4px;background:{{ pa.aviso }};display:block"></span>
                    </span>
                    <span style="flex:1;min-width:0">
                      <span style="display:block;font-size:14px;font-weight:700;color:{{ tema.tinta }};white-space:nowrap;overflow:hidden;text-overflow:ellipsis">{{ pa.nombre }}</span>
                      <span style="display:block;font-size:12px;color:{{ tema.gris }};margin-top:1px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis">{{ pa.pista }}</span>
                    </span>
                  </button>
                </sc-for>
              </div>
            </div>

            <div style="background:{{ tema.card }};border:1px solid {{ tema.borde }};border-radius:18px;padding:20px">
              <h2 style="margin:0 0 4px;font-family:'Bricolage Grotesque',sans-serif;font-size:17px;font-weight:800;letter-spacing:-0.02em">{{ txt.personaje }}</h2>
              <p style="margin:0 0 16px;font-size:13px;color:{{ tema.gris }}">{{ txt.personajeDesc }}</p>
              <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(160px,1fr));gap:12px">
                <sc-for list="{{ personajes }}" as="p" hint-placeholder-count="6">
                  <button onClick="{{ p.go }}" style="padding:14px 10px;border-radius:16px;border:2px solid {{ p.borde }};background:{{ tema.suave }};cursor:pointer;display:flex;flex-direction:column;align-items:center;gap:9px">
                    <span style="position:relative;width:56px;height:56px;display:block">
                      <img src="{{ p.chinolo }}" alt="" width="56" height="56" style="width:56px;height:56px;flex:none;pointer-events:none" />
                    </span>
                    <span style="font-size:11px;font-weight:700;color:{{ tema.tinta }};text-align:center">{{ p.nombre }}</span>
                  </button>
                </sc-for>
              </div>
            </div>
          </div>
        </sc-if>

        <!-- LIBRETAS -->
        <sc-if value="{{ tabLibretas }}" hint-placeholder-val="{{ false }}">
          <div style="display:flex;flex-direction:column;gap:16px">
            <div style="background:{{ tema.card }};border:1px solid {{ tema.borde }};border-radius:18px;overflow:hidden">
              <sc-for list="{{ libretasAjustes }}" as="l" hint-placeholder-count="3">
                <button onClick="{{ l.go }}" style="width:100%;display:flex;align-items:center;gap:14px;padding:16px 18px;border:none;border-bottom:1px solid {{ tema.suave }};background:{{ l.bg }};cursor:pointer;text-align:left;color:inherit">
                  <span style="width:40px;height:40px;border-radius:13px;background:{{ l.color }};display:flex;align-items:center;justify-content:center;color:#fff;font-size:12px;font-weight:800;flex:0 0 auto">{{ l.inicial }}</span>
                  <span style="flex:1;min-width:0">
                    <span style="display:block;font-size:14px;font-weight:700">{{ l.nombre }}</span>
                    <span style="display:block;font-size:12px;color:{{ tema.gris }};margin-top:2px">{{ l.detalle }}</span>
                  </span>
                  <span style="font-size:11px;padding:6px 11px;border-radius:18px;font-weight:700;background:{{ l.rolBg }};color:{{ l.rolFg }}">{{ l.rol }}</span>
                  <span style="font-size:17px;color:{{ tema.gris }}">›</span>
                </button>
              </sc-for>
            </div>
            <button onClick="{{ irLibretas }}" style="align-self:flex-start;padding:13px 20px;border-radius:13px;border:none;background:oklch(0.852 0.147 93);color:oklch(0.24 0.05 155);cursor:pointer;font-size:14px;font-weight:700">Administrar libretas y permisos →</button>
          </div>
        </sc-if>

        <!-- INTEGRACIONES -->
        <sc-if value="{{ tabIntegraciones }}" hint-placeholder-val="{{ false }}">
          <div style="display:flex;flex-direction:column;gap:16px">
            <div style="background:{{ tema.card }};border:1px solid {{ tema.borde }};border-radius:18px;padding:22px;display:flex;flex-direction:column;gap:12px">
              <div>
                <h2 style="margin:0 0 4px;font-family:'Bricolage Grotesque',sans-serif;font-size:17px;font-weight:800;letter-spacing:-0.02em">Claves de API</h2>
                <p style="margin:0;font-size:13px;line-height:1.55;color:{{ tema.gris }}">Para que otro programa registre movimientos en tus libretas: un flujo de WhatsApp o Instagram, una hoja de cálculo, lo que sea. La clave se ve una sola vez.</p>
              </div>
              <sc-if value="{{ claveNueva }}" hint-placeholder-val="{{ false }}">
                <div style="padding:14px;border-radius:13px;background:oklch(0.95 0.05 152);color:oklch(0.30 0.09 152);display:flex;flex-direction:column;gap:8px">
                  <span style="font-size:12px;font-weight:700">Cópiala ahora: no se vuelve a mostrar.</span>
                  <span style="font-family:ui-monospace,SFMono-Regular,Menlo,monospace;font-size:13px;overflow-wrap:anywhere">{{ claveNueva }}</span>
                  <button onClick="{{ copiarClave }}" style="align-self:flex-start;padding:9px 14px;border-radius:8px;border:none;background:oklch(0.30 0.09 152);color:#fff;cursor:pointer;font-size:12px;font-weight:700">Copiar</button>
                </div>
              </sc-if>
              <sc-if value="{{ puedeApi }}" hint-placeholder-val="{{ true }}">
                <div style="display:flex;gap:10px;flex-wrap:wrap;align-items:flex-end">
                  <label style="flex:1;min-width:200px;display:flex;flex-direction:column;gap:6px;font-size:12px;font-weight:600;color:{{ tema.gris }}">Nombre de la clave
                    <input value="{{ nombreClave }}" onChange="{{ onNombreClave }}" placeholder="Flujo de WhatsApp o Instagram" style="padding:12px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" /></label>
                  <button onClick="{{ crearClave }}" style="padding:13px 20px;border-radius:13px;border:none;background:oklch(0.852 0.147 93);color:oklch(0.24 0.05 155);cursor:pointer;font-size:14px;font-weight:700">Crear clave</button>
                </div>
              </sc-if>
              <sc-if value="{{ sinApi }}" hint-placeholder-val="{{ false }}">
                <div style="padding:13px 16px;border-radius:13px;background:{{ tema.suave }};font-size:13px;line-height:1.55;color:{{ tema.gris }}">
                  Las integraciones vienen con el plan Pro. <a href="/planes" target="_blank" rel="noopener">Ver los planes →</a>
                </div>
              </sc-if>
            </div>

            <sc-if value="{{ hayClaves }}" hint-placeholder-val="{{ false }}">
              <div style="background:{{ tema.card }};border:1px solid {{ tema.borde }};border-radius:18px;overflow:hidden">
                <sc-for list="{{ claves }}" as="c" hint-placeholder-count="2">
                  <div style="display:flex;align-items:center;gap:14px;padding:15px 18px;border-bottom:1px solid {{ tema.suave }};flex-wrap:wrap">
                    <span style="flex:1;min-width:170px">
                      <span style="display:block;font-size:14px;font-weight:700">{{ c.nombre }}</span>
                      <span style="display:block;font-size:12px;color:{{ tema.gris }};font-family:ui-monospace,SFMono-Regular,Menlo,monospace">{{ c.prefijo }}…</span>
                    </span>
                    <span style="font-size:12px;color:{{ tema.gris }}">{{ c.uso }}</span>
                    <button onClick="{{ c.revocar }}" style="padding:9px 14px;border-radius:8px;border:1px solid oklch(0.90 0.05 30);background:transparent;color:oklch(0.62 0.16 30);cursor:pointer;font-size:12px;font-weight:700">Revocar</button>
                  </div>
                </sc-for>
              </div>
            </sc-if>

            <div style="background:{{ tema.card }};border:1px solid {{ tema.borde }};border-radius:18px;padding:22px">
              <h2 style="margin:0 0 4px;font-family:'Bricolage Grotesque',sans-serif;font-size:17px;font-weight:800;letter-spacing:-0.02em">Cómo se usa</h2>
              <p style="margin:0 0 12px;font-size:13px;line-height:1.55;color:{{ tema.gris }}">Un POST con la clave en la cabecera registra un movimiento. La guía completa, con el flujo de mensajería listo para pegar en n8n, está en <a href="/desarrolladores" target="_blank" rel="noopener">la página para desarrolladores</a>.</p>
              <pre style="margin:0;padding:14px;border-radius:13px;background:{{ tema.suave }};font-size:12px;line-height:1.6;overflow-x:auto;color:{{ tema.tinta }}">{{ ejemploApi }}</pre>
            </div>
          </div>
        </sc-if>

        <!-- SEGURIDAD -->
        <sc-if value="{{ tabSeguridad }}" hint-placeholder-val="{{ false }}">
          <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(340px,1fr));gap:16px;align-items:start">
            <!-- Acceso: contraseña, verificación en dos pasos y salir -->
            <div style="display:flex;flex-direction:column;gap:16px">
              <div style="background:{{ tema.card }};border:1px solid {{ tema.borde }};border-radius:18px;padding:22px;display:flex;flex-direction:column;gap:14px">
              <div>
                <h2 style="margin:0 0 4px;font-family:'Bricolage Grotesque',sans-serif;font-size:17px;font-weight:800;letter-spacing:-0.02em">Cambiar contraseña</h2>
                <p style="margin:0;font-size:13px;line-height:1.55;color:{{ tema.gris }}">Al cambiarla se cierran las sesiones abiertas en otros dispositivos.</p>
              </div>
              <input aria-label="Contraseña actual" value="{{ claveForm.actual }}" onChange="{{ onClaveForm.actual }}" type="password" placeholder="Contraseña actual" style="padding:12px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" />
              <input aria-label="Nueva contraseña" value="{{ claveForm.nueva }}" onChange="{{ onClaveForm.nueva }}" type="password" placeholder="Nueva contraseña" style="padding:12px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" />
              <input aria-label="Repite la nueva" value="{{ claveForm.repetir }}" onChange="{{ onClaveForm.repetir }}" type="password" placeholder="Repite la nueva" style="padding:12px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" />
              <button onClick="{{ cambiarClave }}" style="align-self:flex-start;padding:13px 22px;border-radius:13px;border:none;background:oklch(0.852 0.147 93);color:oklch(0.24 0.05 155);cursor:pointer;font-size:14px;font-weight:700">{{ botonClave }}</button>
            </div>
              <div style="background:{{ tema.card }};border:1px solid {{ tema.borde }};border-radius:18px;padding:22px;display:flex;flex-direction:column;gap:12px">
              <div>
                <h2 style="margin:0;font-family:'Bricolage Grotesque',sans-serif;font-size:17px;font-weight:800;letter-spacing:-0.02em">Verificación en dos pasos</h2>
                <p style="margin:4px 0 0;font-size:13px;line-height:1.55;color:{{ tema.gris }}">Estado: <span style="color:{{ mfaColor }};font-weight:700">{{ mfaEstado }}</span>. {{ mfaTexto }} Puedes tener varios métodos a la vez y elegir con cuál entrar; todos son gratis.</p>
              </div>
              <div style="display:flex;flex-direction:column;border-top:1px solid {{ tema.suave }}">
                <sc-for list="{{ dpFilas }}" as="f" hint-placeholder-count="4">
                  <div style="display:flex;align-items:center;gap:12px;padding:12px 0;border-bottom:1px solid {{ tema.suave }}">
                    <span style="flex:1;min-width:0">
                      <span style="display:block;font-size:14px;font-weight:700">{{ f.label }} <span style="font-size:12px;font-weight:700;color:{{ f.color }};margin-left:6px">{{ f.valor }}</span></span>
                      <span style="display:block;font-size:12px;line-height:1.5;color:{{ tema.gris }}">{{ f.detalle }}</span>
                    </span>
                    <button onClick="{{ f.go }}" style="flex:none;padding:9px 14px;border-radius:13px;border:1px solid {{ tema.borde }};background:transparent;color:inherit;cursor:pointer;font-size:13px;font-weight:700">{{ f.boton }}</button>
                  </div>
                </sc-for>
              </div>
              <sc-if value="{{ dpAbierto }}" hint-placeholder-val="{{ false }}">
                <div style="display:flex;flex-direction:column;gap:10px;padding:14px;border-radius:13px;background:{{ tema.suave }}">
                  <span style="font-size:13px;font-weight:800">{{ dpTitulo }}</span>
                  <sc-if value="{{ dpPaso1 }}" hint-placeholder-val="{{ true }}">
                    <input aria-label="Tu contraseña, para confirmar que eres tú" value="{{ dpClave }}" onChange="{{ onDpClave }}" type="password" placeholder="Tu contraseña, para confirmar que eres tú" style="padding:12px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" />
                  </sc-if>
                  <sc-if value="{{ dpEsTotp2 }}" hint-placeholder-val="{{ false }}">
                    <p style="margin:0;font-size:13px;line-height:1.55;color:{{ tema.gris }}">Escanea el código con Google Authenticator, Microsoft Authenticator, Authy o la app de contraseñas del teléfono, y escribe el código que te dé.</p>
                    <div style="display:flex;gap:16px;align-items:center;flex-wrap:wrap">
                      <img src="{{ dpQr }}" alt="QR" style="width:180px;height:180px;border-radius:13px;background:#fff;padding:6px;border:1px solid {{ tema.borde }}" />
                      <span style="flex:1;min-width:200px;font-size:12px;color:{{ tema.gris }}">O escribe esta clave en la app:<br /><code style="display:block;margin-top:6px;font-size:14px;letter-spacing:0.08em;word-break:break-all;user-select:text">{{ dpSecreto }}</code></span>
                    </div>
                    <input aria-label="Código de 6 dígitos que te da la app" value="{{ dpCodigo }}" onChange="{{ onDpCodigo }}" inputmode="numeric" maxlength="6" placeholder="Código de 6 dígitos que te da la app" style="padding:12px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit;letter-spacing:0.15em" />
                  </sc-if>
                  <sc-if value="{{ dpEsTelegram2 }}" hint-placeholder-val="{{ false }}">
                    <p style="margin:0;font-size:13px;line-height:1.55;color:{{ tema.gris }}">Abre el bot {{ dpBot }} y toca «Iniciar». Esto se cierra solo en cuanto quede enlazado.</p>
                    <a href="{{ dpEnlace }}" target="_blank" rel="noopener" style="align-self:flex-start;padding:11px 18px;border-radius:13px;background:oklch(0.852 0.147 93);color:oklch(0.24 0.05 155);font-size:13px;font-weight:700;text-decoration:none">Abrir Telegram</a>
                  </sc-if>
                  <sc-if value="{{ dpEsRespaldo2 }}" hint-placeholder-val="{{ false }}">
                    <p style="margin:0;font-size:13px;line-height:1.55;color:{{ tema.gris }}">Guárdalos donde solo tú los veas. Cada uno vale una sola vez; pedir otros anula estos.</p>
                    <div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(120px,1fr));gap:6px 14px;padding:12px 14px;border-radius:13px;background:{{ tema.card }};border:1px solid {{ tema.borde }}">
                      <sc-for list="{{ dpCodigos }}" as="c" hint-placeholder-count="8"><code style="font-size:14px;letter-spacing:0.08em;user-select:text">{{ c }}</code></sc-for>
                    </div>
                    <div style="display:flex;gap:16px;flex-wrap:wrap">
                      <button onClick="{{ dpDescargarCodigos }}" style="border:none;background:transparent;cursor:pointer;font-size:13px;font-weight:700;color:oklch(0.44 0.11 155);padding:0">Descargar (.txt)</button>
                      <button onClick="{{ dpCopiarCodigos }}" style="border:none;background:transparent;cursor:pointer;font-size:13px;font-weight:700;color:oklch(0.44 0.11 155);padding:0">Copiar los ocho</button>
                    </div>
                  </sc-if>
                  <sc-if value="{{ dpError }}" hint-placeholder-val="{{ false }}">
                    <div style="padding:10px 12px;border-radius:13px;background:oklch(0.96 0.04 30);color:oklch(0.48 0.15 30);font-size:13px">{{ dpError }}</div>
                  </sc-if>
                  <div style="display:flex;gap:10px;flex-wrap:wrap">
                    <button onClick="{{ dpConfirmar }}" style="padding:12px 20px;border-radius:13px;border:none;background:oklch(0.852 0.147 93);color:oklch(0.24 0.05 155);cursor:pointer;font-size:14px;font-weight:700">{{ dpBoton }}</button>
                    <button onClick="{{ dpCancelar }}" style="padding:12px 16px;border-radius:13px;border:1px solid {{ tema.borde }};background:transparent;color:inherit;cursor:pointer;font-size:13px;font-weight:700">Cancelar</button>
                  </div>
                </div>
              </sc-if>
            </div>
              <div style="background:{{ tema.card }};border:1px solid {{ tema.borde }};border-radius:18px;padding:22px;display:flex;flex-direction:column;gap:12px">
                <h2 style="margin:0;font-family:'Bricolage Grotesque',sans-serif;font-size:17px;font-weight:800;letter-spacing:-0.02em">{{ txt.cerrarSesion }}</h2>
                <button onClick="{{ cerrarSesion }}" style="align-self:flex-start;padding:12px 18px;border-radius:13px;border:1px solid {{ tema.borde }};background:transparent;color:{{ tema.gris }};cursor:pointer;font-size:13px;font-weight:700">{{ txt.cerrarSesion }}</button>
              </div>
            </div>
            <!-- Dispositivos y actividad -->
            <div style="display:flex;flex-direction:column;gap:16px">
              <div style="background:{{ tema.card }};border:1px solid {{ tema.borde }};border-radius:18px;padding:22px;display:flex;flex-direction:column;gap:12px">
                <h2 style="margin:0;font-family:'Bricolage Grotesque',sans-serif;font-size:17px;font-weight:800;letter-spacing:-0.02em">{{ tituloDispositivos }}</h2>
                <sc-for list="{{ sesiones }}" as="q" hint-placeholder-count="2">
                  <div style="display:flex;align-items:center;gap:12px;padding:11px 0;border-bottom:1px solid {{ q.linea }}">
                    <span style="width:34px;height:34px;border-radius:13px;flex:none;display:flex;align-items:center;justify-content:center;background:{{ tema.suave }};color:{{ q.tinta }}">
                      <sc-if value="{{ q.esMovil }}" hint-placeholder-val="{{ false }}"><svg viewBox="0 0 24 24" style="width:17px;height:17px" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="7" y="3" width="10" height="18" rx="2"></rect><path d="M11 18h2"></path></svg></sc-if>
                      <sc-if value="{{ q.esMovil }}" hint-placeholder-val="{{ true }}"><svg viewBox="0 0 24 24" style="width:17px;height:17px" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="12" rx="2"></rect><path d="M8 20h8M12 16v4"></path></svg></sc-if>
                    </span>
                    <div style="flex:1;min-width:0">
                      <div style="font-size:14px;font-weight:600;color:{{ q.tinta }};white-space:nowrap;overflow:hidden;text-overflow:ellipsis">{{ q.equipo }}</div>
                      <div style="font-size:12px;color:{{ tema.gris }}">{{ q.detalle }}</div>
                    </div>
                    <sc-if value="{{ q.cerrable }}" hint-placeholder-val="{{ true }}">
                      <button onClick="{{ q.onCerrar }}" style="flex:none;padding:11px 16px;border-radius:13px;border:1px solid {{ tema.borde }};background:transparent;color:inherit;cursor:pointer;font-size:13px;font-weight:700">Cerrar</button>
                    </sc-if>
                  </div>
                </sc-for>
                <button onClick="{{ cerrarOtras }}" style="align-self:flex-start;margin-top:4px;padding:11px 16px;border-radius:13px;border:1px solid {{ tema.borde }};background:transparent;color:inherit;cursor:pointer;font-size:13px;font-weight:700">Cerrar las demás</button>
              </div>
              <div style="background:{{ tema.card }};border:1px solid {{ tema.borde }};border-radius:18px;padding:22px;display:flex;flex-direction:column;gap:8px">
                <h2 style="margin:0;font-family:'Bricolage Grotesque',sans-serif;font-size:17px;font-weight:800;letter-spacing:-0.02em;margin-bottom:6px">{{ tituloActividadSeg }}</h2>
                <sc-if value="{{ hayActividad }}" hint-placeholder-val="{{ true }}">
                  <sc-for list="{{ actividadSeg }}" as="a" hint-placeholder-count="4">
                    <div style="padding:9px 0;border-bottom:1px solid {{ a.linea }}">
                      <div style="font-size:13px;line-height:1.4;color:{{ tema.tinta }}">{{ a.accion }}</div>
                      <div style="font-size:11px;color:{{ tema.gris }}">{{ a.cuando }}</div>
                    </div>
                  </sc-for>
                </sc-if>
                <sc-if value="{{ hayActividad }}" hint-placeholder-val="{{ false }}">
                  <p style="margin:0;font-size:13px;color:{{ tema.gris }}">Todavía no hay actividad reciente.</p>
                </sc-if>
              </div>
              <div style="background:{{ tema.card }};border:1px solid {{ tema.borde }};border-radius:18px;padding:22px;display:flex;flex-direction:column;gap:12px">
                <h2 style="margin:0;font-family:'Bricolage Grotesque',sans-serif;font-size:17px;font-weight:800;letter-spacing:-0.02em">Notificaciones de pago</h2>
                <p style="margin:0;font-size:13px;line-height:1.55;color:{{ tema.gris }}">Avisos del navegador cuando se acerque un corte o una cuota.</p>
                <button onClick="{{ pedirNotis }}" style="align-self:flex-start;padding:12px 18px;border-radius:13px;border:1px solid {{ tema.borde }};background:transparent;cursor:pointer;font-size:13px;font-weight:700;color:{{ notisPermColor }}">{{ notisPermLabel }}</button>
              </div>
            </div>
          </div>
        </sc-if>
        <!-- DATOS -->
        <sc-if value="{{ tabDatos }}" hint-placeholder-val="{{ false }}">
          <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(320px,1fr));gap:16px;align-items:start">
            <div style="display:flex;flex-direction:column;gap:16px">
            <div style="background:{{ tema.card }};border:1px solid {{ tema.borde }};border-radius:18px;overflow:hidden">
              <sc-for list="{{ ajustes }}" as="a" hint-placeholder-count="4">
                <button onClick="{{ a.go }}" style="width:100%;padding:16px 20px;border:none;border-bottom:1px solid {{ tema.suave }};background:transparent;cursor:pointer;display:flex;align-items:center;gap:14px;text-align:left;color:inherit">
                  <span style="width:34px;height:34px;border-radius:13px;background:{{ a.bg }};display:flex;align-items:center;justify-content:center;flex:0 0 auto">
                    <svg viewBox="0 0 24 24" style="width:18px;height:18px" fill="none" stroke="{{ a.fg }}" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="{{ a.icono }}"></path></svg>
                  </span>
                  <span style="flex:1;font-size:14px;font-weight:600">{{ a.label }}</span>
                  <span style="font-size:12px;color:{{ tema.gris }}">{{ a.valor }}</span>
                </button>
              </sc-for>
            </div>
              <div style="background:{{ tema.card }};border:1px solid {{ tema.borde }};border-radius:18px;padding:20px">
                <h2 style="margin:0 0 4px;font-family:'Bricolage Grotesque',sans-serif;font-size:17px;font-weight:800;letter-spacing:-0.02em">{{ importarTitulo }}</h2>
                <p style="margin:0 0 14px;font-size:13px;line-height:1.5;color:{{ tema.gris }}">{{ importarDesc }}</p>
                <button data-csv-zona onClick="{{ importarCsv }}" style="width:100%;padding:26px 16px;border-radius:13px;border:2px dashed {{ csvZonaBorde }};background:{{ csvZonaBg }};color:{{ csvZonaColor }};cursor:pointer;display:flex;flex-direction:column;align-items:center;gap:10px;text-align:center">
                  <svg viewBox="0 0 24 24" style="width:26px;height:26px" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4M7 9l5-5 5 5M12 4v12"></path></svg>
                  <span style="font-size:13px;font-weight:700">{{ csvZonaTexto }}</span>
                </button>
              </div>
            </div>
            <div style="display:flex;flex-direction:column;gap:16px">
              <div style="background:{{ tema.card }};border:1px solid {{ tema.borde }};border-radius:18px;padding:20px">
                <h2 style="margin:0 0 12px;font-family:'Bricolage Grotesque',sans-serif;font-size:17px;font-weight:800;letter-spacing:-0.02em">{{ txt.resumenAnio }}</h2>
                <sc-for list="{{ resumenAnual }}" as="r" hint-placeholder-count="4">
                  <div style="display:flex;justify-content:space-between;align-items:center;font-size:13px;padding:9px 0;border-bottom:1px solid {{ tema.suave }}">
                    <span style="color:{{ tema.gris }}">{{ r.label }}</span>
                    <span style="font-weight:800;color:{{ r.color }}">{{ r.valor }}</span>
                  </div>
                </sc-for>
              </div>
              <div style="background:{{ tema.card }};border:1px solid oklch(0.88 0.06 30);border-radius:18px;padding:22px;display:flex;flex-direction:column;gap:12px">
                <h2 style="margin:0;font-family:'Bricolage Grotesque',sans-serif;font-size:17px;font-weight:800;letter-spacing:-0.02em;color:oklch(0.55 0.16 30)">Eliminar mi cuenta</h2>
                <p style="margin:0;font-size:13px;line-height:1.55;color:{{ tema.gris }}">Se borran tus libretas, movimientos y accesos compartidos. No se puede deshacer.</p>
                <input aria-label="Escribe tu contraseña para confirmar" value="{{ bajaClave }}" onChange="{{ onBajaClave }}" type="password" placeholder="Escribe tu contraseña para confirmar" style="padding:12px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" />
                <button onClick="{{ eliminarCuenta }}" style="align-self:flex-start;padding:12px 18px;border-radius:13px;border:1px solid oklch(0.88 0.06 30);background:transparent;color:oklch(0.55 0.16 30);cursor:pointer;font-size:13px;font-weight:700">{{ botonBaja }}</button>
              </div>
            </div>
          </div>
        </sc-if>

        <sc-if value="{{ tabPlan }}" hint-placeholder-val="{{ false }}">
          <div style="display:flex;flex-direction:column;gap:18px">
            <div style="background:{{ tema.card }};border:1px solid {{ tema.borde }};border-radius:18px;padding:22px;display:flex;align-items:center;justify-content:space-between;gap:14px;flex-wrap:wrap">
              <div>
                <div style="font-size:12px;text-transform:uppercase;letter-spacing:0.08em;color:{{ tema.gris }};font-weight:700">Tu plan</div>
                <div style="margin-top:4px;font-family:'Bricolage Grotesque',sans-serif;font-size:22px;font-weight:800;letter-spacing:-0.02em;color:{{ planActualColor }}">{{ planActualNombre }}</div>
              </div>
              <p style="margin:0;flex:1;min-width:240px;max-width:520px;font-size:12px;line-height:1.55;color:{{ tema.gris }}">{{ planIntro }}</p>
            </div>
            <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(260px,1fr));gap:16px;align-items:start">
              <sc-for list="{{ planes }}" as="pl" hint-placeholder-count="3">
                <div style="background:{{ pl.bg }};border:2px solid {{ pl.borde }};border-radius:18px;padding:22px;display:flex;flex-direction:column;gap:14px">
                  <div style="display:flex;align-items:baseline;justify-content:space-between;gap:10px">
                    <div>
                      <div style="font-family:'Bricolage Grotesque',sans-serif;font-size:20px;font-weight:800;letter-spacing:-0.02em">{{ pl.nombre }}</div>
                      <div style="font-size:12px;color:{{ tema.gris }}">{{ pl.para }}</div>
                    </div>
                    <div style="text-align:right;white-space:nowrap">
                      <div style="font-family:'Bricolage Grotesque',sans-serif;font-size:19px;font-weight:800;letter-spacing:-0.02em">{{ pl.precio }}</div>
                      <div style="font-size:11px;color:{{ tema.gris }}">{{ pl.cada }}</div>
                    </div>
                  </div>
                  <div style="display:flex;flex-direction:column;gap:7px">
                    <sc-for list="{{ pl.items }}" as="it" hint-placeholder-count="4">
                      <div style="display:flex;align-items:flex-start;gap:8px;font-size:13px;line-height:1.4;color:{{ tema.gris }}">
                        <svg viewBox="0 0 24 24" style="width:15px;height:15px;flex:none;margin-top:2px" fill="none" stroke="var(--positivo)" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12.5l5 5L19 7"></path></svg>{{ it.texto }}
                      </div>
                    </sc-for>
                  </div>
                  <button onClick="{{ pl.go }}" disabled="{{ pl.deshabilitado }}" style="margin-top:auto;padding:12px;border-radius:13px;border:none;background:{{ pl.botonBg }};color:{{ pl.botonFg }};cursor:pointer;font-size:13px;font-weight:700">{{ pl.botonLabel }}</button>
                </div>
              </sc-for>
            </div>
          </div>
        </sc-if>
      </div>
    </sc-if>
      <!-- Pie legal. Una app con cuentas necesita decir de quién es y dónde
           están sus condiciones, sin obligar a salir a buscarlo. -->
      <footer style="margin-top:36px;padding-top:18px;border-top:1px solid {{ tema.borde }};display:flex;flex-wrap:wrap;align-items:center;gap:8px 16px;font-size:12px;color:{{ tema.gris }}">
        <span>© 2026 FENTE · Chinola</span>
        <a href="/guia" target="_blank" rel="noopener" style="color:{{ tema.gris }}">{{ pie.guia }}</a>
        <a href="/planes" target="_blank" rel="noopener" style="color:{{ tema.gris }}">{{ pie.planes }}</a>
        <a href="/legal/terminos" target="_blank" rel="noopener" style="color:{{ tema.gris }}">{{ pie.terminos }}</a>
        <a href="/legal/privacidad" target="_blank" rel="noopener" style="color:{{ tema.gris }}">{{ pie.privacidad }}</a>
        <a href="/legal/soporte" target="_blank" rel="noopener" style="color:{{ tema.gris }}">{{ pie.soporte }}</a>
        <a href="/legal/licencias" target="_blank" rel="noopener" style="color:{{ tema.gris }}">{{ pie.licencias }}</a>
        <span style="flex:1;min-width:12px"></span>
        <span>{{ pie.aviso }}</span>
      </footer>
    </main>

    <!-- MODAL MOVIMIENTO -->
    <sc-if value="{{ formOpen }}" hint-placeholder-val="{{ false }}">
      <div style="position:fixed;inset:0;background:oklch(0.22 0 0 / 0.45);display:flex;align-items:center;justify-content:center;z-index:60;padding:{{ movil.padModal }};animation:aparece 0.2s ease both">
        <div style="width:100%;max-width:600px;max-height:calc(100vh - 56px);overflow-y:auto;background:{{ tema.card }};border-radius:26px;padding:24px;display:flex;flex-direction:column;gap:13px;animation:entra 0.3s ease both">
          <div style="display:flex;justify-content:space-between;align-items:center">
            <h2 style="margin:0;font-family:'Bricolage Grotesque',sans-serif;font-size:21px;font-weight:800;letter-spacing:-0.025em">{{ formTitulo }}</h2>
            <button onClick="{{ cerrarForm }}" style="width:34px;height:34px;border:none;border-radius:13px;background:{{ tema.suave }};cursor:pointer;font-size:17px;color:{{ tema.gris }}">×</button>
          </div>
          <div style="display:flex;gap:8px">
            <sc-for list="{{ tiposBotones }}" as="t" hint-placeholder-count="4">
              <button onClick="{{ t.go }}" style="flex:1;padding:12px 6px;border-radius:13px;cursor:pointer;font-size:12px;font-weight:700;border:1px solid {{ t.border }};background:{{ t.bg }};color:{{ t.fg }}">{{ t.label }}</button>
            </sc-for>
          </div>
          <input aria-label="0" value="{{ form.monto }}" onChange="{{ onForm.monto }}" type="number" placeholder="0" style="padding:17px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit;font-family:'Bricolage Grotesque',sans-serif;font-size:29px;font-weight:800;text-align:center" />
          <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px">
            <input aria-label="{{ txt.concepto }}" value="{{ form.concepto }}" onChange="{{ onForm.concepto }}" placeholder="{{ txt.concepto }}" style="padding:12px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" />
            <span style="display:flex;align-items:center;gap:9px;min-width:0">
              <span style="width:38px;height:38px;border-radius:13px;background:{{ formIconoBg }};display:flex;align-items:center;justify-content:center;flex:0 0 auto">
                <svg viewBox="0 0 24 24" style="width:20px;height:20px" fill="none" stroke="{{ formIconoColor }}" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="{{ formIconoPath }}"></path></svg>
              </span>
              <select aria-label="{{ a11y.categoria }}" value="{{ form.categoria }}" onChange="{{ onForm.categoria }}" style="flex:1;min-width:0;padding:12px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit">
                <sc-for list="{{ nombresCat }}" as="c" hint-placeholder-count="8"><option value="{{ c }}">{{ c }}</option></sc-for>
              </select>
            </span>
            <select aria-label="{{ a11y.medio }}" value="{{ form.medio }}" onChange="{{ onForm.medio }}" style="grid-column:span 2;padding:12px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit">
              <sc-for list="{{ medios }}" as="m" hint-placeholder-count="3"><option value="{{ m.id }}">{{ m.label }}</option></sc-for>
            </select>
          </div>
          <div style="display:flex;flex-direction:column;gap:9px;padding:13px;border-radius:13px;background:{{ tema.suave }}">
            <div style="display:flex;align-items:center;justify-content:space-between;gap:10px;flex-wrap:wrap">
              <span style="font-size:12px;font-weight:700;color:{{ tema.gris }}">{{ txt.fecha }}</span>
              <div style="display:flex;gap:6px;flex-wrap:wrap">
                <sc-for list="{{ fechasRapidas }}" as="fr" hint-placeholder-count="3">
                  <button onClick="{{ fr.go }}" style="padding:8px 13px;border-radius:18px;border:1px solid {{ fr.border }};background:{{ fr.bg }};color:{{ fr.fg }};cursor:pointer;font-size:12px;font-weight:700">{{ fr.label }}</button>
                </sc-for>
              </div>
            </div>
            <div style="display:flex;flex-direction:column;gap:8px">
              <div style="display:flex;align-items:center;justify-content:space-between;gap:8px">
                <button onClick="{{ fechaForm.antes }}" style="width:30px;height:30px;border-radius:8px;border:1px solid {{ tema.borde }};background:{{ tema.card }};cursor:pointer;color:inherit;font-size:14px">‹</button>
                <span style="font-size:13px;font-weight:700">{{ fechaForm.titulo }}</span>
                <button onClick="{{ fechaForm.despues }}" style="width:30px;height:30px;border-radius:8px;border:1px solid {{ tema.borde }};background:{{ tema.card }};cursor:pointer;color:inherit;font-size:14px">›</button>
              </div>
              <div style="display:grid;grid-template-columns:repeat(7,1fr);gap:3px">
                <sc-for list="{{ fechaForm.diasSemana }}" as="d" hint-placeholder-count="7">
                  <span style="text-align:center;font-size:10px;font-weight:700;text-transform:uppercase;color:{{ tema.gris }};padding:2px 0">{{ d }}</span>
                </sc-for>
                <sc-for list="{{ fechaForm.dias }}" as="d" hint-placeholder-count="42">
                  <button onClick="{{ d.go }}" style="aspect-ratio:1;border:none;border-radius:{{ d.radio }};background:{{ d.bg }};color:{{ d.fg }};cursor:pointer;font-size:12px;font-weight:{{ d.peso }};padding:0;opacity:{{ d.opacidad }}">{{ d.n }}</button>
                </sc-for>
              </div>
            </div>
          </div>
          <label style="display:flex;align-items:center;gap:9px;font-size:13px;color:{{ tema.gris }}">
            <input type="checkbox" checked="{{ form.recurrente }}" onChange="{{ onForm.recurrente }}" style="width:18px;height:18px" />{{ txt.repetir }}
          </label>
          <button onClick="{{ guardarTx }}" style="padding:15px;border-radius:13px;border:none;background:oklch(0.852 0.147 93);color:oklch(0.24 0.05 155);cursor:pointer;font-size:15px;font-weight:700">{{ txt.guardarMov }}</button>
        </div>
      </div>
    </sc-if>

    <sc-if value="{{ toastOpen }}" hint-placeholder-val="{{ false }}">
      <div style="position:fixed;right:26px;bottom:26px;z-index:90;display:flex;align-items:center;gap:13px;padding:14px 18px 14px 14px;border-radius:18px;background:{{ tema.card }};border:1px solid {{ tema.borde }};box-shadow:0 20px 44px oklch(0.20 0.05 90 / 0.26);animation:toastIn 0.32s ease both;max-width:340px">
        <img src="{{ mascota.chinoloGrande }}" alt="" width="132" height="132" style="width:132px;height:132px;flex:none;pointer-events:none" />
        <div style="min-width:0">
          <div style="font-size:14px;font-weight:800;letter-spacing:-0.01em">{{ toastTitulo }}</div>
          <div style="font-size:12px;line-height:1.45;color:{{ tema.gris }};margin-top:2px">{{ toastTexto }}</div>
        </div>
      </div>
    </sc-if>

    <sc-if value="{{ invModal }}" hint-placeholder-val="{{ false }}">
      <div style="position:fixed;inset:0;background:oklch(0.22 0 0 / 0.45);display:flex;align-items:center;justify-content:center;z-index:66;padding:{{ movil.padModal }};animation:aparece 0.2s ease both">
        <div style="width:100%;max-width:480px;max-height:calc(100vh - 56px);overflow-y:auto;background:{{ tema.card }};border-radius:26px;padding:24px;display:flex;flex-direction:column;gap:14px;animation:entra 0.3s ease both">
          <div style="display:flex;justify-content:space-between;align-items:center">
            <h2 style="margin:0;font-family:'Bricolage Grotesque',sans-serif;font-size:21px;font-weight:800;letter-spacing:-0.025em">{{ tituloInvitar }}</h2>
            <button onClick="{{ cerrarInvitar }}" style="width:34px;height:34px;border:none;border-radius:13px;background:{{ tema.suave }};cursor:pointer;font-size:17px;color:{{ tema.gris }}">×</button>
          </div>
          <label style="display:flex;flex-direction:column;gap:6px;font-size:12px;font-weight:600;color:{{ tema.gris }}">{{ txt.correo }}
            <input value="{{ invForm.email }}" onChange="{{ onInv.email }}" placeholder="correo@persona.com" style="padding:13px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" /></label>
          <label style="display:flex;flex-direction:column;gap:6px;font-size:12px;font-weight:600;color:{{ tema.gris }}">{{ catNombreLabel }}
            <input value="{{ invForm.nombre }}" onChange="{{ onInv.nombre }}" style="padding:13px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" /></label>
          <div style="display:flex;flex-direction:column;gap:9px">
            <span style="font-size:12px;font-weight:600;color:{{ tema.gris }}">{{ txt.permisos }}</span>
            <sc-for list="{{ invRoles }}" as="r" hint-placeholder-count="4">
              <button onClick="{{ r.go }}" style="display:flex;flex-direction:column;gap:3px;align-items:flex-start;padding:13px 15px;border-radius:13px;border:2px solid {{ r.border }};background:{{ r.bg }};cursor:pointer;text-align:left">
                <span style="font-size:13px;font-weight:800;color:{{ tema.tinta }}">{{ r.label }}</span>
                <span style="font-size:11px;line-height:1.45;color:{{ tema.gris }}">{{ r.detalle }}</span>
              </button>
            </sc-for>
          </div>
          <button onClick="{{ enviarInvitacion }}" style="padding:15px;border-radius:13px;border:none;background:oklch(0.852 0.147 93);color:oklch(0.24 0.05 155);cursor:pointer;font-size:15px;font-weight:700">{{ txt.invitar }}</button>
        </div>
      </div>
    </sc-if>

    <!-- MODAL CATEGORÍA -->
    <sc-if value="{{ catModal }}" hint-placeholder-val="{{ false }}">
      <div style="position:fixed;inset:0;background:oklch(0.22 0 0 / 0.45);display:flex;align-items:center;justify-content:center;z-index:65;padding:{{ movil.padModal }};animation:aparece 0.2s ease both">
        <div style="width:100%;max-width:560px;max-height:calc(100vh - 56px);overflow-y:auto;background:{{ tema.card }};border-radius:26px;padding:24px;display:flex;flex-direction:column;gap:14px;animation:entra 0.3s ease both">
          <div style="display:flex;justify-content:space-between;align-items:center">
            <h2 style="margin:0;font-family:'Bricolage Grotesque',sans-serif;font-size:21px;font-weight:800;letter-spacing:-0.025em">{{ catTitulo }}</h2>
            <button onClick="{{ cerrarCatModal }}" style="width:34px;height:34px;border:none;border-radius:13px;background:{{ tema.suave }};cursor:pointer;font-size:17px;color:{{ tema.gris }}">×</button>
          </div>
          <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:12px;min-width:0">
            <label style="display:flex;flex-direction:column;gap:6px;font-size:12px;font-weight:600;color:{{ tema.gris }};min-width:0">{{ catNombreLabel }}
              <input value="{{ catForm.nombre }}" onChange="{{ onCatForm.nombre }}" style="min-width:0;padding:12px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" /></label>
            <label style="display:flex;flex-direction:column;gap:6px;font-size:12px;font-weight:600;color:{{ tema.gris }};min-width:0">{{ catLimiteLabel }}
              <input value="{{ catForm.limite }}" onChange="{{ onCatForm.limite }}" type="number" style="min-width:0;padding:12px;border-radius:13px;border:1px solid {{ tema.borde }};background:{{ tema.card }};color:inherit" /></label>
          </div>
          <div style="display:flex;gap:8px;flex-wrap:wrap">
            <sc-for list="{{ catTipos }}" as="ct" hint-placeholder-count="2">
              <button onClick="{{ ct.go }}" style="padding:11px 16px;border-radius:13px;border:1px solid {{ ct.border }};background:{{ ct.bg }};color:{{ ct.fg }};cursor:pointer;font-size:13px;font-weight:700">{{ ct.label }}</button>
            </sc-for>
          </div>
          <div style="display:flex;align-items:center;gap:9px;flex-wrap:wrap">
            <span style="font-size:12px;font-weight:600;color:{{ tema.gris }}">{{ catColorLabel }}</span>
            <sc-for list="{{ swatchesCat }}" as="sw" hint-placeholder-count="7">
              <button aria-label="{{ a11y.color }}" onClick="{{ sw.go }}" style="width:28px;height:28px;border-radius:8px;cursor:pointer;background:{{ sw.color }};border:2px solid {{ sw.borde }}"></button>
            </sc-for>
          </div>
          <div style="display:flex;flex-direction:column;gap:9px">
            <span style="font-size:12px;font-weight:600;color:{{ tema.gris }}">{{ catIconoLabel }}</span>
            <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(52px,1fr));gap:8px;max-height:270px;overflow-y:auto;padding:3px">
              <sc-for list="{{ iconosLista }}" as="ic" hint-placeholder-count="24">
                <button aria-label="{{ ic.label }}" onClick="{{ ic.go }}" title="{{ ic.label }}" style="aspect-ratio:1;border-radius:13px;border:2px solid {{ ic.border }};background:{{ ic.bg }};cursor:pointer;display:flex;align-items:center;justify-content:center">
                  <svg viewBox="0 0 24 24" style="width:22px;height:22px" fill="none" stroke="{{ ic.stroke }}" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="{{ ic.path }}"></path></svg>
                </button>
              </sc-for>
            </div>
          </div>
          <button onClick="{{ guardarCat }}" style="padding:15px;border-radius:13px;border:none;background:oklch(0.852 0.147 93);color:oklch(0.24 0.05 155);cursor:pointer;font-size:15px;font-weight:700">{{ catGuardar }}</button>
        </div>
      </div>
    </sc-if>

    <!-- TOUR -->
    <sc-if value="{{ tourOpen }}" hint-placeholder-val="{{ false }}">
      <div style="position:fixed;inset:0;background:oklch(0.20 0 0 / 0.55);z-index:80;display:flex;align-items:flex-end;padding:32px;animation:aparece 0.2s ease both">
        <div style="width:100%;max-width:460px;background:{{ tema.card }};border-radius:18px;padding:22px;display:flex;flex-direction:column;gap:12px;animation:entra 0.3s ease both">
          <div style="display:flex;justify-content:space-between;align-items:center">
            <span style="font-size:11px;font-weight:800;letter-spacing:0.09em;text-transform:uppercase;color:oklch(0.48 0.10 130)">{{ tourPaso }}</span>
            <button onClick="{{ cerrarTour }}" style="border:none;background:transparent;cursor:pointer;font-size:13px;color:{{ tema.gris }}">Saltar</button>
          </div>
          <div style="display:flex;gap:13px;align-items:flex-start">
            <img src="{{ toast.chinolo }}" alt="" width="52" height="52" style="width:52px;height:52px;flex:none;pointer-events:none" />
            <div>
              <div style="font-family:'Bricolage Grotesque',sans-serif;font-size:19px;font-weight:800;letter-spacing:-0.02em">{{ tourTitulo }}</div>
              <p style="margin:5px 0 0;font-size:14px;line-height:1.55;color:{{ tema.gris }}">{{ tourTexto }}</p>
            </div>
          </div>
          <div style="display:flex;gap:6px">
            <sc-for list="{{ tourDots }}" as="d" hint-placeholder-count="6">
              <span style="flex:1;height:5px;border-radius:4px;background:{{ d.bg }}"></span>
            </sc-for>
          </div>
          <button onClick="{{ tourSiguiente }}" style="padding:14px;border-radius:13px;border:none;background:{{ tema.side }};color:oklch(0.96 0.03 95);cursor:pointer;font-size:15px;font-weight:700">{{ tourBoton }}</button>
        </div>
      </div>
    </sc-if>
  </div>
</sc-if>


<!-- Pantallas que el prototipo no tenía porque no había servidor: recuperar la
     contraseña, confirmar el correo y aceptar una invitación. \`npm run sync\`
     las añade al final de la plantilla del diseño. -->
<sc-if value="{{ pantallaExtra }}" hint-placeholder-val="{{ false }}">
  <div style="min-height:100vh;display:flex;align-items:center;justify-content:center;padding:{{ movil.padAcceso }};background:oklch(0.975 0.015 95);color:oklch(0.24 0.03 155)">
    <div style="width:100%;max-width:430px;background:#fff;border:1px solid oklch(0.91 0.02 95);border-radius:26px;padding:32px;display:flex;flex-direction:column;gap:14px;animation:entra 0.4s ease both">
      <div style="display:flex;align-items:center;gap:10px">
        <div style="width:32px;height:32px;border-radius:50%;background:oklch(0.28 0.07 155);display:flex;align-items:center;justify-content:center"><div style="width:12px;height:12px;border-radius:50%;background:oklch(0.852 0.147 93)"></div></div>
        <span style="font-family:'Bricolage Grotesque',sans-serif;font-weight:800;font-size:20px;letter-spacing:-0.03em">Chinola</span>
      </div>
      <h1 style="margin:0;font-family:'Bricolage Grotesque',sans-serif;font-weight:800;font-size:27px;letter-spacing:-0.03em">{{ extraTitulo }}</h1>
      <p style="margin:0;font-size:14px;line-height:1.5;color:oklch(0.44 0.03 155)">{{ extraTexto }}</p>

      <sc-if value="{{ extraCampoEmail }}" hint-placeholder-val="{{ true }}">
        <input aria-label="tucorreo@mail.com" value="{{ extraEmail }}" onChange="{{ onExtraEmail }}" type="email" placeholder="tucorreo@mail.com" style="padding:14px;border-radius:13px;border:1px solid oklch(0.90 0.02 95)" />
      </sc-if>
      <sc-if value="{{ extraCampoClave }}" hint-placeholder-val="{{ false }}">
        <input aria-label="Nueva contraseña" value="{{ extraClave }}" onChange="{{ onExtraClave }}" type="password" placeholder="Nueva contraseña" style="padding:14px;border-radius:13px;border:1px solid oklch(0.90 0.02 95)" />
      </sc-if>

      <sc-if value="{{ extraHayError }}" hint-placeholder-val="{{ false }}">
        <div style="padding:12px 14px;border-radius:13px;background:oklch(0.96 0.04 30);color:oklch(0.48 0.15 30);font-size:13px;line-height:1.5">{{ extraError }}</div>
      </sc-if>
      <sc-if value="{{ extraHayOk }}" hint-placeholder-val="{{ false }}">
        <div style="padding:12px 14px;border-radius:13px;background:oklch(0.95 0.05 152);color:oklch(0.38 0.11 152);font-size:13px;line-height:1.5">{{ extraOk }}</div>
      </sc-if>

      <sc-if value="{{ extraHayBoton }}" hint-placeholder-val="{{ true }}">
        <button onClick="{{ extraAccion }}" style="padding:16px;border-radius:13px;border:none;background:oklch(0.852 0.147 93);color:oklch(0.24 0.05 155);cursor:pointer;font-size:15px;font-weight:700">{{ extraBoton }}</button>
      </sc-if>
      <button onClick="{{ extraVolver }}" style="padding:10px;border:none;background:transparent;cursor:pointer;font-size:13px;color:oklch(0.50 0.03 155)">Volver</button>
    </div>
  </div>
</sc-if>

<!-- Aviso discreto cuando el navegador no logra hablar con el servidor. -->
<sc-if value="{{ sinConexion }}" hint-placeholder-val="{{ false }}">
  <div style="position:fixed;left:50%;transform:translateX(-50%);bottom:22px;z-index:95;display:flex;align-items:center;gap:9px;padding:11px 17px;border-radius:18px;background:oklch(0.30 0.05 40);color:oklch(0.96 0.03 95);font-size:13px;font-weight:600;box-shadow:0 14px 30px oklch(0.20 0.05 40 / 0.35);animation:toastIn 0.3s ease both">
    <span style="width:8px;height:8px;border-radius:50%;background:oklch(0.80 0.15 60)"></span>Sin conexión: guardamos en este dispositivo y sincronizamos al volver.
  </div>
</sc-if>
`,Oa=Qt(Aa,Be,ca);export{Oa as default};
