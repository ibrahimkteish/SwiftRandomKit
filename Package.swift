// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftRandomKit",
    platforms: [.iOS(.v13), .macOS(.v13)],
    products: [
        .library(name: "SwiftRandomKit", targets: ["SwiftRandomKit"])
    ],
    targets: [
        .target(name: "SwiftRandomKit"),

        .executableTarget(name: "SwiftRandomKitExample", dependencies: ["SwiftRandomKit"]),

        .testTarget(name: "SwiftRandomKitTests", dependencies: ["SwiftRandomKit"])
    ]
)
