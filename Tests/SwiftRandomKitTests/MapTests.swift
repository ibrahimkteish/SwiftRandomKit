import Testing
import SwiftRandomKit

struct MapTests {
    @Test func map() {
        let intGenerator = IntGenerator<Int>(in: 0...10)
        let mapped = intGenerator.map { $0 * 2 }
        var rng = LCRNG(seed: 1)

        #expect(mapped.run(using: &rng) == 2)
        #expect(mapped.run(using: &rng) == 14)
    }

    @Test func mapString() {
        let intGenerator = IntGenerator<Int>(in: 0...10)
        let mapped = intGenerator.map { String($0) }
        var rng = LCRNG(seed: 1)

        #expect(mapped.run(using: &rng) == "1")
        #expect(mapped.run(using: &rng) == "7")
    }
        
    @Test func mapChaining() {
        // Test the optimized map chaining method on RandomGenerators.Map
        let intGenerator = IntGenerator<Int>(in: 0...10)
        
        // Create a map generator
        let doubledGenerator = intGenerator.map { $0 * 2 }
        
        // Chain another map transformation using the optimized method
        let formattedGenerator = doubledGenerator.map { "Value: \($0)" }
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 1)
        
        // Verify the results
        #expect(formattedGenerator(using: &rng) == "Value: 2")
        #expect(formattedGenerator(using: &rng) == "Value: 14")
    }
    
    @Test func multipleMapChaining() {
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
        #expect(result.run(using: &rng) == "Result: 12")
        #expect(result.run(using: &rng) == "Result: 24")
    }
    
    @Test func mapWithComplexTransformations() {
        // Test map with more complex transformations
        let tupleGenerator = IntGenerator<Int>(in: 1...10).tuple()
        
        // Map the tuple to a formatted string
        let formattedGenerator = tupleGenerator.map { tuple in
            "Coordinates: (\(tuple.0), \(tuple.1))"
        }
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 1)
        
        // Verify the results
        #expect(formattedGenerator.run(using: &rng) == "Coordinates: (2, 7)")
        #expect(formattedGenerator.run(using: &rng) == "Coordinates: (9, 1)")
    }
}
