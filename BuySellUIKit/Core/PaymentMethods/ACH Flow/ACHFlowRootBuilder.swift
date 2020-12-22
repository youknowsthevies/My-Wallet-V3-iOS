//
//  ACHFlowRootBuilder.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 03/12/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RIBs

// MARK: - Builder

protocol ACHFlowRootBuildable {
    func build() -> (flow: ACHFlowStarter, viewController: ViewControllable)
}

final class ACHFlowRootBuilder: ACHFlowRootBuildable {

    private let stateService: StateServiceAPI
    
    init(stateService: StateServiceAPI) {
        self.stateService = stateService
    }

    func build() -> (flow: ACHFlowStarter, viewController: ViewControllable) {
        let rootNavigation = RootNavigation()
        let selectPaymentMethodBuilder = SelectPaymentMethodBuilder(stateService: stateService)
        let interactor = ACHFlowRootInteractor(stateService: stateService)
        let router = ACHFlowRootRouter(interactor: interactor,
                                       navigation: rootNavigation,
                                       selectPaymentMethodBuilder: selectPaymentMethodBuilder)
        return (router, rootNavigation)
    }
}
