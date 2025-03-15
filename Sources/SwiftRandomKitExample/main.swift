import SwiftRandomKit
import Foundation
import SwiftRandomKitGenerators
var rng = SystemRandomNumberGenerator()

// var clock = ContinuousClock()
// let uuidGenerator = UUIDGenerator()

// var uuids: [String] = []
// let duration = clock.measure {
//     uuids.append(
//         contentsOf: (0..<1).map { _ in uuidGenerator.run() }
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
// Swift.print(ip.run())

// let ip2 = IPAddressGenerator(version: .v6).array(10)
// Swift.print(ip2.run())

// let latLong = LatLongGenerator().array(10)
// Swift.print(latLong.run())

// let creditCard = CreditCardGenerator(type: .visa).array(10)
// Swift.print(creditCard.run())

// example of flatMap using Always as condition 
// it should be .flatmap { value in if value { Always(true) } else { Always(false) } }
