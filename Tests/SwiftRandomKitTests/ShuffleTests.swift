import XCTest
import SwiftRandomKit

final class ShuffleTests: XCTestCase {
    
    func testShuffleArray() {
        // Given a fixed array, test that shuffle produces different permutations
        let fixedArray = [1, 2, 3, 4, 5]
        
        var rng1 = LCRNG(seed: 1)
        var rng2 = LCRNG(seed: 2)
        
        // Two different RNGs should produce different shuffles
        let shuffle1 = fixedArray.shuffled(using: &rng1)
        let shuffle2 = fixedArray.shuffled(using: &rng2)
        
        // Test exact expected output for seed 1
        XCTAssertEqual(shuffle1, [1, 4, 5, 2, 3], "Shuffle with seed 1 should produce expected permutation")
        
        // Test exact expected output for seed 2
        XCTAssertEqual(shuffle2, [2, 5, 1, 3, 4], "Shuffle with seed 2 should produce expected permutation")
        
        // The arrays should contain the same elements but in different orders
        XCTAssertNotEqual(shuffle1, shuffle2, "Different seeds should produce different shuffles")
        XCTAssertEqual(shuffle1.sorted(), fixedArray, "Shuffled array should contain the same elements")
        XCTAssertEqual(shuffle2.sorted(), fixedArray, "Shuffled array should contain the same elements")
    }
    
    func testShuffleDeterministic() {
        // Tests that shuffle is deterministic when using the same seed
        let fixedArray = ["a", "b", "c", "d", "e"]
        
        var rng1 = LCRNG(seed: 42)
        var rng2 = LCRNG(seed: 42)
        
        let shuffle1 = fixedArray.shuffled(using: &rng1)
        let shuffle2 = fixedArray.shuffled(using: &rng2)
        
        // Test exact expected output for seed 42
        XCTAssertEqual(shuffle1, ["c", "e", "d", "b", "a"], "Shuffle with seed 42 should produce expected permutation")
        
        // Same seed should produce the same shuffle
        XCTAssertEqual(shuffle1, shuffle2, "Same seed should produce same shuffle")
    }
    
    func testShuffleEmptyArray() {
        // Shuffling an empty array should return an empty array
        let emptyArray: [Int] = []
        
        var rng = LCRNG(seed: 1)
        let shuffled = emptyArray.shuffled(using: &rng)
        
        XCTAssertEqual(shuffled, [], "Shuffling empty array should return empty array")
    }
    
    func testShuffleSingleElement() {
        // Shuffling an array with a single element should return the same array
        let singleElementArray = ["singleElement"]
        
        var rng = LCRNG(seed: 1)
        let shuffled = singleElementArray.shuffled(using: &rng)
        
        XCTAssertEqual(shuffled, singleElementArray, "Shuffling single element array should return same array")
    }
    
    func testShuffleInPlace() {
        // Test that shuffle(using:) modifies the array in place
        var array = [1, 2, 3, 4, 5]
        let originalArray = array
        
        var rng = LCRNG(seed: 1)
        array.shuffle(using: &rng)
        
        // Test exact expected output after in-place shuffle with seed 1
        XCTAssertEqual(array, [1, 4, 5, 2, 3], "In-place shuffle with seed 1 should produce expected permutation")
        
        // The array should be modified in place and have a different order
        XCTAssertNotEqual(array, originalArray, "Array should be modified in place")
        XCTAssertEqual(array.sorted(), originalArray, "Shuffled array should contain same elements")
    }
    
    func testShuffleLargeArray() {
        // Test shuffling a large array to ensure performance and randomness
        let largeArray = Array(1...100)
        
        var rng = LCRNG(seed: 7)
        let shuffled = largeArray.shuffled(using: &rng)
        
        // Verify specific expected positions for a subset of elements with seed 7
        XCTAssertEqual(shuffled[0], 9, "First element should be 9 with seed 7")
        XCTAssertEqual(shuffled[1], 17, "Second element should be 17 with seed 7")
        XCTAssertEqual(shuffled[2], 98, "Third element should be 98 with seed 7")
        XCTAssertEqual(shuffled[99], 52, "Last element should be 52 with seed 7")
        
        // The shuffled array should not match the original for large arrays
        XCTAssertNotEqual(shuffled, largeArray, "Large array should be shuffled")
        XCTAssertEqual(shuffled.sorted(), largeArray, "Shuffled array should contain same elements")
        
        // Check that the array is well-shuffled by ensuring runs of original order are limited
        // Count consecutive elements that maintained their original position
        var consecutiveMatches = 0
        var maxConsecutiveMatches = 0
        
        for i in 0..<shuffled.count {
            if shuffled[i] == i + 1 {
                consecutiveMatches += 1
            } else {
                maxConsecutiveMatches = max(maxConsecutiveMatches, consecutiveMatches)
                consecutiveMatches = 0
            }
        }
        maxConsecutiveMatches = max(maxConsecutiveMatches, consecutiveMatches)
        
        // With seed 7, we should know the exact value of maxConsecutiveMatches
        XCTAssertEqual(maxConsecutiveMatches, 0, "With seed 7, max consecutive matches should be 0")
    }
} 