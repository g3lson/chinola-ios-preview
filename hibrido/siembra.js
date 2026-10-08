/**
 * UNA LIBRETA DE EJEMPLO, SOLO PARA EL BANCO DE PRUEBAS.
 *
 * El simulador arranca siempre sin cuenta y sin datos, así que lo único que se
 * llegaba a ver era la pantalla de bienvenida. Las pantallas nativas —Resumen,
 * Movimientos, Cuentas, Plan, Perfil— son justo las que tapan el webview y las
 * que hay que ver con números dentro.
 *
 * Esto NO va en la app: se copia solo dentro del paquete que usa el banco.
 */
/**
 * Y UNA CUENTA FINGIDA, con Chino con IA encendido.
 *
 * Lo que decide si sale el botón flotante viene del servidor
 * (`/integraciones/voz`), y en el banco no hay servidor: sin esto no se puede
 * comprobar ni que el botón sale ni que la charla abre. Se responde a las
 * pocas rutas que hacen falta y lo demás sigue su camino.
 *
 * Solo para el banco: este archivo no va dentro de la app.
 */
(function () {
  const orig = window.fetch;
  const json = (o) => new Response(JSON.stringify(o), { headers: { 'content-type': 'application/json' } });
  window.fetch = function (u, o) {
    const url = String((u && u.url) || u || '');
    // `/yo` es lo que decide si se ENTRA: sin esto la app se queda en la
    // pantalla de acceso (`paso: auth`) y no hay nada que mirar.
    if (/\/yo(\?|$)/.test(url)) {
      return Promise.resolve(json({
        usuario: { email: 'gelson@banco', nombre: 'Gelson', plan: 'pro', ia: 1 },
        prefs: { tema: 'sistema', idioma: 'es', personaje: 'auto', notis: false }
      }));
    }
    // Las libretas las pone la siembra en el almacén local; aquí se contesta
    // vacío para que la bajada no pise lo sembrado.
    if (/\/libretas(\?|$)/.test(url)) {
      const d = JSON.parse(localStorage.getItem('chinola-datos-v3') || '{}');
      return Promise.resolve(json({ libretas: d.libretas || [] }));
    }
    if (url.includes('/integraciones/voz')) {
      return Promise.resolve(json({ ia: true, hayIA: true, alexa: {}, whatsapp: {}, telegram: {} }));
    }
    if (url.includes('/mi-ia')) return Promise.resolve(json({ mia: null, presets: [] }));
    if (url.includes('/ia/permisos')) return Promise.resolve(json({ texto: 'Mirar y anotar', catalogo: [] }));

    // TODO LO DEMÁS DEL SERVIDOR, VACÍO Y EN 200.
    //
    // Antes se dejaba pasar al servidor DE VERDAD, que con un vale inventado
    // contesta 401. La app hace lo correcto con un 401 —cerrar la sesión— y se
    // volvía a la pantalla de acceso: `paso: auth`. A partir de ahí la lógica
    // corta antes de calcular nada y devuelve listas vacías, así que Cuentas
    // salía sin una sola fila teniendo tres cuentas sembradas, y todas las
    // demás pantallas enseñaban lo último que el nativo hubiera guardado.
    //
    // Es decir: el banco fotografiaba una app que nunca llegó a entrar, y no lo
    // decía en ninguna parte. Un 200 vacío deja la sesión en pie, que es lo
    // único que hace falta para que las pantallas se puedan mirar.
    if (/\/(yo|libretas|claves|mfa|seguridad|integraciones|ia|voz|estuve|metricas|plan|cobro)/.test(url)
        || url.indexOf('chinola.fente.com.do') >= 0) {
      return Promise.resolve(json({}));
    }
    return orig.call(this, u, o);
  };
})();

(function () {
  if (localStorage.getItem('chinola-datos-v3')) return;   // ya hay algo: no tocar
  var COLS = ['oklch(0.42 0.10 155)', 'oklch(0.46 0.11 255)', 'oklch(0.60 0.13 95)',
    'oklch(0.46 0.11 200)', 'oklch(0.56 0.16 30)', 'oklch(0.50 0.14 300)',
    'oklch(0.50 0.12 175)', 'oklch(0.46 0.12 290)', 'oklch(0.58 0.14 60)',
    'oklch(0.50 0.15 10)', 'oklch(0.44 0.11 230)', 'var(--ahorro)', 'oklch(0.32 0.03 155)'];
  var NOM = ['Ingresos', 'Vivienda', 'Alimentación', 'Servicios', 'Transporte', 'Educación',
    'Salud', 'Donaciones', 'Entretenimiento', 'Deudas', 'Personal', 'Ahorro', 'Otros'];
  var categorias = NOM.map(function (n, i) {
    return { id: i + 1, nombre: n, color: COLS[i], ingreso: i === 0 };
  });

  var hoy = new Date();
  var mes = function (atras) {
    var f = new Date(hoy.getFullYear(), hoy.getMonth() - atras, 1);
    return f.getFullYear() + '-' + String(f.getMonth() + 1).padStart(2, '0');
  };
  var cats = ['Alimentación', 'Transporte', 'Servicios', 'Vivienda', 'Entretenimiento', 'Salud'];
  var conceptos = ['Supermercado', 'Gasolina', 'Luz', 'Internet', 'Cine', 'Farmacia'];
  var tx = [];
  var k = 1;
  for (var m = 0; m < 4; m++) {
    var p = mes(m);
    tx.push({ id: 't' + (k++), concepto: 'Sueldo', categoria: 'Ingresos', tipo: 'Ingreso', monto: 95000, fecha: p + '-01', recurrente: true, medio: 'cuenta:2' });
    tx.push({ id: 't' + (k++), concepto: 'Alquiler', categoria: 'Vivienda', tipo: 'Gasto Fijo', monto: 25000, fecha: p + '-02', recurrente: true, medio: 'cuenta:2' });
    for (var i = 0; i < 6; i++) {
      tx.push({
        id: 't' + (k++), concepto: conceptos[i], categoria: cats[i], tipo: 'Gasto Variable',
        monto: 1500 + i * 1100 + m * 300, fecha: p + '-' + String(4 + i * 3).padStart(2, '0'),
        recurrente: false, medio: i % 2 ? 'cuenta:1' : 'cuenta:2'
      });
    }
  }

  // TRES DEL MISMO DÍA, para mirar el orden dentro del grupo: el último
  // anotado tiene que encabezar la lista. Los ids son como los que genera la
  // app de verdad: los milisegundos de cuando se anotó, y tres cifras detrás.
  var t0 = Date.now();
  ['PRIMERO', 'SEGUNDO', 'TERCERO'].forEach(function (n, i) {
    tx.unshift({
      id: String(t0 + i * 1000) + String(100 + i), concepto: n, categoria: 'Otros',
      tipo: 'Gasto Variable', monto: 100 * (i + 1),
      fecha: new Date().toISOString().slice(0, 10), recurrente: false, medio: 'cuenta:1'
    });
  });

  var libreta = {
    id: 'lb-banco-de-pruebas', nombre: 'Personal', tipo: 'Personal', color: COLS[0],
    // CON EL CORREO DE LA SESIÓN, no «local».
    //
    // Con «local», el dueño de la libreta sembrada no era quien entraba
    // (`gelson@banco`), así que la app lo veía de LECTOR en la única libreta
    // que hay y `aseguraLibretaPropia` le creaba otra —vacía— y la ponía
    // activa. El banco llevaba fotografiando esa: una cuenta y un movimiento,
    // sin tarjeta, sin préstamo y sin meta. Por eso las fichas salían en
    // blanco, y por eso lo que medía el banco no era lo que se sembraba.
    miembros: [{ email: 'gelson@banco', nombre: 'Gelson', rol: 'Dueño' }],
    tx: tx, categorias: categorias,
    presupuesto: { 'Alimentación': 18000, 'Transporte': 9000, 'Servicios': 7000, 'Vivienda': 25000 },
    // CON SU TIPO Y LO SUYO, que es lo que ahora distingue a una cuenta de
    // otra: al efectivo no se le pregunta el banco —no tiene— y a un
    // certificado sí su tasa y cuándo vence. Sin esto el banco fotografía tres
    // cuentas iguales y no se ve la diferencia.
    cuentas: [
      { id: 1, nombre: 'Efectivo', banco: '', saldo: 8400, color: COLS[0],
        clase: 'efectivo', tipo: 'efectivo', extra: { donde: 'La cartera' } },
      { id: 2, nombre: 'Nómina', banco: 'Banreservas', saldo: 52300, color: COLS[1],
        clase: 'banco', tipo: 'banco', extra: { last4: '4417' } },
      { id: 3, nombre: 'Certificado', banco: 'Popular', saldo: 118000, color: COLS[4],
        clase: 'ahorro', tipo: 'ahorro', extra: { tasa: '7.5', vence: '2027-03-15' } }
    ],
    tarjetas: [{ id: 1, nombre: 'Visa Popular', banco: 'Popular', limite: 80000, saldo: 23400, corte: 20, pago: 10, color: COLS[3] }],
    // OJO CON LOS NOMBRES DE LOS CAMPOS.
    //
    // Un préstamo se guarda con `total` y `pagado`, no con `saldo`; y una meta
    // con `meta` y `mensual`, no con `objetivo` y `aporte`. Estaban puestos los
    // que no eran, así que el préstamo y la meta salían en CERO en todas las
    // capturas: el banco enseñaba una pantalla sin el caso que había que mirar
    // y nadie se enteraba, porque una cifra en cero se lee como «no hay nada».
    prestamos: [{ id: 1, nombre: 'Carro', banco: 'Banreservas', total: 210000, pagado: 60000,
      sentido: 'debo', cuota: 12500, dia: 5, color: COLS[4] }],
    metas: [{ id: 1, nombre: 'Viaje', meta: 120000, ahorrado: 45000, mensual: 8000, color: COLS[2] }],
    panel: [
      { id: 'w1', tipo: 'kpi-balance', ancho: 2 },
      { id: 'w5', tipo: 'barras-categorias', ancho: 2 },
      { id: 'w6', tipo: 'columnas-tendencia', ancho: 2 },
      { id: 'w7', tipo: 'lista-recientes', ancho: 2 },
      { id: 'w8', tipo: 'lista-recordatorios', ancho: 2 }
    ]
  };

  localStorage.setItem('chinola-datos-v3', JSON.stringify({ libretas: [libreta], activa: libreta.id }));
  // Con sesión: sin token, la app no pide nada al servidor y el estado de la
  // IA no llega nunca.
  localStorage.setItem('chinola-token', 'banco-de-pruebas');
  localStorage.setItem('chinola-usuario', JSON.stringify({ email: 'gelson@banco', nombre: 'Gelson', plan: 'pro' }));
  localStorage.setItem('chinola-sesion-v3', JSON.stringify({
    sesion: { email: 'gelson@banco', nombre: 'Gelson' }, local: false, tema: 'sistema', personaje: 'auto', idioma: 'es', notis: false,
    cabecera: 'auto', cabeceraColor: '', cabeceraTarjeta: false, empiezaFuera: [], letra: 'normal',
    nombreLocal: 'Gelson', temaAuto: true, temaClaro: 'sistema', temaOscuro: 'sistema_noche'
  }));
})();
