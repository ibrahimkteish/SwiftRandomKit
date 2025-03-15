extension RandomGenerators {
    /// A generator that produces random characters.
    ///
    /// The `Character` generator creates random characters within a specified range.
    /// It works by mapping the unicode scalar values to characters.
    public struct Character<Upstream: RandomGenerator>: RandomGenerator where Upstream.Element == Swift.Character {
        public typealias Element = Swift.Character

        /// The upstream generator that produces characters.
        let generator: Upstream
        
        /// The range of characters to generate from.
        let closedRange: ClosedRange<Swift.Character>

        /// Creates a new character generator with the specified range.
        ///
        /// - Parameters:
        ///   - generator: The upstream generator that produces characters.
        ///   - range: The range of characters to generate from.
        public init(_ generator: Upstream, in range: ClosedRange<Swift.Character>) {
            self.generator = generator
            self.closedRange = range
        }

        /// Generates a random character.
        ///
        /// - Parameter rng: The random number generator to use.
        /// - Returns: A random character within the specified range.
        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Swift.Character {
            // Map the Character generator to a UnicodeScalar generator
            let unicodeGenerator = generator.map { $0.unicodeScalars.first! }
            let scalarGenerator = RandomGenerators.UnicodeScalar(unicodeGenerator, in: closedRange.lowerBound.unicodeScalars.first!...closedRange.upperBound.unicodeScalars.last!)
            let scalar = scalarGenerator.run(using: &rng)
            return Swift.Character(scalar)
        }
    }
}

public extension RandomGenerator where Element == Swift.Character {
    /// Creates a generator that produces characters within a specified range.
    ///
    /// - Parameter range: The range of characters to generate from.
    /// - Returns: A generator that produces random characters within the specified range.
    func character(in range: ClosedRange<Swift.Character>) -> RandomGenerators.Character<Self> {
        .init(self, in: range)
    }
}

extension RandomGenerators {
    /// Returns a generator of random characters within the specified range.
    ///
    /// - Parameter range: The range in which to create a random character. `range` must be finite.
    /// - Returns: A generator of random characters within the bounds of range.
    @inlinable
    public static func character(in range: ClosedRange<Swift.Character>) -> AnyRandomGenerator<Swift.Character> {
        return IntGenerator<UInt32>(in: range.lowerBound.unicodeScalars.first!.value...range.upperBound.unicodeScalars.last!.value)
            .map { Swift.Character(Swift.UnicodeScalar($0)!) }
            .eraseToAnyRandomGenerator()
    }

    /// A generator of random numeric digits.
    ///
    /// Produces random characters in the range "0" to "9".
    ///
    /// Example usage:
    /// ```swift
    /// let digitGen = RandomGenerators.number
    /// let digit = digitGen.run() // e.g., "7"
    /// ```
    public static var number: some RandomGenerator<Swift.Character> {
        character(in: "0"..."9")
    }
    
    /// A generator of uppercase letters.
    ///
    /// Produces random characters in the range "A" to "Z".
    ///
    /// Example usage:
    /// ```swift
    /// let uppercaseGen = RandomGenerators.uppercaseLetter
    /// let letter = uppercaseGen.run() // e.g., "M"
    /// ```
    public static var uppercaseLetter: some RandomGenerator<Swift.Character> {
        character(in: "A"..."Z")
    }

    /// A generator of lowercase letters.
    ///
    /// Produces random characters in the range "a" to "z".
    ///
    /// Example usage:
    /// ```swift
    /// let lowercaseGen = RandomGenerators.lowercaseLetter
    /// let letter = lowercaseGen.run() // e.g., "k"
    /// ```
    public static var lowercaseLetter: some RandomGenerator<Swift.Character> {
        character(in: "a"..."z")
    }
}

public extension RandomGenerators {
    /// A generator of uppercase and lowercase letters.
    ///
    /// Produces random alphabetic characters, selecting from both uppercase and lowercase letters.
    ///
    /// Example usage:
    /// ```swift
    /// let letterGen = RandomGenerators.letter
    /// let randomLetter = letterGen.run() // e.g., "G" or "t"
    /// 
    /// // Generate a random 5-letter sequence
    /// let randomLetters = letterGen.array(5).run() // e.g., ["a", "Z", "f", "B", "p"]
    /// ```
    static var letter: some RandomGenerator<Swift.Character> {
        Always(Swift.Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"))
        .element()
        .map { $0! }
    }

    /// A generator of letters and numbers.
    ///
    /// Produces random alphanumeric characters, selecting from uppercase letters, 
    /// lowercase letters, and digits.
    ///
    /// Example usage:
    /// ```swift
    /// let alphanumericGen = RandomGenerators.letterOrNumber
    /// let randomChar = alphanumericGen.run() // e.g., "8" or "A" or "j"
    /// 
    /// // Generate a random 8-character alphanumeric code
    /// let code = alphanumericGen.array(8).run().map(String.init).joined() // e.g., "a7Bf9pQ3"
    /// ```
    static var letterOrNumber: some RandomGenerator<Swift.Character> {
        Always(Swift.Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"))
            .element()
            .map { $0! }
    }

    /// A generator of ASCII characters.
    ///
    /// Produces random characters from the ASCII character set (characters with 
    /// Unicode values from 0 to 127).
    ///
    /// Example usage:
    /// ```swift
    /// let asciiGen = RandomGenerators.ascii
    /// let asciiChar = asciiGen.run() // e.g., "A", "~", or a control character
    /// ```
    ///
    /// Note: This includes control characters and other non-printable characters.
    /// For printable characters only, consider using a more restricted range.
    static var ascii: some RandomGenerator<Swift.Character> {
        IntGenerator<UInt32>(in: 0...127)
            .map { Swift.Character(Swift.UnicodeScalar($0)!) }
    }

    /// A generator of Latin-1 characters.
    ///
    /// Produces random characters from the Latin-1 character set (characters with
    /// Unicode values from 0 to 255), which includes ASCII plus extended Latin characters.
    ///
    /// Example usage:
    /// ```swift
    /// let latin1Gen = RandomGenerators.latin1
    /// let latin1Char = latin1Gen.run() // e.g., "A", "é", "ß"
    /// ```
    ///
    /// Note: This includes control characters and other non-printable characters.
    /// For printable characters only, consider using a more restricted range.
    static var latin1: some RandomGenerator<Swift.Character> {
        IntGenerator<UInt32>(in: 0...255)
            .map { Swift.Character(Swift.UnicodeScalar($0)!) }
    }
}