public struct AnyRandomGenerator<Element>: RandomGenerator {
    private let _run: (inout any RandomNumberGenerator) -> Element
    
    public init<G: RandomGenerator>(_ generator: G) where G.Element == Element {
        self._run = { rng in
            generator.run(using: &rng)
        }
    }

    public init(_ run: @escaping (inout any RandomNumberGenerator) -> Element) {
        self._run = run
    }
    
    public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Element {
        var anyRNG: any RandomNumberGenerator = rng
        return _run(&anyRNG)
    }
    
    public func eraseToAnyRandomGenerator() -> AnyRandomGenerator<Element> {
        self
    }
}

extension RandomGenerator {
    public func eraseToAnyRandomGenerator() -> AnyRandomGenerator<Element> {
        .init(self)
    }
}
