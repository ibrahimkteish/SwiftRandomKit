import XCTest
import SwiftRandomKit

final class OptionalTests: XCTestCase {
    func testOptionalInt() {
        // Create an optional integer generator
        let intGenerator = IntGenerator(in: 1...6)
        let optionalGenerator = intGenerator.optional()
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 42)
        let result = optionalGenerator.run(using: &rng)
        
        // With seed 42, IntGenerator(1...6) produces 4
        XCTAssertEqual(result, 4)
        
        // Run again with the same seed to verify determinism
        var rng2 = LCRNG(seed: 42)
        let result2 = optionalGenerator.run(using: &rng2)
        XCTAssertEqual(result, result2)
        
        // Generate a sequence of values and verify they match expected values
        let expectedSequence = [6, 4, 5, 1, 2, 4, 6, 6, 1]
        for expected in expectedSequence {
            let value = optionalGenerator.run(using: &rng)
            XCTAssertEqual(value, expected)
        }
    }
    
    func testOptionalString() {
        // Create an optional string generator
        let stringGenerator = ["apple", "banana", "cherry"].randomGeneratorElement()
        let optionalGenerator = stringGenerator.optional()
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 42)
        let result = optionalGenerator.run(using: &rng)
        
        // With seed 42, we should get "banana"
        XCTAssertEqual(result, "banana")
        
        // Generate a sequence of values and verify they match expected values
        let expectedSequence = ["cherry", "banana", "cherry", "apple"]
        for expected in expectedSequence {
            let value = optionalGenerator.run(using: &rng)
            XCTAssertEqual(value, expected)
        }
    }
    
    func testOptionalTuple() {
        // Create an optional tuple generator
        let tupleGenerator = IntGenerator(in: 0...100).tuple()
        let optionalGenerator = tupleGenerator.optional()
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 42)
        let result = optionalGenerator.run(using: &rng)
        
        // With seed 42, we should get (52, 100)
        XCTAssertEqual(result?.0, 52)
        XCTAssertEqual(result?.1, 100)
        
        // Run again with the same seed to verify determinism
        var rng2 = LCRNG(seed: 42)
        let result2 = optionalGenerator.run(using: &rng2)
        XCTAssertEqual(result2?.0, 52)
        XCTAssertEqual(result2?.1, 100)
    }
    
    func testOptionalInChain() {
        // Create a chain of generators with optional in the middle
        let generator = IntGenerator(in: 1...10)
            .optional()
            .map { optionalValue in
                optionalValue.map { $0 * 2 } ?? 0
            }
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 42)
        let result = generator.run(using: &rng)
        
        // With seed 42, IntGenerator(1...10) produces 6
        // So the result should be 6 * 2 = 12
        XCTAssertEqual(result, 12)
        
        // Generate a sequence of values and verify they match expected values
        let expectedSequence = [20, 12, 16, 4, 6, 14, 18, 20, 2]
        for expected in expectedSequence {
            let value = generator.run(using: &rng)
            XCTAssertEqual(value, expected)
        }
    }
} 