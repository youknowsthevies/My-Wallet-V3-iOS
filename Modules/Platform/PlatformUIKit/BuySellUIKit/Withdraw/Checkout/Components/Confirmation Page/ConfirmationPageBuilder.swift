// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RIBs

enum ConfirmationPageType: Equatable {
    case loading(FiatValue)
    case success(FiatValue)
    case failure(CurrencyType, Error)

    static func == (lhs: ConfirmationPageType, rhs: ConfirmationPageType) -> Bool {
        switch (lhs, rhs) {
        case let (.loading(lhsFiatValue), .loading(rhsFiatValue)):
            return lhsFiatValue == rhsFiatValue
        case let (.success(lhsFiatValue), .success(rhsFiatValue)):
            return lhsFiatValue == rhsFiatValue
        case let (.failure(lhsCurrencyType, _), .failure(rhsCurrencyType, _)):
            return lhsCurrencyType == rhsCurrencyType
        default:
            return false
        }
    }
}

final class ConfirmationPageBuilder {
    func build(for type: ConfirmationPageType, routing: WithdrawalConfirmationRouting) -> PendingStateViewController {
        let interactor = WithdrawalConfirmationInteractor(type: type)
        let presenter = WithdrawalConfirmationPresenter(interactor: interactor, routing: routing)
        return PendingStateViewController(presenter: presenter)
    }
}
