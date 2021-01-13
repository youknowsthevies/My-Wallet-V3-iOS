//
//  LinkBankFailureScreenRouter.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 23/12/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RIBs

protocol LinkBankFailureScreenInteractable: Interactable {
    var router: LinkBankFailureScreenRouting? { get set }
    var listener: LinkBankFailureScreenListener? { get set }
}

protocol LinkBankFailureScreenViewControllable: ViewControllable {
    
}

final class LinkBankFailureScreenRouter: ViewableRouter<LinkBankFailureScreenInteractable, LinkBankFailureScreenViewControllable>,
                                         LinkBankFailureScreenRouting {

    override init(interactor: LinkBankFailureScreenInteractable, viewController: LinkBankFailureScreenViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
