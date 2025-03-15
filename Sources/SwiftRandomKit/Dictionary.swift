extension RandomGenerators {
  /// A generator that produces dictionaries of key-value pairs.
  ///
  /// The `Dictionary` generator creates dictionaries by generating multiple key-value pairs
  /// from an upstream generator and a count generator that determines the dictionary size.
  /// If duplicate keys are generated, later values will overwrite earlier ones.
  ///
  /// Example usage:
  /// ```swift
  /// 
  /// // Generate a dictionary with random size
  /// let pairGen =  ["name", "age", "score", "level"].randomGeneratorElement().zip(IntGenerator(in: 1...100))
  /// let dictGen = pairGen.dictionary(Always(3))
  /// let result = dictGen.run() // e.g., ["name": 42, "level": 87, "score": 13] or ["name": 42, "level": 87]
  /// ```
  public struct Dictionary<Upstream: RandomGenerator, C: RandomGenerator<Int>, K: Hashable, V>: RandomGenerator where Upstream.Element == (K, V) {
        /// The type of elements produced by this generator.
        public typealias Element = [K: V]
        
        /// The upstream generator providing key-value pairs.
        let upstream: Upstream
        
        /// The generator that determines how many key-value pairs to generate.
        let countGenerator: C

        /// Initializes a new dictionary generator with the given upstream generator and count generator.
        /// - Parameters:
        ///   - upstream: The generator that produces key-value pairs.
        ///   - countGenerator: The generator that determines how many key-value pairs to generate.
        public init(_ upstream: Upstream, _ countGenerator: C) {
            self.upstream = upstream
            self.countGenerator = countGenerator
        }

        /// Runs the generator using the provided random number generator.
        /// - Parameter rng: The random number generator to use.
        /// - Returns: A dictionary containing the generated key-value pairs.
        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> [K: V] {
            let size = countGenerator.run(using: &rng)
            var dictionary: [K: V] = [:]
            for _ in 0..<size {
                let (k, v) = upstream.run(using: &rng)
                dictionary[k] = v
            }
            return dictionary
        }
    }
}


extension RandomGenerator {
    /// Creates a generator that produces dictionaries from key-value pairs.
    ///
    /// This method is useful when you have a generator that produces key-value pairs (tuples)
    /// and you want to collect them into dictionaries. The count generator determines how many
    /// pairs to generate for each dictionary.
    ///
    /// - Parameter countGenerator: A generator that determines how many key-value pairs to include in each dictionary.
    /// - Returns: A generator that produces dictionaries containing the generated key-value pairs.
    public func dictionary<C: RandomGenerator<Int>, K: Hashable, V>(_ countGenerator: C) -> RandomGenerators.Dictionary<Self, C, K, V> where Element == (K, V) {
        .init(self, countGenerator)
    }
}
