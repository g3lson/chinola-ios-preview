// Lo que hace la app de verdad al arrancar, en pequeño: pintar algo y hablarle
// al nativo. Si el vigía NO salta, es que el saludo llegó.
document.addEventListener('DOMContentLoaded', function () {
  var d = document.createElement('div');
  d.setAttribute('style', 'padding:80px 20px 24px;background:#1f6f3f;color:#fff');
  d.textContent = 'LA APP ARRANCÓ';
  document.body.appendChild(d);
});

window.__chinolaTemaJSON = function () {
  return JSON.stringify({ scr: '#ffffff', card: '#ffffff', ink: '#111111', side: '#0f3a1a' });
};
window.__chinolaDatosJSON = function () { return '{}'; };
window.__chinolaHuella = function () { return 'prueba'; };

// Y el saludo al nativo por el puente, que es la señal que su vigía espera.
(async function () {
  try {
    var m = await import('@capacitor/core');
  } catch (e) { /* no hay módulos: se usa el puente global */ }
  try {
    var Nativo = window.Capacitor.registerPlugin('Nativo');
    await Nativo.tema({ json: window.__chinolaTemaJSON() });
    var ok = document.createElement('div');
    ok.setAttribute('style', 'padding:20px;background:#2f5bc4;color:#fff');
    ok.textContent = 'SALUDÓ AL NATIVO';
    document.body.appendChild(ok);
  } catch (e) {
    var er = document.createElement('div');
    er.setAttribute('style', 'padding:20px;background:#b33;color:#fff;font-size:16px');
    er.textContent = 'no pudo saludar: ' + e;
    document.body.appendChild(er);
  }
})();
