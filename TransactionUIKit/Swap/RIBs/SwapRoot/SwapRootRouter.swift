//
//  SwapRootRouter.swift
//  TransactionUIKit
//
//  Created by Paulo on 29/09/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import KYCKit
import KYCUIKit
import PlatformKit
import PlatformUIKit
import RIBs

struct SwapTrendingPair {
    let sourceAccount: CryptoAccount
    let destinationAccount: CryptoAccount
    let enabled: Bool
}

protocol SwapRootRouting: ViewableRouting {
    func routeToSwapBootstrap()
    func routeToSwapLanding()
    func routeToSwapTiers(model: KYCTiersPageModel, present: Bool)
    func routeToKYC()
    func routeToSwap(with pair: SwapTrendingPair?)
}

final class SwapRootRouter: ViewableRouter<SwapRootInteractor, SwapRootViewControllable>, SwapRootRouting {

    private weak var bootstrap: SwapBootstrapRouting?

    func routeToSwapBootstrap() {
        let router = SwapBootstrapBuilder().build(withListener: interactor)
        let viewControllable = router.viewControllable
        bootstrap = router
        attachChild(router)
        viewController.replaceRoot(viewController: viewControllable)
    }

    func routeToSwapLanding() {
        if let child = bootstrap {
            detachChild(child)
            bootstrap = nil
        }
        let router = SwapLandingBuilder().build(withListener: interactor)
        let viewControllable = router.viewControllable
        attachChild(router)
        viewController.replaceRoot(viewController: viewControllable)
    }

    func routeToSwapTiers(model: KYCTiersPageModel, present: Bool) {
        let controller = KYCTiersViewController(pageModel: model)
        if present {
            let nav = UINavigationController(rootViewController: controller)
            viewController.present(viewController: nav)
        } else {
            viewController.replaceRoot(viewController: controller)
        }
    }

    func routeToKYC() {
        let presenter = SwapKYCPresenter()
        let vc = DetailsScreenViewController(presenter: presenter)
        viewController.replaceRoot(viewController: vc)
    }
    
    func routeToSwap(with pair: SwapTrendingPair?) {
        let builder = TransactionFlowBuilder()
        let router = builder.build(
            withListener: interactor,
            action: .swap,
            sourceAccount: pair?.sourceAccount,
            target: pair?.destinationAccount
        )
        let viewControllable = router.viewControllable
        children.forEach { child in
            if child is TransactionFlowRouting {
                detachChild(child)
            }
        }
        attachChild(router)
        viewController.present(viewController: viewControllable)
    }
}
