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

    private weak var bootstrap: SwapBootstrapRouting?

    func routeToSwapBootstrap() {
        let router = SwapBootstrapBuilder().build(withListener: interactor)
        let viewControllable = router.viewControllable
        bootstrap = router
        attachChild(router)
        viewController.replaceRoot(viewController: viewControllable)
    }

    func routeToNewSwap() {
        if let child = bootstrap {
            detachChild(child)
            bootstrap = nil
        }
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
            routeToSourceAccountPicker()
        }
    }

    private func routeToSourceAccountPicker() {
        let header = AccountPickerSimpleHeaderModel(
            title: "Swap",
            subtitle: "Which wallet do you want to Swap from?"
        )
        let builder = AccountPickerBuilder(
            singleAccountsOnly: true,
            action: .swap,
            navigationModel: ScreenNavigationModel.AccountPicker.navigation,
            headerModel: .simple(header)
        )
        let router = builder.build { [weak self] account in
            self?.routeToDestinationAccountPicker(source: account)
        }
        let viewControllable = router.viewControllable
        attachChild(router)
        viewController.push(viewController: viewControllable)
    }

    private func routeToDestinationAccountPicker(source sourceAccount: BlockchainAccount) {
        guard let sourceAccount = sourceAccount as? CryptoAccount else { return }
        let header = AccountPickerSimpleHeaderModel(
            title: "Receive",
            subtitle: "Which crypto do you want to Swap for?"
        )
        let builder = AccountPickerBuilder(
            singleAccountsOnly: true,
            action: .swap,
            sourceAccount: sourceAccount,
            navigationModel: ScreenNavigationModel.AccountPicker.navigation,
            headerModel: .simple(header)
        )
        let router = builder.build { [weak self] account in
            // TODO: Navigate to price input
        }
        let viewControllable = router.viewControllable
        attachChild(router)
        viewController.push(viewController: viewControllable)
    }

    private func routeToPriceInput(with pair: (CurrencyType, CurrencyType)) {
        let router = AmountInputBuilder(pair: pair).build(withListener: interactor)
        let viewControllable = router.viewControllable
        attachChild(router)
        viewController.push(viewController: viewControllable)
    }
}
