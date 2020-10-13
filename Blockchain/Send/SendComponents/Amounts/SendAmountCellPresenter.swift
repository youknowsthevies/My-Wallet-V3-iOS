//
//  SendAmountCellPresenter.swift
//  Blockchain
//
//  Created by Daniel Huri on 06/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxCocoa
import RxRelay
import RxSwift

/// The presentation layer for the amount component on send screen
final class SendAmountCellPresenter {

    /// The currently edited amount field
    private enum CurrentlyUpdatedField {
        case crypto
        case fiat
        case none
    }
    
    // MARK: - Properties
    
    let cryptoName: String
    var fiatName: Driver<String> {
        fiatNameRelay.asDriver()
    }
    
    let cryptoPlaceholder = "0.00"
    let fiatPlaceholder = "0.00"

    /// The crypto value as string
    var cryptoValue: Driver<String> {
        cryptoValueRelay.asDriver()
    }
    
    /// The fiat value as string
    var fiatValue: Driver<String> {
       fiatValueRelay.asDriver()
    }
    
    /// Total fiat: amount + fee
    var totalFiat: Observable<String> {
        interactor.total
            .map { $0.quote.toDisplayString(includeSymbol: true) }
    }
    
    /// Total crypto: amount + fee
    var totalCrypto: Observable<String> {
        interactor.total
            .map { $0.base.toDisplayString(includeSymbol: true) }
    }
    
    private var currentlyUpdatedField = CurrentlyUpdatedField.none

    private let fiatNameRelay = BehaviorRelay<String>(value: "")
    private let cryptoValueRelay = BehaviorRelay<String>(value: "")
    private let fiatValueRelay = BehaviorRelay<String>(value: "")
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Services
    
    let spendableBalancePresenter: SendSpendableBalanceViewPresenter

    private let interactor: SendAmountInteracting
    private let fiatCurrencyService: FiatCurrencySettingsServiceAPI
    
    // MARK: - Setup
    
    init(spendableBalancePresenter: SendSpendableBalanceViewPresenter,
         interactor: SendAmountInteracting,
         fiatCurrencyService: FiatCurrencySettingsServiceAPI = resolve()) {
        self.spendableBalancePresenter = spendableBalancePresenter
        self.interactor = interactor
        self.fiatCurrencyService = fiatCurrencyService
        cryptoName = interactor.asset.displayCode
        
        fiatCurrencyService.fiatCurrencyObservable
            .map { $0.code }
            .bindAndCatch(to: fiatNameRelay)
            .disposed(by: disposeBag)
        
        // Bind taps on max spendable amount to crypto
        spendableBalancePresenter.spendableBalanceTap
            .map { $0.base }
            .map { $0.toDisplayString(includeSymbol: false) }
            .bindAndCatch(to: cryptoValueRelay)
            .disposed(by: disposeBag)
        
        // Bind taps on max spendable amount to fiat
        spendableBalancePresenter.spendableBalanceTap
            .map { $0.quote }
            .map { $0.toDisplayString(includeSymbol: false) }
            .bindAndCatch(to: fiatValueRelay)
            .disposed(by: disposeBag)
        
        let asset = interactor.asset
        
        let fiatCurrencyChange = fiatCurrencyService.fiatCurrencyObservable
            .do(onNext: { [weak self] _ in
                self?.clean()
            })
        
        let transferredValue = Observable
            .combineLatest(interactor.calculationState, fiatCurrencyChange)
            .map { (state, fiatCurrency) -> MoneyValuePair in
                if let value = state.value {
                    return value
                } else {
                    return .zero(
                        baseCurrency: asset.currency,
                        quoteCurrency: fiatCurrency.currency
                    )
                }
            }
            .share(replay: 1)

        transferredValue
            .filter { [weak self] value -> Bool in
                self?.currentlyUpdatedField == .fiat
            }
            .do(onNext: { [weak self] _ in
                self?.currentlyUpdatedField = .none
            })
            .map { $0.base }
            .map { $0.amount > 0 ? $0.toDisplayString(includeSymbol: false) : "" }
            .bindAndCatch(to: cryptoValueRelay)
            .disposed(by: disposeBag)
        
        transferredValue
            .filter { [weak self] value -> Bool in
                self?.currentlyUpdatedField == .crypto
            }
            .do(onNext: { [weak self] _ in
                self?.currentlyUpdatedField = .none
            })
            .map { $0.quote }
            .map { $0.amount > 0 ? $0.toDisplayString(includeSymbol: false) : "" }
            .bindAndCatch(to: fiatValueRelay)
            .disposed(by: disposeBag)
    }
    
    /// Called upon once the crypto field was edited / updated.
    /// - Parameter rawValue: A raw value in major format.
    /// - Parameter shouldPublish: A boolean indication of whether the update should be
    /// reflected back to the UI layer. i.e scanned QR code that contains amounts should
    /// be shown in the crypto amount field.
    func cryptoFieldEdited(rawValue: String, shouldPublish: Bool = false) {
        currentlyUpdatedField = .crypto
        interactor.recalculateAmounts(fromCrypto: rawValue)
        
        if shouldPublish {
            cryptoValueRelay.accept(rawValue)
        }
    }

    /// Called upon once the fiat field was edited / updated.
    /// - Parameter rawValue: A raw value in standard format (`1.0` or `1` to represent $1)
    /// - Parameter shouldPublish: A boolean indication of whether the update should be
    /// reflected back to the UI layer. i.e scanned QR code that contains amounts should
    /// be shown in the fiat amount field.
    func fiatFieldEdited(rawValue: String, shouldPublish: Bool = false) {
        currentlyUpdatedField = .fiat
        interactor.recalculateAmounts(fromFiat: rawValue)
        
        if shouldPublish {
            fiatValueRelay.accept(rawValue)
        }
    }
    
    /// Performs cleaning of the amounts.
    /// Publishes the new state so that it will be reflected in the UI layer
    func clean() {
        cryptoFieldEdited(rawValue: "", shouldPublish: true)
        fiatFieldEdited(rawValue: "", shouldPublish: true)
    }
}
