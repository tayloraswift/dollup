// swift-tools-version:6.1
import PackageDescription

let package = Package(
    name: "Dollup",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .executable(name: "dollup", targets: ["dollup"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
        .package(url: "https://github.com/tayloraswift/swift-io", branch: "master"),
        .package(url: "https://github.com/apple/swift-syntax", from: "601.0.1")
    ],
    targets: [
        .executableTarget(
            name: "dollup",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SystemIO", package: "swift-io"),
                .product(name: "System_ArgumentParser", package: "swift-io"),
                .target(name: "BlockIndentFormatter"),
            ]),
        .target(
            name: "BlockIndentFormatter",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax")
            ]
        ),
        .testTarget(
            name: "BlockIndentTests",
            dependencies: [
                .target(name: "BlockIndentFormatter"),
            ],
        )
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
