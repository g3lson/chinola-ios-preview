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
    var contenido: UIView?

    override func capacitorDidLoad() {
        nativo.store = datos
        nativo.menuEstado = estado
        bridge?.registerPluginInstance(nativo)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        mostrar(0)

        // Cápsula flotante de Liquid Glass con la barra propia dentro (permite
        // la LENTE de vidrio sobre la opción seleccionada).
        var efecto: UIVisualEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        if #available(iOS 26.0, *) { let e = UIGlassEffect(); e.isInteractive = true; efecto = e }
        let panel = UIVisualEffectView(effect: efecto)
        panel.translatesAutoresizingMaskIntoConstraints = false
        panel.layer.cornerRadius = 30
        panel.layer.cornerCurve = .continuous
        panel.clipsToBounds = true
        panel.layer.borderWidth = 1
        panel.layer.borderColor = UIColor.white.withAlphaComponent(0.28).cgColor
        view.addSubview(panel)

        let hosting = UIHostingController(rootView: CNBarraMenu(estado: estado, conFondo: false))
        hosting.view.backgroundColor = .clear
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(hosting); hosting.didMove(toParent: self)
        panel.contentView.addSubview(hosting.view)
        NSLayoutConstraint.activate([
            hosting.view.topAnchor.constraint(equalTo: panel.contentView.topAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: panel.contentView.bottomAnchor),
            hosting.view.leadingAnchor.constraint(equalTo: panel.contentView.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: panel.contentView.trailingAnchor),
            panel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 14),
            panel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -14),
            panel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -4)
        ])
        view.bringSubviewToFront(panel)
        barraView = panel

        // Guion de la prueba: Movimientos → detalle de un movimiento (para ver
        // atrás y ⋯ en vidrio) → nuevo movimiento (cerrar y guardar).
        conectarAcciones()
        DispatchQueue.main.asyncAfter(deadline: .now() + 12) { [weak self] in
            guard let s = self, let m = s.datos.libreta.tx.first else { return }
            s.presentar(AnyView(CNDetalleMov(datos: s.datos, movId: m.id, onClose: { s.cerrar() })))
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 22) { [weak self] in
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
        host.modalPresentationStyle = .overFullScreen
        host.view.backgroundColor = .clear
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
        h.view.backgroundColor = .systemGroupedBackground
        addChild(h); view.addSubview(h.view); h.didMove(toParent: self)
        h.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            h.view.topAnchor.constraint(equalTo: view.topAnchor),
            h.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            h.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            h.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        contenido = h.view
        if let p = barraView { view.bringSubviewToFront(p) }

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
