import UIKit

/// La ventana igual que en la app de verdad: a mano, con ChinolaViewController.
///
/// El banco de pruebas de al lado usa su propio `TestVC`, así que el
/// controlador de verdad se compilaba pero NUNCA se ejecutaba. Y el fallo que
/// perseguimos —la app abre en blanco— está justo ahí: en lo que ese
/// controlador le hace al webview al arrancar.
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    func scene(_ scene: UIScene, willConnectTo: UISceneSession, options: UIScene.ConnectionOptions) {
        guard let escena = scene as? UIWindowScene else { return }
        window = UIWindow(windowScene: escena)
        window?.rootViewController = ChinolaViewController()
        window?.makeKeyAndVisible()
    }
}
