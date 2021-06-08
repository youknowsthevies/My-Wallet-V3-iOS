// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import EthereumKit
import PlatformKit
import RxRelay
import RxSwift

final class ERC20AssetBalanceFetcher: CryptoAccountBalanceFetching {

    // MARK: - Exposed Properties

    var accountType: SingleAccountType {
        .nonCustodial
    }

    var balance: Single<CryptoValue> {
        balanceService
            .accountBalance(cryptoCurrency: cryptoCurrency)
    }

    var pendingBalanceMoneyObservable: Observable<MoneyValue> {
        pendingBalanceMoney
            .asObservable()
    }

    var pendingBalanceMoney: Single<MoneyValue> {
        Single.just(MoneyValue.zero(currency: .ethereum))
    }

    var balanceMoney: Single<MoneyValue> {
        balance.moneyValue
    }

    var balanceObservable: Observable<CryptoValue> {
        _ = setup
        return balanceRelay.asObservable()
    }

    var balanceMoneyObservable: Observable<MoneyValue> {
        balanceObservable.moneyValue
    }

    let balanceFetchTriggerRelay = PublishRelay<Void>()

    // MARK: - Private Properties

    private lazy var setup: Void = {
        Observable
            .combineLatest(
                reactiveWallet.waitUntilInitialized,
                balanceFetchTriggerRelay
            )
            .throttle(
                .milliseconds(100),
                scheduler: ConcurrentDispatchQueueScheduler(qos: .background)
            )
            .flatMapLatest(weak: self) { (self, _) in
                self.balance
                    .asObservable()
                    .materialize()
                    .filter { !$0.isStopEvent }
                    .dematerialize()
            }
            .bindAndCatch(to: balanceRelay)
            .disposed(by: disposeBag)
    }()

    private let balanceRelay = PublishRelay<CryptoValue>()
    private let disposeBag = DisposeBag()
    private let balanceService: ERC20BalanceServiceAPI
    private let cryptoCurrency: CryptoCurrency
    private unowned let reactiveWallet: ReactiveWalletAPI

    // MARK: - Setup

    init(
        reactiveWallet: ReactiveWalletAPI = resolve(),
        balanceService: ERC20BalanceServiceAPI = resolve(),
        cryptoCurrency: CryptoCurrency
    ) {
        self.reactiveWallet = reactiveWallet
        self.balanceService = balanceService
        self.cryptoCurrency = cryptoCurrency
    }
}
