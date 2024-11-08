extension RandomGenerators {
    public struct Set<Upstream: RandomGenerator, S: SetAlgebra, Count: RandomGenerator<Int>>: RandomGenerator where S.Element == Upstream.Element {
        public typealias Element = S

        let generator: Upstream
        let countGenerator: Count

        public init(_ generator: Upstream, count: Count) {
            self.generator = generator
            self.countGenerator = count
        }

        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> S {
            let count = countGenerator.run(using: &rng)
            guard count > 0 else { return .init() }
            var set: S = .init()
            (0..<count).forEach { _ in set.insert(generator.run(using: &rng)) }
            return set
        }
    }
}

extension RandomGenerator where Element: SetAlgebra {
    public func set<C: RandomGenerator<Int>>(count: C) -> RandomGenerators.Set<Self, Element, C> {
        .init(self, count: count)
    }
}