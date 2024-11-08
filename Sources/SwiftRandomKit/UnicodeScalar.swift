extension RandomGenerators {
    public struct UnicodeScalar<Upstream: RandomGenerator>: RandomGenerator where Upstream.Element == Swift.UnicodeScalar  {
        public typealias Element = Swift.UnicodeScalar

        let generator: Upstream
        let closedRange: ClosedRange<Swift.UnicodeScalar>

        public init(_ generator: Upstream, in range: ClosedRange<Swift.UnicodeScalar>) {
            self.generator = generator
            self.closedRange = range
        }

        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Swift.UnicodeScalar {
            IntGenerator<UInt32>(in: closedRange.lowerBound.value...closedRange.upperBound.value)
                .map { Swift.UnicodeScalar($0)! }
                .run(using: &rng)
        }
    }
}

public extension RandomGenerator where Element == Swift.UnicodeScalar {
    func unicodeScalar(in range: ClosedRange<Swift.UnicodeScalar>) -> RandomGenerators.UnicodeScalar<Self> {
        .init(self, in: range)
    }
}
