extension RandomGenerators {
    public struct Print<G: RandomGenerator>: RandomGenerator {
        public typealias Element = G.Element

        let generator: G
        let prefix: String

        public init(_ generator: G, prefix: String) {
            self.generator = generator
            self.prefix = prefix
        }

        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Element {
            let value = generator.run(using: &rng)
            Swift.print("\(prefix): \(value)")
            return value
        }
    }
}

extension RandomGenerator {
    public func print(_ prefix: String) -> RandomGenerators.Print<Self> {
        .init(self, prefix: prefix)
    }
}
