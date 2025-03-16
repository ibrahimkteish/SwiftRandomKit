import XCTest
import SwiftRandomKit

final class RemoveDuplicatesTests: XCTestCase {
    func testRemoveDuplicatesWithEquatable() {
        // Create a generator that only produces a few values
        let limitedGenerator = [1, 2, 3, 3, 3, 4, 5].randomGeneratorElement()
        
        // Create a generator that removes duplicates
        let noDuplicatesGenerator = limitedGenerator.removeDuplicates()
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 42)
        
        // With seed 42, we can predict the exact sequence
        let expectedSequence = [3, 5, 3, 4, 1, 2, 3, 5, 1, 3]
        
        for expected in expectedSequence {
            let value = noDuplicatesGenerator.run(using: &rng)
            XCTAssertEqual(value, expected)
        }
        
        // Verify that no consecutive duplicates appear
        var previousValue: Int? = nil
        rng = LCRNG(seed: 100) // Different seed
        for _ in 0..<20 {
            let value = noDuplicatesGenerator.run(using: &rng)
            if let previous = previousValue {
                XCTAssertNotEqual(value, previous, "Found consecutive duplicate: \(String(describing: value))")
            }
            previousValue = value
        }
    }
    
    func testRemoveDuplicatesWithPredicate() {
        // Create a generator for points (tuples)
        let pointGenerator = IntGenerator(in: 0...5).tuple()
        
        // Create a generator that removes duplicates based on a custom predicate
        // Two points are considered "duplicates" if they have the same x-coordinate
        let noDuplicatesGenerator = pointGenerator.removeDuplicates(by: { point1, point2 in
            point1.0 == point2.0 // Compare x-coordinates
        })
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 42)
        
        // With seed 42, we can predict the first few points
        let firstPoint = noDuplicatesGenerator.run(using: &rng)
        XCTAssertEqual(firstPoint.0, 3)
        XCTAssertEqual(firstPoint.1, 5)
        
        let secondPoint = noDuplicatesGenerator.run(using: &rng)
        XCTAssertEqual(secondPoint.0, 0)
        XCTAssertEqual(secondPoint.1, 1)
        
        // Verify that no consecutive points have the same x-coordinate
        var previousPoint: (Int, Int)? = nil
        rng = LCRNG(seed: 100) // Different seed
        for _ in 0..<20 {
            let point = noDuplicatesGenerator.run(using: &rng)
            if let previous = previousPoint {
                XCTAssertNotEqual(point.0, previous.0, "Found consecutive points with same x-coordinate: \(point) and \(previous)")
            }
            previousPoint = point
        }
    }
    
    func testRemoveDuplicatesWithMaxAttempts() {
        // Create a generator that always produces the same value
        let constantGenerator = Always(42)
        
        // Create a generator that tries to remove duplicates but with a low max attempts
        let noDuplicatesGenerator = constantGenerator.removeDuplicates(maxAttempts: 3)
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 42)
        
        // Since the upstream generator always produces 42, and max attempts is 3,
        // the generator should give up and return 42 anyway
        let value1 = noDuplicatesGenerator.run(using: &rng)
        let value2 = noDuplicatesGenerator.run(using: &rng)
        
        XCTAssertEqual(value1, 42)
        XCTAssertEqual(value2, 42)
        
        // Run a few more times to verify it always returns 42
        for _ in 0..<5 {
            XCTAssertEqual(noDuplicatesGenerator.run(using: &rng), 42)
        }
    }
    
    func testRemoveDuplicatesWithCustomType() {
        // Define a custom type
        struct Person {
            let id: Int
            let name: String
        }
        
        // Create a generator for Person objects
        let personGenerator = IntGenerator(in: 1...5).map { id in
            let names = ["Alice", "Bob", "Charlie", "David", "Eve"]
            return Person(id: id, name: names[id - 1])
        }
        
        // Create a generator that removes duplicates based on ID
        let noDuplicatesGenerator = personGenerator.removeDuplicates(by: { person1, person2 in
            person1.id == person2.id
        })
        
        // Test with a deterministic RNG
        var rng = LCRNG(seed: 42)
        
        // With seed 42, IntGenerator(1...5) produces the sequence [3, 5, 3, 4, 1, 2, 4, 5, 5, 1]
        // After removing duplicates, we should get [3, 5, 4, 1, 2]
        let firstPerson = noDuplicatesGenerator.run(using: &rng)
        XCTAssertEqual(firstPerson.id, 3)
        XCTAssertEqual(firstPerson.name, "Charlie")
        
        let secondPerson = noDuplicatesGenerator.run(using: &rng)
        XCTAssertEqual(secondPerson.id, 5)
        XCTAssertEqual(secondPerson.name, "Eve")
        
        let thirdPerson = noDuplicatesGenerator.run(using: &rng)
        XCTAssertEqual(thirdPerson.id, 3)
        XCTAssertEqual(thirdPerson.name, "Charlie")
        
        let fourthPerson = noDuplicatesGenerator.run(using: &rng)
        XCTAssertEqual(fourthPerson.id, 4)
        XCTAssertEqual(fourthPerson.name, "David")
        
        let fifthPerson = noDuplicatesGenerator.run(using: &rng)
        XCTAssertEqual(fifthPerson.id, 1)
        XCTAssertEqual(fifthPerson.name, "Alice")
    }
} 