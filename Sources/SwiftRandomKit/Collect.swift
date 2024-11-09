
extension RandomGenerators {
    public struct Collect<Upstream: RandomGenerator>: RandomGenerator {
        public typealias Element = [Upstream.Element]

        let generators: [Upstream]

        public init(_ generators: [Upstream]) {
            self.generators = generators
        }

        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Element {
            return  generators.map { $0.run(using: &rng) }
        }
    }
}

public extension Array where Element: RandomGenerator {
    @inlinable
    func collect() -> RandomGenerators.Collect<Element> {
        .init(self)
    }
}

public typealias Collect = RandomGenerators.Collect
