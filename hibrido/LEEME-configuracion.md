# Por qué el `capacitor.config.json` del banco es el de la app menos una línea

Es el mismo fichero que usa la app, a propósito: el banco traía uno mínimo, de
juguete, y por eso no veía el fallo que de verdad tenía el usuario —la app lleva
`launchAutoHide` en la pantalla de arranque y el banco no, así que en el banco el
arranque se quitaba solo y todo parecía ir bien mientras en el teléfono se
quedaba puesto, crema y liso, tapando la app entera—. Un banco que no reproduce
la configuración no reproduce nada.

La ÚNICA diferencia es `webDir`:

- La app sirve desde `nativo/`.
- El banco monta la web en `www/`.

Copiándolo tal cual, Capacitor no encuentra los ficheros y no llega ni a
compilar: «Could not find the web assets directory: ./nativo». Ya pasó.

`hoy.yml` y `real.yml` además lo fuerzan a `www` después de copiarlo, y
comprueban que quedó puesto. Es de más, y es a propósito: el día que alguien
vuelva a traer el fichero de la app entero, el banco sigue compilando.
