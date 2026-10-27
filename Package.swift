// swift-tools-version: 6.2
// swiftlint:disable:previous no_comments
import PackageDescription

// swiftlint:disable:next explicit_top_level_acl
let package = Package(
    name: "UtilitiesKit",
    platforms: [.iOS(.v26), .macOS(.v26)],
    products: [
        .library(name: "UtilitiesKit", targets: ["UtilitiesKit"]),
        .library(name: "TestUtilitiesKit", targets: ["TestUtilitiesKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/krzysztofzablocki/Difference", exact: "1.1.0"),
    ],
    targets: [
        .target(name: "UtilitiesKit", path: "Sources/UtilitiesKit"),
        .testTarget(name: "UtilitiesKitTests", dependencies: ["UtilitiesKit"], path: "Tests/UtilitiesKitTests"),
        .target(
            name: "TestUtilitiesKit",
            dependencies: [.product(name: "Difference", package: "Difference")],
            path: "Sources/TestUtilitiesKit"
        ),
        .testTarget(name: "TestUtilitiesKitTests", dependencies: ["TestUtilitiesKit"], path: "Tests/TestUtilitiesKitTests"),
    ]
)
