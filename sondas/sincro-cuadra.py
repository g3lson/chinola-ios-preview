#!/usr/bin/env python3
"""
¿EL TELÉFONO SINCRONIZA ÉL SOLO?

La sincronización es lo que de verdad ata la app al webview: hoy la libreta la
baja, la concilia y la sube `src/nube.js`, y por eso el webview no se puede
quitar aunque todas las pantallas sean nativas.

`CNNube` hace ese mismo ciclo en Swift. Esto comprueba que lo haga de verdad
—contra el servidor de mentira del banco— y no solo que compile:

  · que BAJÓ las libretas del servidor;
  · que lo que SUBIÓ llevaba lo de los dos lados, no solo lo suyo;
  · y que la libreta de llave vieja —«lb1», la que chocaba con la de todo el
    mundo— la RESCATÓ con una llave nueva en vez de darla por perdida. Eso es lo
    que se veía como «una libreta que no deja escribir».

Se le pasa el log del simulador. El Swift escupe una línea `CNSINCRO {...}`.
"""
import base64
import json
import re
import sys


def main():
    if len(sys.argv) < 2:
        print('uso: sincro-cuadra.py log-del-simulador.txt')
        return 2
    log = open(sys.argv[1], encoding='utf-8', errors='replace').read()

    # ¿LLEGÓ LA WEB A PREGUNTAR quién sincroniza? Es lo único que prueba, desde
    # fuera, que el puente está enchufado. Si no pregunta, sigue hablando ella
    # con el servidor y todo lo nativo sería adorno.
    mando = re.findall(r'CNMANDO: (\S+) copia=(\S+) vale=(\S+)', log)
    if not mando:
        print('La web NO preguntó quién sincroniza: el puente no está enchufado.')
        return 1
    quien, copia, vale = mando[-1]
    print('manda: ' + quien + ' (copia=' + copia + ', vale=' + vale + ')')

    # En base64, por lo mismo que el fichero de oro: `log show` reescribe los
    # caracteres raros y las barras invertidas.
    m = re.findall(r'CNSINCRO ([A-Za-z0-9+/=]+)', log)
    if not m:
        print('El teléfono no sincronizó nada. ¿Arrancó con CN_SINCRO=1?')
        return 1
    try:
        r = json.loads(base64.b64decode(m[-1].strip()).decode('utf-8'))
    except (ValueError, UnicodeDecodeError) as e:
        print('No entiendo lo que dijo el Swift: ' + str(e))
        print(m[-1][:300])
        return 1
    if 'error' in r:
        print('El teléfono no pudo sincronizar: ' + str(r['error']))
        return 1

    fallos = []
    if r.get('bajadas') != ['lb-dos', 'lb-uno']:
        fallos.append('no bajó las dos libretas del servidor: ' + str(r.get('bajadas')))
    # La de llave vieja tiene que salir rescatada, con llave nueva y larga.
    renombradas = r.get('renombradas') or []
    if len(renombradas) != 1 or renombradas[0].get('de') != 'lb1':
        fallos.append('no rescató la libreta de llave vieja: ' + str(renombradas))
    elif not str(renombradas[0].get('a', '')).startswith('lb-') or len(renombradas[0]['a']) < 20:
        fallos.append('la renombró con una llave que vuelve a poder chocar: '
                      + str(renombradas[0].get('a')))
    # Y no puede darla por perdida: es el fallo que se arregló.
    if 'lb1' in (r.get('sinPermiso') or []):
        fallos.append('dio por perdida la libreta vieja en vez de rescatarla')
    if r.get('perdidas'):
        fallos.append('se quedó sin guardar: ' + str(r['perdidas']))
    # LO QUE DE VERDAD IMPORTA: la libreta que el servidor rechazó por atrasada
    # tiene que volver con lo de los DOS aparatos. Si se queda solo con lo suyo,
    # el ciclo «termina bien» y por el camino ha borrado lo que anotó el otro.
    dentro = (r.get('movimientos') or {}).get('lb-uno')
    if dentro is None:
        fallos.append('no concilió la libreta que el servidor rechazó por atrasada')
    else:
        for cual, dequien in [('m-servidor', 'del servidor'), ('m-local', 'de este teléfono')]:
            if cual not in dentro:
                fallos.append('al conciliar perdió el movimiento ' + dequien
                              + ': quedó ' + str(dentro))

    if fallos:
        print('EL TELÉFONO NO SINCRONIZA COMO DEBE:')
        for f in fallos:
            print('  · ' + f)
        return 1
    print('sincroniza: bajó ' + ', '.join(r['bajadas'])
          + ' · rescató ' + renombradas[0]['de'] + ' → ' + renombradas[0]['a'][:12] + '…')
    return 0


if __name__ == '__main__':
    sys.exit(main())
