import Testing
import SwiftRandomKit
import SwiftRandomKitGenerators

@Suite("Safari Password Generator Tests")
struct SafariPasswordGeneratorTests {
    @Test("SafariPasswordGenerator produces expected password format")
    func testSafariPassword() {
        let safariPasswordGenerator = SafariPasswordGenerator()
        var rng = LCRNG(seed: 1)

        let password = safariPasswordGenerator.run(using: &rng)
        #expect(password == "jN2cpg-2FB5Hx-6rigDv")
    }
}
