//
//  CardAuthorizationScreenViewController.swift
//  Blockchain
//
//  Created by Daniel Huri on 14/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import WebKit

final class CardAuthorizationScreenViewController: BaseScreenViewController {
    
    // MARK: - UI Properties
    
    private lazy var webView: WKWebView = {
        let script = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
        let userScript = WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let userContentController = WKUserContentController()
        userContentController.addUserScript(userScript)
        let config = WKWebViewConfiguration()
        config.userContentController = userContentController
        return WKWebView(frame: view.bounds, configuration: config)
    }()
    
    // MARK: - Injected
    
    private let presenter: CardAuthorizationScreenPresenter
    private var exitUrl: URL!
    
    // MARK: - Setup
    
    init(presenter: CardAuthorizationScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switch presenter.authorizationState {
        case .required(let urls):
            self.exitUrl = urls.exitLink
            view.addSubview(webView)
            webView.fillSuperview()
            webView.navigationDelegate = self
            webView.load(URLRequest(url: urls.paymentLink))
        case .none, .confirmed:
            break
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        switch presenter.authorizationState {
        case .none, .confirmed:
            presenter.redirect()
        case .required:
            break
        }
    }
        
    private func setupNavigationBar() {
        set(barStyle: .darkContent())
        titleViewStyle = .text(value: presenter.title)
    }
}

// MARK: WKNavigationDelegate

extension CardAuthorizationScreenViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        if navigationAction.request.url?.host == exitUrl.host {
            presenter.redirect()
        }

        decisionHandler(.allow)
    }
}
