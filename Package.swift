// swift-tools-version:6.2
import PackageDescription

let package = Package(
    name: "Dollup",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .executable(name: "dollup", targets: ["DollupTool"]),
        .library(name: "Dollup", targets: ["Dollup"]),
        .library(name: "DollupConfig", targets: ["DollupConfig"]),
    ],
    dependencies: [
        .package(url: "https://github.com/rarestype/swift-io", from: "1.1.0"),
        .package(url: "https://github.com/swiftlang/swift-syntax", "603.0.0" ..< "604.0.0")
    ],
    targets: [
        .executableTarget(
            name: "DollupTool",
            dependencies: [
                .target(name: "DollupConfig"),
            ]
        ),

        .target(
            name: "DollupConfig",
            dependencies: [
                .target(name: "Dollup"),
                .product(name: "SystemIO", package: "swift-io"),
            ]
        ),
        .target(
            name: "Dollup",
            dependencies: [
                .target(name: "WhitespaceFormatter"),
            ]
        ),
        .target(
            name: "WhitespaceFormatter",
            dependencies: [
                .product(name: "SwiftOperators", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
            ]
        ),
        .testTarget(
            name: "WhitespaceFormatterTests",
            dependencies: [
                .target(name: "WhitespaceFormatter"),
            ],
        ),
    ]
)
for target: Target in package.targets {
    switch target.type {
    case .plugin: continue
    case .binary: continue
    default: break
    }
    {
        $0 = ($0 ?? []) + [
            .enableUpcomingFeature("ExistentialAny")
        ]
    }(&target.swiftSettings)
}
