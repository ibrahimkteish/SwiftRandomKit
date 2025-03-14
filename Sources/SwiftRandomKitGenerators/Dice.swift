import SwiftRandomKit

public struct Dice: RandomGenerator {
    public typealias Element = Int
    public init() {}
    public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Int {
        return IntGenerator(in: 1...6).run(using: &rng)
    }
}

extension Dice: Equatable {
    public func roll(using rng: inout some RandomNumberGenerator) -> Int { self.run(using: &rng) }
}
