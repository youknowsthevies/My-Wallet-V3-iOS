// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import TransactionKit

extension DependencyContainer {
    
    // MARK: - EthereumKit Module
     
    public static var ethereumKit = module {
        
        factory { APIClient() as APIClientAPI }
        
        factory { CryptoFeeService<EthereumTransactionFee>() }
        
        factory(tag: CryptoCurrency.ethereum) { EthereumExternalAssetAddressFactory() as CryptoReceiveAddressFactory }

        factory(tag: CryptoCurrency.ethereum) { EthereumAsset() as CryptoAsset }
        
        factory(tag: CryptoCurrency.ethereum) { EthereumOnChainTransactionEngineFactory() as OnChainTransactionEngineFactory }
        
        single { EthereumAssetAccountRepository() }
        
        factory { EthereumAssetAccountDetailsService() }
        
        factory { EthereumWalletAccountRepository() }
                
        factory { () -> EthereumWalletAccountRepositoryAPI in
            let repository: EthereumWalletAccountRepository = DIKit.resolve()
            return repository as EthereumWalletAccountRepositoryAPI
        }
        
        factory { EthereumAccountBalanceService() as EthereumAccountBalanceServiceAPI }
        
        factory(tag: CryptoCurrency.ethereum) {
            EthereumAssetBalanceFetcher() as CryptoAccountBalanceFetching
        }
        
        single { EthereumHistoricalTransactionService() }

        factory { EthereumTransactionalActivityItemEventsService() }
        
        factory { EthereumActivityItemEventDetailsFetcher() }
        
        factory { EthereumWalletService() as EthereumWalletServiceAPI }
        
        factory { EthereumTransactionBuildingService() as EthereumTransactionBuildingServiceAPI }
        
        factory { EthereumTransactionSendingService() as EthereumTransactionSendingServiceAPI }
        
        factory { EthereumTransactionValidationService() }
        
        factory { AnyCryptoFeeService<EthereumTransactionFee>.ethereum() }
        
        factory { AnyKeyPairProvider<EthereumKeyPair>.ethereum() }
        
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

extension AnyKeyPairProvider where Pair == EthereumKeyPair {
    
    fileprivate static func ethereum(
        ethereumWalletAccountRepository: EthereumWalletAccountRepository = resolve()
    ) -> AnyKeyPairProvider<Pair> {
        AnyKeyPairProvider<Pair>(provider: ethereumWalletAccountRepository)
    }
}

