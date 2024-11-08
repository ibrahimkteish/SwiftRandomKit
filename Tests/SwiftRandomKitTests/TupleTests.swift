import XCTest
import SwiftRandomKit

final class TupleTests: XCTestCase {
    func testTuple() {
        let intGenerator = RandomGenerators.IntGenerator<Int>(range: 0...10)
        let tuple = intGenerator.tuple()
        var rng = LCRNG(seed: 1)
        let result = tuple.run(using: &rng)
        XCTAssertEqual(result.0, 1)
        XCTAssertEqual(result.1, 7)
    }
}
