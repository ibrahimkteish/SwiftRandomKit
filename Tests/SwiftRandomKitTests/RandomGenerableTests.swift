import Testing
import SwiftRandomKit

struct RandomGenerableTests {
    @Test func integerDefaultsAreDeterministic() {
        var a = LCRNG(seed: 1)
        var b = LCRNG(seed: 1)
        #expect(Int.generator.run(using: &a) == Int.generator.run(using: &b))
        #expect(UInt8.generator.run(using: &a) == UInt8.generator.run(using: &b))
    }

    @Test func floatDefaultStaysInUnitInterval() {
        var rng = LCRNG(seed: 2)
        for _ in 1...100 {
            let value = Double.generator.run(using: &rng)
            #expect((0.0...1.0).contains(value))
        }
    }

    @Test func boolDefaultProducesBothValues() {
        var rng = LCRNG(seed: 3)
        let flips = Bool.generator.array(100).run(using: &rng)
        #expect(flips.contains(true))
        #expect(flips.contains(false))
    }

    @Test func stringDefaultIsEightAlphanumerics() {
        var rng = LCRNG(seed: 4)
        for _ in 1...20 {
            let value = String.generator.run(using: &rng)
            #expect(value.count == 8)
            #expect(value.allSatisfy { $0.isLetter || $0.isNumber })
        }
    }

    @Test func characterDefaultIsLetter() {
        var rng = LCRNG(seed: 5)
        for _ in 1...50 {
            #expect(Character.generator.run(using: &rng).isLetter)
        }
    }

    @Test func optionalDefaultMixesNilAndValues() {
        var rng = LCRNG(seed: 6)
        let values = Optional<Int>.generator.array(100).run(using: &rng)
        let nilCount = values.filter { $0 == nil }.count
        #expect((20...80).contains(nilCount))
    }

    @Test func arrayDefaultCountWithinBounds() {
        var rng = LCRNG(seed: 7)
        for _ in 1...50 {
            let count = [Bool].generator.run(using: &rng).count
            #expect((0...10).contains(count))
        }
    }

    @Test func manualConformanceComposes() {
        struct Temperature: RandomGenerable, Equatable {
            var celsius: Double

            static var generator: some RandomGenerator<Temperature> {
                FloatGenerator(in: -40...50).map(Temperature.init)
            }
        }

        var rng = LCRNG(seed: 8)
        let sample = Temperature.generator.array(10).run(using: &rng)
        #expect(sample.count == 10)
        #expect(sample.allSatisfy { (-40.0...50.0).contains($0.celsius) })
    }
}
