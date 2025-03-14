import Foundation
import SwiftRandomKit

public enum CreditCardType {
    case visa
    case mastercard
    case amex
    case discover
    
    var prefix: AnyRandomGenerator<[Int]> {
        switch self {
        case .visa: Always([4]).eraseToAnyRandomGenerator()
        case .mastercard: Always([51, 52, 53, 54, 55]).eraseToAnyRandomGenerator()
        case .amex: Always([34, 37]).eraseToAnyRandomGenerator()
        case .discover: Always([6011, 644, 645, 646, 647, 648, 649, 65]).eraseToAnyRandomGenerator()
        }
    }
    
    var length: [Int] {
        switch self {
        case .visa:  [ 16 ]
        case .mastercard:  [16]
        case .amex:  [15]
        case .discover:  [16]
        }
    }
}

public struct CreditCardGenerator: RandomGenerator {
    public typealias Generated = String
    
    private let type: CreditCardType
    
    public init(type: CreditCardType = .visa) {
        self.type = type
    }
    
    func lengthOfInt(_ number: Int) -> Int {
    guard number != 0 else { return 1 } // Handle the case where the number is 0

    var num = abs(number) // Work with the absolute value to handle negative numbers
    var count = 0

    while num > 0 {
        num /= 10
        count += 1
    }

    return count
}

    private func calculateLuhnCheckDigit(_ number: [Int]) -> Int {
        let reversedDigits = number.reversed()
        var sum = 0
        for (index, digit) in reversedDigits.enumerated() {
            if index % 2 == 0 {
                sum += digit
            } else {
                let doubled = digit * 2
                sum += (doubled > 9) ? (doubled - 9) : doubled
            }
        }
        return (10 - (sum % 10)) % 10
    }

    public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> String {
        // Get random prefix for the card type
        guard let prefix = type.prefix.element().run(using: &rng),
              let length = type.length.randomElement() else {
            fatalError("Invalid card type configuration")
        }
        
        // Generate random digits for the number (excluding the last digit)
        var cardNumber = prefix
        let remainingLength = length - lengthOfInt(prefix) - 1
        
       var remainingDigits: [Int] = IntGenerator(in: 0...9).array(remainingLength).run(using: &rng)
        
        // Calculate the Luhn check digit
        let checkDigit = calculateLuhnCheckDigit([prefix] + remainingDigits)

        
        return ([prefix] + remainingDigits + [checkDigit]).map { String($0) }.joined()
    }
}

