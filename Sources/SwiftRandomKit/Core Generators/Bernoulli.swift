extension RandomGenerators {
    /// A generator that produces `true` with a given probability — a Bernoulli trial,
    /// or "biased coin".
    ///
    /// Example usage:
    /// ```swift
    /// // A coin that lands heads 70% of the time
    /// let biased = RandomGenerators.Bernoulli(probability: 0.7)
    /// let heads = biased.run()
    ///
    /// // Dot syntax in generic positions
    /// let critChance: some RandomGenerator<Bool> = .bool(probability: 0.05)
    /// ```
    public struct Bernoulli: RandomGenerator {
        public typealias Element = Bool

        /// The chance of producing `true`, from 0 (never) to 1 (always).
        public let probability: Double

        /// Creates a biased coin.
        /// - Parameter probability: The chance of producing `true`, from 0 (never) to 1 (always).
        public init(probability: Double) {
            precondition((0...1).contains(probability), "probability must be within 0...1, got \(probability)")
            self.probability = probability
        }

        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Bool {
            Double.random(in: 0..<1, using: &rng) < probability
        }
    }
}

extension RandomGenerators.Bernoulli: Sendable {}

extension RandomGenerator where Self == RandomGenerators.Bernoulli {
    /// A biased coin: generates `true` with the given probability.
    ///
    /// - Parameter probability: The chance of `true`, from 0 (never) to 1 (always).
    public static func bool(probability: Double) -> RandomGenerators.Bernoulli {
        .init(probability: probability)
    }
}
