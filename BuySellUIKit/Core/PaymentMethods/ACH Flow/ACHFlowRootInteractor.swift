//
//  ACHFlowRootInteractor.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 03/12/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RIBs
import RxSwift

struct ACHFlow {
    enum Screen {
        case selectMethod
        case addPaymentMethod
    }
}

protocol ACHFlowRootRouting: Routing {
    // Declare methods the interactor can invoke to manage sub-tree via the router.
    func route(to screen: ACHFlow.Screen)
    func closeFlow()
}

protocol ACHFlowRootListener: class {
    // Declare methods the interactor can invoke to communicate with other RIBs.
}

final class ACHFlowRootInteractor: Interactor,
                                   ACHFlowRootInteractable,
                                   SelectPaymentMethodListener {

    // MARK: - Injected

    weak var router: ACHFlowRootRouting?
    weak var listener: ACHFlowRootListener?

    private let stateService: StateServiceAPI

    init(stateService: StateServiceAPI) {
        self.stateService = stateService
        super.init()
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // TODO: Check if there are no available methods and route to `addPaymentMethod`
        router?.route(to: .selectMethod)
    }

    func closeFlow() {
        // this dismiss the navigation flow...
        stateService.previousRelay.accept(())
        router?.closeFlow()
    }
}
