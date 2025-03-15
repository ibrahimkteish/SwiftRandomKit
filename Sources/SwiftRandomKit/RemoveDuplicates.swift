import Foundation

extension RandomGenerators {
    /// A generator that avoids returning the same value twice in a row.
    ///
    /// This generator maintains state between runs. Basic thread safety is implemented 
    /// to protect access to the internal state, but the overall duplicate-avoidance behavior
    /// may not work as expected in highly concurrent scenarios where multiple threads
    /// are simultaneously generating values from the same instance.
    /// 
    /// For best results in multi-threaded environments, create separate generator
    /// instances for each thread.
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
            
            /// Atomically generates a new value that avoids duplicating the last value
            fileprivate func generateNonDuplicateValue<RNG: RandomNumberGenerator>(
                using generator: Upstream,
                rng: inout RNG,
                predicate: (Element, Element) -> Bool,
                maxAttempts: Int
            ) -> Element {
                lock.lock()
                defer { lock.unlock() }
                
                // If no previous value, simply generate and store
                if lastValue == nil {
                    let newValue = generator.run(using: &rng)
                    lastValue = newValue
                    return newValue
                }
                
                // Try to generate a non-duplicate
                var nextValue: Element
                var attempts = 0
                
                repeat {
                    nextValue = generator.run(using: &rng)
                    attempts += 1
                    // Give up after maxAttempts and just return the value even if duplicate
                    if attempts >= maxAttempts {
                        break
                    }
                } while lastValue != nil && predicate(nextValue, lastValue!)
                
                // Update stored value and return
                lastValue = nextValue
                return nextValue
            }
        }
    
        private let generator: Upstream
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
            // Use the thread-safe method to generate a non-duplicate value
            return storage.generateNonDuplicateValue(
                using: generator,
                rng: &rng,
                predicate: predicate,
                maxAttempts: maxAttempts
            )
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
