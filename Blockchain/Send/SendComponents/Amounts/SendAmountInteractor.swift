//
//  SendAmountInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 06/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import RxCocoa
import RxRelay
import RxSwift

/// The interaction layer for sent amount on the send screen
final class SendAmountInteractor: SendAmountInteracting {

    // MARK: - Exposed Properties
    
    /// The amount calculation state.
    /// This state may being indicating of `.calculating`, `.invalid`, `.value`
    var calculationState: Observable<MoneyValuePairCalculationState> {
        _ = setup
        return calculationStateRelay.asObservable()
    }
    
    /// Streams `.withinSpendableBalance` if the amount + fee is within the spendable balance.
    /// Streams `.aboveSpendableBalance` if the amount + fee is above the spendable balance.
    /// Always starts with `.withinSpendableBalance`.
    var amountBalanceRatio: Observable<AmountBalanceRatio> {
        _ = setup
        let amount = calculationState
            .map { [weak self] state -> CryptoValue? in
                guard let self = self else { return nil }
                return state.value?.base.cryptoValue ?? CryptoValue.zero(currency: self.asset)
            }
            .compactMap { $0 }
        let spendableBalance = spendableBalanceInteractor.balance
            .map { $0.base.cryptoValue! }
        return Observable
            .combineLatest(amount, spendableBalance)
            .map { (amount, spendableBalance) -> AmountBalanceRatio in
                do {
                    return try amount <= spendableBalance ? .withinSpendableBalance : .aboveSpendableBalance
                } catch { // Must NOT reach here
                    return .aboveSpendableBalance
                }
            }
            .startWith(.withinSpendableBalance)
            .share()
    }

    /// Streams the total of amount + fee represented as both fiat and crypto.
    var total: Observable<MoneyValuePair> {
        _ = setup
        let amount = calculationState
            .compactMap { $0.value }
        let fee = feeInteractor.calculationState
            .compactMap { $0.value }
        return Observable
            .combineLatest(amount, fee)
            .map { amount, fee -> MoneyValuePair in
                try amount + fee
            }
    }
    
    // MARK: - Injected
    
    let asset: CryptoCurrency
    let spendableBalanceInteractor: SendSpendableBalanceInteracting

    private lazy var setup: Void = {
        setupFiatUpdates()
        setupCryptoUpdates()
    }()
    
    private let feeInteractor: SendFeeInteracting
    private let exchangeService: PairExchangeServiceAPI
    private let fiatCurrencyService: FiatCurrencySettingsServiceAPI
    
    // MARK: - Accessors
    
    private let calculationStateRelay = BehaviorRelay<MoneyValuePairCalculationState>(value: .invalid(.empty))
    private let disposeBag = DisposeBag()
    
    private let latestFiatRelay = PublishRelay<String>()
    private let latestCryptoRelay = PublishRelay<String>()

    // MARK: - Setup
    
    init(asset: CryptoCurrency,
         spendableBalanceInteractor: SendSpendableBalanceInteracting,
         feeInteractor: SendFeeInteracting,
         exchangeService: PairExchangeServiceAPI,
         fiatCurrencyService: FiatCurrencySettingsServiceAPI) {
        self.asset = asset
        self.spendableBalanceInteractor = spendableBalanceInteractor
        self.feeInteractor = feeInteractor
        self.exchangeService = exchangeService
        self.fiatCurrencyService = fiatCurrencyService
    }
    
    private func setupCryptoUpdates() {
        let asset = self.asset
        let currentCrypto = latestCryptoRelay
            .map { $0.isEmpty ? "0" : $0 }
            .map { CryptoValue.create(majorDisplay: $0, currency: asset) }
        
        currentCrypto
            .filter { $0 == nil }
            .bind { [weak self] _ in
                self?.calculationStateRelay.accept(.invalid(.empty))
            }
            .disposed(by: disposeBag)
        
        let unwrappedCrypto = currentCrypto
            .compactMap { $0 }

        Observable
            .combineLatest(unwrappedCrypto, exchangeService.fiatPrice)
            .map { MoneyValuePair(base: $0.0, exchangeRate: $0.1) }
            .map { $0.isZero ? .invalid(.empty) : .value($0) }
            .catchErrorJustReturn(.calculating)
            .bindAndCatch(to: calculationStateRelay)
            .disposed(by: disposeBag)
    }
    
    private func setupFiatUpdates() {
        let asset = self.asset

        let latestFiat = latestFiatRelay
            .map { $0.isEmpty ? "0" : $0 }
        
        // Observe fiat price by combining the latest fiat amount, currency code, and exchange rate
        let currentFiat = Observable
            .combineLatest(latestFiat, fiatCurrencyService.fiatCurrencyObservable)
            .map { (amount, currency) -> FiatValue in
                FiatValue.create(major: amount, currency: currency)!
            }
        
        Observable
            .combineLatest(currentFiat, exchangeService.fiatPrice)
            .map { MoneyValuePair(fiat: $0, priceInFiat: $1, cryptoCurrency: asset, usesFiatAsBase: false) }
            .map { $0.isZero ? .invalid(.empty) : .value($0) }
            .catchErrorJustReturn(.invalid(.valueCouldNotBeCalculated))
            .bindAndCatch(to: calculationStateRelay)
            .disposed(by: disposeBag)
    }
    
    /// Recalculates amounts from crypto raw value
    func recalculateAmounts(fromCrypto rawValue: String) {
        latestCryptoRelay.accept(rawValue)
    }
    
    /// Recalculates amounts from fiat raw value
    func recalculateAmounts(fromFiat rawValue: String) {
        latestFiatRelay.accept(rawValue)
    }
}
