extension RandomGenerators {
    public struct Always<Element>: RandomGenerator {
        let value: Element

        public init(_ value: Element) {
            self.value = value
        }

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