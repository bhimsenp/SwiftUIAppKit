import Foundation

public extension Double {
    func withoutTrailingZeros() -> String {
        String(format: "%g", self)
    }

    func toRoundedString(_ decimals: Int = 2) -> String {
        String(format: "%.\(decimals)f", self)
    }

    func toRoundedStringWithSign(_ decimals: Int = 2) -> String {
        String(format: "\(self >= 0 ? "+" : "-")%.\(decimals)f", abs(self))
    }
}
