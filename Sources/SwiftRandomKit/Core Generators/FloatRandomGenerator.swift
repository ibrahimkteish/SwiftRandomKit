/// A generator that produces random floating-point values within a specified range.
///
/// The `FloatGenerator` creates random floating-point values within a specified range.
/// It works with any type that conforms to `BinaryFloatingPoint` with an appropriate
/// `RawSignificand`, such as `Float`, `Double`, and `CGFloat`.
///
/// Example usage:
/// ```swift
/// // Generate random Double values between 0 and 1
/// let probabilityGen = FloatGenerator<Double>(in: 0...1)
/// let probability = probabilityGen.run() // e.g., 0.7283
///
/// // Generate random CGFloat values for UI elements
/// let widthGen = FloatGenerator<CGFloat>(in: 50...300)
/// let randomWidth = widthGen.run() // e.g., 173.5
///
/// // Use with Swift's built-in floating point types
/// let floatGen = FloatGenerator<Float>(in: -1...1)
/// let normalizedValue = floatGen.run() // e.g., -0.42
/// ```
public struct FloatGenerator<Element>: RandomGenerator where Element: BinaryFloatingPoint, Element.RawSignificand: FixedWidthInteger {
    /// The closed range from which random values will be generated.
    public let range: ClosedRange<Element>
    
    /// Creates a generator that produces random floating-point values within the specified range.
    ///
    /// - Parameter range: The range of possible values to generate (inclusive of both bounds).
    ///
    /// Example:
    /// ```swift
    /// // Generate random temperatures between freezing and boiling (in Celsius)
    /// let temperatureGen = FloatGenerator<Double>(in: 0...100)
    /// ```
    public init(in range: ClosedRange<Element>) {
        self.range = range
    }
    
    /// Generates a random floating-point value within the specified range.
    ///
    /// - Parameter rng: The random number generator to use.
    /// - Returns: A random floating-point value within the specified range.
    public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Element {
        .random(in: range, using: &rng)
    }
}