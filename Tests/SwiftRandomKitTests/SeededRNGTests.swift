import Testing
import SwiftRandomKit

struct SeededRNGTests {

    @Test func splitMix64KnownVector() {
        // Reference output for seed 0 from the SplitMix64 reference implementation
        var rng = SplitMix64(seed: 0)
        #expect(rng.next() == 0xE220A8397B1DCDAF)
        #expect(rng.next() == 0x6E789E6AA1B965F4)
        #expect(rng.next() == 0x06C45D188009454F)
    }

    @Test func determinismAndSeedSensitivity() {
        func sequence<R: RandomNumberGenerator>(_ make: () -> R) -> [UInt64] {
            var rng = make()
            return (0..<10).map { _ in rng.next() }
        }

        #expect(sequence { SplitMix64(seed: 42) } == sequence { SplitMix64(seed: 42) })
        #expect(sequence { Xoshiro256(seed: 42) } == sequence { Xoshiro256(seed: 42) })
        #expect(sequence { PCG(seed: 42) } == sequence { PCG(seed: 42) })

        #expect(sequence { SplitMix64(seed: 1) } != sequence { SplitMix64(seed: 2) })
        #expect(sequence { Xoshiro256(seed: 1) } != sequence { Xoshiro256(seed: 2) })
        #expect(sequence { PCG(seed: 1) } != sequence { PCG(seed: 2) })
    }

    @Test func PCGStreamsAreIndependent() {
        var stream1 = PCG(seed: 42, sequence: 1)
        var stream2 = PCG(seed: 42, sequence: 2)

        let a = (0..<10).map { _ in stream1.next() }
        let b = (0..<10).map { _ in stream2.next() }

        #expect(a != b, "Same seed, different sequences must yield different streams")
    }

    @Test func generatorsWorkWithRandomGeneratorPipeline() {
        // Each RNG drives the library's generators and covers a small range fully
        func coverage<R: RandomNumberGenerator>(_ rng: inout R) -> Set<Int> {
            let die = IntGenerator(in: 1...6)
            var seen = Set<Int>()
            for _ in 0..<200 {
                seen.insert(die.run(using: &rng))
            }
            return seen
        }

        var xoshiro = Xoshiro256(seed: 7)
        var pcg = PCG(seed: 7)
        var splitmix = SplitMix64(seed: 7)

        #expect(coverage(&xoshiro) == [1, 2, 3, 4, 5, 6])
        #expect(coverage(&pcg) == [1, 2, 3, 4, 5, 6])
        #expect(coverage(&splitmix) == [1, 2, 3, 4, 5, 6])
    }
}
