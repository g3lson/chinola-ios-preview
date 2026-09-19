import UIKit
import SwiftUI
import Capacitor

// Prueba FIEL del arranque de la app real: patrón CANÓNICO de Capacitor
// (ventana creada A MANO en el SceneDelegate, SIN UISceneStoryboardFile) pero con
// una SUBCLASE de CAPBridgeViewController que monta una barra nativa encima del
// webview (como ChinolaViewController.montarBarra). Si esto carga el webview + la
// barra (no negro), el patrón para la app está validado.

class TestVC: CAPBridgeViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let bar = UIHostingController(rootView: BarraTest())
        bar.view.backgroundColor = .clear
        addChild(bar); view.addSubview(bar.view); bar.didMove(toParent: self)
        bar.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bar.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bar.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bar.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 8)
        ])
        view.bringSubviewToFront(bar.view)
        bar.view.layer.zPosition = 999
    }
}

struct BarraTest: View {
    var body: some View {
        HStack(spacing: 0) {
            ForEach(["Resumen", "Movs", "Cuentas", "Plan", "Perfil"], id: \.self) { t in
                VStack(spacing: 4) {
                    Image(systemName: "circle.fill").font(.system(size: 18))
                    Text(t).font(.system(size: 11, weight: .heavy))
                }.frame(maxWidth: .infinity).foregroundColor(Color(red: 0.07, green: 0.14, blue: 0.1))
            }
        }
        .padding(.vertical, 10).padding(.horizontal, 8)
        .background(RoundedRectangle(cornerRadius: 30, style: .continuous).fill(.ultraThinMaterial).shadow(color: .black.opacity(0.16), radius: 20, y: 8))
        .overlay(RoundedRectangle(cornerRadius: 30, style: .continuous).stroke(Color.white.opacity(0.6), lineWidth: 1))
        .padding(.horizontal, 16)
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        // CANÓNICO: la ventana se crea a mano (con NUESTRA subclase), y NO hay
        // UISceneStoryboardFile en el Info.plist → una sola ventana.
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
