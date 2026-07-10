# ``SwiftRandomKitGenerators``

Ready-made generators for common real-world values.

## Overview

This module builds on SwiftRandomKit's core with generators for realistic test data and
simulations — credit card numbers that pass Luhn validation, RFC 4122 v4 UUID strings,
IP addresses, geographic coordinates, semantic versions, Safari-style passwords, dice,
colors, and Sudoku puzzles.

```swift
import SwiftRandomKitGenerators

CreditCardGenerator(type: .visa).run()   // "4532015112830366"
IPAddressGenerator(version: .v6).run()   // "2001:0db8:85a3:0000:..."
Dice.d20.roll()                          // 1...20
RandomGenerators.sudoku(difficulty: .hard).run()
```

## Topics

### Identifiers and Networking

- ``UUIDGenerator``
- ``IPAddressGenerator``
- ``VersionNumberGenerator``

### Finance

- ``CreditCardGenerator``
- ``CreditCardType``

### Games

- ``Dice``
- ``SudokuGenerator``

### Miscellaneous

- ``SafariPasswordGenerator``
- ``LatLongGenerator``
- ``ColorGenerator``
