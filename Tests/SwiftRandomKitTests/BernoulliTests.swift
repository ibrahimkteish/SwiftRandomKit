import Testing
import SwiftRandomKit

struct BernoulliTests {

    @Test func zeroProbabilityIsAlwaysFalse() {
        var rng = LCRNG(seed: 1)
        let coin = RandomGenerators.Bernoulli(probability: 0)

        for _ in 0..<100 {
            #expect(!(coin.run(using: &rng)))
        }
    }

    @Test func fullProbabilityIsAlwaysTrue() {
        var rng = LCRNG(seed: 1)
        let coin = RandomGenerators.Bernoulli(probability: 1)

        for _ in 0..<100 {
            #expect(coin.run(using: &rng))
        }
    }

    @Test func biasIsRoughlyRespected() {
        var rng = LCRNG(seed: 42)
        let coin: some RandomGenerator<Bool> = .bool(probability: 0.7)

        var trues = 0
        for _ in 0..<1000 {
            if coin.run(using: &rng) { trues += 1 }
        }

        // Loose statistical band around 700/1000
        #expect(trues > 620)
        #expect(trues < 780)
    }

    @Test func deterministicWithSameSeed() {
        var rng1 = LCRNG(seed: 7)
        var rng2 = LCRNG(seed: 7)
        let coin = RandomGenerators.Bernoulli(probability: 0.5)

        for _ in 0..<20 {
            #expect(coin.run(using: &rng1) == coin.run(using: &rng2))
        }
    }
}
