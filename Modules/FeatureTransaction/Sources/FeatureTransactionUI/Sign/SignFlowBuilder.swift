// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RIBs

protocol SignFlowBuildable: Buildable {
    func build(with listener: SignFlowListening, interactor: SignFlowInteractor) -> SignFlowRouting
}

final class SignFlowBuilder: SignFlowBuildable {

    func build(with listener: SignFlowListening, interactor: SignFlowInteractor) -> SignFlowRouting {
        let router = SignFlowRouter(interactor: interactor)
        interactor.listener = listener
        interactor.router = router
        return router
    }
}
