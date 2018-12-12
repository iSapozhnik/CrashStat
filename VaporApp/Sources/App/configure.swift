import FluentSQLite
import Vapor
import PostgreSQL

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentSQLiteProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

/*
    // Configure a SQLite database
    let sqlite = try SQLiteDatabase(storage: .memory)

    /// Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: sqlite, as: .sqlite)
    services.register(databases)
*/
    
//    try services.register(PostgreSQLProvider())
    var databases = DatabasesConfig()
    var config: PostgreSQLDatabaseConfig
    if let url = Environment.get("DATABASE_URL") { // it will read from this URL in production
        config = (PostgreSQLDatabaseConfig(url: url))!
    } else { // when environment variable not present, default to local development environment
        config = PostgreSQLDatabaseConfig(hostname: "localhost", port: 5432, username: "isapozhnik", database: "crashstat", password: nil, transport: .cleartext)
    }
    let postgres = PostgreSQLDatabase(config: config)
    databases.add(database: postgres, as: .psql)
    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: AppInfo.self, database: .psql)
//    migrations.add(model: Todo.self, database: .sqlite)
//    migrations.add(model: AppInfo.self, database: .sqlite)
    services.register(migrations)

}
