#!/usr/bin/env python3
"""
UN SERVIDOR DE MENTIRA PARA QUE EL TELÉFONO TENGA CON QUIÉN HABLAR.

La siembra del banco reemplaza `window.fetch`, y eso solo intercepta las
llamadas de la WEB. El teléfono usa `URLSession` y salía a internet de verdad
con un vale inventado: le contestaban 401 y las tres subpantallas que hablan con
el servidor —«Mi cuenta», «Seguridad», «Dos pasos»— caían a la de la web.

Lo peor de eso no es que fallaran: es que NO fallaban. La pantalla salía igual de
bien, y solo se notaba contando las flechitas de las filas en una captura.

Esto contesta lo justo para que esas tres se puedan armar y fotografiar. No
pretende ser la API: pretende que lo que se mira sea lo que se cree que se mira.
"""
import json
from http.server import BaseHTTPRequestHandler, HTTPServer

# Lo que contesta cada ruta. Con datos DISTINGUIBLES a propósito: si una
# pantalla sale con «Ana Probeta» dentro, es que la armó el teléfono con esto.
RESPUESTAS = {
    '/api/yo': {
        'usuario': {'nombre': 'Ana Probeta', 'email': 'ana@banco.prueba', 'plan': 'pro', 'mfa': True}
    },
    '/api/mfa/metodos': {
        'usuario': {'mfa': True},
        'metodos': {
            'correo': {'activo': True},
            'totp': {'activo': False},
            # Telegram sin bot: es el tercer estado que casi se pierde al
            # rehacer la pantalla —«No disponible» no es lo mismo que «No»—.
            'telegram': {'activo': False, 'disponible': False},
            'respaldo': {'activo': True, 'quedan': 7}
        }
    },
    '/api/sesiones': {
        'sesiones': [
            {'id': 1, 'equipo': 'iPhone de Ana', 'actual': True,
             'creado': '2026-09-29T10:00:00Z', 'visto': '2026-09-30T09:00:00Z'},
            {'id': 2, 'equipo': 'MacBook Pro', 'actual': False,
             'creado': '2026-09-01T10:00:00Z', 'visto': '2026-09-28T18:00:00Z'}
        ]
    },
    # Dos libretas para que el teléfono tenga qué bajar, conciliar y subir. La
    # primera con un movimiento, para ver si lo que sube lleva lo de los DOS
    # lados; la segunda solo para que la lista no sea de una.
    '/api/libretas': {
        'libretas': [
            {'id': 'lb-uno', 'nombre': 'Personal', '__version': 3, '__rol': 'Dueño',
             'miembros': [{'email': 'ana@banco.prueba', 'rol': 'Dueño'}],
             'cuentas': [{'id': 1, 'nombre': 'Banco', 'saldo': 50000}],
             'tarjetas': [], 'categorias': [], 'presupuesto': {}, 'metas': [],
             'tx': [{'id': 'm-servidor', 'monto': 100, 'concepto': 'Del servidor'}]},
            {'id': 'lb-dos', 'nombre': 'Negocio', '__version': 1, '__rol': 'Dueño',
             'miembros': [{'email': 'ana@banco.prueba', 'rol': 'Dueño'}],
             'cuentas': [], 'tarjetas': [], 'categorias': [], 'presupuesto': {},
             'metas': [], 'tx': []}
        ]
    },
    '/api/actividad': {
        'actividad': [
            {'accion': 'Entró en la cuenta', 'creado': '2026-09-30T09:00:00Z', 'origen': 'iPhone'},
            {'accion': 'Cambió la contraseña', 'creado': '2026-09-27T12:00:00Z', 'origen': 'web'}
        ]
    }
}


# Lo que el teléfono ha subido, para que la sonda pueda mirarlo. En un servidor
# de verdad esto sería la base de datos.
RECIBIDO = []


class Mano(BaseHTTPRequestHandler):
    def _contesta(self):
        # Sin vale no se contesta: así el banco comprueba de paso que el
        # teléfono lo manda, que es la mitad de que esto funcione.
        if not (self.headers.get('authorization') or '').startswith('Bearer '):
            self.send_response(401)
            self.end_headers()
            self.wfile.write(b'{"error":"sin vale"}')
            return
        cuerpo = json.dumps(RESPUESTAS.get(self.path.split('?')[0], {})).encode()
        self.send_response(200)
        self.send_header('content-type', 'application/json')
        self.send_header('content-length', str(len(cuerpo)))
        self.end_headers()
        self.wfile.write(cuerpo)

    def do_GET(self):
        self._contesta()

    def do_PUT(self):
        """Subir las libretas.

        Contesta como el servidor de verdad en el caso que más importa: acepta
        las que van al día, rechaza «lb1» por SIN PERMISO —es la llave corta que
        chocaba, y el teléfono tiene que reconocerla como suya y renombrarla— y
        se guarda lo que llegó para que la sonda pueda mirarlo.
        """
        if not (self.headers.get('authorization') or '').startswith('Bearer '):
            self.send_response(401); self.end_headers()
            self.wfile.write(b'{"error":"sin vale"}')
            return
        largo = int(self.headers.get('content-length') or 0)
        try:
            pedido = json.loads(self.rfile.read(largo) or b'{}')
        except (ValueError, OSError):
            pedido = {}
        libretas = pedido.get('libretas') or []
        RECIBIDO.append(pedido)
        versiones, conflictos = {}, []
        for l in libretas:
            lid = l.get('id')
            if lid == 'lb1':
                # La llave corta: el servidor dice que la fila es de otro.
                conflictos.append({'id': lid, 'motivo': 'sin-permiso'})
            else:
                versiones[lid] = (l.get('__version') or 0) + 1
        cuerpo = json.dumps({'versiones': versiones, 'conflictos': conflictos,
                             'yo': 'ana@banco.prueba'}).encode()
        self.send_response(200)
        self.send_header('content-type', 'application/json')
        self.send_header('content-length', str(len(cuerpo)))
        self.end_headers()
        self.wfile.write(cuerpo)

    def do_POST(self):
        self._contesta()

    def do_DELETE(self):
        self._contesta()

    def log_message(self, *a):
        # Sin ruido: el log del banco ya es largo.
        pass


if __name__ == '__main__':
    HTTPServer(('127.0.0.1', 8099), Mano).serve_forever()
