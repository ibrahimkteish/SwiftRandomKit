import SwiftRandomKit

public struct IPAddressGenerator: RandomGenerator {
    public typealias Element = String
    
  public enum Version: Sendable {
        case v4, v6
    }
    
    private let version: Version
    
    public init(version: Version = .v4) {
        self.version = version
    }
    
    public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> String {
        switch version {
        case .v4:
            let segments = IntGenerator(in: 0...255).array(4).run(using: &rng)
            return segments.map(String.init).joined(separator: ".")
        case .v6:
            let segments = IntGenerator(in: 0...65535).array(8).run(using: &rng)
            return segments.map { String(format: "%04x", $0) }.joined(separator: ":")
        }
    }
}

public struct IPAddress: Equatable {
    let mask: Int
    let address: String
}

