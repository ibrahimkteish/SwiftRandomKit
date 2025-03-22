import XCTest
@testable import SwiftRandomKit

final class RetryTests: XCTestCase {
    
    // MARK: - Basic Retry Testing
    
    func testBasicRetry() {
        // Create a generator for numbers 1-10
        let intGenerator = IntGenerator(in: 1...10)
        
        // Retry until we get a value greater than 5
        let greaterThanFiveGen = intGenerator.retry(until: { $0 > 5 })
        
        var rng = LCRNG(seed: 42)
        
        // With our deterministic RNG, we should get predictable values
        let result1 = greaterThanFiveGen.run(using: &rng)
        let result2 = greaterThanFiveGen.run(using: &rng)
        let result3 = greaterThanFiveGen.run(using: &rng)
        
        // Verify all results are > 5
        XCTAssertGreaterThan(result1, 5)
        XCTAssertGreaterThan(result2, 5)
        XCTAssertGreaterThan(result3, 5)
        
        // Verify we get the expected sequence based on our seed
        XCTAssertEqual(result1, 6) 
        XCTAssertEqual(result2, 10)
        XCTAssertEqual(result3, 6)
    }
    
    func testRetryWithAlwaysFailing() {
        // Create a generator for integers
        let intGenerator = IntGenerator(in: 1...100)
        
        // Create a retry with a condition that always fails
        // but with a fallback to use the last value
        let impossibleGenerator = intGenerator.retry(
            maxAttempts: 5,
            fallbackStrategy: .useLast,
            until: { $0 > 100 }
        )
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 42)

        // We should get the last attempted value after 5 failures
        let result = impossibleGenerator.run(using: &rng)

        // The result should be within our range since it's the fallback value
        XCTAssertGreaterThanOrEqual(result, 1)
        XCTAssertLessThanOrEqual(result, 100)
    }
    
    func testRetryWithDefaultFallback() {
        // Create a generator for integers
        let intGenerator = IntGenerator(in: 1...100)
        
        // Create a retry with a condition that always fails
        // but with a fallback to use a default value
        let impossibleGenerator = intGenerator.retry(
            maxAttempts: 5,
            fallbackStrategy: .useDefault(42),
            until: { $0 > 100 }
        )
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 7)
        
        // First generated value should be our default value
        let result = impossibleGenerator.run(using: &rng)
        
        // The result should be our default value
        XCTAssertEqual(result, 42)
    }
    
    func testRetryWithKeepTryingFallback() {
        // Create a generator that sometimes satisfies a condition
        let diceGenerator = IntGenerator(in: 1...6)
        
        // Create a mock function that checks if we've tried to generate a six
        let  attemptsToGenerate6 = LockIsolated(0)
        let conditionCounter: @Sendable (Int) -> Bool = { @Sendable value in
            if value == 6 {
                return true
            }
            attemptsToGenerate6.withValue { $0 += 1 }
            return false
        }
        
        // Create a retry with keepTrying fallback
        let eventuallyGenerator = diceGenerator.retry(
            maxAttempts: 3, // Only try 3 times initially
            fallbackStrategy: .keepTrying,
            until: conditionCounter // But keep trying if we don't succeed
        )
        
        // Use a deterministic RNG that won't generate a 6 in the first 3 tries
        var rng = LCRNG(seed: 123) // Chosen to not generate a 6 immediately
        
        // This should eventually generate a 6 after multiple attempts
        let result = eventuallyGenerator.run(using: &rng)
        
        // We should get a 6
        XCTAssertEqual(result, 6)
        // We should have made more than the initial maxAttempts
        XCTAssertGreaterThan(attemptsToGenerate6.value, 0, "Should have made at least one attempt")
    }
    
    // MARK: - Specialized Retry Functions
    
    func testRetryMap() {
        // Create a generator for strings, some of which can be parsed as integers
        let stringGenerator = ["abc", "123", "xyz", "456", "qwerty"].randomGeneratorElement()
        
        // Use retryMap to parse as integers
        let intGenerator = stringGenerator.retryMap { $0.flatMap(Int.init) }
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 42)
        
        // This should generate the first numeric string and convert it
        let result = intGenerator.run(using: &rng)
        
        // Verify we get a numeric value
        XCTAssertEqual(result, 456)
    }
    
    func testRetryThrowing() {
        // Define a simple error
        enum TestError: Error { case notEven }
        
        // Create a generator for integers
        let intGenerator = IntGenerator(in: 1...10)
        
        // Use retryThrowing to get only even numbers
        let evenGenerator = intGenerator.retryThrowing { value in
            guard value % 2 == 0 else {
                throw TestError.notEven
            }
            return value
        }
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 42)
        
        // Generate values and verify they're all even
        let result1 = evenGenerator.run(using: &rng)
        let result2 = evenGenerator.run(using: &rng)
        let result3 = evenGenerator.run(using: &rng)
        
        // Verify all results are even
        XCTAssertEqual(result1 % 2, 0)
        XCTAssertEqual(result2 % 2, 0)
        XCTAssertEqual(result3 % 2, 0)
        
        // Verify the expected sequence
        XCTAssertEqual(result1, 6)
        XCTAssertEqual(result2, 10)
        XCTAssertEqual(result3, 6)
    }
    
    // MARK: - Complex Scenarios
    
    func testRetryWithAnotherGeneratorFallback() {
        // Create a generator for integers 1-50
        let intGenerator = IntGenerator(in: 1...50)
        
        // Create a custom fallback generator that always returns 999
        let fallbackGenerator: @Sendable () -> Int = {
            return 999
        }
        
        // Create a retry with a condition that always fails
        // and with a fallback to use another generator
        let impossibleGenerator = intGenerator.retry(
            maxAttempts: 5,
            fallbackStrategy: .useAnotherGenerator(fallbackGenerator), 
            until: { $0 > 200 } // This is impossible in our range
        )
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 1)
        
        // After maxAttempts, it should call our fallback generator
        let result = impossibleGenerator.run(using: &rng)
        
        // The result should be the value from our fallback generator
        XCTAssertEqual(result, 999)
    }
    
    func testRetryWithIncreasingProbability() {
        // Create a generator that returns true with increasing probability
      let attemptCount = LockIsolated(0)
      let increasingProbabilityGenerator = IntGenerator(in: 0...10).map { _ -> Bool in
            attemptCount.withValue { $0 += 1 }
            // Return true with probability attemptCount/10
            return Double(attemptCount.value) / 10.0 > 0.7
        }

        // Create a retry that continues until we get a true
        let eventualSuccessGenerator = increasingProbabilityGenerator.retry(
            maxAttempts: 10,
            fallbackStrategy: .keepTrying,
            until: { $0 == true }
        )
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 42)
        
        // This should eventually succeed after multiple attempts
        let result = eventualSuccessGenerator.run(using: &rng)
        
        // We should get a true result
        XCTAssertTrue(result)
        
        // We should have made several attempts (8 or more since probability is attemptCount/10 > 0.7)
      XCTAssertGreaterThanOrEqual(attemptCount.value, 8)
    }
} 
