import XCTest
import SwiftRandomKit

final class DictionaryTests: XCTestCase {
    func testDictionaryWithFixedCount() {
        // Create a generator for key-value pairs
        let keyGen = ["name", "age", "score", "level"].randomGeneratorElement()
        let valueGen = IntGenerator(in: 1...100)
        let pairGen = keyGen.zip(valueGen)
        
        // Create a dictionary generator with fixed count of 3
        let dictGen = pairGen.dictionary(Always(3))
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 42)
        let result = dictGen.run(using: &rng)
        
        // With seed 42, we can predict the exact output
        let expectedDict = ["score": 76, "name": 24]
        XCTAssertEqual(result, expectedDict)
        
        // Run again with the same seed to verify determinism
        var rng2 = LCRNG(seed: 42)
        let result2 = dictGen.run(using: &rng2)
        XCTAssertEqual(result, result2)
    }
    
    func testDictionaryWithVariableCount() {
        // Create a generator for key-value pairs
        let keyGen = ["name", "age", "score", "level"].randomGeneratorElement()
        let valueGen = IntGenerator(in: 1...100)
        let pairGen = keyGen.zip(valueGen)
        
        // Create a dictionary generator with variable count
        let countGen = IntGenerator(in: 1...4)
        let dictGen = pairGen.dictionary(countGen)
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 42)
        let result = dictGen.run(using: &rng)
        
        // With seed 42, we can predict the exact output
        // IntGenerator(1...4) with seed 42 produces 2
        // So we'll get 2 key-value pairs
        let expectedDict = ["name": 67, "level": 13]
        XCTAssertEqual(result, expectedDict)
    }
    
    func testDictionaryWithDuplicateKeys() {
        // Create a generator that always produces the same key but different values
        let keyGen = Always("key")
        let valueGen = IntGenerator(in: 1...100)
        let pairGen = keyGen.zip(valueGen)
        
        // Create a dictionary generator with count of 3
        let dictGen = pairGen.dictionary(Always(3))
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 42)
        let result = dictGen.run(using: &rng)
        
        // Since all keys are the same, the dictionary should have only one entry
        // The last value generated will be kept
        let expectedDict = ["key": 59]
        XCTAssertEqual(result, expectedDict)
    }
    
    func testEmptyDictionary() {
        // Create a generator for key-value pairs
        let keyGen = ["name", "age", "score", "level"].randomGeneratorElement()
        let valueGen = IntGenerator(in: 1...100)
        let pairGen = keyGen.zip(valueGen)
        
        // Create a dictionary generator with count of 0
        let dictGen = pairGen.dictionary(Always(0))
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 42)
        let result = dictGen.run(using: &rng)
        
        // The dictionary should be empty
        XCTAssertEqual(result, [:])
    }
} 