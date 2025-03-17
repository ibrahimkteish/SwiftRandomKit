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

// MARK: - Variadic Support

// A generator that produces arrays of elements
extension RandomGenerators {
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

  public func zip<R: RandomGenerator, T>(_ other: R, _ transform: @escaping (Self.Element, R.Element) -> T) -> RandomGenerators.Map<RandomGenerators.Zip<Self, R>, T> {
    .init(.init(self, other), transform)
  }
}

// Variadic array support
extension Array where Element: RandomGenerator {
    // Create a generator that produces arrays from multiple generators of the same type
    public func zipAll() -> RandomGenerators.ZipArrayGenerator<Element> {
        RandomGenerators.ZipArrayGenerator(generators: self)
    }
}

// Factory function for combining any number of generators of the same type
public func zipGenerators<G: RandomGenerator>(_ generators: G...) -> RandomGenerators.ZipArrayGenerator<G> {
    RandomGenerators.ZipArrayGenerator(generators: generators)
} 
