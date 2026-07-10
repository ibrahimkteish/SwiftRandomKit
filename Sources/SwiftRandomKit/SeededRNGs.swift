/// A `SplitMix64` random number generator.
///
/// Fast, tiny (64 bits of state), and statistically solid for its size. Often used to
/// seed larger-state generators like ``Xoshiro256`` from a single 64-bit seed.
///
/// Reference: Steele, Lea, Flood — "Fast Splittable Pseudorandom Number Generators".
public struct SplitMix64: RandomNumberGenerator, Sendable {
    var state: UInt64

    /// Creates a generator with the given seed.
    public init(seed: UInt64) {
        self.state = seed
    }

    public mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}

/// A `xoshiro256++` random number generator.
///
/// The recommended general-purpose choice for seeded generation: 256 bits of state,
/// excellent statistical quality (passes BigCrush), and very fast. Not cryptographically
/// secure — use `SystemRandomNumberGenerator` where security matters.
///
/// Reference: Blackman & Vigna — https://prng.di.unimi.it
public struct Xoshiro256: RandomNumberGenerator, Sendable {
    var state: (UInt64, UInt64, UInt64, UInt64)

    /// Creates a generator with the given seed, expanded to the full 256-bit state
    /// via ``SplitMix64`` (as recommended by the xoshiro authors).
    public init(seed: UInt64) {
        var seeder = SplitMix64(seed: seed)
        self.state = (seeder.next(), seeder.next(), seeder.next(), seeder.next())
    }

    public mutating func next() -> UInt64 {
        func rotl(_ x: UInt64, _ k: UInt64) -> UInt64 {
            (x << k) | (x >> (64 - k))
        }

        let result = rotl(state.0 &+ state.3, 23) &+ state.0
        let t = state.1 << 17
        state.2 ^= state.0
        state.3 ^= state.1
        state.1 ^= state.2
        state.0 ^= state.3
        state.2 ^= t
        state.3 = rotl(state.3, 45)
        return result
    }
}

/// A `PCG-XSH-RR` random number generator (pcg32, two outputs per `next()`).
///
/// Small state, good statistical quality, and support for independent streams via the
/// `sequence` parameter: generators with the same seed but different sequences produce
/// uncorrelated outputs. Not cryptographically secure.
///
/// Reference: O'Neill — https://www.pcg-random.org
public struct PCG: RandomNumberGenerator, Sendable {
    var state: UInt64
    let increment: UInt64

    /// Creates a generator with the given seed and stream.
    ///
    /// - Parameters:
    ///   - seed: The initial seed value.
    ///   - sequence: Selects an independent stream; different sequences with the same
    ///     seed yield unrelated outputs.
    public init(seed: UInt64, sequence: UInt64 = 0xDA3E39CB94B95BDB) {
        self.increment = (sequence << 1) | 1
        self.state = 0
        _ = next32()
        state &+= seed
        _ = next32()
    }

    private mutating func next32() -> UInt32 {
        let old = state
        state = old &* 6364136223846793005 &+ increment
        let xorshifted = UInt32(truncatingIfNeeded: ((old >> 18) ^ old) >> 27)
        let rot = UInt32(truncatingIfNeeded: old >> 59)
        return (xorshifted >> rot) | (xorshifted << ((32 &- rot) & 31))
    }

    public mutating func next() -> UInt64 {
        (UInt64(next32()) << 32) | UInt64(next32())
    }
}
