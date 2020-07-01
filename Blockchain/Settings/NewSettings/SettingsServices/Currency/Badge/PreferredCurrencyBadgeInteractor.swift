//
//  PreferredCurrencyBadgeInteractor.swift
//  Blockchain
//
//  Created by AlexM on 12/19/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

final class PreferredCurrencyBadgeInteractor: DefaultBadgeAssetInteractor {

    // MARK: - Setup
    
    init(settingsService: SettingsServiceAPI,
         fiatCurrencyService: FiatCurrencySettingsServiceAPI) {
        super.init()
        let settingsFiatCurrency = settingsService.valueObservable
            .map { $0.fiatCurrency }
        let fiatCurrency = fiatCurrencyService.fiatCurrencyObservable
        let currencyNames = CurrencySymbol.currencyNames()!
        
        Observable
            .combineLatest(settingsFiatCurrency, fiatCurrency)
            .map { currencyInfo -> BadgeItem in
                let currency = currencyInfo.0
                let description = currencyNames[currency] as? String ?? currency
                let title = "\(description) (\(currencyInfo.1.symbol))"
                return BadgeItem(type: .default, description: title)
            }
            .map { .loaded(next: $0) }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
