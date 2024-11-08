# SwiftRandomKit

A powerful and flexible Swift library for generating random data with composable generators.

## Features

- 🎲 Type-safe random generators
- 🧩 Composable and chainable API
- 🔄 Support for custom random number generators
- 📦 Rich set of built-in generators
- 🛠 Extensive collection of combinators

## Installation

### Swift Package Manager

Add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/SwiftRandomKit.git", from: "1.0.0")
]
```

## Basic Usage

### Simple Generators

```swift
import SwiftRandomKit

// Initialize a random number generator
var rng = SystemRandomNumberGenerator() // or LCRNG(seed: 1) for deterministic results

// Generate random integers
let diceRoll = Dice().run(using: &rng) // 1...6

// Generate random floats
let probability = FloatGenerator(in: 0...1).run(using: &rng)

// Generate random booleans
let coinFlip = BoolRandomGenerator().run(using: &rng)
```

### Advanced Generators

```swift
// Generate UUIDs
let uuidGen = UUIDGenerator()
let uuid = uuidGen.run(using: &rng)

// Generate random colors
let colorGen = RandomGenerators.ColorGenerator()
let color = colorGen.run(using: &rng)

// Generate Safari-style passwords
let passwordGen = SafariPasswordGenerator()
let password = passwordGen.run(using: &rng) // e.g., "huwKun-1zyjxi-nyxseh"
```

### Combinators

SwiftRandomKit provides powerful combinators to compose generators:

```swift
// Map values
let doubledDice = Dice().map { $0 * 2 }

// Generate arrays
let tenDiceRolls = Dice().array(10)

// Filter values
let evenDice = Dice().filter { $0 % 2 == 0 }

// Zip multiple generators
let colorAndDice = ColorGenerator()
    .zip(Dice()) { color, number in 
        (color: color, roll: number)
    }
```

### Collections

```swift
// Generate arrays
let numbers = IntGenerator(in: 1...100).array(5)

// Generate sets
let uniqueNumbers = IntGenerator(in: 1...100).set(count: Always(10))

// Generate dictionaries
let keyValuePairs = IntGenerator(in: 1...5)
    .zip(BoolRandomGenerator())
    .dictionary(Always(3))
```

## Advanced Features

### Custom Generators

Create your own generators by conforming to the `RandomGenerator` protocol:

```swift
struct CustomGenerator: RandomGenerator {
    typealias Element = String
    
    func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> String {
        // Your implementation here
    }
}
```

### Frequency-based Generation

```swift
let weighted = Dice().frequency([
    (2, Dice().map { $0 * 2 }), // Double weight for even numbers
    (1, Dice())                 // Normal weight for regular numbers
])
```

### Distinct Values

```swift
let distinctNumbers = IntGenerator(in: 1...10).distinct()
```

## License

This library is released under the MIT License. See LICENSE file for details.