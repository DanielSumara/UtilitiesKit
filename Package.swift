// swift-tools-version: 6.2
// swiftlint:disable:previous no_comments
import PackageDescription

// swiftlint:disable:next explicit_top_level_acl
let package = Package(
    name: "UtilitiesKit",
    platforms: [.iOS(.v26), .macOS(.v26)],
    products: [
        .library(name: "UtilitiesKit", targets: ["UtilitiesKit"]),
    ],
    targets: [
        .target(name: "UtilitiesKit", path: "Sources/UtilitiesKit"),
        .testTarget(name: "UtilitiesKitTests", dependencies: ["UtilitiesKit"], path: "Tests/UtilitiesKitTests"),
    ]
)
