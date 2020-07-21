//
//  AssetPieChartInteractor.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 24/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxRelay
import RxSwift

public final class AssetPieChartInteractor: AssetPieChartInteracting {
        
    // MARK: - Properties
    
    public var state: Observable<AssetPieChart.State.Interaction> {
        _ = setup
        return stateRelay
            .asObservable()
    }
            
    // MARK: - Private Accessors
    
    private lazy var setup: Void = {
        let currencies = Observable.just(cryptoCurrencies)
        Observable
            .combineLatest(balanceProvider.fiatBalances, balanceProvider.fiatBalance, currencies)
            .map { (balances, totalBalance, currencies) in
                guard let totalFiatValue = totalBalance.value else {
                    return .loading
                }
                
                let total = MoneyValue(fiatValue: totalFiatValue)
                
                guard total.isPositive else {
                    let zero = MoneyValue.zero(total.currencyType)
                    let states = currencies.map { AssetPieChart.Value.Interaction(asset: $0, percentage: zero) }
                    return .loaded(next: states)
                }

                let balances: [LoadingState<AssetPieChart.Value.Interaction>] = try currencies
                    .map { currency -> LoadingState<AssetPieChart.Value.Interaction> in
                        guard let balance = balances[currency.currency].value?.quote else {
                            return .loading
                        }
                        return .loaded(next: AssetPieChart.Value.Interaction(asset: currency, percentage: try balance / total))
                    }

                guard !balances.contains(.loading) else {
                    return .loading
                }
                return .loaded(next: balances.compactMap { $0.value })
            }
            .catchErrorJustReturn(.loading)
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }()
    
    private let stateRelay = BehaviorRelay<AssetPieChart.State.Interaction>(value: .loading)
    private let disposeBag = DisposeBag()

    private let cryptoCurrencies: [CryptoCurrency]
    private let balanceProvider: BalanceProviding

    // MARK: - Setup
    
    public init(balanceProvider: BalanceProviding, cryptoCurrencies: [CryptoCurrency]) {
        self.balanceProvider = balanceProvider
        self.cryptoCurrencies = cryptoCurrencies
    }    
}
