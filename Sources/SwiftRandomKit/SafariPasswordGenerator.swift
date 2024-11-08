
public struct SafariPasswordGenerator: RandomGenerator {
    public init() {}

    public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> String {
        // huwKun-1zyjxi-nyxseh
        let chars =  Always(
            Array(
  "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            )
        )

        let alphanum = chars.element().map { $0! }
        let passwordSegment = alphanum.array(6).map(charsToString)
        let password = passwordSegment.array(3).map { $0.joined(separator: "-") }
        return password.run(using: &rng)
    }
}

func charsToString(_ chars: [Character]) -> String {
    chars.map(String.init).joined()
}