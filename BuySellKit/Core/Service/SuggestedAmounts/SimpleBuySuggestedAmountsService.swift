//
//  SimpleBuySuggestedAmountsService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 29/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import ToolKit
import PlatformKit

// TODO: Handle `CryptoValue`
/// The calculation state of Simple Buy suggested fiat amounts to buy
public typealias SimpleBuySuggestedAmountsCalculationState = ValueCalculationState<[FiatValue]>

/// A simple buy suggested amounts API
public protocol SimpleBuySuggestedAmountsServiceAPI: class {
    
    /// Streams the suggested amounts
    var calculationState: Observable<SimpleBuySuggestedAmountsCalculationState> { get }
    
    /// Refresh, triggering a re-fetch of `SimpleBuySuggestedAmountsCalculationState`.
    /// Makes `calculationState` to stream an updated value
    func refresh()
}

public final class SimpleBuySuggestedAmountsService: SimpleBuySuggestedAmountsServiceAPI {
    
    // MARK: - Exposed
    
    public var calculationState: Observable<SimpleBuySuggestedAmountsCalculationState> {
        calculationStateRelay.asObservable()
    }
        
    // MARK: - Injected
            
    private let authenticationService: NabuAuthenticationServiceAPI
    private let client: SimpleBuySuggestedAmountsClientAPI
    
    // MARK: - Accessors
    
    private let calculationStateRelay = BehaviorRelay<SimpleBuySuggestedAmountsCalculationState>(value: .invalid(.empty))
    private let fetchTriggerRelay = PublishRelay<Void>()
    private let reactiveWallet: ReactiveWalletAPI
    private let fiatCurrencySettingsService: FiatCurrencySettingsServiceAPI
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(client: SimpleBuySuggestedAmountsClientAPI = SimpleBuyClient(),
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
            .map { SimpleBuySuggestedAmountsCalculationState.value($0) }
            .catchErrorJustReturn(.invalid(.valueCouldNotBeCalculated))
            .bind(to: calculationStateRelay)
            .disposed(by: disposeBag)
    }
    
    /// Refreshes the cached data set
    public func refresh() {
        fetchTriggerRelay.accept(())
    }
    
    private func fetchSuggestedAmounts(for currency: FiatCurrency) -> Single<[FiatValue]> {
        return authenticationService
            .tokenString
            .flatMap(weak: self) { (self, token) -> Single<SimpleBuySuggestedAmountsResponse> in
                self.client.suggestedAmounts(for: currency, using: token)
            }
            .map { SimpleBuySuggestedAmounts(response: $0) }
            .map { $0[currency] }
    }
}
