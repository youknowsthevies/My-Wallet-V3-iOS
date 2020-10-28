//
//  WithdrawAmountPageBuilder.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 01/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformUIKit
import RIBs

protocol WithdrawAmountPageInteractable: Interactable {
    var router: WithdrawAmountPageRouting? { get set }
    var listener: WithdrawAmountPageListener? { get set }
}

protocol WithdrawAmountViewControllable: ViewControllable { }

final class WithdrawAmountPageRouter: ViewableRouter<WithdrawAmountPageInteractable, WithdrawAmountViewControllable>,
                                      WithdrawAmountPageRouting {

    private let alertViewPresenter: AlertViewPresenterAPI

    init(interactor: WithdrawAmountPageInteractable,
         viewController: WithdrawAmountViewControllable,
         alertViewPresenter: AlertViewPresenterAPI = resolve()) {
        self.alertViewPresenter = alertViewPresenter
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    func showError() {
        alertViewPresenter.error(in: viewController.uiviewController, action: nil)
    }
}
