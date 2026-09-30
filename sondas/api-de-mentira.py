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
    '/api/actividad': {
        'actividad': [
            {'accion': 'Entró en la cuenta', 'creado': '2026-09-30T09:00:00Z', 'origen': 'iPhone'},
            {'accion': 'Cambió la contraseña', 'creado': '2026-09-27T12:00:00Z', 'origen': 'web'}
        ]
    }
}


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

    def do_POST(self):
        self._contesta()

    def do_DELETE(self):
        self._contesta()

    def log_message(self, *a):
        # Sin ruido: el log del banco ya es largo.
        pass


if __name__ == '__main__':
    HTTPServer(('127.0.0.1', 8099), Mano).serve_forever()
