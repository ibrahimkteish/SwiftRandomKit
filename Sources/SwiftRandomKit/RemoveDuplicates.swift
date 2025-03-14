import Foundation

extension RandomGenerators {
    /// A generator that avoids returning the same value twice in a row.
    ///
    /// WARNING: This generator maintains state between runs and is not thread-safe.
    /// Do not use this generator in concurrent contexts without proper synchronization.
    public struct RemoveDuplicates<Upstream: RandomGenerator>: RandomGenerator {
        public typealias Element = Upstream.Element
        
        /// Storage class to hold the last value generated
        private final class Storage {
            var lastValue: Upstream.Element?
            // Use a lock for thread safety
            let lock = NSLock()
            
            fileprivate init() {
                self.lastValue = nil
            }
            
            fileprivate func getLastValue() -> Upstream.Element? {
                lock.lock()
                defer { lock.unlock() }
                return lastValue
            }
            
            fileprivate func setLastValue(_ value: Upstream.Element) {
                lock.lock()
                defer { lock.unlock() }
                lastValue = value
            }
        }
    
        private var generator: Upstream
        private let storage = Storage()
        private let predicate: (Element, Element) -> Bool
        private let maxAttempts: Int
        
        /// Creates a generator that avoids returning consecutive duplicate values
        ///
        /// - Parameters:
        ///   - generator: The upstream generator
        ///   - predicate: A function that returns true if two values are considered equal
        ///   - maxAttempts: Maximum number of attempts to generate a non-duplicate value before giving up
        public init(_ generator: Upstream, predicate: @escaping (Element, Element) -> Bool, maxAttempts: Int = 100) {
            self.generator = generator
            self.predicate = predicate
            self.maxAttempts = maxAttempts > 0 ? maxAttempts : 100
        }
    
        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Upstream.Element {
            guard let lastValue = storage.getLastValue() else {
                let last = generator.run(using: &rng)
                storage.setLastValue(last)
                return last
            }
            
            var nextValue: Upstream.Element
            var attempts = 0
            
            repeat {
                nextValue = generator.run(using: &rng)
                attempts += 1
                // Give up after maxAttempts and just return the value even if duplicate
                if attempts >= maxAttempts {
                    break
                }
            } while predicate(nextValue, lastValue)
            
            storage.setLastValue(nextValue)
            return nextValue
        }
    }
}

public extension RandomGenerator where Self.Element: Equatable {
    /// Returns a generator that avoids generating consecutive duplicate values
    /// 
    /// - Parameter maxAttempts: Maximum number of attempts to generate a non-duplicate value before giving up. Default is 100.
    /// - Returns: A generator that tries to avoid duplicates
    func removeDuplicates(maxAttempts: Int = 100) -> RandomGenerators.RemoveDuplicates<Self> {
        RandomGenerators.RemoveDuplicates(self, predicate: ==, maxAttempts: maxAttempts)
    }
}

public extension RandomGenerator {
    /// Returns a generator that avoids generating consecutive duplicate values according to a predicate
    /// 
    /// - Parameters:
    ///   - predicate: A function that returns true if two values are considered equal
    ///   - maxAttempts: Maximum number of attempts to generate a non-duplicate value before giving up. Default is 100.
    /// - Returns: A generator that tries to avoid duplicates
    func removeDuplicates(by predicate: @escaping (Element, Element) -> Bool, maxAttempts: Int = 100) -> RandomGenerators.RemoveDuplicates<Self> {
        RandomGenerators.RemoveDuplicates(self, predicate: predicate, maxAttempts: maxAttempts)
    }
}
