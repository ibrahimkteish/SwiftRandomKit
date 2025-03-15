import Testing
import SwiftRandomKit

@Suite("Float Generator Tests")
struct FloatGeneratorTests {
    @Test("Float16 Generator produces expected values")
    func testFloat16Generator() {
        let generator16 = FloatGenerator<Float16>(in: 0...1)
        var rng = LCRNG(seed: 1)
        
        #expect(generator16.run(using: &rng) == 0.641)
    }
    
    @Test("Float32 Generator produces values within range")
    func testFloat32Generator() {
        let generator32 = FloatGenerator<Float32>(in: 0...1)
        var rng = LCRNG(seed: 1)
        
        for _ in 0..<1000 {
            let value = generator32.run(using: &rng)
            #expect(value >= 0.0 && value <= 1.0, "Generated float should be between 0 and 1")
        }
    }
    
    @Test("Float64 Generator produces values within range")
    func testFloat64Generator() {
        let generator64 = FloatGenerator<Float64>(in: 0...1)
        var rng = LCRNG(seed: 1)
        
        for _ in 0..<1000 {
            let value = generator64.run(using: &rng)
            #expect(value >= 0.0 && value <= 1.0, "Generated float should be between 0 and 1")
        }
    }
    
    @Test("Double Generator produces values within range")
    func testDoubleGenerator() {
        let generator = FloatGenerator(in: 0...1)
        var rng = LCRNG(seed: 1)
        
        for _ in 0..<1000 {
            let value = generator.run(using: &rng)
            #expect(value >= 0.0 && value <= 1.0, "Generated double should be between 0 and 1")
        }
    }
} 