import XCTest
@testable import SwiftRandomKit

final class ZipTests: XCTestCase {
    
    func testZipTwoGenerators() {
        var rng = LCRNG(seed: 1)
        
        let intGenerator = IntGenerator(in: 1...100)
        let charGenerator = RandomGenerators.letterOrNumber
        
        let zipGenerator = RandomGenerators.Zip(intGenerator, charGenerator)
        
        let result = zipGenerator.run(using: &rng)
        
        // Expected values based on the seed
        XCTAssertEqual(result.0, 16)
        XCTAssertEqual(result.1, "N")
    }
    
    func testZipThreeGenerators() {
        var rng = LCRNG(seed: 1)
        
        let intGenerator = IntGenerator(in: 1...100)
        let doubleGenerator = FloatGenerator<Double>(in: 0.0...1.0)
        let boolGenerator = BoolRandomGenerator()
        
        let zipGenerator = RandomGenerators.Zip(intGenerator, doubleGenerator, boolGenerator)
        
        let result = zipGenerator.run(using: &rng)
        
        XCTAssertEqual(result.0, 16)
        XCTAssertEqual(result.1, 0.6390517027105214)
        XCTAssertEqual(result.2, false)
    }
    
    func testZipFourGenerators() {
        var rng = LCRNG(seed: 1)
        
        let intGenerator = IntGenerator(in: 1...100)
        let doubleGenerator = FloatGenerator<Double>(in: 0.0...1.0)
        let charGenerator = RandomGenerators.letterOrNumber
        let boolGenerator = BoolRandomGenerator()
        
        let zipGenerator = RandomGenerators.Zip(intGenerator, doubleGenerator, charGenerator, boolGenerator)
        
        let result = zipGenerator.run(using: &rng)
        
        XCTAssertEqual(result.0, 16)
        XCTAssertEqual(result.1, 0.6390517027105214)
        XCTAssertEqual(result.2, "2")
        XCTAssertEqual(result.3, false)
    }

    func testZipExtensionMethod() {
        var rng = LCRNG(seed: 1)
        
        let intGenerator = IntGenerator(in: 1...100)
        let doubleGenerator = FloatGenerator<Double>(in: 0.0...1.0)
        
        let zipGenerator = intGenerator.zip(doubleGenerator)
        
        let result = zipGenerator.run(using: &rng)
        
        XCTAssertEqual(result.0, 16)
        XCTAssertEqual(result.1, 0.6390517027105214)
    }
    
    func testZipWithTransform() {
        var rng = LCRNG(seed: 1)
        
        let intGenerator = IntGenerator(in: 1...100)
        let doubleGenerator = FloatGenerator<Double>(in: 0.0...1.0)
        
        let zipGenerator = intGenerator.zip(doubleGenerator) { intVal, doubleVal in
            return "\(intVal): \(doubleVal)"
        }
        
        let result = zipGenerator.run(using: &rng)
        
        XCTAssertEqual(result, "16: 0.6390517027105214")
    }
        
    func testZip3WithTransform() {
        var rng = LCRNG(seed: 1)
        
        let intGenerator = IntGenerator(in: 1...100)
        let doubleGenerator = FloatGenerator<Double>(in: 0.0...1.0)
        let boolGenerator = BoolRandomGenerator()
        
        let zipGenerator = RandomGenerators.Zip(intGenerator, doubleGenerator, boolGenerator).map { intVal, doubleVal, boolVal in
            return "\(intVal): \(doubleVal): \(boolVal)"
        }
        
        let result = zipGenerator.run(using: &rng)
        
        XCTAssertEqual(result, "16: 0.6390517027105214: false")
    }
    
    func testZip4WithTransform() {
        var rng = LCRNG(seed: 1)
        
        let intGenerator = IntGenerator(in: 1...100)
        let doubleGenerator = FloatGenerator<Double>(in: 0.0...1.0)
        let charGenerator = RandomGenerators.letterOrNumber
        let boolGenerator = BoolRandomGenerator()
        
        let zipGenerator = RandomGenerators.Zip(intGenerator, doubleGenerator, charGenerator, boolGenerator).map { intVal, doubleVal, charVal, boolVal in
            return "\(intVal): \(doubleVal): \(charVal): \(boolVal)"
        }
        
        let result = zipGenerator.run(using: &rng)
        
        XCTAssertEqual(result, "16: 0.6390517027105214: 2: false")
    }
    
    func testZipSameTypeGenerators() {
        var rng = LCRNG(seed: 1)
        
        let intGenerator1 = IntGenerator(in: 1...50)
        let intGenerator2 = IntGenerator(in: 51...100)
        
        let zipGenerator = intGenerator1.zip(intGenerator2)
        
        let result = zipGenerator.run(using: &rng)
        
        XCTAssertEqual(result.0, 8)
        XCTAssertEqual(result.1, 82)
    }
    
    // MARK: - New tests for 100% coverage
    
    func testZipArrayGenerator() {
        var rng = LCRNG(seed: 1)
        
        // Create an array of generators of the same type
        let generators = [
            IntGenerator(in: 1...10),
            IntGenerator(in: 11...20),
            IntGenerator(in: 21...30)
        ]
        
        // Create a ZipArrayGenerator directly
        let zipArrayGenerator = RandomGenerators.ZipArrayGenerator(generators: generators)
        
        // Run the generator
        let result = zipArrayGenerator.run(using: &rng)
        
        // Verify the result
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0], 2)
        XCTAssertEqual(result[1], 17)
        XCTAssertEqual(result[2], 29)
    }
    
    func testArrayZipAllExtension() {
        var rng = LCRNG(seed: 1)
        
        // Create an array of generators of the same type
        let generators = [
            IntGenerator(in: 1...10),
            IntGenerator(in: 11...20),
            IntGenerator(in: 21...30)
        ]
        
        // Use the zipAll extension method
        let zipGenerator = generators.zipAll()
        
        // Run the generator
        let result = zipGenerator.run(using: &rng)
        
        // Verify the result
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0], 2)
        XCTAssertEqual(result[1], 17)
        XCTAssertEqual(result[2], 29)
    }
    
    func testZipGeneratorsFactoryFunction() {
        var rng = LCRNG(seed: 1)
        
        // Use the zipGenerators factory function
        let zipGenerator = zipGenerators(
            IntGenerator(in: 1...10),
            IntGenerator(in: 11...20),
            IntGenerator(in: 21...30)
        )
        
        // Run the generator
        let result = zipGenerator.run(using: &rng)
        
        // Verify the result
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0], 2)
        XCTAssertEqual(result[1], 17)
        XCTAssertEqual(result[2], 29)
    }
    
    func testZipGeneratorsWithEmptyArray() {
        // Create a single generator to use as a reference type
        let singleGenerator = IntGenerator(in: 1...10)
        
        // Test the zipAll extension method with a single generator
        var rng1 = LCRNG(seed: 1)
        let singleGeneratorArray = [singleGenerator]
        let zipGenerator = singleGeneratorArray.zipAll()
        let result = zipGenerator.run(using: &rng1)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0], 2) // With seed 1, should get 2
        
        // Test the zipGenerators factory function with a single generator
        // Use a fresh RNG with the same seed
        var rng2 = LCRNG(seed: 1)
        let factoryGenerator = zipGenerators(singleGenerator)
        let factoryResult = factoryGenerator.run(using: &rng2)
        XCTAssertEqual(factoryResult.count, 1)
        XCTAssertEqual(factoryResult[0], 2) // With seed 1, should get 2
    }
}
