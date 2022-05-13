import SwiftUI

public extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }

    func withSafeAreaTopPadding() -> some View {
        self.padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0)
    }

    func withSafeAreaBottomPadding() -> some View {
        self.padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0)
    }
}

struct SizePreferenceKey: PreferenceKey {
    typealias Value = CGSize
    static var defaultValue = CGSize.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = CGSize(width: value.width + nextValue().width, height: value.height + nextValue().height)
    }
}
