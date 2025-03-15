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
        
        let zipGenerator = RandomGenerators.Zip3(intGenerator, doubleGenerator, boolGenerator)
        
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
        
        let zipGenerator = RandomGenerators.Zip4(intGenerator, doubleGenerator, charGenerator, boolGenerator)
        
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
        
        let zipGenerator = RandomGenerators.Zip3(intGenerator, doubleGenerator, boolGenerator).map { intVal, doubleVal, boolVal in
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
        
        let zipGenerator = RandomGenerators.Zip4(intGenerator, doubleGenerator, charGenerator, boolGenerator).map { intVal, doubleVal, charVal, boolVal in
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
}
