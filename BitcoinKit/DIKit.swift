//
//  DIKit.swift
//  BitcoinKit
//
//  Created by Jack Pooley on 25/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit

extension DependencyContainer {
    
    // MARK: - BitcoinKit Module
     
    public static var bitcoinKit = module {
        
        factory { APIClient() as APIClientAPI }

        factory { BalanceService() as BalanceServiceAPI }

        // MARK: - Bitcoin

        factory { BitcoinWalletAccountRepository() }

        factory(tag: CryptoCurrency.bitcoin) { BitcoinAsset() as CryptoAsset }

        factory { BitcoinHistoricalTransactionService() }
        
        factory { BitcoinActivityItemEventDetailsFetcher() }
        
        factory { BitcoinTransactionalActivityItemEventsService() }

        // MARK: - Bitcoin Cash

        factory { BitcoinCashWalletAccountRepository() }

        factory(tag: CryptoCurrency.bitcoinCash) { BitcoinCashAsset() as CryptoAsset }
        
        factory { BitcoinCashHistoricalTransactionService() }
        
        factory { BitcoinCashActivityItemEventDetailsFetcher() }
        
        factory { BitcoinCashTransactionalActivityItemEventsService() }
        
    }
}
