import XCTest
import SwiftRandomKit

final class CollectTests: XCTestCase {
    
    func testCollectSameTypeGenerators() {
        // Test collecting values from generators of the same type
        let gen1 = IntGenerator(in: 1...10)
        let gen2 = IntGenerator(in: 11...20)
        let gen3 = IntGenerator(in: 21...30)
        
        let generators = [gen1, gen2, gen3]
        let collectGenerator = generators.collect()
        
        var rng = LCRNG(seed: 1)
        let result = collectGenerator.run(using: &rng)
        
        // With the seed 1, we expect these specific values
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0], 2)
        XCTAssertEqual(result[1], 17)
        XCTAssertEqual(result[2], 29)
    }
    
    func testCollectEmptyArray() {
        // Test collecting from an empty array of generators
        let emptyGenerators: [IntGenerator<Int>] = []
        let collectGenerator = emptyGenerators.collect()
        
        var rng = LCRNG(seed: 1)
        let result = collectGenerator.run(using: &rng)
        
        XCTAssertEqual(result.count, 0)
        XCTAssertTrue(result.isEmpty)
    }
    
    func testCollectSingleGenerator() {
        // Test collecting from a single generator
        let gen = IntGenerator(in: 1...100)
        let generators = [gen]
        let collectGenerator = generators.collect()
        
        var rng = LCRNG(seed: 1)
        let result = collectGenerator.run(using: &rng)
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0], 16)
    }
    
    func testCollectWithMappedValues() {
        // Test collecting from generators that have been mapped
        let gen1 = IntGenerator(in: 1...10).map { $0 * 2 }
        let gen2 = IntGenerator(in: 11...20).map { $0 * 2 }
        
        let generators = [gen1, gen2]
        let collectGenerator = generators.collect()
        
        var rng = LCRNG(seed: 1)
        let result = collectGenerator.run(using: &rng)
        
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0], 4)  // 2 * 2
        XCTAssertEqual(result[1], 34) // 17 * 2
    }
    
    func testCollectWithTypeErasure() {
        // Test collecting generators after type erasure
        let gen1 = IntGenerator(in: 1...10).eraseToAnyRandomGenerator()
        let gen2 = IntGenerator(in: 11...20).eraseToAnyRandomGenerator()
        
        let generators = [gen1, gen2]
        let collectGenerator = generators.collect()
        
        var rng = LCRNG(seed: 1)
        let result = collectGenerator.run(using: &rng)
        
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0], 2)
        XCTAssertEqual(result[1], 12)
    }
    
    func testCollectDifferentTypes() {
        // Test collecting values from generators of different types using type erasure and Any
        let intGen = IntGenerator(in: 1...100).map { $0 as Any }.eraseToAnyRandomGenerator()
        let boolGen = BoolRandomGenerator().map { $0 as Any }.eraseToAnyRandomGenerator()
        let stringGen = Always("random").map { $0 as Any }.eraseToAnyRandomGenerator()
        
        let generators = [intGen, boolGen, stringGen]
        let collectGenerator = generators.collect()
        
        var rng = LCRNG(seed: 1)
        let result = collectGenerator.run(using: &rng)
        
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0] as? Int, 16)
        XCTAssertEqual(result[1] as? Bool, true)
        XCTAssertEqual(result[2] as? String, "random")
    }
} 