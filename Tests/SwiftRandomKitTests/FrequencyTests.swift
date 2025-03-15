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
        var rng = LCRNG(seed: 42)
        var results: [Int: Int] = [1: 0, 2: 0, 3: 0]
        
        // For statistical significance, generate a large number of values
        for _ in 1...1000 {
            let value = frequencyGen.run(using: &rng)
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
    }
    
    func testFrequencyWithSingleItem() {
        // A frequency generator with only one item should always return that item
        let onlyOption = Always("only option")
        
        let distribution: [(Int, RandomGenerators.Always<String>)] = [
            (1, onlyOption)
        ]
        
        let frequencyGen = onlyOption.frequency(distribution)
        
        var rng = LCRNG(seed: 1)
        for _ in 1...10 {
            XCTAssertEqual(frequencyGen.run(using: &rng), "only option")
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
        
        var rng = LCRNG(seed: 1)
        let result = frequencyGen.run(using: &rng)
        
        // Verify we get one of the expected values
        XCTAssertTrue([1, 2, 3].contains(result))
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
        
        var rng = LCRNG(seed: 1)
        for _ in 1...20 {
            XCTAssertEqual(frequencyGen.run(using: &rng), "always select")
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
        
        var rng = LCRNG(seed: 42)
        var results = [Int]()
        
        // Generate 100 values and make sure we see both dice ranges
        for _ in 1...100 {
            results.append(frequencyGen.run(using: &rng))
        }
        
        // Should have numbers 1-6 from the first dice
        XCTAssertTrue(results.contains { $0 >= 1 && $0 <= 6 })
        
        // Should also have numbers 7-10 from the second dice
        XCTAssertTrue(results.contains { $0 >= 7 && $0 <= 10 })
    }
} 