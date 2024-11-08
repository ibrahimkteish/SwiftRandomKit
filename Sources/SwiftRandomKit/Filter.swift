extension RandomGenerators {
    public struct Filter<G: RandomGenerator>: RandomGenerator {

        public typealias Element = G.Element?
        let generator: G
        let predicate: (G.Element) -> Bool

        public init(_ generator: G, _ predicate: @escaping (G.Element) -> Bool) {
            self.generator = generator
            self.predicate = predicate
        }

        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> G.Element? {
            let value = generator.run(using: &rng)
            return predicate(value) ? value : nil
        }
    }
}

public extension RandomGenerator {
    func filter(_ predicate: @escaping (Element) -> Bool) -> RandomGenerators.Filter<Self> {
        .init(self, predicate)
    }
}
