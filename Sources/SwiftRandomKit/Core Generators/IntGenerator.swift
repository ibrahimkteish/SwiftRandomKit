/// A generator that produces random integer values within a specified range.
///
/// The `IntGenerator` creates random integer values within a specified range.
/// It works with any type that conforms to `FixedWidthInteger`, such as:
/// `Int`, `UInt`, `Int8`, `UInt64`, etc.
///
/// Example usage:
/// ```swift
/// // Generate random integers between 1 and 100
/// let diceGen = IntGenerator(in: 1...100)
/// let randomInt = diceGen.run() // e.g., 42
///
/// // Generate random UInt8 values
/// let byteGen = IntGenerator<UInt8>(in: 0...255)
/// let randomByte = byteGen.run() // e.g., 173
///
/// // Use with an open range
/// let openRangeGen = IntGenerator(in: 0..<10) // Equivalent to 0...9
/// ```
public struct IntGenerator<Element>: RandomGenerator where Element: FixedWidthInteger {
    /// The closed range from which random values will be generated.
    public let closedRange: ClosedRange<Element>

    /// Creates a generator that produces random integers within the specified closed range.
    ///
    /// A closed range includes both its lower and upper bounds, so `1...6` can generate
    /// the values 1, 2, 3, 4, 5, and 6.
    ///
    /// - Parameter closedRange: The range of possible values to generate (inclusive).
    public init(in closedRange: ClosedRange<Element>) {
        self.closedRange = closedRange
    }

    /// Creates a generator that produces random integers within the specified half-open range.
    ///
    /// A half-open range includes its lower bound but not its upper bound, so `1..<7`
    /// can generate the values 1, 2, 3, 4, 5, and 6 (but not 7).
    ///
    /// - Parameter openRange: The half-open range of possible values to generate.
    public init(in openRange: Range<Element>) {
        self.init(in: openRange.toClosedRange())
    }

    /// Generates a random integer value within the specified range.
    ///
    /// - Parameter rng: The random number generator to use.
    /// - Returns: A random integer value within the specified range.
    @inlinable
    public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Element {
        Element.random(in: closedRange, using: &rng)
    }
}

/// Extension to convert a half-open range to a closed range.
extension Range where Bound: Comparable & Strideable {
    /// Converts a half-open range (like `0..<10`) to a closed range (like `0...9`).
    ///
    /// This is an internal utility function used by the `IntGenerator` initializer
    /// that takes a half-open range.
    ///
    /// - Returns: A closed range equivalent to this half-open range.
    func toClosedRange() -> ClosedRange<Bound> {
        self.lowerBound...self.upperBound.advanced(by: -1)
    }
}
