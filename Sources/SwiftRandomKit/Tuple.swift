extension RandomGenerators {
    public struct Tuple<Upstream: RandomGenerator>: RandomGenerator {
        let upstream: Upstream

        public init(_ upstream: Upstream) {
            self.upstream = upstream
        }

        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> (Upstream.Element, Upstream.Element) {
            (upstream.run(using: &rng), upstream.run(using: &rng))
        }
    }
}

extension RandomGenerator {
    public func tuple() -> RandomGenerators.Tuple<Self> {
        .init(self)
    }
}
