import UIKit
import Capacitor

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        // Patrón CANÓNICO de Capacitor 8 (verificado en el simulador): la ventana
        // se crea A MANO aquí, con ChinolaViewController (nuestra subclase, donde
        // se registran los plugins y se monta la barra nativa). El Info.plist NO
        // debe tener UISceneStoryboardFile: si lo tiene, el storyboard crea OTRA
        // ventana además de esta y el WKWebView queda muerto = pantalla negra.
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = ChinolaViewController()
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
