
extension RandomGenerators {
    public struct RemoveDuplicates<G: RandomGenerator>: RandomGenerator {
        public typealias Element = G.Element
        
        private final class Storage {
            var lastValue: G.Element?
            
            fileprivate init() {
                self.lastValue = nil
            }
        }
    
        private var generator: G
        private let storage: Storage
        private let predicate: (Element, Element) -> Bool

        public init(_ generator: G, predicate: @escaping (Element, Element) -> Bool) {
            self.generator = generator
            self.storage = Storage()
            self.predicate = predicate
        }
    
        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> G.Element {
            guard let lastValue = storage.lastValue else {
                let last =  generator.run(using: &rng)
                storage.lastValue = last
                return last
            }


            var nextValue: G.Element
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
