import UIKit

/// La ventana a mano, con nuestro controlador, igual que en Chinola.
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    func scene(_ scene: UIScene, willConnectTo: UISceneSession, options: UIScene.ConnectionOptions) {
        guard let escena = scene as? UIWindowScene else { return }
        window = UIWindow(windowScene: escena)
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
    }
}
