import SwiftUI

public struct Dialog<Content: View>: View {
    let dialogContent: () -> Content
    let onClose: () -> Void

    public init(dialogContent: @escaping () -> Content, onClose: @escaping () -> Void) {
        self.dialogContent = dialogContent
        self.onClose = onClose
    }

    public var body: some View {
        ZStack(alignment: .center) {
            dialogContent()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.75))
        .edgesIgnoringSafeArea(.all)
    }
}

public typealias CloseDialogCallback = () -> Void

public struct DialogUtils {
    public static func show<Content: View>(dialogBuilder: @escaping ((@escaping CloseDialogCallback) -> Content), transition: UIModalTransitionStyle = .crossDissolve) {
        var source: UIViewController?
        let dialog = Dialog(dialogContent: {
            dialogBuilder {
                source?.dismiss(animated: true, completion: nil)
            }
        }, onClose: {
            source?.dismiss(animated: true, completion: nil)
        })
        source = UIHostingController(rootView: dialog)
        source?.view.backgroundColor = .clear
        let viewController = UIApplication.shared.windows.first?.rootViewController
        source?.modalPresentationStyle = .overCurrentContext
        source?.modalTransitionStyle = transition
        viewController?.present(source!, animated: true, completion: nil)
    }
}
