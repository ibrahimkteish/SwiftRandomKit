import Foundation

extension RandomGenerators {
    /// A generator that produces normally (Gaussian) distributed values.
    ///
    /// Uses the Box–Muller transform: two uniform draws produce one normal value.
    ///
    /// Example usage:
    /// ```swift
    /// // Standard normal: mean 0, standard deviation 1
    /// let z = RandomGenerators.Normal().run()
    ///
    /// // Adult heights in centimeters
    /// let height: some RandomGenerator<Double> = .normal(mean: 170, standardDeviation: 10)
    /// ```
    public struct Normal: RandomGenerator {
        public typealias Element = Double

        /// The center of the distribution.
        public let mean: Double

        /// The spread of the distribution.
        public let standardDeviation: Double

        /// Creates a normal distribution generator.
        /// - Parameters:
        ///   - mean: The center of the distribution. Defaults to 0.
        ///   - standardDeviation: The spread of the distribution. Must be non-negative. Defaults to 1.
        public init(mean: Double = 0, standardDeviation: Double = 1) {
            precondition(standardDeviation >= 0, "standardDeviation must be non-negative, got \(standardDeviation)")
            self.mean = mean
            self.standardDeviation = standardDeviation
        }

        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Double {
            // Box–Muller. u1 is drawn from (0, 1) to keep log(u1) finite.
            let u1 = Double.random(in: .ulpOfOne..<1, using: &rng)
            let u2 = Double.random(in: 0..<1, using: &rng)
            let z = (-2 * log(u1)).squareRoot() * cos(2 * .pi * u2)
            return mean + standardDeviation * z
        }
    }

    /// A generator that produces exponentially distributed values.
    ///
    /// Uses inverse transform sampling. Exponential values model waiting times
    /// between independent events occurring at a constant average rate.
    ///
    /// Example usage:
    /// ```swift
    /// // Time between requests arriving at 2 per second (mean 0.5s)
    /// let wait: some RandomGenerator<Double> = .exponential(rate: 2)
    /// ```
    public struct Exponential: RandomGenerator {
        public typealias Element = Double

        /// The rate parameter (λ). The mean of the distribution is `1 / rate`.
        public let rate: Double

        /// Creates an exponential distribution generator.
        /// - Parameter rate: The rate parameter (λ). Must be positive. Defaults to 1.
        public init(rate: Double = 1) {
            precondition(rate > 0, "rate must be positive, got \(rate)")
            self.rate = rate
        }

        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Double {
            // Inverse CDF; u is drawn from (0, 1) to keep log(u) finite.
            let u = Double.random(in: .ulpOfOne..<1, using: &rng)
            return -log(u) / rate
        }
    }
}

extension RandomGenerators.Normal: Sendable {}
extension RandomGenerators.Exponential: Sendable {}

extension RandomGenerator where Self == RandomGenerators.Normal {
    /// A generator of normally distributed values, for dot-syntax usage.
    ///
    /// - Parameters:
    ///   - mean: The center of the distribution. Defaults to 0.
    ///   - standardDeviation: The spread of the distribution. Defaults to 1.
    public static func normal(mean: Double = 0, standardDeviation: Double = 1) -> RandomGenerators.Normal {
        .init(mean: mean, standardDeviation: standardDeviation)
    }
}

extension RandomGenerator where Self == RandomGenerators.Exponential {
    /// A generator of exponentially distributed values, for dot-syntax usage.
    ///
    /// - Parameter rate: The rate parameter (λ). Defaults to 1.
    public static func exponential(rate: Double = 1) -> RandomGenerators.Exponential {
        .init(rate: rate)
    }
}
