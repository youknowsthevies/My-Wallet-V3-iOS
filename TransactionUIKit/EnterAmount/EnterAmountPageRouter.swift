//
//  EnterAmountPageRouter.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 01/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformUIKit
import RIBs

protocol EnterAmountPageInteractable: Interactable {
    var router: EnterAmountPageRouting? { get set }
    var listener: EnterAmountPageListener? { get set }
}

protocol EnterAmountViewControllable: ViewControllable { }

final class EnterAmountPageRouter: ViewableRouter<EnterAmountPageInteractable, EnterAmountViewControllable>,
                                   EnterAmountPageRouting {

    private let alertViewPresenter: AlertViewPresenterAPI

    init(interactor: EnterAmountPageInteractable,
         viewController: EnterAmountViewControllable,
         alertViewPresenter: AlertViewPresenterAPI = resolve()) {
        self.alertViewPresenter = alertViewPresenter
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    func showError() {
        alertViewPresenter.error(in: viewController.uiviewController, action: nil)
    }
}
