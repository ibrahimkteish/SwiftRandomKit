import XCTest
import SwiftRandomKit

final class UUIDGeneratorTests: XCTestCase {
    func testUUID() {
        let uuidGenerator = UUIDGenerator()
        var rng = LCRNG(seed: 1)

        let realUUID = UUID.init(uuidString: uuidGenerator.run(using: &rng))
        XCTAssertEqual("2AD041E8-7E86-F421-7536-B5783931DA00", realUUID?.uuidString)
        XCTAssertNotNil(realUUID)
    }
}
