# ``SwiftRandomKit``

Composable, protocol-based random value generation.

## Overview

SwiftRandomKit builds random values out of small, composable generators. A generator is
any type conforming to ``RandomGenerator`` — a description of how to produce a value from
a `RandomNumberGenerator`. Generators combine with operators like `map`, `zip`, `flatMap`
and `filter` into pipelines that stay deterministic under a seeded RNG.

```swift
let dice = IntGenerator(in: 1...6)
let roll = dice.run() // e.g., 4

// Deterministic with a seeded RNG
var rng = Xoshiro256(seed: 42)
let reproducible = dice.run(using: &rng)

// Compose
let code = RandomGenerators.letterOrNumber.string(count: 8).run() // e.g., "a7Bf9pQ3"
```

Generators are ordinary values, confined to the isolation domain where they are built and
run: the ``RandomGenerator`` protocol does not require `Sendable`, leaf generators declare
it, and closure-free combinators propagate it conditionally.

## Topics

### Essentials

- ``RandomGenerator``
- ``RandomGenerators``
- ``AnyRandomGenerator``

### Core Generators

- ``IntGenerator``
- ``FloatGenerator``
- ``BoolGenerator``
- ``Always``

### Distributions

- ``RandomGenerators/Bernoulli``
- ``RandomGenerators/Normal``
- ``RandomGenerators/Exponential``
- ``RandomGenerators/Frequency``

### Characters and Strings

- ``RandomGenerators/Character``
- ``RandomGenerators/UnicodeScalar``
- ``RandomGenerators/StringOf``

### Transforming Generators

- ``RandomGenerators/Map``
- ``RandomGenerators/FlatMap``
- ``RandomGenerators/TryMap``

### Combining Generators

- ``RandomGenerators/Zip``
- ``RandomGenerators/OneOf2``
- ``RandomGenerators/OneOf3``
- ``RandomGenerators/OneOf4``
- ``RandomGenerators/Collect``
- ``RandomGenerators/Concat``

### Collections

- ``RandomGenerators/Array``
- ``RandomGenerators/ArrayGenerator``
- ``RandomGenerators/Collection``
- ``RandomGenerators/Dictionary``
- ``RandomGenerators/Element``
- ``RandomGenerators/Shuffled``
- ``RandomGenerators/Tuple``

### Constraining Output

- ``RandomGenerators/Filter``
- ``RandomGenerators/Retry``
- ``RandomGenerators/AttemptBounded``
- ``RandomGenerators/RemoveDuplicates``
- ``RandomGenerators/OptionalGenerator``
- ``RandomGenerators/OrNil``

### Debugging

- ``RandomGenerators/Print``

### Seeded Random Number Generators

- ``Xoshiro256``
- ``PCG``
- ``SplitMix64``
- ``LCRNG``
