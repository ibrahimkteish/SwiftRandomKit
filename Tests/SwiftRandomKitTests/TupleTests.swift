import Testing
import SwiftRandomKit

struct TupleTests {
    @Test func tuple() {
        let intGenerator = IntGenerator<Int>(in: 0...10)
        let tuple = intGenerator.tuple()
        var rng = LCRNG(seed: 1)
        
        let result = tuple.run(using: &rng)
        #expect(result.0 == 1)
        #expect(result.1 == 7)
    }
}
