import SwiftUI

public struct Space: View {
    let width: CGFloat?
    let height: CGFloat?
    public init(width: CGFloat? = nil, height: CGFloat? = nil) {
        self.width = width
        self.height = height
    }
    public var body: some View {
        Spacer().frame(width: width, height: height)
    }
}
