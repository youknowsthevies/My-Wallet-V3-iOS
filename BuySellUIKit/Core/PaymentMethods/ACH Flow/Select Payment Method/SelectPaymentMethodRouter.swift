//
//  SelectPaymentMethodRouter.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 03/12/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RIBs

protocol SelectPaymentMethodInteractable: Interactable {
    var router: SelectPaymentMethodRouting? { get set }
    var listener: SelectPaymentMethodListener? { get set }
}

protocol SelectPaymentMethodViewControllable: ViewControllable {
    // Declare methods the router invokes to manipulate the view hierarchy.
}

final class SelectPaymentMethodRouter: ViewableRouter<SelectPaymentMethodInteractable, SelectPaymentMethodViewControllable>,
                                       SelectPaymentMethodRouting {

    // Constructor inject child builder protocols to allow building children.
    override init(interactor: SelectPaymentMethodInteractable, viewController: SelectPaymentMethodViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
