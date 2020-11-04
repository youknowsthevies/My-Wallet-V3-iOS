//
//  WithdrawlConfirmationInteractor.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 02/11/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RIBs
import RxCocoa

enum WithdrawalConfirmationRoute {
    case closeFlow
}

protocol WithdrawalConfirmationRouting: AnyObject {
    func confirmationRequested(to route: WithdrawalConfirmationRoute)
}

final class WithdrawalConfirmationInteractor: Interactor {

    var isLoading: Bool {
        guard case .loading = type else {
            return false
        }
        return true
    }
    
    var isSuccess: Bool {
        guard case .success = type else {
            return false
        }
        return true
    }

    var currencyType: CurrencyType {
        switch type {
        case .success(let value):
            return value.currency
        case .failure(let currencyType):
            return currencyType
        case .loading(let value):
            return value.currency
        }
    }

    var amount: FiatValue? {
        switch type {
        case .success(let value),
             .loading(let value):
            return value
        case .failure:
            return nil
        }
    }

    private let type: ConfirmationPageType

    private weak var listener: CheckoutPageRouting?

    init(type: ConfirmationPageType) {
        self.type = type
    }
}
