import XCTest
import SwiftRandomKit
import SwiftRandomKitGenerators

final class UUIDGeneratorTests: XCTestCase {
    func testUUID() {
        let uuidGenerator = UUIDGenerator()
        var rng = LCRNG(seed: 1)

        let realUUID = UUID.init(uuidString: uuidGenerator.run(using: &rng))
        XCTAssertEqual("2AAF20CD-C6DB-4C59-A2C7-D8A53E73D4B1", realUUID?.uuidString)
        XCTAssertNotNil(realUUID)
    }
}
