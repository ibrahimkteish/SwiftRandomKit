/// A type-erased wrapper around any random generator.
///
/// `AnyRandomGenerator` allows you to hide the concrete type of a random generator
/// while preserving its behavior. This is useful when you want to:
///
/// - Store generators of different concrete types in the same collection
/// - Return a generator from a function without exposing its implementation details
/// - Reduce generic complexity in your code
/// 
public struct AnyRandomGenerator<Element: Sendable>: RandomGenerator {
    /// The function that will be called to generate random values.
    ///
    /// This property stores the type-erased generation logic from the original generator.
    public let _run: @Sendable (inout any RandomNumberGenerator) -> Element

    /// Creates a type-erased generator from another random generator.
    ///
    /// This initializer takes any generator that produces the same element type
    /// and wraps it in a type-erased container.
    ///
    /// - Parameter generator: The generator to type-erase.
    public init<Upstream: RandomGenerator>(_ generator: Upstream) where Upstream.Element == Element {
        self._run = { rng in
            generator.run(using: &rng)
        }
    }

    /// Creates a type-erased generator from a function that generates random values.
    ///
    /// This initializer allows you to create a generator directly from a function
    /// without having to create a concrete generator type first.
    ///
    /// Example usage:
    /// ```swift
    /// // Create a generator from a closure
    /// let customGen = AnyRandomGenerator<Int> { rng in
    ///     return Int.random(in: 1...100, using: &rng) * 2
    /// }
    /// ```
    ///
    /// - Parameter run: A function that takes a random number generator and returns a random value.
    public init(_ run: @Sendable @escaping (inout any RandomNumberGenerator) -> Element) {
        self._run = run
    }
    
    /// Generates a random value.
    ///
    /// This method delegates to the stored generation function, type-erasing
    /// the provided random number generator.
    ///
    /// - Parameter rng: The random number generator to use.
    /// - Returns: A randomly generated value of type `Element`.
    @inlinable
    @inline(__always)
    public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Element {
        var anyRNG: any RandomNumberGenerator = rng
        return _run(&anyRNG)
    }
    
    /// Returns self since this is already a type-erased generator.
    ///
    /// This method is provided for API consistency, so you can call `eraseToAnyRandomGenerator()`
    /// on any generator including one that's already type-erased.
    ///
    /// - Returns: The same generator, unchanged.
    public func eraseToAnyRandomGenerator() -> AnyRandomGenerator<Element> {
        self
    }
}

extension RandomGenerator {
    /// Wraps this generator in a type-erased container.
    ///
    /// Use this method when you want to hide the concrete type of a generator
    /// while preserving its behavior. This is particularly useful when:
    ///
    /// - Returning generators from functions without exposing implementation details
    /// - Storing generators of different concrete types in the same collection
    /// - Reducing generic complexity in your API
    ///
    /// Example usage:
    /// ```swift
    /// func createGenerator() -> AnyRandomGenerator<Int> {
    ///     // The caller doesn't need to know it's an IntGenerator
    ///     return IntGenerator(in: 1...100).eraseToAnyRandomGenerator()
    /// }
    /// ```
    ///
    /// - Returns: A type-erased generator that has the same behavior as this generator.
    @inlinable
    public func eraseToAnyRandomGenerator() -> AnyRandomGenerator<Element> {
        .init(self)
    }
}
