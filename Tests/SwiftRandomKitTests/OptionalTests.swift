import Testing
import SwiftRandomKit

struct OptionalTests {
    @Test func optionalInt() {
        // Create an optional integer generator
        let intGenerator = IntGenerator(in: 1...6)
        let optionalGenerator = intGenerator.optional()
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 42)
        let result = optionalGenerator.run(using: &rng)
        
        // With seed 42, IntGenerator(1...6) produces 4
        #expect(result == 4)
        
        // Run again with the same seed to verify determinism
        var rng2 = LCRNG(seed: 42)
        let result2 = optionalGenerator.run(using: &rng2)
        #expect(result == result2)
        
        // Generate a sequence of values and verify they match expected values
        let expectedSequence = [6, 4, 5, 1, 2, 4, 6, 6, 1]
        for expected in expectedSequence {
            let value = optionalGenerator.run(using: &rng)
            #expect(value == expected)
        }
    }
    
    @Test func optionalString() {
        // Create an optional string generator
        let stringGenerator = ["apple", "banana", "cherry"].randomGeneratorElement()
        let optionalGenerator = stringGenerator.optional()
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 42)
        let result = optionalGenerator.run(using: &rng)
        
        // With seed 42, we should get "banana"
        #expect(result == "banana")
        
        // Generate a sequence of values and verify they match expected values
        let expectedSequence = ["cherry", "banana", "cherry", "apple"]
        for expected in expectedSequence {
            let value = optionalGenerator.run(using: &rng)
            #expect(value == expected)
        }
    }
    
    @Test func optionalTuple() {
        // Create an optional tuple generator
        let tupleGenerator = IntGenerator(in: 0...100).tuple()
        let optionalGenerator = tupleGenerator.optional()
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 42)
        let result = optionalGenerator.run(using: &rng)
        
        // With seed 42, we should get (52, 100)
        #expect(result?.0 == 52)
        #expect(result?.1 == 100)
        
        // Run again with the same seed to verify determinism
        var rng2 = LCRNG(seed: 42)
        let result2 = optionalGenerator.run(using: &rng2)
        #expect(result2?.0 == 52)
        #expect(result2?.1 == 100)
    }
    
    @Test func optionalInChain() {
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
        #expect(result == 12)
        
        // Generate a sequence of values and verify they match expected values
        let expectedSequence = [20, 12, 16, 4, 6, 14, 18, 20, 2]
        for expected in expectedSequence {
            let value = generator.run(using: &rng)
            #expect(value == expected)
        }
    }

    // MARK: - OrNil

    @Test func orNilNeverNilAtZeroProbability() {
        var rng = LCRNG(seed: 1)
        let generator = IntGenerator(in: 1...100).orNil(probability: 0)

        for _ in 0..<50 {
            #expect(generator.run(using: &rng) != nil)
        }
    }

    @Test func orNilAlwaysNilAtFullProbability() {
        var rng = LCRNG(seed: 1)
        let generator = IntGenerator(in: 1...100).orNil(probability: 1)

        for _ in 0..<50 {
            #expect(generator.run(using: &rng) == nil)
        }
    }

    @Test func orNilMixesNilAndValues() {
        var rng = LCRNG(seed: 42)
        let generator = IntGenerator(in: 1...100).orNil(probability: 0.5)

        var nils = 0
        var values = 0
        for _ in 0..<200 {
            if generator.run(using: &rng) == nil { nils += 1 } else { values += 1 }
        }

        // Loose statistical bounds around 50/50
        #expect(nils > 50)
        #expect(values > 50)
    }

    @Test func orNilIsDeterministic() {
        var rng1 = LCRNG(seed: 42)
        var rng2 = LCRNG(seed: 42)
        let generator = IntGenerator(in: 1...100).orNil(probability: 0.5)

        for _ in 0..<20 {
            #expect(generator.run(using: &rng1) == generator.run(using: &rng2))
        }
    }
} 