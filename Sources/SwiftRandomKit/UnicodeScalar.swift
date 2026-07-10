extension RandomGenerators {
    /// A generator that produces random Unicode scalars within a range.
    ///
    /// Surrogate code points (U+D800...U+DFFF) are not valid Unicode scalars; when the
    /// range spans them they are skipped and the remaining scalars are drawn uniformly,
    /// so the distribution is never biased toward a fallback value.
    ///
    /// Example usage:
    /// ```swift
    /// let uppercase = RandomGenerators.UnicodeScalar(in: "A"..."Z")
    /// let scalar = uppercase.run() // e.g., "Q"
    /// ```
    public struct UnicodeScalar: RandomGenerator {
        public typealias Element = Swift.UnicodeScalar

        /// The range of scalars to draw from.
        public let closedRange: ClosedRange<Swift.UnicodeScalar>

        /// Creates a generator that produces scalars within the given range.
        /// - Parameter range: The range of scalars to draw from.
        public init(in range: ClosedRange<Swift.UnicodeScalar>) {
            self.closedRange = range
        }

        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Swift.UnicodeScalar {
            let low = closedRange.lowerBound.value
            let high = closedRange.upperBound.value

            // Valid scalars exclude the surrogate code points U+D800...U+DFFF.
            // The range bounds are Unicode.Scalar values, so they are themselves
            // valid; only the interior of the range can overlap the gap.
            let gapLow: UInt32 = 0xD800
            let gapHigh: UInt32 = 0xDFFF
            let overlap: UInt32 = (high >= gapLow && low <= gapHigh)
                ? min(high, gapHigh) - max(low, gapLow) + 1
                : 0
            let validCount = (high - low + 1) - overlap

            let index = IntGenerator<UInt32>(in: 0...(validCount - 1)).run(using: &rng)
            let preGapCount = low < gapLow ? min(high, gapLow - 1) - low + 1 : 0
            let value: UInt32
            if overlap == 0 || index < preGapCount {
                value = low + index
            } else {
                value = gapHigh + 1 + (index - preGapCount)
            }
            // The index mapping skips the surrogate gap, so the value is always
            // a representable scalar.
            return Swift.UnicodeScalar(value)!
        }
    }
}
