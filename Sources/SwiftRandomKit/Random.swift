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
public protocol RandomGenerator<Element>: Sendable {
    /// The type of value this generator produces.
  associatedtype Element: Sendable

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

extension RandomGenerator {
  /// Allows calling the generator directly as a function without explicitly using the `run()` method.
  /// 
  /// This provides a convenient shorthand syntax for generating random values. 
  /// Instead of writing `generator.run()`, you can simply write `generator()`.
  ///
  /// - Returns: A randomly generated element of type `Element`.
  ///
  /// Example:
  /// ```swift
  /// let diceRoll = IntGenerator(in: 1...6)()  // Same as diceRoll.run()
  /// ```
  public func callAsFunction() -> Element {
    self.run()
  }

  /// Allows calling the generator directly as a function with a custom random number generator.
  ///
  /// This provides a convenient shorthand syntax for generating random values using a specific random number generator.
  /// Instead of writing `generator.run(using: &rng)`, you can simply write `generator(using: &rng)`.
  ///
  /// - Parameters:
  ///   - rng: The random number generator to use.
  /// - Returns: A randomly generated element of type `Element`.
  public func callAsFunction<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Element {
    self.run(using: &rng)
  }
}
