import XCTest
import SwiftRandomKit

final class MapTests: XCTestCase {
    func testMap() {
        let intGenerator = IntGenerator<Int>(in: 0...10)
        let mapped = intGenerator.map { $0 * 2 }
        var rng = LCRNG(seed: 1)

        XCTAssertEqual(mapped.run(using: &rng), 2)
        XCTAssertEqual(mapped.run(using: &rng), 14)
    }

    func testMapString() {
        let intGenerator = IntGenerator<Int>(in: 0...10)
        let mapped = intGenerator.map { String($0) }
        var rng = LCRNG(seed: 1)

        XCTAssertEqual(mapped.run(using: &rng), "1")
        XCTAssertEqual(mapped.run(using: &rng), "7")
    }
        
    func testMapChaining() {
        // Test the optimized map chaining method on RandomGenerators.Map
        let intGenerator = IntGenerator<Int>(in: 0...10)
        
        // Create a map generator
        let doubledGenerator = intGenerator.map { $0 * 2 }
        
        // Chain another map transformation using the optimized method
        let formattedGenerator = doubledGenerator.map { "Value: \($0)" }
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 1)
        
        // Verify the results
        XCTAssertEqual(formattedGenerator(using: &rng), "Value: 2")
        XCTAssertEqual(formattedGenerator(using: &rng), "Value: 14")
    }
    
    func testMultipleMapChaining() {
        // Test multiple levels of map chaining
        let intGenerator = IntGenerator<Int>(in: 0...10)
        
        // Create a chain of map transformations
        let result = intGenerator
            .map { $0 * 2 }                // Double the value
            .map { $0 + 10 }               // Add 10
            .map { "\($0)" }               // Convert to string
            .map { "Result: \($0)" }       // Format with prefix
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 1)
        
        // Verify the results
        XCTAssertEqual(result.run(using: &rng), "Result: 12")
        XCTAssertEqual(result.run(using: &rng), "Result: 24")
    }
    
    func testMapWithComplexTransformations() {
        // Test map with more complex transformations
        let tupleGenerator = IntGenerator<Int>(in: 1...10).tuple()
        
        // Map the tuple to a formatted string
        let formattedGenerator = tupleGenerator.map { tuple in
            "Coordinates: (\(tuple.0), \(tuple.1))"
        }
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 1)
        
        // Verify the results
        XCTAssertEqual(formattedGenerator.run(using: &rng), "Coordinates: (2, 7)")
        XCTAssertEqual(formattedGenerator.run(using: &rng), "Coordinates: (9, 1)")
    }
}
