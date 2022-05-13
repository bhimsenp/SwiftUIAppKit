import SwiftUI
import WebKit

public struct URLWebView: UIViewRepresentable {
    public let url: String
    public init(url: String) {
        self.url = url
    }
    public func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }

    public func updateUIView(_ uiView: WKWebView, context: Context) {
        if let urlObj = URL(string: url) {
            uiView.load(URLRequest(url: urlObj))
        }
    }
}
