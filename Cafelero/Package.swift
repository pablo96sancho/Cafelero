// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Cafelero",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "Cafelero",
            path: "Sources/Cafelero",
            resources: []
        )
    ]
)
