import XCTest
@testable import SwiftRandomKit

final class ShuffledTests: XCTestCase {
    
    // MARK: - Basic Shuffling
    
    func testBasicShuffling() {
        // Create a generator with a fixed array
        let originalArray = [1, 2, 3, 4, 5]
        let numbers = RandomGenerators.Always(originalArray)
        
        // Create a shuffled generator
        let shuffled = numbers.shuffled()
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 1)
        
        // Run the shuffle operation several times
        let result1 = shuffled.run(using: &rng)
        let result2 = shuffled.run(using: &rng)
        let result3 = shuffled.run(using: &rng)


        // Verify properties that should hold after shuffling:
        // 1. The shuffled array should have the same length
        XCTAssertEqual(result1.count, originalArray.count)
        XCTAssertEqual(result2.count, originalArray.count)
        XCTAssertEqual(result3.count, originalArray.count)

        // Verify that the shuffled result contains all the original elements in a different order
        XCTAssertEqual(result1, [1,4,5,2,3])
        XCTAssertEqual(result2, [2,1,5,3,4])
        XCTAssertEqual(result3, [3,5,4,1,2])

        // 3. Different calls should produce different shuffles
        XCTAssertNotEqual(result1, result2)
        XCTAssertNotEqual(result2, result3)
        XCTAssertNotEqual(result1, result3)
    }
    
    func testShufflingEmptyArray() {
        // Create a generator with an empty array
        let emptyArray = RandomGenerators.Always([Int]())
        
        // Create a shuffled generator
        let shuffled = emptyArray.shuffled()
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 1)
        
        // Shuffling an empty array should return an empty array
        let result = shuffled.run(using: &rng)
        
        XCTAssertEqual(result, [])
    }
    
    func testShufflingSingleElementArray() {
        // Create a generator with a single-element array
        let singleElement = RandomGenerators.Always([42])
        
        // Create a shuffled generator
        let shuffled = singleElement.shuffled()
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 1)
        
        // Shuffling a single-element array should return the same array
        let result = shuffled.run(using: &rng)
        
        XCTAssertEqual(result, [42])
    }
    
    // MARK: - Complex Shuffling
    
    func testShufflingWithArrayGenerator() {
        // Create some distinct arrays to better test shuffling
        let array1 = [1, 2, 3]
        let array2 = [4, 5, 6]
        let array3 = [7, 8, 9]
        let arrays = [array1, array2, array3]
        
        // Create a generator that always returns this array of arrays
        let arrayGen = RandomGenerators.Always(arrays)
        
        // Create a shuffled generator to shuffle the outer array
        let shuffled = arrayGen.shuffled()
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 1)
        
        // Get the shuffled result
        let result = shuffled.run(using: &rng)
        
        // Verify that we got an array of arrays
        XCTAssertEqual(result.count, arrays.count)

        // Verify result is different from original order
        XCTAssertEqual(result, [[1,2,3], [7,8,9], [4,5,6]])
        
        // If the arrays are distinct, and the result is different from the original order,
        // then shuffling occurred
        XCTAssertNotEqual(result, arrays, "Arrays should have been shuffled")
    }
    
    func testShufflingStrings() {
        // Create a generator with a fixed string (treated as [Character])
        let originalString = "hello"
        let stringGen = RandomGenerators.Always(originalString.map { $0 })
        
        // Create a shuffled generator
        let shuffled = stringGen.shuffled()
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 1)
        
        // Get the shuffled result
        let result1 = shuffled.run(using: &rng)
        let result2 = shuffled.run(using: &rng)
        
        // Convert characters back to strings for easier assertion
        let resultString1 = String(result1)
        let resultString2 = String(result2)

        // Verify result is different from original order
        XCTAssertEqual(resultString1, "hloel")
        XCTAssertEqual(resultString2, "eholl")
    }
}
