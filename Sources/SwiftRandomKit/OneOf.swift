extension RandomGenerators {
    /// A generator that picks uniformly between two generators of the same element type.
    ///
    /// Unlike `Frequency`, which weights same-type generators, the `oneOf` family accepts
    /// generators of *different concrete types* (as long as they produce the same element)
    /// and gives each an equal chance of being selected.
    ///
    /// Example usage:
    /// ```swift
    /// // A fair mix of a die roll, a constant, and a wide range
    /// let mixed = RandomGenerators.oneOf(
    ///     IntGenerator(in: 1...6),
    ///     Always(0),
    ///     IntGenerator(in: 100...200)
    /// )
    /// let value = mixed.run() // each source selected with probability 1/3
    /// ```
    ///
    /// > Note: These are fixed-arity types because Swift's parameter packs cannot yet
    /// > express "every pack element has the same `Element`" (same-element requirements).
    /// > For arbitrary arity with a single generator type, use
    /// > `RandomGenerators.frequency(gens.map { (1, $0) })`.
    public struct OneOf2<G1: RandomGenerator, G2: RandomGenerator>: RandomGenerator
    where G1.Element == G2.Element {
        public typealias Element = G1.Element

        let first: G1
        let second: G2

        public init(_ first: G1, _ second: G2) {
            self.first = first
            self.second = second
        }

        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Element {
            switch IntGenerator(in: 0...1).run(using: &rng) {
            case 0: return first.run(using: &rng)
            default: return second.run(using: &rng)
            }
        }
    }

    /// A generator that picks uniformly among three generators of the same element type.
    /// See ``OneOf2`` for discussion.
    public struct OneOf3<G1: RandomGenerator, G2: RandomGenerator, G3: RandomGenerator>: RandomGenerator
    where G1.Element == G2.Element, G1.Element == G3.Element {
        public typealias Element = G1.Element

        let first: G1
        let second: G2
        let third: G3

        public init(_ first: G1, _ second: G2, _ third: G3) {
            self.first = first
            self.second = second
            self.third = third
        }

        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Element {
            switch IntGenerator(in: 0...2).run(using: &rng) {
            case 0: return first.run(using: &rng)
            case 1: return second.run(using: &rng)
            default: return third.run(using: &rng)
            }
        }
    }

    /// A generator that picks uniformly among four generators of the same element type.
    /// See ``OneOf2`` for discussion.
    public struct OneOf4<G1: RandomGenerator, G2: RandomGenerator, G3: RandomGenerator, G4: RandomGenerator>: RandomGenerator
    where G1.Element == G2.Element, G1.Element == G3.Element, G1.Element == G4.Element {
        public typealias Element = G1.Element

        let first: G1
        let second: G2
        let third: G3
        let fourth: G4

        public init(_ first: G1, _ second: G2, _ third: G3, _ fourth: G4) {
            self.first = first
            self.second = second
            self.third = third
            self.fourth = fourth
        }

        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Element {
            switch IntGenerator(in: 0...3).run(using: &rng) {
            case 0: return first.run(using: &rng)
            case 1: return second.run(using: &rng)
            case 2: return third.run(using: &rng)
            default: return fourth.run(using: &rng)
            }
        }
    }
}

extension RandomGenerators.OneOf2: Sendable where G1: Sendable, G2: Sendable {}
extension RandomGenerators.OneOf3: Sendable where G1: Sendable, G2: Sendable, G3: Sendable {}
extension RandomGenerators.OneOf4: Sendable where G1: Sendable, G2: Sendable, G3: Sendable, G4: Sendable {}

extension RandomGenerators {
    /// Creates a generator that picks uniformly between two generators.
    public static func oneOf<G1, G2>(_ first: G1, _ second: G2) -> OneOf2<G1, G2> {
        OneOf2(first, second)
    }

    /// Creates a generator that picks uniformly among three generators.
    public static func oneOf<G1, G2, G3>(_ first: G1, _ second: G2, _ third: G3) -> OneOf3<G1, G2, G3> {
        OneOf3(first, second, third)
    }

    /// Creates a generator that picks uniformly among four generators.
    public static func oneOf<G1, G2, G3, G4>(_ first: G1, _ second: G2, _ third: G3, _ fourth: G4) -> OneOf4<G1, G2, G3, G4> {
        OneOf4(first, second, third, fourth)
    }
}
