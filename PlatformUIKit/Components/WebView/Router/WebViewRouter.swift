//
//  WebViewRouter.swift
//  Blockchain
//
//  Created by Daniel Huri on 19/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa

public final class WebViewRouter: WebViewRouterAPI {
    
    // MARK: - Exposed
    
    public let launchRelay = PublishRelay<TitledLink>()
    
    // MARK: - Private

    private var launch: Signal<TitledLink> {
        launchRelay.asSignal()
    }
    
    private let disposeBag = DisposeBag()

    // MARK: - Injected
    
    private let topMostViewControllerProvider: TopMostViewControllerProviding
    private let webViewServiceAPI: WebViewServiceAPI
    
    // MARK: - Setup
    
    public init(topMostViewControllerProvider: TopMostViewControllerProviding,
                webViewServiceAPI: WebViewServiceAPI) {
        self.topMostViewControllerProvider = topMostViewControllerProvider
        self.webViewServiceAPI = webViewServiceAPI
        
        launch
            .map { $0.url }
            .emit(onNext: { [weak self] url in
                guard let self = self else { return }
                guard let topViewController = self.topMostViewControllerProvider.topMostViewController else {
                    return
                }
                self.webViewServiceAPI.openSafari(url: url, from: topViewController)
            })
            .disposed(by: disposeBag)
    }
}
