// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftRandomKit",
    platforms: [.iOS(.v13), .macOS(.v13)],
    products: [
        .library(name: "SwiftRandomKit", targets: ["SwiftRandomKit"]),
        .library(name: "SwiftRandomKitGenerators", targets: ["SwiftRandomKitGenerators"])
    ],
    targets: [
        .target(name: "SwiftRandomKit"),
        .target(name: "SwiftRandomKitGenerators", dependencies: ["SwiftRandomKit"]),
        
        .executableTarget(name: "SwiftRandomKitExample", dependencies: ["SwiftRandomKit", "SwiftRandomKitGenerators"]),

        .testTarget(name: "SwiftRandomKitTests", dependencies: ["SwiftRandomKit"])
    ]
)
