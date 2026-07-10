import XCTest
import SwiftRandomKit

final class BernoulliTests: XCTestCase {

    func testZeroProbabilityIsAlwaysFalse() {
        var rng = LCRNG(seed: 1)
        let coin = RandomGenerators.Bernoulli(probability: 0)

        for _ in 0..<100 {
            XCTAssertFalse(coin.run(using: &rng))
        }
    }

    func testFullProbabilityIsAlwaysTrue() {
        var rng = LCRNG(seed: 1)
        let coin = RandomGenerators.Bernoulli(probability: 1)

        for _ in 0..<100 {
            XCTAssertTrue(coin.run(using: &rng))
        }
    }

    func testBiasIsRoughlyRespected() {
        var rng = LCRNG(seed: 42)
        let coin: some RandomGenerator<Bool> = .bool(probability: 0.7)

        var trues = 0
        for _ in 0..<1000 {
            if coin.run(using: &rng) { trues += 1 }
        }

        // Loose statistical band around 700/1000
        XCTAssertGreaterThan(trues, 620)
        XCTAssertLessThan(trues, 780)
    }

    func testDeterministicWithSameSeed() {
        var rng1 = LCRNG(seed: 7)
        var rng2 = LCRNG(seed: 7)
        let coin = RandomGenerators.Bernoulli(probability: 0.5)

        for _ in 0..<20 {
            XCTAssertEqual(coin.run(using: &rng1), coin.run(using: &rng2))
        }
    }
}
