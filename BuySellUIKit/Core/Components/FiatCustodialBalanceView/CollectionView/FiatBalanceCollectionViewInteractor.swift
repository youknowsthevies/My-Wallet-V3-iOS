//
//  FiatBalanceCollectionViewInteractor.swift
//  PlatformUIKit
//
//  Created by Daniel on 13/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformKit
import BuySellKit
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
            .compactMap { $0.value }
            .startWith([])
    }
    
    // MARK: - Injected Properties
    
    private let featureFetcher: FeatureFetching
    private let balanceProvider: BalanceProviding
    private let paymentMethodsService: PaymentMethodsServiceAPI
    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    private let refreshRelay = PublishRelay<Void>()
    
    // MARK: - Accessors
    
    let interactorsStateRelay = BehaviorRelay<State>(value: .invalid(.empty))
    private let disposeBag = DisposeBag()
    
    private lazy var setup: Void = {
        let enabledFiatCurrencies = enabledCurrenciesService.allEnabledFiatCurrencies
        Observable
            .combineLatest(
                featureFetcher.fetchBool(for: .simpleBuyFundsEnabled).asObservable(),
                balanceProvider.fiatFundsBalances,
                paymentMethodsService.paymentMethods.map { $0.fundsCurrencies },
                refreshRelay.asObservable()
            )
            .filter { $0.0 }
            .map { (balances: $0.1, funds: $0.2) }
            .map { $0.balances.filter(by: $0.funds) }
            .filter { $0.isValue } // All balances must contain value to load
            .map {
                Array.init(
                    balancePairsCalculationStates: $0,
                    supportedFiatCurrencies: enabledFiatCurrencies
                )
            }
            .map { .value($0) }
            .startWith(.calculating)
            .catchErrorJustReturn(.invalid(.empty))
            .bindAndCatch(to: interactorsStateRelay)
            .disposed(by: disposeBag)
    }()
    
    public init(balanceProvider: BalanceProviding,
                enabledCurrenciesService: EnabledCurrenciesServiceAPI,
                paymentMethodsService: PaymentMethodsServiceAPI,
                featureFetcher: FeatureFetching) {
        self.balanceProvider = balanceProvider
        self.featureFetcher = featureFetcher
        self.paymentMethodsService = paymentMethodsService
        self.enabledCurrenciesService = enabledCurrenciesService
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
