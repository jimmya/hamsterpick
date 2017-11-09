import PostgreSQLProvider
import AuthProvider

extension Config {
    public func setup() throws {
        Node.fuzzy = [Row.self, JSON.self, Node.self]

        try setupProviders()
        try setupPreparations()
    }
    
    /// Configure providers
    private func setupProviders() throws {
        try addProvider(PostgreSQLProvider.Provider.self)
        try addProvider(AuthProvider.Provider.self)
    }
    
    private func setupPreparations() throws {
        preparations.append(User.self)
        preparations.append(Score.self)
    }
}
