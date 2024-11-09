extension RandomGenerators {
    public struct Null<Element>: RandomGenerator {
        public init() {}
        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Optional<Element> { nil }
    }
}

extension RandomGenerator {
    public func null() -> RandomGenerators.Null<Self.Element> { .init() }
}

// Void Generator
extension RandomGenerators {
    public struct VoidGenerator<Element>: RandomGenerator {
        public init() {}
        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Void { () }
    }
}

public typealias VoidGenerator = RandomGenerators.VoidGenerator