//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import PlatformKit

/// A protocol to fetch and monitor changes in `UserState`
protocol UserAdapterAPI {

    /// A publisher that streams `UserState` values on subscription and on change.
    var userState: AnyPublisher<UserState, Never> { get }
}

// MARK: - UserAdapterAPI concrete implementation

final class UserAdapter: UserAdapterAPI {

    let userState: AnyPublisher<UserState, Never>

    init(
        coincore: CoincoreAPI,
        kycTiersService: KYCTiersServiceAPI,
        paymentMethodsService: PaymentMethodTypesServiceAPI,
        ordersService: OrdersServiceAPI
    ) {
        userState = kycTiersService.kycStatusStream
            .combineLatest(
                paymentMethodsService.paymentMethodsStream,
                ordersService.hasPurchasedAnyCryptoStream,
                coincore.balanceStream
            )
            .map { kycStatus, paymentMethods, hasEverPurchasedCrypto, balanceData -> UserState in
                UserState(
                    kycStatus: kycStatus,
                    linkedPaymentMethods: paymentMethods,
                    hasEverPurchasedCrypto: hasEverPurchasedCrypto,
                    balanceData: balanceData
                )
            }
            .removeDuplicates()
            .shareReplay()
    }
}

// MARK: - Helpers

extension UserState.KYCStatus {

    fileprivate init(userTiers: KYC.UserTiers, isSDDVerified: Bool) {
        if userTiers.isTier2Approved {
            self = .gold
        } else if userTiers.isTier1Approved, isSDDVerified {
            self = .silverPlus
        } else if userTiers.isTier1Approved {
            self = .silver
        } else {
            self = .unverified
        }
    }
}

extension KYCTiersServiceAPI {

    fileprivate var kycStatusStream: AnyPublisher<UserState.KYCStatus, Never> {
        tiers
            .flatMap { [checkSimplifiedDueDiligenceVerification] tiers -> AnyPublisher<(KYC.UserTiers, Bool), Never> in
                Just(tiers)
                    .zip(
                        checkSimplifiedDueDiligenceVerification(tiers.latestApprovedTier, false)
                    )
                    .eraseToAnyPublisher()
            }
            .map(UserState.KYCStatus.init)
            .catch(UserState.KYCStatus.unverified)
            .eraseToAnyPublisher()
    }
}

extension PaymentMethodTypesServiceAPI {

    fileprivate var paymentMethodsStream: AnyPublisher<[UserState.PaymentMethod], Never> {
        paymentMethodTypesValidForBuyPublisher
            .map { paymentMethods -> [UserState.PaymentMethod] in
                paymentMethods.compactMap { paymentMethodType -> UserState.PaymentMethod? in
                    guard !paymentMethodType.isSuggested else {
                        return nil
                    }
                    return UserState.PaymentMethod(
                        id: paymentMethodType.id,
                        label: paymentMethodType.label
                    )
                }
            }
            .catch([])
            .eraseToAnyPublisher()
    }
}

extension OrdersServiceAPI {

    fileprivate var hasPurchasedAnyCryptoStream: AnyPublisher<Bool, Never> {
        hasUserMadeAnyPurchases
            .catch(false)
            .eraseToAnyPublisher()
    }
}

extension CoincoreAPI {

    fileprivate var balanceStream: AnyPublisher<UserState.BalanceData?, Never> {
        hasFundedAccounts(for: .fiat)
            .combineLatest(
                hasFundedAccounts(for: .crypto)
            )
            .map { hasFiatBalance, hasCryptoBalance -> UserState.BalanceData in
                UserState.BalanceData(
                    hasAnyBalance: hasFiatBalance || hasCryptoBalance,
                    hasAnyFiatBalance: hasFiatBalance,
                    hasAnyCryptoBalance: hasCryptoBalance
                )
            }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
}
