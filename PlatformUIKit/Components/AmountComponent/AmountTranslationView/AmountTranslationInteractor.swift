//
//  AmountTranslationInteractor.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 09/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

public enum ActiveAmountInput {
    case fiat
    case crypto
    
    var inverted: ActiveAmountInput {
        switch self {
        case .fiat:
            return .crypto
        case .crypto:
            return .fiat
        }
    }
}

public final class AmountTranslationInteractor {
    
    // MARK: - Types
    
    public enum State {
        case empty
        case inBounds
        case maxLimitExceeded(MoneyValuePair)
        case minLimitExceeded(MoneyValuePair)
    }
        
    // MARK: - Properties
    
    /// Fiat interactor
    public let fiatInteractor: InputAmountLabelInteractor
    
    /// Crypto interactor
    public let cryptoInteractor: InputAmountLabelInteractor

    var currentInteractor: Single<InputAmountLabelInteractor> {
        activeInput
            .map(weak: self) { (self, activeInput) in
                switch activeInput {
                case .fiat:
                    return self.fiatInteractor
                case .crypto:
                    return self.cryptoInteractor
                }
            }
            .take(1)
            .asSingle()
    }
    
    /// The state of the component
    public let stateRelay = BehaviorRelay<State>(value: .empty)
    public var state: Observable<State> {
        stateRelay.asObservable()
    }
    
    /// The active input relay
    public let activeInputRelay = BehaviorRelay<ActiveAmountInput>(value: .fiat)
    
    /// A relay responsible for accepting deletion events for the active input
    public let deleteLastRelay = PublishRelay<Void>()
    
    /// A relay responsible for appending new characters to the active input
    public let appendNewRelay = PublishRelay<Character>()
        
    /// The active input - streams distinct elements of `ActiveInput`
    public var activeInput: Observable<ActiveAmountInput> {
        activeInputRelay
            .asObservable()
            .distinctUntilChanged()
    }
    
    /// Input injection relay - allow any client of the component to inject number as a `Decimal` type
    public let inputInjectionRelay = PublishRelay<Decimal>()
    
    /// Streams the amount as `FiatValue`
    public var fiatAmount: Observable<MoneyValue> {
        fiatAmountRelay.asObservable()
    }
    
    /// Streams the amount as `CryptoValue`
    public var cryptoAmount: Observable<MoneyValue> {
        cryptoAmountRelay.asObservable()
    }
    
    /// The amount as `FiatValue`
    private let fiatAmountRelay = BehaviorRelay<MoneyValue>(
        value: .zero(FiatCurrency.default)
    )
    
    /// The amount as `CryptoValue`
    private let cryptoAmountRelay: BehaviorRelay<MoneyValue>
    
    // MARK: - Injected
    
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let cryptoCurrencyService: CryptoCurrencyServiceAPI
    private let exchangeProvider: ExchangeProviding
    
    // MARK: - Accessors
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(fiatCurrencyService: FiatCurrencyServiceAPI,
                cryptoCurrencyService: CryptoCurrencyServiceAPI,
                exchangeProvider: ExchangeProviding,
                defaultFiatCurrency: FiatCurrency = .default,
                defaultCryptoCurrency: CryptoCurrency = .bitcoin) {
        cryptoAmountRelay = BehaviorRelay(value: .zero(defaultCryptoCurrency))
        fiatInteractor = InputAmountLabelInteractor(currency: defaultFiatCurrency)
        cryptoInteractor = InputAmountLabelInteractor(currency: defaultCryptoCurrency)
        self.fiatCurrencyService = fiatCurrencyService
        self.cryptoCurrencyService = cryptoCurrencyService
        self.exchangeProvider = exchangeProvider
        
        /// Currency Change - upon selection of a new fiat or crypto currency,
        /// take the current input amount and based on that and the new currency
        /// modify the fiat / crypto value
        
        // Fiat changes affect crypto
        
        fiatCurrencyService.fiatCurrencyObservable
            .map { $0 as Currency }
            .bind(to: fiatInteractor.interactor.currencyRelay)
            .disposed(by: disposeBag)
        
        cryptoCurrencyService.cryptoCurrencyObservable
            .map { $0 as Currency }
            .bind(to: cryptoInteractor.interactor.currencyRelay)
            .disposed(by: disposeBag)
        
        // Make fiat amount zero after any currency change
        Observable
            .merge(
                fiatInteractor.interactor.currency,
                cryptoInteractor.interactor.currency
            )
            .mapToVoid()
            .map { "" }
            .bind(to: fiatInteractor.scanner.rawInputRelay, cryptoInteractor.scanner.rawInputRelay)
            .disposed(by: disposeBag)

        // Bind of the edit values to the scanner depending on the currently edited currency type
        
        let pairFromFiatInput = fiatInteractor.scanner.input
            .flatMap(weak: self) { (self, input) in
                self.activeInput
                    .take(1)
                    .map { (activeInputType: $0, input: input) }
            }
            // Only when the fiat is under focus
            .filter { $0.activeInputType == .fiat }
            // Get the value
            .map { $0.input }
            .flatMapLatest(weak: self) { (self, value) -> Observable<MoneyValuePair> in
                cryptoCurrencyService
                    .cryptoCurrencyObservable
                    .take(1)
                    .asObservable()
                    .flatMapLatest(weak: self) { (self, currency) in
                         exchangeProvider[currency].fiatPrice
                            .map { pricePerMajor in
                                var amount = value.amount
                                if amount.isEmpty {
                                    amount = "0"
                                }
                                let fiatValue = FiatValue.create(amountString: amount, currency: pricePerMajor.currencyType)
                                let pair = MoneyValuePair(
                                    fiat: fiatValue,
                                    priceInFiat: pricePerMajor,
                                    cryptoCurrency: currency,
                                    usesFiatAsBase: true
                                )
                                return pair
                            }
                    }
            }
        
        let pairFromCryptoInput = cryptoInteractor.scanner.input
            .flatMap(weak: self) { (self, input) in
                self.activeInput
                    .take(1)
                    .map { (activeInputType: $0, input: input) }
            }
            .filter { $0.activeInputType == .crypto }
            .map { $0.input }
            .flatMapLatest(weak: self) { (self, value) -> Observable<MoneyValuePair> in
                cryptoCurrencyService.cryptoCurrency
                    .asObservable()
                    .flatMapLatest(weak: self) { (self, currency) in
                         exchangeProvider[currency].fiatPrice
                             .map { exchangeRate in
                                var amount = value.amount
                                if amount.isEmpty {
                                    amount = "0"
                                }
                                let cryptoValue = CryptoValue(major: amount, cryptoCurrency: currency)!
                                return MoneyValuePair(base: cryptoValue, exchangeRate: exchangeRate)
                             }
                     }
            }
        
        // Merge the output of the scanner from edited amount to the other scanner input relay
                
        pairFromFiatInput
            .map { $0.quote }
            .map { "\($0.displayMajorValue)" }
            .bind(to: cryptoInteractor.scanner.rawInputRelay)
            .disposed(by: disposeBag)

        pairFromCryptoInput
            .map { $0.quote }
            .map { "\($0.amount)" }
            .bind(to: fiatInteractor.scanner.rawInputRelay)
            .disposed(by: disposeBag)
        
        let anyPair = Observable
            .merge(
                pairFromCryptoInput,
                pairFromFiatInput
            )
            .share(replay: 1)
        
        anyPair
            .bindAndCatch(weak: self) { (self, value) in
                switch value.base.currencyType {
                case .crypto:
                    self.cryptoAmountRelay.accept(value.base)
                    self.fiatAmountRelay.accept(value.quote)
                case .fiat:
                    self.fiatAmountRelay.accept(value.base)
                    self.cryptoAmountRelay.accept(value.quote)
                }

            }
            .disposed(by: disposeBag)
 
        // Bind deletion events
                
        let deleteAction = deleteLastRelay
            .withLatestFrom(activeInput)
            .share(replay: 1)
        
        deleteAction
            .filter { $0 == .fiat }
            .mapToVoid()
            .map { MoneyValueInputScanner.Action.remove }
            .bind(to: fiatInteractor.scanner.actionRelay)
            .disposed(by: disposeBag)
        
        deleteAction
            .filter { $0 == .crypto }
            .mapToVoid()
            .map { MoneyValueInputScanner.Action.remove }
            .bind(to: cryptoInteractor.scanner.actionRelay)
            .disposed(by: disposeBag)
        
        // Bind insertion events
        
        let insertAction = appendNewRelay
            .map { MoneyValueInputScanner.Action.insert($0) }
            .flatMap(weak: self) { (self, action) in
                self.activeInput
                    .take(1)
                    .map { (activeInputType: $0, action: action) }
            }
            .share(replay: 1)
        
        insertAction
            .filter { $0.0 == .fiat }
            .map { $0.1 }
            .bind(to: fiatInteractor.scanner.actionRelay)
            .disposed(by: disposeBag)
        
        insertAction
            .filter { $0.0 == .crypto }
            .map { $0.1 }
            .bind(to: cryptoInteractor.scanner.actionRelay)
            .disposed(by: disposeBag)
        
        state
            .map { state in
                switch state {
                case .empty, .inBounds:
                    return .valid
                case .maxLimitExceeded, .minLimitExceeded:
                    return .invalid
                }
            }
            .bindAndCatch(to: fiatInteractor.interactor.stateRelay, cryptoInteractor.interactor.stateRelay)
            .disposed(by: disposeBag)
        
        let inputInjectionAction = inputInjectionRelay
            .flatMap(weak: self) { (self, input) in
                self.activeInput
                    .take(1)
                    .map { (activeInputType: $0, action: input) }
            }
            .share(replay: 1)
        
        inputInjectionAction
            .filter { $0.0 == .fiat }
            .map { $0.1 }
            .map { .init(decimal: $0) }
            .bindAndCatch(to: fiatInteractor.scanner.internalInputRelay)
            .disposed(by: disposeBag)
        
        inputInjectionAction
            .filter { $0.0 == .crypto }
            .map { $0.1 }
            .map { .init(decimal: $0) }
            .bindAndCatch(to: cryptoInteractor.scanner.internalInputRelay)
            .disposed(by: disposeBag)
    }
    
    public func set(amount: String) {
        currentInteractor
            .asObservable()
            .bind { interactor in
                interactor.scanner.rawInputRelay.accept(amount)
            }
            .disposed(by: disposeBag)
    }
}
