import XCTest
@testable import SwiftRandomKit

final class CharacterTests: XCTestCase {
    
    func testCharacterInRange() {
        // Test character generation within a range
        var rng = LCRNG(seed: 42)
        
        // Test with lowercase letters range
        let lowercaseRange = Character("a")...Character("z")
        let lowercaseGen = RandomGenerators.character(in: lowercaseRange)
        
        // With seed 42, we should get deterministic values
        let char1 = lowercaseGen.run(using: &rng)
        let char2 = lowercaseGen.run(using: &rng)
        let char3 = lowercaseGen.run(using: &rng)
        
        XCTAssertEqual(char1, "z", "First character with seed 42 should be 'z'")
        XCTAssertEqual(char2, "z", "Second character with seed 42 should be 'z'")
        XCTAssertEqual(char3, "z", "Third character with seed 42 should be 'z'")
        
        // Test with digit range
        let digitRange = Character("0")...Character("9")
        let digitGen = RandomGenerators.character(in: digitRange)
        
        let digit1 = digitGen.run(using: &rng)
        let digit2 = digitGen.run(using: &rng)
        
        XCTAssertEqual(digit1, "9", "First digit with seed 42 should be '9'")
        XCTAssertEqual(digit2, "9", "Second digit with seed 42 should be '9'")
        
        // Make sure characters are within the range
        for _ in 1...20 {
            let char = lowercaseGen.run(using: &rng)
            XCTAssertGreaterThanOrEqual(char, Character("a"), "Character should be >= 'a'")
            XCTAssertLessThanOrEqual(char, Character("z"), "Character should be <= 'z'")
        }
    }
    
    func testNumberGenerator() {
        // Test the number character generator (0-9)
        var rng = LCRNG(seed: 42)
        
        let numberGen = RandomGenerators.number
        
        // Test deterministic sequence with seed 42
        let digit1 = numberGen.run(using: &rng)
        let digit2 = numberGen.run(using: &rng)
        let digit3 = numberGen.run(using: &rng)
        
        XCTAssertEqual(digit1, "9", "First digit with seed 42 should be '9'")
        XCTAssertEqual(digit2, "9", "Second digit with seed 42 should be '9'")
        XCTAssertEqual(digit3, "9", "Third digit with seed 42 should be '9'")
        
        // Verify all outputs are digits
        for _ in 1...20 {
            let digit = numberGen.run(using: &rng)
            XCTAssertTrue((Character("0")...Character("9")).contains(digit), "Character should be a digit (0-9)")
        }
    }
    
    func testUppercaseLetterGenerator() {
        // Test the uppercase letter generator (A-Z)
        var rng = LCRNG(seed: 42)
        
        let uppercaseGen = RandomGenerators.uppercaseLetter
        
        // Test deterministic sequence with seed 42
        let char1 = uppercaseGen.run(using: &rng)
        let char2 = uppercaseGen.run(using: &rng)
        let char3 = uppercaseGen.run(using: &rng)
        
        XCTAssertEqual(char1, "Z", "First uppercase letter with seed 42 should be 'Z'")
        XCTAssertEqual(char2, "Z", "Second uppercase letter with seed 42 should be 'Z'")
        XCTAssertEqual(char3, "Z", "Third uppercase letter with seed 42 should be 'Z'")
        
        // Verify all outputs are uppercase letters
        for _ in 1...20 {
            let letter = uppercaseGen.run(using: &rng)
            XCTAssertTrue((Character("A")...Character("Z")).contains(letter), "Character should be an uppercase letter (A-Z)")
        }
    }
    
    func testLowercaseLetterGenerator() {
        // Test the lowercase letter generator (a-z)
        var rng = LCRNG(seed: 42)
        
        let lowercaseGen = RandomGenerators.lowercaseLetter
        
        // Test deterministic sequence with seed 42
        let char1 = lowercaseGen.run(using: &rng)
        let char2 = lowercaseGen.run(using: &rng)
        let char3 = lowercaseGen.run(using: &rng)
        
        XCTAssertEqual(char1, "z", "First lowercase letter with seed 42 should be 'z'")
        XCTAssertEqual(char2, "z", "Second lowercase letter with seed 42 should be 'z'")
        XCTAssertEqual(char3, "z", "Third lowercase letter with seed 42 should be 'z'")
        
        // Verify all outputs are lowercase letters
        for _ in 1...20 {
            let letter = lowercaseGen.run(using: &rng)
            XCTAssertTrue((Character("a")...Character("z")).contains(letter), "Character should be a lowercase letter (a-z)")
        }
    }
    
    func testLetterGenerator() {
        // Test the letter generator (combines uppercase and lowercase)
        var rng = LCRNG(seed: 42)
        
        let letterGen = RandomGenerators.letter
        
        // Test deterministic sequence with seed 42
        let char1 = letterGen.run(using: &rng)
        let char2 = letterGen.run(using: &rng)
        let char3 = letterGen.run(using: &rng)
        
        XCTAssertEqual(char1, "A", "First letter with seed 42 should be 'A'")
        XCTAssertEqual(char2, "Z", "Second letter with seed 42 should be 'Z'")
        XCTAssertEqual(char3, "E", "Third letter with seed 42 should be 'E'")
        
        // Verify all outputs are letters
        for _ in 1...50 {
            let letter = letterGen.run(using: &rng)
            let isLetter = ((Character("a")...Character("z")).contains(letter) || 
                           (Character("A")...Character("Z")).contains(letter))
            XCTAssertTrue(isLetter, "Character should be a letter (a-z or A-Z)")
        }
        
        // Check distribution of letters over many iterations
        var rngForDistribution = LCRNG(seed: 123)
        var uppercaseCount = 0
        var lowercaseCount = 0
        let iterations = 1000
        
        for _ in 1...iterations {
            let letter = letterGen.run(using: &rngForDistribution)
            if (Character("A")...Character("Z")).contains(letter) {
                uppercaseCount += 1
            } else if (Character("a")...Character("z")).contains(letter) {
                lowercaseCount += 1
            }
        }
        
        // Should have a reasonable distribution between uppercase and lowercase
        XCTAssertGreaterThan(uppercaseCount, iterations / 10, "Should have a significant number of uppercase letters")
        XCTAssertGreaterThan(lowercaseCount, iterations / 10, "Should have a significant number of lowercase letters")
    }
    
    func testLetterOrNumberGenerator() {
        // Test the alphanumeric generator (a-z, A-Z, 0-9)
        var rng = LCRNG(seed: 42)
        
        let alphanumericGen = RandomGenerators.letterOrNumber
        
        // Test deterministic sequence with seed 42
        let char1 = alphanumericGen.run(using: &rng)
        let char2 = alphanumericGen.run(using: &rng)
        let char3 = alphanumericGen.run(using: &rng)
        
        XCTAssertEqual(char1, "G", "First alphanumeric char with seed 42 should be 'G'")
        XCTAssertEqual(char2, "9", "Second alphanumeric char with seed 42 should be '9'")
        XCTAssertEqual(char3, "K", "Third alphanumeric char with seed 42 should be 'K'")
        
        // Verify all outputs are alphanumeric
        for _ in 1...50 {
            let char = alphanumericGen.run(using: &rng)
            let isAlphanumeric = ((Character("a")...Character("z")).contains(char) || 
                                  (Character("A")...Character("Z")).contains(char) ||
                                  (Character("0")...Character("9")).contains(char))
            XCTAssertTrue(isAlphanumeric, "Character should be alphanumeric")
        }
        
        // Check distribution of character types over many iterations
        var rngForDistribution = LCRNG(seed: 123)
        var uppercaseCount = 0
        var lowercaseCount = 0
        var digitCount = 0
        let iterations = 1000
        
        for _ in 1...iterations {
            let char = alphanumericGen.run(using: &rngForDistribution)
            if (Character("A")...Character("Z")).contains(char) {
                uppercaseCount += 1
            } else if (Character("a")...Character("z")).contains(char) {
                lowercaseCount += 1
            } else if (Character("0")...Character("9")).contains(char) {
                digitCount += 1
            }
        }
        
        // Should have a reasonable distribution among all character types
        XCTAssertGreaterThan(uppercaseCount, iterations / 10, "Should have a significant number of uppercase letters")
        XCTAssertGreaterThan(lowercaseCount, iterations / 10, "Should have a significant number of lowercase letters")
        XCTAssertGreaterThan(digitCount, iterations / 10, "Should have a significant number of digits")
    }
    
    func testAsciiGenerator() {
        // Test the ASCII generator (0-127)
        var rng = LCRNG(seed: 42)
        
        let asciiGen = RandomGenerators.ascii
        
        // Test deterministic sequence with seed 42
        let char1 = asciiGen.run(using: &rng)
        let char2 = asciiGen.run(using: &rng)
        let char3 = asciiGen.run(using: &rng)
        
        // Get Unicode scalar values for verification
        let scalar1 = char1.unicodeScalars.first!.value
        let scalar2 = char2.unicodeScalars.first!.value
        let scalar3 = char3.unicodeScalars.first!.value
        
        XCTAssertEqual(scalar1, 124, "First ASCII char with seed 42 should have scalar value 124")
        XCTAssertEqual(scalar2, 23, "Second ASCII char with seed 42 should have scalar value 23")
        XCTAssertEqual(scalar3, 17, "Third ASCII char with seed 42 should have scalar value 17")
        
        // Verify all outputs are within ASCII range
        for _ in 1...50 {
            let char = asciiGen.run(using: &rng)
            let scalar = char.unicodeScalars.first!.value
            XCTAssertLessThanOrEqual(scalar, 127, "Character should be within ASCII range (0-127)")
        }
    }
    
    func testLatin1Generator() {
        // Test the Latin-1 generator (0-255)
        var rng = LCRNG(seed: 42)
        
        let latin1Gen = RandomGenerators.latin1
        
        // Test deterministic sequence with seed 42
        let char1 = latin1Gen.run(using: &rng)
        let char2 = latin1Gen.run(using: &rng)
        let char3 = latin1Gen.run(using: &rng)
        
        // Get Unicode scalar values for verification
        let scalar1 = char1.unicodeScalars.first!.value
        let scalar2 = char2.unicodeScalars.first!.value
        let scalar3 = char3.unicodeScalars.first!.value
        
        XCTAssertEqual(scalar1, 248, "First Latin-1 char with seed 42 should have scalar value 248")
        XCTAssertEqual(scalar2, 46, "Second Latin-1 char with seed 42 should have scalar value 46")
        XCTAssertEqual(scalar3, 34, "Third Latin-1 char with seed 42 should have scalar value 34")
        
        // Verify all outputs are within Latin-1 range
        for _ in 1...50 {
            let char = latin1Gen.run(using: &rng)
            let scalar = char.unicodeScalars.first!.value
            XCTAssertLessThanOrEqual(scalar, 255, "Character should be within Latin-1 range (0-255)")
        }
    }
    
    func testCharacterExtensionMethod() {
        // Test the character() extension method on RandomGenerator
        var rng = LCRNG(seed: 42)
        
        // Create a custom Character generator and use the extension method
        let baseGen = Always(Character("x"))
        let rangeGen = baseGen.character(in: Character("a")...Character("z"))
        
        // Run the generator and verify the output
        let result = rangeGen.run(using: &rng)
        
        XCTAssertEqual(result, "z", "Character generator with seed 42 should produce 'z'")
    }
    
    func testCharacterWithArrays() {
        // Test generating arrays of characters
        var rng = LCRNG(seed: 42)
        
        // Create a character generator and generate an array
        let digitGen = RandomGenerators.number
        let digitArrayGen = digitGen.array(5)
        
        // Run the generator and verify the output
        let digits = digitArrayGen.run(using: &rng)
        
        XCTAssertEqual(digits.count, 5, "Should generate 5 digits")
        XCTAssertEqual(digits, ["9", "9", "9", "9", "9"], "Should generate the expected sequence of digits")
        
        // Test with the letterOrNumber generator
        let alphanumericGen = RandomGenerators.letterOrNumber
        let alphanumericArrayGen = alphanumericGen.array(8)
        
        // Run the generator and verify the output
        let alphanumeric = alphanumericArrayGen.run(using: &rng)
        
        XCTAssertEqual(alphanumeric.count, 8, "Should generate 8 alphanumeric characters")
        XCTAssertEqual(alphanumeric, ["G", "9", "K", "U", "h", "o", "P", "2"], "Should generate the expected sequence")
    }
    
    func testCharacterPerformance() {
        // Test the performance of character generation
        let charGen = RandomGenerators.letterOrNumber
        measure {
            var rng = LCRNG(seed: 42)
            for _ in 1...10000 {
                _ = charGen.run(using: &rng)
            }
        }
    }
} 