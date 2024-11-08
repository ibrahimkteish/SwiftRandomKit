extension RandomGenerators {
    public struct Zip<R1: RandomGenerator, R2: RandomGenerator>: RandomGenerator {
        public typealias Element = (R1.Element, R2.Element)

        let generator1: R1
        let generator2: R2

        public init(_ generator1: R1, _ generator2: R2) {
            self.generator1 = generator1
            self.generator2 = generator2
        }

        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Element {
            return (generator1.run(using: &rng), generator2.run(using: &rng))
        }
    }
}

extension RandomGenerators {
   public struct Zip3<R1: RandomGenerator, R2: RandomGenerator, R3: RandomGenerator>: RandomGenerator {
       public typealias Element = (R1.Element, R2.Element, R3.Element)

       let generator1: R1
       let generator2: R2
       let generator3: R3

       public init(_ generator1: R1, _ generator2: R2, _ generator3: R3) {
           self.generator1 = generator1
           self.generator2 = generator2
           self.generator3 = generator3
       }

       public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Element {
           return (generator1.run(using: &rng), generator2.run(using: &rng), generator3.run(using: &rng))
       }
   }
}

extension RandomGenerators {
    public struct Zip4<R1: RandomGenerator, R2: RandomGenerator, R3: RandomGenerator, R4: RandomGenerator>: RandomGenerator {
        public typealias Element = (R1.Element, R2.Element, R3.Element, R4.Element)

        let generator1: R1
        let generator2: R2
        let generator3: R3
        let generator4: R4

        public init(_ generator1: R1, _ generator2: R2, _ generator3: R3, _ generator4: R4) {
            self.generator1 = generator1
            self.generator2 = generator2
            self.generator3 = generator3
            self.generator4 = generator4
        }

        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Element {
            return (generator1.run(using: &rng), generator2.run(using: &rng), generator3.run(using: &rng), generator4.run(using: &rng))
        }
    }
}

extension RandomGenerator {
   public func zip<R: RandomGenerator>(_ other: R) -> RandomGenerators.Zip<Self, R> {
        .init(self, other)
   }

    public func zip<R: RandomGenerator, T>(_ other: R, _ transform: @escaping (Self.Element, R.Element) -> T) -> RandomGenerators.Map<RandomGenerators.Zip<Self, R>, T> {
        .init(.init(self, other), transform)
    }

    public func zip<Other1, Other2, Result>(
        _ other1: Other1,
        _ other2: Other2,
        _ transform: @escaping (Self.Element, Other1.Element, Other2.Element) -> Result
    ) ->  RandomGenerators.Map<RandomGenerators.Zip3<Self, Other1, Other2>, Result>
    where Other1: RandomGenerator, Other2: RandomGenerator, Self.Element == Other1.Element, Other1.Element == Other2.Element {
        .init(.init(self, other1, other2), transform)
    }

    public func zip<Other1, Other2, Other3, Result>(
        _ other1: Other1,
        _ other2: Other2,
        _ other3: Other3,
        _ transform: @escaping (Self.Element, Other1.Element, Other2.Element, Other3.Element) -> Result
    ) ->  RandomGenerators.Map<RandomGenerators.Zip4<Self, Other1, Other2, Other3>, Result>
    where Other1: RandomGenerator, Other2: RandomGenerator, Other3: RandomGenerator, Self.Element == Other1.Element, Other1.Element == Other2.Element, Other2.Element == Other3.Element {
        .init(.init(self, other1, other2, other3), transform)
    }
}
