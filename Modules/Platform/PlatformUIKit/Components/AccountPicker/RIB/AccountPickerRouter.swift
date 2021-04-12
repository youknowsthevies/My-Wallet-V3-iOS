//
//  AccountPickerRouter.swift
//  PlatformUIKit
//
//  Created by Paulo on 21/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RIBs

protocol AccountPickerInteractable: Interactable {
    var router: AccountPickerRouting? { get set }
}

final class AccountPickerRouter: ViewableRouter<AccountPickerInteractable, AccountPickerViewControllable>, AccountPickerRouting {

    override init(interactor: AccountPickerInteractable, viewController: AccountPickerViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
