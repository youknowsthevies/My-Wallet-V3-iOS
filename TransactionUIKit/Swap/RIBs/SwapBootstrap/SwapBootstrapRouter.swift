//
//  SwapBootstrapRouter.swift
//  TransactionUIKit
//
//  Created by Paulo on 30/09/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RIBs

protocol SwapBootstrapInteractable: Interactable {
    var router: SwapBootstrapRouting? { get set }
    var listener: SwapBootstrapListener? { get set }
}

protocol SwapBootstrapViewControllable: ViewControllable {
}

final class SwapBootstrapRouter: ViewableRouter<SwapBootstrapInteractable, SwapBootstrapViewControllable>, SwapBootstrapRouting {
    override init(interactor: SwapBootstrapInteractable, viewController: SwapBootstrapViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
