import Vapor
import FluentProvider
import HTTP

final class Score: Model, Timestampable {
    
    let storage = Storage()
    
    // MARK: Properties and database keys
    var score: Int
    let userId: Identifier
    
    struct Keys {
        static let score = "score"
        static let user = "user"
    }
    
    init(score: Int, userId: Identifier) {
        self.score = score
        self.userId = userId
    }
    
    // MARK: Fluent Serialization
    init(row: Row) throws {
        score = try row.get(Score.Keys.score)
        userId = try row.get(User.foreignIdKey)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Score.Keys.score, score)
        try row.set(User.foreignIdKey, userId)
        return row
    }
}

// MARK: Fluent Preparation
extension Score: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.int(Score.Keys.score)
            builder.parent(User.self)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON
extension Score: JSONConvertible {
    
    convenience init(json: JSON) throws {
        self.init(
            score: try json.get(Score.Keys.score),
            userId: try json.get(User.foreignIdKey)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Score.idKey, id)
        try json.set(Score.Keys.score, score)
        try json.set(Score.Keys.user, user.get())
        return json
    }
}

extension Score {
    
    var user: Parent<Score, User> {
        return parent(id: userId)
    }
}

extension Score: ResponseRepresentable { }
