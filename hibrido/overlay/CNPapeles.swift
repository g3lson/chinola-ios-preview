import Foundation

/**
 * QUÉ TE DEJA HACER UNA LIBRETA.
 *
 * Una libreta compartida reparte papeles: el Dueño y el Editor tocan todo, el
 * Registrador puede anotar movimientos pero no cambiar cuentas ni
 * presupuestos, y el Lector solo mira. Eso decide si sale el botón de editar,
 * si sale el de anotar y si salen las acciones de una fila.
 *
 * Lo decidía la web y lo mandaba ya resuelto dentro de cada modelo
 * (`puedeEditar`, `puedeRegistrar`). Armando las pantallas aquí hay que
 * saberlo aquí, y se sabe: los miembros viajan DENTRO de la libreta.
 *
 * DOS COSAS QUE SE PIERDEN AL REHACERLO DE MEMORIA, y las dos dejan a alguien
 * fuera de su propia libreta:
 *
 *  · **manda `__rol`, no la lista.** Es el papel que da el servidor, el mismo
 *    con el que decide si te deja escribir. La lista de miembros es para
 *    ENSEÑARLA: se queda vieja. Mirándola a ella se le dice «solo lectura» a
 *    quien sí puede escribir;
 *  · **el correo se compara sin mayúsculas.** Invitada como «Ana@…» y con
 *    sesión como «ana@…» es la misma persona. Comparándolos tal cual se queda
 *    de Lectora en su libreta —y con el botón de quitarse a sí misma puesto—.
 *
 * Y sin sesión el correo es «local», que es con el que se apunta a sí mismo
 * quien empieza sin cuenta. Dejarlo vacío lo dejaría de Lector en la única
 * libreta que tiene, sin poder anotar nada.
 */
enum CNPapeles {

    static let dueno = "Dueño"
    static let editor = "Editor"
    static let registrador = "Registrador"
    static let lector = "Lector"

    /// Quién soy yo para la libreta: el correo de la sesión, o «local».
    static func yo(_ p: CNPerfilInfo) -> String {
        p.local || p.email.isEmpty ? "local" : p.email
    }

    static func rol(_ l: CNLibreta, yo correo: String) -> String {
        if !l.rolServidor.isEmpty { return l.rolServidor }
        let mio = correo.trimmingCharacters(in: .whitespaces).lowercased()
        let m = l.miembros.first {
            $0.email.trimmingCharacters(in: .whitespaces).lowercased() == mio
        }
        return m?.rol ?? lector
    }

    /// Tocar cuentas, tarjetas, préstamos, metas y presupuestos.
    static func puedeEditar(_ l: CNLibreta, yo correo: String) -> Bool {
        let r = rol(l, yo: correo)
        return r == dueno || r == editor
    }

    /// Anotar movimientos. El Registrador puede, y por eso no es lo mismo que
    /// `puedeEditar`: con una sola de las dos, o el Registrador no puede
    /// anotar —que es justo lo único que le toca— o puede cambiar la libreta
    /// entera.
    static func puedeRegistrar(_ l: CNLibreta, yo correo: String) -> Bool {
        puedeEditar(l, yo: correo) || rol(l, yo: correo) == registrador
    }
}
