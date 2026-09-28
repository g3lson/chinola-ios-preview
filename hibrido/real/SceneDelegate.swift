import UIKit
import Capacitor

/// La MISMA app, con uno u otro controlador según la variable de entorno.
///
/// Así se comparan en la misma compilación y la misma página: si con el de
/// fábrica los módulos arrancan y con el de Chinola no, el culpable es el
/// controlador. Si no arrancan con ninguno, el culpable es este banco de
/// pruebas y hay que dejar de creerle.
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    func scene(_ scene: UIScene, willConnectTo: UISceneSession, options: UIScene.ConnectionOptions) {
        guard let escena = scene as? UIWindowScene else { return }
        let deFabrica = ProcessInfo.processInfo.environment["CN_FABRICA"] == "1"
        NSLog("SONDA: controlador \(deFabrica ? "DE FÁBRICA" : "de Chinola")")
        window = UIWindow(windowScene: escena)
        window?.rootViewController = deFabrica ? CAPBridgeViewController() : ChinolaViewController()
        window?.makeKeyAndVisible()
    }
}
