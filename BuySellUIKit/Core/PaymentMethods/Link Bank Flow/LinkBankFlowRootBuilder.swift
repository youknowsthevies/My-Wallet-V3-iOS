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

    init(stateService: StateServiceAPI) {
        self.stateService = stateService
    }

    func build(presentingController: NavigationControllerAPI?) -> LinkBankFlowStarter {
        let splashScreenBuilder = LinkBankSplashScreenBuilder(stateService: stateService)
        let yodleeScreenBuilder = YodleeScreenBuilder(stateService: stateService)
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
