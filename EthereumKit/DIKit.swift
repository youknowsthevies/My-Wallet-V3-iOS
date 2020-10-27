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
        
        factory { CryptoFeeService<EthereumTransactionFee>() }

        factory(tag: CryptoCurrency.ethereum) { EthereumAsset() as CryptoAsset }
        
        single { EthereumAssetAccountRepository() }
        
        factory { EthereumAssetAccountDetailsService() }
        
        factory { EthereumWalletAccountRepository() as EthereumWalletAccountRepositoryAPI }
        
        factory { EthereumAccountBalanceService() as EthereumAccountBalanceServiceAPI }
        
        single { EthereumHistoricalTransactionService() }

        factory { EthereumTransactionalActivityItemEventsService() }
        
        factory { EthereumActivityItemEventDetailsFetcher() }
        
        factory { EthereumWalletService() as EthereumWalletServiceAPI }
        
        factory { EthereumTransactionBuildingService() as EthereumTransactionBuildingServiceAPI }
        
        factory { EthereumTransactionSendingService() as EthereumTransactionSendingServiceAPI }
        
        factory { EthereumTransactionValidationService() }
        
        factory { AnyCryptoFeeService<EthereumTransactionFee>.ethereum() }
        
        factory { EthereumTransactionBuilder() as EthereumTransactionBuilderAPI }
        
        factory { EthereumTransactionSigner() as EthereumTransactionSignerAPI }
        
        factory { EthereumTransactionEncoder() as EthereumTransactionEncoderAPI }
    }
}

extension AnyCryptoFeeService where FeeType == EthereumTransactionFee {
    
    fileprivate static func ethereum(
        service: CryptoFeeService<EthereumTransactionFee> = resolve()
    ) -> AnyCryptoFeeService<FeeType> {
        AnyCryptoFeeService<FeeType>(service: service)
    }
}
