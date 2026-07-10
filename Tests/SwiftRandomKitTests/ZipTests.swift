import Testing
@testable import SwiftRandomKit

struct ZipTests {
    
    @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
    @Test func zipTwoGenerators() {
        var rng = LCRNG(seed: 1)
        
        let intGenerator = IntGenerator(in: 1...100)
        let charGenerator = RandomGenerators.letterOrNumber
        
        let zipGenerator = RandomGenerators.Zip(intGenerator, charGenerator)
        
        let result = zipGenerator.run(using: &rng)
        
        // Expected values based on the seed
        #expect(result.0 == 16)
        #expect(result.1 == "N")
    }
    
    @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
    @Test func zipThreeGenerators() {
        var rng = LCRNG(seed: 1)
        
        let intGenerator = IntGenerator(in: 1...100)
        let doubleGenerator = FloatGenerator<Double>(in: 0.0...1.0)
        let boolGenerator = BoolGenerator()
        
        let zipGenerator = RandomGenerators.Zip(intGenerator, doubleGenerator, boolGenerator)
        
        let result = zipGenerator.run(using: &rng)
        
        #expect(result.0 == 16)
        #expect(result.1 == 0.6390517027105214)
        #expect(result.2 == false)
    }
    
    @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
    @Test func zipFourGenerators() {
        var rng = LCRNG(seed: 1)
        
        let intGenerator = IntGenerator(in: 1...100)
        let doubleGenerator = FloatGenerator<Double>(in: 0.0...1.0)
        let charGenerator = RandomGenerators.letterOrNumber
        let boolGenerator = BoolGenerator()
        
        let zipGenerator = RandomGenerators.Zip(intGenerator, doubleGenerator, charGenerator, boolGenerator)
        
        let result = zipGenerator.run(using: &rng)
        
        #expect(result.0 == 16)
        #expect(result.1 == 0.6390517027105214)
        #expect(result.2 == "2")
        #expect(result.3 == false)
    }

    @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
    @Test func zipExtensionMethod() {
        var rng = LCRNG(seed: 1)
        
        let intGenerator = IntGenerator(in: 1...100)
        let doubleGenerator = FloatGenerator<Double>(in: 0.0...1.0)
        
        let zipGenerator = intGenerator.zip(doubleGenerator)
        
        let result = zipGenerator.run(using: &rng)
        
        #expect(result.0 == 16)
        #expect(result.1 == 0.6390517027105214)
    }
    
    @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
    @Test func zipWithTransform() {
        var rng = LCRNG(seed: 1)
        
        let intGenerator = IntGenerator(in: 1...100)
        let doubleGenerator = FloatGenerator<Double>(in: 0.0...1.0)
        
        let zipGenerator = intGenerator.zip(doubleGenerator) { intVal, doubleVal in
            return "\(intVal): \(doubleVal)"
        }
        
        let result = zipGenerator.run(using: &rng)
        
        #expect(result == "16: 0.6390517027105214")
    }
        
    @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
    @Test func zip3WithTransform() {
        var rng = LCRNG(seed: 1)
        
        let intGenerator = IntGenerator(in: 1...100)
        let doubleGenerator = FloatGenerator<Double>(in: 0.0...1.0)
        let boolGenerator = BoolGenerator()
        
        let zipGenerator = RandomGenerators.Zip(intGenerator, doubleGenerator, boolGenerator).map { intVal, doubleVal, boolVal in
            return "\(intVal): \(doubleVal): \(boolVal)"
        }
        
        let result = zipGenerator.run(using: &rng)
        
        #expect(result == "16: 0.6390517027105214: false")
    }
    
    @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
    @Test func zip4WithTransform() {
        var rng = LCRNG(seed: 1)
        
        let intGenerator = IntGenerator(in: 1...100)
        let doubleGenerator = FloatGenerator<Double>(in: 0.0...1.0)
        let charGenerator = RandomGenerators.letterOrNumber
        let boolGenerator = BoolGenerator()
        
        let zipGenerator = RandomGenerators.Zip(intGenerator, doubleGenerator, charGenerator, boolGenerator).map { intVal, doubleVal, charVal, boolVal in
            return "\(intVal): \(doubleVal): \(charVal): \(boolVal)"
        }
        
        let result = zipGenerator.run(using: &rng)
        
        #expect(result == "16: 0.6390517027105214: 2: false")
    }
    
    @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
    @Test func zipSameTypeGenerators() {
        var rng = LCRNG(seed: 1)
        
        let intGenerator1 = IntGenerator(in: 1...50)
        let intGenerator2 = IntGenerator(in: 51...100)
        
        let zipGenerator = intGenerator1.zip(intGenerator2)
        
        let result = zipGenerator.run(using: &rng)
        
        #expect(result.0 == 8)
        #expect(result.1 == 82)
    }
    
    @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
    @Test func collectReplacesZipArray() {
        var rng = LCRNG(seed: 1)

        // Same-type generators combine into an array via collect()
        let generators = [
            IntGenerator(in: 1...10),
            IntGenerator(in: 11...20),
            IntGenerator(in: 21...30)
        ]

        let result = generators.collect().run(using: &rng)

        #expect(result.count == 3)
        #expect(result[0] == 2)
        #expect(result[1] == 17)
        #expect(result[2] == 29)
    }
}
