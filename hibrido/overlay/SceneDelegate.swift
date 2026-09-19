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

        // El MENÚ: un UITabBar de verdad (Liquid Glass del sistema en iOS 26).
        barra.alTocar = { [weak self] id in self?.estado.activa = id; self?.barra.pintar(activa: id, titulos: true) }
        barra.montar(en: view)
        barra.pintar(activa: estado.activa, titulos: true)

        // El guion lo manda el entorno (SIMCTL_CHILD_CNPANTALLA): una pantalla
        // por lanzamiento, así cada captura es la que se pidió y no depende de
        // cuánto tarde el simulador en arrancar.
        conectarAcciones()
        let cual = ProcessInfo.processInfo.environment["CNPANTALLA"] ?? "movs"
        if cual.hasSuffix("-oscuro") {
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
                         "cab-fina": "fina", "cab-clara": "clara", "cab-minima": "minima"][cual] ?? "auto"
        let grad = cual.hasPrefix("cab-") ? TestVC.fondoDegradado : TestVC.fondoLlano
        datos.cargarResumen(json: TestVC.resumenDeMuestra
            .replacingOccurrences(of: "\"diseno\":\"auto\"", with: "\"diseno\":\"\(disenoCab)\"")
            .replacingOccurrences(of: "__FONDO__", with: grad))
        let base = cual.replacingOccurrences(of: "-oscuro", with: "")
        mostrar(base)
        barra.pintar(activa: estado.activa, titulos: true)
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
        case "resumen", "organiza", "cab-auto", "cab-clasica", "cab-detallada", "cab-fina", "cab-clara", "cab-minima":
            vista = AnyView(CNResumen(datos: datos)); estado.activa = "resumen"
        case "cuentas": vista = AnyView(CNCuentas(datos: datos)); estado.activa = "cuentas"
        case "plan":    vista = AnyView(CNPlan(datos: datos));    estado.activa = "plan"
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
