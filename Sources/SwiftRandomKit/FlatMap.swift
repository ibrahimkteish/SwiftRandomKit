
extension RandomGenerators {
    public struct FlatMap<Upstream: RandomGenerator, NewOutput: RandomGenerator>: RandomGenerator {
        let upstream: Upstream
        let transform: (Upstream.Element) -> NewOutput

        public init(_ upstream: Upstream, _ transform: @escaping (Upstream.Element) -> NewOutput) {
            self.upstream = upstream
            self.transform = transform
        }

        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> NewOutput.Element {
            transform(upstream.run(using: &rng)).run(using: &rng)
        }
    }
}

extension RandomGenerator {
    public func flatMap<NewOutput: RandomGenerator>(_ transform: @escaping (Element) -> NewOutput) -> RandomGenerators.FlatMap<Self, NewOutput> {
        .init(self, transform)
    }
}
