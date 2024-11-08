
public struct Distinct<G: RandomGenerator>: RandomGenerator where G.Element: Equatable {
    public typealias Element = G.Element
    
    private final class Storage<T> {
        var lastValue: T?
        
        fileprivate init() {
            self.lastValue = nil
        }
    }
    
    private var generator: G
    private let storage: Storage<G.Element>
    
    public init(_ generator: G) {
        self.generator = generator
        self.storage = Storage()
    }
    
    public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> G.Element {
        if storage.lastValue == nil {
            Swift.print(self)
            let last =  generator.run(using: &rng)
            storage.lastValue = last
            return last
        } else {
            var nextValue: G.Element
            repeat {
                nextValue = generator.run(using: &rng)
            } while nextValue == storage.lastValue
            storage.lastValue = nextValue
            return nextValue
        }
    }
}

public extension RandomGenerator where Self.Element: Equatable {
    func distinct() -> Distinct<Self>  {
        Distinct(self)
    }
}
