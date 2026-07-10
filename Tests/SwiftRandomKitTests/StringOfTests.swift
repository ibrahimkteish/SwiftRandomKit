import XCTest
import SwiftRandomKit

final class StringOfTests: XCTestCase {

    func testMatchesArrayMapEquivalent() {
        // string(count:) must consume the RNG identically to .array(n).map(String.init)
        var rng1 = LCRNG(seed: 42)
        var rng2 = LCRNG(seed: 42)

        let viaString = RandomGenerators.letterOrNumber.string(count: 8).run(using: &rng1)
        let viaArray = String(RandomGenerators.letterOrNumber.array(8).run(using: &rng2))

        XCTAssertEqual(viaString, viaArray)
        XCTAssertEqual(viaString.count, 8)
    }

    func testKnownSequence() {
        // With seed 42, letterOrNumber produces G, 9, K first
        var rng = LCRNG(seed: 42)
        let code = RandomGenerators.string(of: RandomGenerators.letterOrNumber, count: 3)

        XCTAssertEqual(code.run(using: &rng), "G9K")
    }

    func testCharacterMembership() {
        var rng = LCRNG(seed: 7)
        let pin = RandomGenerators.number.string(count: 6)

        for _ in 0..<20 {
            let value = pin.run(using: &rng)
            XCTAssertEqual(value.count, 6)
            XCTAssertTrue(value.allSatisfy { ("0"..."9").contains($0) }, "PIN should be all digits: \(value)")
        }
    }

    func testZeroCountProducesEmptyString() {
        var rng = LCRNG(seed: 1)
        XCTAssertEqual(RandomGenerators.letter.string(count: 0).run(using: &rng), "")
    }
}
