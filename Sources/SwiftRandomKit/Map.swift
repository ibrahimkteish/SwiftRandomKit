extension RandomGenerators {
    /// A generator that transforms the output of another generator with a given closure.
    ///
    /// The `Map` generator is a fundamental building block for creating complex random generation pipelines.
    /// It allows you to transform the output of any generator into a different type or format without
    /// changing the underlying randomness.
    ///
    /// You will not typically need to interact with this type directly. Instead you will usually use
    /// the ``map(_:)`` operation, which constructs this type.
    ///
    /// Example usage:
    /// ```swift
    /// // Transform dice rolls into strings
    /// let diceGen = IntGenerator(in: 1...6)
    /// let diceStringGen = diceGen.map { "You rolled a \($0)" }
    /// let result = diceStringGen.run() // "You rolled a 4"
    ///
    /// // Transform coordinates into a formatted string
    /// let coordGen = IntGenerator(in: 0...100).tuple()
    /// let formattedCoordGen = coordGen.map { "(\($0.0), \($0.1))" }
    /// let position = formattedCoordGen.run() // "(42, 73)"
    ///
    /// // Chain multiple transformations
    /// let complexGen = IntGenerator(in: 1...100)
    ///     .map { $0 * 2 }
    ///     .map { "Value: \($0)" }
    /// let output = complexGen.run() // "Value: 84"
    /// ```
  public struct Map<Upstream: RandomGenerator, NewOutput: Sendable>: RandomGenerator {
        /// The generator from which this generator receives its output.
        public let upstream: Upstream
        /// The transformation to apply to the upstream's output.
        public let transform: @Sendable (Upstream.Element) -> NewOutput

        /// Initializes a new map generator with the given upstream generator and transformation.
        /// - Parameters:
        ///   - upstream: The generator whose output will be transformed.
        ///   - transform: A closure that transforms the upstream generator's output to a new type.
        @inlinable
        public init(_ upstream: Upstream, _ transform: @Sendable @escaping (Upstream.Element) -> NewOutput) {
            self.upstream = upstream
            self.transform = transform
        }

        /// Runs the generator using the provided random number generator.
        /// - Parameter rng: The random number generator to use.
        /// - Returns: The transformed value after applying the transformation to the upstream generator's output.
        @inlinable
        @inline(__always)
        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> NewOutput {
            transform(upstream.run(using: &rng))
        }
    }
}

extension RandomGenerator {
    /// Transforms the output of this generator using the given closure.
    ///
    /// This method is one of the most commonly used operations in SwiftRandomKit, allowing you to
    /// transform random values into different types or formats. The transformation is applied
    /// each time the generator runs.
    ///
    /// - Parameter transform: A closure that takes the output of this generator and returns a transformed value.
    /// - Returns: A generator that produces the transformed values.
    @inlinable
    public func map<NewOutput>(_ transform: @Sendable @escaping (Element) -> NewOutput) -> RandomGenerators.Map<Self, NewOutput> {
        .init(self, transform)
    }
}

extension RandomGenerators.Map {
    /// Transforms the output of this map generator using a new transformation.
    ///
    /// This method provides an optimized way to chain multiple transformations. Instead of creating
    /// nested map generators, it composes the transformations and creates a single map generator
    /// with the combined transformation.
    ///
    /// - Parameter transform: A closure that takes the output of this generator and returns a new transformed value.
    /// - Returns: A generator that applies both transformations in sequence.
    @inlinable
    public func map<New>(_ transform: @Sendable @escaping (Element) -> New) -> RandomGenerators.Map<Upstream, New> {
        .init(self.upstream) { element in
            transform(self.transform(element))
        }
    }
}
