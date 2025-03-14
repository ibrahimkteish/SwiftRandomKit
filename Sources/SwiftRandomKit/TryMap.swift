extension RandomGenerators {
    public struct TryMap<Upstream: RandomGenerator, ElementOfResult>: RandomGenerator {
        public typealias Element = Result<ElementOfResult, Error>
        
        public let generator: Upstream
        public let transform: (Upstream.Element) throws -> ElementOfResult

        public init(_ generator: Upstream, _ transform: @escaping (Upstream.Element) throws -> ElementOfResult) {
            self.generator = generator
            self.transform = transform
        }

        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Element {
            do {
                return .success(try transform(generator.run(using: &rng)))
            } catch {
                return .failure(error)
            }
        }
    }
}

extension RandomGenerator {
    @inlinable
    public func tryMap<ElementOfResult>(
        _ transform: @escaping (Element) throws -> ElementOfResult
    ) -> RandomGenerators.TryMap<Self, ElementOfResult> {
        return .init(self, transform)
    }
}
