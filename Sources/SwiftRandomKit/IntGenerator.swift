public struct IntGenerator<Element>: RandomGenerator where Element: FixedWidthInteger {
    public let closedRange: ClosedRange<Element>

    public init(in closedRange: ClosedRange<Element>) {
        self.closedRange = closedRange
    }

    public init(in openRange: Range<Element>) {
        self.init(in: openRange.toClosedRange())
    }

    @inlinable
    public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Element {
        Element.random(in: closedRange, using: &rng)
    }
}

extension RandomGenerator where Element: FixedWidthInteger {
    @inlinable
    public static func int(in closedRange: ClosedRange<Element>) -> IntGenerator<Element> {
        .init(in: closedRange)
    }
}

extension Range where Bound: Comparable & Strideable {
    func toClosedRange() -> ClosedRange<Bound> {
        self.lowerBound...self.upperBound.advanced(by: -1)
    }
}
