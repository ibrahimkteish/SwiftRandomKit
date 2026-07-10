extension RandomGenerators {
    /// A generator that avoids returning the same value twice in a row.
    ///
    /// This generator maintains state between runs. It is intentionally not `Sendable`:
    /// the compiler confines an instance to a single isolation domain, so no locking
    /// is needed to protect its state.
    ///
    /// > Important: Although this is a struct, its last-value state lives in a shared
    /// > reference. Copies of a `RemoveDuplicates` generator share that state: a value
    /// > generated through one copy also counts as "the previous value" for every other
    /// > copy. Create a fresh generator (not a copy) for independent duplicate tracking.
    public struct RemoveDuplicates<Upstream: RandomGenerator>: RandomGenerator {
        public typealias Element = Upstream.Element

        /// Storage for the last generated value, shared across copies of the struct.
        private final class Storage {
            var lastValue: Upstream.Element?
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
            // If no previous value, simply generate and store
            guard let lastValue = storage.lastValue else {
                let newValue = generator.run(using: &rng)
                storage.lastValue = newValue
                return newValue
            }

            // Use AttemptBounded to generate a non-duplicate value
            let boundedGenerator = generator.attemptBounded(
                maxAttempts: maxAttempts,
                condition: { newValue in !self.predicate(newValue, lastValue) },
                fallbackStrategy: .useLast // Accept duplicates after maxAttempts
            )

            let nextValue = boundedGenerator.run(using: &rng)
            storage.lastValue = nextValue
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
        return RandomGenerators.RemoveDuplicates(self, predicate: { $0 == $1 }, maxAttempts: maxAttempts)
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
