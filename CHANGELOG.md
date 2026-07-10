# Changelog

## [2.0.0] - 2026-07-10

A major release: critical correctness fixes, a rework of the library's concurrency
story, removal of APIs that didn't make sense, and a batch of new generators. If you are
coming from 1.x, build against 1.3.0 first — it deprecates everything 2.0 removes, with
messages naming the replacements.

### Concurrency: `RandomGenerator` no longer requires `Sendable`

Generators are ordinary values, confined to the isolation domain where they are built
and run:

- The protocol requires neither `Sendable` nor `Element: Sendable`. Conformers may hold
  non-Sendable state and produce non-Sendable values.
- Transform closures (`map`, `flatMap`, `filter`, `retry`, `tryMap`, ...) are plain
  closures — they can capture anything the surrounding context can.
- Leaf generators (`IntGenerator`, `FloatGenerator`, `BoolGenerator`, `Always`,
  `Character`, `UnicodeScalar`, the seeded RNGs, and all ready-made generators) declare
  `Sendable` explicitly, and closure-free combinators (`Array`, `Collect`, `Concat`,
  `Dictionary`, `Element`, `Frequency`, `OneOf`, `OrNil`, `Print`, `Shuffled`, `Tuple`,
  `Zip`, ...) propagate it conditionally — so leaf-only compositions remain shareable.
- `RemoveDuplicates` drops its lock and `@unchecked Sendable`; the compiler now enforces
  its single-domain confinement.
- `AttemptBounded.FallbackStrategy` is no longer `Sendable` (it carries a closure).

**Migration:** pipelines containing closures are no longer `Sendable`. Move one into a
`Task` and region isolation checks the transfer; to use a pipeline from several tasks,
build one per task.

### Fixed

- **`AnyRandomGenerator` never advanced the caller's RNG** — erased generators (including
  the character presets) replayed the same value forever under a seeded RNG. Seeded
  sequences involving erased generators change with this fix.
- `Zip(...).map { a, b, c in }` compiles again on Swift 6.3 via a pack-argument overload.
- `compactMap`/`retryMap` could crash on a force-unwrap when the attempt budget was
  exhausted; they now produce `Optional` (nil on exhaustion). `retryThrowing` produces
  `Result` (the last failure on exhaustion), runs its transform once per candidate, and
  no longer backstops with `fatalError`.
- `uiColor(alpha:)`/`swiftUIColor(alpha:)` silently ignored their alpha parameter; the
  parameter is removed and the generator's `init(alpha:)` visibly governs.
- `UnicodeScalar`/`Character` generation over ranges spanning the surrogate gap
  (U+D800–DFFF) no longer biases toward the lower bound or traps; the gap is skipped
  uniformly.
- `Frequency` no longer materializes a sum-of-all-weights array on every run (cumulative
  bounds + one draw), and fails fast with clear preconditions on empty or all-zero
  distributions.
- `AttemptBounded` counts the initial run toward `maxAttempts` (previously
  `maxAttempts: 3` ran the upstream up to 4 times); `maxAttempts` must be ≥ 1.
- `IntGenerator(in: 0..<0)` traps with a clear message instead of a confusing
  `ClosedRange` precondition.
- The package declared iOS 13 but could not compile for iOS at all (`Zip`'s parameter
  packs require the iOS 17 runtime). Platforms are now honestly declared —
  iOS 13 / macOS 10.15 / tvOS 13 / watchOS 6 — with only `Zip` and its operators gated
  behind `@available(macOS 14, iOS 17, tvOS 17, watchOS 10)`.
- `IPAddressGenerator` imports Foundation explicitly.

### Added

- `RandomGenerators.Bernoulli` / `.bool(probability:)` — biased coin.
- `orNil(probability:)` — produce nil with a given probability.
- `RandomGenerators.Normal` (Box–Muller) and `RandomGenerators.Exponential`
  distributions, with `.normal(mean:standardDeviation:)` / `.exponential(rate:)` sugar.
- `RandomGenerators.oneOf(...)` — uniform pick across 2–4 generators of different
  concrete types sharing an element type.
- `RandomGenerators.string(of:count:)` and `characterGen.string(count:)`.
- Seeded RNGs: `Xoshiro256` (xoshiro256++), `SplitMix64`, `PCG` (independent streams via
  `sequence:`).
- `Dice(sides:)` with `d4`/`d6`/`d8`/`d10`/`d12`/`d20`/`d100` presets.
- Dot-syntax statics: `.int(in:)`, `.float(in:)`, `.bool`.
- `RandomGenerators.sudoku(difficulty:)` convenience.
- DocC catalogs for both modules and the swift-docc-plugin.
- A runnable example target exercising the whole API.

### Changed (breaking)

- `BoolRandomGenerator` is renamed `BoolGenerator` (deprecated typealias retained).
- `compactMap`/`retryMap` produce `Output?`; `retryThrowing` produces
  `Result<Output, Error>`.
- `Frequency` is constructed via `RandomGenerators.frequency(_:)`; the receiver-ignoring
  instance method is removed.
- `UnicodeScalar` and `Character` are standalone generators constructed from a range;
  the combinator forms (whose upstream was ignored) are removed.

### Removed

- `ZipArrayGenerator`, `zipAll()`, `zipGenerators(...)` — exact duplicates of `Collect`;
  use `[generators].collect()`.
- `gen.always(_:)`, `gen.colorGenerator(alpha:)` — receiver-ignoring factories; construct
  `Always(_:)` / `ColorGenerator(alpha:)` directly.
- `CreditCardGenerator.Generated` — use `Element`.

## [1.3.0] - 2026-07-10

The final planned release of the 1.x line: backports the 2.0 features (Bernoulli,
distributions, oneOf, `string(of:count:)`, orNil, seeded RNGs), fixes the
`AnyRandomGenerator` seeded-RNG bug and Swift 6.3 compilation, and deprecates every API
removed in 2.0 with messages naming the replacements. See the `release/1.3.0` branch
changelog for details.

## [1.2.0] and earlier

See the release notes on GitHub.
