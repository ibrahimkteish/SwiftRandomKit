// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "SwiftRandomKit",
    platforms: [.iOS(.v13), .macOS(.v10_15), .tvOS(.v13), .watchOS(.v6)],
    products: [
        .library(name: "SwiftRandomKit", targets: ["SwiftRandomKit"]),
        .library(name: "SwiftRandomKitGenerators", targets: ["SwiftRandomKitGenerators"])
    ],
    traits: [
        .trait(
            name: "Derive",
            description: """
                Enables the @RandomGenerable derivation macro. Opting in adds a \
                build-time dependency on swift-syntax.
                """
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.4.0"),
        .package(url: "https://github.com/swiftlang/swift-syntax", "600.0.0"..<"700.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-macro-testing", from: "0.6.0")
    ],
    targets: [
        .target(
            name: "SwiftRandomKit",
            dependencies: [
                .target(name: "SwiftRandomKitMacros", condition: .when(traits: ["Derive"]))
            ]
        ),
        .macro(
            name: "SwiftRandomKitMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .target(name: "SwiftRandomKitGenerators", dependencies: ["SwiftRandomKit"]),

        .executableTarget(name: "SwiftRandomKitExample", dependencies: ["SwiftRandomKit", "SwiftRandomKitGenerators"]),

        .testTarget(
            name: "SwiftRandomKitTests",
            dependencies: [
                "SwiftRandomKit",
                "SwiftRandomKitGenerators"
            ],
            exclude: ["SwiftRandomKit-Package.xctestplan"]
        ),

        // Macro expansion tests live in their own target that only imports the
        // macro implementation and MacroTesting; both dependencies exist only
        // when the Derive trait is enabled, and the sources are gated on it.
        .testTarget(
            name: "SwiftRandomKitMacrosTests",
            dependencies: [
                .target(name: "SwiftRandomKitMacros", condition: .when(traits: ["Derive"])),
                .product(name: "MacroTesting", package: "swift-macro-testing", condition: .when(traits: ["Derive"]))
            ]
        )
    ]
)
