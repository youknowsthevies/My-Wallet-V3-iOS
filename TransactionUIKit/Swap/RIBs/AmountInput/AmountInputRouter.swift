//
//  AmountInputRouter.swift
//  TransactionUIKit
//
//  Created by Paulo on 12/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RIBs

protocol AmountInputInteractable: Interactable {
    var router: AmountInputRouting? { get set }
    var listener: AmountInputListener? { get set }
}

protocol AmountInputViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class AmountInputRouter: ViewableRouter<AmountInputInteractable, AmountInputViewControllable>, AmountInputRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: AmountInputInteractable, viewController: AmountInputViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
