
public protocol RandomGenerator<Element> {
    associatedtype Element
    func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Element
}
