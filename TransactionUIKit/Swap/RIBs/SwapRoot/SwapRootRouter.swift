//
//  SwapRootRouter.swift
//  TransactionUIKit
//
//  Created by Paulo on 29/09/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RIBs

public protocol SwapRootRouting: ViewableRouting {
    func routeToSwapBootstrap()
    func routeToNewSwap()
    func routeToComingSoon()
    func routeToKYC()
    func routeToSwap(with pair: (CurrencyType, CurrencyType)?)
}

final class SwapRootRouter: ViewableRouter<SwapRootInteractor, SwapRootViewControllable>, SwapRootRouting {

    func routeToSwapBootstrap() {
        let router = SwapBootstrapBuilder().build(withListener: interactor)
        let viewControllable = router.viewControllable
        attachChild(router)
        viewController.replaceRoot(viewController: viewControllable)
    }

    func routeToNewSwap() {
        let router = NewSwapBuilder().build(withListener: interactor)
        let viewControllable = router.viewControllable
        attachChild(router)
        viewController.replaceRoot(viewController: viewControllable)
    }

    func routeToComingSoon() {
        // TODO: Route to Coming Soon
        routeToNewSwap()
    }

    func routeToKYC() {
        // TODO: Route to KYC
        routeToNewSwap()
    }

    func routeToSwap(with pair: (CurrencyType, CurrencyType)?) {
        if let pair = pair {
            routeToPriceInput(with: pair)
        } else {
            routeToFromWalletPicker()
        }
    }

    private func routeToFromWalletPicker() {
        // TODO:
    }

    private func routeToPriceInput(with pair: (CurrencyType, CurrencyType)) {
        let router = AmountInputBuilder(pair: pair).build(withListener: interactor)
        let viewControllable = router.viewControllable
        attachChild(router)
        viewController.push(viewController: viewControllable)
    }
}
