//
//  LinkBankFlowRootBuilder.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 10/12/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import PlatformUIKit
import RIBs

// MARK: - Builder

protocol LinkBankFlowRootBuildable {
    /// Builds the flow for linking a new bank
    /// - Parameter presentingController: A `NavigationControllerAPI` object that acts as a presenting controller
    func build(presentingController: NavigationControllerAPI?) -> LinkBankFlowStarter
}

final class LinkBankFlowRootBuilder: LinkBankFlowRootBuildable {

    private let stateService: StateServiceAPI
    private let checkoutData: CheckoutData

    init(stateService: StateServiceAPI, checkoutData: CheckoutData) {
        self.stateService = stateService
        self.checkoutData = checkoutData
    }

    func build(presentingController: NavigationControllerAPI?) -> LinkBankFlowStarter {
        let splashScreenBuilder = LinkBankSplashScreenBuilder(stateService: stateService, checkoutData: checkoutData)
        let yodleeScreenBuilder = YodleeScreenBuilder(stateService: stateService, checkoutData: checkoutData)
        let failureScreenBuilder = LinkBankFailureScreenBuilder()
        let interactor = LinkBankFlowRootInteractor()
        return LinkBankFlowRootRouter(interactor: interactor,
                                      stateService: stateService,
                                      presentingController: presentingController,
                                      splashScreenBuilder: splashScreenBuilder,
                                      yodleeScreenBuilder: yodleeScreenBuilder,
                                      failureScreenBuilder: failureScreenBuilder)
    }
}
