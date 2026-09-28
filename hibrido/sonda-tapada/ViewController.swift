import UIKit
import Capacitor

/// Igual que hace Chinola: una vista OPACA a pantalla completa encima del
/// webview desde el primer fotograma, porque todas sus pantallas son nativas.
///
/// La pregunta es si WebKit, al no ver el webview, suspende su JavaScript y por
/// eso el módulo de la app nunca llega a ejecutarse.
class ViewController: CAPBridgeViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapa = UIView()
        tapa.backgroundColor = .systemBackground      // opaca, como la de Chinola
        tapa.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tapa)
        NSLayoutConstraint.activate([
            tapa.topAnchor.constraint(equalTo: view.topAnchor),
            tapa.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tapa.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tapa.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        let aviso = UILabel()
        aviso.text = "tapando el webview…"
        aviso.textAlignment = .center
        aviso.translatesAutoresizingMaskIntoConstraints = false
        tapa.addSubview(aviso)
        NSLayoutConstraint.activate([
            aviso.centerXAnchor.constraint(equalTo: tapa.centerXAnchor),
            aviso.centerYAnchor.constraint(equalTo: tapa.centerYAnchor)
        ])

        // A los 9 segundos se destapa para poder fotografiar la respuesta. Para
        // entonces el módulo ya habría corrido de sobra si fuera a correr.
        DispatchQueue.main.asyncAfter(deadline: .now() + 9) {
            tapa.removeFromSuperview()
        }
    }
}
