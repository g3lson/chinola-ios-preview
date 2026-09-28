// Lo más simple posible: si esto no pinta, el script externo no se ejecuta.
var d = document.createElement('div');
d.setAttribute('style', 'padding:80px 20px 24px;background:#1f6f3f;color:#fff');
d.textContent = 'EXTERNO CLASICO: corrio';
(document.body || document.documentElement).appendChild(d);
