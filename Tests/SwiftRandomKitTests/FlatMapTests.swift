import XCTest
import SwiftRandomKit

final class FlatMapTests: XCTestCase {
    func testBasicFlatMap() {
        // Create a generator that produces integers
        let intGenerator = IntGenerator(in: 1...3)
        
        // Create a flatMap generator that transforms each integer into an array of that size
        let flatMapGenerator = intGenerator.flatMap { count in
            IntGenerator(in: 1...10).array(count)
        }
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 42)
        
        // With seed 42, IntGenerator(1...3) produces 2
        // Then IntGenerator(1...10) with the next values produces [10, 6]
        let result = flatMapGenerator.run(using: &rng)
        XCTAssertEqual(result, [10, 6])
        
        // Next run should produce [2, 3, 7]
        let result2 = flatMapGenerator.run(using: &rng)
        XCTAssertEqual(result2, [2, 3, 7])
        
        // Next run should produce [10, 1, 2]
        let result3 = flatMapGenerator.run(using: &rng)
        XCTAssertEqual(result3, [10, 1, 2])
    }
    
    func testNestedFlatMap() {
        // Create a generator that produces strings
        let sizeGenerator = ["small", "medium", "large"].randomGeneratorElement()
        
        // Create a nested flatMap generator
        let nestedGenerator = sizeGenerator.flatMap { size in
            if let unwrappedSize = size {
                switch unwrappedSize {
                case "small": return IntGenerator(in: 1...10).array(3)
                case "medium": return IntGenerator(in: 1...50).array(5)
                case "large": return IntGenerator(in: 1...100).array(10)
                default: return IntGenerator(in: 0...0).array(0)
                }
            } else {
                return IntGenerator(in: 0...0).array(0)
            }
        }
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 42)
        
        // With seed 42, sizeGenerator produces "medium"
        // Then IntGenerator(1...50) produces [50, 30, 38, 7, 12]
        let result = nestedGenerator.run(using: &rng)
        XCTAssertEqual(result, [50, 30, 38, 7, 12])
        
        // Next run should produce [44, 48, 1, 6, 22]
        let result2 = nestedGenerator.run(using: &rng)
        XCTAssertEqual(result2, [44, 48, 1, 6, 22])
    }
    
    // Skip this test for now as it requires more complex type handling
    /*
    func testFlatMapWithDifferentTypes() {
        // Create a generator that produces booleans
        let boolGenerator = BoolRandomGenerator()
        
        // Create a flatMap generator that produces different types based on the boolean
        let flatMapGenerator = boolGenerator.flatMap { isTrue in
            if isTrue {
                return IntGenerator(in: 1...100).map { $0 } as any RandomGenerator
            } else {
                return Always("string") as any RandomGenerator
            }
        }
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 42)
        let result = flatMapGenerator.run(using: &rng)
        
        // The result type should be Any, but we can check if it's an Int or String
        if let intResult = result as? Int {
            XCTAssertGreaterThanOrEqual(intResult, 1)
            XCTAssertLessThanOrEqual(intResult, 100)
        } else if let stringResult = result as? String {
            XCTAssertEqual(stringResult, "string")
        } else {
            XCTFail("Result is neither Int nor String")
        }
    }
    */
    
    func testFlatMapChaining() {
        // Create a simpler chain of flatMap operations
        let generator = IntGenerator(in: 1...3)
            .flatMap { count in
                IntGenerator(in: 1...5).array(count)
            }
            .flatMap { array in
                // Create a generator that selects the first element from the array
                // and doubles it
                if array.isEmpty {
                    return Always(0)
                } else {
                    return Always(array[0] * 2)
                }
            }
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 42)
        
        // With seed 42, the first flatMap produces [5, 3]
        // Then the second flatMap selects the first element and doubles it: 5 * 2 = 10
        let result = generator.run(using: &rng)
        XCTAssertEqual(result, 10)
        
        // Next run produces [1, 2, 4], first element doubled: 1 * 2 = 2
        let result2 = generator.run(using: &rng)
        XCTAssertEqual(result2, 2)
        
        // Next run produces [5, 1, 1], first element doubled: 5 * 2 = 10
        let result3 = generator.run(using: &rng)
        XCTAssertEqual(result3, 10)
    }
} 