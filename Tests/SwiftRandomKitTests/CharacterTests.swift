import Testing
@testable import SwiftRandomKit

struct CharacterTests {
    
    @Test func characterInRange() {
        // Test character generation within a range
        var rng = LCRNG(seed: 42)
        
        // Test with lowercase letters range
        let lowercaseRange = Character("a")...Character("z")
        let lowercaseGen = RandomGenerators.character(in: lowercaseRange)
        
        // With seed 42, we should get deterministic values
        let char1 = lowercaseGen.run(using: &rng)
        let char2 = lowercaseGen.run(using: &rng)
        let char3 = lowercaseGen.run(using: &rng)
        
        #expect(char1 == "z", "First character with seed 42 should be 'z'")
        #expect(char2 == "e", "Second character with seed 42 should be 'e'")
        #expect(char3 == "d", "Third character with seed 42 should be 'd'")

        // Test with digit range
        let digitRange = Character("0")...Character("9")
        let digitGen = RandomGenerators.character(in: digitRange)

        let digit1 = digitGen.run(using: &rng)
        let digit2 = digitGen.run(using: &rng)

        #expect(digit1 == "5", "First digit with seed 42 should be '5'")
        #expect(digit2 == "0", "Second digit with seed 42 should be '0'")
        
        // Make sure characters are within the range
        for _ in 1...20 {
            let char = lowercaseGen.run(using: &rng)
            #expect(char >= Character("a"), "Character should be >= 'a'")
            #expect(char <= Character("z"), "Character should be <= 'z'")
        }
    }
    
    @Test func numberGenerator() {
        // Test the number character generator (0-9)
        var rng = LCRNG(seed: 42)
        
        let numberGen = RandomGenerators.number
        
        // Test deterministic sequence with seed 42
        let digit1 = numberGen.run(using: &rng)
        let digit2 = numberGen.run(using: &rng)
        let digit3 = numberGen.run(using: &rng)
        
        #expect(digit1 == "9", "First digit with seed 42 should be '9'")
        #expect(digit2 == "1", "Second digit with seed 42 should be '1'")
        #expect(digit3 == "1", "Third digit with seed 42 should be '1'")
        
        // Verify all outputs are digits
        for _ in 1...20 {
            let digit = numberGen.run(using: &rng)
            #expect((Character("0")...Character("9")).contains(digit), "Character should be a digit (0-9)")
        }
    }
    
    @Test func uppercaseLetterGenerator() {
        // Test the uppercase letter generator (A-Z)
        var rng = LCRNG(seed: 42)
        
        let uppercaseGen = RandomGenerators.uppercaseLetter
        
        // Test deterministic sequence with seed 42
        let char1 = uppercaseGen.run(using: &rng)
        let char2 = uppercaseGen.run(using: &rng)
        let char3 = uppercaseGen.run(using: &rng)
        
        #expect(char1 == "Z", "First uppercase letter with seed 42 should be 'Z'")
        #expect(char2 == "E", "Second uppercase letter with seed 42 should be 'E'")
        #expect(char3 == "D", "Third uppercase letter with seed 42 should be 'D'")
        
        // Verify all outputs are uppercase letters
        for _ in 1...20 {
            let letter = uppercaseGen.run(using: &rng)
            #expect((Character("A")...Character("Z")).contains(letter), "Character should be an uppercase letter (A-Z)")
        }
    }
    
    @Test func lowercaseLetterGenerator() {
        // Test the lowercase letter generator (a-z)
        var rng = LCRNG(seed: 42)
        
        let lowercaseGen = RandomGenerators.lowercaseLetter
        
        // Test deterministic sequence with seed 42
        let char1 = lowercaseGen.run(using: &rng)
        let char2 = lowercaseGen.run(using: &rng)
        let char3 = lowercaseGen.run(using: &rng)
        
        #expect(char1 == "z", "First lowercase letter with seed 42 should be 'z'")
        #expect(char2 == "e", "Second lowercase letter with seed 42 should be 'e'")
        #expect(char3 == "d", "Third lowercase letter with seed 42 should be 'd'")
        
        // Verify all outputs are lowercase letters
        for _ in 1...20 {
            let letter = lowercaseGen.run(using: &rng)
            #expect((Character("a")...Character("z")).contains(letter), "Character should be a lowercase letter (a-z)")
        }
    }
    
    @Test func letterGenerator() {
        // Test the letter generator (combines uppercase and lowercase)
        var rng = LCRNG(seed: 42)
        
        let letterGen = RandomGenerators.letter
        
        // Test deterministic sequence with seed 42
        let char1 = letterGen.run(using: &rng)
        let char2 = letterGen.run(using: &rng)
        let char3 = letterGen.run(using: &rng)
        
        #expect(char1 == "A", "First letter with seed 42 should be 'A'")
        #expect(char2 == "Z", "Second letter with seed 42 should be 'Z'")
        #expect(char3 == "E", "Third letter with seed 42 should be 'E'")
        
        // Verify all outputs are letters
        for _ in 1...50 {
            let letter = letterGen.run(using: &rng)
            let isLetter = ((Character("a")...Character("z")).contains(letter) || 
                           (Character("A")...Character("Z")).contains(letter))
            #expect(isLetter, "Character should be a letter (a-z or A-Z)")
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
        #expect(uppercaseCount > iterations / 10, "Should have a significant number of uppercase letters")
        #expect(lowercaseCount > iterations / 10, "Should have a significant number of lowercase letters")
    }
    
    @Test func letterOrNumberGenerator() {
        // Test the alphanumeric generator (a-z, A-Z, 0-9)
        var rng = LCRNG(seed: 42)
        
        let alphanumericGen = RandomGenerators.letterOrNumber
        
        // Test deterministic sequence with seed 42
        let char1 = alphanumericGen.run(using: &rng)
        let char2 = alphanumericGen.run(using: &rng)
        let char3 = alphanumericGen.run(using: &rng)
        
        #expect(char1 == "G", "First alphanumeric char with seed 42 should be 'G'")
        #expect(char2 == "9", "Second alphanumeric char with seed 42 should be '9'")
        #expect(char3 == "K", "Third alphanumeric char with seed 42 should be 'K'")
        
        // Verify all outputs are alphanumeric
        for _ in 1...50 {
            let char = alphanumericGen.run(using: &rng)
            let isAlphanumeric = ((Character("a")...Character("z")).contains(char) || 
                                  (Character("A")...Character("Z")).contains(char) ||
                                  (Character("0")...Character("9")).contains(char))
            #expect(isAlphanumeric, "Character should be alphanumeric")
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
        #expect(uppercaseCount > iterations / 10, "Should have a significant number of uppercase letters")
        #expect(lowercaseCount > iterations / 10, "Should have a significant number of lowercase letters")
        #expect(digitCount > iterations / 10, "Should have a significant number of digits")
    }
    
    @Test func asciiGenerator() {
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
        
        #expect(scalar1 == 124, "First ASCII char with seed 42 should have scalar value 124")
        #expect(scalar2 == 23, "Second ASCII char with seed 42 should have scalar value 23")
        #expect(scalar3 == 17, "Third ASCII char with seed 42 should have scalar value 17")
        
        // Verify all outputs are within ASCII range
        for _ in 1...50 {
            let char = asciiGen.run(using: &rng)
            let scalar = char.unicodeScalars.first!.value
            #expect(scalar <= 127, "Character should be within ASCII range (0-127)")
        }
    }
    
    @Test func latin1Generator() {
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
        
        #expect(scalar1 == 248, "First Latin-1 char with seed 42 should have scalar value 248")
        #expect(scalar2 == 46, "Second Latin-1 char with seed 42 should have scalar value 46")
        #expect(scalar3 == 34, "Third Latin-1 char with seed 42 should have scalar value 34")
        
        // Verify all outputs are within Latin-1 range
        for _ in 1...50 {
            let char = latin1Gen.run(using: &rng)
            let scalar = char.unicodeScalars.first!.value
            #expect(scalar <= 255, "Character should be within Latin-1 range (0-255)")
        }
    }
    
    @Test func characterGeneratorStruct() {
        // Test constructing the Character generator directly
        var rng = LCRNG(seed: 42)

        let rangeGen = RandomGenerators.Character(in: Character("a")...Character("z"))

        // Run the generator and verify the output
        let result = rangeGen.run(using: &rng)

        #expect(result == "z", "Character generator with seed 42 should produce 'z'")
    }
    
    @Test func characterWithArrays() {
        // Test generating arrays of characters
        var rng = LCRNG(seed: 42)
        
        // Create a character generator and generate an array
        let digitGen = RandomGenerators.number
        let digitArrayGen = digitGen.array(5)
        
        // Run the generator and verify the output
        let digits = digitArrayGen.run(using: &rng)
        
        #expect(digits.count == 5, "Should generate 5 digits")
        #expect(digits == ["9", "1", "1", "5", "0"], "Should generate the expected sequence of digits")
        
        // Test with the letterOrNumber generator
        let alphanumericGen = RandomGenerators.letterOrNumber
        let alphanumericArrayGen = alphanumericGen.array(8)
        
        // Run the generator and verify the output
        let alphanumeric = alphanumericArrayGen.run(using: &rng)
        
        #expect(alphanumeric.count == 8, "Should generate 8 alphanumeric characters")
        #expect(alphanumeric == ["o", "P", "2", "6", "a", "g", "A", "V"], "Should generate the expected sequence")
    }
} 
