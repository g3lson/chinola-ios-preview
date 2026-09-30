#!/usr/bin/env python3
"""
¿LO QUE CALCULÓ EL SWIFT ES LO MISMO QUE CALCULÓ LA WEB?

`test/calculo-oro.json` lleva tiempo en el repositorio y su propia nota dice qué
tenía que pasar: «Si cambia la web, se regenera y el Swift tiene que seguir
cuadrando». Lo que no había era nadie que lo comprobara. El oro lo GENERA la
web, una prueba en Node la ejecuta contra él, y el Swift se comprobaba leyendo
su texto con expresiones regulares.

Esa es la diferencia que importa: una expresión regular confirma que el código
dice lo que dice, no que la cuenta salga bien. Por ahí se colaron, en un solo
día, una serie con el nombre cambiado —así que la que eligieras no se dibujaba
nunca—, una forma de gráfico hecha como la otra, y cinco cifras que perdían el
signo, de modo que un mes en rojo salía en positivo. Las tres pruebas pasaban.

Esto es la prueba de contrato: el MISMO fichero de entrada pasa por las dos
implementaciones y tiene que salir lo mismo.

Se le pasa el fichero de oro y el log del simulador; busca la línea `CNORO:` que
escupe el Swift y compara los dos árboles, número a número.
"""
import base64
import gzip
import json
import re
import sys

# Cuánto se admite de diferencia en un número. Cero: son cuentas de dinero, y
# las dos implementaciones suman los mismos enteros. Un redondeo distinto ES el
# fallo que se busca.
TOLERANCIA = 0.0


def pegaLosTrozos(log):
    """El resultado viene PARTIDO, y hay que pegarlo antes de leerlo.

    Iba en una sola línea y funcionó mientras el oro tenía cinco apartados. Con
    los catorce, el JSON pasa de mil caracteres y `os_log` lo corta ahí: esto
    leía media línea y decía «no entiendo lo que dijo el Swift».

    Se devuelve None si no hay nada. Si hay trozos pero falta alguno, se dice
    CUÁL falta: pegar los que hay daría un JSON roto, o —peor— uno que se lee
    pero al que le faltan apartados, y entonces el banco compararía media verdad
    y diría que cuadra.
    """
    trozos = re.findall(r'CNORO (\d+)/(\d+) ([A-Za-z0-9+/=]+)', log)
    if not trozos:
        # Por si queda una app vieja con el formato de una sola línea.
        viejo = re.findall(r'CNORO:\s*(\{.*)', log)
        return viejo[-1].strip() if viejo else None
    total = int(trozos[-1][1])
    # El último arranque manda: el banco abre la app varias veces.
    partes = {}
    for i, n, t in trozos:
        if int(n) == total:
            partes[int(i)] = t
    faltan = [str(i) for i in range(1, total + 1) if i not in partes]
    if faltan:
        print('El Swift dijo ' + str(len(partes)) + ' trozos de ' + str(total)
              + ': falta(n) el ' + ', '.join(faltan))
        return None
    # VIENE EN BASE64: `log show` reescribe los caracteres no ASCII y las barras
    # invertidas —`\u2212` salía como `\134u2212`—, así que escaparlos tampoco
    # valía, porque el log escapaba el escape. En base64 no hay ninguno de los
    # dos y el log no toca nada.
    pegado = ''.join(partes[i] for i in range(1, total + 1)).strip()
    try:
        return base64.b64decode(pegado).decode('utf-8')
    except (ValueError, UnicodeDecodeError) as e:
        print('Los trozos no forman un base64 válido: ' + str(e))
        return None


def compara(camino, espera, hay, fallos):
    """Los dos árboles, rama a rama. `camino` es para poder decir DÓNDE falló."""
    if isinstance(espera, dict):
        if not isinstance(hay, dict):
            fallos.append(camino + ': la web dio un objeto y el Swift ' + tipo(hay))
            return
        for k in espera:
            if k not in hay:
                fallos.append(camino + '.' + k + ': el Swift no lo calculó')
                continue
            compara(camino + '.' + k, espera[k], hay[k], fallos)
        return
    if isinstance(espera, list):
        if not isinstance(hay, list):
            fallos.append(camino + ': la web dio una lista y el Swift ' + tipo(hay))
            return
        if len(espera) != len(hay):
            fallos.append(camino + ': la web dio ' + str(len(espera))
                          + ' y el Swift ' + str(len(hay)))
            return
        for i, (e, h) in enumerate(zip(espera, hay)):
            compara(camino + '[' + str(i) + ']', e, h, fallos)
        return
    if isinstance(espera, bool) or isinstance(hay, bool):
        if bool(espera) != bool(hay):
            fallos.append(camino + ': web ' + str(espera) + ' · Swift ' + str(hay))
        return
    if isinstance(espera, (int, float)):
        try:
            d = abs(float(espera) - float(hay))
        except (TypeError, ValueError):
            fallos.append(camino + ': web ' + str(espera) + ' · Swift ' + repr(hay))
            return
        if d > TOLERANCIA:
            fallos.append(camino + ': web ' + str(espera) + ' · Swift ' + str(hay))
        return
    if str(espera) != str(hay):
        fallos.append(camino + ': web «' + str(espera) + '» · Swift «' + str(hay) + '»')


def tipo(x):
    return {dict: 'un objeto', list: 'una lista', type(None): 'nada'}.get(type(x), 'un valor')


def main():
    if len(sys.argv) < 3:
        print('uso: oro-cuadra.py oro.json [otro-oro.json ...] log-del-simulador.txt')
        return 2
    # VARIOS FICHEROS DE ORO, uno por generador: los cálculos salen de la lógica
    # de la pantalla y la fusión de la capa de nube. Se juntan y se compara el
    # árbol entero de una vez.
    oro = {}
    for ruta in sys.argv[1:-1]:
        for k, v in json.load(open(ruta)).items():
            # `nota` es la explicación de cada fichero, no un apartado que se
            # compare: los dos la traen y no se pisan nada. El aviso es para los
            # apartados de verdad, donde uno taparía al otro EN SILENCIO y el
            # banco compararía media cosa diciendo que cuadra.
            if k == 'nota':
                continue
            if k in oro:
                print('Dos ficheros de oro traen «' + k + '»: uno taparía al otro')
                return 1
            oro[k] = v
    log = open(sys.argv[-1], encoding='utf-8', errors='replace').read()

    texto = pegaLosTrozos(log)
    if texto is None:
        print('El Swift no dijo nada. ¿Arrancó con CN_ORO=1? ¿Está el fichero en el paquete?')
        return 1
    try:
        hay = json.loads(texto)
    except json.JSONDecodeError as e:
        print('No entiendo lo que dijo el Swift: ' + str(e))
        print(texto[:300])
        return 1
    if 'error' in hay:
        print('El Swift no pudo: ' + str(hay['error']))
        return 1

    fallos = []
    # GZIP aparte: no se compara número a número, se DESCOMPRIME. Es la única
    # manera de saber si los bytes que el teléfono manda son un gzip de verdad y
    # no un DEFLATE pelado —que es lo que da Apple— con la etiqueta de gzip
    # puesta. El servidor rechazaría eso, y solo con las libretas grandes.
    if 'gzip' in hay and 'gzip' in oro:
        try:
            crudo = gzip.decompress(base64.b64decode(hay['gzip']['base64'])).decode('utf-8')
            if crudo != oro['gzip']['texto']:
                fallos.append('gzip: se descomprime pero sale otro texto')
            elif hay['gzip']['apretado'] >= hay['gzip']['crudo']:
                fallos.append('gzip: comprimido ocupa más que sin comprimir ('
                              + str(hay['gzip']['apretado']) + ' vs ' + str(hay['gzip']['crudo']) + ')')
            else:
                print('gzip: ' + str(hay['gzip']['crudo']) + ' → '
                      + str(hay['gzip']['apretado']) + ' bytes, y se descomprime')
        except (OSError, ValueError, KeyError) as e:
            fallos.append('gzip: no se puede descomprimir lo que manda el teléfono — ' + str(e))

    # LA VUELTA, tampoco contra el oro: contra sí misma. El teléfono empaqueta
    # la libreta, la vuelve a leer y la empaqueta otra vez. Un campo que se
    # escriba y no se lea —o al revés— se pierde en ese viaje, y se pierde sin
    # error: la primera vez que se toca esa tarjeta desaparecen sus cuatro
    # dígitos. Si el viaje no pierde nada, los dos paquetes son idénticos.
    if 'vuelta' in hay:
        antes = hay['vuelta'].get('antes')
        despues = hay['vuelta'].get('despues')
        if antes is None or despues is None:
            fallos.append('vuelta: el teléfono no pudo empaquetar su propia libreta')
        else:
            cuantos = len(fallos)
            compara('vuelta (ida→vuelta)', antes, despues, fallos)
            if len(fallos) == cuantos:
                print('vuelta: la libreta va y viene sin perder nada')

    # Solo lo que el Swift dice haber calculado: el oro lleva apartados que aún
    # no tienen equivalente, y culparle por ellos sería ruido.
    for apartado in hay:
        if apartado == 'gzip':
            continue
        if apartado == 'vuelta':
            continue
        if apartado in oro:
            compara(apartado, oro[apartado], hay[apartado], fallos)

    if fallos:
        print('LAS DOS IMPLEMENTACIONES NO DICEN LO MISMO:')
        for f in fallos:
            print('  · ' + f)
        return 1
    print('cuadra: ' + ', '.join(sorted(hay)))
    return 0


if __name__ == '__main__':
    sys.exit(main())
