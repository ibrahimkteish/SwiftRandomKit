import XCTest
import SwiftRandomKit

final class ElementTests: XCTestCase {
    
    func testElementFromStaticArray() {
        // Given a static array, test that element() selects items from it
        let fruits = ["apple", "banana", "orange", "grape", "kiwi"]
        let fruitGen = Always(fruits).element()
        
        var rng = LCRNG(seed: 42)
        let selectedFruit = fruitGen.run(using: &rng)
        
        // Verify a fruit was selected
        XCTAssertNotNil(selectedFruit)
        XCTAssertTrue(fruits.contains(selectedFruit!))
        
        // Test multiple selections to ensure different items can be chosen
        var uniqueSelections = Set<String>()
        for _ in 1...20 {
            if let fruit = fruitGen.run(using: &rng) {
                uniqueSelections.insert(fruit)
            }
        }
        
        // With 20 selections from 5 items, we should get at least 3 unique items
        XCTAssertGreaterThanOrEqual(uniqueSelections.count, 3)
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
        for _ in 1...10 {
            let result = singleItemGen.run(using: &rng)
            XCTAssertEqual(result, "only option")
        }
    }
    
    func testElementFromDynamicCollection() {
        // Test selecting elements from dynamically generated collections
        // We'll use a fixed seed so we can predict the results
        var rng = LCRNG(seed: 42)
        
        // For this test, let's use a more predictable approach
        for size in 1...5 {
            // Create a fixed array of this size
            let array = Array(1...size)
            let arrayGen = Always(array)
            let elementGen = arrayGen.element()
            
            // Select a random element and verify it's within the valid range
            if let selectedElement = elementGen.run(using: &rng) {
                XCTAssertGreaterThanOrEqual(selectedElement, 1)
                XCTAssertLessThanOrEqual(selectedElement, size)
            } else {
                XCTFail("Should have selected an element from non-empty array")
            }
        }
        
        // Also test a truly dynamic array generation
        let dynamicArrayGen = IntGenerator(in: 1...5).map { Array(1...$0) }
        var resultValues = [Int]()
        
        // Run several times to collect some results
        for _ in 1...10 {
            let array = dynamicArrayGen.run(using: &rng)
            let randomElement = array.randomElement(using: &rng)
            
            if let element = randomElement {
                // Verify the element is valid for the array that was generated
                XCTAssertGreaterThanOrEqual(element, 1)
                XCTAssertLessThanOrEqual(element, array.count)
                resultValues.append(element)
            }
        }
        
        // We should have collected some values
        XCTAssertFalse(resultValues.isEmpty)
    }
    
    func testElementDistribution() {
        // Test that element selection is approximately uniform
        let options = [1, 2, 3, 4, 5]
        let optionsGen = Always(options).element()
        
        var rng = LCRNG(seed: 123)
        var counts = [1: 0, 2: 0, 3: 0, 4: 0, 5: 0]
        
        // Generate a large number of elements to check distribution
        for _ in 1...1000 {
            if let selected = optionsGen.run(using: &rng) {
                counts[selected, default: 0] += 1
            }
        }
        
        // In a uniform distribution with 1000 samples and 5 options,
        // each option should appear approximately 200 times (1000/5)
        // Allow for some variation with a reasonable margin
        for count in counts.values {
            XCTAssertGreaterThan(count, 150, "Each option should be selected approximately 200 times (with a reasonable margin)")
            XCTAssertLessThan(count, 250, "Each option should be selected approximately 200 times (with a reasonable margin)")
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
        
        XCTAssertNotNil(selectedArray)
        XCTAssertTrue(nestedArrays.contains(selectedArray!))
        
        // Now select from the selected array
        if let array = selectedArray {
            let innerGen = Always(array).element()
            let innerElement = innerGen.run(using: &rng)
            
            XCTAssertNotNil(innerElement)
            XCTAssertTrue(array.contains(innerElement!))
        }
    }
    
    func testElementWithRandomGeneratorElement() {
        // Test the randomGeneratorElement convenience method on collections
        let numbers = [10, 20, 30, 40, 50]
        let numberGen = numbers.randomGeneratorElement()
        
        var rng = LCRNG(seed: 42)
        let selectedNumber = numberGen.run(using: &rng)
        
        XCTAssertNotNil(selectedNumber)
        XCTAssertTrue(numbers.contains(selectedNumber!))
    }
} 