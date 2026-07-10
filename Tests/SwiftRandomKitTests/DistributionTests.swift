import Testing
import SwiftRandomKit

struct DistributionTests {

    @Test func standardNormalMoments() {
        var rng = LCRNG(seed: 42)
        let normal = RandomGenerators.Normal()

        let n = 5000
        var samples: [Double] = []
        samples.reserveCapacity(n)
        for _ in 0..<n {
            samples.append(normal.run(using: &rng))
        }

        let mean = samples.reduce(0, +) / Double(n)
        let variance = samples.reduce(0) { $0 + ($1 - mean) * ($1 - mean) } / Double(n)

        #expect(abs((mean) - (0)) <= 0.1)
        #expect(abs((variance.squareRoot()) - (1)) <= 0.1)

        // ~68% of a standard normal falls within one standard deviation
        let withinOneSigma = samples.filter { abs($0) <= 1 }.count
        #expect(Double(withinOneSigma) / Double(n) > 0.6)
        #expect(Double(withinOneSigma) / Double(n) < 0.76)
    }

    @Test func normalRespectsMeanAndDeviation() {
        var rng = LCRNG(seed: 7)
        let heights: some RandomGenerator<Double> = .normal(mean: 170, standardDeviation: 10)

        let n = 5000
        var sum = 0.0
        for _ in 0..<n {
            sum += heights.run(using: &rng)
        }

        #expect(abs((sum / Double(n)) - (170)) <= 1)
    }

    @Test func exponentialMeanAndPositivity() {
        var rng = LCRNG(seed: 42)
        let wait: some RandomGenerator<Double> = .exponential(rate: 2)

        let n = 5000
        var sum = 0.0
        for _ in 0..<n {
            let value = wait.run(using: &rng)
            #expect(value >= 0, "Exponential values are non-negative")
            sum += value
        }

        // Mean of Exp(rate: 2) is 0.5
        #expect(abs((sum / Double(n)) - (0.5)) <= 0.05)
    }

    @Test func deterministicWithSameSeed() {
        var rng1 = LCRNG(seed: 9)
        var rng2 = LCRNG(seed: 9)

        let normal = RandomGenerators.Normal()
        let exponential = RandomGenerators.Exponential()

        for _ in 0..<10 {
            #expect(normal.run(using: &rng1) == normal.run(using: &rng2))
            #expect(exponential.run(using: &rng1) == exponential.run(using: &rng2))
        }
    }
}
