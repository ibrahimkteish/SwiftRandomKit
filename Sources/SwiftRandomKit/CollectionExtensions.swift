import Foundation

/// Extensions to make working with collections and generators more convenient.
extension Collection where Self: Sendable, Element: Sendable {
    /// Converts a collection to an Always generator that produces this collection.
    ///
    /// This is a convenience method that wraps the collection in an `Always` generator,
    /// making it easier to use collections with the generator pipeline.
    ///
    /// Example usage:
    /// ```swift
    /// let colors = ["red", "green", "blue"].asGenerator().element().run()
    /// ```
    ///
    /// - Returns: An Always generator that produces this collection.
    public func asGenerator() -> RandomGenerators.Always<Self> {
        return RandomGenerators.Always(self)
    }
    
    /// Creates a generator that selects a random element from this collection.
    ///
    /// This is a convenience method that combines `asGenerator()` and `element()` to
    /// create a generator that selects a random element from the collection.
    ///
    /// Example usage:
    /// ```swift
    /// let colors = ["red", "green", "blue"]
    /// let randomColorGen = colors.randomElement()
    /// let randomColor = randomColorGen.run() // e.g., "blue"
    /// ```
    ///
    /// - Returns: A generator that produces random elements from this collection.
    public func randomGeneratorElement() -> RandomGenerators.Element<RandomGenerators.Always<Self>> {
        return self.asGenerator().element()
    }
} 
