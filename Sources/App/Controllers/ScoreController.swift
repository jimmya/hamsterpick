import Foundation
import Vapor
import HTTP

final class ScoreController: ResourceRepresentable {
    
    func index(_ req: Request) throws -> ResponseRepresentable {
        let date = Date()
        let week: TimeInterval = 60 * 60 * 24 * 7
        let oneWeekAgo = date.addingTimeInterval(-week)
        return try Score.makeQuery()
            .filter(Score.createdAtKey, .greaterThanOrEquals, oneWeekAgo)
            .sort(Score.Keys.score, .descending)
            .limit(20)
            .all()
            .makeJSON()
    }
    
    func userScores(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.user()
        return try user.scores.all().makeJSON()
    }
    
    func store(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.user()
        guard let userId = user.id else {
            throw Abort.serverError
        }
        guard let scoreString = req.data["score"]?.string, let scoreInt = Int(scoreString) else {
            throw Abort.badRequest
        }
        let score = Score(score: scoreInt, userId: userId)
        try score.save()
        return score
    }
    
    func makeResource() -> Resource<Score> {
        return Resource(
            index: index,
            store: store
        )
    }
}

extension ScoreController: EmptyInitializable { }
