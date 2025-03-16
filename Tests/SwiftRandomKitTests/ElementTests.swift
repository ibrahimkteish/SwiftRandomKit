import XCTest
import SwiftRandomKit

final class ElementTests: XCTestCase {
    
    func testElementFromStaticArray() {
        // Given a static array, test that element() selects items from it
        let fruits = ["apple", "banana", "orange", "grape", "kiwi"]
        let fruitGen = Always(fruits).element()
        
        var rng = LCRNG(seed: 42)
        let selectedFruit = fruitGen.run(using: &rng)
        
        // With LCRNG seed 42, we should get a specific fruit
        XCTAssertEqual(selectedFruit, "orange", "LCRNG with seed 42 should deterministically select 'orange'")
        
        // Rather than testing a sequence, verify we get a different value with a different seed
        var rng2 = LCRNG(seed: 43)
        let selectedFruit2 = fruitGen.run(using: &rng2)
        XCTAssertNotEqual(selectedFruit, selectedFruit2, "Different seeds should produce different results")
        
        // Also verify we can get all fruits over time
        var rngForFullTest = LCRNG(seed: 123) // Different seed for this part
        var uniqueSelections = Set<String>()
        for _ in 1...20 {
            if let fruit = fruitGen.run(using: &rngForFullTest) {
                uniqueSelections.insert(fruit)
            }
        }
        
        // With 20 selections from 5 items, we should get all 5 items
        XCTAssertEqual(uniqueSelections.count, 5, "All fruits should be selected with enough iterations")
    }
    
    func testElementFromEmptyCollection() {
        // Test that selecting from an empty collection returns nil
        let emptyArray: [Int] = []
        let emptyGen = Always(emptyArray).element()
        
        var rng = LCRNG(seed: 42)
        let result = emptyGen.run(using: &rng)
        
        XCTAssertNil(result, "Selection from empty collection should be nil")
    }
    
    func testElementFromSingleItemCollection() {
        // Test that selecting from a single-item collection always returns that item
        let singleItem = ["only option"]
        let singleItemGen = Always(singleItem).element()
        
        var rng = LCRNG(seed: 42)
        let result = singleItemGen.run(using: &rng)
        
        XCTAssertEqual(result, "only option", "Single item collection should always return that item")
        
        // Verify multiple runs also return the same item
        for _ in 1...5 {
            XCTAssertEqual(singleItemGen.run(using: &rng), "only option")
        }
    }
    
    func testElementFromDynamicCollection() {
        // Test selecting elements from dynamically generated collections
        // We'll use a fixed seed so we can predict the results
        var rng = LCRNG(seed: 42)
        
        // For this test, use fixed arrays with fixed seeds for predictable results
        let array1 = Array(1...3)
        let elementGen1 = Always(array1).element()
        let firstSelection = elementGen1.run(using: &rng)
        XCTAssertEqual(firstSelection, 2, "With LCRNG seed 42 on array [1,2,3], should select 2")
        
        let array2 = Array(1...5)
        let elementGen2 = Always(array2).element()
        let secondSelection = elementGen2.run(using: &rng)
        XCTAssertEqual(secondSelection, 5, "Next value in sequence should be 5")
        
        // Also test with an array generator, but still verify exact results
        let dynamicArrayGen = IntGenerator(in: 1...5).map { Array(1...$0) }
        
        // With seed 42, let's verify what IntGenerator(1...5) produces
        let arrayResult = dynamicArrayGen.run(using: &rng)
        XCTAssertEqual(arrayResult, [1, 2, 3], "IntGenerator with seed 42 and next LCRNG value produces [1,2,3]")
        
        let elementResult = arrayResult.randomElement(using: &rng)
        XCTAssertEqual(elementResult, 3, "randomElement on [1,2,3] with next LCRNG value selects 3")
    }
    
    func testElementDistribution() {
        // Test that element selection is approximately uniform
        let options = [1, 2, 3, 4, 5]
        let optionsGen = Always(options).element()
        
        // For distribution test, use large number of iterations
        // But first verify deterministic behavior with a fixed seed
        var rng1 = LCRNG(seed: 123)
        var rng2 = LCRNG(seed: 123)
        
        // Same seed should produce the same results
        for _ in 1...5 {
            let value1 = optionsGen.run(using: &rng1)
            let value2 = optionsGen.run(using: &rng2)
            XCTAssertEqual(value1, value2, "Same seed should produce same results")
        }
        
        // Now check overall distribution with many iterations
        var rng = LCRNG(seed: 456) // Different seed for distribution test
        var counts = [1: 0, 2: 0, 3: 0, 4: 0, 5: 0]
        
        // Generate a large number of elements to check distribution
        for _ in 1...1000 {
            if let selected = optionsGen.run(using: &rng) {
                counts[selected, default: 0] += 1
            }
        }
        
        // In a uniform distribution with 1000 samples and 5 options,
        // each option should appear approximately 200 times
        for count in counts.values {
            XCTAssertGreaterThan(count, 150, "Each option should be selected approximately 200 times")
            XCTAssertLessThan(count, 250, "Each option should be selected approximately 200 times")
        }
    }
    
    func testElementWithNestedCollections() {
        // Test element selection with nested collections
        let nestedArrays = [
            [1, 2, 3],
            [4, 5],
            [6, 7, 8, 9]
        ]
        
        let nestedGen = Always(nestedArrays).element()
        
        var rng = LCRNG(seed: 42)
        let selectedArray = nestedGen.run(using: &rng)
        
        // With seed 42, we know exactly which array should be selected
        XCTAssertEqual(selectedArray!, [4, 5], "LCRNG with seed 42 should select the second array")
        
        // Now select from the selected array with the next LCRNG value
        let innerGen = Always([4, 5]).element()
        let innerElement = innerGen.run(using: &rng)
        
        XCTAssertEqual(innerElement, 5, "Next LCRNG value should select the element 5")
    }
    
    func testElementWithRandomGeneratorElement() {
        // Test the randomGeneratorElement convenience method on collections
        let numbers = [10, 20, 30, 40, 50]
        let numberGen = numbers.randomGeneratorElement()
        
        var rng = LCRNG(seed: 42)
        let selectedNumber = numberGen.run(using: &rng)
        
        // With seed 42, verify exact result
        XCTAssertEqual(selectedNumber, 30, "LCRNG with seed 42 should select 30 from the array")
        
        // Verify the next few values in sequence
        XCTAssertEqual(numberGen.run(using: &rng), 50, "Next value should be 50")
        XCTAssertEqual(numberGen.run(using: &rng), 30, "Next value should be 30")
    }
} 