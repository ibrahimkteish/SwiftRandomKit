import Foundation
import SwiftRandomKit

public enum CreditCardType: Sendable {
    case visa
    case mastercard
    case amex
    case discover

    /// The issuer prefixes a generated number may start with.
    var prefixes: [Int] {
        switch self {
        case .visa: [4]
        case .mastercard: [51, 52, 53, 54, 55]
        case .amex: [34, 37]
        case .discover: [6011, 644, 645, 646, 647, 648, 649, 65]
        }
    }

    /// The total number of digits, including the check digit.
    var length: Int {
        switch self {
        case .visa: 16
        case .mastercard: 16
        case .amex: 15
        case .discover: 16
        }
    }
}

public struct CreditCardGenerator: RandomGenerator {
    public typealias Element = String

    private let type: CreditCardType
    
    public init(type: CreditCardType = .visa) {
        self.type = type
    }
    
    private func digitsFrom(number: Int) -> [Int] {
        var num = number
        var digits: [Int] = []
        
        if num == 0 {
            return [0]
        }
        
        while num > 0 {
            digits.insert(num % 10, at: 0)
            num /= 10
        }
        
        return digits
    }
    
    /// Calculate check digit using the Luhn algorithm
    private func calculateLuhnCheckDigit(_ digits: [Int]) -> Int {
        // Create a copy of digits for manipulation
        var workingDigits = digits
        
        // Double every second digit from the right
        for i in stride(from: workingDigits.count - 1, through: 0, by: -2) {
            var doubled = workingDigits[i] * 2
            // If doubling results in a two-digit number, subtract 9
            if doubled > 9 {
                doubled -= 9
            }
            workingDigits[i] = doubled
        }
        
        // Sum all digits
        let sum = workingDigits.reduce(0, +)
        
        // Calculate check digit: the digit that needs to be added to make sum divisible by 10
        return (10 - (sum % 10)) % 10
    }

    public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> String {
        // The prefix lists are non-empty by construction, so randomElement cannot return nil.
        let prefixValue = type.prefixes.randomElement(using: &rng)!
        let prefixDigits = digitsFrom(number: prefixValue)

        // Generate random digits for the number (excluding the check digit)
        let remainingLength = type.length - prefixDigits.count - 1
        
        let remainingDigits: [Int] = IntGenerator(in: 0...9).array(remainingLength).run(using: &rng)
        
        // Combine prefix digits and remaining digits
        let allDigitsExceptCheck = prefixDigits + remainingDigits
        
        // Apply Luhn algorithm to calculate the check digit
        let checkDigit = calculateLuhnCheckDigit(allDigitsExceptCheck)
        
        // Form the complete card number
        let allDigits = allDigitsExceptCheck + [checkDigit]
        return allDigits.map { String($0) }.joined()
    }
}


extension CreditCardGenerator: Sendable {}
