public struct FloatGenerator<Element>: RandomGenerator where Element: BinaryFloatingPoint, Element.RawSignificand: FixedWidthInteger {
    public let range: ClosedRange<Element>
    
    public init(in range: ClosedRange<Element>) {
        self.range = range
    }
    
    public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Element {
        .random(in: range, using: &rng)
    }
}

public extension RandomGenerator where Element: BinaryFloatingPoint, Element.RawSignificand: FixedWidthInteger {
    static func float(in range: ClosedRange<Element>) -> FloatGenerator<Element> {
        .init(in: range)
    }
}
