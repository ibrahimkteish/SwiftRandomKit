extension RandomGenerators {
    /// A generator that produces strings by drawing characters from an upstream generator.
    ///
    /// This replaces the recurring `.array(n).map(String.init)` dance and builds the
    /// string directly, without an intermediate array.
    ///
    /// Example usage:
    /// ```swift
    /// // An 8-character alphanumeric code
    /// let code = RandomGenerators.string(of: RandomGenerators.letterOrNumber, count: 8)
    /// code.run() // e.g., "a7Bf9pQ3"
    ///
    /// // Or fluently from any Character generator
    /// let pin = RandomGenerators.number.string(count: 4).run() // e.g., "0417"
    /// ```
    public struct StringOf<C: RandomGenerator>: RandomGenerator where C.Element == Swift.Character {
        public typealias Element = Swift.String

        /// The generator that produces each character.
        let character: C

        /// The number of characters in each generated string.
        let count: Int

        /// Creates a generator that produces strings of `count` characters.
        ///
        /// - Parameters:
        ///   - character: The generator that produces each character.
        ///   - count: The number of characters per string. Must be non-negative.
        public init(_ character: C, count: Int) {
            precondition(count >= 0, "count must be non-negative, got \(count)")
            self.character = character
            self.count = count
        }

        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Swift.String {
            var string = ""
            string.reserveCapacity(count)
            for _ in 0..<count {
                string.append(character.run(using: &rng))
            }
            return string
        }
    }

    /// Creates a generator that produces strings of `count` characters drawn from `character`.
    ///
    /// - Parameters:
    ///   - character: The generator that produces each character.
    ///   - count: The number of characters per string.
    /// - Returns: A generator of strings.
    public static func string<C: RandomGenerator>(of character: C, count: Int) -> StringOf<C> {
        StringOf(character, count: count)
    }
}

extension RandomGenerators.StringOf: Sendable where C: Sendable {}

extension RandomGenerator where Element == Character {
    /// Collects `count` characters from this generator into a string.
    ///
    /// - Parameter count: The number of characters per string.
    /// - Returns: A generator of strings.
    public func string(count: Int) -> RandomGenerators.StringOf<Self> {
        .init(self, count: count)
    }
}
