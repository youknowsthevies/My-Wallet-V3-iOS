// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import DIKit
import MoneyKit
import PlatformKit

extension DependencyContainer {

    // MARK: - BitcoinKit Module

    public static var bitcoinKit = module {

        single { APIClient() as APIClientAPI }

        factory { BitcoinWalletAccountRepository() }

        factory(tag: CryptoCurrency.bitcoin) { BitcoinAsset() as CryptoAsset }

        single { BitcoinHistoricalTransactionService() as BitcoinHistoricalTransactionServiceAPI }

        factory { () -> AnyActivityItemEventDetailsFetcher<BitcoinActivityItemEventDetails> in
            AnyActivityItemEventDetailsFetcher(api: BitcoinActivityItemEventDetailsFetcher())
        }
    }
}
