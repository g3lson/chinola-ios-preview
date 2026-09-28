import UIKit
import Capacitor

/// Igual que hace Chinola: una vista OPACA a pantalla completa encima del
/// webview desde el primer fotograma, porque todas sus pantallas son nativas.
///
/// La pregunta es si WebKit, al no ver el webview, suspende su JavaScript y por
/// eso el módulo de la app nunca llega a ejecutarse.
class ViewController: CAPBridgeViewController {
    private var tapa: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("SONDA: viewDidLoad del controlador propio")

        let tapa = UIView()
        self.tapa = tapa
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 9) { [weak self] in
            NSLog("SONDA: destapando")
            self?.tapa?.removeFromSuperview()
            self?.tapa = nil
        }
    }

    /// La tapa, otra vez al frente después de que Capacitor coloque lo suyo: en
    /// `viewDidLoad` el webview todavía se está montando y puede quedar encima.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let t = tapa {
            view.bringSubviewToFront(t)
            NSLog("SONDA: tapa al frente · webview tapado = \(t.superview != nil)")
        }
    }
}
