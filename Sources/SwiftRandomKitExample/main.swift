import Foundation
import SwiftRandomKit
import SwiftRandomKitGenerators

// A seeded RNG makes every run of this example reproducible.
var rng = LCRNG(seed: 2024)

// MARK: - Core generators

let dice = IntGenerator(in: 1...6)
print("Dice roll:", dice.run(using: &rng))

let probability: some RandomGenerator<Double> = .float(in: 0...1)
print("Probability:", probability.run(using: &rng))

let coin: some RandomGenerator<Bool> = .bool
print("Coin flip:", coin.run(using: &rng))

// MARK: - Transforming and combining

let doubled = dice.map { $0 * 2 }
print("Doubled roll:", doubled.run(using: &rng))

let fiveRolls = dice.array(5)
print("Five rolls:", fiveRolls.run(using: &rng))

let weighted = RandomGenerators.frequency([
    (3, IntGenerator(in: 1...3)),   // 75% low
    (1, IntGenerator(in: 4...6))    // 25% high
])
print("Weighted roll:", weighted.run(using: &rng))

let maybeBonus = IntGenerator(in: 1...100).orNil(probability: 0.5)
print("Bonus (sometimes nil):", maybeBonus.run(using: &rng) as Any)

let evenOnly = IntGenerator(in: 1...100).filter { $0.isMultiple(of: 2) }
print("Even number:", evenOnly.run(using: &rng))

if #available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *) {
    let game = dice.zip(coin)
    print("Dice + coin:", game.run(using: &rng))

    let labeled = RandomGenerators.Zip(dice, coin, RandomGenerators.letter)
        .map { roll, flip, letter in "\(roll)-\(flip)-\(letter)" }
    print("Zip of three:", labeled.run(using: &rng))
}

// MARK: - Characters and strings

let code = RandomGenerators.letterOrNumber.array(8)
    .map { String($0) }
print("Alphanumeric code:", code.run(using: &rng))

// MARK: - Ready-made generators

print("Safari-style password:", SafariPasswordGenerator().run(using: &rng))
print("UUID:", UUIDGenerator().run(using: &rng))
print("IPv4:", IPAddressGenerator(version: .v4).run(using: &rng))
print("Version:", VersionNumberGenerator(includePrerelease: true).run(using: &rng))
print("Visa number:", CreditCardGenerator(type: .visa).run(using: &rng))
print("d20:", Dice.d20.roll(using: &rng))

let puzzle = RandomGenerators.sudoku(difficulty: .easy).run(using: &rng)
print("Sudoku (easy):")
for row in puzzle {
    print(row.map { $0 == 0 ? "." : "\($0)" }.joined(separator: " "))
}
