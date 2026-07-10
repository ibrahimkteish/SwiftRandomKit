import XCTest
import SwiftRandomKit

final class AnyRandomGeneratorTests: XCTestCase {

    func testErasedGeneratorMatchesUnerasedSequence() {
        // An erased generator must produce the exact same sequence as the
        // generator it wraps when driven by the same seeded RNG.
        var plainRng = LCRNG(seed: 1)
        var erasedRng = LCRNG(seed: 1)

        let plain = IntGenerator(in: 1...100)
        let erased = IntGenerator(in: 1...100).eraseToAnyRandomGenerator()

        let plainValues = (0..<10).map { _ in plain.run(using: &plainRng) }
        let erasedValues = (0..<10).map { _ in erased.run(using: &erasedRng) }

        XCTAssertEqual(plainValues, erasedValues, "Type erasure should not change the generated sequence")
    }

    func testErasedGeneratorAdvancesRngState() {
        // Regression test: run(using:) used to box the RNG and never write the
        // advanced state back, so every call replayed the same seed.
        var rng = LCRNG(seed: 1)
        let erased = IntGenerator(in: 1...1_000_000).eraseToAnyRandomGenerator()

        let values = (0..<10).map { _ in erased.run(using: &rng) }

        XCTAssertGreaterThan(Set(values).count, 1, "Consecutive runs should advance the RNG, not replay the same value")
    }

    func testClosureInitializedGeneratorAdvancesRngState() {
        var rng = LCRNG(seed: 1)
        let custom = AnyRandomGenerator<Int> { rng in
            Int.random(in: 1...1_000_000, using: &rng)
        }

        let values = (0..<10).map { _ in custom.run(using: &rng) }

        XCTAssertGreaterThan(Set(values).count, 1, "Consecutive runs should advance the RNG, not replay the same value")
    }

    func testErasedCharacterPresetAdvancesRngState() {
        // The built-in character presets are erased internally, so they were
        // affected too: number.array(6) produced the same digit six times.
        var rng = LCRNG(seed: 1)
        let digits = RandomGenerators.number.array(20).run(using: &rng)

        XCTAssertGreaterThan(Set(digits).count, 1, "20 random digits should not all be identical")
    }

    func testDoubleErasureMatchesSingleErasure() {
        var singleRng = LCRNG(seed: 42)
        var doubleRng = LCRNG(seed: 42)

        let single = IntGenerator(in: 1...100).eraseToAnyRandomGenerator()
        let double = single.eraseToAnyRandomGenerator()

        let singleValues = (0..<5).map { _ in single.run(using: &singleRng) }
        let doubleValues = (0..<5).map { _ in double.run(using: &doubleRng) }

        XCTAssertEqual(singleValues, doubleValues)
    }
}
