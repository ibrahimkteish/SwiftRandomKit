import Testing
import SwiftRandomKit

typealias AnySendable = Any & Sendable

struct CollectTests {
    
    @Test func collectSameTypeGenerators() {
        // Test collecting values from generators of the same type
        let gen1 = IntGenerator(in: 1...10)
        let gen2 = IntGenerator(in: 11...20)
        let gen3 = IntGenerator(in: 21...30)
        
        let generators = [gen1, gen2, gen3]
        let collectGenerator = generators.collect()
        
        var rng = LCRNG(seed: 1)
        let result = collectGenerator.run(using: &rng)
        
        // With the seed 1, we expect these specific values
        #expect(result.count == 3)
        #expect(result[0] == 2)
        #expect(result[1] == 17)
        #expect(result[2] == 29)
    }
    
    @Test func collectEmptyArray() {
        // Test collecting from an empty array of generators
        let emptyGenerators: [IntGenerator<Int>] = []
        let collectGenerator = emptyGenerators.collect()
        
        var rng = LCRNG(seed: 1)
        let result = collectGenerator.run(using: &rng)
        
        #expect(result.count == 0)
        #expect(result.isEmpty)
    }
    
    @Test func collectSingleGenerator() {
        // Test collecting from a single generator
        let gen = IntGenerator(in: 1...100)
        let generators = [gen]
        let collectGenerator = generators.collect()
        
        var rng = LCRNG(seed: 1)
        let result = collectGenerator.run(using: &rng)
        
        #expect(result.count == 1)
        #expect(result[0] == 16)
    }
    
    @Test func collectWithMappedValues() {
        // Test collecting from generators that have been mapped
        let gen1 = IntGenerator(in: 1...10).map { $0 * 2 }
        let gen2 = IntGenerator(in: 11...20).map { $0 * 2 }
        
        let generators = [gen1, gen2]
        let collectGenerator = generators.collect()
        
        var rng = LCRNG(seed: 1)
        let result = collectGenerator.run(using: &rng)
        
        #expect(result.count == 2)
        #expect(result[0] == 4)  // 2 * 2
        #expect(result[1] == 34) // 17 * 2
    }
    
    @Test func collectWithTypeErasure() {
        // Test collecting generators after type erasure
        let gen1 = IntGenerator(in: 1...10).eraseToAnyRandomGenerator()
        let gen2 = IntGenerator(in: 11...20).eraseToAnyRandomGenerator()
        
        let generators = [gen1, gen2]
        let collectGenerator = generators.collect()
        
        var rng = LCRNG(seed: 1)
        let result = collectGenerator.run(using: &rng)
        
        #expect(result.count == 2)
        #expect(result[0] == 2)
        #expect(result[1] == 17)
    }
    
    @Test func collectDifferentTypes() {
        // Test collecting values from generators of different types using type erasure and Any
        let intGen = IntGenerator(in: 1...100).map { $0 as AnySendable}.eraseToAnyRandomGenerator()
        let boolGen = BoolGenerator().map { $0 as AnySendable}.eraseToAnyRandomGenerator()
        let stringGen = Always("random").map { $0 as AnySendable}.eraseToAnyRandomGenerator()
        
        let generators = [intGen, boolGen, stringGen]
        let collectGenerator = generators.collect()
        
        var rng = LCRNG(seed: 1)
        let result = collectGenerator.run(using: &rng)
        
        #expect(result.count == 3)
        #expect(result[0] as? Int == 16)
        #expect(result[1] as? Bool == true)
        #expect(result[2] as? String == "random")
    }
} 
