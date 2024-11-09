extension RandomGenerators {
    public struct Shuffled<Upstream: RandomGenerator>: RandomGenerator where Upstream.Element: Swift.Collection, Upstream.Element: MutableCollection, Upstream.Element: RandomAccessCollection, Upstream.Element.Element: Equatable {
        public typealias Element = Upstream.Element
        let generator: Upstream

        public init(_ generator: Upstream) {
            self.generator = generator
        }

        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Upstream.Element {
            var array = generator.run(using: &rng)
            array.shuffle(using: &rng)
            return array
        }
    }
}

public extension RandomGenerator where Element: Collection & MutableCollection & RandomAccessCollection, Element.Element: Equatable {
    func shuffled() -> RandomGenerators.Shuffled<Self> {
        .init(self)
    }
}