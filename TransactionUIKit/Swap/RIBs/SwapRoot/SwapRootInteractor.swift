//
//  SwapRootInteractor.swift
//  TransactionUIKit
//
//  Created by Paulo on 29/09/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RIBs

protocol SwapRootListener: ViewListener { }

final class SwapRootInteractor: Interactor, SwapBootstrapListener, SwapRootListener, NewSwapListener, AmountInputListener {

    weak var router: SwapRootRouting?

    func userIsIneligibleForSwap() {
        router?.routeToComingSoon()
    }

    func userMustKYCForSwap() {
        router?.routeToKYC()
    }
    
    func userReadyForSwap() {
        router?.routeToNewSwap()
    }

    func routeToSwap(with pair: (CurrencyType, CurrencyType)?) {
        router?.routeToSwap(with: pair)
    }

    func userSelected(pair: (CurrencyType, CurrencyType), amount: Decimal) {
        // router
    }

    private lazy var routeViewDidAppear: Void = {
        router?.routeToSwapBootstrap()
    }()
    
    func viewDidAppear() {
        // if first time, got to variant router
        _ = routeViewDidAppear
    }
}
