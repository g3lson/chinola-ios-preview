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
    miembros: [{ email: 'local', nombre: 'Gelson', rol: 'Dueño' }],
    tx: tx, categorias: categorias,
    presupuesto: { 'Alimentación': 18000, 'Transporte': 9000, 'Servicios': 7000, 'Vivienda': 25000 },
    cuentas: [
      { id: 1, nombre: 'Efectivo', banco: 'Sin banco', saldo: 8400, color: COLS[0] },
      { id: 2, nombre: 'Nómina', banco: 'Banreservas', saldo: 52300, color: COLS[1] },
      { id: 3, nombre: 'Ahorros', banco: 'Popular', saldo: 118000, color: COLS[4] }
    ],
    tarjetas: [{ id: 1, nombre: 'Visa Popular', banco: 'Popular', limite: 80000, saldo: 23400, corte: 20, pago: 10, color: COLS[3] }],
    prestamos: [{ id: 1, nombre: 'Carro', banco: 'Banreservas', saldo: 210000, cuota: 12500, dia: 5, color: COLS[4] }],
    metas: [{ id: 1, nombre: 'Viaje', objetivo: 120000, ahorrado: 45000, aporte: 8000, color: COLS[2] }],
    panel: [
      { id: 'w1', tipo: 'kpi-balance', ancho: 2 },
      { id: 'w5', tipo: 'barras-categorias', ancho: 2 },
      { id: 'w6', tipo: 'columnas-tendencia', ancho: 2 },
      { id: 'w7', tipo: 'lista-recientes', ancho: 2 },
      { id: 'w8', tipo: 'lista-recordatorios', ancho: 2 }
    ]
  };

  localStorage.setItem('chinola-datos-v3', JSON.stringify({ libretas: [libreta], activa: libreta.id }));
  localStorage.setItem('chinola-sesion-v3', JSON.stringify({
    sesion: null, local: true, tema: 'sistema', personaje: 'auto', idioma: 'es', notis: false,
    cabecera: 'auto', cabeceraColor: '', cabeceraTarjeta: false, empiezaFuera: [], letra: 'normal',
    nombreLocal: 'Gelson', temaAuto: true, temaClaro: 'sistema', temaOscuro: 'sistema_noche'
  }));
})();
