// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureProductsDomain
import FeatureTransactionDomain
import FeatureTransactionUI
import PlatformKit

final class TransactionUserActionService: UserActionServiceAPI {

    private let userService: UserAdapterAPI
    private(set) var latestUserState: UserState?
    private var cancellables = Set<AnyCancellable>()

    init(userService: UserAdapterAPI) {
        self.userService = userService
        registerForUserStateUpdates()
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

    private func registerForUserStateUpdates() {
        userService.userState
            .sink { [weak self] userStateResult in
                guard case .success(let userState) = userStateResult else {
                    return
                }
                self?.latestUserState = userState
            }
            .store(in: &cancellables)
    }
}

extension TransactionUserActionService: TransactionRestrictionsProviderAPI {

    func canPerform(_ action: AssetAction, using target: TransactionTarget) -> Bool {
        guard target.accountType == .custodial else {
            return true
        }
        guard let rawProduct = latestUserState?.product(id: .custodialWallet) else {
            return true
        }
        guard case .custodialWallet(let custodialWalletProduct) = rawProduct else {
            return true
        }
        return action.canBePerformed(custodialWalletProduct)
    }

    func maximumNumbersOfTransactions(for action: AssetAction) -> Int? {
        // Ignore Tier 0 users
        guard latestUserState?.kycStatus != .unverified else {
            return nil
        }
        guard let rawProduct = latestUserState?.product(id: action.productId) else {
            return nil
        }
        guard case .trading(let tradingProduct) = rawProduct else {
            return nil
        }
        return tradingProduct.maxOrdersCap ?? tradingProduct.maxOrdersLeft
    }
}

extension AssetAction {

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
        case .viewActivity:
            productId = nil
        }
        return productId
    }

    // swiftlint:disable cyclomatic_complexity
    func canBePerformed(_ product: CustodialWalletProduct) -> Bool {
        let canPerformAction: Bool
        switch self {
        case .deposit:
            canPerformAction = product.canDepositFiat
        case .withdraw:
            canPerformAction = product.canWithdrawFiat
        case .receive:
            canPerformAction = product.canDepositCrypto
        case .send:
            canPerformAction = product.canWithdrawCrypto
        case .buy:
            canPerformAction = true
        case .interestTransfer:
            canPerformAction = true
        case .interestWithdraw:
            canPerformAction = true
        case .sell:
            canPerformAction = true
        case .sign:
            canPerformAction = true
        case .swap:
            canPerformAction = true
        case .viewActivity:
            canPerformAction = true
        }
        return canPerformAction
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
        // For first-time users, let them go through the buy flow.
        if productId == .buy, kycStatus == .unverified {
            return true
        }

        // For everyone else, check the actual product.
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
