extension RandomGenerators {
    /// A generator that produces a shuffled version of the collection from the upstream generator.
    ///
    /// Example usage:
    /// ```swift
    /// // Create a generator with a fixed array
    /// let numbers = Always([1, 2, 3, 4, 5])
    /// 
    /// // Create a shuffled generator
    /// let shuffled = numbers.shuffled()
    /// 
    /// // Get a shuffled array (e.g., [3, 1, 5, 2, 4])
    /// let result = shuffled.run()
    /// 
    /// // You can also chain it with other generators:
    /// let multiShuffle = numbers.array(3).shuffled().run()
    /// // Might produce: [[2, 4, 1, 5, 3], [5, 1, 3, 2, 4], [3, 5, 2, 1, 4]]
    /// ```
    public struct Shuffled<Upstream: RandomGenerator>: RandomGenerator where Upstream.Element: Swift.Collection, Upstream.Element: MutableCollection, Upstream.Element: RandomAccessCollection, Upstream.Element.Element: Equatable {
        public typealias Element = Upstream.Element
        public let generator: Upstream

        @inlinable
        public init(_ generator: Upstream) {
            self.generator = generator
        }

        @inlinable
        @inline(__always)
        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Upstream.Element {
            var array = generator.run(using: &rng)
            array.shuffle(using: &rng)
            return array
        }
    }
}

public extension RandomGenerator where Element: Collection & MutableCollection & RandomAccessCollection, Element.Element: Equatable {
    @inlinable
    func shuffled() -> RandomGenerators.Shuffled<Self> {
        .init(self)
    }
}