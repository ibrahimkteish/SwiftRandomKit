public protocol RandomGenerator<Element> {
    associatedtype Element
    func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Element
}

extension RandomGenerator {
    /// Runs the generator using the default SystemRandomNumberGenerator
    public func run() -> Element {
        var generator = SystemRandomNumberGenerator()
        return run(using: &generator)
    }
}
