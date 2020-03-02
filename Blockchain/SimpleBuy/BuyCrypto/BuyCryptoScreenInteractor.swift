//
//  BuyCryptoScreenInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 23/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformKit
import PlatformUIKit

final class BuyCryptoScreenInteractor {

    // MARK: - Types
    
    enum KYCState {
        case completed
        case shouldComplete
    }
    
    enum State {
        case inBounds(data: SimpleBuyCheckoutData, upperLimit: FiatValue)
        case tooLow(min: FiatValue)
        case tooHigh(max: FiatValue)
        case empty
        
        var isValid: Bool {
            switch self {
            case .inBounds:
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
    
    /// MARK: - Input Properties (writable)

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
    var data: Observable<SimpleBuyCheckoutData?> {
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
    
    /// MARK: - Output (readable)
    
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
    
    /// Streams a boolean indicating shether yhe user should complete KYC
    var currentKycState: Single<Result<KYCState, Error>> {
        kycTiersService.fetchTiers()
            .map { $0.isTier2Approved }
            .mapToResult(successMap: { $0 ? .completed : .shouldComplete })
    }
        
    // MARK: - Injected
    
    let fiatCurrencyService: FiatCurrencySettingsServiceAPI
    private let kycTiersService: KYCTiersServiceAPI
    private let suggestedAmountsService: SimpleBuySuggestedAmountsServiceAPI
    private let pairsService: SimpleBuySupportedPairsInteractorServiceAPI
    private let cryptoCurrencySelectionService: SelectionServiceAPI
    
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
    private let stateRelay = BehaviorRelay<State>(value: .empty)
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(kycTiersService: KYCTiersServiceAPI,
         fiatCurrencyService: FiatCurrencySettingsServiceAPI,
         pairsService: SimpleBuySupportedPairsInteractorServiceAPI,
         cryptoCurrencySelectionService: SelectionServiceAPI,
         suggestedAmountsService: SimpleBuySuggestedAmountsServiceAPI) {
        self.kycTiersService = kycTiersService
        self.fiatCurrencyService = fiatCurrencyService
        self.pairsService = pairsService
        self.suggestedAmountsService = suggestedAmountsService
        self.cryptoCurrencySelectionService = cryptoCurrencySelectionService
        
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
            .map { (pairs, item) -> SimpleBuySupportedPairs.Pair? in
                pairs.pairs(per: item.cryptoCurrency).first
            }
        
        Observable
            .combineLatest(
                currentAmountRelay,
                pairForCryptoCurrency
            )
            .map { (amount, pair) -> State in
                /// There must be a pair to compare to before calculation begins
                guard let pair = pair, pair.fiatCurrency == amount.currency else {
                    return .empty
                }
                
                if amount.amount.isZero {
                    return .empty
                } else if try amount > pair.maxFiatValue {
                    return .tooHigh(max: pair.maxFiatValue)
                } else if try amount < pair.minFiatValue {
                    return .tooLow(min: pair.minFiatValue)
                }
                let data = SimpleBuyCheckoutData(fiatValue: amount, cryptoCurrency: pair.cryptoCurrency)
                
                return .inBounds(data: data, upperLimit: pair.maxFiatValue)
            }
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
    }
    
    /// Triggers a refresh
    func refresh() {
        suggestedAmountsService.refresh()
    }
}

fileprivate extension SelectionItemViewModel {
    
    var cryptoCurrency: CryptoCurrency {
        CryptoCurrency(rawValue: id)!
    }
}
