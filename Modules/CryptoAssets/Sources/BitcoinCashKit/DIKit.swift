// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import MoneyKit
import PlatformKit

extension DependencyContainer {

    // MARK: - BitcoinCashKit Module

    public static var bitcoinCashKit = module {

        single {
            BitcoinCashKit.APIClient() as BitcoinCashKit.APIClientAPI
        }

        factory { BitcoinCashWalletAccountRepository() }

        factory(tag: CryptoCurrency.bitcoinCash) { BitcoinCashAsset() as CryptoAsset }

        single { BitcoinCashHistoricalTransactionService() as BitcoinCashHistoricalTransactionServiceAPI }

        factory { () -> AnyActivityItemEventDetailsFetcher<BitcoinCashActivityItemEventDetails> in
            AnyActivityItemEventDetailsFetcher(api: BitcoinCashActivityItemEventDetailsFetcher())
        }
    }
}
