import SwiftUI
import Combine

public struct ExpandableTextInput: UIViewRepresentable {
    @Binding var text: String
    @Binding var isFocused: Bool
    @Binding var height: CGFloat
    let onEditingChanged: (Bool) -> Void
    private let maxHeight: CGFloat = 100

    public init(text: Binding<String>, isFocused: Binding<Bool>, height: Binding<CGFloat>, onEditingChanged: @escaping (Bool) -> Void) {
        self._text = text
        self._isFocused = isFocused
        self._height = height
        self.onEditingChanged = onEditingChanged
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public func makeUIView(context: Context) -> UITextView {
        let uiTextView = UITextView()
        uiTextView.delegate = context.coordinator
        uiTextView.backgroundColor = .clear
        uiTextView.autocorrectionType = .default
        uiTextView.translatesAutoresizingMaskIntoConstraints = false
        uiTextView.isScrollEnabled = false
        context.coordinator.heightConstraint = uiTextView.heightAnchor.constraint(equalToConstant: 33)
        NSLayoutConstraint.activate([
            uiTextView.widthAnchor.constraint(equalToConstant: 250),
            context.coordinator.heightConstraint
        ])
        return uiTextView
    }

    public func updateUIView(_ uiView: UITextView, context: Context) {
        if self.text != uiView.text {
            uiView.text = text
        }
        if self.isFocused {
            uiView.becomeFirstResponder()
        } else {
            uiView.resignFirstResponder()
        }
    }

    public class Coordinator: NSObject, UITextViewDelegate {
        var textViewParent: ExpandableTextInput
        var heightConstraint: NSLayoutConstraint!

        init(_ textView: ExpandableTextInput) {
            self.textViewParent = textView
            super.init()
        }

        public func textViewDidBeginEditing(_ textView: UITextView) {
            if !textViewParent.isFocused {
                textViewParent.isFocused = true
                textViewParent.onEditingChanged(true)
            }
        }

        public func textViewDidEndEditing(_ textView: UITextView) {
            textViewParent.text = textView.text
            if textViewParent.isFocused {
                textViewParent.isFocused = false
                textViewParent.onEditingChanged(false)
            }
        }

        public func textViewDidChange(_ textView: UITextView) {
            textViewParent.text = textView.text
            updateHeight(textView)
        }

        private func updateHeight(_ textView: UITextView) {
            let isScrollEnabled = textView.contentSize.height >= textViewParent.maxHeight
            let contentHeight = textView.text.height(withConstrainedWidth: textView.frame.width, font: textView.font!) + 16
            let height = min(contentHeight, textViewParent.maxHeight)
            textViewParent.height = height
            heightConstraint.constant = height
            textView.setNeedsLayout()
            textView.layoutIfNeeded()
            if isScrollEnabled {
                NSLayoutConstraint.activate([heightConstraint])
            } else {
                NSLayoutConstraint.deactivate([heightConstraint])
            }
            textView.isScrollEnabled = isScrollEnabled
        }
    }
}
