import Foundation
import Testing
import SwiftRandomKit
import SwiftRandomKitGenerators

struct VersionNumberGeneratorTests {

    private let semverPattern = #"^\d+\.\d+\.\d+(-(alpha|beta|rc)\.\d+)?(\+\d+)?$"#

    @Test func coreVersionFormatAndRanges() {
        var rng = LCRNG(seed: 1)
        let generator = VersionNumberGenerator(
            majorRange: 1...2,
            minorRange: 0...5,
            patchRange: 0...9
        )

        for _ in 0..<50 {
            let version = generator.run(using: &rng)
            let parts = version.split(separator: ".").compactMap { Int($0) }
            #expect(parts.count == 3, "Plain versions are MAJOR.MINOR.PATCH: \(version)")
            #expect((1...2).contains(parts[0]), "Major within range: \(version)")
            #expect((0...5).contains(parts[1]), "Minor within range: \(version)")
            #expect((0...9).contains(parts[2]), "Patch within range: \(version)")
        }
    }

    @Test func prereleaseAndBuildStayWellFormed() {
        var rng = LCRNG(seed: 2)
        let generator = VersionNumberGenerator(includePrerelease: true, includeBuild: true)

        var sawPrerelease = false
        var sawBuild = false
        for _ in 0..<100 {
            let version = generator.run(using: &rng)
            #expect(version.range(of: semverPattern, options: .regularExpression) != nil, "Should be valid semver: \(version)")
            if version.contains("-") { sawPrerelease = true }
            if version.contains("+") { sawBuild = true }
        }

        // The flags enable, but do not force, the extra components (50% each).
        #expect(sawPrerelease, "Prerelease identifiers should appear over 100 runs")
        #expect(sawBuild, "Build metadata should appear over 100 runs")
    }

    @Test func deterministicWithSameSeed() {
        var rng1 = LCRNG(seed: 42)
        var rng2 = LCRNG(seed: 42)
        let generator = VersionNumberGenerator(includePrerelease: true, includeBuild: true)

        #expect(generator.run(using: &rng1) == generator.run(using: &rng2))
    }
}
