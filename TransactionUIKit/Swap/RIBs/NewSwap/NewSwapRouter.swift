//
//  NewSwapRouter.swift
//  TransactionUIKit
//
//  Created by Paulo on 12/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RIBs

protocol NewSwapInteractable: Interactable {
    var router: NewSwapRouting? { get set }
    var listener: NewSwapListener? { get set }
}

protocol NewSwapViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class NewSwapRouter: ViewableRouter<NewSwapInteractable, NewSwapViewControllable>, NewSwapRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: NewSwapInteractable, viewController: NewSwapViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
