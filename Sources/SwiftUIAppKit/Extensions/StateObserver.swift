import SwiftUI

public struct StateObserver<Obs, Content>: View where Obs: ObservableObject, Content: View {
    @State private var obs: Obs?
    private var content: Content
    private var initializer: () -> Obs

    public init(_ initializer: @autoclosure @escaping () -> Obs, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.initializer = initializer
    }

    public var body: some View {
        if let obs = obs {
            content.environmentObject(obs)
        } else {
            Color.clear.onAppear(perform: initialize)
        }
    }

    private func initialize() {
        obs = initializer()
    }
}
