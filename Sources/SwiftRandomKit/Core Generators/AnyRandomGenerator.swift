public struct AnyRandomGenerator<Element>: RandomGenerator {
    public let _run: (inout any RandomNumberGenerator) -> Element
    
    public init<Upstream: RandomGenerator>(_ generator: Upstream) where Upstream.Element == Element {
        self._run = { rng in
            generator.run(using: &rng)
        }
    }

    public init(_ run: @escaping (inout any RandomNumberGenerator) -> Element) {
        self._run = run
    }
    
    @inlinable
    @inline(__always)
    public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Element {
        var anyRNG: any RandomNumberGenerator = rng
        return _run(&anyRNG)
    }
    
    public func eraseToAnyRandomGenerator() -> AnyRandomGenerator<Element> {
        self
    }
}

extension RandomGenerator {
    @inlinable
    public func eraseToAnyRandomGenerator() -> AnyRandomGenerator<Element> {
        .init(self)
    }
}
