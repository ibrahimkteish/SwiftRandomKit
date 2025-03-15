import Testing
import SwiftRandomKit

@Suite("Tuple Generator Tests")
struct TupleTests {
    @Test("Tuple generator creates tuples with expected values")
    func testTuple() {
        let intGenerator = IntGenerator<Int>(in: 0...10)
        let tuple = intGenerator.tuple()
        var rng = LCRNG(seed: 1)
        
        let result = tuple.run(using: &rng)
        #expect(result.0 == 1)
        #expect(result.1 == 7)
    }
}
