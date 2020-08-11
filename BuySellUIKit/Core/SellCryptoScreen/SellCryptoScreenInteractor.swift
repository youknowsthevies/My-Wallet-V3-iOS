//
//  SellCryptoScreenInteractor.swift
//  BuySellUIKit
//
//  Created by Daniel on 05/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxSwift
import RxRelay

public struct SellCryptoInteractionData {

    // TODO: Daniel - Remove and replac with a real account
    struct AnyAccount {
        let id: String
        let currencyType: CurrencyType
    }
    
    let source: AnyAccount
    let destination: AnyAccount
}

final class SellCryptoScreenInteractor: EnterAmountScreenInteractor {

    // MARK: - Types
    
    enum State {
        case inBounds
        case tooHigh(max: MoneyValue)
        case empty
                
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
    
    override var selectedCurrencyType: Observable<CurrencyType> {
        .just(data.source.currencyType)
    }
    
    override var hasValidState: Observable<Bool> {
        stateRelay.map { $0.isValid }
    }
    
    var state: Observable<State> {
        stateRelay.asObservable()
    }

    // MARK: - Interactors
    
    let auxiliaryViewInteractor: SendAuxililaryViewInteractor
    
    // MARK: - Injected
    
    let data: SellCryptoInteractionData
    private let balanceProvider: BalanceProviding
    
    // MARK: - Accessors
    
    private let stateRelay: BehaviorRelay<State>
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(data: SellCryptoInteractionData,
         exchangeProvider: ExchangeProviding,
         balanceProvider: BalanceProviding,
         fiatCurrencyService: FiatCurrencyServiceAPI,
         cryptoCurrencySelectionService: CryptoCurrencyServiceAPI & SelectionServiceAPI,
         initialActiveInput: ActiveAmountInput) {
        self.data = data
        self.balanceProvider = balanceProvider
        stateRelay = BehaviorRelay(value: .empty)
        auxiliaryViewInteractor = SendAuxililaryViewInteractor(
            balanceProvider: balanceProvider,
            currencyType: data.source.currencyType
        )
                
        super.init(
            exchangeProvider: exchangeProvider,
            fiatCurrencyService: fiatCurrencyService,
            cryptoCurrencySelectionService: cryptoCurrencySelectionService,
            initialActiveInput: initialActiveInput
        )
    }
    
    override func didLoad() {
        let sourceAccount = self.data.source
        let sourceAccountCurrency = sourceAccount.currencyType.currency
        let exchangeProvider = self.exchangeProvider
        let amountTranslationInteractor = self.amountTranslationInteractor

        let balance = balanceProvider[sourceAccountCurrency]
            .calculationState
            .compactMap { state -> MoneyValuePair? in
                switch state {
                case .value(let pairs):
                    return pairs[.custodial(.trading)]
                case .calculating, .invalid:
                    return nil
                }
            }
            .share(replay: 1)

        auxiliaryViewInteractor.resetToMaxAmount
            .withLatestFrom(balance)
            .map { $0.quote }
            .map { $0.isZero ? .empty : .inBounds }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    
        Observable
            .combineLatest(
                amountTranslationInteractor.fiatAmount,
                balance,
                fiatCurrencyService.fiatCurrencyObservable
            )
            .map { (amount, balance, fiatCurrency) -> State in
                guard !amount.isZero else {
                    return .empty
                }
                guard try amount <= balance.quote else {
                    return .tooHigh(max: balance.quote)
                }
                return .inBounds
            }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
        
        state
            .flatMapLatest { state -> Observable<AmountTranslationInteractor.State> in
                amountTranslationInteractor.activeInputRelay.take(1).asSingle()
                    .flatMap { activeInput -> Single<AmountTranslationInteractor.State> in
                        switch state {
                        case .tooHigh(max: let moneyValue):
                            return exchangeProvider[sourceAccountCurrency].fiatPrice
                                .take(1)
                                .asSingle()
                                 .map { exchangeRate -> MoneyValuePair in
                                    MoneyValuePair(
                                        fiat: moneyValue.fiatValue!,
                                        priceInFiat: exchangeRate,
                                        cryptoCurrency: sourceAccountCurrency.cryptoCurrency!,
                                        usesFiatAsBase: activeInput == .fiat
                                    )
                                 }
                                .map { pair -> AmountTranslationInteractor.State in
                                    switch state {
                                    case .tooHigh:
                                        return .maxLimitExceeded(pair)
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
    }
}
