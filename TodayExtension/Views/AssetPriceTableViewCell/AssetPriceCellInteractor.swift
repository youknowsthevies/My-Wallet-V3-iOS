// Copyright © Blockchain Luxembourg S.A. All rights reserved.

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
