import UIKit
import SwiftUI
import Capacitor

/// La forma que tiene Chinola, y el arreglo.
///
/// Capacitor hace `view = webView` en su `loadView`, que es `final`: la vista
/// raíz del controlador ES el WKWebView. Así que todo lo que Chinola añadía a
/// `view` —las pantallas nativas, la barra, el botón flotante— se estaba
/// metiendo DENTRO del webview.
///
/// Aquí se reproduce lo que hace la app de verdad —un huésped de SwiftUI a
/// pantalla completa encima, desde el arranque— con el webview ya sacado a un
/// contenedor. Si la página se pinta y el módulo corre, la estructura aguanta.
class ViewController: CAPBridgeViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("SONDA: viewDidLoad")

        // EL ARREGLO: el webview deja de ser la raíz.
        if let web = viewIfLoaded, web === (webView as UIView?) {
            let contenedor = UIView(frame: web.frame)
            contenedor.backgroundColor = web.backgroundColor
            contenedor.autoresizingMask = web.autoresizingMask
            view = contenedor
            contenedor.addSubview(web)
            web.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                web.topAnchor.constraint(equalTo: contenedor.topAnchor),
                web.leadingAnchor.constraint(equalTo: contenedor.leadingAnchor),
                web.trailingAnchor.constraint(equalTo: contenedor.trailingAnchor),
                web.bottomAnchor.constraint(equalTo: contenedor.bottomAnchor)
            ])
            NSLog("SONDA: webview sacado de la raíz · raíz ahora = \(type(of: view!))")
        } else {
            NSLog("SONDA: la raíz NO era el webview")
        }

        // Y encima, un huésped de SwiftUI a pantalla completa, como el botón
        // flotante de Chinola: transparente y sin robar toques.
        let host = UIHostingController(rootView: EncimaDeTodo())
        host.view.backgroundColor = .clear
        host.view.isOpaque = false
        host.view.isUserInteractionEnabled = false
        addChild(host); view.addSubview(host.view); host.didMove(toParent: self)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        NSLog("SONDA: huésped de SwiftUI encima")
    }
}

/// Un botón flotante de mentira, para ocupar el mismo sitio que el de verdad.
struct EncimaDeTodo: View {
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Circle().fill(Color.yellow)
                    .frame(width: 56, height: 56)
                    .shadow(radius: 6)
                    .padding(24)
            }
        }
    }
}
