import SwiftRandomKit
import Foundation
// var rng = SystemRandomNumberGenerator()
var rng = LCRNG(seed: 1)

var clock = ContinuousClock()
let uuidGenerator = UUIDGenerator()

var uuids: [String] = []
let duration = clock.measure {
    uuids.append(
        contentsOf: (0..<1).map { _ in uuidGenerator.run(using: &rng) }
    )
}

// write to file
let fileURL = URL(fileURLWithPath: "uuid.txt")
try uuids.joined(separator: "\n").write(to: fileURL, atomically: true, encoding: .utf8)

print(duration)

// vs Foundation UUID()
var clock2 = ContinuousClock()
var foundationUuids: [String] = []
let foundationDuration = clock2.measure {
    foundationUuids.append(contentsOf: (0..<1).map { _ in UUID().uuidString })
}

// write to file
let foundationFileURL = URL(fileURLWithPath: "foundation-uuid.txt")
try foundationUuids.joined(separator: "\n").write(to: foundationFileURL, atomically: true, encoding: .utf8)
print(foundationDuration)

