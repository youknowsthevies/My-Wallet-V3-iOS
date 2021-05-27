// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinCashKit
import BitcoinChainKit
import DIKit
import PlatformKit
import RxCocoa
import RxSwift

final class BitcoinCashAssetBalanceFetcher: CryptoAccountBalanceFetching {

    // MARK: - Exposed Properties

    var accountType: SingleAccountType {
        .nonCustodial
    }

    var balance: Single<CryptoValue> {
        activeAccountAddresses
            .flatMap(weak: self) { (self, activeAccounts) -> Single<CryptoValue> in
                self.balanceService.balances(for: activeAccounts)
            }
    }

    var balanceObservable: Observable<CryptoValue> {
        balanceRelay.asObservable()
    }

    var balanceMoney: Single<MoneyValue> {
        balance.moneyValue
    }

    var balanceMoneyObservable: Observable<MoneyValue> {
        balanceObservable.moneyValue
    }

    var pendingBalanceMoney: Single<MoneyValue> {
        .just(.zero(currency: .bitcoinCash))
    }

    var pendingBalanceMoneyObservable: Observable<MoneyValue> {
        pendingBalanceMoney.asObservable()
    }

    let balanceFetchTriggerRelay = PublishRelay<Void>()

    // MARK: - Private Properties

    private let balanceRelay = PublishRelay<CryptoValue>()
    private let disposeBag = DisposeBag()

    // MARK: - Injected

    private let balanceService: BalanceServiceAPI
    private let bridge: BitcoinCashWalletBridgeAPI

    private var activeAccountAddresses: Single<[XPub]> {
        bridge.wallets
            .map { accounts in
                accounts.map(\.publicKey)
            }
    }

    // MARK: - Setup

    convenience init() {
        self.init(bridge: resolve(), balanceService: resolve(tag: BitcoinChainKit.BitcoinChainCoin.bitcoinCash))
    }

    init(bridge: BitcoinCashWalletBridgeAPI, balanceService: BalanceServiceAPI) {
        self.bridge = bridge
        self.balanceService = balanceService
        balanceFetchTriggerRelay
            .throttle(
                .milliseconds(100),
                scheduler: ConcurrentDispatchQueueScheduler(qos: .background)
            )
            .observeOn(MainScheduler.asyncInstance)
            .flatMapLatest(weak: self) { (self, _) in
                self.balance.asObservable()
            }
            .bindAndCatch(to: balanceRelay)
            .disposed(by: disposeBag)
    }
}
