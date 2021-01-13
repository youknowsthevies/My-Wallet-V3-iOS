//
//  YodleeScreenBuilder.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 11/12/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import RIBs
import WebKit

// MARK: - Builder

protocol YodleeScreenBuildable {
    func build(withListener listener: YodleeScreenListener, data: BankLinkageData) -> YodleeScreenRouting
}

final class YodleeScreenBuilder: YodleeScreenBuildable {

    private let stateService: StateServiceAPI
    private let checkoutData: CheckoutData

    init(stateService: StateServiceAPI, checkoutData: CheckoutData) {
        self.stateService = stateService
        self.checkoutData = checkoutData
    }

    func build(withListener listener: YodleeScreenListener, data: BankLinkageData) -> YodleeScreenRouting {
        let webConfiguration = provideYodleeConfiguration()
        let messageHandler = YodleeMessageHandler(webViewConfiguration: webConfiguration)
        let messageService = YodleeMessageService(messageHandler: messageHandler, parser: yodleeMessageParser)
        let activationService = YodleeActivateService()
        let contentReducer = YodleeScreenContentReducer()
        let yodleeRequestProvider = YodleeRequestProvider()
        let viewController = YodleeScreenViewController(webConfiguration: webConfiguration)
        let interactor = YodleeScreenInteractor(presenter: viewController,
                                                bankLinkageData: data,
                                                checkoutData: checkoutData,
                                                stateService: stateService,
                                                yodleeRequestProvider: yodleeRequestProvider,
                                                yodleeMessageService: messageService,
                                                yodleeActivationService: activationService,
                                                contentReducer: contentReducer)
        interactor.listener = listener
        return YodleeScreenRouter(interactor: interactor, viewController: viewController)
    }

    private func provideYodleeConfiguration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.allowsAirPlayForMediaPlayback = false
        configuration.allowsInlineMediaPlayback = false
        configuration.allowsPictureInPictureMediaPlayback = false
        return configuration
    }
}
