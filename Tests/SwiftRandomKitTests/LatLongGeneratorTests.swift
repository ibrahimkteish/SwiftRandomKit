import XCTest
import SwiftRandomKit
import SwiftRandomKitGenerators

final class LatLongGeneratorTests: XCTestCase {

    func testDefaultRangesCoverTheGlobe() {
        var rng = LCRNG(seed: 1)
        let generator = LatLongGenerator()

        for _ in 0..<50 {
            let coordinate = generator.run(using: &rng)
            XCTAssertTrue((-90.0...90.0).contains(coordinate.latitude))
            XCTAssertTrue((-180.0...180.0).contains(coordinate.longitude))
        }
    }

    func testCustomRangesAreRespected() {
        var rng = LCRNG(seed: 2)
        // Roughly continental Europe
        let generator = LatLongGenerator(
            latitudeRange: 36.0...60.0,
            longitudeRange: -10.0...30.0
        )

        for _ in 0..<50 {
            let coordinate = generator.run(using: &rng)
            XCTAssertTrue((36.0...60.0).contains(coordinate.latitude))
            XCTAssertTrue((-10.0...30.0).contains(coordinate.longitude))
        }
    }

    func testDeterministicWithSameSeed() {
        var rng1 = LCRNG(seed: 42)
        var rng2 = LCRNG(seed: 42)
        let generator = LatLongGenerator()

        let first = generator.run(using: &rng1)
        let second = generator.run(using: &rng2)
        XCTAssertEqual(first.latitude, second.latitude)
        XCTAssertEqual(first.longitude, second.longitude)
    }
}
