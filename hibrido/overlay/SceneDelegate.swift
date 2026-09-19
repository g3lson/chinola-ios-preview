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

        // Movimientos nativa (real) encima del webview, opaca. Se llena por el
        // puente (la web empuja Nativo.datos al store compartido).
        let host = UIHostingController(rootView: AnyView(CNPruebaColores()))
        host.view.backgroundColor = UIColor(CNC.scr)
        addChild(host); view.addSubview(host.view); host.didMove(toParent: self)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Barra con LIQUID GLASS de UIKit: capa de SOMBRA fuera + vidrio RECORTADO dentro.
        let contenedor = UIView()
        contenedor.backgroundColor = .clear
        contenedor.layer.shadowColor = UIColor.black.cgColor
        contenedor.layer.shadowOpacity = 0.18
        contenedor.layer.shadowRadius = 22
        contenedor.layer.shadowOffset = CGSize(width: 0, height: 8)
        contenedor.layer.masksToBounds = false

        let vidrio: UIVisualEffectView
        if #available(iOS 26.0, *) {
            let efecto = UIGlassEffect()
            efecto.isInteractive = true
            vidrio = UIVisualEffectView(effect: efecto)
        } else {
            vidrio = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        }
        vidrio.layer.cornerRadius = 32
        vidrio.layer.cornerCurve = .continuous
        vidrio.clipsToBounds = true
        vidrio.translatesAutoresizingMaskIntoConstraints = false
        contenedor.addSubview(vidrio)
        NSLayoutConstraint.activate([
            vidrio.topAnchor.constraint(equalTo: contenedor.topAnchor),
            vidrio.bottomAnchor.constraint(equalTo: contenedor.bottomAnchor),
            vidrio.leadingAnchor.constraint(equalTo: contenedor.leadingAnchor),
            vidrio.trailingAnchor.constraint(equalTo: contenedor.trailingAnchor)
        ])
        let dentro: UIView = vidrio.contentView

        let barra = UIHostingController(rootView: CNBarraMenu(estado: estado, conFondo: false))
        barra.view.backgroundColor = .clear
        addChild(barra); barra.didMove(toParent: self)
        barra.view.translatesAutoresizingMaskIntoConstraints = false
        dentro.addSubview(barra.view)
        NSLayoutConstraint.activate([
            barra.view.topAnchor.constraint(equalTo: dentro.topAnchor),
            barra.view.bottomAnchor.constraint(equalTo: dentro.bottomAnchor),
            barra.view.leadingAnchor.constraint(equalTo: dentro.leadingAnchor),
            barra.view.trailingAnchor.constraint(equalTo: dentro.trailingAnchor)
        ])
        view.addSubview(contenedor)
        contenedor.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contenedor.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            contenedor.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            contenedor.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 6)
        ])
        view.bringSubviewToFront(contenedor)
        contenedor.layer.zPosition = 999
        barraView = contenedor

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
