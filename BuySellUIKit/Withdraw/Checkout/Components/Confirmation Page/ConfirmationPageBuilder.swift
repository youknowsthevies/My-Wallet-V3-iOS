//
//  ConfirmationPageBuilder.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 02/11/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RIBs

enum ConfirmationPageType: Equatable {
    case loading(FiatValue)
    case success(FiatValue)
    case failure(CurrencyType)
}

final class ConfirmationPageBuilder {
    func build(for type: ConfirmationPageType, routing: WithdrawalConfirmationRouting) -> PendingStateViewController {
        let interactor = WithdrawalConfirmationInteractor(type: type)
        let presenter = WithdrawalConfirmationPresenter(interactor: interactor, routing: routing)
        return PendingStateViewController(presenter: presenter)
    }
}

extension PendingStateViewController: ViewControllable { }
