// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RIBs

// MARK: - Builder

protocol InterestTransactionBuildable: Buildable {
    func buildWithInteractor(
        _ interactor: InterestTransactionInteractor
    ) -> InterestTransactionRouter
}

final class InterestTransactionBuilder: InterestTransactionBuildable {

    init() {}

    func buildWithInteractor(
        _ interactor: InterestTransactionInteractor
    ) -> InterestTransactionRouter {
        let router = InterestTransactionRouter(interactor: interactor)
        interactor.router = router
        return router
    }
}
