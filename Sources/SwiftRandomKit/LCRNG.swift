/// A Linear Congruential Random Number Generator (LCRNG) that implements Swift's `RandomNumberGenerator` protocol.
/// 
/// LCRNGs generate pseudo-random numbers using the recurrence relation:
/// X(n+1) = (a * X(n) + c) mod m
/// where:
/// - a = 2862933555777941757 (multiplier)
/// - c = 3037000493 (increment)
/// - m = 2^64 (modulus, implicit due to 64-bit integer overflow)
///
/// > Note: LCRNGs are statistically weak — in particular the low-order bits have short
/// > cycles. `LCRNG` is fine for deterministic tests, where only reproducibility matters,
/// > but for simulations prefer ``Xoshiro256`` or ``PCG``, and for anything
/// > security-sensitive use `SystemRandomNumberGenerator`.
public struct LCRNG: RandomNumberGenerator {
  /// The current state of the generator
  var seed: UInt64

  /// Creates a new LCRNG with the specified seed value.
  ///
  /// - Parameter seed: The initial seed value for the generator.
  public init(seed: UInt64) {
    self.seed = seed
  }

  /// Generates the next random value in the sequence.
  ///
  /// - Returns: A 64-bit unsigned random integer.
  public mutating func next() -> UInt64 {
    seed = 2862933555777941757 &* seed &+ 3037000493
    return seed
  }
}
