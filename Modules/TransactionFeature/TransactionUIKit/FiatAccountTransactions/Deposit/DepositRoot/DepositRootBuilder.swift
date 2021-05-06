// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RIBs

// MARK: - Builder

public protocol DepositRootBuildable: Buildable {
    func build() -> DepositRootRouting
}

public final class DepositRootBuilder: DepositRootBuildable {

    public init() { }

    public func build() -> DepositRootRouting {
        let viewController = DepositRootViewController()
        let interactor = DepositRootInteractor()
        viewController.listener = interactor
        let router = DepositRootRouter(interactor: interactor, viewController: viewController)
        interactor.router = router
        return router
    }
}
