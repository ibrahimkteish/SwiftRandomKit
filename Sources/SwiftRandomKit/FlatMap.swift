extension RandomGenerators {
    /// A generator that transforms the output of another generator into a new generator and runs it.
    ///
    /// The `FlatMap` generator is a powerful tool for creating dynamic random generation pipelines.
    /// Unlike `Map` which transforms values directly, `FlatMap` transforms a value into a completely
    /// new generator, which is then run to produce the final result.
    ///
    /// Example usage:
    /// ```swift
    /// // Generate a random dice roll, then roll that many dice
    /// let diceCountGen = IntGenerator(in: 1...4) // Generates 1-4
    /// let diceRollGen = diceCountGen.flatMap { count in
    ///     // For each count, create a generator that rolls that many dice
    ///     IntGenerator(in: 1...6).array(count)
    /// }
    /// 
    /// let rolls = diceRollGen.run() // e.g., [3, 6, 1] (if count was 3)
    ///
    /// // Create a nested random structure
    /// let nestedGen = ["small", "medium", "large"].element().flatMap { size in
    ///     switch size {
    ///     case "small": return IntGenerator(in: 1...10).array(3)
    ///     case "medium": return IntGenerator(in: 1...50).array(5)
    ///     case "large": return IntGenerator(in: 1...100).array(10)
    ///     default: return IntGenerator(in: 0...0).array(0)
    ///     }
    /// }
    /// 
    /// let values = nestedGen.run() // Different array sizes and ranges based on random size
    /// ```
    public struct FlatMap<Upstream: RandomGenerator, NewOutput: RandomGenerator>: RandomGenerator {
        /// The generator from which this generator receives its input.
        let upstream: Upstream
        
        /// The transformation function that converts the upstream's output into a new generator.
        let transform: (Upstream.Element) -> NewOutput

        /// Initializes a new flat-map generator with the given upstream generator and transformation.
        /// - Parameters:
        ///   - upstream: The generator whose output will be transformed into a new generator.
        ///   - transform: A closure that takes the upstream generator's output and returns a new generator.
        public init(_ upstream: Upstream, _ transform: @escaping (Upstream.Element) -> NewOutput) {
            self.upstream = upstream
            self.transform = transform
        }

        /// Runs the generator using the provided random number generator.
        /// - Parameter rng: The random number generator to use.
        /// - Returns: The result of running the generator produced by the transformation.
        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> NewOutput.Element {
            transform(upstream.run(using: &rng)).run(using: &rng)
        }
    }
}

extension RandomGenerator {
    /// Transforms the output of this generator into a new generator and runs it.
    ///
    /// This method is useful for creating dynamic generation pipelines where the output of one
    /// generator determines what kind of generator to use next. It allows for complex, nested
    /// random structures and conditional random generation.
    ///
    /// - Parameter transform: A closure that takes the output of this generator and returns a new generator.
    /// - Returns: A generator that produces values by transforming the output into a new generator and running it.
    public func flatMap<NewOutput: RandomGenerator>(_ transform: @escaping (Element) -> NewOutput) -> RandomGenerators.FlatMap<Self, NewOutput> {
        .init(self, transform)
    }
}
