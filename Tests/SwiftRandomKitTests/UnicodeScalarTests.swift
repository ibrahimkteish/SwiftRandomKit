import Testing
import SwiftRandomKit

struct UnicodeScalarTests {
    @Test func unicodeScalarInRange() {
        // Create a UnicodeScalar generator for ASCII range
        let asciiRange: ClosedRange<UnicodeScalar> = UnicodeScalar(65)...UnicodeScalar(90) // A-Z
        let generator = RandomGenerators.UnicodeScalar(in: asciiRange)

        // Test with a deterministic RNG
        var rng = LCRNG(seed: 42)

        // With seed 42, we can predict the exact sequence
        let expectedSequence: [UInt32] = [90, 69, 68, 78, 66, 77, 73, 68, 72, 76]

        for expected in expectedSequence {
            let scalar = generator.run(using: &rng)
            #expect(scalar.value == expected)

            // Convert to Character for better debugging
            let char = Character(scalar)
            #expect(char == Character(UnicodeScalar(expected)!))
        }
    }

    @Test func unicodeScalarLowercase() {
        // Create a UnicodeScalar generator for lowercase letters
        let lowercaseRange: ClosedRange<UnicodeScalar> = UnicodeScalar(97)...UnicodeScalar(122) // a-z
        let generator = RandomGenerators.UnicodeScalar(in: lowercaseRange)

        // Test with a deterministic RNG
        var rng = LCRNG(seed: 42)

        // With seed 42, we can predict the exact sequence
        let expectedSequence: [UInt32] = [122, 101, 100, 110, 98, 109, 105, 100, 104, 108]

        for expected in expectedSequence {
            let scalar = generator.run(using: &rng)
            #expect(scalar.value == expected)

            // Convert to Character for better debugging
            let char = Character(scalar)
            #expect(char == Character(UnicodeScalar(expected)!))
        }
    }

    @Test func unicodeScalarDigits() {
        // Create a UnicodeScalar generator for digits
        let digitRange: ClosedRange<UnicodeScalar> = UnicodeScalar(48)...UnicodeScalar(57) // 0-9
        let generator = RandomGenerators.UnicodeScalar(in: digitRange)

        // Test with a deterministic RNG
        var rng = LCRNG(seed: 42)

        // With seed 42, we can predict the exact sequence
        let expectedSequence: [UInt32] = [57, 49, 49, 53, 48, 52, 51, 49, 50, 52]

        for expected in expectedSequence {
            let scalar = generator.run(using: &rng)
            #expect(scalar.value == expected)

            // Convert to Character for better debugging
            let char = Character(scalar)
            #expect(char == Character(UnicodeScalar(expected)!))
        }
    }

    @Test func unicodeScalarSkipsSurrogateGap() {
        // U+D800...U+DFFF are surrogate code points, not valid scalars. A range
        // spanning the gap must never produce one and must not be biased toward
        // any fallback value.
        let range: ClosedRange<UnicodeScalar> = UnicodeScalar(0xD7FE)!...UnicodeScalar(0xE001)!
        let generator = RandomGenerators.UnicodeScalar(in: range)

        var rng = LCRNG(seed: 42)
        var seen = Set<UInt32>()
        for _ in 0..<200 {
            let scalar = generator.run(using: &rng)
            #expect(!((0xD800...0xDFFF).contains(scalar.value)), "Surrogates are not valid scalars")
            #expect(range.contains(scalar))
            seen.insert(scalar.value)
        }

        // Only four valid scalars exist in this range; a uniform draw over 200
        // runs should hit all of them.
        #expect(seen == [0xD7FE, 0xD7FF, 0xE000, 0xE001])
    }
}
