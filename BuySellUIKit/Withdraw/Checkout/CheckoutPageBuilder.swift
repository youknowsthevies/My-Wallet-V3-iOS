//
//  CheckoutPageBuilder.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 29/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import PlatformKit
import PlatformUIKit
import RIBs
import UIKit

protocol CheckoutPageBuildable {
    func build(listener: CheckoutPageListener, checkoutData: WithdrawalCheckoutData) -> CheckoutPageRouter
}

final class CheckoutPageBuilder: CheckoutPageBuildable {
    func build(listener: CheckoutPageListener, checkoutData: WithdrawalCheckoutData) -> CheckoutPageRouter {
        let detailsPresenter = CheckoutPageDetailsPresenter(fiatCurrency: checkoutData.currency)
        let checkountViewController = DetailsScreenViewController(presenter: detailsPresenter)
        let interactor = CheckoutPageInteractor(presenter: detailsPresenter,
                                                checkoutData: checkoutData)
        interactor.listener = listener
        let confirmationPageBuilder = ConfirmationPageBuilder()
        let contentPage = ContentPage(state: .initial)
        return CheckoutPageRouter(interactor: interactor,
                                  contentControllable: contentPage,
                                  checkoutControllable: checkountViewController,
                                  confirmationBuilder: confirmationPageBuilder)
    }
}

/// Conforming to CheckoutPageViewControllable for RIB compatibility
extension DetailsScreenViewController: ViewControllable { }
