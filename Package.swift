// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "MakeChatWithUs",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", .branch("beta")),
        .package(url: "https://github.com/vapor/fluent.git", .branch("beta")),
        .package(url: "https://github.com/vapor/mysql-driver.git", .branch("beta")),
        .package(url: "https://github.com/vapor/mysql.git", .branch("beta")),
        .package(url: "https://github.com/vapor/fluent-postgresql.git", .branch("beta")),
        .package(url: "https://github.com/vapor/postgresql.git", .branch("beta")),
        .package(url: "https://github.com/vapor/leaf.git", .branch("beta")),
        ],
    targets: [
        .target(name: "App", dependencies: [
            "Vapor",
            "FluentMySQL",
            "FluentSQLite",
            "FluentPostgreSQL",
            "Leaf"
            ]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"]),
        ]
)

