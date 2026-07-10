extension RandomGenerators {
  /// A generator that combines multiple generators into a tuple of their results.
  ///
  /// The `Zip` generator takes multiple generators and runs them in sequence, collecting their
  /// results into a tuple. This is useful when you need to generate multiple related random values
  /// at once while preserving their individual types.
  ///
  /// Example usage:
  /// ```swift
  /// // Create two separate generators
  /// let diceGen = IntGenerator(in: 1...6)
  /// let coinGen = BoolGenerator()
  ///
  /// // Combine them with zip
  /// let game = diceGen.zip(coinGen)
  ///
  /// // Run to get a tuple containing both a dice roll and a coin flip
  /// let result = game.run() // e.g., (4, true)
  ///
  /// // You can also zip more than two generators
  /// let letterGen = RandomGenerators.letter
  /// let tripleGen = diceGen.zip(coinGen).zip(letterGen)
  /// let triple = tripleGen.run() // e.g., ((5, false), "K")
  /// ```
  ///
  /// Zipped generators can be particularly useful when combined with the `map` function
  /// to transform the resulting tuple:
  ///
  /// ```swift
  /// let cardValue = IntGenerator(in: 1...13)
  /// let cardSuit = Always(["♠️", "♥️", "♦️", "♣️"]).element()
  ///
  /// let cardGen = cardValue.zip(cardSuit).map { (value, suit) in
  ///     let faceValue: String
  ///     switch value {
  ///     case 1: faceValue = "A"
  ///     case 11: faceValue = "J"
  ///     case 12: faceValue = "Q"
  ///     case 13: faceValue = "K"
  ///     default: faceValue = "\(value)"
  ///     }
  ///     return "\(faceValue)\(suit ?? "")"
  /// }
  ///
  /// let card = cardGen.run() // e.g., "Q♠️"
  /// ```
  @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
  public struct Zip<each R: RandomGenerator>: RandomGenerator {
    public typealias Element = (repeat (each R).Element)

    /// The generators to zip together.
    let generators: (repeat each R)

    /// Creates a new zip generator with the provided generators.
    /// - Parameter generators: The generators to zip together.
    public init(_ generators: repeat each R) {
      self.generators = (repeat each generators)
    }

    /// Generates a tuple containing results from each of the constituent generators.
    /// - Parameter rng: The random number generator to use.
    /// - Returns: A tuple where each element is the result of running the corresponding generator.
    public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Element {
      return (repeat (each generators).run(using: &rng))
    }
  }
}

@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
extension RandomGenerators.Zip {
  /// Transforms the zipped results, receiving each generator's value as a
  /// separate closure argument instead of a single tuple.
  ///
  /// Example:
  /// ```swift
  /// let gen = RandomGenerators.Zip(IntGenerator(in: 1...6), BoolGenerator())
  ///     .map { roll, flip in "\(roll)-\(flip)" }
  /// ```
  ///
  /// Newer Swift compilers no longer destructure a pack-expansion tuple into a
  /// multi-parameter closure, so the generic `map(_:)` cannot be called as
  /// `{ a, b, c in ... }` on a zip of three generators; this overload keeps
  /// that spelling working.
  public func map<T>(
    _ transform: @escaping (repeat (each R).Element) -> T
  ) -> RandomGenerators.Map<Self, T> {
    .init(self) { element in
      transform(repeat each element)
    }
  }
}

@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
extension RandomGenerator {
  /// Combines this generator with another generator to produce tuples of their results.
  ///
  /// - Parameter other: Another generator to combine with this one.
  /// - Returns: A generator that produces tuples containing results from both generators.
  public func zip<R: RandomGenerator>(_ other: R) -> RandomGenerators.Zip<Self, R> {
    .init(self, other)
  }

  /// Combines this generator with another generator and immediately maps the result.
  ///
  /// This is a convenience method that combines `zip` and `map` operations in one step.
  ///
  /// - Parameters:
  ///   - other: Another generator to combine with this one.
  ///   - transform: A function that transforms the tuple of results into a new value.
  /// - Returns: A generator that produces values transformed from the combined results.
  public func zip<R: RandomGenerator, T>(_ other: R, _ transform: @escaping (Self.Element, R.Element) -> T) -> RandomGenerators.Map<RandomGenerators.Zip<Self, R>, T> {
    .init(.init(self, other), transform)
  }
}
