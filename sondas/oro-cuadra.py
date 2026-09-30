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
import json
import re
import sys

# Cuánto se admite de diferencia en un número. Cero: son cuentas de dinero, y
# las dos implementaciones suman los mismos enteros. Un redondeo distinto ES el
# fallo que se busca.
TOLERANCIA = 0.0


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
        print('uso: oro-cuadra.py calculo-oro.json log-del-simulador.txt')
        return 2
    oro = json.load(open(sys.argv[1]))
    log = open(sys.argv[2], encoding='utf-8', errors='replace').read()

    m = re.findall(r'CNORO:\s*(\{.*)', log)
    if not m:
        print('El Swift no dijo nada. ¿Arrancó con CN_ORO=1? ¿Está el fichero en el paquete?')
        return 1
    try:
        hay = json.loads(m[-1].strip())
    except json.JSONDecodeError as e:
        print('No entiendo lo que dijo el Swift: ' + str(e))
        print(m[-1][:300])
        return 1
    if 'error' in hay:
        print('El Swift no pudo: ' + str(hay['error']))
        return 1

    fallos = []
    # Solo lo que el Swift dice haber calculado: el oro lleva apartados que aún
    # no tienen equivalente, y culparle por ellos sería ruido.
    for apartado in hay:
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
