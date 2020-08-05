//
//  AssetPriceCellInteractor.swift
//  TodayExtension
//
//  Created by Alex McGregor on 5/26/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit

final class AssetPriceCellInteractor {
    let priceViewInteractor: AssetPriceViewInteractor
    let currency: CryptoCurrency
    
    init(cryptoCurrency: CryptoCurrency,
         historicalFiatPriceServiceAPI: HistoricalFiatPriceServiceAPI) {
        currency = cryptoCurrency
        priceViewInteractor = AssetPriceViewInteractor(
            historicalPriceProvider: historicalFiatPriceServiceAPI
        )
    }
}
