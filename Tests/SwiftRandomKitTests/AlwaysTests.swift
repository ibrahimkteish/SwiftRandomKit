import Testing
@testable import SwiftRandomKit

struct AlwaysTests {
    
    @Test func alwaysBasicUsage() {
        // Create an Always generator with different types
        let intGenerator = Always(42)
        let stringGenerator = Always("hello")
        let boolGenerator = Always(true)
        let doubleGenerator = Always(3.14)
        
        // Test with different RNGs to ensure the value doesn't change
        var rng1 = LCRNG(seed: 123)
        var rng2 = LCRNG(seed: 456)
        
        // Integer tests
        #expect(intGenerator.run(using: &rng1) == 42, "Always should return the same integer value")
        #expect(intGenerator.run(using: &rng2) == 42, "Always should return the same integer value with different RNG")
        
        // String tests
        #expect(stringGenerator.run(using: &rng1) == "hello", "Always should return the same string value")
        #expect(stringGenerator.run(using: &rng2) == "hello", "Always should return the same string value with different RNG")
        
        // Boolean tests
        #expect(boolGenerator.run(using: &rng1), "Always should return the same boolean value")
        #expect(boolGenerator.run(using: &rng2), "Always should return the same boolean value with different RNG")
        
        // Double tests
        #expect(doubleGenerator.run(using: &rng1) == 3.14, "Always should return the same double value")
        #expect(doubleGenerator.run(using: &rng2) == 3.14, "Always should return the same double value with different RNG")
    }
    
    @Test func alwaysWithMultipleRuns() {
        // Create an Always generator
        let generator = Always(100)
        
        // Run it multiple times with the same RNG to verify consistency
        var rng = LCRNG(seed: 42)
        
        for _ in 1...10 {
            #expect(generator.run(using: &rng) == 100, "Always should return the same value on multiple runs")
        }
    }
    
    @Test func alwaysWithComplexType() {
        // Test with a more complex type (struct)
        struct Person {
            let name: String
            let age: Int
        }
        
        let person = Person(name: "John", age: 30)
        let personGenerator = Always(person)
        
        var rng = LCRNG(seed: 42)
        let result = personGenerator.run(using: &rng)
        
        #expect(result.name == "John", "Always should preserve struct property values")
        #expect(result.age == 30, "Always should preserve struct property values")
    }
    
    @Test func alwaysMap() {
        // Test the map function on Always
        let intGenerator = Always(5)
        let doubledGenerator = intGenerator.map { $0 * 2 }
        
        var rng = LCRNG(seed: 42)
        let result = doubledGenerator.run(using: &rng)
        
        #expect(result == 10, "Always.map should transform the value")
        
        // Test with string transformation
        let stringGenerator = Always("hello")
        let uppercaseGenerator = stringGenerator.map { $0.uppercased() }
        
        let stringResult = uppercaseGenerator.run(using: &rng)
        #expect(stringResult == "HELLO", "Always.map should transform string values")
    }
    
    @Test func alwaysCollect() {
        // Test the collect() function
        let generator = Always(42)
        let collectedGenerator = generator.collect()
        
        var rng = LCRNG(seed: 42)
        let result = collectedGenerator.run(using: &rng)
        
        #expect(result == [42], "Always.collect should wrap the value in an array")
    }
    
    @Test func alwaysRemoveDuplicates() {
        // For an Always generator, removeDuplicates() should have no effect
        let generator = Always(42)
        let dedupedGenerator = generator.removeDuplicates()
        
        var rng = LCRNG(seed: 42)
        let result = dedupedGenerator.run(using: &rng)
        
        #expect(result == 42, "Always.removeDuplicates should return the same generator")
        
        // Test with custom predicate
        let customDedupedGenerator = generator.removeDuplicates { _, _ in true }
        let customResult = customDedupedGenerator.run(using: &rng)
        
        #expect(customResult == 42, "Always.removeDuplicates with custom predicate should return the same generator")
    }
    
    @Test func alwaysVoid() {
        // Test with Void type
        let voidGenerator = Always(())
        
        var rng = LCRNG(seed: 42)
        voidGenerator.run(using: &rng)
        
        // There's no real assertion here, we're just making sure it compiles and runs
        #expect(true, "Always<Void> should run without errors")
    }
    
    @Test func alwaysIgnoresRng() {
        let constantGenerator = Always(99)

        var rng = LCRNG(seed: 42)
        let result = constantGenerator.run(using: &rng)

        #expect(result == 99, "Always should produce its value regardless of the RNG")
    }
    
    @Test func alwaysWithCollections() {
        // Test with collections
        let arrayGenerator = Always([1, 2, 3, 4, 5])
        let dictGenerator = Always(["a": 1, "b": 2, "c": 3])
        
        var rng = LCRNG(seed: 42)
        
        // Test array
        let arrayResult = arrayGenerator.run(using: &rng)
        #expect(arrayResult == [1, 2, 3, 4, 5], "Always should work with arrays")
        
        // Test dictionary
        let dictResult = dictGenerator.run(using: &rng)
        #expect(dictResult == ["a": 1, "b": 2, "c": 3], "Always should work with dictionaries")
    }
    
    @Test func collectionAsGenerator() {
        // Test the asGenerator() extension on Collection
        let array = [1, 2, 3, 4, 5]
        let generator = array.asGenerator()
        
        var rng = LCRNG(seed: 42)
        let result = generator.run(using: &rng)
        
        #expect(result == [1, 2, 3, 4, 5], "Collection.asGenerator() should create an Always generator")
    }
    
    @Test func equatableConformance() {
        // Test Equatable conformance of Always
        let gen1 = Always(42)
        let gen2 = Always(42)
        let gen3 = Always(43)
        
        #expect(gen1 == gen2, "Always generators with the same value should be equal")
        #expect(gen1 != gen3, "Always generators with different values should not be equal")
    }
} 
