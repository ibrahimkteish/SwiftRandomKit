import XCTest
import SwiftRandomKit
import SwiftRandomKitGenerators

final class SafariPasswordGeneratorTests: XCTestCase {
    func testSafariPassword() {
        let safariPasswordGenerator = SafariPasswordGenerator()
        var rng = LCRNG(seed: 1)

        let password = safariPasswordGenerator.run(using: &rng)
        XCTAssertEqual(password, "jN2cpg-2FB5Hx-6rigDv")
    }
}
