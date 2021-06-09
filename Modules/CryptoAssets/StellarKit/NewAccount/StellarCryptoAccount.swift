// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Localization
import PlatformKit
import RxSwift
import ToolKit

class StellarCryptoAccount: CryptoNonCustodialAccount {
    let id: String
    let label: String
    let asset: CryptoCurrency
    let isDefault: Bool = true

    func createTransactionEngine() -> Any {
        StellarOnChainTransactionEngineFactory()
    }

    var balance: Single<MoneyValue> {
        accountCache.valueSingle
            .map(\.balance)
            .moneyValue
    }

    var actionableBalance: Single<MoneyValue> {
        accountCache.valueSingle
            .map(\.actionableBalance)
            .moneyValue
    }

    var pendingBalance: Single<MoneyValue> {
        .just(.zero(currency: asset))
    }

    var actions: Single<AvailableActions> {
        isFunded
            .map { isFunded -> AvailableActions in
                var base: AvailableActions = [.viewActivity, .receive, .send]
                if isFunded {
                    base.insert(.swap)
                }
                return base
            }
    }

    var receiveAddress: Single<ReceiveAddress> {
        .just(StellarReceiveAddress(address: id, label: label))
    }

    private let hdAccountIndex: Int
    private let bridge: StellarWalletBridgeAPI
    private let accountDetailsService: StellarAccountDetailsServiceAPI
    private let exchangeService: PairExchangeServiceAPI
    private let accountCache: CachedValue<StellarAccountDetails>

    init(id: String,
         label: String? = nil,
         hdAccountIndex: Int,
         bridge: StellarWalletBridgeAPI = resolve(),
         accountDetailsService: StellarAccountDetailsServiceAPI = resolve(),
         exchangeProviding: ExchangeProviding = resolve()) {
        let asset = CryptoCurrency.stellar
        self.asset = asset
        self.bridge = bridge
        self.id = id
        self.hdAccountIndex = hdAccountIndex
        self.label = label ?? asset.defaultWalletName
        self.accountDetailsService = accountDetailsService
        self.exchangeService = exchangeProviding[asset]
        accountCache = .init(configuration: .init(refreshType: .periodic(seconds: 20)))
        accountCache.setFetch(weak: self) { (self) -> Single<StellarAccountDetails> in
            self.accountDetailsService.accountDetails(for: self.id)
        }
    }

    func can(perform action: AssetAction) -> Single<Bool> {
        switch action {
        case .receive,
             .send,
             .viewActivity:
            return .just(true)
        case .deposit,
             .sell,
             .withdraw:
            return .just(false)
        case .swap:
            return isFunded
        }
    }

    func balancePair(fiatCurrency: FiatCurrency) -> Observable<MoneyValuePair> {
        exchangeService.fiatPrice
            .flatMapLatest(weak: self) { (self, exchangeRate) in
                self.balance
                    .map { balance -> MoneyValuePair in
                        try MoneyValuePair(base: balance, exchangeRate: exchangeRate.moneyValue)
                    }
                    .asObservable()
            }
    }

    func updateLabel(_ newLabel: String) -> Completable {
        bridge.update(accountIndex: hdAccountIndex, label: newLabel)
    }
}
