// swift-tools-version:6.1
import PackageDescription

let package = Package(
    name: "Dollup",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .executable(name: "dollup", targets: ["DollupTool"]),

        .executable(name: "DollupTool", targets: ["DollupTool"]),
        .library(name: "Dollup", targets: ["Dollup"]),
        .library(name: "DollupConfig", targets: ["DollupConfig"]),
    ],
    dependencies: [
        .package(url: "https://github.com/tayloraswift/swift-io", branch: "master"),
        .package(url: "https://github.com/swiftlang/swift-syntax", "601.0.0" ..< "603.0.0")
    ],
    targets: [
        .executableTarget(
            name: "DollupTool",
            dependencies: [
                .target(name: "DollupConfig"),
            ]
        ),

        .plugin(
            name: "DollupPlugin",
            capability: .command(
                intent: .custom(verb: "dollup", description: "format source files"),
                permissions: [.writeToPackageDirectory(reason: "code formatter")],
            ),
            dependencies: [
                .target(name: "DollupTool"),
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
    if case .plugin = target.type {
        continue
    }
    {
        $0 = ($0 ?? []) + [
            .enableUpcomingFeature("ExistentialAny")
        ]
    }(&target.swiftSettings)
}
