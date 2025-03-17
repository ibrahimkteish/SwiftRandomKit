import XCTest
import SwiftRandomKit

final class UnicodeScalarTests: XCTestCase {
    func testUnicodeScalarInRange() {
        // Create a UnicodeScalar generator for ASCII range
        let asciiRange: ClosedRange<UnicodeScalar> = UnicodeScalar(65)...UnicodeScalar(90) // A-Z
        let generator = IntGenerator<UInt32>(in: 0...0).map { _ in UnicodeScalar(65)! }
            .unicodeScalar(in: asciiRange)
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 42)
        
        // With seed 42, we can predict the exact sequence
        let expectedSequence: [UInt32] = [90, 69, 68, 78, 66, 77, 73, 68, 72, 76]
        
        for expected in expectedSequence {
            let scalar = generator.run(using: &rng)
            XCTAssertEqual(scalar.value, expected)
            
            // Convert to Character for better debugging
            let char = Character(scalar)
            XCTAssertEqual(char, Character(UnicodeScalar(expected)!))
        }
    }
    
    func testUnicodeScalarLowercase() {
        // Create a UnicodeScalar generator for lowercase letters
        let lowercaseRange: ClosedRange<UnicodeScalar> = UnicodeScalar(97)...UnicodeScalar(122) // a-z
        let generator = IntGenerator<UInt32>(in: 0...0).map { _ in UnicodeScalar(97)! }
            .unicodeScalar(in: lowercaseRange)
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 42)
        
        // With seed 42, we can predict the exact sequence
        let expectedSequence: [UInt32] = [122, 101, 100, 110, 98, 109, 105, 100, 104, 108]
        
        for expected in expectedSequence {
            let scalar = generator.run(using: &rng)
            XCTAssertEqual(scalar.value, expected)
            
            // Convert to Character for better debugging
            let char = Character(scalar)
            XCTAssertEqual(char, Character(UnicodeScalar(expected)!))
        }
    }
    
    func testUnicodeScalarDigits() {
        // Create a UnicodeScalar generator for digits
        let digitRange: ClosedRange<UnicodeScalar> = UnicodeScalar(48)...UnicodeScalar(57) // 0-9
        let generator = IntGenerator<UInt32>(in: 0...0).map { _ in UnicodeScalar(48)! }
            .unicodeScalar(in: digitRange)
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 42)
        
        // With seed 42, we can predict the exact sequence
        let expectedSequence: [UInt32] = [57, 49, 49, 53, 48, 52, 51, 49, 50, 52]
        
        for expected in expectedSequence {
            let scalar = generator.run(using: &rng)
            XCTAssertEqual(scalar.value, expected)
            
            // Convert to Character for better debugging
            let char = Character(scalar)
            XCTAssertEqual(char, Character(UnicodeScalar(expected)!))
        }
    }
    
    func testUnicodeScalarWithInvalidValue() {
        // Create a UnicodeScalar generator with a range that includes potentially invalid values
        // UnicodeScalar values 0xD800-0xDFFF are invalid (surrogate code points)
        let validScalar = UnicodeScalar(0xD700)!
        let invalidRangeStart = UnicodeScalar(0xD7FF)!
        let generator = IntGenerator<UInt32>(in: 0...0).map { _ in validScalar }
            .unicodeScalar(in: validScalar...invalidRangeStart)
        
        // Test with a deterministic RNG that would generate an invalid value
        var rng = LCRNG(seed: 42)
        
        // With seed 42, we would get a value in the invalid range
        // The generator should handle invalid values by returning the lower bound
        let scalar = generator.run(using: &rng)
        
        // The value should be the actual value generated
        XCTAssertEqual(scalar.value, 0xD7F8)
        
        // Run a few more times to verify behavior with invalid values
        for _ in 0..<5 {
            let nextScalar = generator.run(using: &rng)
            // Should always return a valid scalar
            XCTAssertNotNil(UnicodeScalar(nextScalar.value))
        }
    }
} 