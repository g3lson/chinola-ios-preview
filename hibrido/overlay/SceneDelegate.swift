import UIKit
import SwiftUI
import Capacitor

// Reproduce el flujo COMPLETO de la app: arranca en web + barra nativa, y a los
// 3s hace lo mismo que mostrarNativo() (esconde el webview y muestra una pantalla
// SwiftUI a pantalla completa). Si esa pantalla sale negra, reproduce el bug.

class TestVC: CAPBridgeViewController {
    private var barraView: UIView?
    private var contenedorNativo: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        montarBarra()
        // A los 3s: simula tocar una pestaña nativa.
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.mostrarNativo()
        }
    }

    private func montarBarra() {
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
        barraView = bar.view
    }

    // COPIA FIEL de ChinolaViewController.mostrarNativo (sin los datos).
    private func mostrarNativo() {
        contenedorNativo?.removeFromSuperview()
        let host = UIHostingController(rootView: AnyView(PantallaNativaTest()))
        host.view.backgroundColor = UIColor(Color(.sRGB, red: 0.98, green: 0.968, blue: 0.925, opacity: 1))
        addChild(host); view.addSubview(host.view); host.didMove(toParent: self)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        contenedorNativo = host.view
        webView?.isHidden = true
        if let barra = barraView { view.bringSubviewToFront(barra) }
    }
}

struct PantallaNativaTest: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                Text("PANTALLA NATIVA OK").font(.system(size: 30, weight: .heavy)).foregroundColor(Color(.sRGB, red: 0.07, green: 0.49, blue: 0.25, opacity: 1))
                Text("mostrarNativo escondió el webview y esta vista SwiftUI se ve.").font(.system(size: 15)).foregroundColor(.gray).multilineTextAlignment(.center)
            }.padding(.top, 120).padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.sRGB, red: 0.98, green: 0.968, blue: 0.925, opacity: 1).ignoresSafeArea())
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
