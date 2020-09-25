//
//  DIKit.swift
//  StellarKit
//
//  Created by Paulo on 10/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit

extension DependencyContainer {

    // MARK: - BitcoinKit Module

    public static var stellarKit = module {

        factory {
            AnyAssetAccountDetailsAPI<StellarAssetAccountDetails>(
                service: StellarAssetAccountDetailsService()
            )
        }

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
        
        factory { StellarTransactionalActivityItemEventsService() }
        
        factory { StellarActivityItemEventDetailsFetcher() }
    }
}
