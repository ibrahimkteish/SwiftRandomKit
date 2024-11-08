extension RandomGenerators {
    public struct Collection<Upstream: RandomGenerator, C: RandomGenerator<Int>>: RandomGenerator where C: RangeReplaceableCollection, C.Element == Upstream.Element {
        let upstream: Upstream
        let countGenerator: C

        public init(_ upstream: Upstream, _ countGenerator: C) {
            self.upstream = upstream
            self.countGenerator = countGenerator
        }

        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> C {
            let count = countGenerator.run(using: &rng)
            guard count > 0 else { return C() }
            var collection: C = .init()
            collection.reserveCapacity(count)
            (0..<count).forEach { _ in collection.append(upstream.run(using: &rng)) }
            return collection
        }
    }
}

extension RandomGenerator {
    public func collection<C: RandomGenerator<Int>>(_ countGenerator: C) -> RandomGenerators.Collection<Self, C> {
        .init(self, countGenerator)
    }
}
