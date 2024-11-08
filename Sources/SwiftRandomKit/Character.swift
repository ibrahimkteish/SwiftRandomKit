extension RandomGenerators {
    public struct Character<Upstream: RandomGenerator>: RandomGenerator where Upstream.Element == Swift.Character {
        public typealias Element = Swift.Character

        let generator: Upstream
        let closedRange: ClosedRange<Swift.Character>

        public init(_ generator: Upstream, in range: ClosedRange<Swift.Character>) {
            self.generator = generator
            self.closedRange = range
        }

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
    static func character(in range: ClosedRange<Swift.Character>) -> AnyRandomGenerator<Swift.Character> {
        return IntGenerator<UInt32>(in: range.lowerBound.unicodeScalars.first!.value...range.upperBound.unicodeScalars.last!.value)
            .map { Swift.Character(Swift.UnicodeScalar($0)!) }
            .eraseToAnyRandomGenerator()
    }

    /// A generator of random numeric digits.
    static var number: some RandomGenerator<Swift.Character> {
        character(in: "0"..."9")
    }
    /// A generator of uppercase letters.
    static var uppercaseLetter: some RandomGenerator<Swift.Character> {
        character(in: "A"..."Z")
    }

    /// A generator of lowercase letters.
    static var lowercaseLetter: some RandomGenerator<Swift.Character> {
        character(in: "a"..."z")
    }
}

public extension RandomGenerators {
    /// A generator of uppercase and lowercase letters.
    static var letter: some RandomGenerator<Swift.Character> {
        Always(Swift.Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"))
        .element()
        .map { $0! }
    }

     /// A generator of letters and numbers.
    static var letterOrNumber: some RandomGenerator<Swift.Character> {
        Always(Swift.Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"))
            .element()
            .map { $0! }
    }

    /// A generator of ASCII characters.
    static var ascii: some RandomGenerator<Swift.Character> {
        IntGenerator<UInt32>(in: 0...127)
            .map { Swift.Character(Swift.UnicodeScalar($0)!) }
    }

    /// A generator of Latin-1 characters.
    static var latin1: some RandomGenerator<Swift.Character> {
        IntGenerator<UInt32>(in: 0...255)
            .map { Swift.Character(Swift.UnicodeScalar($0)!) }
    }
}