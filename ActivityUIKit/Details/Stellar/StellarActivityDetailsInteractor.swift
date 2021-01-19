//
//  StellarActivityDetailsInteractor.swift
//  Blockchain
//
//  Created by Paulo on 19/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import EthereumKit
import PlatformKit
import RxSwift
import StellarKit

final class StellarActivityDetailsInteractor {
    
    // MARK: - Private Properties

    private let fiatCurrencySettings: FiatCurrencySettingsServiceAPI
    private let priceService: PriceServiceAPI
    private let detailsService: AnyActivityItemEventDetailsFetcher<StellarActivityItemEventDetails>
    
    // MARK: - Init

    init(fiatCurrencySettings: FiatCurrencySettingsServiceAPI = resolve(),
         priceService: PriceServiceAPI = resolve(),
         detailsService: AnyActivityItemEventDetailsFetcher<StellarActivityItemEventDetails> = resolve()) {
        self.fiatCurrencySettings = fiatCurrencySettings
        self.priceService = priceService
        self.detailsService = detailsService
    }
    
    // MARK: - Public Functions

    func details(identifier: String, createdAt: Date) -> Observable<StellarActivityDetailsViewModel> {
        let transaction = detailsService
            .details(for: identifier)
        let price = self.price(at: createdAt)
            .optional()
            .catchErrorJustReturn(nil)

        return Observable
            .combineLatest(
                transaction,
                price.asObservable()
            )
            .map { StellarActivityDetailsViewModel(with: $0, price: $1?.moneyValue.fiatValue) }
    }
    
    // MARK: - Private Functions
    
    private func price(at date: Date) -> Single<PriceQuoteAtTime> {
        fiatCurrencySettings
            .fiatCurrency
            .flatMap(weak: self) { (self, fiatCurrency) in
                self.price(at: date, in: fiatCurrency)
            }
    }

    private func price(at date: Date, in fiatCurrency: FiatCurrency) -> Single<PriceQuoteAtTime> {
        priceService.price(
            for: CurrencyType.crypto(CryptoCurrency.stellar),
            in: fiatCurrency,
            at: date
        )
    }
}
