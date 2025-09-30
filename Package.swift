// swift-tools-version:6.1
import PackageDescription

let package = Package(
    name: "Dollup",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .executable(name: "dollup", targets: ["DollupTool"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
        .package(url: "https://github.com/tayloraswift/swift-io", branch: "master"),
        .package(url: "https://github.com/apple/swift-syntax", from: "602.0.0")
    ],
    targets: [
        .executableTarget(
            name: "DollupTool",
            dependencies: [
                .target(name: "Dollup"),

                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SystemIO", package: "swift-io"),
                .product(name: "System_ArgumentParser", package: "swift-io"),
            ]),

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
    {
        $0 =
            ($0 ?? []) + [
                .enableUpcomingFeature("ExistentialAny")
            ]
    }(&target.swiftSettings)
}
