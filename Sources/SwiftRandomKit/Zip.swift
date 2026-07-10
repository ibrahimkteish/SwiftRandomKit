extension RandomGenerators {
  public struct Zip<each R: RandomGenerator>: RandomGenerator {
    public typealias Element = (repeat (each R).Element)

    let generators: (repeat each R)

    public init(_ generators: repeat each R) {
      self.generators = (repeat each generators)
    }

    public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Element {
      return (repeat (each generators).run(using: &rng))
    }
  }
}

extension RandomGenerators.Zip {
  /// Transforms the zipped results, receiving each generator's value as a
  /// separate closure argument instead of a single tuple.
  ///
  /// Example:
  /// ```swift
  /// let gen = RandomGenerators.Zip(IntGenerator(in: 1...6), BoolRandomGenerator())
  ///     .map { roll, flip in "\(roll)-\(flip)" }
  /// ```
  ///
  /// Newer Swift compilers no longer destructure a pack-expansion tuple into a
  /// multi-parameter closure, so the generic `map(_:)` cannot be called as
  /// `{ a, b, c in ... }` on a zip of three generators; this overload keeps
  /// that spelling working.
  public func map<T: Sendable>(
    _ transform: @Sendable @escaping (repeat (each R).Element) -> T
  ) -> RandomGenerators.Map<Self, T> {
    .init(self) { element in
      transform(repeat each element)
    }
  }
}

// MARK: - Variadic Support

// A generator that produces arrays of elements
extension RandomGenerators {
    @available(*, deprecated, message: "ZipArrayGenerator duplicates Collect and will be removed in 2.0. Use [generators].collect() instead.")
    public struct ZipArrayGenerator<G: RandomGenerator>: RandomGenerator {
        public typealias Element = [G.Element]
        
        let generators: [G]
        
        public init(generators: [G]) {
            self.generators = generators
        }
        
        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> [G.Element] {
            generators.map { $0.run(using: &rng) }
        }
    }
}

extension RandomGenerator {
  public func zip<R: RandomGenerator>(_ other: R) -> RandomGenerators.Zip<Self, R> {
    .init(self, other)
  }

  public func zip<R: RandomGenerator, T>(_ other: R, _ transform: @Sendable @escaping (Self.Element, R.Element) -> T) -> RandomGenerators.Map<RandomGenerators.Zip<Self, R>, T> {
    .init(.init(self, other), transform)
  }
}

// Variadic array support
extension Array where Element: RandomGenerator {
    // Create a generator that produces arrays from multiple generators of the same type
    @available(*, deprecated, message: "Removed in 2.0. Use collect() instead.")
    public func zipAll() -> RandomGenerators.ZipArrayGenerator<Element> {
        RandomGenerators.ZipArrayGenerator(generators: self)
    }
}

// Factory function for combining any number of generators of the same type
@available(*, deprecated, message: "Removed in 2.0. Use [generators].collect() instead.")
public func zipGenerators<G: RandomGenerator>(_ generators: G...) -> RandomGenerators.ZipArrayGenerator<G> {
    RandomGenerators.ZipArrayGenerator(generators: generators)
} 
