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
        ///   - condition: A closure that returns true when a retry is no longer needed.
        ///   - fallbackStrategy: What to do if max attempts are reached without success.
        public init(
            _ upstream: Upstream, 
            maxAttempts: Int = 10, 
            until condition: @escaping (Upstream.Element) -> Bool,
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
        until condition: @escaping (Element) -> Bool
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
    /// With the default `.useLast` fallback, exhausting the attempts produces `nil`.
    ///
    /// Example usage:
    /// ```swift
    /// // Parse a random string as an integer, retrying if parsing fails
    /// let stringGen = ["123", "abc", "456", "xyz"].element()
    /// let intGen = stringGen.retryMap(maxAttempts: 5) { $0.flatMap(Int.init) }
    /// let value = intGen.run() // e.g., 123, or nil if no attempt succeeded
    /// ```
    ///
    /// - Parameters:
    ///   - maxAttempts: Maximum number of retry attempts.
    ///   - fallbackStrategy: What to do if max attempts are reached without success.
    ///   - transform: A closure that transforms the generator's output to an optional value.
    /// - Returns: A generator that produces the transformed value, or nil when no attempt succeeded.
    public func retryMap<Output>(
        maxAttempts: Int = 10,
        fallbackStrategy: RandomGenerators.AttemptBounded<RandomGenerators.Map<Self, Output?>>.FallbackStrategy = .useLast,
        _ transform: @escaping (Element) -> Output?
    ) -> RandomGenerators.Retry<RandomGenerators.Map<Self, Output?>> {
        self.map(transform).retry(
            maxAttempts: maxAttempts,
            fallbackStrategy: fallbackStrategy,
            until: { $0 != nil }
        )
    }
    
    /// Returns a generator that retries if an error is thrown.
    ///
    /// This is useful for generators whose values might need validation that can throw.
    /// The transformation runs once per generated value, and the result is delivered
    /// as a `Result`: `.success` when an attempt succeeds, or the last `.failure`
    /// when the attempt budget is exhausted (with the default `.useLast` fallback).
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
    /// let number = try numberGen.run().get()
    /// ```
    ///
    /// - Parameters:
    ///   - maxAttempts: Maximum number of retry attempts.
    ///   - fallbackStrategy: What to do if max attempts are reached without success.
    ///   - transform: A throwing closure that validates or transforms the generator's output.
    /// - Returns: A generator that produces a `Result` of the transformation.
    public func retryThrowing<Output>(
        maxAttempts: Int = 10,
        fallbackStrategy: RandomGenerators.AttemptBounded<RandomGenerators.TryMap<Self, Output>>.FallbackStrategy = .useLast,
        _ transform: @escaping (Element) throws -> Output
    ) -> RandomGenerators.Retry<RandomGenerators.TryMap<Self, Output>> {
        self.tryMap(transform).retry(
            maxAttempts: maxAttempts,
            fallbackStrategy: fallbackStrategy,
            until: { result in
                if case .success = result { return true }
                return false
            }
        )
    }
}
