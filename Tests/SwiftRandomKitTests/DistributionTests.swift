import XCTest
import SwiftRandomKit

final class DistributionTests: XCTestCase {

    func testStandardNormalMoments() {
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

        XCTAssertEqual(mean, 0, accuracy: 0.1)
        XCTAssertEqual(variance.squareRoot(), 1, accuracy: 0.1)

        // ~68% of a standard normal falls within one standard deviation
        let withinOneSigma = samples.filter { abs($0) <= 1 }.count
        XCTAssertGreaterThan(Double(withinOneSigma) / Double(n), 0.6)
        XCTAssertLessThan(Double(withinOneSigma) / Double(n), 0.76)
    }

    func testNormalRespectsMeanAndDeviation() {
        var rng = LCRNG(seed: 7)
        let heights: some RandomGenerator<Double> = .normal(mean: 170, standardDeviation: 10)

        let n = 5000
        var sum = 0.0
        for _ in 0..<n {
            sum += heights.run(using: &rng)
        }

        XCTAssertEqual(sum / Double(n), 170, accuracy: 1)
    }

    func testExponentialMeanAndPositivity() {
        var rng = LCRNG(seed: 42)
        let wait: some RandomGenerator<Double> = .exponential(rate: 2)

        let n = 5000
        var sum = 0.0
        for _ in 0..<n {
            let value = wait.run(using: &rng)
            XCTAssertGreaterThanOrEqual(value, 0, "Exponential values are non-negative")
            sum += value
        }

        // Mean of Exp(rate: 2) is 0.5
        XCTAssertEqual(sum / Double(n), 0.5, accuracy: 0.05)
    }

    func testDeterministicWithSameSeed() {
        var rng1 = LCRNG(seed: 9)
        var rng2 = LCRNG(seed: 9)

        let normal = RandomGenerators.Normal()
        let exponential = RandomGenerators.Exponential()

        for _ in 0..<10 {
            XCTAssertEqual(normal.run(using: &rng1), normal.run(using: &rng2))
            XCTAssertEqual(exponential.run(using: &rng1), exponential.run(using: &rng2))
        }
    }
}
