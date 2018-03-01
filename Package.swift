// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "MakeChatWithUs",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0-rc"),
//        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0-rc.1"),
        .package(url: "https://github.com/vapor/fluent-mysql", from: "3.0.0-rc.1"),
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0-beta"),
        ],
    targets: [
        .target(name: "App", dependencies: [
            "Vapor",
            "FluentMySQL",
            "Leaf"
            ]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"]),
        ]
)

