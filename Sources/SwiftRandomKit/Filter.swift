 import Foundation

extension RandomGenerators {
    /// A generator that produces values that satisfy a predicate.
    ///
    /// The `Filter` generator repeatedly runs the upstream generator until it produces
    /// a value that satisfies the given predicate, with a maximum number of attempts.
    public struct Filter<Upstream: RandomGenerator>: RandomGenerator {
        /// The upstream generator.
        private let attempter: AttemptBounded<Upstream>
        
        /// The type of elements produced by this generator.
        public typealias Element = Upstream.Element
        
        /// Creates a generator that produces values that satisfy a predicate.
        ///
        /// - Parameters:
        ///   - upstream: The generator to filter.
        ///   - maxAttempts: Maximum number of attempts before applying the fallback strategy.
        ///   - predicate: A closure that returns true if the value should be included.
        ///   - fallbackStrategy: What to do if max attempts are reached without satisfying the predicate.
        public init(
            _ upstream: Upstream, 
            maxAttempts: Int = 100, 
            predicate: @Sendable @escaping (Upstream.Element) -> Bool,
            fallbackStrategy: AttemptBounded<Upstream>.FallbackStrategy = .useLast
        ) {
          self.attempter = upstream.attemptBounded(maxAttempts: maxAttempts,
            condition: predicate,
            fallbackStrategy: fallbackStrategy
          )
        }
        
        /// Generates a value by filtering the upstream generator.
        /// - Parameter rng: The random number generator to use.
        /// - Returns: A value that satisfies the predicate.
        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Upstream.Element {
            attempter.run(using: &rng)
        }
    }
}

extension RandomGenerator {
    /// Returns a generator that only produces values that satisfy the given predicate.
    ///
    /// This method is useful for filtering out unwanted values. The resulting generator
    /// will repeatedly generate values until one satisfies the predicate.
    ///
    /// Example usage:
    /// ```swift
    /// // Generate only even numbers
    /// let evenGen = IntGenerator(in: 1...100).filter { $0 % 2 == 0 }
    /// 
    /// // Generate non-empty strings
    /// let nonEmptyGen = ["hello", "", "world", ""].element().filter { !$0.isEmpty }
    /// ```
    ///
    /// - Parameters:
    ///   - maxAttempts: Maximum number of attempts before applying the fallback strategy.
    ///   - predicate: A closure that returns true if the value should be included.
    ///   - fallbackStrategy: What to do if max attempts are reached without satisfying the predicate.
    /// - Returns: A generator that only produces values that satisfy the predicate.
    public func filter(
        maxAttempts: Int = 100,
        _ predicate: @Sendable @escaping (Element) -> Bool,
        fallbackStrategy: RandomGenerators.AttemptBounded<Self>.FallbackStrategy = .useLast
    ) -> RandomGenerators.Filter<Self> {
        .init(
            self,
            maxAttempts: maxAttempts,
            predicate: predicate,
            fallbackStrategy: fallbackStrategy
        )
    }
    
    /// Returns a generator that filters out nil values after transformation.
    ///
    /// This method is similar to `compactMap` in Swift's standard library. It applies
    /// a transformation to each generated value and only includes non-nil results.
    ///
    /// Example usage:
    /// ```swift
    /// // Generate random strings and parse them as integers
    /// let stringGen = ["123", "abc", "456", "xyz"].element()
    /// let intGen = stringGen.compactMap { Int($0) }
    /// ```
    ///
    /// - Parameters:
    ///   - maxAttempts: Maximum number of attempts before giving up.
    ///   - fallbackStrategy: What to do if max attempts are reached without success.
    ///   - transform: A closure that transforms values and can return nil.
    /// - Returns: A generator that produces non-nil transformed values.
    public func compactMap<Output>(
        maxAttempts: Int = 100,
        fallbackStrategy: RandomGenerators.AttemptBounded<Self>.FallbackStrategy = .useLast,
        _ transform: @Sendable @escaping (Element) -> Output?
    ) -> RandomGenerators.Map<RandomGenerators.Filter<Self>, Output> {
        // First filter to only values that transform to non-nil
        let filteredGen = self.filter(
            maxAttempts: maxAttempts,
            { transform($0) != nil },
            fallbackStrategy: fallbackStrategy
        )
        
        // Then map to extract the non-nil value
        return filteredGen.map { transform($0)! }
    }
}
