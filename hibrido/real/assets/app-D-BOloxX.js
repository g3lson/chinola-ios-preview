// Si esto corre, la app arranca.
const d = document.createElement('div');
d.setAttribute('style', 'padding:80px 20px 24px;background:#1f6f3f;color:#fff');
d.textContent = 'LA APP ARRANCÓ';
(document.body || document.documentElement).appendChild(d);

window.__chinolaTemaJSON = () => JSON.stringify({ scr: '#ffffff', card: '#ffffff', ink: '#111111' });
window.__chinolaDatosJSON = () => '{}';
window.__chinolaHuella = () => 'prueba';

// Y el saludo al nativo, que apaga su vigía: es la prueba de que el puente va.
try {
  const Nativo = window.Capacitor.registerPlugin('Nativo');
  Nativo.tema({ json: window.__chinolaTemaJSON() }).then(() => {
    const ok = document.createElement('div');
    ok.setAttribute('style', 'padding:20px;background:#2f5bc4;color:#fff');
    ok.textContent = 'SALUDÓ AL NATIVO';
    document.body.appendChild(ok);
  });
} catch (e) { /* nada */ }
