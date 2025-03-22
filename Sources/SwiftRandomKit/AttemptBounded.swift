extension RandomGenerators {
    /// A generator that bounds another generator to a maximum number of attempts.
    ///
    /// This generator wraps any other generator and tries to generate a value that satisfies
    /// a condition, up to a maximum number of attempts. If no value passes the condition
    /// within the maximum attempts, a fallback strategy is used.
    public struct AttemptBounded<Upstream: RandomGenerator>: RandomGenerator {
        /// The type of fallback strategy to use when max attempts are reached.
        ///
        ///
        /// > Warning: Using the keepTrying strategy may result in an infinite loop if the condition can never be satisfied.
        /// > For example, `Always(5).retry(until: { $0.isMultiple(of: 2) })` will hang indefinitely
        /// > because 5 will never be divisible by 2.
        public enum FallbackStrategy: Sendable {
            /// Return the last generated value, even if it doesn't satisfy the condition.
            case useLast
            /// Return a specific default value.
            case useDefault(Upstream.Element)
            /// Continue trying until a condition is met (no bound).

            case keepTrying
            /// Use a custom generator as fallback.
            case useAnotherGenerator(@Sendable () -> Upstream.Element)
        }

        /// The upstream generator to wrap.
        let upstream: Upstream
        
        /// The condition that must be satisfied.
        let condition: @Sendable (Upstream.Element) -> Bool
        
        /// Maximum number of attempts before applying the fallback strategy.
        let maxAttempts: Int
        
        /// The strategy to use if max attempts are reached.
        let fallbackStrategy: FallbackStrategy
        
        /// Creates a new attempt-bounded generator.
        /// - Parameters:
        ///   - upstream: The generator to wrap.
        ///   - maxAttempts: Maximum number of attempts to make.
        ///   - condition: A closure that returns true if the value is acceptable.
        ///   - fallbackStrategy: Strategy to use if max attempts are reached.
        public init(
            _ upstream: Upstream, 
            maxAttempts: Int, 
            condition: @Sendable @escaping (Upstream.Element) -> Bool,
            fallbackStrategy: FallbackStrategy = .useLast
        ) {
            self.upstream = upstream
            self.maxAttempts = maxAttempts
            self.condition = condition
            self.fallbackStrategy = fallbackStrategy
        }
        
        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Upstream.Element {
            var attempts = 0
            var lastValue = upstream.run(using: &rng)
            
            // Try to find a value that satisfies the condition
            while !condition(lastValue) && attempts < maxAttempts {
                lastValue = upstream.run(using: &rng)
                attempts += 1
            }
            
            // If we found a satisfying value, return it
            if condition(lastValue) {
                return lastValue
            }
            
            // Otherwise, apply the fallback strategy
            switch fallbackStrategy {
            case .useLast:
                return lastValue
            case .useDefault(let defaultValue):
                return defaultValue
            case .keepTrying:
                // Keep trying until we find a value
                while true {
                    let value = upstream.run(using: &rng)
                    if condition(value) {
                        return value
                    }
                }
            case .useAnotherGenerator(let generator):
                return generator()
            }
        }
    }
}

extension RandomGenerator {
    /// Bounds this generator to a maximum number of attempts, returning a value that satisfies a condition.
    ///
    /// - Parameters:
    ///   - maxAttempts: Maximum number of attempts to make.
    ///   - condition: A closure that returns true if the value is acceptable.
    ///   - fallbackStrategy: Strategy to use if max attempts are reached.
    /// - Returns: A generator that tries to produce values satisfying the condition.
    public func attemptBounded(
        maxAttempts: Int,
        condition: @Sendable @escaping (Element) -> Bool,
        fallbackStrategy: RandomGenerators.AttemptBounded<Self>.FallbackStrategy = .useLast
    ) -> RandomGenerators.AttemptBounded<Self> {
        .init(self, maxAttempts: maxAttempts, condition: condition, fallbackStrategy: fallbackStrategy)
    }
}
