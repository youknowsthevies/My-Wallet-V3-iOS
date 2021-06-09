// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxRelay
import RxSwift
import ToolKit

public protocol ActivityServiceContaining {
    var asset: Observable<CurrencyType> { get }
    var activityProviding: ActivityProviding { get }
    var exchangeProviding: ExchangeProviding { get }
    var fiatCurrency: FiatCurrencySettingsServiceAPI { get }
    var activity: Observable<ActivityItemEventServiceAPI> { get }
    var selectionService: WalletPickerSelectionServiceAPI { get }
    var accountSelectionService: AccountSelectionServiceAPI { get }
    var activityEventsLoadingState: Observable<ActivityItemEventsLoadingState> { get }
}

final class ActivityServiceContainer: ActivityServiceContaining {
    public var asset: Observable<CurrencyType> {
        selectionService.selectedData
            .map(\.currencyType)
    }

    public var activityEventsLoadingState: Observable<ActivityItemEventsLoadingState> {
        _ = setup
        return eventsRelay.asObservable()
    }

    public var activity: Observable<ActivityItemEventServiceAPI> {
        asset.map { currency -> ActivityItemEventServiceAPI in
            self.activityProviding[currency]
        }
    }

    public let activityProviding: ActivityProviding
    public let fiatCurrency: FiatCurrencySettingsServiceAPI
    public let selectionService: WalletPickerSelectionServiceAPI
    public let accountSelectionService: AccountSelectionServiceAPI
    public let exchangeProviding: ExchangeProviding

    private let eventsRelay = BehaviorRelay<ActivityItemEventsLoadingState>(value: .loading)
    private let disposeBag = DisposeBag()
    private lazy var setup: Void = {
        accountSelectionService
            .selectedData
            .bind { [weak self] selection in
                self?.selectionService.record(selection: selection)
            }
            .disposed(by: disposeBag)

        selectionService
            .selectedData
            .do(afterNext: { [weak self] _ in self?.activityProviding.refresh() })
            .flatMapLatest(weak: self) { (self, account) -> Observable<ActivityItemEventsLoadingState> in
                /// For non-custodial and custodial events there are swaps
                /// specific to the non-custodial or custodial wallet.
                /// In other words, you can swap from either type of wallet.
                /// The picker allows you to filter by wallet, so we must pull swaps from
                /// either the custodial, non-custodial, or both. We would normally use
                ///  `ActivityItemEventsLoadingState` for each of our services but, since we need to split
                ///  custodial from non-custodial swaps, we need deviate from this in the `.nonCustodial`
                ///  and `.custodial` state.
                switch account {
                case is AccountGroup:
                    return self.activityProviding.activityItems
                case let nonCustodial as CryptoNonCustodialAccount:
                    let activityProvider = self.activityProviding[nonCustodial.asset]
                    /// We can't use the `activityProvider.swap.state` here since we want only the
                    /// noncustodial swaps.
                    return Observable
                        .combineLatest(
                            activityProvider.swap.nonCustodial,
                            activityProvider.transactional.state
                        ) { (swap: $0, transactional: $1) }
                        .map { states -> ActivityItemEventsLoadingState in
                            [states.swap, states.transactional].reduce()
                        }
                case let fiatAccount as FiatAccount:
                    return self.activityProviding[fiatAccount.fiatCurrency]
                        .activityLoadingStateObservable
                case let tradingAccount as CryptoTradingAccount:
                    let activityProvider = self.activityProviding[tradingAccount.asset]
                    /// We can't use the `self.activityProviding[crypto].swap.state`
                    /// here since we want only the custodial swaps.
                    return Observable
                        .combineLatest(
                            activityProvider.swap.custodial,
                            activityProvider.buySell.state
                        ) { (swap: $0, buySell: $1) }
                        .map { states -> ActivityItemEventsLoadingState in
                            [states.swap, states.buySell].reduce()
                        }
                default:
                    impossible("Unsupported Account Type \(String(reflecting: account))")
                }
            }
            .bindAndCatch(to: eventsRelay)
            .disposed(by: disposeBag)
    }()

    public init(fiatCurrency: FiatCurrencySettingsServiceAPI = resolve(),
                exchangeProviding: ExchangeProviding = resolve(),
                activityProviding: ActivityProviding = resolve()) {
        self.selectionService = WalletPickerSelectionService()
        self.accountSelectionService = AccountSelectionService()
        self.fiatCurrency = fiatCurrency
        self.exchangeProviding = exchangeProviding
        self.activityProviding = activityProviding
    }
}
