extension RandomGenerators {
    /// A generator that transforms the output of another generator with a given closure.
    ///
    /// You will not typically need to interact with this type directly. Instead you will usually use
    /// the ``map(_:)`` operation, which constructs this type.
    public struct Map<Upstream: RandomGenerator, NewOutput>: RandomGenerator {
        /// The generator from which this generator receives its output.
        public let upstream: Upstream
        /// The transformation to apply to the upstream's output.
        public let transform: (Upstream.Element) -> NewOutput

        @inlinable
        public init(_ upstream: Upstream, _ transform: @escaping (Upstream.Element) -> NewOutput) {
            self.upstream = upstream
            self.transform = transform
        }

        @inlinable
        @inline(__always)
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
