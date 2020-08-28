//
//  ActivityScreenInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 16/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift
import ToolKit

final class ActivityScreenInteractor {
    
    typealias State = ValueCalculationState<[ActivityItemInteractor]>
    
    // MARK: - Public Properties
    
    var fiatCurrency: Observable<FiatCurrency> {
        serviceContainer
            .fiatCurrency
            .fiatCurrencyObservable
    }
    
    var selectedData: Observable<WalletPickerSelection> {
        selectionService
            .selectedData
    }
    
    var activityBalance: Observable<FiatValue> {
        selectionService
            .selectedData
            .flatMap(weak: self) { (self, selection) -> Observable<FiatValue> in
                switch selection {
                case .all:
                    return self.serviceContainer
                        .balanceProviding
                        .fiatBalance
                        .compactMap { $0.value }
                case .custodial(let currency):
                    return self.serviceContainer
                        .balanceProviding
                        .fiatBalances
                        .map { $0[currency.currency] }
                        .compactMap { $0.value }
                        .compactMap { $0[.custodial(.trading)].quote.fiatValue }
                case .nonCustodial(let currency):
                    return self.serviceContainer
                        .balanceProviding
                        .fiatBalances
                        .map { $0[currency.currency] }
                        .compactMap { $0.value }
                        .compactMap { $0[.nonCustodial].quote.fiatValue }
                }
        }
    }
    
    var state: Observable<State> {
        stateRelay
            .asObservable()
    }
    
    var isEmpty: Observable<Bool> {
        stateRelay
            .asObservable()
            .map { value in
                switch value {
                case .invalid(let error):
                    return error == .empty
                case .value(let values):
                    return values.count == 0
                case .calculating:
                    return false
                }
        }
    }
    
    // MARK: - Private Properties
    
    private var selectionService: WalletPickerSelectionServiceAPI {
        serviceContainer.selectionService
    }
    
    private let stateRelay = BehaviorRelay<State>(value: .invalid(.empty))
    private let serviceContainer: ActivityServiceContainer
    private let disposeBag = DisposeBag()
    
    init(serviceContainer: ActivityServiceContainer) {
        self.serviceContainer = serviceContainer
        
        serviceContainer
            .activityEventsLoadingState
            .map {
                .init(
                    with: $0,
                    exchangeProviding: serviceContainer.exchangeProviding,
                    balanceProviding: serviceContainer.balanceProviding
                )
            }
            .startWith(.calculating)
            .catchErrorJustReturn(.invalid(.empty))
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }
    
    func refresh() {
        serviceContainer.activityProviding.refresh()
    }
}

fileprivate extension ActivityScreenInteractor.State {
    
    /// Initializer that receives the loading state and
    /// maps it to `self`
    init(with state: ActivityItemEventsLoadingState,
         exchangeProviding: ExchangeProviding,
         balanceProviding: BalanceProviding) {
        switch state {
        case .loading:
            self = .calculating
        case .loaded(let value):
            let sorted = value.sorted(by: { $0.creationDate.compare($1.creationDate) == .orderedDescending })
            let interactors: [ActivityItemInteractor] = sorted.map {
                ActivityItemInteractor(
                    exchangeAPI: exchangeProviding[$0.amount.currencyType],
                    assetBalanceFetcher: balanceProviding[$0.amount.currencyType],
                    activityItemEvent: $0
                )
            }
            self = interactors.count > 0 ? .value(interactors) : .invalid(.empty)
        }
    }
}
