//
//  DIKit.swift
//  Blockchain
//
//  Created by Paulo on 17/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import BitcoinKit
import ERC20Kit
import EthereumKit
import PlatformKit
import PlatformUIKit
import StellarKit
import ToolKit

extension DependencyContainer {
    
    // MARK: - Blockchain Module
    
    static var blockchain = module {

        single { EnabledCurrenciesService(featureFetcher: AppFeatureConfigurator.shared) }
        
        single { AppCoordinator() }
        
        single { AuthenticationCoordinator() }
        
        single { BlockchainSettings.App() }
        
        factory { () -> AppSettingsAPI in
            let app: BlockchainSettings.App = DIKit.resolve()
            return app as AppSettingsAPI
        }
        
        factory { () -> AppSettingsAuthenticating in
            let app: BlockchainSettings.App = DIKit.resolve()
            return app as AppSettingsAuthenticating
        }
        
        single { WalletManager() }

        factory { () -> ReactiveWalletAPI in
            let manager: WalletManager = DIKit.resolve()
            return manager.reactiveWallet
        }

        factory { () -> MnemonicAccessAPI in
            let walletManager: WalletManager = DIKit.resolve()
            return walletManager.wallet as MnemonicAccessAPI
        }
        
        single { OnboardingRouter() }
        
        factory { PaymentPresenter() }

        factory { AirdropRouter() as AirdropRouterAPI }

        single { LoadingViewPresenter() as LoadingViewPresenting }
        
        single { AppFeatureConfigurator() }

        factory { () -> FeatureFetching in
            let featureFetching: AppFeatureConfigurator = DIKit.resolve()
            return featureFetching
        }
        
        factory { DeepLinkRouter() }
        
        factory { UIDevice.current as DeviceInfo }
        
        single { UserInformationServiceProvider() as UserInformationServiceProviding }
        
        factory { () -> SettingsServiceAPI in
            let userInformationProvider: UserInformationServiceProviding = DIKit.resolve()
            let settings = userInformationProvider.settings
            return settings as SettingsServiceAPI
        }
        
        factory { () -> WalletRepositoryProvider in
            let walletManager: WalletManager = DIKit.resolve()
            return walletManager as WalletRepositoryProvider
        }
        
        single { AnalyticsService() as AnalyticsServiceAPI }

        single { DataProvider() }

        factory { () -> DataProviding in
            let provider: DataProvider = DIKit.resolve()
            return provider as DataProviding
        }

        factory { () -> JSContextProviderAPI in
            let walletManager: WalletManager = DIKit.resolve()
            return walletManager as JSContextProviderAPI
        }

        // MARK: - Ethereum Wallet

        factory { () -> EthereumWallet in
            let manager: WalletManager = DIKit.resolve()
            return manager.wallet.ethereum
        }

        factory { () -> ERC20BridgeAPI in
            let ethereum: EthereumWallet = DIKit.resolve()
            return ethereum
        }

        factory { () -> EthereumWalletBridgeAPI in
            let ethereum: EthereumWallet = DIKit.resolve()
            return ethereum
        }

        factory { () -> EthereumWalletAccountBridgeAPI in
            let ethereum: EthereumWallet = DIKit.resolve()
            return ethereum
        }

        factory(tag: CryptoCurrency.ethereum) { () -> MnemonicAccessAPI in
            let ethereum: EthereumWallet = DIKit.resolve()
            return ethereum
        }

        factory(tag: CryptoCurrency.ethereum) { () -> PasswordAccessAPI in
            let ethereum: EthereumWallet = DIKit.resolve()
            return ethereum
        }

        factory(tag: CryptoCurrency.ethereum) { () -> SecondPasswordPromptable in
            let ethereum: EthereumWallet = DIKit.resolve()
            return ethereum
        }

        factory(tag: CryptoCurrency.ethereum) { () -> CryptoAccountBalanceFetching in
            let ethereum: EthereumWallet = DIKit.resolve()
            return ethereum
        }

        // MARK: - Stellar Wallet

        factory { () -> StellarWalletBridgeAPI in
            let walletManager: WalletManager = DIKit.resolve()
            return walletManager.wallet as StellarWalletBridgeAPI
        }

        // MARK: - Bitcoin Wallet

        factory { () -> BitcoinWalletBridgeAPI in
            let walletManager: WalletManager = DIKit.resolve()
            return walletManager.wallet.bitcoin
        }

        single { BitcoinCashWallet() as BitcoinCashWalletBridgeAPI }
    }
}
