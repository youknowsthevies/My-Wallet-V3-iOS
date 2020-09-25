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
