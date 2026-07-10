// swift-tools-version: 6.0.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftRandomKit",
    platforms: [.iOS(.v13), .macOS(.v10_15), .tvOS(.v13), .watchOS(.v6)],
    products: [
        .library(name: "SwiftRandomKit", targets: ["SwiftRandomKit"]),
        .library(name: "SwiftRandomKitGenerators", targets: ["SwiftRandomKitGenerators"])
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.4.0")
    ],
    targets: [
        .target(name: "SwiftRandomKit"),
        .target(name: "SwiftRandomKitGenerators", dependencies: ["SwiftRandomKit"]),
        
        .executableTarget(name: "SwiftRandomKitExample", dependencies: ["SwiftRandomKit", "SwiftRandomKitGenerators"]),

        .testTarget(
            name: "SwiftRandomKitTests",
            dependencies: [
                "SwiftRandomKit",
                "SwiftRandomKitGenerators"
            ],
            exclude: ["SwiftRandomKit-Package.xctestplan"]
        )
    ]
)
