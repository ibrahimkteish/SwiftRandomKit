import Testing
import SwiftRandomKit
import SwiftRandomKitGenerators
import Foundation

struct UUIDGeneratorTests {
    @Test func uuidGeneration() {
        let uuidGenerator = UUIDGenerator()
        var rng = LCRNG(seed: 1)

        let uuid = uuidGenerator.run(using: &rng)
        let realUUID = UUID.init(uuidString: uuid)
        
        #expect(uuid.lowercased() == "2aaf20cd-c6db-4c59-a2c7-d8a53e73d4b1")
        #expect(realUUID != nil)
    }
}
