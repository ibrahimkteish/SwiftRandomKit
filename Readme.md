# SwiftRandomKit

SwiftRandomKit is a powerful Swift library that provides a composable, protocol-based approach to random value generation. It offers a flexible and type-safe way to create and combine random generators for various data types.

## Features

- 🎲 Composable random generators
- 🔄 Chainable transformations
- 🎯 Type-safe operations
- 📦 Rich set of built-in generators
- 🛠 Extensible architecture

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
.package(url: "https://github.com/yourusername/SwiftRandomKit.git", from: "1.0.0")
]
```

## Basic Usage

```swift
// Create a simple random number generator
let diceRoll = Dice()
let result = diceRoll.run(using: &SystemRandomNumberGenerator())
// Generate random characters
let letter = RandomGenerators.letter.run(using: &SystemRandomNumberGenerator())
let digit = RandomGenerators.number.run(using: &SystemRandomNumberGenerator())
// Generate arrays of random values
let numbers = IntGenerator(in: 1...100).array(5)
```

## Built-in Generators

### Basic Types
- `IntGenerator`: Generate random integers within a range
- `FloatGenerator`: Generate random floating-point numbers
- `BoolRandomGenerator`: Generate random boolean values
- `UUIDGenerator`: Generate random UUIDs

### Character and String
- `letter`: Random letters (a-z, A-Z)
- `number`: Random digits (0-9)
- `letterOrNumber`: Random alphanumeric characters
- `ascii`: Random ASCII characters
- `latin1`: Random Latin-1 characters

### Collections
- `Array`: Generate arrays of random elements
- `Dictionary`: Generate dictionaries with random key-value pairs
- `Element`: Pick random elements from collections

### Special Generators
- `ColorGenerator`: Generate random colors (supports UIKit and SwiftUI)
- `SafariPasswordGenerator`: Generate Safari-style passwords
- `SudokuGenerator`: Generate Sudoku puzzles with varying difficulty

## Transformations

SwiftRandomKit provides various transformations to modify and combine generators:


