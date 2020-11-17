//
//  CheckoutPageRouter.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 29/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RIBs

enum CheckoutRoute {
    case loading(amount: FiatValue)
    case confirmation(amount: FiatValue)
    case failure(CurrencyType)
}

protocol CheckoutPageInteractable: Interactable, WithdrawalConfirmationRouting {
    var router: CheckoutPageRouting? { get set }
    var listener: CheckoutPageListener? { get set }
}

final class CheckoutPageRouter: ViewableRouter<CheckoutPageInteractable, ContentPageControllable>,
                                CheckoutPageRouting {

    private let confirmationPageBuilder: ConfirmationPageBuilder

    init(interactor: CheckoutPageInteractable,
         contentControllable: ContentPageControllable,
         confirmationBuilder: ConfirmationPageBuilder) {
        self.confirmationPageBuilder = confirmationBuilder
        super.init(interactor: interactor, viewController: contentControllable)
        interactor.router = self
    }

    func route(to type: CheckoutRoute) {
        let controllable = self.controllable(for: type)
        viewController.transition(to: .render(controllable))
    }

    private func controllable(for type: CheckoutRoute) -> ViewControllable {
        switch type {
        case .loading(let amount):
            return confirmationPageBuilder.build(for: .loading(amount), routing: interactor)
        case .confirmation(let data):
            return confirmationPageBuilder.build(for: .success(data), routing: interactor)
        case .failure(let currencyType):
            return confirmationPageBuilder.build(for: .failure(currencyType), routing: interactor)
        }
    }
}
