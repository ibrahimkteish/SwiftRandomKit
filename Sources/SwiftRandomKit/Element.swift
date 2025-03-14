extension RandomGenerators {
    public struct Element<Upstream: RandomGenerator>: RandomGenerator where Upstream.Element: Swift.Collection {
        public typealias Element = Upstream.Element.Element?
        public let upstream: Upstream

        @inlinable
        public init(_ upstream: Upstream) {
            self.upstream = upstream
        }

        @inlinable
        @inline(__always)
        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Upstream.Element.Element? {
            upstream.run(using: &rng).randomElement(using: &rng)
        }
    }
}

extension RandomGenerator where Element: Swift.Collection {
    @inlinable
    public func element() -> RandomGenerators.Element<Self> {
        .init(self)
    }
}
