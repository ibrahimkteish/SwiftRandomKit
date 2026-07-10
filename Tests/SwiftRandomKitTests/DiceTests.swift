import XCTest
import SwiftRandomKit
import SwiftRandomKitGenerators

final class DiceTests: XCTestCase {

    func testDefaultDieIsSixSided() {
        XCTAssertEqual(Dice(), Dice.d6)

        var rng = LCRNG(seed: 1)
        for _ in 0..<100 {
            let roll = Dice().run(using: &rng)
            XCTAssertTrue((1...6).contains(roll))
        }
    }

    func testPresetsCoverTheirRange() {
        var rng = LCRNG(seed: 42)
        let dice: [(Dice, ClosedRange<Int>)] = [
            (.d4, 1...4), (.d6, 1...6), (.d8, 1...8),
            (.d10, 1...10), (.d12, 1...12), (.d20, 1...20), (.d100, 1...100)
        ]

        for (die, range) in dice {
            for _ in 0..<50 {
                XCTAssertTrue(range.contains(die.run(using: &rng)), "\(die.sides)-sided die out of range")
            }
        }
    }

    func testRollMatchesRun() {
        var rng1 = LCRNG(seed: 7)
        var rng2 = LCRNG(seed: 7)

        XCTAssertEqual(Dice.d20.roll(using: &rng1), Dice.d20.run(using: &rng2))
    }
}
