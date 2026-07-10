import Testing
import SwiftRandomKit

struct StringOfTests {

    @Test func matchesArrayMapEquivalent() {
        // string(count:) must consume the RNG identically to .array(n).map(String.init)
        var rng1 = LCRNG(seed: 42)
        var rng2 = LCRNG(seed: 42)

        let viaString = RandomGenerators.letterOrNumber.string(count: 8).run(using: &rng1)
        let viaArray = String(RandomGenerators.letterOrNumber.array(8).run(using: &rng2))

        #expect(viaString == viaArray)
        #expect(viaString.count == 8)
    }

    @Test func knownSequence() {
        // With seed 42, letterOrNumber produces G, 9, K first
        var rng = LCRNG(seed: 42)
        let code = RandomGenerators.string(of: RandomGenerators.letterOrNumber, count: 3)

        #expect(code.run(using: &rng) == "G9K")
    }

    @Test func characterMembership() {
        var rng = LCRNG(seed: 7)
        let pin = RandomGenerators.number.string(count: 6)

        for _ in 0..<20 {
            let value = pin.run(using: &rng)
            #expect(value.count == 6)
            #expect(value.allSatisfy { ("0"..."9").contains($0) }, "PIN should be all digits: \(value)")
        }
    }

    @Test func zeroCountProducesEmptyString() {
        var rng = LCRNG(seed: 1)
        #expect(RandomGenerators.letter.string(count: 0).run(using: &rng) == "")
    }
}
