import Testing
import SwiftRandomKit
import SwiftRandomKitGenerators

struct DiceTests {

    @Test func defaultDieIsSixSided() {
        #expect(Dice() == Dice.d6)

        var rng = LCRNG(seed: 1)
        for _ in 0..<100 {
            let roll = Dice().run(using: &rng)
            #expect((1...6).contains(roll))
        }
    }

    @Test func presetsCoverTheirRange() {
        var rng = LCRNG(seed: 42)
        let dice: [(Dice, ClosedRange<Int>)] = [
            (.d4, 1...4), (.d6, 1...6), (.d8, 1...8),
            (.d10, 1...10), (.d12, 1...12), (.d20, 1...20), (.d100, 1...100)
        ]

        for (die, range) in dice {
            for _ in 0..<50 {
                #expect(range.contains(die.run(using: &rng)), "\(die.sides)-sided die out of range")
            }
        }
    }

    @Test func rollMatchesRun() {
        var rng1 = LCRNG(seed: 7)
        var rng2 = LCRNG(seed: 7)

        #expect(Dice.d20.roll(using: &rng1) == Dice.d20.run(using: &rng2))
    }
}
