import SwiftRandomKit

public struct UUIDGenerator: RandomGenerator {
    public init() {}

    public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> String {
        // Generate 16 random bytes
        var bytes = IntGenerator<UInt8>(in: 0...255).array(16).run(using: &rng)

        // Set the version number to 4 in the 7th byte
        bytes[6] = (bytes[6] & 0x0F) | 0x40

        // Set the variant bits in the 9th byte (RFC 4122 variant)
        bytes[8] = (bytes[8] & 0x3F) | 0x80

        // Convert to hexadecimal string without intermediate arrays
        let hexChars: [UnicodeScalar] = [
            "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
            "a", "b", "c", "d", "e", "f"
        ]
        var uuidString = [Character](repeating: "-", count: 36)
        var index = 0

        for (i, byte) in bytes.enumerated() {
            if i == 4 || i == 6 || i == 8 || i == 10 { index += 1 }
            uuidString[index] = Character(hexChars[Int(byte >> 4)])
            uuidString[index + 1] = Character(hexChars[Int(byte & 0x0F)])
            index += 2
        }

        return String(uuidString)
    }
}
