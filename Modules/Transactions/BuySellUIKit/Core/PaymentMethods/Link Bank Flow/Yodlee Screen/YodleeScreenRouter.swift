//
//  YodleeScreenRouter.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 11/12/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import DIKit
import PlatformUIKit
import RIBs

struct YodleeRoute {
    enum Path {
        case link(url: URL)
    }
}

protocol YodleeScreenInteractable: Interactable {
    var router: YodleeScreenRouting? { get set }
    var listener: YodleeScreenListener? { get set }
}

protocol YodleeScreenViewControllable: ViewControllable {}

final class YodleeScreenRouter: ViewableRouter<YodleeScreenInteractable, YodleeScreenViewControllable>, YodleeScreenRouting {

    private let webViewService: WebViewServiceAPI

    init(interactor: YodleeScreenInteractable,
         viewController: YodleeScreenViewControllable,
         webViewServiceAPI: WebViewServiceAPI = resolve()) {
        self.webViewService = webViewServiceAPI
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    func route(to path: YodleeRoute.Path) {
        switch path {
        case .link(let url):
            webViewService.openSafari(url: url, from: viewController.uiviewController)
        }
    }
}
