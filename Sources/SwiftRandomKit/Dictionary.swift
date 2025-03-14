
extension RandomGenerators {
  public struct Dictionary<Upstream: RandomGenerator, C: RandomGenerator<Int>, K: Hashable, V>: RandomGenerator where Upstream.Element == (K, V) {
        let upstream: Upstream
        let countGenerator: C

        public init(_ upstream: Upstream, _ countGenerator: C) {
            self.upstream = upstream
            self.countGenerator = countGenerator
        }

        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> [K: V] {
            let size = countGenerator.run(using: &rng)
            var dictionary: [K: V] = [:]
            for _ in 0..<size {
                let (k, v) = upstream.run(using: &rng)
                dictionary[k] = v
            }
            return dictionary
        }
    }
}


extension RandomGenerator {
    public func dictionary<C: RandomGenerator<Int>, K: Hashable, V>(_ countGenerator: C) -> RandomGenerators.Dictionary<Self, C, K, V> {
        .init(self, countGenerator)
    }
}
