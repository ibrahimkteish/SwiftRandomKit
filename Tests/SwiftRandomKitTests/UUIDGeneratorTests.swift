import Testing
import SwiftRandomKit
import SwiftRandomKitGenerators
import Foundation

@Suite("UUID Generator Tests")
struct UUIDGeneratorTests {
    @Test("UUID Generator produces valid UUIDs with expected values")
    func testUUID() {
        let uuidGenerator = UUIDGenerator()
        var rng = LCRNG(seed: 1)

        let uuid = uuidGenerator.run(using: &rng)
        let realUUID = UUID.init(uuidString: uuid)
        
        #expect(uuid == "2aaf20cd-c6db-4c59-a2c7-d8a53e73d4b1")
        #expect(realUUID != nil)
    }
}
