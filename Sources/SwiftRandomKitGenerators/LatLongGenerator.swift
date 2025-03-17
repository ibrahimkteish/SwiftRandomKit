import SwiftRandomKit

public struct LatLongGenerator: RandomGenerator {
    public typealias Element = (latitude: Double, longitude: Double)
    
    private let latitudeRange: ClosedRange<Double>
    private let longitudeRange: ClosedRange<Double>
    
    public init(
        latitudeRange: ClosedRange<Double> = -90.0...90.0,
        longitudeRange: ClosedRange<Double> = -180.0...180.0
    ) {
        self.latitudeRange = latitudeRange
        self.longitudeRange = longitudeRange
    }
    
    public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Element {
        let latitude = FloatGenerator<Double>(in: latitudeRange).run(using: &rng)
        let longitude = FloatGenerator<Double>(in: longitudeRange).run(using: &rng)
        return (latitude: latitude, longitude: longitude)
    }
}