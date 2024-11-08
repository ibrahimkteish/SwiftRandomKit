extension RandomGenerators {
    public struct Frequency<G: RandomGenerator>: RandomGenerator {
        public typealias Element = G.Element
        let distribution: [(Int, G)]
        
        public init(_ distribution: [(Int, G)]) {
            self.distribution = distribution
        }

        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> G.Element {
            let generators = distribution.flatMap { (freq, gen) in 
                [G](repeating: gen, count: freq)
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