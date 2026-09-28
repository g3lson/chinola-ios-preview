// Si esto corre, el módulo arranca dentro del controlador real de Chinola.
window.__modulo = true;

// Y se le dice al nativo, que es la señal que su vigía espera. Si el vigía
// salta igual, es que esto nunca corrió.
const pinta = (t, c) => {
  const d = document.createElement('div');
  d.setAttribute('style', 'position:fixed;inset:0;z-index:99999;display:flex;align-items:center;'
    + 'justify-content:center;background:' + c + ';color:#fff;font:700 34px -apple-system,system-ui;'
    + 'text-align:center;padding:24px');
  d.textContent = t;
  document.body.appendChild(d);
};
pinta('EL MÓDULO SÍ CORRIÓ', '#137d41');

// Y se contesta lo que el nativo pregunta, para que no salte su aviso.
window.__chinolaTemaJSON = () => JSON.stringify({ scr: '#f0f0f3', card: '#ffffff', ink: '#1a1a1c' });
window.__chinolaDatosJSON = () => '{}';
window.__chinolaHuella = () => 'prueba';
