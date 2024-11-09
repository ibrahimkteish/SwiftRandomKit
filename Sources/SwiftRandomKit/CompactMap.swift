public struct CompactMap<Upstream: RandomGenerator, T>: RandomGenerator {
    public typealias Element = T
    let generator: Upstream
    let transform: (Upstream.Element) -> T?

    public init(_ generator: Upstream, _ transform: @escaping (Upstream.Element) -> T?) {
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