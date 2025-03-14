public struct CompactMap<Upstream: RandomGenerator, T>: RandomGenerator {
    public typealias Element = T
    let generator: Upstream
    let transform: (Upstream.Element) -> T?

    public init(_ generator: Upstream, _ transform: @escaping (Upstream.Element) -> T?) {
        self.generator = generator
        self.transform = transform
    }

    public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> T {
        var value: T?
        repeat {
            value = transform(generator.run(using: &rng))
        } while value == nil
        return value!
    }
}

public extension RandomGenerator {
    @inlinable
    func compactMap<T>(_ transform: @escaping (Element) -> T?) -> CompactMap<Self, T> {
        .init(self, transform)
    }
}