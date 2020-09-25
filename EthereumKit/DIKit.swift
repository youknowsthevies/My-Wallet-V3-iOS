//
//  DIKit.swift
//  EthereumKit
//
//  Created by Jack Pooley on 24/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit

extension DependencyContainer {
    
    // MARK: - EthereumKit Module
     
    public static var ethereumKit = module {
        
        factory { APIClient() as APIClientAPI }

        factory(tag: CryptoCurrency.ethereum) { EthereumAsset() as CryptoAsset }

        factory { EthereumAccountBalanceService() as EthereumAccountBalanceServiceAPI }
        
        factory { () -> EthereumHistoricalTransactionService in
            let wallet: EthereumWalletBridgeAPI = DIKit.resolve()
            return EthereumHistoricalTransactionService(with: wallet)
        }
        
        factory { EthereumTransactionalActivityItemEventsService() }
        
        factory { EthereumActivityItemEventDetailsFetcher() }
    }
}
