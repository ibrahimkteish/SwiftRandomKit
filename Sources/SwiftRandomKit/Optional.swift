extension RandomGenerators {
    public struct OptionalGenerator<R: RandomGenerator>: RandomGenerator {
        public typealias Element = Optional<R.Element>
        private let generator: R

        public init(_ generator: R) {
            self.generator = generator
        }

        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Element {
            generator.run(using: &rng)
        }
    }
}

extension RandomGenerator {
    @inline(__always)
    public func optional() -> RandomGenerators.OptionalGenerator<Self> {
        .init(self)
    }
}
