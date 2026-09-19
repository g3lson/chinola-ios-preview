import UIKit
import SwiftUI
import Capacitor

// ChinolaNativo.swift (los tipos CN* reales: CNBarraMenu, CNMovs, CNDatos, …) se
// ANEXA a este archivo en el paso de CI. Aquí solo el arranque + Movimientos
// nativa con datos de ejemplo, para VER en el simulador la barra liquid glass
// real, el botón de Perfil y la lista de movimientos.

private let SAMPLE = """
{
 "nombre":"Personal",
 "cuentas":[{"id":1,"nombre":"Cuenta principal","banco":"Banreservas","saldo":48200,"color":"#137d41","clase":"banco","icono":"banco"}],
 "categorias":[{"nombre":"Alimentación","tipo":"Gasto","color":"#e0a92e","icono":"comida"},{"nombre":"Transporte","tipo":"Gasto","color":"#2f6fd6","icono":"auto"},{"nombre":"Servicios","tipo":"Gasto","color":"#825eb9","icono":"rayo"}],
 "tx":[
  {"id":"m1","concepto":"Sueldo quincena","categoria":"Ingresos","tipo":"Ingreso","monto":30000,"fecha":"2026-09-18","medio":"cuenta:1"},
  {"id":"m2","concepto":"Supermercado Nacional","categoria":"Alimentación","tipo":"Gasto Variable","monto":2400,"fecha":"2026-09-18","medio":"cuenta:1"},
  {"id":"m3","concepto":"Uber al trabajo","categoria":"Transporte","tipo":"Gasto Variable","monto":350,"fecha":"2026-09-18","medio":"cuenta:1"},
  {"id":"m4","concepto":"Café con Ana","categoria":"Alimentación","tipo":"Gasto Variable","monto":420,"fecha":"2026-09-17","medio":"cuenta:1"},
  {"id":"m5","concepto":"Luz (EdeEste)","categoria":"Servicios","tipo":"Gasto Fijo","monto":1850,"fecha":"2026-09-17","medio":"cuenta:1"},
  {"id":"m6","concepto":"Gasolina","categoria":"Transporte","tipo":"Gasto Variable","monto":1500,"fecha":"2026-09-16","medio":"cuenta:1"},
  {"id":"m7","concepto":"Almuerzo","categoria":"Alimentación","tipo":"Gasto Variable","monto":650,"fecha":"2026-09-16","medio":"cuenta:1"},
  {"id":"m8","concepto":"Internet","categoria":"Servicios","tipo":"Gasto Fijo","monto":2200,"fecha":"2026-09-15","medio":"cuenta:1"},
  {"id":"m9","concepto":"Freelance","categoria":"Ingresos","tipo":"Ingreso","monto":8000,"fecha":"2026-09-15","medio":"cuenta:1"},
  {"id":"m10","concepto":"Colmado","categoria":"Alimentación","tipo":"Gasto Variable","monto":300,"fecha":"2026-09-14","medio":"cuenta:1"}
 ]
}
"""

class TestVC: CAPBridgeViewController {
    let datos = CNDatos()
    let estado = CNMenuEstado()
    private var barraView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        estado.activa = "movs"
        datos.cargar(json: SAMPLE)

        // Pantalla nativa Movimientos (real) encima del webview, opaca.
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
