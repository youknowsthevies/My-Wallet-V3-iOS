//
//  ActivityServiceContainer.swift
//  Blockchain
//
//  Created by Alex McGregor on 5/5/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxRelay
import RxSwift

public protocol ActivityServiceContaining {
    var asset: Observable<CurrencyType> { get }
    var activityProviding: ActivityProviding { get }
    var balanceProviding: BalanceProviding { get }
    var exchangeProviding: ExchangeProviding { get }
    var fiatCurrency: FiatCurrencySettingsServiceAPI { get }
    var activity: Observable<ActivityItemEventServiceAPI> { get }
    var selectionService: WalletPickerSelectionServiceAPI { get }
    var accountSelectionService: AccountSelectionServiceAPI { get }
    var activityEventsLoadingState: Observable<ActivityItemEventsLoadingState> { get }
}

final class ActivityServiceContainer: ActivityServiceContaining {
    public var asset: Observable<CurrencyType> {
        selectionService
            .selectedData
            .compactMap { $0.currencyType }
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
    public let balanceProviding: BalanceProviding
    public let fiatCurrency: FiatCurrencySettingsServiceAPI
    public let selectionService: WalletPickerSelectionServiceAPI
    public let accountSelectionService: AccountSelectionServiceAPI
    public let exchangeProviding: ExchangeProviding
    
    private let eventsRelay = BehaviorRelay<ActivityItemEventsLoadingState>(value: .loading)
    private let disposeBag = DisposeBag()
    private lazy var setup: Void = {
        accountSelectionService
            .selectedData
            .map { account -> WalletPickerSelection in
                guard let account = account as? SingleAccount else {
                    return .all
                }
                if account is NonCustodialAccount {
                    return .nonCustodial(account.currencyType)
                } else {
                    return .custodial(account.currencyType)
                }
            }
            .bind { [weak self] selection in
                self?.selectionService.record(selection: selection)
            }
            .disposed(by: disposeBag)

        selectionService
            .selectedData
            .do(afterNext: { [weak self] _ in self?.activityProviding.refresh() })
            .flatMapLatest(weak: self) { (self, selection) -> Observable<ActivityItemEventsLoadingState> in
                /// For non-custodial and custodial events there are swaps
                /// specific to the non-custodial or custodial wallet.
                /// In other words, you can swap from either type of wallet.
                /// The picker allows you to filter by wallet, so we must pull swaps from
                /// either the custodial, non-custodial, or both. We would normally use
                ///  `ActivityItemEventsLoadingState` for each of our services but, since we need to split
                ///  custodial from non-custodial swaps, we need deviate from this in the `.nonCustodial`
                ///  and `.custodial` state.
                switch selection {
                case .all:
                    return self.activityProviding.activityItems
                case .nonCustodial(let currency):
                    let activityProvider = self.activityProviding[currency.cryptoCurrency!]
                    let transactional = activityProvider.transactional
                    /// We can't use the `activityProvider.swap.state` here since we want only the
                    /// noncustodial swaps.
                    let swap = activityProvider.swap.nonCustodial
                    return Observable.combineLatest(
                            transactional.state,
                            swap
                        )
                        .map { (states) -> ActivityItemEventsLoadingState in
                            [states.1, states.0].reduce()
                        }
                case .custodial(let currency):
                    switch currency {
                    case .crypto(let crypto):
                        /// We can't use the `self.activityProviding[crypto].swap.state`
                        /// here since we want only the custodial swaps.
                        let swap = self.activityProviding[crypto].swap.custodial
                        let buySell = self.activityProviding[crypto].buySell.state
                        return Observable.combineLatest(swap, buySell)
                            .map { (states) -> ActivityItemEventsLoadingState in
                                [states.1, states.0].reduce()
                            }
                    case .fiat(let fiat):
                        return self.activityProviding[fiat].activityLoadingStateObservable
                    }
                }
            }
            .bindAndCatch(to: eventsRelay)
            .disposed(by: disposeBag)
    }()
    
    public init(fiatCurrency: FiatCurrencySettingsServiceAPI = resolve(),
                balanceProviding: BalanceProviding = resolve(),
                exchangeProviding: ExchangeProviding = resolve(),
                activityProviding: ActivityProviding = resolve()) {
        self.selectionService = WalletPickerSelectionService(defaultSelection: .all)
        self.accountSelectionService = AccountSelectionService()
        self.fiatCurrency = fiatCurrency
        self.balanceProviding = balanceProviding
        self.exchangeProviding = exchangeProviding
        self.activityProviding = activityProviding
    }
}
