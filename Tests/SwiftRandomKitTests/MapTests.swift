import XCTest
import SwiftRandomKit

final class MapTests: XCTestCase {
    func testMap() {
        let intGenerator = IntGenerator<Int>(in: 0...10)
        let mapped = intGenerator.map { $0 * 2 }
        var rng = LCRNG(seed: 1)

        XCTAssertEqual(mapped.run(using: &rng), 2)
        XCTAssertEqual(mapped.run(using: &rng), 14)
    }

     func testMapString() {
        let intGenerator = IntGenerator<Int>(in: 0...10)
        let mapped = intGenerator.map { String($0) }
        var rng = LCRNG(seed: 1)

        XCTAssertEqual(mapped.run(using: &rng), "1")
        XCTAssertEqual(mapped.run(using: &rng), "7")
    }
}
