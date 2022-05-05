// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI
import WebKit

/// A UIViewRepresentable wrapper of WKWebView
public struct WebView: UIViewRepresentable {

    public var url: URL

    public init(url: URL) {
        self.url = url
    }

    public func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }

    public func updateUIView(_ webView: WKWebView, context: Context) {
        webView.load(URLRequest(url: url))
    }
}
