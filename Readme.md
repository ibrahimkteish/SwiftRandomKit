# SwiftRandomKit

[![Swift Tests](https://github.com/ibrahimkteish/SwiftRandomKit/actions/workflows/swift-tests.yml/badge.svg)](https://github.com/ibrahimkteish/SwiftRandomKit/actions/workflows/swift-tests.yml)
[![Swift 6.0.2](https://img.shields.io/badge/Swift-6.0.2-orange.svg)](https://swift.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

SwiftRandomKit is a powerful Swift library that provides a composable, protocol-based approach to random value generation. It offers a flexible and type-safe way to create and combine random generators for various data types.

## Features

- 🎲 Type-safe random generators
- 🧩 Composable and chainable API
- 🔄 Support for custom random number generators
- 📦 Rich set of built-in generators
- 🛠 Extensive collection of combinators

## Concurrency Safety

SwiftRandomKit is designed with Swift's concurrency model in mind:

- ✅ All generators conform to `Sendable` for safe use in concurrent contexts
- 🔒 You can enable strict concurrency checking while using it

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/ibrahimkteish/SwiftRandomKit.git", from: "1.2.0")
]
```

## Basic Usage

```swift
import SwiftRandomKit

// Create a simple random number generator
let diceGen = IntGenerator(in: 1...6)
let roll = diceGen.run() // e.g., 4

// Generate random characters
let letterGen = RandomGenerators.letter
let letter = letterGen.run() // Random letter (a-z, A-Z)

let digitGen = RandomGenerators.number
let digit = digitGen.run() // Random digit (0-9)

// Generate arrays of random values
let fiveRolls = diceGen.array(5).run() // e.g., [3, 1, 6, 2, 5]

// Use a custom random number generator
var myRNG = MyCustomRandomNumberGenerator()
let customRoll = diceGen.run(using: &myRNG)
```

## Function Call Syntax

SwiftRandomKit supports Swift's function call syntax, allowing you to call generators directly as functions:

```swift
import SwiftRandomKit

// Create a random number generator
let diceGen = IntGenerator(in: 1...6)

// Traditional way
let roll1 = diceGen.run() 

// Function call syntax - more concise!
let roll2 = diceGen()

// Works with custom RNGs too
var myRNG = MyCustomRandomNumberGenerator()
let roll3 = diceGen(using: &myRNG)
```

This syntax provides a more concise and natural way to generate random values, making your code cleaner and more expressive.

## Built-in Generators

### Core Generators
- `IntGenerator`: Generate random integers within a range
- `FloatGenerator`: Generate random floating-point numbers
- `BoolRandomGenerator`: Generate random boolean values
- `AnyRandomGenerator`: Type-erased container for any random generator

### Character and String
- `RandomGenerators.letter`: Random letters (a-z, A-Z)
- `RandomGenerators.number`: Random digits (0-9)
- `RandomGenerators.letterOrNumber`: Random alphanumeric characters
- `RandomGenerators.uppercaseLetter`: Random uppercase letters (A-Z)
- `RandomGenerators.lowercaseLetter`: Random lowercase letters (a-z)
- `RandomGenerators.ascii`: Random ASCII characters
- `RandomGenerators.latin1`: Random Latin-1 characters
- `RandomGenerators.character(in:)`: Custom range of characters

### Collections
- `Array`: Generate arrays of random elements with fixed size
- `ArrayGenerator`: Generate arrays with random size
- `Dictionary`: Generate dictionaries with random key-value pairs
- `Element`: Pick random elements from collections
- `Set`: Generate sets of random elements
- `Collection`: Generate custom collections of random elements
- `Shuffled`: Generate shuffled versions of collections

### General Purpose Generators
- `Always`: Always produce the same value
- `LCRNG`: Linear Congruential Random Number Generator

### Transformers and Combinators
- `Map`: Transform the output of a generator
- `FlatMap`: Create generators that depend on previous random values
- `Concat`: Concatenate the output of multiple generators
- `Zip`: Combine multiple generators into tuples
- `Collect`: Collect results from multiple generators
- `Print`: Debug generator outputs
- `RemoveDuplicates`: Remove duplicate values from a generator
- `Filter`: Generate only values that satisfy a predicate
- `Retry`: Retry generation until a condition is met
- `AttemptBounded`: Limit generation attempts with configurable fallback strategies
- `TryMap`: Transform with operations that might fail
- `Frequency`: Weight outputs by frequency
- `Optional`: Generate optional values from a generator
- `Tuple`: Create tuples from a generator's output

### Special Generators

Additional generators available in the SwiftRandomKitGenerators product:

- `ColorGenerator`: Generate random colors (supports UIKit and SwiftUI)
- `CreditCardGenerator`: Generate valid credit card numbers for different card types
- `Dice`: Generate random dice rolls of various types
- `IPAddressGenerator`: Generate random IP addresses (IPv4 or IPv6)
- `LatLongGenerator`: Generate random geographic coordinates (latitude and longitude)
- `SafariPasswordGenerator`: Generate strong passwords following Safari's pattern
- `SudokuGenerator`: Generate valid Sudoku puzzles with varying difficulty
- `UUIDGenerator`: Generate random UUID strings in standard format
- `VersionNumberGenerator`: Generate random semantic version numbers

## Transformations and Combinations

SwiftRandomKit provides various transformations to modify and combine generators:

### Mapping and Transforming

```swift
// Transform values with map
let diceGen = IntGenerator(in: 1...6)
let doubledDice = diceGen.map { $0 * 2 }
let result = doubledDice.run() // 2, 4, 6, 8, 10, or 12

// Use flatMap for dependent generators
let coinFlip = BoolRandomGenerator()
let weightedDice = coinFlip.flatMap { isHeads in
    isHeads ? IntGenerator(in: 1...6) : IntGenerator(in: 4...9)
}
```

### Collecting and Combining

```swift
// Fixed-size arrays
let fiveDice = IntGenerator(in: 1...6).array(5)

// Variable-size arrays
let countGen = IntGenerator(in: 3...7) 
let variableDice = IntGenerator(in: 1...6).arrayGenerator(countGen)

// Collect results from different generators
let smallNumberGen = IntGenerator(in: 1...10)
let mediumNumberGen = IntGenerator(in: 11...50)
let largeNumberGen = IntGenerator(in: 51...100)

let mixedNumbers = [smallNumberGen, mediumNumberGen, largeNumberGen].collect().run()
// e.g., [7, 23, 86]
```

### Constant and Always Generators

```swift
// Always produce the same value
let alwaysSix = Always(6)

// Can be combined with other generators using flatMap
let loadedDice = BoolRandomGenerator().flatMap { isLoaded in
    isLoaded ? alwaysSix.eraseToAnyRandomGenerator() : IntGenerator(in: 1...6).eraseToAnyRandomGenerator()
}

print(loadedDice())
```

### Type Erasure

```swift
// Erase the concrete type for API simplicity
func createDiceGenerator() -> AnyRandomGenerator<Int> {
    return IntGenerator(in: 1...6).eraseToAnyRandomGenerator()
}

// Store different generator types in a collection
let generators: [AnyRandomGenerator<Int>] = [
    IntGenerator(in: 1...100).eraseToAnyRandomGenerator(),
    BoolRandomGenerator().map { $0 == true ? 1 : 0 }.eraseToAnyRandomGenerator()
]

print(generators.collect().run())
```

## Advanced Examples

### Create a Password Generator

```swift
// Generate a secure password with specific requirements
let passwordGen = RandomGenerators.uppercaseLetter
    .array(2).flatMap { uppercase in
        RandomGenerators.lowercaseLetter.array(5).flatMap { lowercase in
            RandomGenerators.number.array(2).flatMap { digits in
                Always(Array("!@#$%^&*")).element().map { special in
                    let allChars = uppercase + lowercase + digits + (special != nil ? [special!] : [])
                    return String(allChars)
                }
            }
        }
    }

let securePassword = passwordGen.run() // e.g., "KTabnre45$"
```

A simpler approach using the zip operator:

```swift
// A simpler way to generate a random password
let simplePasswordGen = RandomGenerators.uppercaseLetter.array(2)
    .zip(RandomGenerators.lowercaseLetter.array(5))
    .zip(RandomGenerators.number.array(2)) 
    .zip(Always(Array("!@#$%^&*")).element())
    .map { (components, special) in
        let (upperAndLower, digits) = components
        let (upper, lower) = upperAndLower
        let chars = upper + lower + digits + (special != nil ? [special!] : [])
        return String(chars)
    }

let password = simplePasswordGen.run() // e.g., "ABcdefg12#"
```

### Using Filter, Retry, and AttemptBounded Generators

```swift
// Generate only even numbers
let evenNumbers = IntGenerator(in: 1...100).filter { $0.isMultiple(of: 2) }
let evenNumber = evenNumbers.run() // Always an even number

// Retry until a condition is met
let diceGen = IntGenerator(in: 1...6)
let sixGenerator = diceGen.retry(until: { $0 == 6 }, maxAttempts: 10)
let result = sixGenerator.run() // Will be 6 if found within 10 attempts

// Filter with fallback for maximum attempts
let primeGen = IntGenerator(in: 1...100).attemptBounded(
    maxAttempts: 20,
    condition: { number in
        // Check if number is prime (simplified)
        if number <= 1 { return false }
        if number <= 3 { return true }
        if number.isMultiple(of: 2) || number.isMultiple(of: 3) { return false }
        var i = 5
        while i * i <= number {
            if number.isMultiple(of: i) || number.isMultiple(of: (i + 2)) { return false }
            i += 6
        }
        return true
    },
    fallbackStrategy: .useDefault(17) // Default to 17 if no prime found in 20 attempts
)

let prime = primeGen.run() // A prime number or 17 if none found

// Using a different generator as fallback
let highRoll = diceGen.attemptBounded(
    maxAttempts: 3,
    condition: { $0 > 4 },
    fallbackStrategy: .useAnotherGenerator { Always(6).run() }
)
let highDiceRoll = highRoll.run() // 5 or 6, or always 6 if not found in 3 attempts
```

> ⚠️ **Warning**: Be careful when using the `.keepTrying` fallback strategy, as it can lead to infinite loops if the condition can never be satisfied. For example, `Always(5).retry(until: { $0.isMultiple(of: 2) })` will hang indefinitely.

### Create a Custom Generator

```swift
// Create a custom dice that can be loaded
struct LoadedDiceGenerator: RandomGenerator {
  let bias: Int
  let probability: Double

  init(bias: Int, probability: Double = 0.7) {
    self.bias = bias
    self.probability = probability
  }

  func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Int {
    FloatGenerator<Double>(in: 0...1)
      .flatMap {
        $0 < probability ? Always(bias).eraseToAnyRandomGenerator()
        : IntGenerator(in: 1...6).eraseToAnyRandomGenerator()
      }
      .run(using: &rng)
  }
}

let loadedDice = LoadedDiceGenerator(bias: 6)
let roll = loadedDice.run() // 6 with 70% probability
```

## License

This project is available under the MIT license. See the LICENSE file for more info.


