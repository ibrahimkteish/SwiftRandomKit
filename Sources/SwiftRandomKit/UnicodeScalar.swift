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
            // Generate random UInt32 values until we find a valid Unicode scalar
            var value: UInt32
            var scalar: Swift.UnicodeScalar?
            
            repeat {
                value = UInt32.random(in: closedRange.lowerBound.value...closedRange.upperBound.value, using: &rng)
                scalar = Swift.UnicodeScalar(value)
            } while scalar == nil
            
            // Force unwrap is safe here because we only exit the loop when scalar is non-nil
            return scalar!
        }
    }
}

public extension RandomGenerator where Element == Swift.UnicodeScalar {
    func unicodeScalar(in range: ClosedRange<Swift.UnicodeScalar>) -> RandomGenerators.UnicodeScalar<Self> {
        .init(self, in: range)
    }
}
