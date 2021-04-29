// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit

extension DependencyContainer {
    
    // MARK: - BitcoinKit Module
     
    public static var bitcoinKit = module {
        
        factory { APIClient() as APIClientAPI }

        factory { BitcoinWalletAccountRepository() }

        factory(tag: CryptoCurrency.bitcoin) { BitcoinAsset() as CryptoAsset }

        factory { BitcoinHistoricalTransactionService() }
        
        factory { BitcoinActivityItemEventDetailsFetcher() }
        
        factory { BitcoinTransactionalActivityItemEventsService() }
    }
}
