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
        
        #expect(uuid == "2AAF20CD-C6DB-4C59-A2C7-D8A53E73D4B1")
        #expect(realUUID != nil)
    }
}
