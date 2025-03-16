/// Extensions for generating random arrays.
extension RandomGenerators {
    /// A generator that produces arrays of a fixed size.
    ///
    /// The `Array` generator creates arrays of random elements by repeatedly running
    /// an upstream generator a specified number of times.
    ///
    /// Example usage:
    /// ```swift
    /// // Create a generator for arrays of 5 random integers between 1 and 100
    /// let intGen = IntGenerator(in: 1...100)
    /// let arrayGen = intGen.array(5)
    /// 
    /// // Generate a random array
    /// let randomArray = arrayGen.run() // e.g., [42, 17, 83, 5, 96]
    /// ```
    public struct Array<Upstream: RandomGenerator>: RandomGenerator {
        /// The generator that produces individual elements for the array.
        public let upstream: Upstream
        
        /// The fixed number of elements to include in the array.
        public let count: Int

        /// Creates a new array generator with a fixed count.
        ///
        /// - Parameters:
        ///   - upstream: The generator that produces individual elements.
        ///   - count: The number of elements to include in the generated array.
        public init(_ upstream: Upstream, _ count: Int) {
            self.upstream = upstream
            self.count = count
        }

        /// Generates a random array of the specified size.
        ///
        /// - Parameter rng: The random number generator to use.
        /// - Returns: An array of randomly generated elements.
        @inlinable
        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> [Upstream.Element] {
            (0..<count).map { _ in upstream.run(using: &rng) }
        }
    }
}

extension RandomGenerator {
    /// Creates a generator that produces arrays of a fixed size.
    ///
    /// This method allows you to create a generator that produces arrays of random elements
    /// with a specified fixed size.
    ///
    /// Example usage:
    /// ```swift
    /// // Generate 10 random boolean values
    /// let boolArrayGen = BoolRandomGenerator().array(10)
    /// let randomBools = boolArrayGen.run() // e.g., [true, false, true, true, false, ...]
    ///
    /// // Generate a random string of 8 alphanumeric characters
    /// let alphanumeric = RandomGenerators.letterOrNumber.array(8).run()
    /// let password = String(alphanumeric) // e.g., "aB3cD9xZ"
    /// ```
    ///
    /// - Parameter count: The number of elements to include in the array.
    /// - Returns: A generator that produces arrays of the specified size.
    @inlinable
    public func array(_ count: Int) -> RandomGenerators.Array<Self> {
        .init(self, count)
    }
}

extension RandomGenerators {
    /// A generator that produces arrays with a variable size determined by another generator.
    ///
    /// The `ArrayGenerator` creates arrays of random elements where the size of the array
    /// is determined by another generator. This is useful when you need arrays of varying
    /// or random lengths.
    ///
    /// Example usage:
    /// ```swift
    /// // Create a generator for arrays of random integers with random size between 3 and 7
    /// let intGen = IntGenerator(in: 1...100)
    /// let sizeGen = IntGenerator(in: 3...7)
    /// let randomArrayGen = intGen.arrayGenerator(sizeGen)
    /// 
    /// // Generate a random array with random size
    /// let randomArray = randomArrayGen.run() // e.g., [42, 17, 83, 5] (size of 4)
    /// ```
    public struct ArrayGenerator<Upstream: RandomGenerator, C: RandomGenerator>: RandomGenerator where C.Element == Int {
        /// The generator that produces individual elements for the array.
        public let upstream: Upstream
        
        /// The generator that determines how many elements to include in the array.
        public let countGenerator: C

        /// Creates a new array generator with variable size.
        ///
        /// - Parameters:
        ///   - upstream: The generator that produces individual elements.
        ///   - countGenerator: The generator that determines the array size.
        public init(_ upstream: Upstream, _ countGenerator: C) {
            self.upstream = upstream
            self.countGenerator = countGenerator
        }

        /// Generates a random array with size determined by the count generator.
        ///
        /// - Parameter rng: The random number generator to use.
        /// - Returns: An array of randomly generated elements with variable size.
        @inlinable
        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> [Upstream.Element] {
            let size = countGenerator.run(using: &rng)
            guard size > 0 else { return [] }
            var array: [Upstream.Element] = .init()
            array.reserveCapacity(size)
            (0..<size).forEach { _ in array.append(upstream.run(using: &rng)) }
            return array
        }
    }
}

extension RandomGenerator {
    /// Creates a generator that produces arrays with variable size.
    ///
    /// This method allows you to create a generator that produces arrays of random elements,
    /// where the size of the array is determined by another generator.
    ///
    /// Example usage:
    /// ```swift
    /// // Generate a random number of dice rolls (between 1 and 6 rolls)
    /// let diceGen = IntGenerator(in: 1...6)
    /// let rollCountGen = IntGenerator(in: 1...6)
    /// let diceRollsGen = diceGen.arrayGenerator(rollCountGen)
    /// 
    /// // Generate a variable number of dice rolls
    /// let diceRolls = diceRollsGen.run() // e.g., [3, 6, 1, 5] (4 rolls)
    /// ```
    ///
    /// - Parameter countGenerator: A generator that produces the count of elements to include.
    /// - Returns: A generator that produces arrays of variable size.
    @inlinable
    @inline(__always)
    public func arrayGenerator<C: RandomGenerator>(_ countGenerator: C) -> RandomGenerators.ArrayGenerator<Self, C> {
        .init(self, countGenerator)
    }
}
