#!/usr/bin/env bash
# EL ESPEJO: lo de la app, copiado al banco.
#
# El banco compila el Swift de Chinola en un runner de macOS porque aquí no hay
# compilador de Swift. Hasta ahora cada vuelta se copiaban los ficheros a mano,
# y olvidarse de uno cuesta una vuelta entera —veinte o cuarenta minutos— para
# enterarse de que el banco compiló la versión de antes.
#
# Esto copia lo que cambia: el Swift, los ficheros de oro y la siembra. Lo que
# no se copia —el proyecto de Xcode del banco, su configuración— es suyo a
# propósito y está explicado en LEEME-configuracion.md.
#
#     ./espejar.sh [ruta-de-chinola]
set -euo pipefail
APP="${1:-$HOME/Desktop/chinola}"
AQUI="$(cd "$(dirname "$0")" && pwd)"

[ -d "$APP/ios/App/App" ] || { echo "no encuentro la app en $APP"; exit 1; }

# EL SWIFT. Se copia TODO el que hay, no una lista: una lista escrita a mano se
# queda corta en cuanto nace un fichero nuevo, y el banco compila sin él —que es
# justo el caso en el que uno cree que la prueba pasó—.
copiados=0
for f in "$APP"/ios/App/App/*.swift; do
  n="$(basename "$f")"
  if ! cmp -s "$f" "$AQUI/hibrido/overlay/$n"; then
    cp "$f" "$AQUI/hibrido/overlay/$n"; echo "  swift · $n"; copiados=$((copiados + 1))
  fi
done

# Y LOS FICHEROS DE ORO, que son la otra mitad: el Swift se ejecuta contra ellos
# dentro del simulador y el banco compara los dos árboles.
#
# TODOS los que haya, como el Swift: aquí había una LISTA escrita a mano —la
# misma trampa que el comentario de arriba avisa para el Swift—, y el primer
# fichero de oro nuevo se habría quedado fuera sin que nadie dijera nada.
for o in "$APP"/test/*-oro.json; do
  [ -f "$o" ] || continue
  n="$(basename "$o")"
  if ! cmp -s "$o" "$AQUI/hibrido/$n"; then
    cp "$o" "$AQUI/hibrido/$n"; echo "  oro   · $n"; copiados=$((copiados + 1))
  fi
done

# Y LA WEB, que el banco monta por detrás de lo nativo. Se construye con
# `npm run build:nativo`, igual que la app, y se copia entera: media web vieja
# con el Swift nuevo da fallos que no existen en ningún sitio.
if [ "${CON_WEB:-1}" = "1" ]; then
  ( cd "$APP" && npm run build:nativo >/dev/null )
  rm -rf "$AQUI/hibrido/app-clasico"
  cp -R "$APP/nativo" "$AQUI/hibrido/app-clasico"
  echo "  web   · app-clasico"
fi

echo "espejo · $copiados fichero(s)"
