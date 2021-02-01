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
    
    public enum Input {
        case insert(Character)
        case remove
        
        var character: Character? {
            switch self {
            case .insert(let value):
                return value
            case .remove:
                return nil
            }
        }
    }
    
    public enum State {
        case empty
        case inBounds
        case warning(message: String, action: () -> Void)
        case error(message: String)
        case maxLimitExceeded(MoneyValue)
        case minLimitExceeded(MoneyValue)
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
    public let activeInputRelay: BehaviorRelay<ActiveAmountInput>
    
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
    
    /// Streams the amount depending on the `ActiveAmountInput` type. 
    public var amount: Observable<MoneyValue> {
        Observable
            .combineLatest(cryptoAmount, fiatAmount, activeInput)
            .map { (crypto: $0.0, fiat: $0.1, input: $0.2) }
            .map { (crypto: MoneyValue, fiat: MoneyValue, input: ActiveAmountInput) -> MoneyValue in
                switch input {
                case .crypto:
                    return crypto
                case .fiat:
                    return fiat
                }
            }
    }
    
    /// The amount as `FiatValue`
    private let fiatAmountRelay: BehaviorRelay<MoneyValue>
    
    /// The amount as `CryptoValue`
    private let cryptoAmountRelay: BehaviorRelay<MoneyValue>
    
    // MARK: - Injected
    
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let cryptoCurrencyService: CryptoCurrencyServiceAPI
    private let priceProvider: AmountTranslationPriceProviding
    
    // MARK: - Accessors
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(fiatCurrencyService: FiatCurrencyServiceAPI,
                cryptoCurrencyService: CryptoCurrencyServiceAPI,
                priceProvider: AmountTranslationPriceProviding = AmountTranslationPriceProvider(),
                defaultFiatCurrency: FiatCurrency = .default,
                defaultCryptoCurrency: CryptoCurrency,
                initialActiveInput: ActiveAmountInput) {
        activeInputRelay = BehaviorRelay(value: initialActiveInput)
        cryptoAmountRelay = BehaviorRelay(value: .zero(currency: defaultCryptoCurrency))
        fiatInteractor = InputAmountLabelInteractor(currency: defaultFiatCurrency)
        cryptoInteractor = InputAmountLabelInteractor(currency: defaultCryptoCurrency)
        self.fiatCurrencyService = fiatCurrencyService
        self.cryptoCurrencyService = cryptoCurrencyService
        self.priceProvider = priceProvider
        fiatAmountRelay = BehaviorRelay<MoneyValue>(
            value: .zero(currency: defaultFiatCurrency)
        )
        
        /// Currency Change - upon selection of a new fiat or crypto currency,
        /// take the current input amount and based on that and the new currency
        /// modify the fiat / crypto value
        
        // Fiat changes affect crypto

        let fiatCurrency = fiatCurrencyService.fiatCurrencyObservable
            .map { $0 as Currency }
            .share(replay: 1, scope: .whileConnected)

        let cryptoCurrency = cryptoCurrencyService.cryptoCurrencyObservable
            .map { $0 as Currency }
            .share(replay: 1, scope: .whileConnected)
        
        fiatCurrency
            .bindAndCatch(to: fiatInteractor.interactor.currencyRelay)
            .disposed(by: disposeBag)

        cryptoCurrency
            .bindAndCatch(to: cryptoInteractor.interactor.currencyRelay)
            .disposed(by: disposeBag)

        // We need to keep any currency selection changes up to date with the input values
        // and eventually update the `cryptoAmountRelay` and `fiatAmountRelay`
        let currenciesMerged = Observable.merge(fiatCurrency, cryptoCurrency)
            .share(replay: 1, scope: .whileConnected)

        // Make fiat amount zero after any currency change
        currenciesMerged
            .mapToVoid()
            .map { "" }
            .bindAndCatch(to: fiatInteractor.scanner.rawInputRelay, cryptoInteractor.scanner.rawInputRelay)
            .disposed(by: disposeBag)

        // Bind of the edit values to the scanner depending on the currently edited currency type
        let pairFromFiatInput = currenciesMerged
            .flatMap(weak: self) { (self, _) -> Observable<MoneyValueInputScanner.Input> in
                self.fiatInteractor.scanner.input
            }
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
                self.pairFromFiatInput(amount: value.amount).asObservable()
            }
        
        let pairFromCryptoInput = currenciesMerged
            .flatMap(weak: self) { (self, _) -> Observable<MoneyValueInputScanner.Input> in
                self.cryptoInteractor.scanner.input
            }
            .flatMap(weak: self) { (self, input) in
                self.activeInput
                    .take(1)
                    .map { (activeInputType: $0, input: input) }
            }
            .filter { $0.activeInputType == .crypto }
            .map { $0.input }
            .flatMapLatest(weak: self) { (self, value) -> Observable<MoneyValuePair> in
                self.pairFromCryptoInput(amount: value.amount).asObservable()
            }

        // Merge the output of the scanner from edited amount to the other scanner input relay

        pairFromFiatInput
            .map(\.quote)
            .map(\.displayMajorValue)
            .map { "\($0)" }
            .bindAndCatch(to: cryptoInteractor.scanner.rawInputRelay)
            .disposed(by: disposeBag)

        pairFromCryptoInput
            .map(\.quote)
            .map(\.displayMajorValue)
            .map { "\($0)" }
            .bindAndCatch(to: fiatInteractor.scanner.rawInputRelay)
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
            .bindAndCatch(to: fiatInteractor.scanner.actionRelay)
            .disposed(by: disposeBag)
        
        deleteAction
            .filter { $0 == .crypto }
            .mapToVoid()
            .map { MoneyValueInputScanner.Action.remove }
            .bindAndCatch(to: cryptoInteractor.scanner.actionRelay)
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
            .bindAndCatch(to: fiatInteractor.scanner.actionRelay)
            .disposed(by: disposeBag)
        
        insertAction
            .filter { $0.0 == .crypto }
            .map { $0.1 }
            .bindAndCatch(to: cryptoInteractor.scanner.actionRelay)
            .disposed(by: disposeBag)
        
        state
            .map { state in
                switch state {
                case .empty, .inBounds:
                    return .valid
                case .maxLimitExceeded, .minLimitExceeded, .warning, .error:
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
    
    public func connect(input: Driver<Input>) -> Driver<State> {
        // Input Actions
        input
            .compactMap(\.character)
            .asObservable()
            .bindAndCatch(to: self.appendNewRelay)
            .disposed(by: disposeBag)
        
        input
            .filter { $0.character == nil }
            .asObservable()
            .mapToVoid()
            .bindAndCatch(to: self.deleteLastRelay)
            .disposed(by: disposeBag)

        return state
            .asDriver(onErrorJustReturn: .empty)
    }
    
    public func set(amount: String) {
        currentInteractor
            .asObservable()
            .bind { interactor in
                interactor.scanner.rawInputRelay.accept(amount)
            }
            .disposed(by: disposeBag)
    }

    public func set(amount: MoneyValue) {
        invertInputIfNeeded(for: amount)
            .andThen(currentInteractor)
            .subscribe { interactor in
                interactor.scanner.reset(to: amount)
            }
            .disposed(by: disposeBag)
    }

    private func invertInputIfNeeded(for amount: MoneyValue) -> Completable {
        activeInput.take(1)
            .asSingle()
            .flatMapCompletable(weak: self) { (self, activeInput) -> Completable in
                switch (activeInput, amount.isFiat) {
                case (.fiat, true), (.crypto, false):
                    return .empty()
                case (.fiat, false), (.crypto, true):
                    return self.invertInput(from: activeInput)
                }
            }
    }

    private func invertInput(from activeInput: ActiveAmountInput) -> Completable {
        Single.just(activeInput)
            .map(\.inverted)
            .observeOn(MainScheduler.asyncInstance)
            .do(onSuccess: { [weak self] input in
                self?.activeInputRelay.accept(input)
            })
            .asCompletable()
    }

    private func pairFromFiatInput(amount: String) -> Single<MoneyValuePair> {
        Single
            .zip(cryptoCurrencyService.cryptoCurrency,
                 fiatCurrencyService.fiatCurrency)
            .flatMap(weak: self) { (self, currencies) -> Single<MoneyValuePair> in
                let (cryptoCurrency, fiatCurrency) = currencies
                return self.priceProvider
                    .pairFromFiatInput(
                        cryptoCurrency: cryptoCurrency,
                        fiatCurrency: fiatCurrency,
                        amount: amount
                    )
            }
    }

    private func pairFromCryptoInput(amount: String) -> Single<MoneyValuePair> {
        Single
            .zip(cryptoCurrencyService.cryptoCurrency,
                 fiatCurrencyService.fiatCurrency)
            .flatMap(weak: self) { (self, currencies) -> Single<MoneyValuePair> in
                let (cryptoCurrency, fiatCurrency) = currencies
                return self.priceProvider
                    .pairFromCryptoInput(
                        cryptoCurrency: cryptoCurrency,
                        fiatCurrency: fiatCurrency,
                        amount: amount
                    )
            }
    }
}

extension AmountTranslationInteractor.State {
    internal var toValidationState: ValidationState {
        switch self {
        case .inBounds:
            return .valid
        case .empty,
             .maxLimitExceeded,
             .minLimitExceeded,
             .warning,
             .error:
            return .invalid
        }
    }
}
