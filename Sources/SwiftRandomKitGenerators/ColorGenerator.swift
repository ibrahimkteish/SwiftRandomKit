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

extension RandomGenerator {
    @available(*, deprecated, message: "Removed in 2.0: the receiver is ignored. Construct ColorGenerator(alpha:) directly.")
    @inlinable
    public func colorGenerator(alpha: CGFloat = 1) -> ColorGenerator {
        .init(alpha: alpha)
    }
}

#if canImport(UIKit)
import UIKit
extension ColorGenerator {
    @available(*, deprecated, message: "Removed in 2.0: the alpha parameter is silently ignored. Use uiColor(using:) and set alpha at initialization.")
    public func uiColor(alpha: CGFloat = 1, using rng: inout some RandomNumberGenerator) -> UIColor {
        let (red, green, blue, alpha) = self.run(using: &rng)
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

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
@available(macOS 10.15, iOS 13.0, *)
extension ColorGenerator {
    @available(*, deprecated, message: "Removed in 2.0: the alpha parameter is silently ignored. Use swiftUIColor(using:) and set alpha at initialization.")
    public func swiftUIColor(alpha: CGFloat = 1, using rng: inout some RandomNumberGenerator) -> Color {
        let (red, green, blue, alpha) = self.run(using: &rng)
        return Color(red: Double(red), green: Double(green), blue: Double(blue), opacity: Double(alpha))
    }

    /// Generates a random SwiftUI `Color`. The opacity comes from the
    /// generator's `alpha` value provided at initialization.
    public func swiftUIColor(using rng: inout some RandomNumberGenerator) -> Color {
        let (red, green, blue, alpha) = self.run(using: &rng)
        return Color(red: Double(red), green: Double(green), blue: Double(blue), opacity: Double(alpha))
    }
}
#endif
#endif // End of Apple platforms
