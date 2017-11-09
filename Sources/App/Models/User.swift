import Vapor
import FluentProvider
import HTTP
import AuthProvider

final class User: Model {
    
    let storage = Storage()
    
    // MARK: Properties and database keys
    var name: String
    
    struct Keys {
        static let id = "id"
        static let name = "name"
    }
    
    init(id: Int, name: String) {
        self.name = name
        self.id = Identifier(id)
    }
    
    // MARK: Fluent Serialization
    init(row: Row) throws {
        name = try row.get(User.Keys.name)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(User.Keys.name, name)
        return row
    }
}

// MARK: Fluent Preparation
extension User: Preparation {

    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(User.Keys.name)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON
extension User: JSONConvertible {
    
    convenience init(json: JSON) throws {
        self.init(
            id: try json.get(User.Keys.id),
            name: try json.get(User.Keys.name)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(User.Keys.id, id)
        try json.set(User.Keys.name, name)
        return json
    }
}

extension User {
    
    var scores: Children<User, Score> {
        return children()
    }
}

extension User: PasswordAuthenticatable {
    
    static func authenticate(_ password: Password) throws -> User {
        guard let user = try User.makeQuery().find(password.username.int) else {
            throw Abort.unauthorized
        }
        return user
    }
}

extension User: ResponseRepresentable { }
