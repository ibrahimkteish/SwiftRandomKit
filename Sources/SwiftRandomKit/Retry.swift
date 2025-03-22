import Foundation

extension RandomGenerators {
    /// A generator that retries generating values until a condition is met.
    ///
    /// This generator is a specialized version of `AttemptBounded` that focuses on the common
    /// retry pattern - trying repeatedly until success or a maximum number of attempts is reached.
    public struct Retry<Upstream: RandomGenerator>: RandomGenerator {
        /// The attempt-bounded generator that powers this retry generator.
        private let attempter: AttemptBounded<Upstream>
        
        /// The type of element this generator produces.
        public typealias Element = Upstream.Element
        
        /// Creates a new retry generator.
        /// - Parameters:
        ///   - upstream: The generator to retry.
        ///   - maxAttempts: Maximum number of retry attempts (defaults to 10).
        ///   - until: A closure that returns true when a retry is no longer needed.
        ///   - fallbackStrategy: What to do if max attempts are reached without success.
        public init(
            _ upstream: Upstream, 
            maxAttempts: Int = 10, 
            until condition: @Sendable @escaping (Upstream.Element) -> Bool,
            fallbackStrategy: AttemptBounded<Upstream>.FallbackStrategy = .useLast
        ) {
            self.attempter = AttemptBounded(
                upstream, 
                maxAttempts: maxAttempts, 
                condition: condition,
                fallbackStrategy: fallbackStrategy
            )
        }
        
        /// Generates a value by retrying the upstream generator.
        /// - Parameter rng: The random number generator to use.
        /// - Returns: The result of running the generator and applying retry logic.
        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Upstream.Element {
            attempter.run(using: &rng)
        }
    }
}

extension RandomGenerator {
    /// Returns a generator that retries until a condition is met or max attempts reached.
    ///
    /// This provides a cleaner, more intention-revealing API for retry operations compared
    /// to using attemptBounded directly.
    ///
    /// Example usage:
    /// ```swift
    /// // Retry generating a number until we get an even one
    /// let evenNumberGen = IntGenerator(in: 1...100)
    ///     .retry(maxAttempts: 5, until: { $0 % 2 == 0 })
    ///
    /// // Retry with a specific fallback value if all attempts fail
    /// let nonZeroGen = FloatGenerator<Double>(in: -1...1)
    ///     .retry(
    ///         maxAttempts: 3,
    ///         until: { $0 != 0 },
    ///         fallbackStrategy: .useDefault(0.5)
    ///     )
    /// ```
    ///
    /// - Parameters:
    ///   - maxAttempts: Maximum number of retry attempts (defaults to 10).
    ///   - condition: A closure that returns true when a retry is no longer needed.
    ///   - fallbackStrategy: What to do if max attempts are reached without success.
    /// - Returns: A generator that retries until the condition is met.
    public func retry(
        maxAttempts: Int = 10,
        fallbackStrategy: RandomGenerators.AttemptBounded<Self>.FallbackStrategy = .useLast,
        until condition: @Sendable @escaping (Element) -> Bool
    ) -> RandomGenerators.Retry<Self> {
        .init(
            self,
            maxAttempts: maxAttempts,
            until: condition,
            fallbackStrategy: fallbackStrategy
        )
    }
}

// MARK: - Common Retry Patterns

extension RandomGenerator {
    /// Returns a generator that retries until a non-nil value is produced.
    ///
    /// This is useful when working with transformations that might return nil.
    ///
    /// Example usage:
    /// ```swift
    /// // Parse a random string as an integer, retrying if parsing fails
    /// let stringGen = ["123", "abc", "456", "xyz"].element()
    /// let intGen = stringGen.retryMap(maxAttempts: 5) { Int($0) }
    /// ```
    ///
    /// - Parameters:
    ///   - maxAttempts: Maximum number of retry attempts.
    ///   - fallbackStrategy: What to do if max attempts are reached without success.
    ///   - transform: A closure that transforms the generator's output to an optional value.
    /// - Returns: A generator that produces non-nil transformed values.
    public func retryMap<Output>(
        maxAttempts: Int = 10,
        fallbackStrategy: RandomGenerators.AttemptBounded<Self>.FallbackStrategy = .useLast,
        _ transform: @Sendable @escaping (Element) -> Output?
    ) -> RandomGenerators.Map<RandomGenerators.Retry<Self>, Output> {
        // First, retry until we get a value that transforms to non-nil
        let retryGen = self.retry(
            maxAttempts: maxAttempts,
            fallbackStrategy: fallbackStrategy,
            until: { transform($0) != nil }
        )
        
        // Then map to extract the non-nil value
        return retryGen.map { transform($0)! }
    }
    
    /// Returns a generator that retries if an error is thrown.
    ///
    /// This is useful for generators whose values might need validation that can throw.
    ///
    /// Example usage:
    /// ```swift
    /// enum ValidationError: Error { case invalidValue }
    ///
    /// // Generate a valid number between 1-100 that's not divisible by 10
    /// let numberGen = IntGenerator(in: 1...100)
    ///     .retryThrowing(maxAttempts: 5) { value in
    ///         if value % 10 == 0 {
    ///             throw ValidationError.invalidValue
    ///         }
    ///         return value
    ///     }
    /// ```
    ///
    /// - Parameters:
    ///   - maxAttempts: Maximum number of retry attempts.
    ///   - fallbackStrategy: What to do if max attempts are reached without success.
    ///   - transform: A throwing closure that validates or transforms the generator's output.
    /// - Returns: A generator that produces values that don't throw errors when transformed.
    public func retryThrowing<Output>(
        maxAttempts: Int = 10,
        fallbackStrategy: RandomGenerators.AttemptBounded<Self>.FallbackStrategy = .useLast,
        _ transform: @Sendable @escaping (Element) throws -> Output
    ) -> RandomGenerators.Map<RandomGenerators.Retry<Self>, Output> {
        // First, retry until we get a value that doesn't throw
        let retryGen = self.retry(
            maxAttempts: maxAttempts,
            fallbackStrategy: fallbackStrategy,
            until: { value in
              do {
                _ = try transform(value)
                return true
              } catch {
                return false
              }
            }
        )
        
        // Then map to apply the transformation (which we know won't throw now)
        return retryGen.map { value in
            do {
                return try transform(value)
            } catch {
                // This should never happen since we're only mapping values that passed the retry check
                fatalError("Unexpected error during retryThrowing: \(error)")
            }
        }
    }
} 
