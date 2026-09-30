#!/usr/bin/env python3
"""
¿QUIÉN ARMÓ CADA SUBPANTALLA DE PERFIL: EL TELÉFONO O LA WEB?

Es la comprobación que faltaba, y la escribo después de que me mordiera.

«Libretas y permisos» estuvo armándose en la web mientras la versión nativa
existía, estaba probada y devolvía nil por no tener datos —la lista de libretas
solo se pedía al abrir el selector, y entrando por Perfil no la pedía nadie—. La
pantalla salía IGUAL DE BIEN. Lo único que la delató fue un chip de más en una
captura, mirada por casualidad.

Eso no se encuentra mirando fotos una por una. Así que el nativo dice en voz
alta quién armó cada una y esto lo lee.

Se le pasan los nombres que TIENEN que salir armados en el teléfono. Si alguno
sale armado en la web, es que le faltan datos o que nadie lo llama, y las dos
cosas significan lo mismo: código escrito y muerto.
"""
import re
import sys


def main():
    if len(sys.argv) < 3:
        print('uso: quien-armo-perfil.py log.txt seccion [seccion...]')
        return 2
    log = open(sys.argv[1], encoding='utf-8', errors='replace').read()
    esperadas = sys.argv[2:]

    # La ÚLTIMA vez que se armó cada una: al entrar se arma dos veces —con lo
    # que se sabía y con lo que llegó— y la que cuenta es la segunda.
    quien = {}
    for m in re.finditer(r'CNSECCION:\s+(\S+)\s+(nativa|web)', log):
        quien[m.group(1)] = m.group(2)

    if not quien:
        print('El nativo no dijo nada. ¿Arrancó con CN_CON=sonda?')
        return 1

    malas = []
    for s in esperadas:
        cual = quien.get(s)
        if cual is None:
            print(' (sin datos)  ' + s + ': no se llegó a abrir')
            continue
        print(('  ok  ' if cual == 'nativa' else ' WEB  ') + s)
        if cual != 'nativa':
            malas.append(s)

    if malas:
        print()
        print('Estas las armó la WEB teniendo versión nativa: ' + ', '.join(malas))
        print('O les faltan datos, o no las llama nadie. Las dos cosas son lo mismo:')
        print('código escrito, probado y muerto, con la pantalla saliendo igual de bien.')
        return 1
    print()
    print(str(len(esperadas)) + ' subpantallas, todas armadas en el teléfono')
    return 0


if __name__ == '__main__':
    sys.exit(main())
