extension RandomGenerators {
    public struct Map<Upstream: RandomGenerator, NewOutput>: RandomGenerator {
        public let upstream: Upstream
        public let transform: (Upstream.Element) -> NewOutput

        public init(_ upstream: Upstream, _ transform: @escaping (Upstream.Element) -> NewOutput) {
            self.upstream = upstream
            self.transform = transform
        }

        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> NewOutput {
            transform(upstream.run(using: &rng))
        }
    }
}

extension RandomGenerator {
    @inlinable
    public func map<NewOutput>(_ transform: @escaping (Element) -> NewOutput) -> RandomGenerators.Map<Self, NewOutput> {
        .init(self, transform)
    }
}

extension RandomGenerators.Map {
  @inlinable
  public func map<New>(_ transform: @escaping (Element) -> New) -> RandomGenerators.Map<Upstream, New> {
      .init(self.upstream) { element in
          transform(self.transform(element))
      }
    }
}
