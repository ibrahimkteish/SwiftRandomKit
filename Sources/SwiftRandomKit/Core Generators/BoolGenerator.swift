/// A generator that produces random boolean values.
///
/// Example usage:
/// ```swift
/// let coinFlip = BoolGenerator()
/// let heads = coinFlip.run() // true or false
/// ```
public struct BoolGenerator: RandomGenerator {
    public typealias Element = Bool

    public init() {}

    public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Bool {
        return Bool.random(using: &rng)
    }
}

@available(*, deprecated, renamed: "BoolGenerator")
public typealias BoolRandomGenerator = BoolGenerator

extension RandomGenerator where Self == BoolGenerator {
    /// A generator of random booleans, for dot-syntax usage:
    /// `let flip: some RandomGenerator<Bool> = .bool`
    public static var bool: BoolGenerator { BoolGenerator() }
}

extension BoolGenerator: Sendable {}
