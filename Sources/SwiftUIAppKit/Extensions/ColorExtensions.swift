import UIKit
import SwiftUI

public extension Color {
    init(redComp: Int, greenComp: Int, blueComp: Int, alpha: CGFloat = 1.0) {
        assert(redComp >= 0 && redComp <= 255, "Invalid red component")
        assert(greenComp >= 0 && greenComp <= 255, "Invalid green component")
        assert(blueComp >= 0 && blueComp <= 255, "Invalid blue component")
        self.init(.sRGB, red: Double(redComp)/255, green: Double(greenComp)/255, blue: Double(blueComp)/255, opacity: alpha)
    }

    init(rgb: Int) {
        self.init(
            redComp: (rgb >> 16) & 0xFF,
            greenComp: (rgb >> 8) & 0xFF,
            blueComp: rgb & 0xFF,
            alpha: (rgb >> 24) & 0xFF == 0 ? 1.0 : Double((rgb >> 24) & 0xFF)/255.0
        )
    }
}

public extension UIColor {
    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1.0) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }

    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF,
            alpha: (rgb >> 24) & 0xFF == 0 ? 1.0 : CGFloat((rgb >> 24) & 0xFF)/255.0
        )
    }
}
