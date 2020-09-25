//
//  DIKit.swift
//  PlatformKit
//
//  Created by Jack Pooley on 24/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import NetworkKit
import ToolKit

extension DependencyContainer {

    // MARK: - PlatformKit Module

    public static var platformKit = module {
        // MARK: - BalanceProviding

        factory { () -> BalanceProviding in
            let provider: DataProviding = DIKit.resolve()
            return provider.balance
        }

        factory { () -> ExchangeProviding in
            let provider: DataProviding = DIKit.resolve()
            return provider.exchange
        }

        // MARK: - Clients
        
        factory { SettingsClient() as SettingsClientAPI }
        
        factory { SwapClient() as SwapClientAPI }
        
        factory { GeneralInformationClient() as GeneralInformationClientAPI }
        
        factory { CustodialClient() as CustodialClientAPI }
        
        factory { () -> CustodyWithdrawalClientAPI in
            let custodialClient: CustodialClientAPI = DIKit.resolve()
            return custodialClient as CustodyWithdrawalClientAPI
        }
        
        factory { PriceClient() as PriceClientAPI }
        
        factory { UpdateWalletInformationClient() as UpdateWalletInformationClientAPI }
        
        factory { JWTClient() as JWTClientAPI }
        
        factory { KYCClient() as KYCClientAPI }

        factory { UserCreationClient() as UserCreationClientAPI }
        
        factory { NabuAuthenticationClient() as NabuAuthenticationClientAPI }
        
        // MARK: - Authentication
        
        single { NabuTokenStore() }

        single { NabuAuthenticationExecutor() as NabuAuthenticationExecutorAPI }
        
        factory { () -> NabuAuthenticationExecutorProvider in
            { () -> NabuAuthenticationExecutorAPI in
                DIKit.resolve()
            }
        }
        
        factory { NabuAuthenticator() as AuthenticatorAPI }
        
        factory { JWTService() as JWTServiceAPI }
        
        // MARK: - Wallet
        
        factory { WalletNabuSynchronizerService() as WalletNabuSynchronizerServiceAPI }
        
        factory { () -> WalletRepositoryAPI in
            let walletRepositoryProvider: WalletRepositoryProvider = DIKit.resolve()
            return walletRepositoryProvider.repository as WalletRepositoryAPI
        }
        
        factory { () -> CredentialsRepositoryAPI in
            let repository: WalletRepositoryAPI = DIKit.resolve()
            return repository as CredentialsRepositoryAPI
        }
        
        factory { () -> NabuOfflineTokenRepositoryAPI in
            let repository: WalletRepositoryAPI = DIKit.resolve()
            return repository as NabuOfflineTokenRepositoryAPI
        }
        
        factory { () -> NabuAuthenticationExecutor.CredentialsRepository in
            let repository: WalletRepositoryAPI = DIKit.resolve()
            return repository as NabuAuthenticationExecutor.CredentialsRepository
        }
        
        // MARK: - Services

        single { EnabledCurrenciesService() as EnabledCurrenciesServiceAPI }
        
        factory { KYCServiceProvider() as KYCServiceProviderAPI }
        
        single { NabuUserService() as NabuUserServiceAPI }
        
        single { SettingsService() as CompleteSettingsServiceAPI }
        
        factory { () -> FiatCurrencySettingsServiceAPI in
            let completeSettings: CompleteSettingsServiceAPI = DIKit.resolve()
            return completeSettings as FiatCurrencySettingsServiceAPI
        }
        
        single { GeneralInformationService() as GeneralInformationServiceAPI }
        
        single { EmailVerificationService() as EmailVerificationServiceAPI }
        
        factory { SwapActivityService() as SwapActivityServiceAPI }

        single { () -> Coincore in
            Coincore(
                cryptoAssets: CryptoCurrency.allCases.reduce(into: [CryptoCurrency: CryptoAsset](), { (result, tag) in
                    let asset: CryptoAsset = DIKit.resolve(tag: tag)
                    result[tag] = asset
                })
            )
        }

        single { KYCTiersService() as KYCTiersServiceAPI }

        factory { CustodialFeatureFetcher() as CustodialFeatureFetching }

        single { () -> WalletOptionsAPI in
            WalletService()
        }

        factory { () -> MaintenanceServicing in
            let service: WalletOptionsAPI = DIKit.resolve()
            return service
        }

        factory { CredentialsStore() as CredentialsStoreAPI }

        factory { NSUbiquitousKeyValueStore.default as UbiquitousKeyValueStore }

        factory { WalletCryptoService() as WalletCryptoServiceAPI }

        factory { TradingBalanceService() as TradingBalanceServiceAPI }
        
        // MARK: Activity Services
        
        factory(tag: FiatCurrency.EUR) { FiatActivityItemEventService(fiatCurrency: .EUR) as FiatActivityItemEventServiceAPI }
        
        factory(tag: FiatCurrency.GBP) { FiatActivityItemEventService(fiatCurrency: .GBP) as FiatActivityItemEventServiceAPI }
        
        factory(tag: FiatCurrency.USD) { FiatActivityItemEventService(fiatCurrency: .USD) as FiatActivityItemEventServiceAPI }
    }
}
