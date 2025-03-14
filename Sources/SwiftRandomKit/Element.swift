extension RandomGenerators {
    /// A generator that selects a random element from a collection.
    ///
    /// The `Element` generator wraps another generator that produces collections and
    /// selects a random element from each generated collection. If the collection is empty,
    /// it returns `nil`.
    ///
    /// Example usage:
    /// ```swift
    /// // Select a random element from a static array
    /// let fruitGen = Always(["apple", "banana", "orange", "grape"]).element()
    /// let randomFruit = fruitGen.run() // e.g., "banana"
    ///
    /// // Using collection extensions (if available in your project)
    /// // let colorGen = ["red", "green", "blue", "yellow"].asGenerator().element()
    /// // let randomColor = colorGen.run() // e.g., "blue"
    ///
    /// // Select a random element from a dynamically generated array
    /// let dynamicArrayGen = IntGenerator(in: 1...10).map { Array(1...$0) }
    /// let randomElementGen = dynamicArrayGen.element()
    /// let randomElement = randomElementGen.run() // A random number from a randomly sized array
    ///
    /// // Handle potentially empty collections
    /// let emptyArrayGen = Always([Int]()).element()
    /// let result = emptyArrayGen.run() // Always nil because the array is empty
    /// if let number = result {
    ///     print("Selected: \(number)")
    /// } else {
    ///     print("Collection was empty")
    /// }
    /// ```
    public struct Element<Upstream: RandomGenerator>: RandomGenerator where Upstream.Element: Swift.Collection {
        /// The type of elements produced by this generator, which is an optional element from the upstream collection.
        public typealias Element = Upstream.Element.Element?
        
        /// The upstream generator providing collections to select elements from.
        public let upstream: Upstream

        /// Initializes a new element generator with the given upstream generator.
        /// - Parameter upstream: The generator that produces collections to select elements from.
        @inlinable
        public init(_ upstream: Upstream) {
            self.upstream = upstream
        }

        /// Runs the generator using the provided random number generator.
        /// - Parameter rng: The random number generator to use.
        /// - Returns: A randomly selected element from the generated collection, or nil if the collection is empty.
        @inlinable
        @inline(__always)
        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Upstream.Element.Element? {
            upstream.run(using: &rng).randomElement(using: &rng)
        }
    }
}

extension RandomGenerator where Element: Swift.Collection {
    /// Creates a generator that selects a random element from each generated collection.
    ///
    /// This method is useful when you have a generator that produces collections and you want
    /// to randomly select a single element from each collection. If a generated collection is empty,
    /// the resulting generator will produce `nil`.
    ///
    /// - Returns: A generator that produces random elements from the generated collections.
    @inlinable
    public func element() -> RandomGenerators.Element<Self> {
        .init(self)
    }
}
