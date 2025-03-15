import SwiftRandomKit

public struct SafariPasswordGenerator: RandomGenerator {
    public init() {}

    public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> String {
        // huwKun-1zyjxi-nyxseh
        let passwordSegment = RandomGenerators.letterOrNumber.array(6).map(charsToString)
        let password = passwordSegment.array(3).map { $0.joined(separator: "-") }
        return password.run(using: &rng)
    }
}

fileprivate func charsToString(_ chars: [Character]) -> String {
    chars.map(String.init).joined()
}
