//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import PlatformKit

/// A protocol to fetch and monitor changes in `UserState`
protocol UserAdapterAPI {

    /// A publisher that streams `UserState` values on subscription and on change.
    var userState: AnyPublisher<Result<UserState, UserStateError>, Never> { get }
}

// MARK: - UserAdapterAPI concrete implementation

final class UserAdapter: UserAdapterAPI {

    let userState: AnyPublisher<Result<UserState, UserStateError>, Never>

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
            .map { kycStatusResult, paymentMethodsResult, hasEverPurchasedCryptoResult, balanceDataResult in
                kycStatusResult.zip(
                    paymentMethodsResult,
                    hasEverPurchasedCryptoResult,
                    balanceDataResult
                )
            }
            .map { zippedResult -> Result<UserState, UserStateError> in
                zippedResult.map { kycStatus, paymentMethods, hasEverPurchasedCrypto, balanceData in
                    UserState(
                        kycStatus: kycStatus,
                        linkedPaymentMethods: paymentMethods,
                        hasEverPurchasedCrypto: hasEverPurchasedCrypto,
                        balanceData: balanceData
                    )
                }
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
        } else if userTiers.isTier2Pending {
            self = .inReview
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

    fileprivate var kycStatusStream: AnyPublisher<Result<UserState.KYCStatus, UserStateError>, Never> {
        let checkSDDVerification = checkSimplifiedDueDiligenceVerification(for:pollUntilComplete:)
        return tiersStream
            .mapError(UserStateError.missingKYCInfo)
            .flatMap { tiers -> AnyPublisher<(KYC.UserTiers, Bool), UserStateError> in
                Just(tiers)
                    .setFailureType(to: UserStateError.self)
                    .zip(
                        checkSDDVerification(tiers.latestApprovedTier, false)
                            .mapError(UserStateError.missingKYCInfo)
                    )
                    .eraseToAnyPublisher()
            }
            .map(UserState.KYCStatus.init)
            .mapToResult()
    }
}

extension PaymentMethodTypesServiceAPI {

    fileprivate var paymentMethodsStream: AnyPublisher<Result<[UserState.PaymentMethod], UserStateError>, Never> {
        paymentMethodTypesValidForBuyPublisher
            .mapError(UserStateError.missingPaymentInfo)
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
            .mapToResult()
    }
}

extension OrdersServiceAPI {

    fileprivate var hasPurchasedAnyCryptoStream: AnyPublisher<Result<Bool, UserStateError>, Never> {
        hasUserMadeAnyPurchases
            .mapError(UserStateError.missingPurchaseHistory)
            .mapToResult()
    }
}

extension CoincoreAPI {

    fileprivate var balanceStream: AnyPublisher<Result<UserState.BalanceData, UserStateError>, Never> {
        var randomNumberGenerator = SystemRandomNumberGenerator()
        return hasFundedAccounts(for: .fiat)
            .zip(
                hasFundedAccounts(for: .crypto)
            )
            // retry a few times on errors
            .retry(5, delay: .exponential(using: &randomNumberGenerator), scheduler: DispatchQueue.main)
            .map { hasFiatBalance, hasCryptoBalance -> UserState.BalanceData in
                UserState.BalanceData(
                    hasAnyBalance: hasFiatBalance || hasCryptoBalance,
                    hasAnyFiatBalance: hasFiatBalance,
                    hasAnyCryptoBalance: hasCryptoBalance
                )
            }
            .mapError(UserStateError.missingBalance)
            .mapToResult()
    }
}
