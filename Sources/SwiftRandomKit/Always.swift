extension RandomGenerators {
    /// A generator that always produces the given value, regardless of the random number generator used.
    ///
    /// While simple, the `Always` generator is useful when combined with other generators or operators.
    /// It can serve as a constant value in a chain of generator operations.
    ///
    /// When its `Element` is `Void`, it can be used as a "no-op" generator and be plugged into
    /// other generator operations.
    ///
    /// Example usage:
    /// ```swift
    /// // Always generate the same number
    /// let constantGen = Always(42)
    /// let value = constantGen.run() // Always 42
    ///
    /// // Combine with other generators
    /// let coinFlipGen = BoolRandomGenerator()
    /// let combinedGen = coinFlipGen.flatMap { isHeads in
    ///     isHeads ? Always("Heads") : Always("Tails")
    /// }
    /// ```
    public struct Always<Element>: RandomGenerator {
        /// The value that this generator will always produce
        let value: Element

        /// Creates a generator that always produces the given value.
        ///
        /// - Parameter value: The value that will be returned every time this generator runs.
        public init(_ value: Element) {
            self.value = value
        }

        /// Runs the generator, always returning the stored value regardless of the provided RNG.
        ///
        /// - Parameter rng: The random number generator (unused in this implementation).
        /// - Returns: The stored value.
        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Element {
            value
        }
    }
}

extension RandomGenerator {
    /// Creates a generator that always produces the given value.
    ///
    /// This convenience method allows you to easily create an `Always` generator from any value.
    ///
    /// Example usage:
    /// ```swift
    /// // Create a generator that always returns "Hello"
    /// let greetingGen = RandomGenerators.BoolRandomGenerator().flatMap { isHello in
    ///     isHello ? Always("Hello") : Always("Goodbye")
    /// }
    /// ```
    ///
    /// - Parameter value: The value that will be returned every time the generator runs.
    /// - Returns: A generator that always produces the given value.
    @inlinable
    public func always(_ value: Element) -> RandomGenerators.Always<Element> {
        .init(value)
    }
}

/// Type alias for easier access to the Always generator.
public typealias Always<Element> = RandomGenerators.Always<Element>

extension Always: Equatable where Element: Equatable {}
extension Always: Sendable where Element: Sendable {}
extension Always: Hashable where Element: Hashable {}

extension Always where Element: Equatable {
    /// Returns the same Always generator unchanged.
    ///
    /// Since an Always generator always produces the same value, removing duplicates
    /// has no effect - it simply returns the same generator.
    ///
    /// - Returns: The same Always generator.
    public func removeDuplicates() -> Always<Element> {
        return self
    }
}

extension Always {
    /// Converts the Always generator to an Always generator that produces a single-element array.
    ///
    /// This method wraps the always-produced value in a single-element array.
    ///
    /// Example usage:
    /// ```swift
    /// let constantGen = Always(42)
    /// let arrayGen = constantGen.collect()
    /// let array = arrayGen.run() // [42]
    /// ```
    ///
    /// - Returns: An Always generator that produces a single-element array containing the original value.
    public func collect() -> Always<[Element]> {
        return .init([value])
    }

    /// Transforms the Always generator by applying a transformation to its value.
    ///
    /// Since an Always generator produces a constant value, this method transforms
    /// that value using the provided function and returns a new Always generator
    /// that will always produce the transformed value.
    ///
    /// Example usage:
    /// ```swift
    /// let numberGen = Always(5)
    /// let doubledGen = numberGen.map { $0 * 2 }
    /// let doubled = doubledGen.run() // Always 10
    ///
    /// let stringGen = Always("hello")
    /// let uppercaseGen = stringGen.map { $0.uppercased() }
    /// let uppercase = uppercaseGen.run() // Always "HELLO"
    /// ```
    ///
    /// - Parameter transform: A function that transforms the generator's value.
    /// - Returns: A new Always generator that produces the transformed value.
    public func map<ElementOfResult>(
        _ transform: (Element) -> ElementOfResult
    ) -> Always<ElementOfResult> {
        return .init(transform(value))
    }

    /// Returns the same Always generator unchanged.
    ///
    /// Since an Always generator always produces the same value, removing duplicates
    /// using a custom predicate has no effect - it simply returns the same generator.
    ///
    /// - Parameter predicate: A function that determines whether two elements are equal.
    /// - Returns: The same Always generator.
    public func removeDuplicates(
        by predicate: (Element, Element) -> Bool
    ) -> Always<Element> {
        return self
    }
}