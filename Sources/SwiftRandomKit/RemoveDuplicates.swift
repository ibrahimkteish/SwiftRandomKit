
extension RandomGenerators {
    public struct RemoveDuplicates<Upstream: RandomGenerator>: RandomGenerator {
        public typealias Element = Upstream.Element
        
        private final class Storage {
            var lastValue: Upstream.Element?
            
            fileprivate init() {
                self.lastValue = nil
            }
        }
    
        private var generator: Upstream
        private let storage: Storage
        private let predicate: (Element, Element) -> Bool

        public init(_ generator: Upstream, predicate: @escaping (Element, Element) -> Bool) {
            self.generator = generator
            self.storage = Storage()
            self.predicate = predicate
        }
    
        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Upstream.Element {
            guard let lastValue = storage.lastValue else {
                let last =  generator.run(using: &rng)
                storage.lastValue = last
                return last
            }
            var nextValue: Upstream.Element
            repeat {
                nextValue = generator.run(using: &rng)
            } while predicate(nextValue, lastValue)
            storage.lastValue = nextValue
            return nextValue
        }
    }
}

public extension RandomGenerator where Self.Element: Equatable {
    func removeDuplicates() -> RandomGenerators.RemoveDuplicates<Self>  {
        RandomGenerators.RemoveDuplicates(self, predicate: ==)
    }
}

public extension RandomGenerator {
    func removeDuplicates(by predicate: @escaping (Element, Element) -> Bool) -> RandomGenerators.RemoveDuplicates<Self> {
        RandomGenerators.RemoveDuplicates(self, predicate: predicate)
    }
}
