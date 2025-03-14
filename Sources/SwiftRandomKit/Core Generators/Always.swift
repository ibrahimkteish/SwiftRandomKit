
extension RandomGenerators {
    /// A generator that always produces the given value, regardless of the random number generator used.
    ///
    /// While simple, the `Always` generator is useful when combined with other generators or operators.
    /// It can serve as a constant value in a chain of generator operations.
    ///
    /// When its `Element` is `Void`, it can be used as a "no-op" generator and be plugged into
    /// other generator operations:
    ///
    public struct Always<Element>: RandomGenerator {
        /// The value that this generator will always produce
        let value: Element

        /// Creates a generator that always produces the given value.
        ///
        /// - Parameter value: The value that will be returned every time this generator runs.
        public init(_ value: Element) {
            self.value = value
        }

        /// Runs the generator, always returning the stored value regardless of the provided RNG.
        ///
        /// - Parameter rng: The random number generator (unused in this implementation).
        /// - Returns: The stored value.
        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Element {
            value
        }
    }
}

extension RandomGenerator {
    @inlinable
    public func always(_ value: Element) -> RandomGenerators.Always<Element> {
        .init(value)
    }
}

public typealias Always<Element> = RandomGenerators.Always<Element>

extension Always: Equatable where Element: Equatable {}
extension Always: Sendable where Element: Sendable {}
extension Always: Hashable where Element: Hashable {}

extension Always where Element: Equatable {
    public func removeDuplicates() -> Always<Element> {
        return self
    }
}

extension Always {

    public func collect() -> Always<[Element]> {
        return .init([value])
    }

    public func map<ElementOfResult>(
        _ transform: (Element) -> ElementOfResult
    ) -> Always<ElementOfResult> {
        return .init(transform(value))
    }

    public func removeDuplicates(
        by predicate: (Element, Element) -> Bool
    ) -> Always<Element> {
        return self
    }
}