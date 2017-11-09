import Vapor
import AuthProvider

extension Droplet {
    func setupRoutes() throws {
        guard let digestKey = config["digest", "key"]?.string else {
            fatalError("Digest key not available")
        }
        let digestMiddleware = DigestMiddleware(digestKey: digestKey)
        let protected = grouped(digestMiddleware)
        
        try protected.resource("users", UserController.self)
        
        let authenticationMiddleware = PasswordAuthenticationMiddleware(User.self)
        let authorized = protected.grouped(authenticationMiddleware)
        
        let scoreController = ScoreController()
        authorized.resource("scores", scoreController)
        authorized.group("scores") { (scoreBuilder) in
            scoreBuilder.get(User.parameter, handler: scoreController.userScores)
        }
    }
}
