import XCTest
import SwiftRandomKit

final class PrintTests: XCTestCase {
    // We can't easily capture print output in Swift, so we'll test the functionality
    // by verifying that the Print generator returns the correct values
    
    func testPrintInt() {
        // Create a print generator for integers
        let intGenerator = IntGenerator(in: 1...6)
        let printGenerator = intGenerator.print("Dice roll")
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 42)
        let result = printGenerator.run(using: &rng)
        
        // With seed 42, IntGenerator(1...6) produces 4
        XCTAssertEqual(result, 4)
        
        // Generate a sequence of values and verify they match expected values
        let expectedSequence = [6, 4, 5, 1, 2, 4]
        for expected in expectedSequence {
            let value = printGenerator.run(using: &rng)
            XCTAssertEqual(value, expected)
        }
    }
    
    func testPrintString() {
        // Create a print generator for strings
        let stringGenerator = ["apple", "banana", "cherry"].randomGeneratorElement()
        let printGenerator = stringGenerator.print("Fruit")
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 42)
        let result = printGenerator.run(using: &rng)
        
        // With seed 42, we should get "banana"
        XCTAssertEqual(result, "banana")
        
        // Generate a sequence of values and verify they match expected values
        let expectedSequence = ["cherry", "banana", "cherry", "apple"]
        for expected in expectedSequence {
            let value = printGenerator.run(using: &rng)
            XCTAssertEqual(value, expected)
        }
    }
    
    func testPrintInChain() {
        // Create a chain of generators with print in the middle
        let generator = IntGenerator(in: 1...10)
            .print("Original")
            .map { $0 * 2 }
            .print("Doubled")
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 42)
        let result = generator.run(using: &rng)
        
        // With seed 42, IntGenerator(1...10) produces 6
        // So the result should be 6 * 2 = 12
        XCTAssertEqual(result, 12)
        
        // Generate a sequence of values and verify they match expected values
        let expectedSequence = [20, 12, 16, 4, 6, 14]
        for expected in expectedSequence {
            let value = generator.run(using: &rng)
            XCTAssertEqual(value, expected)
        }
    }
} 