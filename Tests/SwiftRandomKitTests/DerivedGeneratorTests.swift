#if Derive
import Testing
import SwiftRandomKit

@RandomGenerable
private struct Fixture: Equatable {
    @Gen(IntGenerator(in: 18...99))
    var age: Int
    var name: String
    var isActive: Bool
    var nickname: String?
    let version = 1
}

@RandomGenerable
private struct Nested: Equatable {
    var fixture: Fixture
    @Gen(FloatGenerator(in: 0...1))
    var weight: Double
}

@RandomGenerable
private enum Weather: Equatable {
    case sunny
    case cloudy(coverage: Double)
    case windy(Int)
}

struct DerivedGeneratorTests {
    @Test func sameSeedProducesSameFixture() {
        var a = LCRNG(seed: 42)
        var b = LCRNG(seed: 42)
        #expect(Fixture.generator.run(using: &a) == Fixture.generator.run(using: &b))
    }

    @Test func genOverrideIsRespected() {
        var rng = LCRNG(seed: 1)
        for _ in 1...200 {
            let fixture = Fixture.generator.run(using: &rng)
            #expect((18...99).contains(fixture.age))
            #expect(fixture.version == 1)
        }
    }

    @Test func derivedStructUsesTypeDefaults() {
        var rng = LCRNG(seed: 2)
        let fixtures = Fixture.generator.array(100).run(using: &rng)
        #expect(fixtures.allSatisfy { $0.name.count == 8 })
        // The Optional default should produce both nil and non-nil over 100 runs.
        #expect(fixtures.contains { $0.nickname == nil })
        #expect(fixtures.contains { $0.nickname != nil })
    }

    @Test func derivedTypesNest() {
        var rng = LCRNG(seed: 3)
        let nested = Nested.generator.run(using: &rng)
        #expect((18...99).contains(nested.fixture.age))
        #expect((0.0...1.0).contains(nested.weight))
    }

    @Test func derivedEnumCoversAllCases() {
        var rng = LCRNG(seed: 4)
        var sawSunny = false
        var sawCloudy = false
        var sawWindy = false
        for _ in 1...300 {
            switch Weather.generator.run(using: &rng) {
            case .sunny: sawSunny = true
            case .cloudy: sawCloudy = true
            case .windy: sawWindy = true
            }
        }
        #expect(sawSunny && sawCloudy && sawWindy)
    }

    @Test func derivedGeneratorComposesWithCombinators() {
        var rng = LCRNG(seed: 5)
        let adults = Fixture.generator
            .filter { $0.age >= 50 }
            .array(10)
            .run(using: &rng)
        #expect(adults.allSatisfy { $0.age >= 50 })
    }
}
#endif
