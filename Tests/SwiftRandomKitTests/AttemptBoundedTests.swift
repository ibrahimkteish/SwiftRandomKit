import XCTest
import SwiftRandomKit

final class AttemptBoundedTests: XCTestCase {

    /// A generator that counts how many times it runs.
    private func countingGenerator(_ counter: LockIsolated<Int>) -> AnyRandomGenerator<Int> {
        AnyRandomGenerator<Int> { rng in
            counter.withValue { $0 += 1 }
            return Int.random(in: 1...6, using: &rng)
        }
    }

    func testMaxAttemptsBoundsTotalRuns() {
        let counter = LockIsolated(0)
        let bounded = countingGenerator(counter).attemptBounded(
            maxAttempts: 3,
            condition: { _ in false },
            fallbackStrategy: .useDefault(0)
        )

        var rng = LCRNG(seed: 1)
        let result = bounded.run(using: &rng)

        XCTAssertEqual(result, 0, "Fallback default should be used when no value satisfies")
        XCTAssertEqual(counter.value, 3, "maxAttempts is the total number of upstream runs, including the first")
    }

    func testStopsAtFirstSatisfyingValue() {
        let counter = LockIsolated(0)
        let bounded = countingGenerator(counter).attemptBounded(
            maxAttempts: 100,
            condition: { _ in true }
        )

        var rng = LCRNG(seed: 1)
        _ = bounded.run(using: &rng)

        XCTAssertEqual(counter.value, 1, "A satisfying first value should stop immediately")
    }

    func testUseLastReturnsLastGeneratedValue() {
        var rng1 = LCRNG(seed: 42)
        var rng2 = LCRNG(seed: 42)

        let upstream = IntGenerator(in: 1...6)
        let bounded = upstream.attemptBounded(
            maxAttempts: 4,
            condition: { _ in false },
            fallbackStrategy: .useLast
        )

        // Replaying the same seed, the bounded generator's result must equal
        // the fourth draw of the raw upstream.
        let expected = (0..<4).map { _ in upstream.run(using: &rng1) }.last
        XCTAssertEqual(bounded.run(using: &rng2), expected)
    }

    func testUseAnotherGeneratorFallback() {
        var rng = LCRNG(seed: 1)
        let bounded = IntGenerator(in: 1...6).attemptBounded(
            maxAttempts: 2,
            condition: { $0 > 6 },
            fallbackStrategy: .useAnotherGenerator { 99 }
        )

        XCTAssertEqual(bounded.run(using: &rng), 99)
    }
}
