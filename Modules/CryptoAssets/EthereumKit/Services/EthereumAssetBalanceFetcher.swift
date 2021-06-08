// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxRelay
import RxSwift
import ToolKit

final class EthereumAssetBalanceFetcher: CryptoAccountBalanceFetching {

    // MARK: - Exposed Properties

    let accountType: SingleAccountType = .nonCustodial

    var balance: Single<CryptoValue> {
        accountDetailsService
            .accountDetails()
            .map(\.balance)
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
    private let accountDetailsService: EthereumAccountDetailsServiceAPI

    private unowned let reactiveWallet: ReactiveWalletAPI

    // MARK: - Setup

    init(accountDetailsService: EthereumAccountDetailsServiceAPI = resolve(),
         reactiveWallet: ReactiveWalletAPI = resolve()) {

        self.reactiveWallet = reactiveWallet
        self.accountDetailsService = accountDetailsService
    }
}
