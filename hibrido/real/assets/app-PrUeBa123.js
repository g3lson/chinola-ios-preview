// Si esto corre, los módulos arrancan dentro del controlador real.
const d = document.createElement('div');
d.id = 'modulo';
d.setAttribute('style', 'padding:24px 20px;background:#b8860b;color:#fff');
d.textContent = 'MÓDULO: sí corrió';
document.body.appendChild(d);

// Y se le contesta al nativo, para que su vigía no tape la pantalla.
window.__chinolaTemaJSON = () => JSON.stringify({ scr: '#ffffff', card: '#ffffff', ink: '#111111' });
window.__chinolaDatosJSON = () => '{}';
window.__chinolaHuella = () => 'prueba';
