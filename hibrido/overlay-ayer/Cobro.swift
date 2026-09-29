import Foundation
import Capacitor
import StoreKit

/**
 * El cobro de las suscripciones, con StoreKit 2.
 *
 * Aquí solo pasa lo que tiene que pasar en el teléfono: enseñar los precios que
 * dice Apple —nunca los que diga la app, que cambian por país— y abrir la caja.
 * Quién tiene qué plan **no se decide aquí**: se manda el identificador de la
 * transacción al servidor y es el servidor quien le pregunta a Apple. Si esto
 * decidiera, bastaría con trastear el teléfono para tener el plan Negocio.
 *
 * Es un plugin de la propia app y no un paquete de fuera: lo que hace falta son
 * tres llamadas de StoreKit, y una dependencia más es una cosa más que se
 * rompe en cada actualización de Capacitor.
 */
@objc(CobroPlugin)
public class CobroPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "CobroPlugin"
    public let jsName = "Cobro"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "productos", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "comprar", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "restaurar", returnType: CAPPluginReturnPromise)
    ]

    /// Los precios, tal como Apple los da en la tienda de quien mira.
    @objc func productos(_ call: CAPPluginCall) {
        guard let ids = call.getArray("ids", String.self), !ids.isEmpty else {
            call.reject("Falta la lista de productos.")
            return
        }
        Task {
            do {
                let encontrados = try await Product.products(for: ids)
                let lista = encontrados.map { p -> [String: Any] in
                    return [
                        "id": p.id,
                        "nombre": p.displayName,
                        "descripcion": p.description,
                        // El precio ya viene con su moneda y su formato: en
                        // Santo Domingo dirá RD$ y en Miami US$, sin que la app
                        // tenga que saber de cambio de divisas.
                        "precio": p.displayPrice
                    ]
                }
                call.resolve(["productos": lista])
            } catch {
                call.reject("No pudimos pedirle los precios a Apple: \(error.localizedDescription)")
            }
        }
    }

    /// Abre la caja de Apple y devuelve la transacción para que la verifique el servidor.
    @objc func comprar(_ call: CAPPluginCall) {
        guard let id = call.getString("id") else {
            call.reject("Falta el producto.")
            return
        }
        Task {
            do {
                guard let producto = try await Product.products(for: [id]).first else {
                    call.reject("Apple no conoce ese producto.")
                    return
                }
                let resultado = try await producto.purchase()
                switch resultado {
                case .success(let verificacion):
                    switch verificacion {
                    case .verified(let transaccion):
                        // Se cierra la transacción solo después de habérsela
                        // dado al servidor; si la app muriera aquí, Apple la
                        // vuelve a entregar al abrir.
                        call.resolve([
                            "estado": "listo",
                            "transaccion": String(transaccion.id),
                            "producto": transaccion.productID
                        ])
                        await transaccion.finish()
                    case .unverified:
                        call.reject("Apple no pudo verificar esa compra.")
                    }
                case .userCancelled:
                    call.resolve(["estado": "cancelado"])
                case .pending:
                    // «Pide permiso a un adulto» y parecidos: la compra sigue
                    // viva y llegará por el aviso del servidor.
                    call.resolve(["estado": "esperando"])
                @unknown default:
                    call.resolve(["estado": "desconocido"])
                }
            } catch {
                call.reject("No se pudo completar la compra: \(error.localizedDescription)")
            }
        }
    }

    /// Lo que esta persona ya tiene comprado, para devolverle su plan en un teléfono nuevo.
    @objc func restaurar(_ call: CAPPluginCall) {
        Task {
            var vivas: [[String: Any]] = []
            for await resultado in Transaction.currentEntitlements {
                if case .verified(let t) = resultado {
                    vivas.append(["transaccion": String(t.id), "producto": t.productID])
                }
            }
            call.resolve(["compras": vivas])
        }
    }
}
