//
//  EnterAmountScreenInteractor.swift
//  PlatformUIKit
//
//  Created by Daniel on 04/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit

/// API for interaction of enter amount screen
public protocol EnterAmountScreenInteractorAPI: AnyObject {
    var hasValidState: Observable<Bool> { get }
    var selectedCryptoCurrency: Observable<CryptoCurrency> { get }
    func didLoad()
}

open class EnterAmountScreenInteractor: Interactor {
    
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
