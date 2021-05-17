// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit

extension DependencyContainer {

    // MARK: - BitcoinCashKit Module

    public static var bitcoinCashKit = module {

        factory { APIClient() as APIClientAPI }

        factory { BitcoinCashWalletAccountRepository() }

        factory(tag: CryptoCurrency.bitcoinCash) { BitcoinCashAsset() as CryptoAsset }

        factory { BitcoinCashHistoricalTransactionService() }

        factory { BitcoinCashActivityItemEventDetailsFetcher() }

        factory { BitcoinCashTransactionalActivityItemEventsService() }

    }
}
