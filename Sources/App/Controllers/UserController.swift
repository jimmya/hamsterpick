import Vapor
import HTTP
import AuthProvider

final class UserController: ResourceRepresentable {

    func store(_ req: Request) throws -> ResponseRepresentable {
        guard let id = req.auth.header?.basic?.username.int else {
            throw Abort.unauthorized
        }
        guard let name = req.data["name"]?.string else {
            throw Abort.badRequest
        }
        if let user = try User.find(Identifier(id)) {
            user.name = name
            try user.save()
            return user
        }
        let user = User(id: id, name: name)
        try user.save()
        return user
    }

    func makeResource() -> Resource<User> {
        return Resource(
            store: store
        )
    }
}

extension UserController: EmptyInitializable { }
