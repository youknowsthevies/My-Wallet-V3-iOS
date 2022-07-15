// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import DIKit
import MoneyKit
import PlatformKit
import RxRelay
import RxSwift
import ToolKit

public final class FiatBalanceCollectionViewInteractor {

    // MARK: - Types

    public typealias State = ValueCalculationState<[FiatCustodialBalanceViewInteractor]>

    // MARK: - Exposed Properties

    /// Streams the interactors
    public var interactorsState: Observable<State> {
        _ = setup
        return interactorsStateRelay.asObservable()
    }

    var interactors: Observable<[FiatCustodialBalanceViewInteractor]> {
        interactorsState
            .compactMap(\.value)
            .startWith([])
    }

    // MARK: - Injected Properties

    private let app: AppProtocol
    private let tiersService: KYCTiersServiceAPI
    private let paymentMethodsService: PaymentMethodsServiceAPI
    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let userService: NabuUserServiceAPI
    private let refreshRelay = PublishRelay<Void>()
    private let coincore: CoincoreAPI
    private let disposeBag = DisposeBag()

    // MARK: - Accessors

    let interactorsStateRelay = BehaviorRelay<State>(value: .invalid(.empty))

    private func fiatAccounts() -> Single<[SingleAccount]> {
        tiersService.tiers
            .asSingle()
            .map(\.isTier2Approved)
            .catchAndReturn(false)
            .flatMap(weak: self) { (self, isTier2Approved) in
                guard isTier2Approved else {
                    return .just([])
                }
                return self.coincore.fiatAsset
                    .accountGroup(filter: .all)
                    .asObservable()
                    .asSingle()
                    .map(\.accounts)
            }
    }

    private lazy var setup: Void = Observable
        .combineLatest(
            fiatCurrencyService.displayCurrencyPublisher.asObservable(),
            refreshRelay.asObservable(),
            app.publisher(for: blockchain.user.currency.currencies, as: [FiatCurrency].self)
                .compactMap(\.value)
                .asObservable()
        ) { (fiatCurrency: $0, _: $1, currencies: $2) }
        .flatMapLatest(weak: self) { (self, data) in
            self.fiatAccounts()
                .asObservable()
                .map { accounts in
                    data.currencies
                        .compactMap { currency in
                            accounts.first(where: { account in account.currencyType.fiatCurrency == currency })
                        }
                        .map(FiatCustodialBalanceViewInteractor.init(account:))
                }
        }
        .map { .value($0) }
        .startWith(.calculating)
        .catchAndReturn(.invalid(.empty))
        .bindAndCatch(to: interactorsStateRelay)
        .disposed(by: disposeBag)

    public init(
        app: AppProtocol = resolve(),
        tiersService: KYCTiersServiceAPI = resolve(),
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve(),
        paymentMethodsService: PaymentMethodsServiceAPI = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
        coincore: CoincoreAPI = resolve(),
        userService: NabuUserServiceAPI = resolve()
    ) {
        self.app = app
        self.coincore = coincore
        self.tiersService = tiersService
        self.paymentMethodsService = paymentMethodsService
        self.enabledCurrenciesService = enabledCurrenciesService
        self.fiatCurrencyService = fiatCurrencyService
        self.userService = userService
    }

    public func refresh() {
        refreshRelay.accept(())
    }
}

extension FiatBalanceCollectionViewInteractor: Equatable {
    public static func == (lhs: FiatBalanceCollectionViewInteractor, rhs: FiatBalanceCollectionViewInteractor) -> Bool {
        lhs.interactorsStateRelay.value == rhs.interactorsStateRelay.value
    }
}

extension FiatBalanceCollectionViewInteractor: FiatBalancesInteracting {
    public var hasBalances: Observable<Bool> {
        interactorsState
            .compactMap(\.value)
            .map(\.isNotEmpty)
            .catchAndReturn(false)
    }

    public func reloadBalances() {
        refresh()
    }
}
