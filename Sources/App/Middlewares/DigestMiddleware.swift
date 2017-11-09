import Vapor
import Foundation
import AuthProvider

final class DigestMiddleware: Middleware {
    
    var digestKey: String
    
    init(digestKey: String) {
        self.digestKey = digestKey
    }
    
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        guard let digestHeader = request.headers["X-Digest"]?.string else {
            throw Abort.unauthorized
        }
        
        var pathAndQuery = request.uri.path
        if let query = request.uri.query {
            pathAndQuery += "?\(query)"
        }
        var dataComponents: [Data?] = []
        dataComponents.append(pathAndQuery.data(using: .utf8))
        
        if let bytes = request.body.bytes {
            let bodyData = Data(bytes: bytes, count: min(1000, bytes.count))
            dataComponents.append(bodyData)
        }
        
        if let userId = request.auth.header?.basic?.username {
            dataComponents.append(userId.data(using: .utf8))
        }
        
        dataComponents.append(digestKey.data(using: .utf8))
        
        // Filter nil values and combine
        let data = dataComponents.flatMap({ return $0 }).reduce(Data()) { (data, current) -> Data in
            return data + current
        }
        
        let hasher = CryptoHasher(hash: .sha1, encoding: .hex)
        let hash = try hasher.make(data.makeBytes()).makeString()
        
        guard digestHeader == hash else {
            throw Abort.badRequest
        }
        return try next.respond(to: request)
    }
}
