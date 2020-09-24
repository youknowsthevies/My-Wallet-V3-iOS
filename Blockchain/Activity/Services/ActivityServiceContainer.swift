//
//  ActivityServiceContainer.swift
//  Blockchain
//
//  Created by Alex McGregor on 5/5/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxRelay
import RxSwift

protocol ActivityServiceContaining {
    var asset: Observable<CurrencyType> { get }
    var balanceProviding: BalanceProviding { get }
    var exchangeProviding: ExchangeProviding { get }
    var fiatCurrency: FiatCurrencySettingsServiceAPI { get }
    var activity: Observable<ActivityItemEventServiceAPI> { get }
    var selectionService: WalletPickerSelectionServiceAPI { get }
    var accountSelectionService: AccountSelectionServiceAPI { get }
}

final class ActivityServiceContainer: ActivityServiceContaining {
    var asset: Observable<CurrencyType> {
        selectionService
            .selectedData
            .compactMap { $0.currencyType }
    }
    
    var activityEventsLoadingState: Observable<ActivityItemEventsLoadingState> {
        _ = setup
        return eventsRelay.asObservable()
    }
    
    var activity: Observable<ActivityItemEventServiceAPI> {
        asset.map { currency -> ActivityItemEventServiceAPI in
            self.activityProviding[currency]
        }
    }
    
    let activityProviding: ActivityProviding
    let balanceProviding: BalanceProviding
    let fiatCurrency: FiatCurrencySettingsServiceAPI
    let selectionService: WalletPickerSelectionServiceAPI
    let accountSelectionService: AccountSelectionServiceAPI
    let exchangeProviding: ExchangeProviding
    
    private let eventsRelay = BehaviorRelay<ActivityItemEventsLoadingState>(value: .loading)
    private let disposeBag = DisposeBag()
    private lazy var setup: Void = {
        accountSelectionService
            .selectedData
            .map { account -> WalletPickerSelection in
                if let account: FiatAccount = account as? FiatAccount {
                    switch account.balanceType {
                    case .custodial:
                        return .custodial(account.currencyType)
                    case .nonCustodial:
                        fatalError("Fiat Account cannot be non-custodial: \(account)")
                    }
                }
                if let account: CryptoAccount = account as? CryptoAccount {
                    switch account.balanceType {
                    case .custodial:
                        return .custodial(.crypto(account.asset))
                    case .nonCustodial:
                        return .nonCustodial(account.asset)
                    }
                }
                return .all
            }
            .bind { [weak self] selection in
                self?.selectionService.record(selection: selection)
            }
            .disposed(by: disposeBag)

        selectionService
            .selectedData
            .do(afterNext: { [weak self] _ in self?.activityProviding.refresh() })
            .flatMapLatest(weak: self) { (self, selection) -> Observable<ActivityItemEventsLoadingState> in
                switch selection {
                case .all:
                    return self.activityProviding.activityItems
                case .nonCustodial(let currency):
                    let transactional = self.activityProviding[currency].transactional
                    let swap = self.activityProviding[currency].swap
                    return Observable.combineLatest(
                            transactional.state,
                            swap.state
                        )
                        .map(weak: self) { (self, states) -> ActivityItemEventsLoadingState in
                            [states.1, states.0].reduce()
                        }
                case .custodial(let currency):
                    switch currency {
                    case .crypto(let crypto):
                        return self.activityProviding[crypto].buySell.state
                    case .fiat(let fiat):
                        return self.activityProviding[fiat].activityLoadingStateObservable
                    }
                }
            }
            .bindAndCatch(to: eventsRelay)
            .disposed(by: disposeBag)
    }()
    
    init(fiatCurrency: FiatCurrencySettingsServiceAPI = UserInformationServiceProvider.default.settings,
         balanceProviding: BalanceProviding = DataProvider.default.balance,
         exchangeProviding: ExchangeProviding = DataProvider.default.exchange,
         activityProviding: ActivityProviding = ActivityServiceProvider.default.activity) {
        self.selectionService = WalletPickerSelectionService(defaultSelection: .all)
        self.accountSelectionService = AccountSelectionService()
        self.fiatCurrency = fiatCurrency
        self.balanceProviding = balanceProviding
        self.exchangeProviding = exchangeProviding
        self.activityProviding = activityProviding
    }
}
