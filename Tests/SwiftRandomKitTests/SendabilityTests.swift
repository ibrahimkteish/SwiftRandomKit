import Testing
import SwiftRandomKit
import SwiftRandomKitGenerators

/// Compile-time checks: closure-free combinators of Sendable generators are Sendable,
/// so leaf-only compositions can be shared across isolation domains.
struct SendabilityTests {

    private func requiresSendable<T: Sendable>(_: T) {}

    @Test func closureFreeCombinatorsOfSendableLeavesAreSendable() {
        requiresSendable(IntGenerator(in: 1...6))
        requiresSendable(FloatGenerator<Double>(in: 0...1))
        requiresSendable(BoolGenerator())
        requiresSendable(Always([1, 2, 3]))
        requiresSendable(RandomGenerators.Character(in: "a"..."z"))
        requiresSendable(Dice.d20)

        requiresSendable(IntGenerator(in: 1...6).array(3))
        requiresSendable(IntGenerator(in: 1...6).arrayGenerator(Always(3)))
        requiresSendable(IntGenerator(in: 1...6).collection(Always(3)))
        requiresSendable([IntGenerator(in: 1...6)].collect())
        requiresSendable(Always("a").concat(Always("b"), separator: "-"))
        requiresSendable(RandomGenerators.Dictionary(Always(("key", 1)), Always(2)))
        requiresSendable(Always([1, 2, 3]).element())
        requiresSendable(RandomGenerators.frequency([(1, IntGenerator(in: 1...6))]))
        requiresSendable(IntGenerator(in: 1...6).optional())
        requiresSendable(IntGenerator(in: 1...6).orNil(probability: 0.5))
        requiresSendable(IntGenerator(in: 1...6).print("roll"))
        requiresSendable(Always([1, 2, 3]).shuffled())
        requiresSendable(IntGenerator(in: 1...6).tuple())

        if #available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *) {
            requiresSendable(RandomGenerators.Zip(IntGenerator(in: 1...6), BoolGenerator()))
        }
    }
}
