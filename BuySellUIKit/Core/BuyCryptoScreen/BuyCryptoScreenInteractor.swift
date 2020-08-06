//
//  EnterAmountScreenInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 23/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import PlatformKit
import PlatformUIKit
import ToolKit
import RxRelay
import RxSwift

final class BuyCryptoScreenInteractor: EnterAmountScreenInteractor {

    // MARK: - Types
    
    enum State {
        case inBounds(data: CandidateOrderDetails, upperLimit: FiatValue)
        case tooLow(min: FiatValue)
        case tooHigh(max: FiatValue)
        case empty(currency: FiatCurrency)
                
        var isValid: Bool {
            switch self {
            case .inBounds:
                return true
            default:
                return false
            }
        }
        
        var isEmpty: Bool {
            switch self {
            case .empty:
                return true
            default:
                return false
            }
        }
    }
    
    // MARK: - Properties

    /// Exposes a stream of the currently selected `CryptoCurrency` value
    public override var selectedCryptoCurrency: Observable<CryptoCurrency> {
        cryptoCurrencySelectionService.selectedData.map { $0.cryptoCurrency }.asObservable()
    }
    
    /// The state of the screen with associated data
    var state: Observable<State> {
        stateRelay.asObservable()
    }
    
    /// Whether the state of the screen is valid
    public override var hasValidState: Observable<Bool> {
        state.map { $0.isValid }
    }
    
    /// The (optional) data, in case the state's value is `inBounds`.
    /// `nil` otherwise.
    var candidateOrderDetails: Observable<CandidateOrderDetails?> {
        state
            .map { state in
                switch state {
                case .inBounds(data: let data, upperLimit: _):
                    return data
                default:
                    return nil
                }
            }
    }
    
    // MARK: - Output (readable)
            
    /// Calculation state of the supported pairs
    var pairsCalculationState: Observable<BuyCryptoSupportedPairsCalculationState> {
        pairsCalculationStateRelay.asObservable()
    }
                
    /// Suggested amounts, each represented a `Decimal value`
    var suggestedAmounts: Observable<[FiatValue]> {
        suggestedAmountsRelay.asObservable()
    }

    /// Streams a `KycState` indicating whether the user should complete KYC
    var currentKycState: Single<Result<KycState, Error>> {
        kycTiersService.fetchTiers()
            .map { $0.isTier2Approved }
            .mapToResult(successMap: { $0 ? .completed : .shouldComplete })
    }

    /// Streams a boolean indicating whether the user is eligible to Simple Buy
    var currentEligibilityState: Observable<Result<Bool, Error>> {
        eligibilityService
            .fetch()
            .mapToResult()
    }

    var paymentMethodTypes: Observable<[PaymentMethodType]> {
        Observable
            .combineLatest(
                paymentMethodTypesService.methodTypes,
                fiatCurrencyService.fiatCurrencyObservable
            )
            .map { payload in
                let (methods, fiatCurrency) = payload
                return methods.filterValidForBuy(currentWalletCurrency: fiatCurrency)
            }
            .catchErrorJustReturn([])
    }
    
    var preferredPaymentMethodType: Observable<PaymentMethodType?> {
        paymentMethodTypesService.preferredPaymentMethodType
    }
    
    // MARK: - Dependencies
        
    private let kycTiersService: KYCTiersServiceAPI
    private let suggestedAmountsService: SuggestedAmountsServiceAPI
    private let pairsService: SupportedPairsInteractorServiceAPI
    private let eligibilityService: EligibilityServiceAPI
    private let paymentMethodTypesService: PaymentMethodTypesServiceAPI
    private let orderCreationService: OrderCreationServiceAPI

    // MARK: - Accessors
    
    private let suggestedAmountsRelay = BehaviorRelay<[FiatValue]>(value: [])
    
    /// The fiat-crypto pairs
    private let pairsCalculationStateRelay = BehaviorRelay<BuyCryptoSupportedPairsCalculationState>(
        value: .invalid(.empty)
    )
    
    /// The state of the screen
    private let stateRelay = BehaviorRelay<State>(value: .empty(currency: FiatCurrency.default))
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(kycTiersService: KYCTiersServiceAPI,
         exchangeProvider: ExchangeProviding,
         fiatCurrencyService: FiatCurrencyServiceAPI,
         cryptoCurrencySelectionService: SelectionServiceAPI & CryptoCurrencyServiceAPI,
         pairsService: SupportedPairsInteractorServiceAPI,
         eligibilityService: EligibilityServiceAPI,
         paymentMethodTypesService: PaymentMethodTypesServiceAPI,
         orderCreationService: OrderCreationServiceAPI,
         suggestedAmountsService: SuggestedAmountsServiceAPI) {
        self.kycTiersService = kycTiersService
        self.pairsService = pairsService
        self.suggestedAmountsService = suggestedAmountsService
        self.eligibilityService = eligibilityService
        self.paymentMethodTypesService = paymentMethodTypesService
        self.orderCreationService = orderCreationService
        super.init(
            exchangeProvider: exchangeProvider,
            fiatCurrencyService: fiatCurrencyService,
            cryptoCurrencySelectionService: cryptoCurrencySelectionService,
            initialActiveInput: .fiat
        )
    }
    
    // MARK: - Interactor
    
    public override func didLoad() {
        let exchangeProvider = self.exchangeProvider
        let cryptoCurrencySelectionService = self.cryptoCurrencySelectionService
        let fiatCurrencyService = self.fiatCurrencyService
        
        state
            .flatMapLatest(weak: self) { (self, state) -> Observable<AmountTranslationInteractor.State> in
                Single
                    .zip(
                        self.amountTranslationInteractor.activeInputRelay.take(1).asSingle(),
                        cryptoCurrencySelectionService.cryptoCurrency
                    )
                    .flatMap { (activeInput, currency) -> Single<AmountTranslationInteractor.State> in
                        switch state {
                        case .tooHigh(max: let fiatValue), .tooLow(min: let fiatValue):
                            return exchangeProvider[currency].fiatPrice
                                .take(1)
                                .asSingle()
                                 .map { exchangeRate -> MoneyValuePair in
                                    MoneyValuePair(
                                        fiat: fiatValue,
                                        priceInFiat: exchangeRate,
                                        cryptoCurrency: currency,
                                        usesFiatAsBase: activeInput == .fiat
                                    )
                                 }
                                .map { pair -> AmountTranslationInteractor.State in
                                    switch state {
                                    case .tooHigh:
                                        return .maxLimitExceeded(pair)
                                    case .tooLow:
                                        return .minLimitExceeded(pair)
                                    case .empty:
                                        return .empty
                                    case .inBounds:
                                        return .inBounds
                                    }
                                }
                        case .empty:
                            return .just(.empty)
                        case .inBounds:
                            return .just(.inBounds)
                        }
                    }
                    .asObservable()
            }
            .bindAndCatch(to: amountTranslationInteractor.stateRelay)
            .disposed(by: disposeBag)
        
        suggestedAmountsService.calculationState
            .compactMap { $0.value }
            .bindAndCatch(to: suggestedAmountsRelay)
            .disposed(by: disposeBag)
        
        pairsService.fetch()
            .map { .value($0) }
            .catchErrorJustReturn(.invalid(.valueCouldNotBeCalculated))
            .startWith(.invalid(.empty))
            .bindAndCatch(to: pairsCalculationStateRelay)
            .disposed(by: disposeBag)
        
        let pairs = pairsCalculationState
            .compactMap { $0.value }
        
        let pairForCryptoCurrency = Observable
            .combineLatest(
                pairs,
                cryptoCurrencySelectionService.selectedData
            )
            .map { (pairs, item) -> SupportedPairs.Pair? in
                pairs.pairs(per: item.cryptoCurrency).first
            }
        
        let preferredPaymentMethod = self.preferredPaymentMethodType
            .compactMap { $0 }
        
        Observable
            .combineLatest(
                preferredPaymentMethod,
                amountTranslationInteractor.fiatAmount.compactMap { $0.fiatValue },
                pairForCryptoCurrency,
                fiatCurrencyService.fiatCurrencyObservable
            )
            .map { (preferredPaymentMethod, amount, pair, currency) -> State in
                
                /// There must be a pair to compare to before calculation begins
                guard let pair = pair else {
                    return .empty(currency: currency)
                }
                
                let minFiatValue = pair.minFiatValue
                let maxFiatValue: FiatValue
                let paymentMethodId: String?
                
                switch preferredPaymentMethod {
                case .card(let cardData):
                    maxFiatValue = cardData.topLimit
                    paymentMethodId = cardData.identifier
                case .account(let data):
                    let maxQuoteFiatValue = data.balance.quote.fiatValue!
                    // Quote must be a fiat value
                    if try maxQuoteFiatValue < data.topLimit {
                        maxFiatValue = maxQuoteFiatValue
                    } else {
                        maxFiatValue = data.topLimit
                    }
                    paymentMethodId = nil
                case .suggested(let method):
                    guard method.max.currency == pair.maxFiatValue.currency else {
                        return .empty(currency: currency)
                    }
                    maxFiatValue = try FiatValue.min(pair.maxFiatValue, method.max)
                    paymentMethodId = nil
                }
                
                guard amount.currencyType == minFiatValue.currencyType && amount.currencyType == maxFiatValue.currencyType else {
                    return .empty(currency: currency)
                }
                
                if amount.amount.isZero {
                    return .empty(currency: currency)
                } else if try amount > maxFiatValue {
                    return .tooHigh(max: maxFiatValue)
                } else if try amount < minFiatValue {
                    return .tooLow(min: minFiatValue)
                }
                let data = CandidateOrderDetails(
                    paymentMethod: preferredPaymentMethod,
                    fiatValue: amount,
                    cryptoCurrency: pair.cryptoCurrency,
                    paymentMethodId: paymentMethodId
                )
                
                return .inBounds(data: data, upperLimit: pair.maxFiatValue)
            }
            // Handle posssible errors: it is unlikely to get here unless
            // there was a connection / BE error
            .catchError { _ in
                fiatCurrencyService.fiatCurrencyObservable
                    .take(1)
                    .map { .empty(currency: $0) }
            }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
        
        suggestedAmountsService.refresh()
    }

    // MARK: - Actions
    
    func createOrder(from candidate: CandidateOrderDetails) -> Single<CheckoutData> {
        orderCreationService.create(using: candidate)
    }
}

fileprivate extension SelectionItemViewModel {
    
    var cryptoCurrency: CryptoCurrency {
        CryptoCurrency(code: id)!
    }
}
