public struct BoolRandomGenerator: RandomGenerator {
    public typealias Element = Bool

    public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Bool {
        return Bool.random(using: &rng)
    }
}
