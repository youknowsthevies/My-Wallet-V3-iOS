//
//  CardAuthorizationScreenViewController.swift
//  Blockchain
//
//  Created by Daniel Huri on 14/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import WebKit
import PlatformUIKit

final class CardAuthorizationScreenViewController: BaseScreenViewController {
    
    // MARK: - UI Properties
    
    private let webView = WKWebView()
    
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
        switch presenter.requiredAuthorizationType {
        case .url(let urls):
            self.exitUrl = urls.exitLink
            view.addSubview(webView)
            webView.fillSuperview()
            webView.navigationDelegate = self
            webView.load(URLRequest(url: urls.paymentLink))
        case .none: /// Cannot arrive at this state with a `none` value
            break
        }
    }
        
    private func setupNavigationBar() {
        set(barStyle: .darkContent(ignoresStatusBar: false, background: .white))
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
