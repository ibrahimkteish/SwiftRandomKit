extension RandomGenerators {
    public struct Shuffled<G: RandomGenerator>: RandomGenerator where G.Element: Swift.Collection, G.Element: MutableCollection, G.Element: RandomAccessCollection, G.Element.Element: Equatable {
        public typealias Element = G.Element
        let generator: G

        public init(_ generator: G) {
            self.generator = generator
        }

        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> G.Element {
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