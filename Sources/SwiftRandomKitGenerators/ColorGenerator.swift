import SwiftRandomKit

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import CoreGraphics

public struct ColorGenerator: RandomGenerator {
    public typealias Element = (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)

    let alpha: CGFloat

    public init(alpha: CGFloat = 1) {
        self.alpha = alpha
    }

    public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Element {
        let red = FloatGenerator<CGFloat>(in: 0...1).run(using: &rng)
        let green = FloatGenerator<CGFloat>(in: 0...1).run(using: &rng)
        let blue = FloatGenerator<CGFloat>(in: 0...1).run(using: &rng)
        return (red: red, green: green, blue: blue, alpha: self.alpha)
    }
}

#if canImport(UIKit)
import UIKit
extension ColorGenerator {
    /// Generates a random `UIColor`. The alpha component comes from the
    /// generator's `alpha` value provided at initialization.
    public func uiColor(using rng: inout some RandomNumberGenerator) -> UIColor {
        let (red, green, blue, alpha) = self.run(using: &rng)
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
#endif

#if canImport(SwiftUI)
import SwiftUI
extension ColorGenerator {
    /// Generates a random SwiftUI `Color`. The opacity comes from the
    /// generator's `alpha` value provided at initialization.
    public func swiftUIColor(using rng: inout some RandomNumberGenerator) -> Color {
        let (red, green, blue, alpha) = self.run(using: &rng)
        return Color(red: Double(red), green: Double(green), blue: Double(blue), opacity: Double(alpha))
    }
}
#endif
#endif // End of Apple platforms
