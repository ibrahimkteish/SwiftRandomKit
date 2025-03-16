import XCTest
@testable import SwiftRandomKit

final class IntGeneratorTests: XCTestCase {
    
    func testIntGeneratorClosedRange() {
        // Test the IntGenerator with a closed range (inclusive bounds)
        let generator = IntGenerator(in: 1...10)
        
        // Test with deterministic RNG to ensure consistent results
        var rng = LCRNG(seed: 42)
        
        // Generate a sequence of values and verify they match the expected values
        let expectedSequence = [6, 10, 6, 8, 2, 3, 7, 9, 10, 1]
        
        for expected in expectedSequence {
            let actual = generator.run(using: &rng)
            XCTAssertEqual(actual, expected, "LCRNG with seed 42 should produce deterministic values")
        }
        
        // Test range bounds - all values should be within specified range
        rng = LCRNG(seed: 100) // Different seed
        for _ in 0..<100 {
            let value = generator.run(using: &rng)
            XCTAssertGreaterThanOrEqual(value, 1, "Generated value should be >= lower bound")
            XCTAssertLessThanOrEqual(value, 10, "Generated value should be <= upper bound")
        }
    }
    
    func testIntGeneratorOpenRange() {
        // Test the IntGenerator with a half-open range (exclusive upper bound)
        let generator = IntGenerator(in: 1..<11)
        
        // With deterministic RNG
        var rng = LCRNG(seed: 42)
        
        // Generate a sequence of values and verify they match the expected values
        let expectedSequence = [6, 10, 6, 8, 2, 3, 7, 9, 10, 1]
        
        for expected in expectedSequence {
            let actual = generator.run(using: &rng)
            XCTAssertEqual(actual, expected, "LCRNG with seed 42 should produce deterministic values")
        }
        
        // Test range bounds - all values should be within specified range
        rng = LCRNG(seed: 100) // Different seed
        for _ in 0..<100 {
            let value = generator.run(using: &rng)
            XCTAssertGreaterThanOrEqual(value, 1, "Generated value should be >= lower bound")
            XCTAssertLessThan(value, 11, "Generated value should be < upper bound")
        }
    }
    
    func testIntGeneratorDifferentSeeds() {
        // Test that different seeds produce different but deterministic sequences
        let generator = IntGenerator(in: 1...100)
        
        var rng1 = LCRNG(seed: 42)
        var rng2 = LCRNG(seed: 43)
        
        // Generate values using different seeds
        let values1 = (0..<10).map { _ in generator.run(using: &rng1) }
        let values2 = (0..<10).map { _ in generator.run(using: &rng2) }
        
        // Sequences should be different
        XCTAssertNotEqual(values1, values2, "Different seeds should produce different sequences")
        
        // But repeating with the same seed should produce the same sequence
        var rng3 = LCRNG(seed: 42) // Same as rng1
        let values3 = (0..<10).map { _ in generator.run(using: &rng3) }
        
        XCTAssertEqual(values1, values3, "Same seed should produce identical sequences")
    }
    
    func testIntGeneratorEdgeCases() {
        // Test with a single-value range
        let singleValueGen = IntGenerator(in: 5...5)
        var rng = LCRNG(seed: 42)
        
        // Should always generate 5
        for _ in 0..<10 {
            XCTAssertEqual(singleValueGen.run(using: &rng), 5, "Single-value range should always produce that value")
        }
        
        // Test with maximum possible range for Int8
        let fullRangeGen = IntGenerator<Int8>(in: Int8.min...Int8.max)
        
        // With deterministic RNG, check a few values
        var rngForFullRange = LCRNG(seed: 42)
        let fullRangeExpected: [Int8] = [-81, 32, -51, -58, -37, -100, 89, 34, -57, -40]
        
        for expected in fullRangeExpected {
            let actual = fullRangeGen.run(using: &rngForFullRange)
            XCTAssertEqual(actual, expected, "Full range Int8 generator should produce expected sequence")
        }
    }
    
    func testIntGeneratorDistribution() {
        // Test the distribution of values - should be roughly uniform
        let generator = IntGenerator(in: 1...6) // Like a dice
        var rng = LCRNG(seed: 100)
        
        var counts = [Int: Int]()
        let iterations = 6000 // 1000 rolls per side
        
        // Count occurrences of each value
        for _ in 0..<iterations {
            let value = generator.run(using: &rng)
            counts[value, default: 0] += 1
        }
        
        // Each value should occur roughly equally often (1000 times each ±20%)
        for i in 1...6 {
            XCTAssertGreaterThan(counts[i, default: 0], 800, "Value \(i) should occur roughly 1000 times in 6000 iterations")
            XCTAssertLessThan(counts[i, default: 0], 1200, "Value \(i) should occur roughly 1000 times in 6000 iterations")
        }
    }
    
    func testIntGeneratorDifferentTypes() {
        // Test with different integer types
        
        // UInt8 generator (0-255)
        let uint8Gen = IntGenerator<UInt8>(in: 0...255)
        var rng1 = LCRNG(seed: 42)
        let uint8Expected: [UInt8] = [175, 32, 205, 198, 219, 156, 89, 34, 199, 216]
        
        for expected in uint8Expected {
            let actual = uint8Gen.run(using: &rng1)
            XCTAssertEqual(actual, expected, "UInt8 generator should produce deterministic sequence")
        }
        
        // Int16 generator
        let int16Gen = IntGenerator<Int16>(in: -1000...1000)
        var rng2 = LCRNG(seed: 42)
        let int16Expected: [Int16] = [975, 970, -760, -346, 734, 536, 11, 939, 100, 780]
        
        for expected in int16Expected {
            let actual = int16Gen.run(using: &rng2)
            XCTAssertEqual(actual, expected, "Int16 generator should produce deterministic sequence")
        }
        
        // UInt32 generator (large range)
        let uint32Gen = IntGenerator<UInt32>(in: 0...UInt32.max)
        var rng3 = LCRNG(seed: 42)
        
        // Just check the values are in range and deterministic
        let firstValue = uint32Gen.run(using: &rng3)
        var rng4 = LCRNG(seed: 42)
        XCTAssertEqual(uint32Gen.run(using: &rng4), firstValue, "UInt32 generator should be deterministic")
    }
} 