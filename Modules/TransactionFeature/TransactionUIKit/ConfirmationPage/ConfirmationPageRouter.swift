//
//  ConfirmationPageRouter.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 29/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RIBs

protocol ConfirmationPageRouting: AnyObject {

}

final class ConfirmationPageRouter: ViewableRouter<ConfirmationPageInteractable, ViewControllable>, ConfirmationPageRouting {

    override init(interactor: ConfirmationPageInteractable, viewController: ViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
