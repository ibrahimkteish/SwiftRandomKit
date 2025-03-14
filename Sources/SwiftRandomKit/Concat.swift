public protocol Concatable {
    static func +(lhs: Self, rhs: Self) -> Self
}

extension RandomGenerators {
    public struct Concat<First: RandomGenerator, Second: RandomGenerator>: RandomGenerator where First.Element == Second.Element, First.Element: Concatable {
        public typealias Element = First.Element

        public let first: First
        public let second: Second
        public let separator: Element
        
        public init(_ first: First, _ second: Second, separator: Element) {
            self.first = first
            self.second = second
            self.separator = separator
        }

        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Element {
            first.run(using: &rng) + separator + second.run(using: &rng)
        }
    }
}

extension RandomGenerator {
    @inlinable
    public func concat<NewOutput: RandomGenerator>(_ other: NewOutput, separator: Element) -> RandomGenerators.Concat<Self, NewOutput> where NewOutput.Element == Element, Element: Concatable {
        .init(self, other, separator: separator)
    }
}

// Even though String already has a + operator, we need to explicitly declare
// conformance to our Concatable protocol for the type system to recognize it.
// This doesn't introduce any new functionality, it just formalizes the relationship.
extension String: Concatable {}
