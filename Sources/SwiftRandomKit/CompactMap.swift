public struct CompactMap<G: RandomGenerator, T>: RandomGenerator {
    public typealias Element = T
    let generator: G
    let transform: (G.Element) -> T?

    public init(_ generator: G, _ transform: @escaping (G.Element) -> T?) {
        self.generator = generator
        self.transform = transform
    }

    public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> T {
        while true {
            if let value = transform(self.generator.run(using: &rng)) {
                return value
            }
        }
    }
}

public extension RandomGenerator {
    func compactMap<T>(_ transform: @escaping (Element) -> T?) -> CompactMap<Self, T> {
        .init(self, transform)
    }
}