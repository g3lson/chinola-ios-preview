#!/usr/bin/env python3
"""
¿SALE LA APP EN LAS CAPTURAS, O ES EL ESCRITORIO DEL IPHONE?

Las cinco capturas del banco fueron durante un tiempo el escritorio de iOS, con
sus iconos y su dock, y el banco decía «success». El lanzamiento fallaba —la app
se lanzaba por un identificador que ya no era el suyo—, un `|| true` se tragaba
el error, y la foto se sacaba igual: del escritorio.

Una foto que sale igual de bien cuando la app no arrancó no comprueba nada, y es
justo el caso que hay que detectar porque es el que pasaba.

CÓMO SE COMPRUEBA, sin adivinar nada:

Se saca una foto del escritorio ANTES de arrancar la app, `cap-0-escritorio.png`.
Después, cada captura tiene que PARECERSE POCO a esa. No hay que reconocer nada
ni saber qué pantalla es: si la app está delante, la imagen cambió; si no, es la
misma foto con el reloj un minuto más tarde.

El primer intento miraba cuántos tonos distintos había en una línea, suponiendo
que el escritorio sería liso. No lo es: el fondo de pantalla y los iconos dan
tantos tonos como una lista de movimientos, y la comprobación decía que todo
estaba bien con cinco fotos del escritorio delante. Comparar contra una foto del
escritorio de verdad no tiene esa duda.

Leer el PNG a mano —sin Pillow, que no está en el runner— es más corto que
instalarlo.
"""
import glob
import struct
import sys
import zlib

# Cuánto tiene que cambiar la imagen, de 0 a 255, para decir que hay otra cosa
# delante. Abrir la app cambia la pantalla ENTERA: sale por encima de 20. El
# reloj avanzando un minuto no llega ni a 1.
CAMBIO_MINIMO = 8.0
# En cuántas casillas se resume cada foto. Con 16x32 se ve la forma de la
# pantalla y no el detalle, que es lo que interesa: no se compara el contenido.
COLUMNAS, FILAS = 16, 32

ESCRITORIO = 'cap-0-escritorio.png'


def lee_png(ruta):
    """El PNG entero descomprimido, sin dependencias. Devuelve (ancho, alto, bytes)."""
    d = open(ruta, 'rb').read()
    i, ancho, alto, trozos = 8, 0, 0, b''
    while i + 8 <= len(d):
        largo = struct.unpack('>I', d[i:i + 4])[0]
        tipo = d[i + 4:i + 8]
        if tipo == b'IHDR':
            ancho, alto = struct.unpack('>II', d[i + 8:i + 16])
        elif tipo == b'IDAT':
            trozos += d[i + 8:i + 8 + largo]
        i += 12 + largo
    return ancho, alto, zlib.decompress(trozos)


def huella(ruta):
    """La foto resumida en una rejilla de grises. Es con lo que se comparan."""
    ancho, alto, raw = lee_png(ruta)
    # Cada fila del PNG lleva delante un byte con su filtro. Estas vienen sin
    # filtrar (filtro 0), que es lo que manda `simctl`.
    paso = ancho * 4 + 1
    out = []
    for fy in range(FILAS):
        y = min(alto - 1, int((fy + 0.5) * alto / FILAS))
        base = y * paso + 1
        for fx in range(COLUMNAS):
            x = min(ancho - 1, int((fx + 0.5) * ancho / COLUMNAS))
            p = base + x * 4
            out.append((raw[p] + raw[p + 1] + raw[p + 2]) / 3)
    return out


def distancia(a, b):
    return sum(abs(x - y) for x, y in zip(a, b)) / len(a)


def main():
    fotos = sorted(f for f in glob.glob('cap-*.png') if f != ESCRITORIO)
    if not fotos:
        print('no hay ninguna captura que mirar')
        return 1
    try:
        base = huella(ESCRITORIO)
    except FileNotFoundError:
        print('falta ' + ESCRITORIO + ': hay que fotografiar el escritorio ANTES de arrancar')
        return 1

    malas = []
    for f in fotos:
        d = distancia(base, huella(f))
        ok = d >= CAMBIO_MINIMO
        print(('  ok  ' if ok else ' VACÍA') + '  ' + f + '  cambio: ' + format(d, '.1f'))
        if not ok:
            malas.append(f)
    if malas:
        print()
        print('Estas capturas son el escritorio, no la app: ' + ', '.join(malas))
        print('Casi siempre significa que la app no arrancó, o arrancó y se cayó.')
        return 1
    print()
    print(str(len(fotos)) + ' capturas, todas con algo delante del escritorio')
    return 0


if __name__ == '__main__':
    sys.exit(main())
