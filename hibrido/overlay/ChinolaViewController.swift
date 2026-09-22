import UIKit
import SwiftUI
import Capacitor
import UniformTypeIdentifiers

/**
 * Base: la WEB de Capacitor. Encima, lo NATIVO:
 *  - La barra de menú (Liquid Glass).
 *  - La pestaña Movimientos (CNMovs).
 *  - Todas las HOJAS y DETALLES: nuevo movimiento, editar, detalles de cuenta /
 *    tarjeta / préstamo / meta, agregar (cuenta/tarjeta/préstamo), nueva meta,
 *    abono, aporte, pago de tarjeta y transferencia.
 *
 * Los datos se LEEN del webview (`traerDatos`), que es a prueba de fallos; el
 * guardado reusa la lógica de la web (`window.__chinola…`), así el dinero se
 * calcula exactamente igual que siempre.
 */
class ChinolaViewController: CAPBridgeViewController {
    let menuEstado = CNMenuEstado.shared
    let datos = CNDatos.shared
    private let nativo = NativoPlugin()
    private let barra = CNBarraNativa()
    private var contenedorNativo: UIView?

    // Pestañas ya nativas.
    private let nativas: Set<String> = ["resumen", "movs", "cuentas", "plan", "perfil"]

    override func capacitorDidLoad() {
        nativo.store = datos
        nativo.menuEstado = menuEstado
        bridge?.registerPluginInstance(CobroPlugin())
        bridge?.registerPluginInstance(nativo)
    }

    /// El teléfono cambió de claro a oscuro (o al revés).
    ///
    /// El webview no siempre vuelve a evaluar `prefers-color-scheme` al volver
    /// del segundo plano, y había que reiniciar la app para ver el cambio. Se
    /// le dice aquí, en cuanto pasa, y también al volver a primer plano.
    override func traitCollectionDidChange(_ previo: UITraitCollection?) {
        super.traitCollectionDidChange(previo)
        guard traitCollection.userInterfaceStyle != previo?.userInterfaceStyle else { return }
        avisarDelModo()
    }
    /// El modo del teléfono DE VERDAD: el de la pantalla.
    ///
    /// La ventana no vale: la app le fuerza el estilo al del tema puesto (para
    /// que las alertas y hojas del sistema vayan a juego), así que su trait
    /// siempre coincide con el tema y nunca avisa de nada. Era justo por eso
    /// por lo que había que reiniciar: la ventana —y con ella el webview y su
    /// `prefers-color-scheme`— no veían el cambio del teléfono.
    private var sistemaOscuro: Bool {
        UIScreen.main.traitCollection.userInterfaceStyle == .dark
    }
    /// Y por si ningún aviso llega: cada dos segundos se comprueba que la
    /// paleta puesta sea la del modo del teléfono. Es una comparación, no
    /// cuesta nada, y cierra la puerta a «hay que reiniciar».
    private var vigiaModo: Timer?
    private func vigilarModo() {
        vigiaModo?.invalidate()
        vigiaModo = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            guard let s = self, CNC.pareja.oscuro != nil else { return }
            if s.sistemaOscuro != CNC.tema.oscuro { s.avisarDelModo() }
        }
    }
    @objc private func avisarDelModo() {
        let oscuro = sistemaOscuro
        // PRIMERO se pinta, con la paleta que la web ya mandó. Esperar a que la
        // web reaccione era lo que obligaba a reiniciar la app: el webview no
        // siempre vuelve a mirar `prefers-color-scheme`, y si no reacciona, no
        // hay tema nuevo que mandar.
        if datos.aplicarModo(oscuro: oscuro) {
            barra.pintar(activa: menuEstado.activa, titulos: menuEstado.titulos)
            contenedorNativo?.backgroundColor = UIColor(CNC.scr)
            view.backgroundColor = UIColor(CNC.scr)
        }
        // Y se le dice a la web, que también tiene que cambiar lo suyo.
        eval("window.__chinolaSistemaOscuro && window.__chinolaSistemaOscuro(\(oscuro))")
        for t in [0.3, 0.9, 1.8] {
            DispatchQueue.main.asyncAfter(deadline: .now() + t) { [weak self] in self?.traerTema() }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // En iOS 17 y más, `traitCollectionDidChange` ya no se llama: hay que
        // apuntarse al cambio. Sin esto, poner el teléfono en oscuro no movía
        // la app hasta reiniciarla.
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (vc: ChinolaViewController, _) in
                vc.avisarDelModo()
            }
        }
        // Las tipografías de la marca, antes de pintar nada.
        CNFuentes.registrar()
        // Y el tema de la última vez: la primera pantalla sale ya con sus
        // colores, su letra y su moneda.
        datos.temaGuardado()
        conectarAcciones()
        NotificationCenter.default.addObserver(self, selector: #selector(avisarDelModo),
                                               name: UIApplication.didBecomeActiveNotification, object: nil)
        montarOrilla()

        menuEstado.alTocar = { [weak self] id in
            guard let self = self else { return }
            self.menuEstado.activa = id
            self.barra.pintar(activa: id, titulos: self.menuEstado.titulos)
            // A la web SIEMPRE, aunque la pantalla sea nativa: es ella la que
            // calcula el modelo, y solo lo calcula de la vista en la que está.
            // Sin esto, entrar al Resumen nativo viniendo de otra pestaña
            // dejaba el panel vacío, porque la web seguía en la otra.
            self.eval("window.__chinolaMenu && window.__chinolaMenu('\(id)')")
            if self.nativas.contains(id) {
                self.mostrarNativo(id)
                self.refrescarPantalla(id)
            } else {
                self.volviendo = false
                self.mostrarWeb()
            }
        }

        montarBarra()
        vigilarModo()
        // Lo NATIVO desde el primer fotograma. Sin esto, al abrir se veía el
        // tablero de la WEB hasta que se tocaba una pestaña: la app empezaba
        // enseñando justo lo que ya no usa.
        mostrarNativo(menuEstado.activa)
        montarCortina()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in self?.traerDatos() }
        // La puerta (bienvenida, acceso, nombre, plan) también es nativa.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in self?.mirarPuerta() }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        barra.ajustar()
    }

    // MARK: acciones de las pantallas nativas
    private func conectarAcciones() {
        // Formularios y detalles: NATIVOS (se presentan encima).
        datos.onNuevoMov = { [weak self] in guard let s = self else { return }
            s.presentar(AnyView(CNNuevoMov(datos: s.datos, onClose: { s.cerrar() }))) }
        datos.onDetalleMov = { [weak self] id in
            guard let s = self else { return }
            s.traerMov(id)
            s.presentar(AnyView(CNDetalleMov(datos: s.datos, movId: id, onClose: { s.cerrar() })))
        }
        datos.onMovAccion = { [weak self] tipo in
            guard let s = self else { return }
            s.eval("window.__chinolaMovAccion && window.__chinolaMovAccion(\(s.comillas(tipo)))")
            s.refrescarPronto()
            if tipo == "duplicar" { s.cerrar() }
        }
        datos.onCuentasAccion = { [weak self] tipo, i in
            guard let s = self else { return }
            if tipo == "cuenta" || tipo == "tarjeta" || tipo == "prestamo" {
                // Los detalles ya son nativos: no hace falta pasar por la web.
                let lb = s.datos.libreta
                if tipo == "cuenta", i < lb.cuentas.count { s.datos.onAbrirCuenta(lb.cuentas[i].id); return }
                if tipo == "tarjeta", i < lb.tarjetas.count { s.datos.onAbrirTarjeta(lb.tarjetas[i].id); return }
                if tipo == "prestamo", i < lb.prestamos.count { s.datos.onAbrirPrestamo(lb.prestamos[i].id); return }
                return
            }
            s.eval("window.__chinolaCuentasAccion && window.__chinolaCuentasAccion(\(s.comillas(tipo)),\(i))")
            s.refrescarPronto()
        }
        // Lo que sale al deslizar una fila: marcar la cuenta de siempre,
        // editar o eliminar. Cada una es la MISMA función de la web.
        datos.onFilaAccion = { [weak self] i, donde in
            guard let s = self else { return }
            s.eval("window.__chinolaFilaAccion && window.__chinolaFilaAccion(\(i),\(s.comillas(donde)))")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                // Si lo que se abrió es una hoja (editar), se dibuja nativa.
                s.webTemporal()
                s.traerCuentas(); s.traerPlan(); s.traerDatos(intentos: 3)
            }
        }
        datos.onAbrirCuenta = { [weak self] id in self?.mostrarDetalle("cuenta", "\(id)") }
        datos.onAbrirTarjeta = { [weak self] id in self?.mostrarDetalle("tarjeta", "\(id)") }
        datos.onAbrirPrestamo = { [weak self] id in self?.mostrarDetalle("prestamo", "\(id)") }
        datos.onAbrirMeta = { [weak self] id in self?.mostrarDetalle("meta", "\(id)") }
        datos.onDetalleAccion = { [weak self] tipo, i in
            guard let s = self else { return }
            // El chip se marca AQUÍ, sin esperar a la web: tocar un periodo y
            // que no pase nada durante medio segundo es lo que hace que la
            // pantalla se sienta lenta.
            if tipo == "chip" {
                CNDatos.shared.marcarChip(i)
                s.eval("window.__chinolaDetalleAccion && window.__chinolaDetalleAccion(\(s.comillas(tipo)),\(i))")
                for t in [0.12, 0.45] {
                    DispatchQueue.main.asyncAfter(deadline: .now() + t) { s.refrescarDetalle() }
                }
                return
            }
            s.eval("window.__chinolaDetalleAccion && window.__chinolaDetalleAccion(\(s.comillas(tipo)),\(i))")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                // Cambiar de periodo repinta la misma pantalla. Un botón abre
                // una hoja: se dibuja NATIVA y encima del detalle, que se queda
                // donde estaba. Antes se cerraba el detalle y se enseñaba la
                // web de debajo: la pantalla cambiaba de cara y volvía sola al
                // cerrar la hoja.
                if tipo == "chip" { s.refrescarDetalle(); return }
                s.webTemporal(alIrALaWeb: { s.cerrarDetalle() })
            }
        }
        // El Plan: cambiar de pestaña repinta; ver una categoría o una meta
        // abre su detalle NATIVO; crear una sigue en la web.
        datos.onPlanAccion = { [weak self] tipo, i in
            guard let s = self else { return }
            if tipo == "categoria", let f = CNDatos.shared.plan?.filas.first(where: { $0.indice == i }) {
                s.eval("window.__chinolaPlanAccion && window.__chinolaPlanAccion(\(s.comillas(tipo)),\(i))")
                s.mostrarDetalle("categoria", f.nombre)
                return
            }
            if tipo == "meta", let g = CNDatos.shared.plan?.metas.first(where: { $0.indice == i }) {
                s.mostrarDetalle("meta", "\(g.idm)")
                return
            }
            s.eval("window.__chinolaPlanAccion && window.__chinolaPlanAccion(\(s.comillas(tipo)),\(i))")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                s.traerPlan(intentos: 6)
                if tipo != "tab" { s.webTemporal() }
            }
        }
        datos.onAgregar = { [weak self] in guard let s = self else { return }
            s.presentar(AnyView(CNAgregar(datos: s.datos, onClose: { s.cerrar() }))) }
        datos.onNuevaMeta = { [weak self] in guard let s = self else { return }
            s.presentar(AnyView(CNFormMeta(datos: s.datos, onClose: { s.cerrar() }))) }
        datos.onTendencia = { [weak self] in guard let s = self else { return }
            s.presentar(AnyView(CNTendencia(libreta: s.datos.libreta, onClose: { s.cerrar() }))) }

        datos.onAccion = { [weak self] tipo, id in
            guard let s = self else { return }
            let lb = s.datos.libreta
            switch tipo {
            case "nuevo":
                s.presentar(AnyView(CNNuevoMov(datos: s.datos, onClose: { s.cerrar() })))
            case "abono":
                let p = lb.prestamos.first { "\($0.id)" == id }
                s.presentar(AnyView(CNMontoHoja(datos: s.datos, tipo: "abono", extra: ["id": p?.id ?? (Int(id) ?? 0), "nombre": p?.nombre ?? ""], onClose: { s.cerrar() })))
            case "aporte":
                let m = lb.metas.first { "\($0.id)" == id }
                s.presentar(AnyView(CNMontoHoja(datos: s.datos, tipo: "aporte", extra: ["id": m?.id ?? (Int(id) ?? 0), "nombre": m?.nombre ?? ""], onClose: { s.cerrar() })))
            case "pagoTarjeta":
                let t = lb.tarjetas.first { "\($0.id)" == id }
                s.presentar(AnyView(CNMontoHoja(datos: s.datos, tipo: "pagoTarjeta", extra: ["id": t?.id ?? (Int(id) ?? 0), "nombre": t?.nombre ?? "", "saldo": t?.saldo ?? 0], onClose: { s.cerrar() })))
            case "editarMov":
                if let m = lb.tx.first(where: { $0.id == id }) {
                    s.presentar(AnyView(CNNuevoMov(datos: s.datos, onClose: { s.cerrar() }, editar: m)))
                }
            case "transferir":
                s.presentar(AnyView(CNFormTransferencia(datos: s.datos, origen: "cuenta:\(id)", onClose: { s.cerrar() })))
            default:
                s.webTemporal(); s.eval("window.__chinolaAccion && window.__chinolaAccion('\(tipo)','\(id)')")
            }
        }

        // Guardado: reusa la lógica de la web y vuelve a leer los datos.
        datos.onGuardarHoja = { [weak self] tipo, form, extra in
            guard let s = self else { return }
            var payload: [String: Any] = ["tipo": tipo, "form": form]
            if let e = extra { payload["extra"] = e }
            s.aWeb("window.__chinolaGuardarHoja", payload)
        }
        datos.onCrearMov = { [weak self] dict in self?.aWeb("window.__chinolaCrearMov", dict) }
        datos.onInvitar = { [weak self] dict in
            guard let s = self else { return }
            s.aWeb("window.__chinolaInvitar", dict)
            // La lista de miembros cambia en cuanto el servidor responde.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                if let id = CNDatos.shared.seccion?.id { s.traerSeccion(id) }
            }
        }
        datos.onCrearLibreta = { [weak self] dict in
            guard let s = self else { return }
            s.aWeb("window.__chinolaCrearLibreta", dict)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                s.traerDatos(intentos: 3); s.traerTema(); s.traerResumen(intentos: 4)
            }
        }
        datos.onMes = { [weak self] dir in
            self?.eval("window.__chinolaMes && window.__chinolaMes(\(dir))")
            self?.refrescarPronto()
        }
        datos.onEmpezar = { [weak self] in self?.webTemporal(); self?.eval("window.__chinolaEmpezar && window.__chinolaEmpezar()") }
        datos.onEditarPanel = { [weak self] in self?.webTemporal(); self?.eval("window.__chinolaEditarPanel && window.__chinolaEditarPanel()") }
        // Perfil: la fila se dispara por su sitio en la lista y, si abre una
        // sección, se enseña la web (esas pantallas siguen allí).
        datos.onAjuste = { [weak self] g, f, valor in
            guard let s = self else { return }
            if let v = valor {
                s.eval("window.__chinolaAjuste && window.__chinolaAjuste(\(g),\(f),\(s.comillas(v)))")
            } else {
                s.webTemporal()
                s.eval("window.__chinolaAjuste && window.__chinolaAjuste(\(g),\(f))")
            }
            s.refrescarPronto()
        }
        // Subpantallas del perfil: se le pide el modelo a la web y se dibuja
        // aquí. La web no cambia de pantalla; solo entrega los datos.
        datos.onAbrirSeccion = { [weak self] id in
            guard let s = self else { return }
            // Una «sección» que empieza por «hoja:» no es una pantalla de
            // ajustes: es un formulario nativo. Hoy solo invitar.
            if id == "importar" { s.pedirCsv(); return }
            // Editar una libreta: la web la deja preparada y el mismo
            // formulario de «nueva» se abre con sus valores.
            if id.hasPrefix("hoja:libreta:") {
                let lid = String(id.dropFirst("hoja:libreta:".count))
                s.eval("window.__chinolaEditarLibreta && window.__chinolaEditarLibreta(\(s.comillas(lid)))")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    s.bridge?.webView?.evaluateJavaScript("(window.__chinolaLibretaNuevaJSON && window.__chinolaLibretaNuevaJSON()) || ''") { res, _ in
                        if let json = res as? String, json.count > 2 { CNDatos.shared.cargarLibretaNueva(json: json) }
                        s.presentar(AnyView(CNFormLibreta(datos: s.datos, onClose: {
                            // Al cerrar (guardado o no) la web suelta la edición y
                            // la pantalla de la libreta se repinta con lo nuevo.
                            s.eval("window.__chinolaEditarLibreta && window.__chinolaEditarLibreta('')")
                            s.cerrar()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                if let sid = CNDatos.shared.seccion?.id { s.traerSeccion(sid) }
                                s.traerDatos(intentos: 2)
                            }
                        })))
                    }
                }
                return
            }
            if id.hasPrefix("hoja:invitar:") {
                let lid = String(id.dropFirst("hoja:invitar:".count))
                s.bridge?.webView?.evaluateJavaScript("(window.__chinolaInvitarJSON && window.__chinolaInvitarJSON()) || ''") { res, _ in
                    if let json = res as? String, json.count > 2 { CNDatos.shared.cargarInvitar(json: json) }
                    s.presentar(AnyView(CNFormInvitar(datos: s.datos, libreta: lid, onClose: { s.cerrar() })))
                }
                return
            }
            s.traerSeccion(id)
        }
        datos.onSeccionAccion = { [weak self] i, valor in
            guard let s = self, let id = CNDatos.shared.seccion?.id else { return }
            // Con el id de la sección: la web guarda las acciones por sección
            // y así el número apunta a la fila que se tocó, no a la de la
            // última sección que se pidió.
            if let v = valor {
                s.eval("window.__chinolaSeccionAccion && window.__chinolaSeccionAccion(\(i),\(s.comillas(v)),\(s.comillas(id)))")
            } else {
                s.eval("window.__chinolaSeccionAccion && window.__chinolaSeccionAccion(\(i),undefined,\(s.comillas(id)))")
            }
            // Algunas acciones abren una hoja de la web (cambiar la clave, crear
            // una libreta…): se enseña la web y se cierra lo nativo.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                s.bridge?.webView?.evaluateJavaScript("!!(window.__chinolaHayHoja && window.__chinolaHayHoja())") { r, _ in
                    if (r as? Bool) == true {
                        // La sección se queda debajo: si lo que se abrió es una
                        // hoja, se dibuja nativa encima y al guardar se vuelve.
                        s.webTemporal()
                    } else {
                        s.traerSeccion(id)
                        s.traerAjustes(); s.traerTema()
                        // «Mi plan» cambia de paso sin abrir hoja: es la puerta.
                        s.mirarPuerta(intentos: 2)
                    }
                }
            }
        }
        datos.onHojaCampo = { [weak self] i, valor, que in
            guard let s = self else { return }
            s.eval("window.__chinolaHojaCampo && window.__chinolaHojaCampo(\(i),\(s.comillas(valor)),\(s.comillas(que)))")
            // Al elegir color, icono u opción la hoja cambia de aspecto; al
            // escribir no hace falta repintar (el campo ya lleva lo escrito).
            if !que.isEmpty || valor.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { s.refrescarHojaWeb() }
            }
        }
        datos.onHojaEnviar = { [weak self] in
            guard let s = self else { return }
            s.eval("window.__chinolaHojaEnviar && window.__chinolaHojaEnviar()")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { s.refrescarHojaWeb() }
        }
        datos.onPlan = { [weak self] in self?.webTemporal(); self?.eval("window.__chinolaPlan && window.__chinolaPlan()") }
        datos.onPanel = { [weak self] op, id, valor in
            self?.aWeb("window.__chinolaPanel", ["op": op, "id": id, "valor": valor])
        }
        // El periodo tiene su propia hoja NATIVA: se abre en la web (para que
        // su estado sea el de siempre) y se dibuja aquí.
        datos.onCalendario = { [weak self] in
            guard let s = self else { return }
            s.eval("window.__chinolaCalendario && window.__chinolaCalendario()")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { s.abrirPeriodo() }
        }
        datos.onPeriodo = { [weak self] tipo, i in
            guard let s = self else { return }
            s.eval("window.__chinolaPeriodo && window.__chinolaPeriodo(\(s.comillas(tipo)),\(i))")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                if tipo == "aplicar" || tipo == "cerrar" {
                    s.cerrarPeriodo()
                } else {
                    s.refrescarPeriodo()
                }
            }
        }
        datos.onMesTira = { [weak self] i in
            guard let s = self else { return }
            s.eval("window.__chinolaMesTira && window.__chinolaMesTira(\(i))")
            s.refrescarPronto()
            // «Rango…» no cambia de mes: abre el calendario. Si la web lo abrió,
            // se dibuja la hoja NATIVA del periodo. Antes no pasaba nada.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                s.bridge?.webView?.evaluateJavaScript("(window.__chinolaPeriodoJSON && window.__chinolaPeriodoJSON()) || ''") { res, _ in
                    guard let json = res as? String, json.count > 2 else { return }
                    CNDatos.shared.cargarPeriodo(json: json)
                    s.abrirPeriodo()
                }
            }
        }
        datos.onPlegar = { [weak self] in
            self?.eval("window.__chinolaPliega && window.__chinolaPliega()")
            self?.refrescarPronto()
        }
        datos.onVerPresupuesto = { [weak self] in
            guard let s = self else { return }
            s.menuEstado.activa = "plan"; s.barra.pintar(activa: "plan", titulos: s.menuEstado.titulos)
            s.mostrarNativo("plan")
        }
        datos.onLimiteCategoria = { [weak self] nombre, limite in
            self?.aWeb("window.__chinolaLimiteCategoria", ["nombre": nombre, "limite": limite])
        }
        datos.onEditarMov = { [weak self] dict in self?.aWeb("window.__chinolaEditarMov", dict) }
        datos.onBorrarMov = { [weak self] id in
            self?.eval("window.__chinolaBorrarMov && window.__chinolaBorrarMov('\(id)')")
            self?.refrescarPronto()
        }
        // Lo que aún vive en la web.
        datos.onNuevaCategoria = { [weak self] in self?.webTemporal(); self?.eval("window.__chinolaNuevaCategoria && window.__chinolaNuevaCategoria()") }
        datos.onPerfil = { [weak self] id in self?.webTemporal(); self?.eval("window.__chinolaPerfil && window.__chinolaPerfil('\(id)')") }
        // El selector de libretas ya no enseña la web por detrás: se pide la
        // lista y se dibuja en una hoja nativa encima de la pantalla que había.
        datos.onSelector = { [weak self] in
            guard let s = self else { return }
            s.abrirLibretas()
            // Red de seguridad: si la lista no llegó (la web aún no publicó el
            // puente), se hace lo de siempre en vez de quedarse en nada.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                guard s.libretasVC == nil || CNDatos.shared.libretas == nil else { return }
                s.cerrarLibretas()
                s.eval("window.__chinolaSelector && window.__chinolaSelector()")
                s.webTemporal()
            }
        }
        datos.onLibreta = { [weak self] que, i in
            guard let s = self else { return }
            if que == "nueva" {
                // Nueva libreta, en nativo: se cierra el selector y se abre la
                // hoja con los tipos, colores e iconos que manda la web.
                s.eval("window.__chinolaLibretaAccion && window.__chinolaLibretaAccion('nueva',0)")
                s.cerrarLibretas()
                s.bridge?.webView?.evaluateJavaScript("(window.__chinolaLibretaNuevaJSON && window.__chinolaLibretaNuevaJSON()) || ''") { res, _ in
                    if let json = res as? String, json.count > 2 { CNDatos.shared.cargarLibretaNueva(json: json) }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        s.presentar(AnyView(CNFormLibreta(datos: s.datos, onClose: { s.cerrar() })))
                    }
                }
                return
            }
            s.eval("window.__chinolaLibretaAccion && window.__chinolaLibretaAccion(\(s.comillas(que)),\(i))")
            if que == "elegir" {
                s.cerrarLibretas()
                s.traerDatos(intentos: 3); s.traerTema()
                s.traerResumen(intentos: 4); s.traerCuentas(); s.traerPlan()
            } else {
                s.cerrarLibretas()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    s.mostrarNativo("perfil")
                    s.traerSeccion("libretas")
                }
            }
        }
    }

    /// Llama a una función de la web con un objeto y luego relee los datos.
    private func aWeb(_ fn: String, _ obj: [String: Any]) {
        guard let d = try? JSONSerialization.data(withJSONObject: obj),
              let json = String(data: d, encoding: .utf8) else { return }
        eval("\(fn) && \(fn)(\(json))")
        refrescarPronto()
    }
    /// El dibujo de Chino y los pagos que vienen, para el icono del perfil.
    fileprivate func traerMascota() {
        bridge?.webView?.evaluateJavaScript("(window.__chinolaMascotaJSON && window.__chinolaMascotaJSON()) || ''") { [weak self] res, _ in
            guard let json = res as? String, json.count > 2 else { return }
            CNDatos.shared.cargarMascota(json: json)
            // Y al menú: el icono de Perfil es Chino.
            self?.barra.ponerChinolo(CNDatos.shared.mascota?.chinolo ?? "")
        }
    }

    /// El modelo de UNA pantalla, en cuanto se entra en ella. La web tarda un
    /// pintado en tener listo lo suyo, así que se pide dos veces.
    private func refrescarPantalla(_ id: String) {
        let pedir = { [weak self] in
            guard let s = self else { return }
            switch id {
            case "resumen": s.traerResumen(intentos: 6)
            case "cuentas": s.traerCuentas()
            case "plan": s.traerPlan(intentos: 6)
            case "perfil": s.traerAjustes(); s.traerMascota()
            default: s.traerDatos(intentos: 3)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12, execute: pedir)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: pedir)
    }

    private func refrescarPronto() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            self?.traerDatos(intentos: 3)
            self?.traerResumen(intentos: 4)
            self?.traerAjustes()
            self?.traerCuentas()
            self?.traerPlan()
            self?.traerMascota()
            // ¿Se cerró la sesión? La web lo sabe; lo nativo tiene que
            // enterarse o se queda con pantallas vacías y sin salida. Pasó:
            // cerrar sesión dejaba la app por dentro, sin puerta.
            self?.mirarPuerta(intentos: 1)
        }
    }

    /// Un texto listo para meter en una llamada de JavaScript.
    private func comillas(_ t: String) -> String {
        (try? JSONSerialization.data(withJSONObject: [t])).flatMap {
            String(data: $0, encoding: .utf8).map { String($0.dropFirst().dropLast()) }
        } ?? "\"\""
    }

    private func eval(_ js: String) {
        bridge?.webView?.evaluateJavaScript(js, completionHandler: nil)
    }

    /// LEE los datos directamente del webview (sin plugin). El empuje por el
    /// plugin puede perderse en silencio; esto los trae y los carga seguro.
    private func traerDatos(intentos: Int = 8) {
        bridge?.webView?.evaluateJavaScript("(window.__chinolaDatosJSON && window.__chinolaDatosJSON()) || ''") { [weak self] res, _ in
            guard let self = self else { return }
            let json = (res as? String) ?? ""
            if json.count > 2, let l = CNLibreta.desde(json: json) {
                CNDatos.shared.libreta = l
                self.bridge?.webView?.evaluateJavaScript("(window.__chinolaPerfilJSON && window.__chinolaPerfilJSON()) || ''") { p, _ in
                    if let ps = p as? String, ps.count > 2 { CNDatos.shared.cargarPerfil(json: ps) }
                }
                self.quitarCortina()
                self.traerTema()
                self.traerResumen(intentos: 6)
                self.traerAjustes()
                self.traerCuentas()
                self.traerPlan()
                // El dibujo de Chino tarda un poco en estar en PNG: se pide
                // ahora y otra vez un segundo después.
                self.traerMascota()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { self.traerMascota() }
                return
            }
            guard intentos > 1 else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { self.traerDatos(intentos: intentos - 1) }
        }
    }

    /// El TEMA que tiene puesto el usuario, leído del webview. Al llegar, la
    /// barra y las pantallas nativas se repintan con esos colores.
    private func traerTema() {
        bridge?.webView?.evaluateJavaScript("(window.__chinolaTemaJSON && window.__chinolaTemaJSON()) || ''") { [weak self] res, _ in
            guard let self = self, let json = res as? String, json.count > 2 else { return }
            CNDatos.shared.cargarTema(json: json)
            self.barra.pintar(activa: self.menuEstado.activa, titulos: self.menuEstado.titulos)
            // Claro u oscuro de sistema según el tema: así el vidrio, las hojas
            // y los menús del sistema acompañan a la paleta de la app.
            self.view.window?.overrideUserInterfaceStyle = CNC.tema.oscuro ? .dark : .light
            self.contenedorNativo?.backgroundColor = UIColor(CNC.scr)
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }

    /// El panel del Resumen, ya calculado por la web (títulos, cifras, puntos de
    /// las gráficas y colores). Aquí solo se dibuja.
    ///
    /// Se reintenta: la web solo calcula las tarjetas del panel estando EN el
    /// resumen, y al cambiar de pestaña el repintado tarda un instante. Leerlo
    /// antes devolvía un panel vacío y la pantalla salía en blanco.
    private func traerResumen(intentos: Int = 1) {
        bridge?.webView?.evaluateJavaScript("(window.__chinolaResumenJSON && window.__chinolaResumenJSON()) || ''") { [weak self] res, _ in
            guard let s = self else { return }
            guard let json = res as? String, json.count > 2 else {
                if intentos > 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { s.traerResumen(intentos: intentos - 1) }
                }
                return
            }
            CNDatos.shared.cargarResumen(json: json)
            if intentos > 1, CNDatos.shared.resumen?.listo != true {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { s.traerResumen(intentos: intentos - 1) }
            }
        }
    }

    // MARK: el periodo (atajos + calendario), en hoja nativa
    private weak var periodoVC: UIViewController?
    // MARK: el selector de libretas, nativo
    private var libretasVC: UIViewController?
    private func abrirLibretas() {
        refrescarLibretas()
        guard libretasVC == nil else { return }
        // Hoja propia, de orilla a orilla y pegada al pie: la del sistema sale
        // flotando con márgenes en iOS 26.
        let d = datos
        let host = UIHostingController(rootView: CNHojaAbajo(onClose: { [weak self] in self?.cerrarLibretas() }) {
            CNLibretasHoja(datos: d, onClose: { [weak self] in self?.cerrarLibretas() })
        })
        host.view.backgroundColor = .clear
        host.modalPresentationStyle = .overFullScreen
        libretasVC = host
        if let actual = presentedViewController {
            actual.dismiss(animated: true) { [weak self] in self?.present(host, animated: false) }
        } else {
            present(host, animated: false)
        }
    }
    private func refrescarLibretas(intentos: Int = 4) {
        bridge?.webView?.evaluateJavaScript("(window.__chinolaLibretasJSON && window.__chinolaLibretasJSON()) || ''") { [weak self] res, _ in
            if let json = res as? String, json.count > 2 {
                CNDatos.shared.cargarLibretas(json: json)
                return
            }
            // La web puede estar a medio pintar: se vuelve a pedir en vez de
            // dejar la hoja vacía.
            guard intentos > 1 else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { self?.refrescarLibretas(intentos: intentos - 1) }
        }
    }
    private func cerrarLibretas() {
        // La hoja ya se ha ido animando sola; aquí solo se retira.
        libretasVC?.dismiss(animated: false)
        libretasVC = nil
    }

    private func abrirPeriodo() {
        refrescarPeriodo()
        guard periodoVC == nil else { return }
        let host = UIHostingController(rootView: CNPeriodoHoja(datos: datos, onClose: { [weak self] in
            self?.eval("window.__chinolaPeriodo && window.__chinolaPeriodo('cerrar',0)")
            self?.cerrarPeriodo()
        }))
        host.modalPresentationStyle = .pageSheet
        if let hoja = host.sheetPresentationController {
            hoja.detents = [.large()]
            hoja.prefersGrabberVisible = false
            hoja.preferredCornerRadius = 28
        }
        periodoVC = host
        if let actual = presentedViewController {
            actual.dismiss(animated: true) { [weak self] in self?.present(host, animated: true) }
        } else {
            present(host, animated: true)
        }
    }
    private func refrescarPeriodo() {
        bridge?.webView?.evaluateJavaScript("(window.__chinolaPeriodoJSON && window.__chinolaPeriodoJSON()) || ''") { res, _ in
            guard let json = res as? String, json.count > 2 else { return }
            CNDatos.shared.cargarPeriodo(json: json)
        }
    }
    private func cerrarPeriodo() {
        periodoVC?.dismiss(animated: true) { [weak self] in
            guard let s = self else { return }
            CNDatos.shared.periodo = nil
            s.traerDatos(intentos: 3); s.traerResumen(intentos: 4)
        }
        periodoVC = nil
    }

    // MARK: volver arrastrando desde la orilla, en las subpantallas de Perfil
    //
    // El detalle tiene el suyo propio en su vista; estas viven dentro de una
    // pantalla de SwiftUI, así que el reconocedor va en la raíz y lo único que
    // hace es mover un número que la vista mira. Solo empieza cuando hay una
    // subpantalla abierta: si no, no le quita el dedo a nadie.
    private func montarOrilla() {
        let g = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(arrastrarSeccion(_:)))
        g.edges = .left
        g.delegate = self
        view.addGestureRecognizer(g)
    }

    @objc private func arrastrarSeccion(_ g: UIScreenEdgePanGestureRecognizer) {
        guard datos.seccion != nil, detalleVC == nil else { return }
        let ancho = view.bounds.width
        let dx = max(0, g.translation(in: view).x)
        switch g.state {
        case .began, .changed:
            datos.arrastreSec = dx
        case .ended, .cancelled, .failed:
            let prisa = g.velocity(in: view).x
            if dx > ancho * 0.33 || prisa > 800 {
                withAnimation(.easeOut(duration: 0.2)) { self.datos.arrastreSec = ancho }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.19) { [weak self] in
                    guard let self = self else { return }
                    UISelectionFeedbackGenerator().selectionChanged()
                    self.datos.seccion = nil
                    self.datos.arrastreSec = 0
                }
            } else {
                withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.86)) { self.datos.arrastreSec = 0 }
            }
        default: break
        }
    }

    // MARK: un detalle cualquiera, empujado encima
    private var detalleVC: UIViewController?
    private var detalleQue = ("", "")
    fileprivate func mostrarDetalle(_ tipo: String, _ id: String) {
        detalleQue = (tipo, id)
        refrescarDetalle()
        guard detalleVC == nil else { return }
        let host = UIHostingController(
            rootView: CNDetalleVista(datos: CNDatos.shared, onVolver: { [weak self] in self?.cerrarDetalle() }))
        host.view.backgroundColor = UIColor(CNC.scr)
        addChild(host); view.addSubview(host.view); host.didMove(toParent: self)
        host.view.frame = view.bounds
        host.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        host.view.transform = CGAffineTransform(translationX: view.bounds.width, y: 0)
        // La sombra del filo, la misma que enseña iOS al empujar una pantalla.
        // Solo se ve mientras está corrida, que es cuando hay algo detrás.
        host.view.layer.shadowColor = UIColor.black.cgColor
        host.view.layer.shadowOpacity = 0.18
        host.view.layer.shadowRadius = 14
        host.view.layer.shadowOffset = CGSize(width: -4, height: 0)
        // Y las esquinas: mientras se arrastra, la pantalla es una tarjeta con
        // las esquinas del teléfono, no un rectángulo cortado a escuadra.
        host.view.layer.cornerRadius = 0
        host.view.layer.cornerCurve = .continuous
        // Volver arrastrando desde la orilla izquierda. Tiene que ser un
        // reconocedor de UIKit: es el mismo que usa UINavigationController y
        // por eso gana al desplazamiento de la lista que hay dentro. El
        // DragGesture de SwiftUI que había aquí no llegaba a empezar nunca.
        let orilla = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(arrastrarDetalle(_:)))
        orilla.edges = .left
        host.view.addGestureRecognizer(orilla)
        detalleVC = host
        // Lo de detrás se va un poco y se apaga, como en cualquier app del
        // teléfono: sin eso, la pantalla nueva parece pegada encima de una foto.
        montarSombraAtras()
        atras(0)
        UIView.animate(withDuration: 0.34, delay: 0, usingSpringWithDamping: 0.92, initialSpringVelocity: 0,
                       options: [.curveEaseOut, .allowUserInteraction]) {
            host.view.transform = .identity
            self.atras(1)
        }
    }

    /// El telón que apaga la pantalla de debajo mientras hay otra encima.
    private var sombraAtras: UIView?
    private func montarSombraAtras() {
        guard sombraAtras == nil, let debajo = contenedorNativo else { return }
        let v = UIView(frame: view.bounds)
        v.backgroundColor = .black
        v.alpha = 0
        v.isUserInteractionEnabled = false
        v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(v, aboveSubview: debajo)
        sombraAtras = v
    }
    /// `p` va de 0 (la de atrás en su sitio) a 1 (la de atrás retirada del todo).
    private func atras(_ p: CGFloat) {
        let q = max(0, min(1, p))
        contenedorNativo?.transform = CGAffineTransform(translationX: -view.bounds.width * 0.28 * q, y: 0)
        sombraAtras?.alpha = 0.16 * q
    }
    private func soltarAtras() {
        contenedorNativo?.transform = .identity
        sombraAtras?.removeFromSuperview()
        sombraAtras = nil
    }
    /// El arrastre desde la orilla: la pantalla sigue al dedo y se va o vuelve
    /// según lo que se haya recorrido o con qué prisa se suelte, como en iOS.
    @objc private func arrastrarDetalle(_ g: UIScreenEdgePanGestureRecognizer) {
        guard let host = detalleVC else { return }
        let ancho = view.bounds.width
        let dx = max(0, g.translation(in: view).x)
        switch g.state {
        case .began, .changed:
            if host.view.layer.cornerRadius == 0 {
                host.view.layer.cornerRadius = 30
                host.view.layer.masksToBounds = true
            }
            host.view.transform = CGAffineTransform(translationX: dx, y: 0)
            atras(1 - dx / max(1, ancho))
        case .ended, .cancelled, .failed:
            let prisa = g.velocity(in: view).x
            if dx > ancho * 0.33 || prisa > 800 {
                cerrarDetalle()
            } else {
                UIView.animate(withDuration: 0.28, delay: 0, usingSpringWithDamping: 0.9,
                               initialSpringVelocity: 0, options: [.allowUserInteraction]) {
                    host.view.transform = .identity
                    self.atras(1)
                } completion: { _ in
                    // De vuelta en su sitio, las esquinas a escuadra otra vez.
                    host.view.layer.cornerRadius = 0
                    host.view.layer.masksToBounds = false
                }
            }
        default: break
        }
    }

    fileprivate func cerrarDetalle() {
        guard let host = detalleVC else { return }
        detalleVC = nil
        UIView.animate(withDuration: 0.26, delay: 0, options: [.curveEaseOut, .allowUserInteraction]) {
            host.view.transform = CGAffineTransform(translationX: self.view.bounds.width, y: 0)
            self.atras(0)
        } completion: { _ in
            host.willMove(toParent: nil); host.view.removeFromSuperview(); host.removeFromParent()
            CNDatos.shared.detalle = nil
            self.soltarAtras()
        }
        traerDatos(intentos: 3); traerCuentas(); traerPlan()
    }
    private func refrescarDetalle() {
        let (tipo, id) = detalleQue
        guard !tipo.isEmpty else { return }
        bridge?.webView?.evaluateJavaScript("(window.__chinolaDetalleJSON && window.__chinolaDetalleJSON(\(comillas(tipo)),\(comillas(id)))) || ''") { res, _ in
            guard let json = res as? String, json.count > 2 else { return }
            CNDatos.shared.cargarDetalle(json: json)
        }
    }

    /// La pantalla de Cuentas, armada por la web.
    private func traerCuentas() {
        bridge?.webView?.evaluateJavaScript("(window.__chinolaCuentasJSON && window.__chinolaCuentasJSON()) || ''") { res, _ in
            guard let json = res as? String, json.count > 2 else { return }
            CNDatos.shared.cargarCuentas(json: json)
        }
    }

    /// El Plan, armado por la web.
    private func traerPlan(intentos: Int = 1) {
        bridge?.webView?.evaluateJavaScript("(window.__chinolaPlanJSON && window.__chinolaPlanJSON()) || ''") { [weak self] res, _ in
            guard let s = self else { return }
            if let json = res as? String, json.count > 2 { CNDatos.shared.cargarPlan(json: json) }
            if intentos > 1, CNDatos.shared.plan?.listo != true {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { s.traerPlan(intentos: intentos - 1) }
            }
        }
    }

    /// El detalle de un movimiento, armado por la web.
    private func traerMov(_ id: String) {
        bridge?.webView?.evaluateJavaScript("(window.__chinolaMovJSON && window.__chinolaMovJSON(\(comillas(id)))) || ''") { res, _ in
            guard let json = res as? String, json.count > 2 else { return }
            CNDatos.shared.cargarMovDetalle(json: json)
        }
    }

    /// El modelo de una subpantalla del perfil.
    private func traerSeccion(_ id: String) {
        bridge?.webView?.evaluateJavaScript("(window.__chinolaSeccionJSON && window.__chinolaSeccionJSON(\(comillas(id)))) || ''") { res, _ in
            guard let json = res as? String, json.count > 2 else { return }
            CNDatos.shared.cargarSeccion(json: json)
        }
    }

    /// Los ajustes del Perfil, armados por la web (los mismos que ve la PWA).
    private func traerAjustes() {
        bridge?.webView?.evaluateJavaScript("(window.__chinolaAjustesJSON && window.__chinolaAjustesJSON()) || ''") { res, _ in
            guard let json = res as? String, json.count > 2 else { return }
            CNDatos.shared.cargarAjustes(json: json)
        }
    }

    // MARK: pantalla nativa (Movimientos) encima del webview
    fileprivate func mostrarNativo(_ id: String) {
        // Si estábamos esperando a que un flujo de la web terminara, ya da
        // igual: el usuario ha cambiado de pantalla.
        volviendo = false
        // Al cambiar de pantalla la barra vuelve entera: la nueva empieza arriba.
        CNScrollEstado.shared.reiniciar()
        contenedorNativo?.removeFromSuperview()
        let host: UIHostingController<AnyView>
        switch id {
        case "resumen": host = UIHostingController(rootView: AnyView(CNResumen(datos: datos)))
        case "movs": host = UIHostingController(rootView: AnyView(CNMovs(datos: datos)))
        case "cuentas": host = UIHostingController(rootView: AnyView(CNCuentas(datos: datos)))
        case "plan": host = UIHostingController(rootView: AnyView(CNPlan(datos: datos)))
        case "perfil": host = UIHostingController(rootView: AnyView(CNPerfil(datos: datos)))
        default: return
        }
        // Fondo OPACO: tapa el webview sin esconderlo (esconderlo = pantalla negra,
        // porque el webView es la vista raíz del VC).
        host.view.backgroundColor = UIColor(CNC.scr)
        addChild(host); view.addSubview(host.view); host.didMove(toParent: self)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        contenedorNativo = host.view
        ajustarHueco(host)
        view.bringSubviewToFront(barra.barra)
        traerDatos()
        // La web se entera igual de en qué pestaña estamos: así sus hojas y su
        // botón de atrás siguen cuadrando con lo que se ve.
        eval("window.__chinolaMenu && window.__chinolaMenu('\(id)')")
        eval("window.__chinolaPush && window.__chinolaPush()")
        // Y se vuelve a pedir el modelo cuando la web ya haya repintado con la
        // pestaña nueva puesta.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let s = self else { return }
            s.traerResumen(intentos: 6); s.traerCuentas(); s.traerPlan(intentos: 6); s.traerAjustes()
        }
    }

    private func mostrarWeb() {
        contenedorNativo?.removeFromSuperview()
        contenedorNativo = nil
    }

    /// Enseñar la web para un flujo SUYO (una hoja, el calendario, el selector
    /// de libreta) y volver a lo nativo en cuanto ese flujo termina.
    ///
    /// Sin esto la app se quedaba en la pantalla WEB de la pestaña —la copia
    /// vieja de la que ya es nativa—, y navegando salía una u otra sin motivo
    /// aparente. Ahora la web solo se ve mientras tiene algo que enseñar.
    private var volviendo = false
    /// `alIrALaWeb` corre SOLO si al final hay que enseñar la web. Así una
    /// pantalla nativa que abre una hoja se queda donde está —la hoja se dibuja
    /// encima— y solo se aparta cuando lo que la web abrió no sabemos dibujarlo.
    private func webTemporal(alIrALaWeb: (() -> Void)? = nil) {
        // Primero se mira si lo que la web abrió es una HOJA: esas se dibujan
        // nativas y el webview no se enseña. Solo lo que no sabemos dibujar
        // (el calendario del periodo, el selector de libreta) pasa a la web.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            guard let s = self else { return }
            // ¿El recorrido? Se dibuja nativo, encima de la pantalla de verdad.
            s.bridge?.webView?.evaluateJavaScript("(window.__chinolaTourJSON && window.__chinolaTourJSON()) || ''") { r0, _ in
                if let j = r0 as? String, j.count > 2 {
                    CNDatos.shared.cargarTour(json: j)
                    s.mostrarTour()
                    return
                }
                // ¿La categoría? También tiene su hoja nativa.
                s.bridge?.webView?.evaluateJavaScript("(window.__chinolaCatJSON && window.__chinolaCatJSON()) || ''") { rc, _ in
                    if let j = rc as? String, j.count > 2 {
                        CNDatos.shared.cargarCategoria(json: j)
                        s.presentar(AnyView(CNFormCategoria(datos: s.datos, onClose: {
                            s.eval("window.__chinolaCat && window.__chinolaCat('cerrar','')")
                            s.cerrar()
                            s.traerPlan(intentos: 4); s.traerDatos(intentos: 3)
                        })))
                        return
                    }
            s.bridge?.webView?.evaluateJavaScript("(window.__chinolaHojaJSON && window.__chinolaHojaJSON()) || ''") { res, _ in
                if let json = res as? String, json.count > 2 {
                    CNDatos.shared.cargarHojaWeb(json: json)
                    s.presentarHojaWeb()
                    return
                }
                // ¿La puerta (cambiar de plan, poner el nombre, cerrar sesión)?
                s.bridge?.webView?.evaluateJavaScript("(window.__chinolaPuertaJSON && window.__chinolaPuertaJSON()) || ''") { rp, _ in
                    if let j = rp as? String, j.count > 2, let m = CNPuerta.desde(json: j), m.paso != "app" {
                        CNDatos.shared.cargarPuerta(json: j)
                        s.abrirPuerta()
                        return
                    }
                    // Nada de eso. Solo si la web tiene de verdad algo abierto
                    // que no sabemos dibujar se enseña la web; si la acción no
                    // abrió nada (un interruptor, exportar, un aviso), nos
                    // quedamos en nativo. Antes se enseñaba la web por defecto,
                    // y eso era «todo es web» y los cuelgues.
                    s.bridge?.webView?.evaluateJavaScript("!!(window.__chinolaHayHoja && window.__chinolaHayHoja())") { rh, _ in
                        guard (rh as? Bool) == true else { return }
                        alIrALaWeb?()
                        s.mostrarWeb()
                        guard !s.volviendo else { return }
                        s.volviendo = true
                        s.vigilarVuelta(200)
                    }
                }
            }
            }
            }
        }
    }

    // MARK: importar un CSV con el selector de archivos del sistema
    //
    // El <input type=file> de la web no abre nada desde una llamada nuestra
    // (WKWebView exige un toque de verdad). El selector lo abre el sistema y el
    // texto se le pasa a la MISMA función de la web que lo lee.
    fileprivate func pedirCsv() {
        let tipos: [UTType] = [.commaSeparatedText, .plainText, .text]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: tipos, asCopy: true)
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }

    // MARK: avisos cortos («Guardado», «Avisos puestos»)
    //
    // Los de la web no los veía nadie: está tapada por las pantallas nativas.
    // Este baja desde arriba, se lee y se va solo.
    private var avisoVista: UIView?
    private func mostrarAviso(_ titulo: String, _ texto: String) {
        avisoVista?.removeFromSuperview()
        let tarjeta = UIView()
        tarjeta.backgroundColor = UIColor(CNC.card)
        tarjeta.layer.cornerRadius = 18
        tarjeta.layer.cornerCurve = .continuous
        tarjeta.layer.borderWidth = 1
        tarjeta.layer.borderColor = UIColor(CNC.line).cgColor
        tarjeta.layer.shadowColor = UIColor.black.cgColor
        tarjeta.layer.shadowOpacity = 0.16
        tarjeta.layer.shadowRadius = 14
        tarjeta.layer.shadowOffset = CGSize(width: 0, height: 6)
        let t = UILabel()
        t.text = titulo; t.font = cnUIFuente(15, .bold); t.textColor = UIColor(CNC.ink); t.numberOfLines = 2
        let x = UILabel()
        x.text = texto; x.font = cnUIFuente(13, .regular); x.textColor = UIColor(CNC.pmut); x.numberOfLines = 3
        x.isHidden = texto.isEmpty
        let pila = UIStackView(arrangedSubviews: [t, x])
        pila.axis = .vertical; pila.spacing = 3
        pila.translatesAutoresizingMaskIntoConstraints = false
        tarjeta.addSubview(pila)
        tarjeta.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tarjeta)
        NSLayoutConstraint.activate([
            pila.topAnchor.constraint(equalTo: tarjeta.topAnchor, constant: 12),
            pila.bottomAnchor.constraint(equalTo: tarjeta.bottomAnchor, constant: -12),
            pila.leadingAnchor.constraint(equalTo: tarjeta.leadingAnchor, constant: 16),
            pila.trailingAnchor.constraint(equalTo: tarjeta.trailingAnchor, constant: -16),
            tarjeta.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tarjeta.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tarjeta.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8)
        ])
        avisoVista = tarjeta
        tarjeta.alpha = 0
        tarjeta.transform = CGAffineTransform(translationX: 0, y: -24)
        UIView.animate(withDuration: 0.32, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0) {
            tarjeta.alpha = 1; tarjeta.transform = .identity
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) { [weak self, weak tarjeta] in
            guard let tj = tarjeta, self?.avisoVista === tj else { return }
            UIView.animate(withDuration: 0.25, animations: { tj.alpha = 0; tj.transform = CGAffineTransform(translationX: 0, y: -16) }) { _ in
                tj.removeFromSuperview()
                if self?.avisoVista === tj { self?.avisoVista = nil }
            }
        }
    }

    // MARK: la cortina del arranque
    //
    // Un telón del color del tema mientras no se sabe qué toca: la app o la
    // puerta. Dura lo que tarde la web en contestar, y como mucho tres
    // segundos y medio —si algo fallara, es preferible una pantalla de más que
    // una app tapada para siempre.
    private var cortina: UIView?
    private func montarCortina() {
        let v = UIView(frame: view.bounds)
        v.backgroundColor = UIColor(CNC.scr)
        v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(v)
        cortina = v
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { [weak self] in self?.quitarCortina() }
    }
    private func quitarCortina() {
        guard let v = cortina else { return }
        cortina = nil
        UIView.animate(withDuration: 0.2) { v.alpha = 0 } completion: { _ in v.removeFromSuperview() }
    }

    // MARK: la puerta — lo de antes de entrar
    //
    // Bienvenida, acceso, nombre, plan y el «listo». La lógica sigue siendo la
    // de la web (la misma que en el navegador); aquí se dibuja y se le dice qué
    // han tocado. Mientras está puesta, el menú de abajo no pinta nada.
    private var puertaVC: UIViewController?
    fileprivate func mirarPuerta(intentos: Int = 12) {
        bridge?.webView?.evaluateJavaScript("(window.__chinolaPuertaJSON && window.__chinolaPuertaJSON()) || ''") { [weak self] res, _ in
            guard let s = self else { return }
            let json = (res as? String) ?? ""
            if s.puertaRendida {
                // Ya se pasó a la web: solo queda mirar si ya entró.
                if let m = CNPuerta.desde(json: json), m.paso == "app" {
                    s.puertaRendida = false
                    s.cerrarPuerta()
                } else if intentos > 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { s.mirarPuerta(intentos: intentos - 1) }
                }
                return
            }
            if json.count > 2 {
                if let m = CNPuerta.desde(json: json), m.paso == "app" {
                    s.cerrarPuerta()
                } else {
                    CNDatos.shared.cargarPuerta(json: json)
                    s.abrirPuerta()
                }
                return
            }
            // Todavía no hay modelo: la web puede estar arrancando.
            guard intentos > 1 else {
                // Se acabó la espera. Si además no hay datos, lo que hay
                // delante es una pantalla vacía: mejor la web, que siempre
                // sabe qué enseñar.
                if CNDatos.shared.resumen == nil && CNDatos.shared.puerta == nil && s.puertaVC == nil {
                    s.puertaALaWeb()
                }
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { s.mirarPuerta(intentos: intentos - 1) }
        }
    }
    private func abrirPuerta() {
        barra.barra.isHidden = true
        quitarCortina()
        guard puertaVC == nil else { return }
        let host = UIHostingController(rootView: CNPuertaVista(datos: datos, onAccion: { [weak self] que, valor in
            guard let s = self else { return }
            // Salida de emergencia: si algo de la puerta nativa fallara, la de
            // la web sigue ahí y es la de siempre. Que nadie se quede fuera.
            if que == "web" { s.puertaALaWeb(); return }
            s.puertaAccion(que, valor)
        }))
        host.view.backgroundColor = UIColor(CNC.scr)
        addChild(host); view.addSubview(host.view); host.didMove(toParent: self)
        host.view.frame = view.bounds
        host.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        host.view.layer.cornerCurve = .continuous
        // Volver deslizando desde la orilla, como en los detalles: el mismo
        // reconocedor de UIKit, que gana a la lista de dentro.
        let orilla = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(arrastrarPuerta(_:)))
        orilla.edges = .left
        host.view.addGestureRecognizer(orilla)
        puertaVC = host
        // Y se vuelve a mirar cada poco mientras esté puesta: la web cambia de
        // paso por su cuenta (la caja de Apple que se cierra, el correo que se
        // verifica, un error) y antes solo se miraba unas veces tras un toque;
        // lo que pasara después se quedaba sin pintar («Un momento…» eterno).
        puertaReloj?.invalidate()
        puertaReloj = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: true) { [weak self] _ in
            guard let s = self, s.puertaVC != nil, !s.puertaRendida else { return }
            s.mirarPuerta(intentos: 1)
        }
    }
    private var puertaReloj: Timer?

    /// El arrastre desde la orilla en la puerta: la pantalla sigue al dedo y,
    /// si se suelta lejos o con prisa, hace lo mismo que la flecha de atrás
    /// del paso (si el paso no tiene atrás, solo vuelve a su sitio).
    @objc private func arrastrarPuerta(_ g: UIScreenEdgePanGestureRecognizer) {
        guard let host = puertaVC else { return }
        let ancho = view.bounds.width
        let dx = max(0, g.translation(in: view).x)
        let volver = CNDatos.shared.puerta?.volver ?? ""
        switch g.state {
        case .began, .changed:
            guard !volver.isEmpty else { return }
            if host.view.layer.cornerRadius == 0 {
                host.view.layer.cornerRadius = 30
                host.view.layer.masksToBounds = true
            }
            host.view.transform = CGAffineTransform(translationX: dx, y: 0)
        case .ended, .cancelled, .failed:
            guard !volver.isEmpty else { return }
            let prisa = g.velocity(in: view).x
            if dx > ancho * 0.33 || prisa > 800 {
                UISelectionFeedbackGenerator().selectionChanged()
                UIView.animate(withDuration: 0.18, delay: 0, options: [.curveEaseOut]) {
                    host.view.transform = CGAffineTransform(translationX: ancho, y: 0)
                } completion: { _ in
                    // Se le pide a la web el paso de antes y, en cuanto lo
                    // dibuja, la pantalla entra desde la izquierda.
                    self.puertaAccion(volver, "")
                    host.view.transform = CGAffineTransform(translationX: -ancho * 0.25, y: 0)
                    host.view.alpha = 0
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { self.mirarPuerta(intentos: 3) }
                    UIView.animate(withDuration: 0.26, delay: 0.3, options: [.curveEaseOut, .allowUserInteraction]) {
                        host.view.transform = .identity
                        host.view.alpha = 1
                    } completion: { _ in
                        host.view.layer.cornerRadius = 0
                        host.view.layer.masksToBounds = false
                    }
                }
            } else {
                UIView.animate(withDuration: 0.28, delay: 0, usingSpringWithDamping: 0.9,
                               initialSpringVelocity: 0, options: [.allowUserInteraction]) {
                    host.view.transform = .identity
                } completion: { _ in
                    host.view.layer.cornerRadius = 0
                    host.view.layer.masksToBounds = false
                }
            }
        default: break
        }
    }
    private func puertaAccion(_ que: String, _ valor: String) {
        // Los DOS argumentos, en su sitio. Mandarlos dentro de un objeto —que
        // es lo que hace `aWeb`— dejaba `que` como un objeto y ningún botón de
        // la puerta hacía nada: no se podía ni entrar.
        eval("window.__chinolaPuerta && window.__chinolaPuerta(\(comillas(que)),\(comillas(valor)))")
        // Escribir en un campo no cambia de pantalla; lo demás sí.
        guard que != "campo" && que != "nombre" else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { [weak self] in
            self?.mirarPuerta(intentos: 4)
            // Entrar con Apple o Google tarda lo que tarde su ventana.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) { self?.mirarPuerta(intentos: 3) }
        }
    }
    /// Dejar la puerta nativa y seguir en la de la web.
    private func puertaALaWeb() {
        barra.barra.isHidden = true
        quitarCortina()
        puertaReloj?.invalidate(); puertaReloj = nil
        if let host = puertaVC {
            puertaVC = nil
            host.willMove(toParent: nil); host.view.removeFromSuperview(); host.removeFromParent()
        }
        CNDatos.shared.puerta = nil
        puertaRendida = true
        mostrarWeb()
        // Y se sigue mirando: en cuanto entre, se monta lo nativo.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in self?.mirarPuerta(intentos: 300) }
    }
    /// Una vez que se ha ido a la web, la puerta nativa no vuelve a asomar en
    /// esta sesión: quien está entrando no necesita que le cambien la pantalla
    /// debajo de los dedos.
    private var puertaRendida = false

    private func cerrarPuerta() {
        barra.barra.isHidden = false
        quitarCortina()
        puertaReloj?.invalidate(); puertaReloj = nil
        guard let host = puertaVC else { return }
        puertaVC = nil
        UIView.animate(withDuration: 0.25) { host.view.alpha = 0 } completion: { _ in
            host.willMove(toParent: nil); host.view.removeFromSuperview(); host.removeFromParent()
            CNDatos.shared.puerta = nil
        }
        traerDatos(intentos: 8)
        mostrarNativo(menuEstado.activa)
    }

    // MARK: Chino en grande (mantener pulsado en Perfil)
    private var mascotaVC: UIViewController?
    fileprivate func abrirMascota() {
        bridge?.webView?.evaluateJavaScript("(window.__chinolaMascotaJSON && window.__chinolaMascotaJSON()) || ''") { [weak self] res, _ in
            guard let s = self else { return }
            if let json = res as? String, json.count > 2 { CNDatos.shared.cargarMascota(json: json) }
            guard s.mascotaVC == nil else { return }
            let host = UIHostingController(rootView: CNMascotaVista(datos: s.datos, onClose: { [weak self] in
                self?.cerrarMascota()
            }))
            host.view.backgroundColor = .clear
            s.addChild(host); s.view.addSubview(host.view); host.didMove(toParent: s)
            host.view.frame = s.view.bounds
            host.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            host.view.alpha = 0
            s.mascotaVC = host
            UIView.animate(withDuration: 0.2) { host.view.alpha = 1 }
        }
    }
    private func cerrarMascota() {
        guard let host = mascotaVC else { return }
        mascotaVC = nil
        UIView.animate(withDuration: 0.18) { host.view.alpha = 0 } completion: { _ in
            host.willMove(toParent: nil); host.view.removeFromSuperview(); host.removeFromParent()
        }
    }

    // MARK: el recorrido de bienvenida
    private var tourVC: UIViewController?
    private func mostrarTour() {
        // La pantalla de la que habla el paso, detrás del globo.
        if let v = CNDatos.shared.tour?.vista, nativas.contains(v) {
            menuEstado.activa = v
            barra.pintar(activa: v, titulos: menuEstado.titulos)
            mostrarNativo(v)
        }
        guard tourVC == nil else { return }
        let host = UIHostingController(rootView: CNTourVista(datos: datos, onPaso: { [weak self] que in
            self?.pasoDelTour(que)
        }))
        host.view.backgroundColor = .clear
        addChild(host); view.addSubview(host.view); host.didMove(toParent: self)
        host.view.frame = view.bounds
        host.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        host.view.alpha = 0
        tourVC = host
        UIView.animate(withDuration: 0.22) { host.view.alpha = 1 }
    }
    private func pasoDelTour(_ que: String) {
        eval("window.__chinolaTour && window.__chinolaTour(\(comillas(que)))")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
            guard let s = self else { return }
            s.bridge?.webView?.evaluateJavaScript("(window.__chinolaTourJSON && window.__chinolaTourJSON()) || ''") { res, _ in
                if let j = res as? String, j.count > 2 {
                    CNDatos.shared.cargarTour(json: j)
                    if let v = CNDatos.shared.tour?.vista, s.nativas.contains(v) {
                        s.menuEstado.activa = v
                        s.barra.pintar(activa: v, titulos: s.menuEstado.titulos)
                        s.mostrarNativo(v)
                        s.view.bringSubviewToFront(s.tourVC?.view ?? UIView())
                    }
                    return
                }
                s.cerrarTour()
            }
        }
    }
    private func cerrarTour() {
        guard let host = tourVC else { return }
        tourVC = nil
        UIView.animate(withDuration: 0.2) { host.view.alpha = 0 } completion: { _ in
            host.willMove(toParent: nil); host.view.removeFromSuperview(); host.removeFromParent()
            CNDatos.shared.tour = nil
        }
        mostrarNativo(menuEstado.activa)
        traerDatos(intentos: 3); traerResumen(intentos: 4)
    }

    /// La hoja de la web, dibujada en nativo y encima de todo.
    private weak var hojaWebVC: UIViewController?
    private func presentarHojaWeb() {
        guard hojaWebVC == nil else { refrescarHojaWeb(); return }
        let host = UIHostingController(rootView: CNHojaWebViva(datos: datos, onClose: { [weak self] in
            self?.eval("window.__chinolaHojaCerrar && window.__chinolaHojaCerrar()")
            self?.cerrarHojaWeb()
        }))
        host.modalPresentationStyle = .pageSheet
        if let hoja = host.sheetPresentationController {
            hoja.detents = [.large()]
            hoja.prefersGrabberVisible = false
            hoja.preferredCornerRadius = 28
        }
        hojaWebVC = host
        if let actual = presentedViewController {
            actual.dismiss(animated: true) { [weak self] in self?.present(host, animated: true) }
        } else {
            present(host, animated: true)
        }
    }
    private func cerrarHojaWeb() {
        hojaWebVC?.dismiss(animated: true) { [weak self] in
            guard let s = self else { return }
            CNDatos.shared.hojaWeb = nil
            s.traerDatos(intentos: 3); s.traerResumen(intentos: 4); s.traerAjustes(); s.traerTema()
            // Si había una subpantalla del perfil debajo, se repinta con lo
            // que acabe de cambiar.
            if let id = CNDatos.shared.seccion?.id { s.traerSeccion(id) }
            // Y el detalle que quedó debajo, también: se acaba de abonar, de
            // aportar o de pagar, y la cifra de arriba tiene que cambiar.
            if s.detalleVC != nil {
                s.refrescarDetalle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { s.refrescarDetalle() }
            }
            s.traerCuentas(); s.traerPlan()
        }
        hojaWebVC = nil
    }
    /// Tras escribir o guardar, la web devuelve el modelo nuevo (con su error o
    /// su «listo»); si ya no hay hoja, se cierra.
    private func refrescarHojaWeb() {
        bridge?.webView?.evaluateJavaScript("(window.__chinolaHojaJSON && window.__chinolaHojaJSON()) || ''") { [weak self] res, _ in
            guard let s = self else { return }
            if let json = res as? String, json.count > 2 {
                CNDatos.shared.cargarHojaWeb(json: json)
            } else {
                s.cerrarHojaWeb()
            }
        }
    }
    private func vigilarVuelta(_ intentos: Int) {
        guard volviendo, intentos > 0 else { volviendo = false; return }
        bridge?.webView?.evaluateJavaScript("!!(window.__chinolaHayHoja && window.__chinolaHayHoja())") { [weak self] r, _ in
            guard let s = self, s.volviendo else { return }
            if (r as? Bool) == false {
                s.volviendo = false
                let id = s.menuEstado.activa
                if s.nativas.contains(id) { s.mostrarNativo(id); s.refrescarPantalla(id) }
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { s.vigilarVuelta(intentos - 1) }
        }
    }

    // MARK: hojas y detalles nativos (presentados encima)
    private weak var hojaVC: UIViewController?
    private func presentar(_ vista: AnyView) {
        let mostrar = { [weak self] in
            guard let self = self else { return }
            let host = UIHostingController(rootView: vista)
            // Hoja del sistema: tirador, esquinas, atenuado y arrastre elástico
            // los pone iOS, como en cualquier app de Apple.
            host.modalPresentationStyle = .pageSheet
            if let hoja = host.sheetPresentationController {
                hoja.detents = [.large()]
                hoja.prefersGrabberVisible = false
                hoja.preferredCornerRadius = 28
            }
            self.hojaVC = host
            self.present(host, animated: true)
        }
        // Si ya hay algo encima (p.ej. el detalle al tocar «abonar»), se cierra
        // primero y se abre la nueva cuando termine.
        if let actual = presentedViewController {
            actual.dismiss(animated: true, completion: mostrar)
        } else {
            mostrar()
        }
    }
    private func cerrar() {
        hojaVC?.dismiss(animated: true) { [weak self] in self?.traerDatos(intentos: 3) }
    }

    // MARK: barra de menú nativa
    /// Un `UITabBar` de VERDAD: en iOS 26 trae el Liquid Glass del sistema (la
    /// lente que se desliza a la pestaña elegida, el brillo de los bordes). Una
    /// barra dibujada a mano se ve como cristal, pero está quieta.
    private func montarBarra() {
        guard barra.barra.superview == nil else { return }
        barra.alTocar = { [weak self] id in self?.menuEstado.alTocar(id) }
        barra.montar(en: view)
        barra.pintar(activa: menuEstado.activa, titulos: menuEstado.titulos)
        // La barra se encoge al bajar por cualquier pantalla y vuelve al subir.
        CNScrollEstado.shared.alCambiar = { [weak self] compacto in
            self?.barra.compactar(compacto)
        }
        // Mantener pulsado un botón del menú: el atajo de esa pestaña, desde
        // donde sea. Anotar es el más usado, así que está en dos.
        datos.onMascota = { [weak self] in self?.abrirMascota() }
        datos.onCategoria = { [weak self] que, valor in
            guard let s = self else { return }
            s.eval("window.__chinolaCat && window.__chinolaCat(\(s.comillas(que)),\(s.comillas(valor)))")
            // Elegir icono, color o tipo cambia cómo se ve la hoja.
            if que == "icono" || que == "color" || que == "tipo" {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    s.bridge?.webView?.evaluateJavaScript("(window.__chinolaCatJSON && window.__chinolaCatJSON()) || ''") { r, _ in
                        if let j = r as? String, j.count > 2 { CNDatos.shared.cargarCategoria(json: j) }
                    }
                }
            }
        }
        barra.alMantener = { [weak self] id in
            guard let s = self else { return }
            switch id {
            case "movs", "resumen": s.datos.onNuevoMov()
            case "cuentas": s.datos.onAgregar()
            case "plan": s.datos.onPlanAccion(CNDatos.shared.plan?.tab == "metas" ? "nuevaMeta" : "nuevaCat", 0)
            case "perfil": s.abrirMascota()
            default: break
            }
        }
        menuEstado.alAviso = { [weak self] titulo, texto in self?.mostrarAviso(titulo, texto) }
        menuEstado.alRepintar = { [weak self] in
            guard let s = self else { return }
            s.barra.pintar(activa: s.menuEstado.activa, titulos: s.menuEstado.titulos)
        }
    }

    /// Deja hueco abajo para que la lista no quede tapada por la barra flotante.
    private func ajustarHueco(_ host: UIViewController) {
        view.layoutIfNeeded()
        let alto = max(barra.alto, 56) + 6
        host.additionalSafeAreaInsets.bottom = max(0, alto - view.safeAreaInsets.bottom)
    }

}

extension ChinolaViewController: UIGestureRecognizerDelegate {
    /// El gesto de la orilla solo entra cuando hay una subpantalla de Perfil
    /// abierta. Así la web y las listas siguen recibiendo el dedo como siempre.
    func gestureRecognizerShouldBegin(_ g: UIGestureRecognizer) -> Bool {
        guard g is UIScreenEdgePanGestureRecognizer else { return true }
        return datos.seccion != nil && detalleVC == nil
    }
}

extension ChinolaViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let u = urls.first else { return }
        let acceso = u.startAccessingSecurityScopedResource()
        defer { if acceso { u.stopAccessingSecurityScopedResource() } }
        guard let datos = try? Data(contentsOf: u) else { return }
        // UTF-8 o, si no, Latin-1: los bancos exportan de las dos maneras.
        let texto = String(data: datos, encoding: .utf8) ?? String(data: datos, encoding: .isoLatin1) ?? ""
        guard !texto.isEmpty else { return }
        eval("window.__chinolaImportaCsv && window.__chinolaImportaCsv(\(comillas(texto)))")
        refrescarPronto()
    }
}
