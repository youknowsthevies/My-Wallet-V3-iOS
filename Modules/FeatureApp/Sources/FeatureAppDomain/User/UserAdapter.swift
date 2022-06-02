//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureProductsDomain
import Foundation
import PlatformKit
import ToolKit

/// A protocol to fetch and monitor changes in `UserState`
public protocol UserAdapterAPI {

    /// A publisher that streams `UserState` values on subscription and on change.
    var userState: AnyPublisher<Result<UserState, UserStateError>, Never> { get }
}

// MARK: - UserAdapterAPI concrete implementation

public protocol BalanceDataFetcherAPI {

    func fetchBalanceData() -> AnyPublisher<UserState.BalanceData, UserStateError>
}

private typealias RawUserData = (
    kycStatus: UserState.KYCStatus,
    balanceData: UserState.BalanceData,
    paymentMethods: [UserState.PaymentMethod],
    hasEverPurchasedCrypto: Bool,
    products: [ProductValue]
)

public final class UserAdapter: UserAdapterAPI {

    public let userState: AnyPublisher<Result<UserState, UserStateError>, Never>

    private let balanceDataStreamer: BalanceDataStreamer

    public init(
        balanceDataFetcher: BalanceDataFetcherAPI,
        kycTiersService: KYCTiersServiceAPI,
        paymentMethodsService: PaymentMethodTypesServiceAPI,
        productsService: ProductsServiceAPI,
        ordersService: OrdersServiceAPI
    ) {
        balanceDataStreamer = BalanceDataStreamer(balanceDataFetcher: balanceDataFetcher)
        let streams = kycTiersService.kycStatusStream
            .combineLatest(
                balanceDataStreamer.balanceDataStream,
                paymentMethodsService.paymentMethodsStream,
                ordersService.hasPurchasedAnyCryptoStream
            )
            .combineLatest(productsService.productsStream)

        userState = streams
            .map { results -> Result<RawUserData, UserStateError> in
                let (r1, r2) = results
                let (kycStatusResult, balanceDataResult, paymentMethodsResult, hasEverPurchasedCryptoResult) = r1
                let products = r2
                return kycStatusResult.zip(
                    balanceDataResult,
                    paymentMethodsResult,
                    hasEverPurchasedCryptoResult,
                    products
                )
                .map { $0 } // this makes the compiler happy by making a generic tuple be casted to RawUserData
            }
            .map { zippedResult -> Result<UserState, UserStateError> in
                zippedResult.map { kycStatus, balanceData, paymentMethods, hasEverPurchasedCrypto, products in
                    UserState(
                        kycStatus: kycStatus,
                        balanceData: balanceData,
                        linkedPaymentMethods: paymentMethods,
                        hasEverPurchasedCrypto: hasEverPurchasedCrypto,
                        products: products
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

extension ProductsServiceAPI {

    fileprivate var productsStream: AnyPublisher<Result<[ProductValue], UserStateError>, Never> {
        streamProducts().map { result in
            result.mapError(UserStateError.missingProductsInfo)
        }
        .eraseToAnyPublisher()
    }
}

public class BalanceDataFetcher: BalanceDataFetcherAPI {

    private let coincore: CoincoreAPI

    public init(coincore: CoincoreAPI) {
        self.coincore = coincore
    }

    public func fetchBalanceData() -> AnyPublisher<UserState.BalanceData, UserStateError> {
        var randomNumberGenerator = SystemRandomNumberGenerator()
        return coincore.hasPositiveDisplayableBalanceAccounts(for: .fiat)
            .zip(
                coincore.hasPositiveDisplayableBalanceAccounts(for: .crypto)
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
            .eraseToAnyPublisher()
    }
}

/// This class helps caching the user's balance data and, most importantly, invalidate and refetch it when it certain events are fired.
private class BalanceDataStreamer {

    private enum CacheKey: Hashable {
        case balanceData
    }

    private let balanceCache: CachedValueNew<CacheKey, UserState.BalanceData, UserStateError>

    init(balanceDataFetcher: BalanceDataFetcherAPI) {
        let cache: AnyCache<CacheKey, UserState.BalanceData> = InMemoryCache(
            configuration: .onUserStateChanged(),
            refreshControl: PerpetualCacheRefreshControl()
        ).eraseToAnyCache()
        balanceCache = CachedValueNew(
            cache: cache,
            fetch: { _ in
                balanceDataFetcher.fetchBalanceData()
            }
        )
    }

    var balanceDataStream: AnyPublisher<Result<UserState.BalanceData, UserStateError>, Never> {
        balanceCache.stream(key: .balanceData)
    }
}
