// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "LiquidPersona",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "LiquidPersona",
            path: "Sources",
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        )
    ]
)
