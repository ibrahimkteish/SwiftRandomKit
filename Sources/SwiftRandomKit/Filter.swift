extension RandomGenerators {
    public struct Filter<Upstream: RandomGenerator>: RandomGenerator {

        public typealias Element = Upstream.Element?
        let generator: Upstream
        let predicate: (Upstream.Element) -> Bool

        public init(_ generator: Upstream, _ predicate: @escaping (Upstream.Element) -> Bool) {
            self.generator = generator
            self.predicate = predicate
        }

        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Upstream.Element? {
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
