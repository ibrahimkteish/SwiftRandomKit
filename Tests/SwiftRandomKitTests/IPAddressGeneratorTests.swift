import XCTest
import SwiftRandomKit
import SwiftRandomKitGenerators

final class IPAddressGeneratorTests: XCTestCase {

    func testIPv4Format() {
        var rng = LCRNG(seed: 1)
        let generator = IPAddressGenerator(version: .v4)

        for _ in 0..<20 {
            let address = generator.run(using: &rng)
            let segments = address.split(separator: ".")
            XCTAssertEqual(segments.count, 4, "IPv4 has four octets: \(address)")
            for segment in segments {
                let value = Int(segment)
                XCTAssertNotNil(value, "Octet is numeric: \(address)")
                XCTAssertTrue((0...255).contains(value!), "Octet in 0...255: \(address)")
            }
        }
    }

    func testIPv6Format() {
        var rng = LCRNG(seed: 2)
        let generator = IPAddressGenerator(version: .v6)
        let hexDigits = CharacterSet(charactersIn: "0123456789abcdef")

        for _ in 0..<20 {
            let address = generator.run(using: &rng)
            let groups = address.split(separator: ":", omittingEmptySubsequences: false)
            XCTAssertEqual(groups.count, 8, "IPv6 has eight groups: \(address)")
            for group in groups {
                XCTAssertEqual(group.count, 4, "Groups are zero-padded to four digits: \(address)")
                XCTAssertTrue(group.unicodeScalars.allSatisfy(hexDigits.contains), "Groups are lowercase hex: \(address)")
            }
        }
    }

    func testDeterministicWithSameSeed() {
        var rng1 = LCRNG(seed: 42)
        var rng2 = LCRNG(seed: 42)
        let generator = IPAddressGenerator(version: .v4)

        XCTAssertEqual(generator.run(using: &rng1), generator.run(using: &rng2))
    }
}
