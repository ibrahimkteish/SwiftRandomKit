import SwiftRandomKit

/// A generator that rolls a die with a configurable number of sides.
///
/// Example usage:
/// ```swift
/// let roll = Dice().run()          // 1...6
/// let d20 = Dice.d20.run()         // 1...20
/// let custom = Dice(sides: 3).run() // 1...3
/// ```
public struct Dice: RandomGenerator, Equatable {
    public typealias Element = Int

    /// The number of faces on the die.
    public let sides: Int

    /// Creates a die with the given number of sides.
    /// - Parameter sides: The number of faces. Defaults to 6.
    public init(sides: Int = 6) {
        precondition(sides >= 1, "A die needs at least one side, got \(sides)")
        self.sides = sides
    }

    public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Int {
        IntGenerator(in: 1...sides).run(using: &rng)
    }

    /// Rolls the die. Synonym for `run(using:)`.
    public func roll(using rng: inout some RandomNumberGenerator) -> Int {
        run(using: &rng)
    }
}

extension Dice {
    /// A four-sided die.
    public static let d4 = Dice(sides: 4)
    /// A six-sided die.
    public static let d6 = Dice(sides: 6)
    /// An eight-sided die.
    public static let d8 = Dice(sides: 8)
    /// A ten-sided die.
    public static let d10 = Dice(sides: 10)
    /// A twelve-sided die.
    public static let d12 = Dice(sides: 12)
    /// A twenty-sided die.
    public static let d20 = Dice(sides: 20)
    /// A hundred-sided die.
    public static let d100 = Dice(sides: 100)
}
