import SwiftRandomKit
import Foundation
import SwiftRandomKitGenerators
// var rng = SystemRandomNumberGenerator()

// var clock = ContinuousClock()
// let uuidGenerator = UUIDGenerator()

// var uuids: [String] = []
// let duration = clock.measure {
//     uuids.append(
//         contentsOf: (0..<1).map { _ in uuidGenerator.run(using: &rng) }
//     )
// }

// write to file
// let fileURL = URL(fileURLWithPath: "uuid.txt")
// try uuids.joined(separator: "\n").write(to: fileURL, atomically: true, encoding: .utf8)

// print(duration)

// vs Foundation UUID()
// var clock2 = ContinuousClock()
// var foundationUuids: [String] = []
// let foundationDuration = clock2.measure {
//     foundationUuids.append(contentsOf: (0..<1).map { _ in UUID().uuidString })
// }

// write to file
// let foundationFileURL = URL(fileURLWithPath: "foundation-uuid.txt")
// try foundationUuids.joined(separator: "\n").write(to: foundationFileURL, atomically: true, encoding: .utf8)
// print(foundationDuration)

// compute how much foundation is faster
// let ratio = duration / foundationDuration
// print("Foundation is \(ratio)x faster")

// let ip = IPAddressGenerator(version: .v4).array(10)
// Swift.print(ip.run(using: &rng))

// let ip2 = IPAddressGenerator(version: .v6).array(10)
// Swift.print(ip2.run(using: &rng))

// let latLong = LatLongGenerator().array(10)
// Swift.print(latLong.run(using: &rng))

// let creditCard = CreditCardGenerator(type: .visa).array(10)
// Swift.print(creditCard.run(using: &rng))

// example of flatMap using Always as condition 
// it should be .flatmap { value in if value { Always(true) } else { Always(false) } }

// Generate a dictionary of string keys and integer values
let pairGen =
    ["name", "age", "score", "level"].randomGeneratorElement().zip(IntGenerator(in: 1...100))
let dictGen = pairGen.dictionary(Always(3))
let result = dictGen.run() // e.g., ["name": 42, "level": 87, "score": 13]
print(result)

// Example of string concatenation with non-optional values
let firstNameGen = Always("John")
let lastNameGen = Always("Smith")
let fullNameGen = firstNameGen.concat(lastNameGen, separator: " ")
let fullName = fullNameGen.run() // "John Smith"
print("Full name: \(fullName)")

// Example with optional values - manual handling
let optFirstNameGen = Always(["John", "Jane", "Alex", "Sarah"]).element()
let optLastNameGen = Always(["Smith", "Johnson", "Williams", "Brown"]).element()

// Run the generators to get the values
let firstName = optFirstNameGen.run()
let lastName = optLastNameGen.run()

// Combine the names manually
let optFullName: String
if let first = firstName, let last = lastName {
    optFullName = "\(first) \(last)"
} else {
    optFullName = "No name generated"
}

print("Optional full name: \(optFullName)")
