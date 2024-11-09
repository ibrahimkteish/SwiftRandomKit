extension RandomGenerators {
    public struct Frequency<Upstream: RandomGenerator>: RandomGenerator {
        public typealias Element = Upstream.Element
        let distribution: [(Int, Upstream)]
        
        public init(_ distribution: [(Int, Upstream)]) {
            self.distribution = distribution
        }

        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Upstream.Element {
            let generators = distribution.flatMap { (freq, gen) in 
                [Upstream](repeating: gen, count: freq)
            }
            return IntGenerator(in: 0..<generators.count)
                .flatMap { idx in generators[idx] }
                .run(using: &rng)
        }
    }
}

public extension RandomGenerator {
    func frequency(_ distribution: [(Int, Self)]) -> RandomGenerators.Frequency<Self> {
        .init(distribution)
    }
}