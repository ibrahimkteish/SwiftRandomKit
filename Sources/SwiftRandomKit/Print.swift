extension RandomGenerators {
    public struct Print<Upstream: RandomGenerator>: RandomGenerator {
        public typealias Element = Upstream.Element

        let generator: Upstream
        let prefix: String

        public init(_ generator: Upstream, prefix: String) {
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
    @inlinable
    public func print(_ prefix: String) -> RandomGenerators.Print<Self> {
        .init(self, prefix: prefix)
    }
}
