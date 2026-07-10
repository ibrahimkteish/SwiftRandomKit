import Testing
@testable import SwiftRandomKit

struct ShuffledTests {
    
    // MARK: - Basic Shuffling
    
    @Test func basicShuffling() {
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
        #expect(result1.count == originalArray.count)
        #expect(result2.count == originalArray.count)
        #expect(result3.count == originalArray.count)

        // Verify that the shuffled result contains all the original elements in a different order
        #expect(result1 == [1,4,5,2,3])
        #expect(result2 == [2,1,5,3,4])
        #expect(result3 == [3,5,4,1,2])

        // 3. Different calls should produce different shuffles
        #expect(result1 != result2)
        #expect(result2 != result3)
        #expect(result1 != result3)
    }
    
    @Test func shufflingEmptyArray() {
        // Create a generator with an empty array
        let emptyArray = RandomGenerators.Always([Int]())
        
        // Create a shuffled generator
        let shuffled = emptyArray.shuffled()
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 1)
        
        // Shuffling an empty array should return an empty array
        let result = shuffled.run(using: &rng)
        
        #expect(result == [])
    }
    
    @Test func shufflingSingleElementArray() {
        // Create a generator with a single-element array
        let singleElement = RandomGenerators.Always([42])
        
        // Create a shuffled generator
        let shuffled = singleElement.shuffled()
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 1)
        
        // Shuffling a single-element array should return the same array
        let result = shuffled.run(using: &rng)
        
        #expect(result == [42])
    }
    
    // MARK: - Complex Shuffling
    
    @Test func shufflingWithArrayGenerator() {
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
        #expect(result.count == arrays.count)

        // Verify result is different from original order
        #expect(result == [[1,2,3], [7,8,9], [4,5,6]])
        
        // If the arrays are distinct, and the result is different from the original order,
        // then shuffling occurred
        #expect(result != arrays, "Arrays should have been shuffled")
    }
    
    @Test func shufflingStrings() {
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
        #expect(resultString1 == "hloel")
        #expect(resultString2 == "eholl")
    }
}
