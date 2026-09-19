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
    private var barraView: UIView?

    override func capacitorDidLoad() {
        nativo.store = datos
        nativo.menuEstado = estado
        bridge?.registerPluginInstance(nativo)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Movimientos nativa (real) encima del webview, opaca. SIN precargar.
        let host = UIHostingController(rootView: AnyView(CNMovs(datos: datos)))
        host.view.backgroundColor = UIColor(CNC.scr)
        addChild(host); view.addSubview(host.view); host.didMove(toParent: self)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Barra de menú nativa REAL.
        let barra = UIHostingController(rootView: CNBarraMenu(estado: estado))
        barra.view.backgroundColor = .clear
        addChild(barra); view.addSubview(barra.view); barra.didMove(toParent: self)
        barra.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            barra.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            barra.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            barra.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 8)
        ])
        view.bringSubviewToFront(barra.view)
        barra.view.layer.zPosition = 999
        barraView = barra.view
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
