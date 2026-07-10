import XCTest
import SwiftRandomKit
import SwiftRandomKitGenerators

final class CreditCardGeneratorTests: XCTestCase {

    /// Standard Luhn checksum validation over a full card number.
    private func isValidLuhn(_ number: String) -> Bool {
        let digits = number.reversed().compactMap { Int(String($0)) }
        guard digits.count == number.count else { return false }
        var sum = 0
        for (index, digit) in digits.enumerated() {
            if index % 2 == 1 {
                let doubled = digit * 2
                sum += doubled > 9 ? doubled - 9 : doubled
            } else {
                sum += digit
            }
        }
        return sum % 10 == 0
    }

    func testVisaNumbersAreValid() {
        var rng = LCRNG(seed: 1)
        let generator = CreditCardGenerator(type: .visa)

        for _ in 0..<20 {
            let number = generator.run(using: &rng)
            XCTAssertEqual(number.count, 16)
            XCTAssertTrue(number.hasPrefix("4"), "Visa numbers start with 4, got \(number)")
            XCTAssertTrue(isValidLuhn(number), "Luhn check failed for \(number)")
        }
    }

    func testMastercardNumbersAreValid() {
        var rng = LCRNG(seed: 2)
        let generator = CreditCardGenerator(type: .mastercard)

        for _ in 0..<20 {
            let number = generator.run(using: &rng)
            XCTAssertEqual(number.count, 16)
            let prefix = Int(number.prefix(2))!
            XCTAssertTrue((51...55).contains(prefix), "Mastercard numbers start with 51-55, got \(number)")
            XCTAssertTrue(isValidLuhn(number), "Luhn check failed for \(number)")
        }
    }

    func testAmexNumbersAreValid() {
        var rng = LCRNG(seed: 3)
        let generator = CreditCardGenerator(type: .amex)

        for _ in 0..<20 {
            let number = generator.run(using: &rng)
            XCTAssertEqual(number.count, 15)
            XCTAssertTrue(number.hasPrefix("34") || number.hasPrefix("37"), "Amex numbers start with 34 or 37, got \(number)")
            XCTAssertTrue(isValidLuhn(number), "Luhn check failed for \(number)")
        }
    }

    func testDiscoverNumbersAreValid() {
        var rng = LCRNG(seed: 4)
        let generator = CreditCardGenerator(type: .discover)
        let prefixes = ["6011", "644", "645", "646", "647", "648", "649", "65"]

        for _ in 0..<20 {
            let number = generator.run(using: &rng)
            XCTAssertEqual(number.count, 16)
            XCTAssertTrue(prefixes.contains { number.hasPrefix($0) }, "Unexpected Discover prefix in \(number)")
            XCTAssertTrue(isValidLuhn(number), "Luhn check failed for \(number)")
        }
    }

    func testDeterministicWithSameSeed() {
        var rng1 = LCRNG(seed: 42)
        var rng2 = LCRNG(seed: 42)
        let generator = CreditCardGenerator(type: .visa)

        XCTAssertEqual(generator.run(using: &rng1), generator.run(using: &rng2))
    }
}
