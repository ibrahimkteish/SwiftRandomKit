# Changelog

## [1.3.0] - 2026-07-10

The final planned release of the 1.x line. It backports the features and critical fixes
from the upcoming 2.0 and deprecates every API that 2.0 removes, so migrating is mostly
a matter of following compiler warnings.

### Fixed

- **`AnyRandomGenerator` never advanced the caller's RNG.** Erased generators — including
  the built-in `number`, `uppercaseLetter`, `lowercaseLetter` and `character(in:)`
  presets — replayed the same value forever under a seeded RNG. Seeded sequences that
  involve erased generators will change with this fix; the first draw is unaffected.
- `Zip(...).map { a, b, c in }` failed to compile on Swift 6.3 (pack-expansion tuples are
  no longer destructured into multi-parameter closures). A `map` overload on `Zip` that
  receives the values as separate arguments restores the spelling, and CI now also builds
  with the current Xcode toolchain and the latest Swift Linux image.
- `IPAddressGenerator` imports Foundation explicitly (required under
  `MemberImportVisibility`).
- `Shuffled` no longer requires `Element.Element: Equatable`; shuffling never compares
  elements.

### Added

- `RandomGenerators.Bernoulli` / `.bool(probability:)` — biased coin.
- `orNil(probability:)` — produce nil with a given probability.
- `RandomGenerators.Normal` (Box–Muller) and `RandomGenerators.Exponential` distribution
  generators, with `.normal(mean:standardDeviation:)` / `.exponential(rate:)` sugar.
- `RandomGenerators.oneOf(...)` — uniform pick across 2–4 generators of different
  concrete types sharing an element type.
- `RandomGenerators.string(of:count:)` and `characterGen.string(count:)` — build strings
  directly from a character generator.
- Seeded RNGs: `Xoshiro256` (xoshiro256++), `SplitMix64`, and `PCG` (with independent
  streams via `sequence:`). `LCRNG` documents its statistical weakness and points
  simulations at these.
- `RandomGenerators.frequency(_:)` static factory (the 2.0 spelling).
- `BoolGenerator` typealias (the 2.0 name for `BoolRandomGenerator`).

### Deprecated (removed in 2.0)

- `ZipArrayGenerator`, `zipAll()`, `zipGenerators(...)` → use `[generators].collect()`.
- `gen.always(_:)` → construct `Always(_:)` directly (the receiver was ignored).
- `gen.colorGenerator(alpha:)` → construct `ColorGenerator(alpha:)` directly.
- `gen.frequency(_:)` → `RandomGenerators.frequency(_:)` (the receiver was never part of
  the distribution).
- `gen.character(in:)` / `gen.unicodeScalar(in:)` → `RandomGenerators.character(in:)`
  (the upstream generator was ignored).
- `uiColor(alpha:using:)` / `swiftUIColor(alpha:using:)` → `uiColor(using:)` /
  `swiftUIColor(using:)` (the alpha parameter was silently ignored; set alpha at
  initialization).
- `CreditCardGenerator.Generated` → `Element`.

## [1.2.0] and earlier

See the release notes on GitHub.
