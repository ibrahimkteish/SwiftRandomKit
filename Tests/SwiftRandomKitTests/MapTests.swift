import Testing
import SwiftRandomKit

@Suite("Map Transformation Tests")
struct MapTests {
    @Test("Map can transform integer values")
    func testMap() {
        let intGenerator = IntGenerator<Int>(in: 0...10)
        let mapped = intGenerator.map { $0 * 2 }
        var rng = LCRNG(seed: 1)

        #expect(mapped.run(using: &rng) == 2)
        #expect(mapped.run(using: &rng) == 14)
    }

    @Test("Map can transform integers to strings")
    func testMapString() {
        let intGenerator = IntGenerator<Int>(in: 0...10)
        let mapped = intGenerator.map { String($0) }
        var rng = LCRNG(seed: 1)

        #expect(mapped.run(using: &rng) == "1")
        #expect(mapped.run(using: &rng) == "7")
    }
}
