#if Derive && os(macOS)
import MacroTesting
import SwiftRandomKitMacros
import Testing

@Suite(
    .macros(
        [RandomGenerableMacro.self, GenMacro.self],
        record: .failed
    )
)
struct RandomGenerableMacroTests {
    @Test func structBasics() {
        assertMacro {
            """
            @RandomGenerable
            struct User {
                let name: String
                let age: Int
                let isAdmin: Bool
            }
            """
        } expansion: {
            """
            struct User {
                let name: String
                let age: Int
                let isAdmin: Bool
            }

            extension User {
                static var generator: SwiftRandomKit.AnyRandomGenerator<User> {
                    SwiftRandomKit.AnyRandomGenerator<User> { rng in
                        User(
                            name: String.generator.run(using: &rng),
                            age: Int.generator.run(using: &rng),
                            isAdmin: Bool.generator.run(using: &rng)
                        )
                    }
                }
            }
            """
        }
    }

    @Test func structWithGenOverrides() {
        assertMacro {
            """
            @RandomGenerable
            struct Player {
                @Gen(IntGenerator(in: 0...9999)) var score: Int
                var alias: String
            }
            """
        } expansion: {
            """
            struct Player {
                var score: Int
                var alias: String
            }

            extension Player {
                static var generator: SwiftRandomKit.AnyRandomGenerator<Player> {
                    SwiftRandomKit.AnyRandomGenerator<Player> { rng in
                        Player(
                            score: (IntGenerator(in: 0 ... 9999)).run(using: &rng),
                            alias: String.generator.run(using: &rng)
                        )
                    }
                }
            }
            """
        }
    }

    @Test func structSkipsNonMemberwiseProperties() {
        assertMacro {
            """
            @RandomGenerable
            struct Config {
                let version = 1
                static var shared: Config? = nil
                var isOn: Bool
                var level: Int { isOn ? 1 : 0 }
                var name: String {
                    didSet { print("renamed") }
                }
            }
            """
        } expansion: {
            """
            struct Config {
                let version = 1
                static var shared: Config? = nil
                var isOn: Bool
                var level: Int { isOn ? 1 : 0 }
                var name: String {
                    didSet { print("renamed") }
                }
            }

            extension Config {
                static var generator: SwiftRandomKit.AnyRandomGenerator<Config> {
                    SwiftRandomKit.AnyRandomGenerator<Config> { rng in
                        Config(
                            isOn: Bool.generator.run(using: &rng),
                            name: String.generator.run(using: &rng)
                        )
                    }
                }
            }
            """
        }
    }

    @Test func structSugaredTypes() {
        assertMacro {
            """
            @RandomGenerable
            struct Profile {
                var nickname: String?
                var scores: [Int]
            }
            """
        } expansion: {
            """
            struct Profile {
                var nickname: String?
                var scores: [Int]
            }

            extension Profile {
                static var generator: SwiftRandomKit.AnyRandomGenerator<Profile> {
                    SwiftRandomKit.AnyRandomGenerator<Profile> { rng in
                        Profile(
                            nickname: Swift.Optional<String>.generator.run(using: &rng),
                            scores: [Int].generator.run(using: &rng)
                        )
                    }
                }
            }
            """
        }
    }

    @Test func publicStructGetsPublicGenerator() {
        assertMacro {
            """
            @RandomGenerable
            public struct Token {
                public let value: String
            }
            """
        } expansion: {
            """
            public struct Token {
                public let value: String
            }

            extension Token {
                public static var generator: SwiftRandomKit.AnyRandomGenerator<Token> {
                    SwiftRandomKit.AnyRandomGenerator<Token> { rng in
                        Token(
                            value: String.generator.run(using: &rng)
                        )
                    }
                }
            }
            """
        }
    }

    @Test func emptyStruct() {
        assertMacro {
            """
            @RandomGenerable
            struct Marker {
            }
            """
        } expansion: {
            """
            struct Marker {
            }

            extension Marker {
                static var generator: SwiftRandomKit.AnyRandomGenerator<Marker> {
                    SwiftRandomKit.AnyRandomGenerator<Marker> { rng in
                        Marker()
                    }
                }
            }
            """
        }
    }

    @Test func multiBindingAnnotation() {
        assertMacro {
            """
            @RandomGenerable
            struct Size {
                var width, height: Int
            }
            """
        } expansion: {
            """
            struct Size {
                var width, height: Int
            }

            extension Size {
                static var generator: SwiftRandomKit.AnyRandomGenerator<Size> {
                    SwiftRandomKit.AnyRandomGenerator<Size> { rng in
                        Size(
                            width: Int.generator.run(using: &rng),
                            height: Int.generator.run(using: &rng)
                        )
                    }
                }
            }
            """
        }
    }

    @Test func enumBasics() {
        assertMacro {
            """
            @RandomGenerable
            enum Reward {
                case coins(Int)
                case badge(name: String)
                case nothing
            }
            """
        } expansion: {
            """
            enum Reward {
                case coins(Int)
                case badge(name: String)
                case nothing
            }

            extension Reward {
                static var generator: SwiftRandomKit.AnyRandomGenerator<Reward> {
                    SwiftRandomKit.AnyRandomGenerator<Reward> { rng in
                        switch Swift.Int.random(in: 0 ... 2, using: &rng) {
                        case 0:
                            return Reward.coins(Int.generator.run(using: &rng))
                        case 1:
                            return Reward.badge(name: String.generator.run(using: &rng))
                        default:
                            return Reward.nothing
                        }
                    }
                }
            }
            """
        }
    }

    @Test func singleCaseEnum() {
        assertMacro {
            """
            @RandomGenerable
            enum Only {
                case one(Bool)
            }
            """
        } expansion: {
            """
            enum Only {
                case one(Bool)
            }

            extension Only {
                static var generator: SwiftRandomKit.AnyRandomGenerator<Only> {
                    SwiftRandomKit.AnyRandomGenerator<Only> { rng in
                        return Only.one(Bool.generator.run(using: &rng))
                    }
                }
            }
            """
        }
    }

    // MARK: Diagnostics

    @Test func classIsRejected() {
        assertMacro {
            """
            @RandomGenerable
            class Service {
                var id: Int
            }
            """
        } diagnostics: {
            """
            @RandomGenerable
            ┬───────────────
            ╰─ 🛑 @RandomGenerable can only be applied to a struct or an enum
            class Service {
                var id: Int
            }
            """
        }
    }

    @Test func genericStructIsRejected() {
        assertMacro {
            """
            @RandomGenerable
            struct Box<Value> {
                var value: Value
            }
            """
        } diagnostics: {
            """
            @RandomGenerable
            ┬───────────────
            ╰─ 🛑 @RandomGenerable does not support generic types
            struct Box<Value> {
                var value: Value
            }
            """
        }
    }

    @Test func missingTypeAnnotationIsRejected() {
        assertMacro {
            """
            @RandomGenerable
            struct Counter {
                var count = 0
            }
            """
        } diagnostics: {
            """
            @RandomGenerable
            struct Counter {
                var count = 0
                    ┬────────
                    ╰─ 🛑 @RandomGenerable requires an explicit type annotation for this property, or a @Gen override
            }
            """
        }
    }

    @Test func genOnMultipleBindingsIsRejected() {
        assertMacro {
            """
            @RandomGenerable
            struct Size {
                @Gen(IntGenerator(in: 1...100)) var width, height: Int
            }
            """
        } diagnostics: {
            """
            @RandomGenerable
            struct Size {
                @Gen(IntGenerator(in: 1...100)) var width, height: Int
                ┬─────────────────────────────────────────────────────
                ├─ 🛑 peer macro can only be applied to a single variable
                ╰─ 🛑 @Gen cannot be applied to a declaration with multiple bindings; declare each property separately
            }
            """
        }
    }

    @Test func enumWithoutCasesIsRejected() {
        assertMacro {
            """
            @RandomGenerable
            enum Never2 {
            }
            """
        } diagnostics: {
            """
            @RandomGenerable
            ┬───────────────
            ╰─ 🛑 @RandomGenerable cannot derive a generator for an enum with no cases
            enum Never2 {
            }
            """
        }
    }

    @Test func genOnFunctionIsRejected() {
        assertMacro {
            """
            struct S {
                @Gen(BoolGenerator()) func flip() {}
            }
            """
        } diagnostics: {
            """
            struct S {
                @Gen(BoolGenerator()) func flip() {}
                ┬────────────────────
                ╰─ 🛑 @Gen can only be applied to a stored property
            }
            """
        }
    }
}
#endif
