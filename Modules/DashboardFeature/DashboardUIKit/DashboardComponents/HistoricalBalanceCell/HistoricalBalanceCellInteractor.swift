// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift

final class HistoricalBalanceCellInteractor {
    
    // MARK: - Properties
    
    let sparklineInteractor: SparklineInteracting
    let priceInteractor: AssetPriceViewInteracting
    let balanceInteractor: AssetBalanceViewInteracting
    let cryptoCurrency: CryptoCurrency
    
    // MARK: - Setup
    
    init(cryptoCurrency: CryptoCurrency,
         historicalFiatPriceService: HistoricalFiatPriceServiceAPI,
         assetBalanceFetcher: AssetBalanceFetching) {
        self.cryptoCurrency = cryptoCurrency
        sparklineInteractor = SparklineInteractor(
            priceService: historicalFiatPriceService,
            cryptoCurrency: cryptoCurrency
        )
        priceInteractor = AssetPriceViewInteractor(
            historicalPriceProvider: historicalFiatPriceService
        )
        balanceInteractor = AssetBalanceViewInteractor(
            assetBalanceFetching: assetBalanceFetcher
        )
    }
}
