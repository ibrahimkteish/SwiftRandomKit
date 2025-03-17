/// A protocol that defines a type capable of generating random values.
///
/// The `RandomGenerator` protocol is the foundation of SwiftRandomKit, allowing you to create
/// composable random value generators. Generators can be combined, transformed, and chained
/// together to create complex random generation logic.
///
/// Example usage:
/// ```swift
/// // Basic integer generator
/// let diceGen = IntGenerator(1...6)
/// let roll = diceGen.run() // 4
///
/// // Combining generators
/// let twoDice = diceGen.tuple()
/// let (roll1, roll2) = twoDice.run() // (6, 2)
///
/// // Transforming generators
/// let wordGen = ["one", "two", "three"].element()
/// let lengthGen = wordGen.map { $0.count }
/// let length = lengthGen.run() // 3
/// ```
public protocol RandomGenerator<Element> {
    /// The type of value this generator produces.
    associatedtype Element
    
    /// Generates a random value using the provided random number generator.
    /// - Parameter rng: The random number generator to use.
    /// - Returns: A randomly generated value of type `Element`.
    func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Element
}

extension RandomGenerator {
    /// Runs the generator using the default SystemRandomNumberGenerator.
    ///
    /// This convenience method creates a new instance of `SystemRandomNumberGenerator`
    /// and uses it to generate a random value. It's the preferred way to generate
    /// random values when you don't need to specify a custom random number generator.
    ///
    /// - Returns: A randomly generated value of type `Element`.
    public func run() -> Element {
        var generator = SystemRandomNumberGenerator()
        return run(using: &generator)
    }
}
