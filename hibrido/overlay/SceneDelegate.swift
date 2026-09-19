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

        mostrar(0)

        // El MENÚ: un UITabBar de verdad (Liquid Glass del sistema en iOS 26).
        barra.alTocar = { [weak self] id in self?.estado.activa = id; self?.barra.pintar(activa: id, titulos: true) }
        barra.montar(en: view)
        barra.pintar(activa: estado.activa, titulos: true)

        // Guion de la prueba, acompasado con las capturas del workflow:
        //  6 s Movimientos · 12 s Movimientos con OTRO TEMA · 20 s detalle · 34 s nuevo.
        conectarAcciones()
        DispatchQueue.main.asyncAfter(deadline: .now() + 9) { [weak self] in
            // Cambio de tema (como si el usuario lo cambiara en la web): todo
            // lo nativo tiene que repintarse.
            self?.datos.cargarTema(json: """
            {"bg":"#101713","card":"#18211b","suave":"#1d2820","borde":"#2c3a31","tinta":"#eef3ee",
             "gris":"#9bb0a1","side":"#0b120e","acento":"#8fd6a0","pos":"#5fcf8a","neg":"#e08a7a","oscuro":true}
            """)
            self?.barra.pintar(activa: self?.estado.activa ?? "movs", titulos: true)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 17) { [weak self] in
            guard let s = self else { return }
            let id = s.datos.libreta.tx.first?.id ?? ""
            s.presentar(AnyView(CNDetalleMov(datos: s.datos, movId: id, onClose: { s.cerrar() })))
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) { [weak self] in
            guard let s = self else { return }
            s.cerrar()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                s.presentar(AnyView(CNNuevoMov(datos: s.datos, onClose: { s.cerrar() })))
            }
        }
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
    /// Va cambiando de pantalla para capturar cada sección.
    func mostrar(_ i: Int) {
        contenido?.removeFromSuperview()
        // Solo Movimientos es nativa; las demás son la web de la app.
        let vistas: [AnyView] = [AnyView(CNMovs(datos: datos))]
        let ids = ["movs"]
        estado.activa = ids[0]
        let h = UIHostingController(rootView: vistas[0])
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
