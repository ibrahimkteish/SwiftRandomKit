extension RandomGenerators {
    /// A generator that produces random collections of a specified type.
    ///
    /// The `Collection` generator creates collections of random elements by combining:
    /// - An upstream generator that produces individual elements
    /// - A count generator that determines how many elements to generate
    ///
    /// This generator is useful when you need to create random collections with a variable
    /// or dynamically determined size.
    ///
    /// Example usage:
    /// ```swift
    /// // Create a generator for random arrays of integers with random size between 3 and 7
    /// let intGen = IntGenerator(in: 1...100)
    /// let countGen = IntGenerator(in: 3...7)
    /// let randomArrayGen = intGen.collection(countGen)
    /// 
    /// // Generate a random array
    /// let randomArray = randomArrayGen.run() // e.g., [42, 17, 83, 5]
    /// ```
    ///
    /// - Note: The collection type must conform to `RangeReplaceableCollection` to allow
    ///   for element-by-element construction.
    public struct Collection<Upstream: RandomGenerator, C: RandomGenerator, ResultCollection: RangeReplaceableCollection & Sendable>: RandomGenerator where C.Element == Int, ResultCollection.Element == Upstream.Element {
        /// The generator that produces individual elements for the collection.
        let upstream: Upstream
        
        /// The generator that determines how many elements to include in the collection.
        let countGenerator: C

        /// Creates a new collection generator.
        ///
        /// - Parameters:
        ///   - upstream: The generator that produces individual elements.
        ///   - countGenerator: The generator that determines the collection size.
        public init(_ upstream: Upstream, _ countGenerator: C) {
            self.upstream = upstream
            self.countGenerator = countGenerator
        }

        /// Generates a random collection.
        ///
        /// - Parameter rng: The random number generator to use.
        /// - Returns: A collection of randomly generated elements.
        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> ResultCollection {
            let count = countGenerator.run(using: &rng)
            guard count > 0 else { return ResultCollection() }
            var collection: ResultCollection = .init()
            collection.reserveCapacity(count)
            (0..<count).forEach { _ in collection.append(upstream.run(using: &rng)) }
            return collection
        }
    }
}

extension RandomGenerator {
    /// Creates a generator that produces arrays of random elements.
    ///
    /// This method allows you to create a generator that produces arrays of random elements,
    /// where the size of the array is determined by another generator.
    ///
    /// - Parameter countGenerator: A generator that produces the count of elements to include.
    /// - Returns: A generator that produces arrays of random elements.
    ///
    /// Example usage:
    /// ```swift
    /// let intGen = IntGenerator(in: 1...100)
    /// let countGen = IntGenerator(in: 3...7) 
    /// let randomArrayGen = intGen.collection(countGen)
    /// let randomArray = randomArrayGen.run() // e.g., [42, 17, 83, 5]
    /// ```
    public func collection<C: RandomGenerator>(_ countGenerator: C) -> RandomGenerators.Collection<Self, C, [Element]> where C.Element == Int {
        .init(self, countGenerator)
    }
}
