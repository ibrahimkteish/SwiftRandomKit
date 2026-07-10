public struct BoolRandomGenerator: RandomGenerator {
    public typealias Element = Bool

    public init() {}

    public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Bool {
        return Bool.random(using: &rng)
    }
}

/// The 2.0 name for this generator, available now for forward-compatible code.
public typealias BoolGenerator = BoolRandomGenerator
