extension RandomGenerators {
    public struct Always<Element>: RandomGenerator {
        let value: Element

        public init(_ value: Element) {
            self.value = value
        }

        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Element {
            value
        }
    }
}

extension RandomGenerator {
    public func always(_ value: Element) -> RandomGenerators.Always<Element> {
        .init(value)
    }
}

public typealias Always<Element> = RandomGenerators.Always<Element>