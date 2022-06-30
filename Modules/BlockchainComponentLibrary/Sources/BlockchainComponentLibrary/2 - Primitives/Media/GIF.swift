import SwiftUI
import WebKit

public struct GIF {

    private let data: Data

    public init(data: Data) {
        self.data = data
    }
}

extension GIF: DataContent {

    public init?(_ data: Data?) {
        guard let data = data else { return nil }
        self.data = data
    }
}

#if canImport(AppKit)
extension GIF: NSViewRepresentable {

    public func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(
            data,
            mimeType: "image/gif",
            characterEncodingName: "UTF-8",
            baseURL: URL(string: "https://blockchain.com")!
        )
        return webView
    }

    public func updateNSView(_ webView: WKWebView, context: Context) {
        webView.reload()
    }
}
#endif

#if canImport(UIKit)
extension GIF: UIViewRepresentable {

    public func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        webView.load(
            data,
            mimeType: "image/gif",
            characterEncodingName: "UTF-8",
            baseURL: URL(string: "https://blockchain.com")!
        )
        return webView
    }

    public func updateUIView(_ webView: WKWebView, context: Context) {
        webView.reload()
    }
}
#endif
