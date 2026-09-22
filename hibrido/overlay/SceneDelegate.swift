import UIKit
import SwiftUI
import Capacitor

// Prueba del flujo REAL de la app: registra el plugin Nativo (store = datos), y
// la web (www/index.html) empuja el JSON por Nativo.datos. El nativo NO precarga
// datos: si Movimientos se llena, el PUENTE web→nativo funciona.

class TestVC: CAPBridgeViewController {
    let datos = CNDatos.shared
    let estado = CNMenuEstado.shared
    private let nativo = NativoPlugin()
    let barra = CNBarraNativa()
    var contenido: UIView?

    override func capacitorDidLoad() {
        nativo.store = datos
        nativo.menuEstado = estado
        bridge?.registerPluginInstance(nativo)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        CNFuentes.registrar()

        // El MENÚ: un UITabBar de verdad (Liquid Glass del sistema en iOS 26).
        barra.alTocar = { [weak self] id in self?.estado.activa = id; self?.barra.pintar(activa: id, titulos: CNMenuEstado.shared.titulos) }
        barra.montar(en: view)
        barra.pintar(activa: estado.activa, titulos: CNMenuEstado.shared.titulos)
        CNScrollEstado.shared.alCambiar = { [weak self] compacto in self?.barra.compactar(compacto) }

        // El guion lo manda el entorno (SIMCTL_CHILD_CNPANTALLA): una pantalla
        // por lanzamiento, así cada captura es la que se pidió y no depende de
        // cuánto tarde el simulador en arrancar.
        conectarAcciones()
        let cual = ProcessInfo.processInfo.environment["CNPANTALLA"] ?? "movs"
        if cual.hasPrefix("tema-") {
            datos.cargarTema(json: cual.contains("oscuro") ? TestVC.temaSistemaOscuro : TestVC.temaSistemaClaro)
        } else if cual.hasSuffix("-oscuro") {
            // Como si el usuario cambiara de tema en la web: todo lo nativo
            // tiene que repintarse con la paleta nueva.
            datos.cargarTema(json: """
            {"bg":"#101713","card":"#18211b","suave":"#1d2820","borde":"#2c3a31","tinta":"#eef3ee",
             "gris":"#9bb0a1","side":"#0b120e","acento":"#8fd6a0","pos":"#5fcf8a","neg":"#e08a7a","oscuro":true}
            """)
        }
        // Claro u oscuro de sistema según el tema, para que el vidrio y las
        // hojas acompañen a la paleta.
        view.window?.overrideUserInterfaceStyle = CNC.tema.oscuro ? .dark : .light
        // La cabecera y el panel del Resumen los calcula la web; en el banco de
        // pruebas no hay web, así que se carga un ejemplo con todas las clases
        // de tarjeta para poder mirarlas.
        // La cabecera de la muestra cambia de diseño según la pantalla pedida,
        // para poder mirarlos todos.
        let disenoCab = ["cab-auto": "auto", "cab-clasica": "clasica", "cab-detallada": "detallada",
                         "cab-fina": "fina", "cab-clara": "clara", "cab-minima": "minima",
                         "cab-viva": "viva", "cab-viva-plegada": "viva"][cual] ?? "auto"
        // La viva lleva su frase y sus cuatro fichas; la paleta es de papel.
        let fichasViva = disenoCab == "viva" ? """
            ,"frase":"Gastos y ahorro juntos pasaron lo que entró","fichas":[
             {"clave":"entro","label":"Entró","valor":"RD$80,000","nota":"3 ingresos","icono":"arrow.up","color":"rgb(19,125,65)","fondo":"rgba(19,125,65,0.13)"},
             {"clave":"gastos","label":"Gastos","valor":"RD$82,400","nota":"103% de lo que entró","icono":"arrow.down","color":"rgb(213,89,72)","fondo":"rgba(213,89,72,0.13)"},
             {"clave":"ahorro","label":"Ahorro","valor":"RD$5,000","nota":"Fondo de emergencia","icono":"hucha","color":"rgb(90,72,200)","fondo":"rgba(90,72,200,0.13)"},
             {"clave":"debes","label":"Debes","valor":"RD$336,000","nota":"2 tarjetas · 1 préstamo","icono":"tarjeta","color":"rgb(196,124,44)","fondo":"rgba(196,124,44,0.13)"}]
            """ : ""
        var grad = cual.hasPrefix("cab-") ? TestVC.fondoDegradado : TestVC.fondoLlano
        if cual.hasPrefix("tema-") {
            grad = cual.contains("oscuro")
                ? "{\"tipo\":\"color\",\"color\":\"rgb(0,28,11)\"}"
                : "{\"tipo\":\"color\",\"color\":\"rgb(6,68,37)\"}"
        }
        if disenoCab == "viva" { grad = "{\"tipo\":\"color\",\"color\":\"rgb(255,255,255)\"}" }
        let tintaCab = disenoCab == "viva" ? "rgb(19,36,25)" : (cual.hasPrefix("cab-") ? "rgb(43,32,16)" : "rgb(245,245,230)")
        let grisCab = disenoCab == "viva" ? "rgb(81,99,86)" : (cual.hasPrefix("cab-") ? "rgba(0,0,0,0.72)" : "rgb(214,222,205)")
        let pastCab = cual.hasPrefix("cab-") ? "rgba(0,0,0,0.13)" : "rgba(255,255,255,0.13)"
        let pastF = cual.hasPrefix("cab-") ? "rgba(0,0,0,0.22)" : "rgba(255,255,255,0.22)"
        datos.cargarCuentas(json: TestVC.cuentasDeMuestra)
        datos.cargarPlan(json: TestVC.planDeMuestra)
        datos.cargarMovDetalle(json: TestVC.movDeMuestra)
        datos.cargarAjustes(json: TestVC.ajustesDeMuestra
            .replacingOccurrences(of: "rgb(249,245,230)",
                                  with: cual.contains("oscuro") ? "rgb(43,43,45)" : "rgb(249,245,230)"))
        datos.cargarResumen(json: TestVC.resumenDeMuestra
            .replacingOccurrences(of: "\"diseno\":\"auto\"", with: "\"diseno\":\"\(disenoCab)\"" + fichasViva)
            .replacingOccurrences(of: "__FONDO__", with: grad)
            .replacingOccurrences(of: "\"tinta\":\"rgb(245,245,230)\"", with: "\"tinta\":\"\(tintaCab)\"")
            .replacingOccurrences(of: "\"gris\":\"rgb(214,222,205)\"", with: "\"gris\":\"\(grisCab)\"")
            .replacingOccurrences(of: "\"pastilla\":\"rgba(255,255,255,0.13)\",\"pastillaFuerte\":\"rgba(255,255,255,0.22)\"",
                                  with: "\"pastilla\":\"\(pastCab)\",\"pastillaFuerte\":\"\(pastF)\"")
            .replacingOccurrences(of: "\"balColor\":\"rgb(255,255,255)\"",
                                  with: cual.hasPrefix("cab-") ? "\"balColor\":\"rgb(43,32,16)\"" : "\"balColor\":\"rgb(255,255,255)\"")
            .replacingOccurrences(of: "rgb(229,225,211)",
                                  with: cual.contains("oscuro") ? "rgb(61,61,63)" : "rgb(229,225,211)"))
        let base = cual.replacingOccurrences(of: "-oscuro", with: "")
        mostrar(base)
        barra.pintar(activa: estado.activa, titulos: CNMenuEstado.shared.titulos)
        if base == "movs-rodado" || base == "plegada" || base == "cab-viva-plegada" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) { [weak self] in self?.rodar(320) }
        }
        if ["cuenta", "tarjeta", "categoria"].contains(base) {
            datos.cargarDetalle(json: TestVC.detalleDeMuestra(base))
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) { [weak self] in
                guard let s = self else { return }
                s.presentar(AnyView(CNDetalleVista(datos: s.datos, onVolver: { s.cerrar() })))
            }
        }
        if base == "periodo" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
                guard let s = self else { return }
                s.presentar(AnyView(CNPeriodoHoja(datos: s.datos, onClose: { s.cerrar() })))
            }
        }
        if base == "hoja-web" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
                guard let s = self else { return }
                s.presentar(AnyView(CNHojaWebViva(datos: s.datos, onClose: { s.cerrar() })))
            }
        }
        if ["detalle", "nuevo", "tarjeta", "agregar"].contains(base) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
                guard let s = self else { return }
                if base == "detalle" {
                    let id = s.datos.libreta.tx.first?.id ?? ""
                    s.presentar(AnyView(CNDetalleMov(datos: s.datos, movId: id, onClose: { s.cerrar() })))
                } else if base == "nuevo" {
                    s.presentar(AnyView(CNNuevoMov(datos: s.datos, onClose: { s.cerrar() })))
                } else if base == "tarjeta" {
                    s.presentar(AnyView(CNFormTarjeta(datos: s.datos, onClose: { s.cerrar() })))
                } else if base == "agregar" {
                    s.presentar(AnyView(CNAgregar(datos: s.datos, onClose: { s.cerrar() })))
                }
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        barra.ajustar()
    }

    /// Rodar la pantalla a mano: el ScrollViewReader de SwiftUI no siempre
    /// llega, y para la captura hace falta que ruede seguro.
    func rodar(_ cuanto: CGFloat) {
        func buscar(_ v: UIView) -> UIScrollView? {
            if let sc = v as? UIScrollView { return sc }
            for h in v.subviews { if let sc = buscar(h) { return sc } }
            return nil
        }
        guard let raiz = contenido, let sc = buscar(raiz) else { return }
        sc.setContentOffset(CGPoint(x: 0, y: cuanto), animated: true)
    }

    private func conectarAcciones() {
        datos.onNuevoMov = { [weak self] in guard let s = self else { return }
            s.presentar(AnyView(CNNuevoMov(datos: s.datos, onClose: { s.cerrar() }))) }
        datos.onDetalleMov = { [weak self] id in guard let s = self else { return }
            s.presentar(AnyView(CNDetalleMov(datos: s.datos, movId: id, onClose: { s.cerrar() }))) }
    }

    private var hojaActual: UIViewController?
    func presentar(_ v: AnyView) {
        let host = UIHostingController(rootView: v)
        host.modalPresentationStyle = .pageSheet
        if let hoja = host.sheetPresentationController {
            hoja.detents = [.large()]
            hoja.prefersGrabberVisible = true
            hoja.preferredCornerRadius = 28
        }
        hojaActual = host
        present(host, animated: true)
    }
    func cerrar() {
        hojaActual?.dismiss(animated: true)
        hojaActual = nil
    }
}

/// Fondo de COLORES para comprobar el Liquid Glass de la barra: si es vidrio de
/// verdad, los colores se ven a través con refracción en los bordes.
struct CNPruebaColores: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [.red, .orange, .yellow, .green, .blue, .purple],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            VStack(spacing: 18) {
                ForEach(0..<9, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white.opacity(0.85))
                        .frame(height: 46)
                        .overlay(Text("Fila \(i + 1)").font(.system(size: 18, weight: .bold)).foregroundColor(.black))
                }
            }.padding(.horizontal, 20)
        }
    }
}

extension TestVC {
    /// Monta la pantalla nativa que toca capturar.
    func mostrar(_ cual: String) {
        contenido?.removeFromSuperview()
        let vista: AnyView
        switch cual {
        case "vidrio": vista = AnyView(CNPruebaColores()); estado.activa = "resumen"
        case "perfil": vista = AnyView(CNPerfil(datos: datos)); estado.activa = "perfil"
        case "periodo":
            datos.cargarPeriodo(json: TestVC.periodoDeMuestra)
            vista = AnyView(CNResumen(datos: datos)); estado.activa = "resumen"
        case "hoja-web":
            datos.cargarHojaWeb(json: TestVC.hojaDeMuestra)
            vista = AnyView(CNPerfil(datos: datos)); estado.activa = "perfil"
        case "sec-cabecera", "sec-colores", "sec-seguridad", "sec-libretas":
            datos.cargarSeccion(json: TestVC.seccionDeMuestra(String(cual.dropFirst(4))))
            vista = AnyView(CNPerfil(datos: datos)); estado.activa = "perfil"
        case "tema-claro-movs", "tema-oscuro-movs", "movs-rodado":
            vista = AnyView(CNMovs(datos: datos, rodarAlEmpezar: cual == "movs-rodado")); estado.activa = "movs"
        case "tema-claro-perfil", "tema-oscuro-perfil": vista = AnyView(CNPerfil(datos: datos)); estado.activa = "perfil"
        case "tema-claro", "tema-oscuro",
             "resumen", "organiza", "plegada", "cab-auto", "cab-clasica", "cab-detallada", "cab-fina", "cab-clara", "cab-minima", "cab-viva", "cab-viva-plegada":
            vista = AnyView(CNResumen(datos: datos, organizaAlEmpezar: cual == "organiza",
                                      rodarAlEmpezar: cual == "plegada" || cual == "cab-viva-plegada"))
            estado.activa = "resumen"
        case "cuentas": vista = AnyView(CNCuentas(datos: datos)); estado.activa = "cuentas"
        case "libretas":
            datos.cargarLibretas(json: TestVC.libretasDeMuestra)
            let d = datos
            vista = AnyView(ZStack { CNResumen(datos: d); CNHojaAbajo(onClose: {}) { CNLibretasHoja(datos: d, onClose: {}) } }); estado.activa = "resumen"
        case "puerta-auth", "puerta-plan", "puerta-lamina":
            datos.cargarPuerta(json: cual == "puerta-plan" ? TestVC.puertaPlan
                               : (cual == "puerta-lamina" ? TestVC.puertaLamina : TestVC.puertaAuth))
            vista = AnyView(CNPuertaVista(datos: datos, onAccion: { _, _ in })); estado.activa = "resumen"
        case "modo-sistema":
            // El tema llega con sus DOS paletas y el aparato cambia a oscuro:
            // lo nativo tiene que repintarse solo, sin web de por medio.
            datos.cargarTema(json: TestVC.temaConPareja)
            datos.aplicarModo(oscuro: true)
            barra.pintar(activa: "perfil", titulos: CNMenuEstado.shared.titulos)
            vista = AnyView(CNPerfil(datos: datos)); estado.activa = "perfil"
        case "mascota":
            datos.cargarMascota(json: TestVC.mascotaDeMuestra)
            vista = AnyView(ZStack { CNPerfil(datos: datos); CNMascotaVista(datos: datos, onClose: {}) })
            estado.activa = "perfil"
        case "tour":
            datos.cargarTour(json: TestVC.tourDeMuestra)
            vista = AnyView(ZStack { CNResumen(datos: datos); CNTourVista(datos: datos, onPaso: { _ in }) })
            estado.activa = "resumen"
        case "invitar":
            datos.cargarInvitar(json: TestVC.invitarDeMuestra)
            vista = AnyView(CNFormInvitar(datos: datos, libreta: "1", onClose: {})); estado.activa = "perfil"
        case "sec-libreta":
            datos.cargarSeccion(json: TestVC.seccionDeMuestra("libreta"))
            vista = AnyView(CNPerfil(datos: datos)); estado.activa = "perfil"
        case "libreta-nueva":
            datos.cargarLibretaNueva(json: TestVC.libretaNuevaDeMuestra)
            vista = AnyView(CNFormLibreta(datos: datos, onClose: {})); estado.activa = "resumen"
        case "panel-vivo":
            CNC.fmt.panelVivo = true
            vista = AnyView(CNResumen(datos: datos)); estado.activa = "resumen"
        case "fuente-outfit":
            CNC.fmt.fuente = "outfit"
            vista = AnyView(CNMovs(datos: datos)); estado.activa = "movs"
        case "menu-sin-titulos":
            CNMenuEstado.shared.titulos = false
            barra.pintar(activa: estado.activa, titulos: false)
            vista = AnyView(CNMovs(datos: datos)); estado.activa = "movs"
        case "plan", "metas":
            if cual == "metas" {
                datos.cargarPlan(json: TestVC.planDeMuestra
                    .replacingOccurrences(of: "\"tab\":\"presupuesto\"", with: "\"tab\":\"metas\"")
                    .replacingOccurrences(of: "\"Presupuesto\",\"puesta\":true", with: "\"Presupuesto\",\"puesta\":false")
                    .replacingOccurrences(of: "\"Metas\",\"puesta\":false", with: "\"Metas\",\"puesta\":true"))
            }
            vista = AnyView(CNPlan(datos: datos)); estado.activa = "plan"
        default:        vista = AnyView(CNMovs(datos: datos));    estado.activa = "movs"
        }
        let h = UIHostingController(rootView: vista)
        h.view.backgroundColor = UIColor(CNC.scr)
        addChild(h); view.addSubview(h.view); h.didMove(toParent: self)
        h.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            h.view.topAnchor.constraint(equalTo: view.topAnchor),
            h.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            h.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            h.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        contenido = h.view
        view.bringSubviewToFront(barra.barra)
        view.layoutIfNeeded()
        h.additionalSafeAreaInsets.bottom = max(0, max(barra.alto, 56) - view.safeAreaInsets.bottom)
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = TestVC()
        window?.makeKeyAndVisible()
        SceneDelegateProxy.shared.scene(scene, willConnectTo: session, options: connectionOptions)
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        SceneDelegateProxy.shared.scene(scene, openURLContexts: URLContexts)
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        SceneDelegateProxy.shared.scene(scene, continue: userActivity)
    }
}

extension TestVC {
    /// Un panel de ejemplo con todas las clases de tarjeta.
    static let fondoLlano = """
    {"tipo":"color","color":"rgb(29,61,40)"}
    """
    static let fondoDegradado = """
    {"tipo":"grad","angulo":150,"paradas":[{"color":"rgb(247,201,72)","pos":0},
      {"color":"rgb(236,154,46)","pos":0.55},{"color":"rgb(63,157,84)","pos":1}]}
    """
    static let resumenDeMuestra = """
    {"cabecera":{"inicial":"CP","nombre":"Casa · Personal","detalle":"6 movimientos · 1 cuenta",
      "color":"rgb(19,125,65)","mesCorto":"sept 2026","balanceRotulo":"Balance del mes",
      "balanceFmt":"RD$15,500","balColor":"rgb(255,255,255)","ingRotulo":"Ingresos","ingFmt":"RD$30,000",
      "gasRotulo":"Gastos","gasFmt":"RD$14,500",
      "diseno":"auto","tarjeta":false,"fondo":__FONDO__,
      "tinta":"rgb(245,245,230)","gris":"rgb(214,222,205)",
      "pastilla":"rgba(255,255,255,0.13)","pastillaFuerte":"rgba(255,255,255,0.22)",
      "rotulo":"te queda este mes","mesLargo":"Septiembre","periodoCorto":"sept 2026",
      "grande":true,"entraFmt":"RD$30,000","saleFmt":"RD$14,500",
      "hayUso":true,"usado":48,"usadoLabel":"48% usado","usadoColor":"rgb(239,203,76)",
      "abierta":true,"positivo":"rgb(19,125,65)","negativo":"rgb(213,89,72)",
      "meses":[{"indice":0,"label":"jul","puesto":false,"bg":"rgba(255,255,255,0.13)","fg":"rgb(245,245,230)"},
               {"indice":1,"label":"ago","puesto":false,"bg":"rgba(255,255,255,0.13)","fg":"rgb(245,245,230)"},
               {"indice":2,"label":"septiembre","puesto":true,"bg":"rgb(239,203,76)","fg":"rgb(32,24,10)"},
               {"indice":3,"label":"oct","puesto":false,"bg":"rgba(255,255,255,0.13)","fg":"rgb(245,245,230)"},
               {"indice":4,"label":"Rango…","puesto":false,"bg":"rgba(255,255,255,0.13)","fg":"rgb(245,245,230)"}]},
     "vacio":false,
     "catIconos":{
       "Salud":{"path":"M12 7v10M7 12h10","color":"rgb(20,158,140)"},
       "Servicios":{"path":"M13 3 5 14h6l-1 7 8-11h-6z","color":"rgb(224,169,46)"},
       "Educación":{"path":"M12 3 2 8l10 5 10-5zM6 11v5c0 1 3 2 6 2s6-1 6-2v-5","color":"rgb(130,94,185)"},
       "Ahorro":{"path":"M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18M8.5 14.5a4.5 4.5 0 0 0 7 0M9 10h.01M15 10h.01","color":"rgb(52,94,178)"},
       "Ingresos":{"path":"M4 7h16a1 1 0 0 1 1 1v9a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V8a1 1 0 0 1 1-1zM3 11h18M7 15h3","color":"rgb(19,125,65)"}},
     "tiposGrafico":[{"id":"linea","label":"Línea"},{"id":"area","label":"Área"},
       {"id":"columnas","label":"Columnas"},{"id":"barras","label":"Barras apiladas"},{"id":"puntos","label":"Puntos"}],
     "rangosGrafico":[{"id":"3","label":"3 meses"},{"id":"6","label":"6 meses"},
       {"id":"12","label":"12 meses"},{"id":"24","label":"24 meses"}],
     "catalogo":[{"id":"kpi-patrimonio","label":"Patrimonio"},{"id":"dona-mezcla","label":"Mezcla de gastos"},
       {"id":"lista-metas","label":"Avance de metas"}],
     "widgets":[
      {"indice":0,"titulo":"Ingresos del mes","clase":"cifra","chica":true,"wid":"w1","ancho":1,"puedeChica":true,
       "valor":"RD$30,000","nota":"del mes","color":"rgb(19,125,65)"},
      {"indice":1,"titulo":"Gastos del mes","clase":"cifra","chica":true,"wid":"w2","ancho":1,"puedeChica":true,
       "valor":"RD$14,500","nota":"48% de tus ingresos","color":"rgb(213,89,72)"},
      {"indice":2,"titulo":"Cómo va el dinero","clase":"serie","periodo":"6 meses","wid":"w3","ancho":2,"cfgGrafico":"linea","cfgRango":"6","series":[{"id":"ingresos","label":"Ingresos","color":"rgb(19,125,65)","puesta":true},{"id":"gastos","label":"Gastos","color":"rgb(213,89,72)","puesta":true},{"id":"balance","label":"Balance","color":"rgb(63,138,214)","puesta":false}],
       "leyenda":[{"label":"Ingresos","color":"rgb(19,125,65)","ultimo":"RD$30,000"},
                  {"label":"Gastos","color":"rgb(213,89,72)","ultimo":"RD$14,500"}],
       "guias":[{"y":11,"color":"rgb(229,225,211)"},{"y":21,"color":"rgb(229,225,211)"},{"y":31,"color":"rgb(229,225,211)"}],
       "areas":[],
       "lineas":[{"puntos":"0,28 20,22 40,25 60,14 80,18 100,6","color":"rgb(19,125,65)"},
                 {"puntos":"0,34 20,31 40,33 60,29 80,32 100,26","color":"rgb(213,89,72)"}],
       "barras":[],"puntos":[],
       "etiquetas":["abr 26","may 26","jun 26","jul 26","ago 26","sept 26"]},
      {"indice":3,"titulo":"En qué se va el dinero","clase":"barras",
       "filas":[{"label":"Educación","valor":"RD$9,000","pct":100,"color":"rgb(130,94,185)","iconoPath":"M12 3 2 8l10 5 10-5zM6 11v5c0 1 3 2 6 2s6-1 6-2v-5","iconoBg":"rgba(130,94,185,0.15)"},
                {"label":"Salud","valor":"RD$3,700","pct":41,"color":"rgb(20,158,140)","iconoPath":"M12 7v10M7 12h10","iconoBg":"rgba(20,158,140,0.15)"},
                {"label":"Servicios","valor":"RD$1,800","pct":20,"color":"rgb(20,158,140)","iconoPath":"M13 3 5 14h6l-1 7 8-11h-6z","iconoBg":"rgba(20,158,140,0.15)"}],
       "rotuloPresupuesto":"Ver el presupuesto","vaAlPresupuesto":true},
      {"indice":4,"titulo":"Tendencia","clase":"columnas","periodo":"6 meses",
       "rotuloEntra":"Ingresos","rotuloSale":"Gastos","hayMedia":true,"media":58,
       "entraColor":"rgb(19,125,65)","saleColor":"rgb(213,89,72)",
       "columnas":[{"label":"abr","a":70,"b":52,"peso":500,"color":"rgb(81,99,86)"},
                   {"label":"may","a":64,"b":60,"peso":500,"color":"rgb(81,99,86)"},
                   {"label":"jun","a":82,"b":44,"peso":500,"color":"rgb(81,99,86)"},
                   {"label":"jul","a":58,"b":70,"peso":500,"color":"rgb(81,99,86)"},
                   {"label":"ago","a":76,"b":48,"peso":500,"color":"rgb(81,99,86)"},
                   {"label":"sept","a":100,"b":48,"peso":700,"color":"rgb(19,36,25)"}]},
      {"indice":5,"titulo":"Mezcla del mes","clase":"dona","total":"RD$22,500",
       "tramos":[{"color":"rgb(29,61,40)","desde":0,"hasta":40},
                 {"color":"rgb(213,89,72)","desde":40,"hasta":75},
                 {"color":"rgb(130,94,185)","desde":75,"hasta":100}],
       "filas":[{"label":"Fijos","valor":"RD$9,000","color":"rgb(29,61,40)"},
                {"label":"Variables","valor":"RD$5,500","color":"rgb(213,89,72)"},
                {"label":"Ahorro","valor":"RD$8,000","color":"rgb(130,94,185)"}]},
      {"indice":6,"titulo":"Últimos movimientos","clase":"lista",
       "items":[{"tieneIcono":true,"iconoPath":"M12 7v10M7 12h10","color":"rgb(20,158,140)","fondo":"rgba(20,158,140,0.15)","titulo":"Médico","detalle":"Salud · 7 sept","monto":"− RD$3,700","montoColor":"rgb(213,89,72)"},
                {"tieneIcono":true,"iconoPath":"M13 3 5 14h6l-1 7 8-11h-6z","color":"rgb(20,158,140)","fondo":"rgba(20,158,140,0.15)","titulo":"Agua y basura","detalle":"Servicios · 6 sept","monto":"− RD$1,800","montoColor":"rgb(213,89,72)"},
                {"tieneIcono":false,"sigla":"SQ","siglaColor":"rgb(255,255,255)","fondo":"rgb(19,125,65)","titulo":"Sueldo quincena","detalle":"Ingresos · 3 sept","monto":"+ RD$30,000","montoColor":"rgb(19,125,65)"}]},
      {"indice":7,"titulo":"Un consejo","clase":"texto",
       "texto":"Sin cuotas este mes: buen momento para aportar a tus metas."}
     ]}
    """
}

extension TestVC {
    /// Los ajustes de ejemplo: los mismos grupos que arma la web.
    static let ajustesDeMuestra = """
    {"usuario":{"inicial":"GR","nombre":"Gelson Reynoso","correo":"gelson@fente.com.do",
      "plan":"Plan Chinola","planColor":"rgb(112,84,24)","modoLabel":"En la nube",
      "modoBg":"rgba(19,125,65,0.14)","modoFg":"rgb(19,125,65)",
      "modoPie":"Tus libretas se guardan en tu cuenta y las ves igual en la web.",
      "acento":"rgb(239,203,76)","sobreAcento":"rgb(32,24,10)"},
     "grupos":[
      {"titulo":"Cuenta","filas":[
        {"label":"Mi cuenta","sub":"gelson@fente.com.do","valor":"","icono":"M12 11a4 4 0 1 0 0-8 4 4 0 0 0 0 8M4 21a8 8 0 0 1 16 0","bg":"rgba(52,110,74,0.14)","fg":"rgb(52,110,74)","entra":true},
        {"label":"Seguridad","sub":"Dos pasos y aparatos conectados","valor":"","icono":"M12 3l8 3v6c0 5-4 8-8 9-4-1-8-4-8-9V6zM9 12l2 2 4-4","bg":"rgba(58,80,168,0.14)","fg":"rgb(58,80,168)","entra":true},
        {"label":"Libretas y permisos","sub":"Quién ve y quién edita cada libreta","valor":"3","icono":"M4 4h11a3 3 0 0 1 3 3v13H7a3 3 0 0 1-3-3zM18 7h2v13H7","bg":"rgba(52,94,178,0.14)","fg":"rgb(52,94,178)","entra":true}]},
      {"titulo":"Apariencia","filas":[
        {"label":"Panel del resumen","sub":"Qué tarjetas hay y en qué orden","valor":"","icono":"M4 4h7v7H4zM13 4h7v4h-7zM13 10h7v10h-7zM4 13h7v7H4z","bg":"rgba(52,110,74,0.14)","fg":"rgb(52,110,74)","entra":true},
        {"label":"Cabecera","sub":"Qué se ve arriba y de qué color","valor":"Automática","icono":"M4 5h16a1 1 0 0 1 1 1v3H3V6a1 1 0 0 1 1-1zM3 9v9a1 1 0 0 0 1 1h16a1 1 0 0 0 1-1V9","bg":"rgba(58,80,168,0.14)","fg":"rgb(58,80,168)","entra":true},
        {"label":"Letra","sub":"Tipografía y tamaño del texto","valor":"Del sistema","icono":"M5 20l6.2-16h1.6L19 20M8 14h8","bg":"rgba(122,66,168,0.14)","fg":"rgb(122,66,168)","entra":true},
        {"label":"Colores","sub":"El tema de toda la app","valor":"Chinola","icono":"M12 21a9 9 0 1 1 0-18c4.9 0 9 3.4 9 7.5 0 2.5-2 4.5-4.5 4.5H15a2 2 0 0 0-1.6 3.2c.3.4.4.8.4 1.2 0 .9-.8 1.6-1.8 1.6M7.5 10.5h.01M11 7.5h.01M15.5 9h.01","bg":"rgba(196,71,60,0.14)","fg":"rgb(196,71,60)","entra":true},
        {"label":"Dinero","sub":"Moneda y cómo se escriben las cifras","valor":"DOP","icono":"M12 2v20M17 6.5c0-1.9-2.2-3-5-3s-5 1.1-5 3 2.2 2.8 5 3.4 5 1.5 5 3.6-2.2 3-5 3-5-1.1-5-3","bg":"rgba(140,106,26,0.14)","fg":"rgb(140,106,26)","entra":true},
        {"label":"Tu personaje","sub":"La chinola que te acompaña","valor":"","icono":"M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18M9 10h.01M15 10h.01M8.5 14.5a4.5 4.5 0 0 0 7 0","bg":"rgba(86,110,32,0.14)","fg":"rgb(86,110,32)","entra":true}]},
      {"titulo":"App","filas":[
        {"label":"Idioma","sub":"","valor":"Español","icono":"M4 5h11M9 3v2c0 5-2.4 8.5-6 10M6 10c0 2.6 3 5.5 8 6M13 21l4.5-10 4.5 10M15 17.5h5","bg":"rgba(52,94,178,0.14)","fg":"rgb(52,94,178)","entra":false,
         "lista":[{"id":"Español","label":"Español"},{"id":"English","label":"English"},{"id":"Français","label":"Français"}],"listaValor":"Español"},
        {"label":"Notificaciones","sub":"Aviso antes de cada pago","valor":"Puestas","icono":"M18 8a6 6 0 1 0-12 0c0 7-3 9-3 9h18s-3-2-3-9M13.7 21a2 2 0 0 1-3.4 0","bg":"rgba(140,106,26,0.14)","fg":"rgb(140,106,26)","entra":false}]},
      {"titulo":"Datos","filas":[
        {"label":"Exportar","sub":"Todos tus movimientos en un CSV","valor":"","icono":"M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4M7 10l5 5 5-5M12 15V3","bg":"rgb(249,245,230)","fg":"rgb(81,99,86)","entra":false},
        {"label":"Importar movimientos","sub":"Traer movimientos de otra app o del banco","valor":"CSV","icono":"M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4M7 9l5-5 5 5M12 4v12","bg":"rgb(249,245,230)","fg":"rgb(81,99,86)","entra":false},
        {"label":"Integraciones","sub":"Conectar Chinola con otras apps","valor":"","icono":"M10 13a5 5 0 0 0 7 0l3-3a5 5 0 0 0-7-7l-1.5 1.5M14 11a5 5 0 0 0-7 0l-3 3a5 5 0 0 0 7 7l1.5-1.5","bg":"rgba(122,66,168,0.14)","fg":"rgb(122,66,168)","entra":true}]},
      {"titulo":"Ayuda","pie":"Versión 1.1.24 · 19 sept 2026","filas":[
        {"label":"Ver el tour","sub":"Repasar cómo funciona la app","valor":"","icono":"M12 22a10 10 0 1 0 0-20 10 10 0 0 0 0 20M10 8l6 4-6 4z","bg":"rgb(249,245,230)","fg":"rgb(81,99,86)","entra":false},
        {"label":"Ayuda y guía","sub":"Preguntas frecuentes y cómo se usa","valor":"","icono":"M12 22a10 10 0 1 0 0-20 10 10 0 0 0 0 20M9.1 9a3 3 0 0 1 5.8 1c0 2-3 3-3 3M12 17h.01","bg":"rgb(249,245,230)","fg":"rgb(81,99,86)","entra":true},
        {"label":"Privacidad y términos","sub":"Qué se guarda y qué no","valor":"","icono":"M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z","bg":"rgb(249,245,230)","fg":"rgb(81,99,86)","entra":true}]},
      {"filas":[
        {"label":"Cerrar sesión","sub":"","valor":"","icono":"M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4M16 17l5-5-5-5M21 12H9","bg":"rgba(213,89,72,0.14)","fg":"rgb(213,89,72)","tinta":"rgb(213,89,72)","entra":false}]}
     ]}
    """
}

extension TestVC {
    /// Secciones de ejemplo para mirarlas sin la web detrás.
    static func seccionDeMuestra(_ id: String) -> String {
        switch id {
        case "colores":
            var ops = ""
            let temas = [("Chinola", "rgb(239,203,76)"), ("Hoja", "rgb(63,157,84)"), ("Semillas", "rgb(140,106,26)"),
                         ("Tinta", "rgb(40,40,40)"), ("Niebla", "rgb(120,140,165)"), ("Flor de chinola", "rgb(170,110,190)"),
                         ("Pulpa", "rgb(230,150,60)"), ("Cáscara", "rgb(120,160,60)"), ("Coral", "rgb(224,120,100)"),
                         ("Índigo", "rgb(90,100,200)"), ("Noche", "rgb(60,70,80)"), ("Carbón", "rgb(45,45,45)")]
            for (i, t) in temas.enumerated() {
                ops += (i > 0 ? "," : "") + "{\"label\":\"\(t.0)\",\"color\":\"\(t.1)\",\"puesta\":\(i == 0),\"accion\":\(i)}"
            }
            return "{\"id\":\"colores\",\"titulo\":\"Colores\",\"bloques\":[{\"tipo\":\"opciones\",\"titulo\":\"El tema de toda la app\",\"columnas\":2,\"opciones\":[\(ops)]}]}"
        case "libreta":
            return """
            {"id":"libreta:1","titulo":"Familia","volverA":"libretas",
             "menu":[{"label":"Abrir","accion":4},{"label":"Editar","abre":"hoja:libreta:1","accion":-1},{"label":"Invitar a alguien","abre":"hoja:invitar:1","accion":-1},{"label":"Eliminar la libreta","peligro":true,"accion":5}],
             "bloques":[
              {"tipo":"lista","titulo":"","items":[
                {"titulo":"Familia","detalle":"Familiar · Dueño","color":"rgb(255,255,255)","fondo":"rgb(122,79,208)","chip":"En uso","chipFondo":"rgb(249,245,230)"}]},
              {"tipo":"grupo","titulo":"Este mes","filas":[
                {"label":"Balance del mes","valor":"−RD$2,400","tinta":"rgb(213,89,72)"},
                {"label":"Ingresos del mes","valor":"RD$80,000","tinta":"rgb(19,125,65)"},
                {"label":"Gastos del mes","valor":"RD$82,400","tinta":"rgb(213,89,72)"},
                {"label":"Deuda total","valor":"RD$336,000","tinta":"rgb(224,169,46)"}]},
              {"tipo":"lista","titulo":"Miembros · 2 personas","botones":[{"label":"Abrir","estilo":"acento","accion":4},{"label":"+ Invitar","estilo":"suave","abre":"hoja:invitar:1","accion":-1}],"items":[
                {"titulo":"Gelson (tú)","detalle":"gelson@correo.do","chip":"Dueño","chipFondo":"rgb(249,245,230)","color":"rgb(255,255,255)","fondo":"rgb(52,110,74)"},
                {"titulo":"Ana","detalle":"ana@correo.do","chip":"Editor","chipFondo":"rgb(249,245,230)","color":"rgb(255,255,255)","fondo":"rgb(52,94,178)",
                 "acciones":[{"label":"Hacer Registrador","accion":1},{"label":"Hacer Lector","accion":2},{"label":"Quitar de la libreta","peligro":true,"accion":3}]}]}]}
            """
        case "cabecera":
            return """
            {"id":"cabecera","titulo":"Cabecera","bloques":[
              {"tipo":"opciones","titulo":"Qué se ve arriba","columnas":2,"opciones":[
                {"label":"Automática","sub":"Se pliega al bajar","puesta":true,"accion":0,"vista":{"tipo":"cabecera","franja":"rgb(29,61,40)","alto":30,"bulto":true,"papel":"rgb(250,247,236)"}},
                {"label":"Clásica","sub":"Con balance plegable","puesta":false,"accion":1,"vista":{"tipo":"cabecera","franja":"rgb(29,61,40)","alto":26,"bulto":true,"papel":"rgb(250,247,236)"}},
                {"label":"Detallada","sub":"Todo a la vista","puesta":false,"accion":2,"vista":{"tipo":"cabecera","franja":"rgb(29,61,40)","alto":30,"bulto":false,"papel":"rgb(250,247,236)"}},
                {"label":"Fina","sub":"Una sola línea","puesta":false,"accion":3,"vista":{"tipo":"cabecera","franja":"rgb(29,61,40)","alto":14,"bulto":false,"papel":"rgb(250,247,236)"}},
                {"label":"Clara","sub":"Del color de la pantalla","puesta":false,"accion":4,"vista":{"tipo":"cabecera","franja":"rgb(250,247,236)","alto":14,"bulto":false,"papel":"rgb(250,247,236)"}},
                {"label":"Mínima","sub":"Lo justo","puesta":false,"accion":5,"vista":{"tipo":"cabecera","franja":"rgb(250,247,236)","alto":12,"bulto":false,"papel":"rgb(250,247,236)"}}
              ]},
              {"tipo":"muestras","titulo":"Color de la cabecera","colores":[
                {"nombre":"Del tema","css":"rgb(29,61,40)","puesta":true,"accion":6},
                {"nombre":"Chinola","css":"linear-gradient(150deg, #f7c948, #ec9a2e 55%, #3f9d54)","accion":7},
                {"nombre":"Mango","css":"linear-gradient(150deg, #f9c04b, #ef8a2c)","accion":8},
                {"nombre":"Lima","css":"linear-gradient(150deg, #cfe95f, #85bb3e)","accion":9},
                {"nombre":"Océano","css":"linear-gradient(150deg, #3f8ad0, #1f4f89)","accion":10},
                {"nombre":"Ciruela","css":"linear-gradient(150deg, #834fa6, #47256e)","accion":11},
                {"nombre":"Coral","css":"linear-gradient(150deg, #ea6a52, #c0343c)","accion":12},
                {"nombre":"Carbón","css":"linear-gradient(150deg, #2a2e2b, #141714)","accion":13}]},
              {"tipo":"interruptores","titulo":"","items":[{"label":"Esquinas redondeadas","sub":"Con las esquinas de abajo redondeadas, como una tarjeta","puesto":false,"accion":14},{"label":"Integrada","sub":"Sin color propio: toma el fondo de la pantalla.","puesto":false,"accion":15}]},
              {"tipo":"interruptores","titulo":"El menú de abajo","items":[{"label":"Nombres en el menú","sub":"El rótulo debajo de cada icono","puesto":true,"accion":16}]}]}
            """
        case "seguridad":
            return """
            {"id":"seguridad","titulo":"Seguridad","bloques":[
              {"tipo":"grupo","filas":[
                {"label":"Cambiar mi contraseña","valor":"","icono":"M5 11h14v10H5zM8 11V7a4 4 0 0 1 8 0v4","bg":"rgba(196,124,44,0.14)","fg":"rgb(196,124,44)","entra":true,"accion":0},
                {"label":"Verificación en dos pasos","valor":"Activada","tinta":"rgb(19,125,65)","icono":"M3 6h18v12H3zM3 8l9 6 9-6M12 20v2","bg":"rgba(58,80,168,0.14)","fg":"rgb(58,80,168)","entra":true,"accion":1}]},
              {"tipo":"lista","titulo":"Aparatos conectados","items":[
                {"titulo":"iPhone de Gelson","detalle":"Esta sesión · Santo Domingo","icono":"M7 2h10a2 2 0 0 1 2 2v16a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2M10 19h4","color":"rgb(19,36,25)","fondo":"rgb(249,245,230)"},
                {"titulo":"Chrome en Windows","detalle":"Hace 2 días","icono":"M3 4h18v12H3zM8 20h8M12 16v4","color":"rgb(19,36,25)","fondo":"rgb(249,245,230)","acciones":[{"label":"Cerrar","peligro":true,"accion":2}]}]},
              {"tipo":"lista","titulo":"Actividad reciente","items":[
                {"titulo":"Entraste desde iPhone","detalle":"Hoy, 9:12"},
                {"titulo":"Cambiaste la contraseña","detalle":"12 sept"}]}]}
            """
        default:
            return """
            {"id":"libretas","titulo":"Libretas y permisos","bloques":[
              {"tipo":"lista","items":[
                {"titulo":"Casa · Personal","detalle":"6 movimientos · 1 cuenta","fondo":"rgb(19,125,65)","chip":"Dueño","chipFondo":"rgb(249,245,230)","accion":0,
                 "acciones":[{"label":"Editar","accion":1}]},
                {"titulo":"Negocio","detalle":"Compartida con 2 personas","fondo":"rgb(63,138,214)","chip":"Dueño","chipFondo":"rgb(249,245,230)","accion":2,
                 "acciones":[{"label":"Editar","accion":3},{"label":"Salir de la libreta","peligro":true,"accion":4}]},
                {"titulo":"Familia","detalle":"Te invitó Ana","fondo":"rgb(130,94,185)","chip":"Invitación","chipFondo":"rgb(249,245,230)",
                 "acciones":[{"label":"Aceptar","accion":5},{"label":"Rechazar","peligro":true,"accion":6}]}]},
              {"tipo":"boton","label":"Nueva libreta","estilo":"acento","accion":7}]}
            """
        }
    }
}

extension TestVC {
    /// Una hoja de la web de ejemplo (nueva libreta), con sus tres tipos de
    /// campo: texto, color e icono.
    static let hojaDeMuestra = """
    {"tipo":"libreta","titulo":"Nueva libreta","texto":"Una libreta para cada parte de tu vida: casa, negocio, viajes.",
     "boton":"Crear libreta","error":"","ok":"","cargando":false,
     "campos":[
       {"indice":0,"label":"Nombre","tipo":"text","ph":"Casa","valor":"","teclado":"text","seguro":false},
       {"indice":1,"label":"Para qué es","tipo":"text","ph":"","valor":"personal","teclado":"text","seguro":false,
        "opciones":[{"id":"personal","label":"Personal"},{"id":"negocio","label":"Negocio"},{"id":"viaje","label":"Viaje"}]},
       {"indice":2,"label":"Color","tipo":"color","valor":"","teclado":"text","seguro":false,
        "colores":[{"indice":0,"color":"#137d41","puesta":true},{"indice":1,"color":"#2f6fd6"},{"indice":2,"color":"#825eb9"},
                   {"indice":3,"color":"#d55948"},{"indice":4,"color":"#e0a92e"},{"indice":5,"color":"#5a7a2e"}]},
       {"indice":3,"label":"Icono","tipo":"icono","valor":"","teclado":"text","seguro":false,
        "iconos":[{"indice":0,"clave":"casa","label":"Casa","path":"M4 21V9l8-6 8 6v12M9 21v-6h6v6","puesta":true},
                  {"indice":1,"clave":"banco","label":"Banco","path":"M4 7h16a1 1 0 0 1 1 1v9a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V8a1 1 0 0 1 1-1zM3 11h18M7 15h3"},
                  {"indice":2,"clave":"avion","label":"Viaje","path":"M12 2l3 8 7 2-7 2-3 8-3-8-7-2 7-2z"},
                  {"indice":3,"clave":"regalo","label":"Regalo","path":"M4 11h16v10H4zM2 7h20v4H2zM12 7v14M12 7S9 2 7 4s5 3 5 3M12 7s3-5 5-3-5 3-5 3"}]}
     ]}
    """
}

extension TestVC {
    /// El periodo de ejemplo, con el calendario abierto y un rango a medias.
    static let periodoDeMuestra: String = {
        var dias = ""
        // Septiembre de 2026 empieza en martes: dos huecos del mes anterior.
        for i in 0..<35 {
            let n = i - 1
            let dentro = n >= 1 && n <= 30
            let num = dentro ? n : (n < 1 ? 30 + n : n - 30)
            let esInicio = n == 5, esFin = n == 14
            let enRango = n > 5 && n < 14
            let banda = (esInicio || esFin || enRango) ? "rgba(239,203,76,0.26)" : "rgba(0,0,0,0)"
            let radio = esInicio ? "999px 0 0 999px" : (esFin ? "0 999px 999px 0" : "0")
            let circ = (esInicio || esFin) ? "rgb(239,203,76)" : "rgba(0,0,0,0)"
            let tinta = (esInicio || esFin) ? "rgb(32,24,10)" : "rgb(19,36,25)"
            dias += (i > 0 ? "," : "")
                + "{\"indice\":\(i),\"n\":\(num),\"banda\":\"\(banda)\",\"bandaRadio\":\"\(radio)\","
                + "\"circulo\":\"\(circ)\",\"tinta\":\"\(tinta)\",\"fuerte\":\(esInicio || esFin),"
                + "\"opacidad\":\(dentro ? 1 : 0.28)}"
        }
        return """
        {"abierto":true,"calendario":true,"resumen":"14 movimientos en este periodo",
         "opciones":[
           {"indice":0,"label":"Este mes","puesta":true,"fondo":"rgb(29,61,40)","tinta":"rgb(245,245,230)","borde":"rgb(29,61,40)"},
           {"indice":1,"label":"Mes pasado","fondo":"rgba(0,0,0,0)","tinta":"rgb(19,36,25)","borde":"rgb(229,225,211)"},
           {"indice":2,"label":"Este año","fondo":"rgba(0,0,0,0)","tinta":"rgb(19,36,25)","borde":"rgb(229,225,211)"},
           {"indice":3,"label":"Últimos 3 meses","fondo":"rgba(0,0,0,0)","tinta":"rgb(19,36,25)","borde":"rgb(229,225,211)"},
           {"indice":4,"label":"Últimos 12 meses","fondo":"rgba(0,0,0,0)","tinta":"rgb(19,36,25)","borde":"rgb(229,225,211)"},
           {"indice":5,"label":"Personalizado","fondo":"rgba(0,0,0,0)","tinta":"rgb(19,36,25)","borde":"rgb(229,225,211)"}],
         "calTitulo":"Septiembre 2026",
         "diasSemana":["D","L","M","M","J","V","S"],
         "dias":[\(dias)],
         "seleccion":"5 – 14 de septiembre","textoAplicar":"Aplicar","puedeAplicar":true}
        """
    }()
}

extension TestVC {
    /// Los dos temas de fábrica: los grises de iOS con la marca encima.
    static let temaSistemaClaro = """
    {"bg":"rgb(240,240,243)","card":"rgb(255,255,255)","suave":"rgb(230,230,233)",
     "borde":"rgb(212,212,215)","tinta":"rgb(26,26,28)","gris":"rgb(107,107,111)",
     "side":"rgb(6,68,37)","acento":"rgb(251,213,48)",
     "pos":"rgb(19,125,65)","neg":"rgb(213,89,72)","info":"rgb(43,126,201)","oscuro":false}
    """
    static let temaSistemaOscuro = """
    {"bg":"rgb(0,0,0)","card":"rgb(26,26,28)","suave":"rgb(43,43,45)",
     "borde":"rgb(61,61,63)","tinta":"rgb(240,240,243)","gris":"rgb(152,152,157)",
     "side":"rgb(0,28,11)","acento":"rgb(251,213,48)",
     "pos":"rgb(77,191,116)","neg":"rgb(239,128,111)","info":"rgb(90,160,230)","oscuro":true}
    """
}

extension TestVC {
    static let cuentasDeMuestra = """
    {"titulo":"Cuentas","oculto":false,
     "patrimonio":{"titulo":"Patrimonio","valor":"−RD$185,000","activosLabel":"Activos","activos":"RD$151,000",
       "pasivosLabel":"Pasivos","pasivos":"RD$336,000","fondo":"rgb(41,45,43)","tinta":"rgb(245,245,230)"},
     "rotuloCuentas":"Cuentas","rotuloTarjetas":"Tarjetas de crédito","rotuloPrestamos":"Préstamos",
     "totales":{"cuentas":{"rotulo":"Tienes","valor":"RD$105,378","tinta":"rgb(19,125,65)"},
                "tarjetas":{"rotulo":"Debes","valor":"RD$44,496","tinta":"rgb(213,89,72)"},
                "prestamos":{"rotulo":"Debes","valor":"RD$180,000","tinta":"rgb(213,89,72)"}},
     "cuentas":[
       {"indice":0,"nombre":"Cuenta principal","detalle":"Banreservas · 73 movs","valor":"RD$54,800",
        "iconoPath":"M4 21V9l8-6 8 6v12M9 21v-6h6v6","color":"rgb(52,110,74)","fondo":"rgba(52,110,74,0.15)"},
       {"indice":1,"nombre":"Ahorros","detalle":"Banco Popular · 0 movs","valor":"RD$92,000",
        "iconoPath":"M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18M8.5 14.5a4.5 4.5 0 0 0 7 0M9 10h.01M15 10h.01","color":"rgb(52,94,178)","fondo":"rgba(52,94,178,0.15)"},
       {"indice":2,"nombre":"Efectivo","detalle":"En mano · 0 movs","valor":"RD$4,200",
        "iconoPath":"M4 7h16a1 1 0 0 1 1 1v9a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V8a1 1 0 0 1 1-1zM3 11h18M7 15h3","color":"rgb(176,140,40)","fondo":"rgba(176,140,40,0.15)"}],
     "tarjetas":[
       {"indice":0,"nombre":"Visa Clásica","valor":"RD$18,600","pie":"23% del límite · pago en 16 d","uso":23,
        "usoColor":"rgb(19,125,65)","iconoPath":"M4 7h16a1 1 0 0 1 1 1v9a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V8a1 1 0 0 1 1-1zM3 11h18M7 15h3",
        "color":"rgb(52,94,178)","fondo":"rgba(52,94,178,0.15)","tintaValor":"rgb(213,89,72)"},
       {"indice":1,"nombre":"Mastercard Gold","valor":"RD$43,200","pie":"29% del límite · pago en 26 d","uso":29,
        "usoColor":"rgb(19,125,65)","iconoPath":"M4 7h16a1 1 0 0 1 1 1v9a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V8a1 1 0 0 1 1-1zM3 11h18M7 15h3",
        "color":"rgb(130,94,185)","fondo":"rgba(130,94,185,0.15)","tintaValor":"rgb(213,89,72)"}],
     "prestamos":[
       {"indice":0,"nombre":"Préstamo del carro","valor":"RD$135,000","pie":"12 de 24 cuotas","uso":50,
        "usoColor":"rgb(130,94,185)","iconoPath":"M3 8h13l-3-3M21 16H8l3 3","color":"rgb(130,94,185)",
        "fondo":"rgba(130,94,185,0.15)","tintaValor":"rgb(213,89,72)"}]}
    """
    static let movDeMuestra = """
    {"nombre":"Préstamo del carro","rotulo":"Salió","montoFmt":"RD$9,800","color":"rgb(213,89,72)",
     "iconoPath":"M4 7h16a1 1 0 0 1 1 1v9a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V8a1 1 0 0 1 1-1zM3 11h18M7 15h3",
     "iconoColor":"rgb(213,89,72)","iconoBg":"rgba(213,89,72,0.15)","puedeEditar":true,
     "textoEditar":"Editar","textoDuplicar":"Duplicar",
     "datos":[{"label":"Categoría","valor":"Deudas"},{"label":"Tipo","valor":"Fijo"},
              {"label":"Fecha","valor":"11 de septiembre"},{"label":"Pagado con","valor":"Cuenta principal"},
              {"label":"Se repite","valor":"Cada mes"}]}
    """
}

extension TestVC {
    static let temaConPareja = """
    {"bg":"oklch(0.975 0.015 95)","card":"#fff","suave":"oklch(0.97 0.02 95)",
     "borde":"oklch(0.91 0.02 95)","tinta":"oklch(0.24 0.03 155)","gris":"oklch(0.48 0.03 155)",
     "side":"oklch(0.255 0.038 156)","acento":"rgb(239,203,76)","pos":"rgb(19,125,65)",
     "neg":"rgb(213,89,72)","info":"rgb(57,138,214)","oscuro":false,
     "pareja":{"claro":{"bg":"oklch(0.975 0.015 95)","card":"#fff","suave":"oklch(0.97 0.02 95)",
                        "borde":"oklch(0.91 0.02 95)","tinta":"oklch(0.24 0.03 155)",
                        "gris":"oklch(0.48 0.03 155)","side":"oklch(0.255 0.038 156)","oscuro":false},
               "oscuro":{"bg":"oklch(0.20 0.02 155)","card":"oklch(0.25 0.025 155)","suave":"oklch(0.29 0.03 155)",
                         "borde":"oklch(0.34 0.03 155)","tinta":"oklch(0.94 0.02 95)",
                         "gris":"oklch(0.72 0.02 110)","side":"oklch(0.16 0.02 155)","oscuro":true}}}
    """
}

extension TestVC {
    static let puertaAuth = """
    {"paso":"auth","registro":true,"rotulo":"Empecemos","titulo":"Crea tu cuenta",
     "texto":"Con cuenta respaldas tus libretas y las ves igual en la web.",
     "labelNombre":"Nombre","labelCorreo":"Correo","labelClave":"Contraseña","labelClave2":"Repite la contraseña",
     "phCorreo":"tucorreo@mail.com","phClave2":"La misma de arriba",
     "nombre":"","email":"","clave":"","clave2":"","boton":"Crear mi cuenta",
     "error":"","oDirecto":"o entra directo con","google":"Google","apple":"Apple",
     "conApple":true,"conGoogle":true,"olvide":"","cambiar":"Ya tengo cuenta","sinCuenta":"Usar sin cuenta"}
    """
    static let puertaPlan = """
    {"paso":"plan","rotulo":"Casi está","titulo":"¿Con qué plan empiezas?",
     "texto":"Puedes cambiarlo cuando quieras desde Perfil. El gratis no caduca.",
     "boton":"Seguir","salida":"Ahora no","error":"","pie":"",
     "planes":[{"indice":0,"id":"gratis","nombre":"Gratis","para":"Para empezar","precio":"RD$0","cada":"",
                "items":["Una libreta","Movimientos, cuentas, tarjetas y préstamos sin límite","Todo en este teléfono y en la web"],"puesto":true},
               {"indice":1,"id":"pro","nombre":"Pro","para":"Para tu casa","precio":"US$3.99","cada":"al mes",
                "items":["Libretas sin límite: la casa, el negocio, lo tuyo","Compartirlas con quien quieras, con permisos"],"puesto":false}]}
    """
    static let puertaLamina = """
    {"paso":"lamina","rotulo":"Así funciona","titulo":"Anota y ya está",
     "texto":"Un toque en el + y listo. Chinola arma los gráficos, los totales y el resto por ti.",
     "boton":"Siguiente","segundo":"Saltar","atras":"Atrás","indice":0,"total":3,
     "lista":[{"titulo":"Cuentas, tarjetas y fiados","pie":"Todo tu dinero en un solo lugar",
               "iconoPath":"M3 8h18v12H3zM9 8V5h6v3M3 13h18","color":"rgb(52,94,178)","fondo":"rgba(52,94,178,0.14)"},
              {"titulo":"Presupuesto por categoría","pie":"Con aviso cuando te pasas del presupuesto",
               "iconoPath":"M4 20V10M10 20V4M16 20v-7M22 20H2","color":"rgb(130,94,185)","fondo":"rgba(130,94,185,0.14)"},
              {"titulo":"Metas de ahorro","pie":"Mira cuánto falta y en cuántos meses",
               "iconoPath":"M12 3v18M5 8h14M5 16h14","color":"rgb(19,125,65)","fondo":"rgba(19,125,65,0.14)"}]}
    """
}

extension TestVC {
    static let mascotaDeMuestra = """
    {"chinolo":"","tituloAvisos":"Lo que viene","verAvisos":"Tócame para ver los pagos",
     "volver":"Toca para volver","nadaTexto":"No tienes pagos cerca. Todo tranquilo.",
     "avisos":[{"titulo":"Pago Visa Clásica","detalle":"RD$18,600 · en 5 d","color":"rgb(224,169,46)"},
               {"titulo":"Cuota Préstamo del carro","detalle":"RD$9,800 · hoy","color":"rgb(213,89,72)"},
               {"titulo":"Pago Mastercard","detalle":"RD$4,200 · en 12 d","color":"rgb(19,125,65)"}]}
    """
}

extension TestVC {
    static let tourDeMuestra = """
    {"paso":1,"total":5,"vista":"resumen","titulo":"Anota en dos toques",
     "texto":"El botón amarillo abre el formulario con la cuenta y la categoría que más usas ya puestas.",
     "textoSiguiente":"Siguiente","textoSaltar":"Saltar"}
    """
}

extension TestVC {
    static let invitarDeMuestra = """
    {"titulo":"Invitar a alguien","phEmail":"Su correo","phNombre":"Su nombre (opcional)",
     "rotuloRol":"Permisos","boton":"Invitar",
     "pie":"Le llega un correo con la invitación. Hasta que la acepte, no ve nada.",
     "roles":[{"id":"Editor","label":"Editor","sub":"Puede anotar y cambiarlo todo"},
              {"id":"Registrador","label":"Registrador","sub":"Solo puede anotar movimientos"},
              {"id":"Lector","label":"Lector","sub":"Solo mira, no toca nada"}]}
    """
}

extension TestVC {
    static let libretaNuevaDeMuestra = """
    {"titulo":"Nueva libreta","rotuloNombre":"Nombre","phNombre":"Nombre (ej. La casa)",
     "rotuloTipo":"Tipo","rotuloIcono":"Icono",
     "tipos":[{"id":"Personal","label":"Personal"},{"id":"Familiar","label":"Familiar"},
              {"id":"Negocio","label":"Negocio"},{"id":"Proyecto","label":"Proyecto"}],
     "colores":["rgb(19,125,65)","rgb(47,111,214)","rgb(122,79,208)","rgb(224,130,46)","rgb(198,95,156)","rgb(90,122,46)"],
     "coloresId":["a","b","c","d","e","f"],
     "iconos":[{"id":"casa","label":"Casa","path":"M3 10.5L12 3l9 7.5M5 9.5V21h14V9.5M10 21v-6h4v6"},
               {"id":"gente","label":"Familia","path":"M9 11a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7M2 21a7 7 0 0 1 14 0M17 11a3 3 0 1 0 0-6M18 21a6.5 6.5 0 0 0-2-4.7"},
               {"id":"maletin","label":"Negocio","path":"M3 8h18v12H3zM9 8V5h6v3M3 13h18"},
               {"id":"estrella","label":"Metas","path":"M12 3l2.7 5.6 6.3.9-4.5 4.4 1 6.1-5.5-2.9-5.5 2.9 1-6.1L3 9.5l6.3-.9z"}]}
    """
}

extension TestVC {
    static let libretasDeMuestra = """
    {"titulo":"Libretas","textoGestionar":"Libretas y permisos",
     "rotuloOtras":"Cambiar de libreta",
     "filas":[
       {"indice":0,"nombre":"Familia","detalle":"Familiar · 2 personas","cifra":"−RD$2,400","cifraTinta":"rgb(213,89,72)","pie":"34 movimientos","color":"oklch(0.52 0.19 300)",
        "iconoPath":"M9 11a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7M2 21a7 7 0 0 1 14 0M17 11a3 3 0 1 0 0-6M18 21a6.5 6.5 0 0 0-2-4.7",
        "enUso":false,"rotuloEnUso":"En uso"},
       {"indice":1,"nombre":"Personal","detalle":"Personal","cifra":"RD$24,500","cifraTinta":"rgb(19,125,65)","pie":"128 movimientos","color":"rgb(19,125,65)",
        "iconoPath":"M3 10.5L12 3l9 7.5M5 9.5V21h14V9.5M10 21v-6h4v6",
        "enUso":true,"rotuloEnUso":"En uso"},
       {"indice":2,"nombre":"Colmado La Esquina","detalle":"Negocio · 2 personas","cifra":"RD$81,200","cifraTinta":"rgb(19,125,65)","pie":"210 movimientos","color":"rgb(52,94,178)",
        "iconoPath":"M3 8h18v12H3zM9 8V5h6v3M3 13h18",
        "enUso":false,"rotuloEnUso":"En uso"}]}
    """
}

extension TestVC {
    static let planDeMuestra = """
    {"titulo":"Plan","listo":true,"tab":"presupuesto","puedeEditar":true,"puedeRegistrar":true,
     "tabs":[{"indice":0,"label":"Presupuesto","puesta":true},{"indice":1,"label":"Metas","puesta":false}],
     "presGastado":"RD$82,400","presDe":"de","presTotal":"RD$88,000","presPct":94,"presColor":"rgb(224,169,46)",
     "presNota":"2 categorías sobre el presupuesto","presAvisoTinta":"rgb(224,169,46)",
     "tituloCategorias":"Categorías","rotuloNuevaCat":"Categoría",
     "tituloTusMetas":"Tus metas","rotuloNuevaMeta":"Meta",
     "filas":[
       {"indice":0,"nombre":"Vivienda","queda":"RD$1,200","pie":"RD$8,800 de RD$10,000","pct":88,
        "color":"rgb(19,125,65)","iconoPath":"M4 21V9l8-6 8 6v12M9 21v-6h6v6","catColor":"rgb(52,110,74)","iconoBg":"oklab(0.51 -0.09 0.05 / 0.15)"},
       {"indice":1,"nombre":"Alimentación","queda":"−RD$1,400","pie":"RD$13,400 de RD$12,000","pct":100,
        "color":"rgb(213,89,72)","iconoPath":"M6 3v8a3 3 0 0 0 6 0V3M9 11v10M18 3c-1.5 2-2 4-2 6v4h3v8","catColor":"rgb(196,124,44)","iconoBg":"color(srgb 0.77 0.49 0.17 / 0.15)"},
       {"indice":2,"nombre":"Transporte","queda":"RD$0","pie":"RD$6,000 de RD$6,000","pct":100,
        "color":"rgb(224,169,46)","iconoPath":"M5 17h14M6 17V9l2-4h8l2 4v8M7 13h10","catColor":"rgb(52,94,178)","iconoBg":"rgba(52,94,178,0.15)"},
       {"indice":3,"nombre":"Salud","queda":"","pie":"RD$2,000 · sin presupuesto","pct":0,
        "color":"rgb(81,99,86)","iconoPath":"M12 7v10M7 12h10","catColor":"rgb(20,158,140)","iconoBg":"rgba(20,158,140,0.15)"}],
     "metas":[
       {"indice":0,"nombre":"Fondo de emergencia","proyeccion":"Listo en ~33 meses","pctLabel":"13%","pct":13,
        "color":"rgb(19,125,65)","iconoPath":"M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18M8.5 14.5a4.5 4.5 0 0 0 7 0M9 10h.01M15 10h.01",
        "iconoBg":"rgba(19,125,65,0.14)","pie":"RD$20,000 de RD$150,000","falta":"Falta RD$130,000","aportar":"Aportar RD$4,000"},
       {"indice":1,"nombre":"Viaje familiar","proyeccion":"Listo en ~22 meses","pctLabel":"8%","pct":8,
        "color":"rgb(130,94,185)","iconoPath":"M12 2l3 8 7 2-7 2-3 8-3-8-7-2 7-2z",
        "iconoBg":"rgba(130,94,185,0.14)","pie":"RD$5,000 de RD$60,000","falta":"Falta RD$55,000","aportar":"Aportar RD$2,500"}]}
    """
}

extension TestVC {
    /// Un detalle de ejemplo de cada clase, para mirarlos sin la web.
    static func detalleDeMuestra(_ que: String) -> String {
        let tarjeta = "M4 7h16a1 1 0 0 1 1 1v9a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V8a1 1 0 0 1 1-1zM3 11h18M7 15h3"
        let casa = "M4 21V9l8-6 8 6v12M9 21v-6h6v6"
        if que == "tarjeta" {
            return """
            {"titulo":"Visa Clásica",
             "hero":{"iconoPath":"\(tarjeta)","iconoColor":"rgb(52,94,178)","iconoBg":"rgba(52,94,178,0.15)",
               "rotulo":"Debes ahora","valor":"RD$18,600","color":"rgb(213,89,72)",
               "pct":23,"colorBarra":"rgb(19,125,65)","pieIzq":"23% del límite","pieDer":"Límite RD$80,000"},
             "botones":[{"label":"Registrar pago","estilo":"acento"},{"label":"Gasto con ella","estilo":"contorno"}],
             "datos":[{"label":"Banco","valor":"Banco Popular"},{"label":"Terminación","valor":"•••• 4821"},
                      {"label":"Día de corte","valor":"día 20"},{"label":"Día de pago","valor":"día 5 · en 15 d"},
                      {"label":"Disponible","valor":"RD$61,400","color":"rgb(19,125,65)"}],
             "rotuloLista":"Consumos con esta tarjeta",
             "vacioTexto":"Aquí saldrá todo lo que anotes con esta tarjeta.","tramos":[]}
            """
        }
        if que == "categoria" {
            return """
            {"titulo":"Educación",
             "chips":[{"indice":0,"label":"Este mes","puesta":false},{"indice":1,"label":"3 meses","puesta":false},
                      {"indice":2,"label":"6 meses","puesta":true},{"indice":3,"label":"12 meses","puesta":false},
                      {"indice":4,"label":"Todo","puesta":false}],
             "hero":{"iconoPath":"M12 3 2 8l10 5 10-5zM6 11v5c0 1 3 2 6 2s6-1 6-2v-5","iconoColor":"rgb(130,94,185)",
               "iconoBg":"rgba(130,94,185,0.15)","rotulo":"Gastado en el periodo","valor":"RD$39,000",
               "color":"rgb(19,36,25)","pct":-1,"nota":"6 movimientos · RD$6,500 al mes de media"},
             "botones":[{"label":"Nuevo gasto aquí","estilo":"acento"},{"label":"Cambiar límite","estilo":"contorno"}],
             "datos":[{"label":"Movimientos","valor":"6"},{"label":"Promedio por movimiento","valor":"RD$6,500"},
                      {"label":"Al mes de media","valor":"RD$6,500"}],
             "barras":{"titulo":"Mes a mes","tope":"máx RD$6,500","columnas":[
               {"label":"abr","pct":100,"color":"rgba(130,94,185,0.4)","colorMes":"rgb(81,99,86)"},
               {"label":"may","pct":100,"color":"rgba(130,94,185,0.4)","colorMes":"rgb(81,99,86)"},
               {"label":"jun","pct":100,"color":"rgba(130,94,185,0.4)","colorMes":"rgb(81,99,86)"},
               {"label":"jul","pct":100,"color":"rgba(130,94,185,0.4)","colorMes":"rgb(81,99,86)"},
               {"label":"ago","pct":100,"color":"rgba(130,94,185,0.4)","colorMes":"rgb(81,99,86)"},
               {"label":"sep","pct":100,"fuerte":true,"color":"rgb(130,94,185)","colorMes":"rgb(19,36,25)"}]},
             "rotuloLista":"Movimientos de la categoría","vacioTexto":"",
             "tramos":[{"label":"Septiembre de 2026","total":"RD$6,500","items":[
               {"concepto":"Universidad","sub":"9 sept de 2026 · cada mes","montoFmt":"RD$6,500","color":"rgb(19,36,25)"}]},
              {"label":"Agosto de 2026","total":"RD$6,500","items":[
               {"concepto":"Universidad","sub":"9 ago de 2026 · cada mes","montoFmt":"RD$6,500","color":"rgb(19,36,25)"}]}]}
            """
        }
        return """
        {"titulo":"Cuenta principal",
         "hero":{"iconoPath":"\(casa)","iconoColor":"rgb(52,110,74)","iconoBg":"rgba(52,110,74,0.15)",
           "rotulo":"Saldo disponible","valor":"RD$54,800","color":"rgb(19,36,25)","pct":-1},
         "cifras":[{"label":"Entró este mes","valor":"RD$80,000","color":"rgb(19,125,65)"},
                   {"label":"Salió este mes","valor":"RD$87,400","color":"rgb(213,89,72)"}],
         "botones":[{"label":"Nuevo movimiento","estilo":"acento"},{"label":"Transferir","estilo":"contorno"}],
         "datos":[{"label":"Banco","valor":"Banreservas"},{"label":"Movimientos","valor":"73"}],
         "rotuloLista":"Movimientos de esta cuenta","vacioTexto":"",
         "tramos":[{"label":"Septiembre de 2026","total":"−RD$7,400","items":[
           {"concepto":"Fondo de emergencia","sub":"Ahorro · 14 sept 2026 · cada mes","montoFmt":"−RD$5,000",
            "color":"rgb(213,89,72)","iconoPath":"M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18M8.5 14.5a4.5 4.5 0 0 0 7 0M9 10h.01M15 10h.01",
            "catColor":"rgb(130,94,185)","iconoBg":"rgba(130,94,185,0.15)"},
           {"concepto":"Gasolina","sub":"Transporte · 12 sept 2026","montoFmt":"−RD$6,000","color":"rgb(213,89,72)",
            "iconoPath":"M5 17h14M6 17V9l2-4h8l2 4v8M7 13h10","catColor":"rgb(213,89,72)","iconoBg":"rgba(213,89,72,0.15)"}]}]}
        """
    }
}
