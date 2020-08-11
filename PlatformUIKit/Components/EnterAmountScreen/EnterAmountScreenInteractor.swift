//
//  EnterAmountScreenInteractor.swift
//  PlatformUIKit
//
//  Created by Daniel on 04/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit
import ToolKit

/// API for interaction of enter amount screen
public protocol EnterAmountScreenInteractorAPI: AnyObject {
    var hasValidState: Observable<Bool> { get }
    var selectedCurrencyType: Observable<CurrencyType> { get }
    func didLoad()
}

open class EnterAmountScreenInteractor: Interactor, EnterAmountScreenInteractorAPI {
    
    /// Must be implemented - decides whether the interactor has a valid state.
    /// if streams `true`, then the CTA button would become enabled.
    /// `super.hasValidState` must not be called by the subclass.
    open var hasValidState: Observable<Bool> {
        unimplemented()
    }

    /// Must be implemented - selected currency
    /// `super.selectedCryptoCurrency` must not be called by the subclass.
    open var selectedCurrencyType: Observable<CurrencyType> {
        unimplemented()
    }

    /// Any one time initialization performed when the bound view controller appears.
    /// `super.didLoad` must not be called by the subclass.
    open func didLoad() {
        unimplemented()
    }
    
    // MARK: - Injected
    
    public let exchangeProvider: ExchangeProviding
    public let fiatCurrencyService: FiatCurrencyServiceAPI
    public let cryptoCurrencySelectionService: SelectionServiceAPI & CryptoCurrencyServiceAPI

    // MARK: - Interactors
    
    /// Amount translation interactor
    public let amountTranslationInteractor: AmountTranslationInteractor
    
    public init(exchangeProvider: ExchangeProviding,
                fiatCurrencyService: FiatCurrencyServiceAPI,
                cryptoCurrencySelectionService: SelectionServiceAPI & CryptoCurrencyServiceAPI,
                initialActiveInput: ActiveAmountInput) {
        self.exchangeProvider = exchangeProvider
        self.fiatCurrencyService = fiatCurrencyService
        self.cryptoCurrencySelectionService = cryptoCurrencySelectionService
        
        amountTranslationInteractor = AmountTranslationInteractor(
            fiatCurrencyService: fiatCurrencyService,
            cryptoCurrencyService: cryptoCurrencySelectionService,
            exchangeProvider: exchangeProvider,
            initialActiveInput: initialActiveInput
        )
    }
}
