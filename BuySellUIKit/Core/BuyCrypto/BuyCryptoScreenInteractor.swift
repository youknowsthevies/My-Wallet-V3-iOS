//
//  BuyCryptoScreenInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 23/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

final class BuyCryptoScreenInteractor {

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
               
    private enum Constant {
        static var defaultFiatCurrency: FiatCurrency { FiatCurrency.USD }
        static var defaultCryptoCurrency: CryptoCurrency { CryptoCurrency.bitcoin }
    }
        
    // MARK: - Input Properties (writable)

    /// Input scanner - scans each digit and map it into
    /// a valid fiat number
    let inputScanner = MoneyValueInputScanner(maxFractionDigits: 2, maxIntegerDigits: 10)
    
    /// Exposes a stream of the currently selected `CryptoCurrency` value
    var selectedCryptoCurrency: Observable<CryptoCurrency> {
        cryptoCurrencySelectionService.selectedData.map { $0.cryptoCurrency }.asObservable()
    }
    
    /// The state of the screen with associated data
    var state: Observable<State> {
        stateRelay.asObservable()
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
    
    /// Streams the amount as `FiatValue`
    var amount: Observable<FiatValue> {
        currentAmountRelay.asObservable()
    }
        
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
        paymentMethodTypesService.methodTypes
    }
    
    var preferredPaymentMethodType: Observable<PaymentMethodType?> {
        paymentMethodTypesService.preferredPaymentMethodType
    }
    
    // MARK: - Injected
    
    let fiatCurrencyService: FiatCurrencySettingsServiceAPI
    let exchangeProvider: ExchangeProviding
    
    private let kycTiersService: KYCTiersServiceAPI
    private let suggestedAmountsService: SuggestedAmountsServiceAPI
    private let pairsService: SupportedPairsInteractorServiceAPI
    private let cryptoCurrencySelectionService: SelectionServiceAPI
    private let eligibilityService: EligibilityServiceAPI
    private let paymentMethodTypesService: PaymentMethodTypesServiceAPI
    private let orderCreationService: OrderCreationServiceAPI

    // MARK: - Accessors
    
    private let suggestedAmountsRelay = BehaviorRelay<[FiatValue]>(value: [])
    
    /// The fiat-crypto pairs
    private let pairsCalculationStateRelay = BehaviorRelay<BuyCryptoSupportedPairsCalculationState>(
        value: .invalid(.empty)
    )
    
    /// The current amount as `FiatValue`
    private let currentAmountRelay = BehaviorRelay<FiatValue>(
        value: .zero(currency: Constant.defaultFiatCurrency)
    )
    
    /// The state of the screen
    private let stateRelay = BehaviorRelay<State>(value: .empty(currency: Constant.defaultFiatCurrency))
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(kycTiersService: KYCTiersServiceAPI,
         exchangeProvider: ExchangeProviding,
         fiatCurrencyService: FiatCurrencySettingsServiceAPI,
         pairsService: SupportedPairsInteractorServiceAPI,
         eligibilityService: EligibilityServiceAPI,
         paymentMethodTypesService: PaymentMethodTypesServiceAPI,
         cryptoCurrencySelectionService: SelectionServiceAPI,
         orderCreationService: OrderCreationServiceAPI,
         suggestedAmountsService: SuggestedAmountsServiceAPI) {
        self.kycTiersService = kycTiersService
        self.fiatCurrencyService = fiatCurrencyService
        self.pairsService = pairsService
        self.suggestedAmountsService = suggestedAmountsService
        self.cryptoCurrencySelectionService = cryptoCurrencySelectionService
        self.eligibilityService = eligibilityService
        self.paymentMethodTypesService = paymentMethodTypesService
        self.orderCreationService = orderCreationService
        self.exchangeProvider = exchangeProvider
        
        suggestedAmountsService.calculationState
            .compactMap { $0.value }
            .bind(to: suggestedAmountsRelay)
            .disposed(by: disposeBag)
        
        pairsService.fetch()
            .map { .value($0) }
            .catchErrorJustReturn(.invalid(.valueCouldNotBeCalculated))
            .startWith(.invalid(.empty))
            .bind(to: pairsCalculationStateRelay)
            .disposed(by: disposeBag)

        Observable
            .combineLatest(
                fiatCurrencyService.fiatCurrencyObservable,
                inputScanner.inputRelay
            )
            .map { (fiatCurrency, input) -> FiatValue in
                FiatValue.create(
                    amountString: input.string,
                    currency: fiatCurrency
                )
            }
            .bind(to: currentAmountRelay)
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
                currentAmountRelay,
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
                case .suggested(let method):
                    guard method.max.currency == pair.maxFiatValue.currency else {
                        return .empty(currency: currency)
                    }
                    maxFiatValue = try FiatValue.min(pair.maxFiatValue, method.max)
                    paymentMethodId = nil
                }
                
                guard minFiatValue.currency == amount.currency && maxFiatValue.currency == amount.currency else {
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
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
    }
    
    /// Triggers a refresh
    func refresh() {
        suggestedAmountsService.refresh()
    }
    
    func createOrder(from candidate: CandidateOrderDetails) -> Single<CheckoutData> {
        orderCreationService.create(using: candidate)
    }
}

fileprivate extension SelectionItemViewModel {
    
    var cryptoCurrency: CryptoCurrency {
        CryptoCurrency(code: id)!
    }
}
