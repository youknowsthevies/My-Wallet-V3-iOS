//
//  SuggestedAmountsService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 29/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxRelay
import RxSwift
import ToolKit

// TODO: Handle `CryptoValue`
/// The calculation state of Simple Buy suggested fiat amounts to buy
public typealias SuggestedAmountsCalculationState = ValueCalculationState<[FiatValue]>

/// A simple buy suggested amounts API
public protocol SuggestedAmountsServiceAPI: class {
    
    /// Streams the suggested amounts
    var calculationState: Observable<SuggestedAmountsCalculationState> { get }
    
    /// Refresh, triggering a re-fetch of `SuggestedAmountsCalculationState`.
    /// Makes `calculationState` to stream an updated value
    func refresh()
}

final class SuggestedAmountsService: SuggestedAmountsServiceAPI {
    
    // MARK: - Exposed
    
    var calculationState: Observable<SuggestedAmountsCalculationState> {
        calculationStateRelay.asObservable()
    }
        
    // MARK: - Injected
            
    private let authenticationService: NabuAuthenticationServiceAPI
    private let client: SuggestedAmountsClientAPI
    
    // MARK: - Accessors
    
    private let calculationStateRelay = BehaviorRelay<SuggestedAmountsCalculationState>(value: .invalid(.empty))
    private let fetchTriggerRelay = PublishRelay<Void>()
    private let reactiveWallet: ReactiveWalletAPI
    private let fiatCurrencySettingsService: FiatCurrencySettingsServiceAPI
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(client: SuggestedAmountsClientAPI,
         reactiveWallet: ReactiveWalletAPI,
         authenticationService: NabuAuthenticationServiceAPI,
         fiatCurrencySettingsService: FiatCurrencySettingsServiceAPI) {
        self.client = client
        self.reactiveWallet = reactiveWallet
        self.authenticationService = authenticationService
        self.fiatCurrencySettingsService = fiatCurrencySettingsService
        
        Observable
            .combineLatest(
                fiatCurrencySettingsService.fiatCurrencyObservable,
                fetchTriggerRelay.asObservable(),
                reactiveWallet.waitUntilInitialized)
            .map { $0.0 }
            .flatMapLatest(weak: self) { (self, currency) -> Observable<[FiatValue]> in
                self.fetchSuggestedAmounts(for: currency).asObservable()
            }
            .map { SuggestedAmountsCalculationState.value($0) }
            .catchErrorJustReturn(.invalid(.valueCouldNotBeCalculated))
            .bind(to: calculationStateRelay)
            .disposed(by: disposeBag)
    }
    
    /// Refreshes the cached data set
    func refresh() {
        fetchTriggerRelay.accept(())
    }
    
    private func fetchSuggestedAmounts(for currency: FiatCurrency) -> Single<[FiatValue]> {
        authenticationService
            .tokenString
            .flatMap(weak: self) { (self, token) -> Single<SuggestedAmountsResponse> in
                self.client.suggestedAmounts(for: currency, using: token)
            }
            .map { SuggestedAmounts(response: $0) }
            .map { $0[currency] }
    }
}
