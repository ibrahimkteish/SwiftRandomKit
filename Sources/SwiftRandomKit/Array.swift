extension RandomGenerators {
    public struct Array<Upstream: RandomGenerator>: RandomGenerator {
        public let upstream: Upstream
        public let count: Int

        public init(_ upstream: Upstream, _ count: Int) {
            self.upstream = upstream
            self.count = count
        }

@inlinable
        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> [Upstream.Element] {
            (0..<count).map { _ in upstream.run(using: &rng) }
        }
    }
}

extension RandomGenerator {
    @inlinable
    public func array(_ count: Int) -> RandomGenerators.Array<Self> {
        .init(self, count)
    }
}

extension RandomGenerators {
    public struct ArrayGenerator<Upstream: RandomGenerator, C: RandomGenerator>: RandomGenerator where C.Element == Int {
        let upstream: Upstream
        let countGenerator: C

        public init(_ upstream: Upstream, _ countGenerator: C) {
            self.upstream = upstream
            self.countGenerator = countGenerator
        }

        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> [Upstream.Element] {
            let size = countGenerator.run(using: &rng)
            guard size > 0 else { return [] }
            var array: [Upstream.Element] = .init()
            array.reserveCapacity(size)
            (0..<size).forEach { _ in array.append(upstream.run(using: &rng)) }
            return array
        }
    }
}

extension RandomGenerator {
    public func arrayGenerator<C: RandomGenerator>(_ countGenerator: C) -> RandomGenerators.ArrayGenerator<Self, C> {
        .init(self, countGenerator)
    }
}
