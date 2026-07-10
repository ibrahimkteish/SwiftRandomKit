import Testing
import SwiftRandomKit

struct FloatGeneratorTests {
    @Test func float16Generator() {
        let generator16 = FloatGenerator<Float16>(in: 0...1)
        var rng = LCRNG(seed: 1)
        
        #expect(generator16.run(using: &rng) == 0.641)
    }
    
    @Test func float32Generator() {
        let generator32 = FloatGenerator<Float32>(in: 0...1)
        var rng = LCRNG(seed: 1)
        
        for _ in 0..<1000 {
            let value = generator32.run(using: &rng)
            #expect(value >= 0.0 && value <= 1.0, "Generated float should be between 0 and 1")
        }
    }
    
    @Test func float64Generator() {
        let generator64 = FloatGenerator<Float64>(in: 0...1)
        var rng = LCRNG(seed: 1)
        
        for _ in 0..<1000 {
            let value = generator64.run(using: &rng)
            #expect(value >= 0.0 && value <= 1.0, "Generated float should be between 0 and 1")
        }
    }
    
    @Test func doubleGenerator() {
        let generator = FloatGenerator(in: 0...1)
        var rng = LCRNG(seed: 1)
        
        for _ in 0..<1000 {
            let value = generator.run(using: &rng)
            #expect(value >= 0.0 && value <= 1.0, "Generated double should be between 0 and 1")
        }
    }
} 