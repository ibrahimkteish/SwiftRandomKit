import XCTest
import SwiftRandomKit
import SwiftRandomKitGenerators
import Foundation

final class UUIDGeneratorTests: XCTestCase {
    func testUUID() {
        let uuidGenerator = UUIDGenerator()
        var rng = LCRNG(seed: 1)

        let uuid = uuidGenerator.run(using: &rng)
        let realUUID = UUID.init(uuidString: uuid)
        
        XCTAssertEqual(uuid.lowercased(), "2aaf20cd-c6db-4c59-a2c7-d8a53e73d4b1")
        XCTAssertNotNil(realUUID)
    }
}
