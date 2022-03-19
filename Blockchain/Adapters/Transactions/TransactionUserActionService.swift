// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureProductsDomain
import FeatureTransactionUI
import PlatformKit

final class TransactionUserActionService: UserActionServiceAPI {

    let userService: UserAdapterAPI

    init(userService: UserAdapterAPI) {
        self.userService = userService
    }

    func canPresentTransactionFlow(
        toPerform action: TransactionFlowAction
    ) -> AnyPublisher<UserActionServiceResult, Never> {
        userService.userState
            .first()
            .map { userStateResult -> UserActionServiceResult in
                let productId = action.productId
                if case .success(let userState) = userStateResult {
                    guard userState.canStartTransactionFlow(for: productId) else {
                        let upgradeTier: KYC.Tier?
                        if let requiredTier = userState.requiredTierToUse(productId) {
                            upgradeTier = KYC.Tier(rawValue: requiredTier)
                        } else {
                            upgradeTier = nil
                        }
                        return .cannotPerform(upgradeTier: upgradeTier)
                    }
                }
                return .canPerform
            }
            .eraseToAnyPublisher()
    }
}

extension TransactionFlowAction {

    var productId: ProductIdentifier? {
        let productId: ProductIdentifier?
        switch self {
        case .buy:
            productId = .buy
        case .sell:
            productId = nil
        case .swap:
            productId = .swap
        case .send:
            productId = nil
        case .receive:
            productId = nil
        case .deposit:
            productId = nil
        case .withdraw:
            productId = nil
        case .interestTransfer:
            productId = nil
        case .interestWithdraw:
            productId = nil
        case .sign:
            productId = nil
        case .order:
            productId = nil
        }
        return productId
    }
}

extension UserState {

    fileprivate func canStartTransactionFlow(for productId: ProductIdentifier?) -> Bool {
        guard let product = product(id: productId) else {
            // Let users use products we don't have information for
            return true
        }
        guard product.enabled, case .trading(let tradingProduct) = product else {
            return false
        }
        return tradingProduct.canPlaceOrder
    }
}
