import XCTest
import SwiftRandomKit

final class TryMapTests: XCTestCase {
    // Define a custom error type for testing
    enum TestError: Error, Equatable {
        case invalidValue
        case outOfRange
    }
    
    func testTryMapSuccess() {
        // Create a generator that produces valid strings for conversion
        let stringGenerator = ["123", "456", "789"].randomGeneratorElement()
        
        // Create a tryMap generator that converts strings to integers
        let intGenerator = stringGenerator.tryMap { str -> Int in
            guard let unwrappedStr = str, let number = Int(unwrappedStr) else {
                throw TestError.invalidValue
            }
            return number
        }
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 42)
        let result = intGenerator.run(using: &rng)
        
        // With seed 42, we should get the correct value
        XCTAssertEqual(try result.get(), 456)
        
        // Generate a sequence of values and verify they match expected values
        let expectedSequence = [789, 456, 789, 123]
        for expected in expectedSequence {
            let value = intGenerator.run(using: &rng)
            XCTAssertEqual(try value.get(), expected)
        }
    }
    
    func testTryMapFailure() {
        // Create a generator that produces both valid and invalid strings
        let stringGenerator = ["123", "abc", "456"].randomGeneratorElement()
        
        // Create a tryMap generator that converts strings to integers
        let intGenerator = stringGenerator.tryMap { str -> Int in
            guard let unwrappedStr = str, let number = Int(unwrappedStr) else {
                throw TestError.invalidValue
            }
            return number
        }
        
        // Test with a deterministic RNG that will select the invalid string
        var rng = LCRNG(seed: 1) // Adjust seed to ensure we get "abc" as the second value
        
        // First value should be valid
        let firstResult = intGenerator.run(using: &rng)
        XCTAssertEqual(try firstResult.get(), 123)
        
        // Second value should be invalid
        let secondResult = intGenerator.run(using: &rng)
        XCTAssertThrowsError(try secondResult.get()) { error in
            XCTAssertEqual(error as? TestError, TestError.invalidValue)
        }
        
        // Third value should be valid again
        let thirdResult = intGenerator.run(using: &rng)
        XCTAssertEqual(try thirdResult.get(), 456)
    }
    
    func testTryMapWithCondition() {
        // Create a generator that produces integers
        let intGenerator = IntGenerator(in: 1...10)
        
        // Create a tryMap generator that only accepts even numbers
        let evenGenerator = intGenerator.tryMap { value -> Int in
            guard value % 2 == 0 else {
                throw TestError.invalidValue
            }
            return value
        }
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 42)
        
        // With seed 42, IntGenerator(1...10) produces a sequence of numbers
        // Only even numbers should succeed
        
        // First value should succeed
        let firstResult = evenGenerator.run(using: &rng)
        XCTAssertEqual(try firstResult.get(), 6)
        
        // Second value should succeed
        let secondResult = evenGenerator.run(using: &rng)
        XCTAssertEqual(try secondResult.get(), 10)
        
        // Third value should succeed
        let thirdResult = evenGenerator.run(using: &rng)
        XCTAssertEqual(try thirdResult.get(), 6)
        
        // Fourth value should succeed
        let fourthResult = evenGenerator.run(using: &rng)
        XCTAssertEqual(try fourthResult.get(), 8)
        
        // Fifth value should succeed
        let fifthResult = evenGenerator.run(using: &rng)
        XCTAssertEqual(try fifthResult.get(), 2)
        
        // Sixth value should fail
        let sixthResult = evenGenerator.run(using: &rng)
        XCTAssertThrowsError(try sixthResult.get()) { error in
            XCTAssertEqual(error as? TestError, TestError.invalidValue)
        }
    }
    
    func testTryMapWithMultipleErrorTypes() {
        // Create a generator that produces integers
        let intGenerator = IntGenerator(in: -5...15)
        
        // Create a tryMap generator with multiple potential errors
        let validatedGenerator = intGenerator.tryMap { value -> Int in
            // Must be positive
            guard value > 0 else {
                throw TestError.invalidValue
            }
            
            // Must be in range 1-10
            guard value <= 10 else {
                throw TestError.outOfRange
            }
            
            return value
        }
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 42)
        
        // With seed 42, IntGenerator(-5...15) produces a sequence of numbers
        
        // First value should succeed
        let firstResult = validatedGenerator.run(using: &rng)
        XCTAssertEqual(try firstResult.get(), 5)
        
        // Second value should fail with outOfRange
        let secondResult = validatedGenerator.run(using: &rng)
        XCTAssertThrowsError(try secondResult.get()) { error in
            XCTAssertEqual(error as? TestError, TestError.outOfRange)
        }
        
        // Third value should succeed
        let thirdResult = validatedGenerator.run(using: &rng)
        XCTAssertEqual(try thirdResult.get(), 7)
        
        // Fourth value should succeed
        let fourthResult = validatedGenerator.run(using: &rng)
        XCTAssertEqual(try fourthResult.get(), 10)
        
        // Fifth value should fail with invalidValue
        let fifthResult = validatedGenerator.run(using: &rng)
        XCTAssertThrowsError(try fifthResult.get()) { error in
            XCTAssertEqual(error as? TestError, TestError.invalidValue)
        }
    }
} 