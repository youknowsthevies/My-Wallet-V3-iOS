//
//  AddNewBankAccountBuilder.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 07/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RIBs

protocol AddNewBankAccountInteractable: Interactable {
    var router: AddNewBankAccountRouting? { get set }
    var listener: AddNewBankAccountListener? { get set }
}

protocol AddNewBankAccountViewControllable: ViewControllable { }

final class AddNewBankAccountRouter: ViewableRouter<AddNewBankAccountInteractable, AddNewBankAccountViewControllable>,
                                     AddNewBankAccountRouting {

    override init(interactor: AddNewBankAccountInteractable,
                  viewController: AddNewBankAccountViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    override func didLoad() {
        super.didLoad()
    }

    func showTermsScreen(link: TitledLink) {
        let webRouter = WebViewRouter(topMostViewControllerProvider: viewController.uiviewController)
        webRouter.launchRelay.accept(link)
    }
}
