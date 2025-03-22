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
        private final class Storage: @unchecked Sendable {
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
    
        private let generator: Upstream
        private let storage = Storage()
        private let predicate: @Sendable (Element, Element) -> Bool
        private let maxAttempts: Int
        
        /// Creates a generator that avoids returning consecutive duplicate values
        ///
        /// - Parameters:
        ///   - generator: The upstream generator
        ///   - predicate: A function that returns true if two values are considered equal
        ///   - maxAttempts: Maximum number of attempts to generate a non-duplicate value before giving up
        public init(_ generator: Upstream, predicate: @Sendable @escaping (Element, Element) -> Bool, maxAttempts: Int = 100) {
            self.generator = generator
            self.predicate = predicate
            self.maxAttempts = maxAttempts > 0 ? maxAttempts : 100
        }
    
        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Upstream.Element {
            // Get the last value (thread-safe)
            let lastValue = storage.getLastValue()
            
            // If no previous value, simply generate and store
            if lastValue == nil {
                let newValue = generator.run(using: &rng)
                storage.setLastValue(newValue)
                return newValue
            }
            
            // Use AttemptBounded to generate a non-duplicate value
            let boundedGenerator = generator.attemptBounded(
                maxAttempts: maxAttempts,
                condition: { newValue in
                    // Only accept values that don't match the last value
                    lastValue.map { !self.predicate(newValue, $0) } ?? true
                },
                fallbackStrategy: .useLast // Accept duplicates after maxAttempts
            )
            
            // Generate the next value
            let nextValue = boundedGenerator.run(using: &rng)
            
            // Save and return the new value
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
        return RandomGenerators.RemoveDuplicates(self, predicate: { @Sendable in $0 == $1 }, maxAttempts: maxAttempts)
    }
}

public extension RandomGenerator {
    /// Returns a generator that avoids generating consecutive duplicate values according to a predicate
    /// 
    /// - Parameters:
    ///   - predicate: A function that returns true if two values are considered equal
    ///   - maxAttempts: Maximum number of attempts to generate a non-duplicate value before giving up. Default is 100.
    /// - Returns: A generator that tries to avoid duplicates
    func removeDuplicates(by predicate: @Sendable @escaping (Element, Element) -> Bool, maxAttempts: Int = 100) -> RandomGenerators.RemoveDuplicates<Self> {
        RandomGenerators.RemoveDuplicates(self, predicate: predicate, maxAttempts: maxAttempts)
    }
}
