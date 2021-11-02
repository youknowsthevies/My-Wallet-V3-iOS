// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Localization
import RxSwift
import ToolKit

public final class CryptoInterestAccount: CryptoAccount, InterestAccount {

    private enum Error: LocalizedError {
        case loadingFailed(asset: String, label: String, action: AssetAction, error: String)

        var errorDescription: String? {
            switch self {
            case .loadingFailed(let asset, let label, let action, let error):
                return "Failed to load: 'CryptoInterestAccount' asset '\(asset)' label '\(label)' action '\(action)' error '\(error)' ."
            }
        }
    }

    public private(set) lazy var identifier: AnyHashable = "CryptoInterestAccount." + asset.code
    public let label: String
    public let asset: CryptoCurrency
    public let isDefault: Bool = false

    public var receiveAddress: Single<ReceiveAddress> {
        receiveAddressRepository
            .fetchInterestAccountReceiveAddressForCurrencyCode(asset.code)
            .eraseToAnyPublisher()
            .asSingle()
            .flatMap { [cryptoReceiveAddressFactory, onTxCompleted] addressString in
                cryptoReceiveAddressFactory
                    .makeExternalAssetAddress(
                        address: addressString,
                        label: "",
                        onTxCompleted: onTxCompleted
                    )
                    .single
            }
            .map { $0 as ReceiveAddress }
    }

    public var requireSecondPassword: Single<Bool> {
        .just(false)
    }

    public var isFunded: Single<Bool> {
        balances.map { $0 != .absent }
    }

    public var pendingBalance: Single<MoneyValue> {
        balances
            .map(\.balance?.pending)
            .onNilJustReturn(.zero(currency: currencyType))
    }

    public var balance: Single<MoneyValue> {
        balances
            .map(\.balance?.available)
            .onNilJustReturn(.zero(currency: currencyType))
    }

    public var disabledReason: AnyPublisher<InterestAccountIneligibilityReason, Swift.Error> {
        interestEligibilityRepository
            .fetchInterestAccountEligibilityForCurrencyCode(currencyType.code)
            .map(\.ineligibilityReason)
            .eraseError()
    }

    public var actionableBalance: Single<MoneyValue> {
        balance
    }

    public var actions: Single<AvailableActions> {
        canPerformInterestWithdraw()
            .map { canPerformWithdraw in
                canPerformWithdraw ? [.interestWithdraw] : []
            }
    }

    public var activity: Single<[ActivityItemEvent]> {
        .just([])
    }

    let cryptoReceiveAddressFactory: ExternalAssetAddressFactory
    private let errorRecorder: ErrorRecording
    private let priceService: PriceServiceAPI
    private let interestEligibilityRepository: InterestAccountEligibilityRepositoryAPI
    private let receiveAddressRepository: InterestAccountReceiveAddressRepositoryAPI
    private let balanceService: InterestAccountOverviewAPI
    private var balances: Single<CustodialAccountBalanceState> {
        balanceService.balance(for: asset)
    }

    public init(
        asset: CryptoCurrency,
        receiveAddressRepository: InterestAccountReceiveAddressRepositoryAPI = resolve(),
        priceService: PriceServiceAPI = resolve(),
        errorRecorder: ErrorRecording = resolve(),
        balanceService: InterestAccountOverviewAPI = resolve(),
        exchangeProviding: ExchangeProviding = resolve(),
        interestEligibilityRepository: InterestAccountEligibilityRepositoryAPI = resolve(),
        cryptoReceiveAddressFactory: ExternalAssetAddressFactory
    ) {
        label = asset.defaultInterestWalletName
        self.cryptoReceiveAddressFactory = cryptoReceiveAddressFactory
        self.receiveAddressRepository = receiveAddressRepository
        self.asset = asset
        self.errorRecorder = errorRecorder
        self.balanceService = balanceService
        self.priceService = priceService
        self.interestEligibilityRepository = interestEligibilityRepository
    }

    public func can(perform action: AssetAction) -> Single<Bool> {
        switch action {
        case .interestWithdraw:
            return canPerformInterestWithdraw()
        case .send,
             .swap,
             .deposit,
             .buy,
             .withdraw,
             .sell,
             .receive,
             .viewActivity,
             .interestTransfer:
            return .just(false)
        }
    }

    public func balancePair(
        fiatCurrency: FiatCurrency,
        at time: PriceTime
    ) -> AnyPublisher<MoneyValuePair, Swift.Error> {
        priceService
            .price(of: asset, in: fiatCurrency, at: time)
            .eraseError()
            .zip(balancePublisher)
            .tryMap { fiatPrice, balance in
                MoneyValuePair(base: balance, exchangeRate: fiatPrice.moneyValue)
            }
            .eraseToAnyPublisher()
    }

    private func canPerformInterestWithdraw() -> Single<Bool> {
        balance
            .map(\.isPositive)
            .flatMap(weak: self) { (self, isPositive) -> Single<Bool> in
                guard isPositive else {
                    return .just(false)
                }
                return self
                    .disabledReason
                    .map(\.isEligible)
                    .asSingle()
            }
            .catchError { [label, asset] error in
                throw Error.loadingFailed(
                    asset: asset.code,
                    label: label,
                    action: .interestWithdraw,
                    error: String(describing: error)
                )
            }
            .recordErrors(on: errorRecorder)
            .catchErrorJustReturn(false)
    }
}
