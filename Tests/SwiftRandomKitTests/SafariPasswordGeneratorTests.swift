import Testing
import SwiftRandomKit
import SwiftRandomKitGenerators

struct SafariPasswordGeneratorTests {
    @Test func safariPassword() {
        let safariPasswordGenerator = SafariPasswordGenerator()
        var rng = LCRNG(seed: 1)

        let password = safariPasswordGenerator.run(using: &rng)
        #expect(password == "jN2cpg-2FB5Hx-6rigDv")
    }
}
