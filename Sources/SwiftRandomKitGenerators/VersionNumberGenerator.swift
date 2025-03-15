import Foundation
import SwiftRandomKit

/// A generator that produces random semantic version numbers.
public struct VersionNumberGenerator: RandomGenerator {
    public typealias Element = String
    
    private let majorRange: ClosedRange<Int>
    private let minorRange: ClosedRange<Int>
    private let patchRange: ClosedRange<Int>
    private let includePrerelease: Bool
    private let includeBuild: Bool
    
    /// Creates a generator that produces random semantic version numbers.
    /// - Parameters:
    ///   - majorRange: The range for the major version number. Default is 0...5.
    ///   - minorRange: The range for the minor version number. Default is 0...15.
    ///   - patchRange: The range for the patch version number. Default is 0...30.
    ///   - includePrerelease: Whether to include prerelease identifiers (e.g., alpha, beta). Default is false.
    ///   - includeBuild: Whether to include build metadata. Default is false.
    public init(
        majorRange: ClosedRange<Int> = 0...5,
        minorRange: ClosedRange<Int> = 0...15,
        patchRange: ClosedRange<Int> = 0...30,
        includePrerelease: Bool = false,
        includeBuild: Bool = false
    ) {
        self.majorRange = majorRange
        self.minorRange = minorRange
        self.patchRange = patchRange
        self.includePrerelease = includePrerelease
        self.includeBuild = includeBuild
    }
    
    public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> String {
        let major = Int.random(in: majorRange, using: &rng)
        let minor = Int.random(in: minorRange, using: &rng)
        let patch = Int.random(in: patchRange, using: &rng)
        
        var version = "\(major).\(minor).\(patch)"
        
        if includePrerelease && Bool.random(using: &rng) {
            let prereleaseOptions = ["alpha", "beta", "rc"]
            let prereleaseType = prereleaseOptions.randomElement(using: &rng)!
            let prereleaseNumber = Int.random(in: 1...10, using: &rng)
            version += "-\(prereleaseType).\(prereleaseNumber)"
        }
        
        if includeBuild && Bool.random(using: &rng) {
            let buildNumber = Int.random(in: 1...99999, using: &rng)
            version += "+\(buildNumber)"
        }
        
        return version
    }
}
