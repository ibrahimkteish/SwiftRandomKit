#if Derive
/// Derives a `RandomGenerable` conformance for a struct or an enum.
///
/// Available when the package is imported with the `Derive` trait enabled.
///
/// For a struct, the derived `generator` builds values through the memberwise
/// initializer, generating every stored property from its type's default generator —
/// or from a `@Gen(...)` override:
///
/// ```swift
/// @RandomGenerable
/// struct User {
///     let name: String
///     @Gen(IntGenerator(in: 18...99)) let age: Int
///     let isAdmin: Bool
/// }
///
/// let user = User.generator.run()
/// let team = User.generator.array(5).run()
/// ```
///
/// For an enum, the derived `generator` picks a case uniformly at random and derives
/// any associated values the same way:
///
/// ```swift
/// @RandomGenerable
/// enum Reward {
///     case coins(Int)
///     case badge(name: String)
///     case nothing
/// }
/// ```
///
/// Every stored property (and associated value) type must either conform to
/// `RandomGenerable` or carry a `@Gen` override. Derivation is not supported for
/// classes, actors, or generic types.
@attached(extension, conformances: RandomGenerable, names: named(generator))
public macro RandomGenerable() = #externalMacro(module: "SwiftRandomKitMacros", type: "RandomGenerableMacro")

/// Overrides the generator used for one stored property in a `@RandomGenerable` type.
///
/// Available when the package is imported with the `Derive` trait enabled.
///
/// The expression is captured as written and re-evaluated inside the derived
/// generator, so it composes with every combinator in the library:
///
/// ```swift
/// @RandomGenerable
/// struct Player {
///     @Gen(["north", "south", "east", "west"].element().map { $0! }) let region: String
///     @Gen(IntGenerator(in: 0...9999)) let score: Int
/// }
/// ```
@attached(peer)
public macro Gen<G: RandomGenerator>(_ generator: G) = #externalMacro(module: "SwiftRandomKitMacros", type: "GenMacro")
#endif
