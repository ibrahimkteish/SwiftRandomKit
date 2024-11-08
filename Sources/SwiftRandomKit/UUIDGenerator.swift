public struct UUIDGenerator: RandomGenerator {
    public init() {}

    public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> String {
        // example: "f81d4fae-7dec-11d0-a765-00a0c91e6bf6"

        let chars = Always(Array("0123456789abcdef"))
        let hexElement = chars.element().map { $0! }
        let first = hexElement.array(8).map(charsToString)
        let middle = hexElement.array(4).map(charsToString).array(3).map { $0.joined(separator: "-") }
        let last = hexElement.array(12).map(charsToString)
        let all = first.concat(middle, separator: "-").concat(last, separator: "-")

        return all.run(using: &rng)
    }
}

func charsToString(_ chars: [Character]) -> String {
    chars.map(String.init).joined()
}
