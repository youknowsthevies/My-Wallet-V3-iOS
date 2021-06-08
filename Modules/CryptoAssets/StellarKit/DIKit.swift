// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import TransactionKit

extension DependencyContainer {

    // MARK: - BitcoinKit Module

    public static var stellarKit = module {

        factory { HorizonProxy() as HorizonProxyAPI }

        factory { StellarAccountDetailsService() as StellarAccountDetailsServiceAPI }

        single { () -> StellarConfigurationAPI in
            StellarConfigurationService()
        }

        factory { () -> StellarWalletOptionsBridgeAPI in
            StellarWalletOptionsService()
        }

        single { StellarWalletAccountRepository() }

        factory { () -> StellarWalletAccountRepositoryAPI in
            let service: StellarWalletAccountRepository = DIKit.resolve()
            return service
        }

        factory(tag: CryptoCurrency.stellar) { StellarAsset() as CryptoAsset }

        factory(tag: CryptoCurrency.stellar) { StellarOnChainTransactionEngineFactory() as OnChainTransactionEngineFactory }

        factory { StellarTransactionalActivityItemEventsService() }

        factory { StellarActivityItemEventDetailsFetcher() }

        single { AnyCryptoFeeService(service: CryptoFeeService<StellarTransactionFee>()) }

        factory { StellarTransactionDispatcher() }

        factory { LedgersServiceProvider() as LedgersServiceProviderAPI }

        factory(tag: CryptoCurrency.stellar) { StellarCryptoReceiveAddressFactory() as CryptoReceiveAddressFactory }

    }
}
