import XCTest
import SwiftRandomKit

final class OneOfTests: XCTestCase {

    func testPicksFromAllSources() {
        var rng = LCRNG(seed: 1)
        // Three disjoint sources of different concrete types
        let mixed = RandomGenerators.oneOf(
            IntGenerator(in: 1...5),
            Always(50),
            IntGenerator(in: 100...105)
        )

        var sawLow = false, sawConstant = false, sawHigh = false
        for _ in 0..<300 {
            let value = mixed.run(using: &rng)
            switch value {
            case 1...5: sawLow = true
            case 50: sawConstant = true
            case 100...105: sawHigh = true
            default: XCTFail("Value \(value) outside all sources")
            }
        }

        XCTAssertTrue(sawLow, "Should select the first generator")
        XCTAssertTrue(sawConstant, "Should select the second generator")
        XCTAssertTrue(sawHigh, "Should select the third generator")
    }

    func testSelectionIsRoughlyUniform() {
        var rng = LCRNG(seed: 42)
        let mixed = RandomGenerators.oneOf(Always(1), Always(2), Always(3))

        var counts = [1: 0, 2: 0, 3: 0]
        for _ in 0..<900 {
            counts[mixed.run(using: &rng), default: 0] += 1
        }

        for (source, count) in counts {
            XCTAssertGreaterThan(count, 220, "Source \(source) should be picked ~1/3 of the time")
            XCTAssertLessThan(count, 380, "Source \(source) should be picked ~1/3 of the time")
        }
    }

    func testTwoAndFourArities() {
        var rng = LCRNG(seed: 7)

        let pair = RandomGenerators.oneOf(Always("a"), Always("b"))
        var seenPair = Set<String>()
        for _ in 0..<50 { seenPair.insert(pair.run(using: &rng)) }
        XCTAssertEqual(seenPair, ["a", "b"])

        let quad = RandomGenerators.oneOf(Always(1), Always(2), Always(3), Always(4))
        var seenQuad = Set<Int>()
        for _ in 0..<100 { seenQuad.insert(quad.run(using: &rng)) }
        XCTAssertEqual(seenQuad, [1, 2, 3, 4])
    }

    func testDeterministicWithSameSeed() {
        var rng1 = LCRNG(seed: 42)
        var rng2 = LCRNG(seed: 42)
        let mixed = RandomGenerators.oneOf(IntGenerator(in: 1...6), IntGenerator(in: 10...60))

        for _ in 0..<20 {
            XCTAssertEqual(mixed.run(using: &rng1), mixed.run(using: &rng2))
        }
    }
}
