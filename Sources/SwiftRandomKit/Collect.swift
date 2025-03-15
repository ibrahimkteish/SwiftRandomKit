/// Extension providing collection-related random generators.
extension RandomGenerators {
    /// A generator that collects the output of multiple generators into a single array.
    ///
    /// The `Collect` generator takes an array of generators of the same type and runs each one,
    /// collecting their results into a single array. This is useful when you want to combine
    /// the output of multiple generators of the same type but with different configurations.
    ///
    /// Unlike the `Collection` generator which runs a single generator multiple times,
    /// `Collect` runs each provided generator exactly once per run call.
    ///
    /// Example usage:
    /// ```swift
    /// // Create generators with different ranges
    /// let smallNumberGen = IntGenerator(in: 1...10)
    /// let mediumNumberGen = IntGenerator(in: 11...50)
    /// let largeNumberGen = IntGenerator(in: 51...100)
    ///
    /// // Collect them into a single generator
    /// let mixedNumbersGen = [smallNumberGen, mediumNumberGen, largeNumberGen].collect()
    ///
    /// // Generate an array with one value from each generator
    /// let mixedNumbers = mixedNumbersGen.run() // e.g., [7, 32, 89]
    /// ```
    public struct Collect<Upstream: RandomGenerator>: RandomGenerator {
        public typealias Element = [Upstream.Element]

        /// The array of generators whose outputs will be collected.
        let generators: [Upstream]

        /// Creates a new collect generator from an array of generators.
        ///
        /// - Parameter generators: An array of generators of the same type whose outputs
        ///   will be collected into a single array.
        public init(_ generators: [Upstream]) {
            self.generators = generators
        }

        /// Runs each generator once and collects their outputs into an array.
        ///
        /// - Parameter rng: The random number generator to use.
        /// - Returns: An array containing one random element from each generator, in order.
        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Element {
            return generators.map { $0.run(using: &rng) }
        }
    }
}

/// Extension that adds collection functionality to arrays of random generators.
public extension Array where Element: RandomGenerator {
    /// Creates a generator that collects the output of all generators in the array.
    ///
    /// This method allows you to easily create a `Collect` generator from an array of generators.
    /// The resulting generator will run each of the original generators once and return their
    /// results as an array.
    ///
    /// - Returns: A generator that collects the output of all generators in the array.
    ///
    /// Example:
    /// ```swift
    /// let diceGens = [
    ///     IntGenerator(in: 1...6),  // First die
    ///     IntGenerator(in: 1...6),  // Second die
    ///     IntGenerator(in: 1...6)   // Third die
    /// ].collect()
    ///
    /// let diceRoll = diceGens.run() // e.g., [3, 5, 1]
    /// ```
    @inlinable
    func collect() -> RandomGenerators.Collect<Element> {
        .init(self)
    }
}

/// Type alias for easier access to the Collect generator.
public typealias Collect = RandomGenerators.Collect
