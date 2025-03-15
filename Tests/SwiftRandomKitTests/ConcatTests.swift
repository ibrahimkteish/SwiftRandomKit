import XCTest
@testable import SwiftRandomKit

final class ConcatTests: XCTestCase {
    
    func testConcatStrings() {
        // Test concatenation of string generators
        var rng = LCRNG(seed: 42)
        
        let firstNameGen = Always("John")
        let lastNameGen = Always("Smith")
        
        // Test with a space separator
        let fullNameGen = firstNameGen.concat(lastNameGen, separator: " ")
        XCTAssertEqual(fullNameGen.run(using: &rng), "John Smith", "String concatenation with space separator should work")
        
        // Test with a different separator
        let hyphenatedNameGen = firstNameGen.concat(lastNameGen, separator: "-")
        XCTAssertEqual(hyphenatedNameGen.run(using: &rng), "John-Smith", "String concatenation with hyphen separator should work")
        
        // Test with an empty separator
        let noSeparatorGen = firstNameGen.concat(lastNameGen, separator: "")
        XCTAssertEqual(noSeparatorGen.run(using: &rng), "JohnSmith", "String concatenation with empty separator should work")
    }
    
    func testConcatWithVariableGenerators() {
        // Test concatenation with generators that produce different values
        var rng = LCRNG(seed: 42)
        
        // Create a generator that switches between two fixed values
        var usedFirst = false
        let adjectiveGen = AnyRandomGenerator<String> { _ in
            if !usedFirst {
                usedFirst = true
                return "Wise"
            } else {
                return "Bold"
            }
        }
        
        var usedFirstNoun = false
        let nounGen = AnyRandomGenerator<String> { _ in
            if !usedFirstNoun {
                usedFirstNoun = true
                return "Developer"
            } else {
                return "Engineer"
            }
        }
        
        // Combine them with concatenation
        let titleGen = adjectiveGen.flatMap { adj in
            return nounGen.map { noun in
                return adj + " " + noun
            }
        }
        
        // Expected results
        XCTAssertEqual(titleGen.run(using: &rng), "Wise Developer", "First concatenation should match expected value")
        XCTAssertEqual(titleGen.run(using: &rng), "Bold Engineer", "Second concatenation should match expected value")
    }
    
    func testConcatArrays() {
        // Test concatenation of array generators
        var rng = LCRNG(seed: 42)
        
        let firstArrayGen = Always([1, 2, 3])
        let secondArrayGen = Always([4, 5, 6])
        
        // Test with no separator
        let combinedArrayGen = firstArrayGen.concat(secondArrayGen, separator: [])
        XCTAssertEqual(combinedArrayGen.run(using: &rng), [1, 2, 3, 4, 5, 6], "Array concatenation with empty separator should work")
        
        // Test with a separator array
        let separatedArrayGen = firstArrayGen.concat(secondArrayGen, separator: [0])
        XCTAssertEqual(separatedArrayGen.run(using: &rng), [1, 2, 3, 0, 4, 5, 6], "Array concatenation with separator should work")
        
        // Test with multiple elements in separator
        let multiSeparatorArrayGen = firstArrayGen.concat(secondArrayGen, separator: [99, 100])
        XCTAssertEqual(multiSeparatorArrayGen.run(using: &rng), [1, 2, 3, 99, 100, 4, 5, 6], "Array concatenation with multi-element separator should work")
    }
    
    func testConcatWithMap() {
        // Test combining concat with map
        var rng = LCRNG(seed: 42)
        
        let numGen1 = IntGenerator(in: 1...10)
        let numGen2 = IntGenerator(in: 11...20)
        
        // Map the integers to strings before concatenation
        let numStringGen1 = numGen1.map { String($0) }
        let numStringGen2 = numGen2.map { String($0) }
        
        let combinedNumGen = numStringGen1.concat(numStringGen2, separator: "+")
        
        // Expected value using deterministic RNG (seed 42)
        XCTAssertEqual(combinedNumGen.run(using: &rng), "6+20", "Concatenation with mapped values should work")
        XCTAssertEqual(combinedNumGen.run(using: &rng), "6+18", "Second run should produce expected values")
    }
    
    func testConcatWithDynamicSeparator() {
        // Test using different separators dynamically
        var rng = LCRNG(seed: 42)
        
        let wordGen1 = Always("hello")
        let wordGen2 = Always("world")
        
        // Create a custom generator that alternates between separators
        var usedFirst = false
        let separatorGen = AnyRandomGenerator<String> { _ in
            if !usedFirst {
                usedFirst = true
                return ":"
            } else {
                return "-"
            }
        }
        
        // Use flatMap to dynamically choose a separator
        let dynamicSeparatorGen = separatorGen.flatMap { sep in
            return wordGen1.concat(wordGen2, separator: sep)
        }
        
        // Expected values
        XCTAssertEqual(dynamicSeparatorGen.run(using: &rng), "hello:world", "First run should use the expected separator")
        XCTAssertEqual(dynamicSeparatorGen.run(using: &rng), "hello-world", "Second run should use a different separator")
    }
    
    func testConcatMultipleGenerators() {
        // Test chaining multiple concatenations
        var rng = LCRNG(seed: 42)
        
        let gen1 = Always("begin")
        let gen2 = Always("middle")
        let gen3 = Always("end")
        
        // Chain the concatenations
        let chainedGen = gen1
            .concat(gen2, separator: "-")
            .concat(gen3, separator: "-")
        
        XCTAssertEqual(chainedGen.run(using: &rng), "begin-middle-end", "Chained concatenation should work correctly")
        
        // Different pattern of chaining
        let nestedGen = gen1.concat(
            gen2.concat(gen3, separator: "."),
            separator: "/"
        )
        
        XCTAssertEqual(nestedGen.run(using: &rng), "begin/middle.end", "Nested concatenation should respect the grouping")
    }
    
    func testConcatWithDifferentTypes() {
        // Test concat with different concatable types
        var rng = LCRNG(seed: 42)
        
        // Test with Data
        let data1Gen = Always(Data([0x01, 0x02]))
        let data2Gen = Always(Data([0x03, 0x04]))
        
        let combinedDataGen = data1Gen.concat(data2Gen, separator: Data())
        let result = combinedDataGen.run(using: &rng)
        
        // Check the result as array of bytes
        let byteArray = [UInt8](result)
        XCTAssertEqual(byteArray, [0x01, 0x02, 0x03, 0x04], "Data concatenation should work correctly")
        
        // Test with separator
        let separatorDataGen = data1Gen.concat(data2Gen, separator: Data([0xFF]))
        let separatedResult = separatorDataGen.run(using: &rng)
        
        // Check the result with separator
        let separatedByteArray = [UInt8](separatedResult)
        XCTAssertEqual(separatedByteArray, [0x01, 0x02, 0xFF, 0x03, 0x04], "Data concatenation with separator should work correctly")
    }
    
    func testConcatPerformance() {
        // Test the performance of the concat operation
        let stringGen1 = Always("performance")
        let stringGen2 = Always("test")
        
        let concatGen = stringGen1.concat(stringGen2, separator: "-")
        
        measure {
            var rng = LCRNG(seed: 42)
            
            // Generate values multiple times to measure performance
            for _ in 0..<1000 {
                _ = concatGen.run(using: &rng)
            }
        }
    }
} 