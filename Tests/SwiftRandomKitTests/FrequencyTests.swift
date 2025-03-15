import XCTest
import SwiftRandomKit

final class FrequencyTests: XCTestCase {
    
    func testFrequencyDistribution() {
        // Given a set of values with assigned weights, checks if the frequency
        // generator produces values according to the expected distribution
        
        let lowWeight = 1
        let mediumWeight = 3
        let highWeight = 6
        
        let gen1 = Always(1)
        let gen2 = Always(2)
        let gen3 = Always(3)
        
        let distribution: [(Int, RandomGenerators.Always<Int>)] = [
            (lowWeight, gen1),
            (mediumWeight, gen2),
            (highWeight, gen3)
        ]
        
        let frequencyGen = gen1.frequency(distribution)
        
        // Run the generator many times to check frequency distribution
        var distributionRng = LCRNG(seed: 100)
        var results: [Int: Int] = [1: 0, 2: 0, 3: 0]
        
        // For statistical significance, generate a large number of values
        for _ in 1...1000 {
            let value = frequencyGen.run(using: &distributionRng)
            results[value, default: 0] += 1
        }
        
        // Test the approximate distribution follows the weights
        // Sum of weights is 10, so each unit of weight should give ~10% of values
        XCTAssertGreaterThan(results[1]!, 50)     // Low weight should have at least ~5% (50 out of 1000)
        XCTAssertGreaterThan(results[2]!, 200)    // Medium weight should have at least ~20% (200 out of 1000)
        XCTAssertGreaterThan(results[3]!, 450)    // High weight should have at least ~45% (450 out of 1000)
        
        // The high-weighted item should occur more often than the medium-weighted item
        XCTAssertGreaterThan(results[3]!, results[2]!)
        
        // The medium-weighted item should occur more often than the low-weighted item
        XCTAssertGreaterThan(results[2]!, results[1]!)
        
        // Test deterministic behavior by checking that same seed produces same first value
        var rng1 = LCRNG(seed: 42)
        var rng2 = LCRNG(seed: 42)
        
        let firstValue1 = frequencyGen.run(using: &rng1)
        let firstValue2 = frequencyGen.run(using: &rng2)
        
        XCTAssertEqual(firstValue1, firstValue2, "Same seed should produce same first value")
    }
    
    func testFrequencyWithSingleItem() {
        // A frequency generator with only one item should always return that item
        let onlyOption = Always("only option")
        
        let distribution: [(Int, RandomGenerators.Always<String>)] = [
            (1, onlyOption)
        ]
        
        let frequencyGen = onlyOption.frequency(distribution)
        
        // Even with different seeds, should always return the same single value
        var rng1 = LCRNG(seed: 1)
        var rng2 = LCRNG(seed: 42)
        var rng3 = LCRNG(seed: 99)
        
        XCTAssertEqual(frequencyGen.run(using: &rng1), "only option", "Only option should be selected regardless of seed")
        XCTAssertEqual(frequencyGen.run(using: &rng2), "only option", "Only option should be selected regardless of seed")
        XCTAssertEqual(frequencyGen.run(using: &rng3), "only option", "Only option should be selected regardless of seed")
        
        // Verify multiple runs also return the same item
        for _ in 1...10 {
            XCTAssertEqual(frequencyGen.run(using: &rng1), "only option", "Only option should always be selected")
        }
    }
    
    func testFrequencyWithMixedValues() {
        // Testing selecting from different values but same generator type
        let int1 = Always(1)
        let int2 = Always(2)
        let int3 = Always(3)
        
        let distribution: [(Int, RandomGenerators.Always<Int>)] = [
            (1, int1),
            (2, int2),
            (3, int3)
        ]
        
        let frequencyGen = int1.frequency(distribution)
        
        // Test distribution properties with many iterations
        var distributionRng = LCRNG(seed: 456)
        var results = [1: 0, 2: 0, 3: 0]
        
        // Run many times to collect a good sample
        for _ in 1...1000 {
            let value = frequencyGen.run(using: &distributionRng)
            results[value, default: 0] += 1
        }
        
        // Check that the weighted distribution is approximately correct
        // Weight 3 should be greater than weight 2 should be greater than weight 1
        XCTAssertGreaterThan(results[3]!, results[2]!)
        XCTAssertGreaterThan(results[2]!, results[1]!)
        
        // Verify rough proportions are correct
        let total = results.values.reduce(0, +)
        let proportion1 = Double(results[1]!) / Double(total)
        let proportion2 = Double(results[2]!) / Double(total)
        let proportion3 = Double(results[3]!) / Double(total)
        
        XCTAssertLessThan(proportion1, 0.2, "Weight 1 should be less than 20% of the total")
        XCTAssertGreaterThan(proportion2, 0.25, "Weight 2 should be at least 25% of the total")
        XCTAssertGreaterThan(proportion3, 0.45, "Weight 3 should be at least 45% of the total")
        
        // Test deterministic behavior by checking that same seed produces same first value
        var rng1 = LCRNG(seed: 42)
        var rng2 = LCRNG(seed: 42)
        
        let firstValue1 = frequencyGen.run(using: &rng1)
        let firstValue2 = frequencyGen.run(using: &rng2)
        
        XCTAssertEqual(firstValue1, firstValue2, "Same seed should produce same first value")
    }
    
    func testFrequencyWithZeroWeights() {
        // Items with zero weight should never be selected
        let neverSelect = Always("never select")
        let alwaysSelect = Always("always select")
        
        let distribution: [(Int, RandomGenerators.Always<String>)] = [
            (0, neverSelect),
            (1, alwaysSelect)
        ]
        
        let frequencyGen = neverSelect.frequency(distribution)
        
        // With any seed, zero-weighted items should never be selected
        var rng1 = LCRNG(seed: 1)
        var rng2 = LCRNG(seed: 42)
        var rng3 = LCRNG(seed: 99)
        
        XCTAssertEqual(frequencyGen.run(using: &rng1), "always select", "Zero-weighted item should never be selected")
        XCTAssertEqual(frequencyGen.run(using: &rng2), "always select", "Zero-weighted item should never be selected")
        XCTAssertEqual(frequencyGen.run(using: &rng3), "always select", "Zero-weighted item should never be selected")
        
        // Test multiple runs to ensure zero-weighted item is never selected
        for _ in 1...20 {
            XCTAssertEqual(frequencyGen.run(using: &rng1), "always select", "Zero-weighted item should never be selected")
        }
    }
    
    func testFrequencyWithCustomGenerators() {
        // Testing with a more complex generator
        let diceGen1 = IntGenerator(in: 1...6)
        let diceGen2 = IntGenerator(in: 1...10)
        
        let distribution: [(Int, IntGenerator<Int>)] = [
            (1, diceGen1),
            (1, diceGen2)
        ]
        
        let frequencyGen = diceGen1.frequency(distribution)
        
        // Check we get values from both dice ranges
        var rng = LCRNG(seed: 42) // Reset RNG for clarity
        var results = [Int]()
        
        // Generate 100 values and make sure we see both dice ranges
        for _ in 1...100 {
            results.append(frequencyGen.run(using: &rng))
        }
        
        // Should have numbers 1-6 from the first dice
        XCTAssertTrue(results.contains { $0 >= 1 && $0 <= 6 }, "Should contain values from first dice (1-6)")
        
        // Should also have numbers 7-10 from the second dice
        XCTAssertTrue(results.contains { $0 >= 7 && $0 <= 10 }, "Should contain values from second dice (7-10)")
        
        // Since the weights are equal, we should get roughly equal numbers from each range
        let firstDiceCount = results.filter { $0 >= 1 && $0 <= 6 }.count
        let secondDiceCount = results.filter { $0 >= 7 && $0 <= 10 }.count
        
        // Check both dice produce results, allowing for statistical variance
        XCTAssertGreaterThan(firstDiceCount, 20, "Should have a substantial number of results from first dice")
        XCTAssertGreaterThan(secondDiceCount, 10, "Should have a substantial number of results from second dice")
        
        // Test deterministic behavior by checking that same seed produces same first value
        var rng1 = LCRNG(seed: 42)
        var rng2 = LCRNG(seed: 42)
        
        let firstValue1 = frequencyGen.run(using: &rng1)
        let firstValue2 = frequencyGen.run(using: &rng2)
        
        XCTAssertEqual(firstValue1, firstValue2, "Same seed should produce same first value")
    }
} 