import SwiftRandomKit
import Foundation
var rng = LCRNG(seed: 1)

var clock = ContinuousClock()
let numbers = IntGenerator<UInt32>(in: 0...1000000)
   

var uuids: [Int] = []
let duration = clock.measure {
    uuids.append(
        contentsOf: numbers
            .map { $0 * 2 }
            .map { String($0) }
            .map { $0.count }
            .array(1000000)
            .run(using: &rng)
    )
}

// write to file
let fileURL = URL(fileURLWithPath: "uuid.txt")
try uuids.map(String.init).joined(separator: "\n").write(to: fileURL, atomically: true, encoding: .utf8)

print(duration)