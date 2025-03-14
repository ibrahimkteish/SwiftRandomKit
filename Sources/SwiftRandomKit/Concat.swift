import Foundation

/// A protocol for types that can be concatenated using the + operator.
///
/// Types conforming to this protocol can be combined using the + operator,
/// which makes them suitable for use with the `Concat` generator.
public protocol Concatable {
    /// Combines two instances of the type using the + operator.
    /// - Parameters:
    ///   - lhs: The left-hand side value.
    ///   - rhs: The right-hand side value.
    /// - Returns: The combined value.
    static func +(lhs: Self, rhs: Self) -> Self
}

extension RandomGenerators {
    /// A generator that concatenates the output of two generators with an optional separator.
    ///
    /// The `Concat` generator combines the output of two generators using the + operator,
    /// with an optional separator in between. This is particularly useful for string generators
    /// or other types that can be meaningfully concatenated.
    ///
    /// Note: This generator works with non-optional values. For generators that produce optional values
    /// (such as those created with `element()`), you'll need to handle the optionals manually.
    ///
    /// Example usage:
    /// ```swift
    /// // Concatenate two string generators
    /// let firstNameGen = Always("John")
    /// let lastNameGen = Always("Smith")
    /// let fullNameGen = firstNameGen.concat(lastNameGen, separator: " ")
    /// let fullName = fullNameGen.run() // "John Smith"
    ///
    /// // Concatenate with empty separator
    /// let domainGen = Always("gmail")
    /// let tldGen = Always("com")
    /// let emailDomainGen = domainGen.concat(tldGen, separator: ".")
    /// let domain = emailDomainGen.run() // "gmail.com"
    ///
    /// // Concatenate arrays or other Concatable types
    /// let firstArrayGen = Always([1, 2, 3])
    /// let secondArrayGen = Always([4, 5, 6])
    /// let combinedArrayGen = firstArrayGen.concat(secondArrayGen, separator: [0])
    /// let combinedArray = combinedArrayGen.run() // [1, 2, 3, 0, 4, 5, 6]
    ///
    /// // For optional values, handle them manually:
    /// let optFirstNameGen = Always(["John", "Jane"]).element()
    /// let optLastNameGen = Always(["Smith", "Johnson"]).element()
    /// 
    /// // Run the generators to get the values
    /// let firstName = optFirstNameGen.run()
    /// let lastName = optLastNameGen.run()
    /// 
    /// // Combine the names manually
    /// let fullName: String
    /// if let first = firstName, let last = lastName {
    ///     fullName = "\(first) \(last)"
    /// } else {
    ///     fullName = "No name generated"
    /// }
    /// ```
    public struct Concat<First: RandomGenerator, Second: RandomGenerator>: RandomGenerator where First.Element == Second.Element, First.Element: Concatable {
        /// The type of elements produced by this generator.
        public typealias Element = First.Element

        /// The first generator in the concatenation.
        public let first: First
        
        /// The second generator in the concatenation.
        public let second: Second
        
        /// The separator to place between the concatenated values.
        public let separator: Element
        
        /// Initializes a new concat generator with the given generators and separator.
        /// - Parameters:
        ///   - first: The first generator in the concatenation.
        ///   - second: The second generator in the concatenation.
        ///   - separator: The separator to place between the concatenated values.
        public init(_ first: First, _ second: Second, separator: Element) {
            self.first = first
            self.second = second
            self.separator = separator
        }

        /// Runs the generator using the provided random number generator.
        /// - Parameter rng: The random number generator to use.
        /// - Returns: The concatenated values from the first and second generators, with the separator in between.
        public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Element {
            first.run(using: &rng) + separator + second.run(using: &rng)
        }
    }
}

extension RandomGenerator {
    /// Creates a generator that concatenates the output of this generator with another generator.
    ///
    /// This method is useful for combining the output of two generators that produce
    /// concatenatable values, such as strings or arrays.
    ///
    /// Note: This method works with non-optional values. For generators that produce optional values
    /// (such as those created with `element()`), you'll need to handle the optionals manually.
    ///
    /// - Parameters:
    ///   - other: The generator to concatenate with this generator.
    ///   - separator: The separator to place between the concatenated values.
    /// - Returns: A generator that produces concatenated values from both generators.
    @inlinable
    public func concat<NewOutput: RandomGenerator>(_ other: NewOutput, separator: Element) -> RandomGenerators.Concat<Self, NewOutput> where NewOutput.Element == Element, Element: Concatable {
        .init(self, other, separator: separator)
    }
}

// Even though String already has a + operator, we need to explicitly declare
// conformance to our Concatable protocol for the type system to recognize it.
// This doesn't introduce any new functionality, it just formalizes the relationship.
extension String: Concatable {}

// Add conformance for Array, which already has a + operator for concatenation
extension Array: Concatable {}

// Add conformance for other standard library types that support concatenation
extension Data: Concatable {}
