import Testing
@testable import SwiftRandomKit

struct ArrayTests {
    
    @Test func fixedSizeArrayGenerator() {
        // Test the array() extension that creates fixed-size arrays
        var rng = LCRNG(seed: 42)
        
        // Test with integers
        let intGen = IntGenerator(in: 1...10)
        let intArrayGen = intGen.array(5)
        
        // Verify the output - with seed 42, we should get deterministic results
        let intArray = intArrayGen.run(using: &rng)
        #expect(intArray.count == 5, "Array should have exactly 5 elements")
        #expect(intArray == [6, 10, 6, 8, 2], "With seed 42, we should get specific values")
        
        // Test with a different size
        let largerIntArrayGen = intGen.array(10)
        let largerIntArray = largerIntArrayGen.run(using: &rng)
        #expect(largerIntArray.count == 10, "Array should have exactly 10 elements")
        #expect(largerIntArray == [3, 7, 9, 10, 1, 2, 5, 8, 4, 1], "With seed 42 (continued), we should get specific values")
    }
    
    @Test func fixedSizeWithStrings() {
        // Test fixed-size array generator with strings
        var rng = LCRNG(seed: 42)
        
        // Create a string generator using alphanumeric characters
        let charGen = RandomGenerators.letterOrNumber
        let stringArrayGen = charGen.array(8)
        
        // Verify the output
        let stringArray = stringArrayGen.run(using: &rng)
        #expect(stringArray.count == 8, "Array should have exactly 8 elements")
        #expect(stringArray == ["G", "9", "K", "U", "h", "o", "P", "2"], "With seed 42, we should get specific characters")
        
        // Test with a different random seed to ensure different results
        var rng2 = LCRNG(seed: 123)
        let differentStringArray = stringArrayGen.run(using: &rng2)
        #expect(differentStringArray.count == 8, "Array should have exactly 8 elements")
        #expect(differentStringArray != stringArray, "Different seeds should produce different arrays")
    }
    
    @Test func zeroSizeArray() {
        // Test edge case: array with zero elements
        var rng = LCRNG(seed: 42)
        
        let intGen = IntGenerator(in: 1...100)
        let emptyArrayGen = intGen.array(0)
        
        let emptyArray = emptyArrayGen.run(using: &rng)
        #expect(emptyArray.count == 0, "Array should be empty")
        #expect(emptyArray == [], "Empty array should be returned")
    }
    
    @Test func arrayWithNestedGenerators() {
        // Test array generator with nested generators
        var rng = LCRNG(seed: 42)
        
        // Create a generator that produces arrays of arrays
        let innerArrayGen = IntGenerator(in: 1...5).array(3)
        let nestedArrayGen = innerArrayGen.array(2)
        
        // Test the output
        let nestedArray = nestedArrayGen.run(using: &rng)
        #expect(nestedArray.count == 2, "Outer array should have 2 elements")
        #expect(nestedArray[0].count == 3, "Inner arrays should have 3 elements")
        #expect(nestedArray[1].count == 3, "Inner arrays should have 3 elements")
        
        // Check exact values with seed 42
        #expect(nestedArray[0] == [3, 5, 3], "First inner array should have expected values")
        #expect(nestedArray[1] == [4, 1, 2], "Second inner array should have expected values")
    }
    
    @Test func variableSizeArrayGenerator() {
        // Test the arrayGenerator() extension that creates variable-size arrays
        var rng = LCRNG(seed: 42)
        
        // Create a generator with variable size
        let elementGen = IntGenerator(in: 1...10)
        let sizeGen = IntGenerator(in: 3...7)
        let variableSizeGen = elementGen.arrayGenerator(sizeGen)
        
        // With seed 42, the size generator should produce a specific size
        let array1 = variableSizeGen.run(using: &rng)
        #expect(array1.count == 5, "With seed 42, the size should be 5")
        #expect(array1 == [10, 6, 8, 2, 3], "Array content should match expected values")
        
        // Run it again to get a different size
        let array2 = variableSizeGen.run(using: &rng)
        #expect(array2.count == 6, "Second run with seed 42 should produce size 6")
        #expect(array2 == [9, 10, 1, 2, 5, 8], "Array content should match expected values")
    }
    
    @Test func variableSizeEdgeCases() {
        // Test edge cases for variable size array generator
        var rng = LCRNG(seed: 42)
        
        // Test with zero size possibility
        let elementGen = IntGenerator(in: 1...10)
        let zeroSizeGen = IntGenerator(in: 0...3)
        let maybeEmptyGen = elementGen.arrayGenerator(zeroSizeGen)
        
        // With seed 42, test the size
        let array1 = maybeEmptyGen.run(using: &rng)
        #expect(array1.count == 2, "With seed 42, the size should be 2")
        #expect(array1 == [10, 6], "Array content should match expected values")
        
        // Create a size generator that always returns zero
        let alwaysZeroGen = Always(0)
        let definitelyEmptyGen = elementGen.arrayGenerator(alwaysZeroGen)
        
        let emptyArray = definitelyEmptyGen.run(using: &rng)
        #expect(emptyArray.count == 0, "With zero size, array should be empty")
        #expect(emptyArray == [], "Empty array should be returned")
        
        // Test with negative size (should result in empty array)
        let negativeGen = Always(-5)
        let negativeArrayGen = elementGen.arrayGenerator(negativeGen)
        
        let negativeArray = negativeArrayGen.run(using: &rng)
        #expect(negativeArray.count == 0, "With negative size, array should be empty")
        #expect(negativeArray == [], "Empty array should be returned")
    }
    
    @Test func arrayWithMapTransformation() {
        // Test combining array generator with map transformation
        var rng = LCRNG(seed: 42)
        
        // Create a generator that produces arrays of integers and maps them to strings
        let intGen = IntGenerator(in: 1...10)
        let arrayGen = intGen.array(5)
        let stringArrayGen = arrayGen.map { intArray in
            return intArray.map { "Value: \($0)" }
        }
        
        // Test the output
        let stringArray = stringArrayGen.run(using: &rng)
        #expect(stringArray.count == 5, "Array should have 5 elements")
        #expect(stringArray == [
            "Value: 6",
            "Value: 10",
            "Value: 6",
            "Value: 8",
            "Value: 2"
        ], "Mapped values should match expected output")
    }
} 
