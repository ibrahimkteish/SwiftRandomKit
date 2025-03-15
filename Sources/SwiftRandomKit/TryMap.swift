extension RandomGenerators {
    /// A random generator that attempts to transform elements from an upstream generator, potentially throwing an error.
    ///
    /// Example usage:
    /// ```swift
    /// // Create a generator that tries to parse integers from strings
    /// let stringGen = ["123", "456", "invalid", "789"].element()
    /// let intGen = stringGen.tryMap { str -> Int in
    ///     guard let number = Int(str) else {
    ///         throw ValidationError.invalidNumber
    ///     }
    ///     return number
    /// }
    /// 
    /// let result = intGen.run() // Returns .success(123) or .failure(error)
    /// ```
    public struct TryMap<Upstream: RandomGenerator, ElementOfResult>: RandomGenerator {
        /// The type of elements produced by this generator, wrapped in a Result type.
        public typealias Element = Result<ElementOfResult, Error>
        
        /// The upstream generator providing input elements.
        public let generator: Upstream
        
        /// The transformation function that may throw an error.
        public let transform: (Upstream.Element) throws -> ElementOfResult

        /// Initializes a new try-map generator with the given upstream generator and transformation.
        /// - Parameters:
        ///   - generator: The upstream generator to transform elements from.
        ///   - transform: A function that attempts to transform elements, potentially throwing an error.
        public init(_ generator: Upstream, _ transform: @escaping (Upstream.Element) throws -> ElementOfResult) {
            self.generator = generator
            self.transform = transform
        }

        /// Runs the generator using the provided random number generator.
        /// - Parameter rng: The random number generator to use.
        /// - Returns: A Result containing either the successfully transformed element or an error.
        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Element {
            do {
                return .success(try transform(generator.run(using: &rng)))
            } catch {
                return .failure(error)
            }
        }
    }
}

extension RandomGenerator {
    /// Creates a generator that attempts to transform elements using a throwing transformation function.
    /// - Parameter transform: A function that attempts to transform elements, potentially throwing an error.
    /// - Returns: A generator that produces Results of either successfully transformed elements or errors.
    @inlinable
    public func tryMap<ElementOfResult>(
        _ transform: @escaping (Element) throws -> ElementOfResult
    ) -> RandomGenerators.TryMap<Self, ElementOfResult> {
        return .init(self, transform)
    }
}
