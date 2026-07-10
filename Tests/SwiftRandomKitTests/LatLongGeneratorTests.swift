import Testing
import SwiftRandomKit
import SwiftRandomKitGenerators

struct LatLongGeneratorTests {

    @Test func defaultRangesCoverTheGlobe() {
        var rng = LCRNG(seed: 1)
        let generator = LatLongGenerator()

        for _ in 0..<50 {
            let coordinate = generator.run(using: &rng)
            #expect((-90.0...90.0).contains(coordinate.latitude))
            #expect((-180.0...180.0).contains(coordinate.longitude))
        }
    }

    @Test func customRangesAreRespected() {
        var rng = LCRNG(seed: 2)
        // Roughly continental Europe
        let generator = LatLongGenerator(
            latitudeRange: 36.0...60.0,
            longitudeRange: -10.0...30.0
        )

        for _ in 0..<50 {
            let coordinate = generator.run(using: &rng)
            #expect((36.0...60.0).contains(coordinate.latitude))
            #expect((-10.0...30.0).contains(coordinate.longitude))
        }
    }

    @Test func deterministicWithSameSeed() {
        var rng1 = LCRNG(seed: 42)
        var rng2 = LCRNG(seed: 42)
        let generator = LatLongGenerator()

        let first = generator.run(using: &rng1)
        let second = generator.run(using: &rng2)
        #expect(first.latitude == second.latitude)
        #expect(first.longitude == second.longitude)
    }
}
