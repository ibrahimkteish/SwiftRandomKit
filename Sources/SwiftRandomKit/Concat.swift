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
    public func concat<NewOutput: RandomGenerator>(_ other: NewOutput, separator: Element) -> RandomGenerators.Concat<Self, NewOutput> {
        .init(self, other, separator: separator)
    }
}

extension String: Concatable {}