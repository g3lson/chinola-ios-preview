import Foundation
import Capacitor
import StoreKit
import UIKit

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
        CAPPluginMethod(name: "diagnostico", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "comprar", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "restaurar", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "gestionar", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "historial", returnType: CAPPluginReturnPromise)
    ]

    /// POR QUÉ NO SE PUEDE COMPRAR.
    ///
    /// Cuando `Product.products(for:)` vuelve vacío, StoreKit no dice por qué:
    /// simplemente no hay productos. Las causas son siempre las mismas cuatro
    /// —el producto no existe, no está al menos en «Ready to Submit», el
    /// bundle no coincide, o el contrato de apps de pago no está activo— y
    /// desde fuera no se distinguen. Esto recoge lo que SÍ se puede saber
    /// desde el teléfono para no tener que adivinar.
    @objc func diagnostico(_ call: CAPPluginCall) {
        let ids = call.getArray("ids", String.self) ?? []
        Task {
            var salida: [String: Any] = [
                "bundle": Bundle.main.bundleIdentifier ?? "—",
                "puedePagar": AppStore.canMakePayments
            ]
            if #available(iOS 15.0, *) {
                let tienda = await Storefront.current
                salida["pais"] = tienda?.countryCode ?? "—"
            }
            do {
                let hallados = try await Product.products(for: ids)
                salida["pedidos"] = ids
                salida["encontrados"] = hallados.map { $0.id }
                salida["faltan"] = ids.filter { id in !hallados.contains { $0.id == id } }
                salida["ok"] = hallados.count == ids.count && !ids.isEmpty
            } catch {
                salida["ok"] = false
                salida["fallo"] = error.localizedDescription
            }
            call.resolve(salida)
        }
    }

    /**
     * ABRE LA PANTALLA DE SUSCRIPCIONES DE APPLE.
     *
     * Cancelar una suscripción solo se puede ahí: Apple no deja que lo haga la
     * app, y además es lo correcto —quien cobra es quien tiene que dejar de
     * cobrar—. Lo que sí es nuestro es LLEVAR hasta esa pantalla.
     *
     * No tenerlo era lo peor de los dos mundos: no se podía cancelar desde la
     * app Y tampoco se decía dónde. Quien quiere irse y no encuentra la puerta
     * no se queda: se enfada y lo cuenta.
     */
    @objc func gestionar(_ call: CAPPluginCall) {
        Task { @MainActor in
            guard let escena = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene }).first else {
                call.reject("No se pudo abrir la pantalla de suscripciones.")
                return
            }
            do {
                try await AppStore.showManageSubscriptions(in: escena)
                call.resolve(["ok": true])
            } catch {
                call.reject(error.localizedDescription)
            }
        }
    }

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
                    /*
                     APPLE NO DEVUELVE EL PRODUCTO, Y CASI NUNCA ES EL ID.
                     
                     «Apple no conoce ese producto» mandaba a buscar donde no
                     era: lo normal es que el id esté perfecto y StoreKit no lo
                     devuelva por otra cosa. Y StoreKit no dice cuál —devuelve
                     una lista vacía y ya—, así que lo único honesto es nombrar
                     las tres de siempre, en el orden en que pasan.
                     
                     Pasó de verdad: los dos productos existían con el id
                     exacto, en «Prepare for Submission», y el mensaje mandó a
                     revisar el id durante un buen rato.
                     */
                    call.reject("Apple no devolvió el producto «\(id)». El id suele estar bien: "
                        + "mira que en App Store Connect la suscripción no esté en «Prepare for Submission» "
                        + "—hace falta precio, nombre y descripción para que pase a «Ready to Submit»—, "
                        + "que el contrato de apps de pago esté activo en Business, y que estés probando "
                        + "con un usuario de Sandbox.")
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

    /**
     * TODOS LOS COBROS, UNO POR UNO.
     *
     * La app no enseñaba ninguno. Quien paga una suscripción quiere ver sus
     * cobros —es lo primero que se busca cuando aparece un cargo y no se
     * recuerda de qué— y en Chinola no había dónde mirarlos.
     *
     * Y hay un sitio donde se nota el doble: en SANDBOX, Apple renueva cada
     * pocos minutos en vez de cada mes, justo para poder ver cómo se comporta
     * una suscripción con el tiempo. Sin esta lista eso no se puede comprobar:
     * las renovaciones pasan y no se ve ninguna.
     *
     * `Transaction.all` las trae todas, también las de otros aparatos y las de
     * antes de reinstalar, porque viven en la cuenta de Apple y no aquí.
     */
    @objc func historial(_ call: CAPPluginCall) {
        Task {
            var filas: [[String: Any]] = []
            for await resultado in Transaction.all {
                guard case .verified(let t) = resultado else { continue }
                var f: [String: Any] = [
                    "id": String(t.id),
                    "original": String(t.originalID),
                    "producto": t.productID,
                    "cuando": ISO8601DateFormatter().string(from: t.purchaseDate),
                    // La primera de una suscripción es la compra; las demás son
                    // renovaciones. Se distingue por el id original, y es lo que
                    // de verdad se quiere ver en sandbox.
                    "esRenovacion": t.id != t.originalID
                ]
                if let caduca = t.expirationDate {
                    f["caduca"] = ISO8601DateFormatter().string(from: caduca)
                }
                // Devuelto o cancelado por Apple: sin esto, un cobro devuelto
                // sigue en la lista como si se hubiera cobrado.
                if let devuelta = t.revocationDate {
                    f["devuelta"] = ISO8601DateFormatter().string(from: devuelta)
                }
                if #available(iOS 15.0, *), let precio = t.price {
                    f["precio"] = NSDecimalNumber(decimal: precio).doubleValue
                }
                if #available(iOS 16.0, *) {
                    f["moneda"] = t.currency?.identifier ?? ""
                }
                filas.append(f)
            }
            // La más nueva arriba: lo que se busca es el último cobro.
            filas.sort { (String($0["cuando"] as? String ?? "")) > (String($1["cuando"] as? String ?? "")) }
            call.resolve(["cobros": filas])
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
