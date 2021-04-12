//
//  AddNewPaymentMethodRouter.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 08/12/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RIBs

protocol AddNewPaymentMethodInteractable: Interactable {
    var router: AddNewPaymentMethodRouting? { get set }
    var listener: AddNewPaymentMethodListener? { get set }
}

protocol AddNewPaymentMethodViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class AddNewPaymentMethodRouter: ViewableRouter<AddNewPaymentMethodInteractable, AddNewPaymentMethodViewControllable>,
                                       AddNewPaymentMethodRouting {

    override init(interactor: AddNewPaymentMethodInteractable, viewController: AddNewPaymentMethodViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
