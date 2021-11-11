// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit

extension DependencyContainer {

    public static var featureTransactionDomain = module {

        factory { CryptoTargetPayloadFactory() as CryptoTargetPayloadFactoryAPI }

        factory { AvailableTradingPairsService() as AvailableTradingPairsServiceAPI }

        factory { PendingSwapCompletionService() as PendingSwapCompletionServiceAPI }

        factory { BlockchainNameResolutionService() as BlockchainNameResolutionServiceAPI }

        factory { () -> CryptoCurrenciesServiceAPI in
            CryptoCurrenciesService(
                pairsService: DIKit.resolve(),
                priceService: DIKit.resolve()
            )
        }

        factory { PaymentAccountsService() as FeatureTransactionDomain.PaymentAccountsServiceAPI }
        factory { () -> TransactionLimitsServiceAPI in
            TransactionLimitsService(
                repository: DIKit.resolve(),
                conversionService: DIKit.resolve(),
                featureFlagService: DIKit.resolve()
            )
        }
    }
}
