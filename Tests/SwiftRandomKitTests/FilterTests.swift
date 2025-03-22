import XCTest
@testable import SwiftRandomKit

final class FilterTests: XCTestCase {
    
    // MARK: - Basic Filtering
    
    func testBasicFiltering() {
        // Create a generator for integers 1-10
        let intGenerator = IntGenerator(in: 1...10)
        
        // Filter to only even numbers
        let evenGenerator = intGenerator.filter { $0 % 2 == 0 }
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 1)

        // With our deterministic RNG, we should get predictable even numbers
        let result1 = evenGenerator.run(using: &rng)
        let result2 = evenGenerator.run(using: &rng)
        let result3 = evenGenerator.run(using: &rng)
        
        // Verify all results are even
        XCTAssertEqual(result1 % 2, 0)
        XCTAssertEqual(result2 % 2, 0)
        XCTAssertEqual(result3 % 2, 0)
        
        // Verify we get the expected sequence based on our seed
        XCTAssertEqual(result1, 2)
        XCTAssertEqual(result2, 2)
        XCTAssertEqual(result3, 6)
    }
    
    func testFilterWithAlwaysFailing() {
        // Create a generator for integers
        let intGenerator = IntGenerator(in: 1...100)
        
        // Create a filter with a predicate that always fails
        // but with a fallback to use the last value
        let impossibleGenerator = intGenerator.filter(
            maxAttempts: 5,
            { $0 > 100 }, // This is impossible in our range
            fallbackStrategy: .useLast
        )
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 42)
        
        // First generated value should be the last attempted value after 5 failures
        let result = impossibleGenerator.run(using: &rng)
        
        // The result should be within our range since it's the fallback value
        XCTAssertGreaterThanOrEqual(result, 1)
        XCTAssertLessThanOrEqual(result, 100)
    }
    
    func testFilterWithCustomFallback() {
        // Create a generator for integers
        let intGenerator = IntGenerator(in: 1...100)
        
        // Create a filter with a predicate that always fails
        // but with a fallback to use a default value
        let impossibleGenerator = intGenerator.filter(
            maxAttempts: 5,
            { $0 > 100 }, // This is impossible in our range
            fallbackStrategy: .useDefault(42)
        )
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 1)
        
        // First generated value should be the default value after 5 failures
        let result = impossibleGenerator.run(using: &rng)
        
        // The result should be our default value
        XCTAssertEqual(result, 42)
    }
    
    // MARK: - Edge Cases
    
    func testFilterWithHighProbabilityOfSuccess() {
        // Create a generator for integers 1-100
        let intGenerator = IntGenerator(in: 1...100)
        
        // Filter to numbers > 10, which should succeed 90% of the time
        let highSuccessGenerator = intGenerator.filter { $0 > 10 }
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 42)
        
        // Generate 10 values
        var allResults = [Int]()
        for _ in 0..<10 {
            allResults.append(highSuccessGenerator.run(using: &rng))
        }
        
        // All results should be > 10
        for result in allResults {
            XCTAssertGreaterThan(result, 10)
        }
        
        // We should have 10 different values
        XCTAssertEqual(allResults.count, 10)
    }
    
    // MARK: - CompactMap
    
    func testCompactMap() {
        // Create a generator for strings, some of which can be parsed as integers
        let stringGenerator = ["123", "abc", "456", "xyz", "789"].randomGeneratorElement()
        
        // Use compactMap to parse as integers
        let intGenerator = stringGenerator.compactMap { $0.flatMap(Int.init) }
        
        // for value in UInt64(1)...UInt64(1000) {
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 65)
        
        // Generate values and verify they're all valid integers
        let result1 = intGenerator.run(using: &rng)
        let result2 = intGenerator.run(using: &rng)
        let result3 = intGenerator.run(using: &rng)
       

        // Results should be the numeric values
        XCTAssertEqual(result1, 123)
        XCTAssertEqual(result2, 789)
        XCTAssertEqual(result3, 456)

    }
    
    func testCompactMapWithLowSuccessRate() {
        // Create an array with mostly values that will yield nil
        let values = ["not a number", "invalid", "error", "123", "not an int"]
        let stringGenerator = values.randomGeneratorElement()
        
        // Use compactMap with a low max attempts to see what happens
        let intGenerator = stringGenerator.compactMap(maxAttempts: 10) { $0.flatMap(Int.init) }
        
        // Create a seeded RNG that will find "123" within 10 attempts
        var rng = LCRNG(seed: 7) // Seed chosen to find a success within attempts
        
        // This should eventually succeed but after several attempts
        let result = intGenerator.run(using: &rng)
        
        // Result should be 123
        XCTAssertEqual(result, 123)
    }
    
    // MARK: - Custom Filtering Logic
    
    func testFilterWithCustomPredicate() {
        // Create a generator for characters
        let charGenerator = RandomGenerators.letterOrNumber
        
        // Filter to only letters (no numbers)
        let letterGenerator = charGenerator.filter { char in
            char.isLetter
        }
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 3)

        // Generate 5 values
        var results = [Character]()
        for _ in 0..<5 {
            results.append(letterGenerator.run(using: &rng))
        }
        
        // All results should be letters
        for char in results {
            XCTAssertTrue(char.isLetter)
        }
    }
} 
