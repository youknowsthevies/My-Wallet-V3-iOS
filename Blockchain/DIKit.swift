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
        
        single { AuthenticationCoordinator() }

        single { OnboardingRouter() }
        
        factory { PaymentPresenter() }

        factory { AirdropRouter() as AirdropRouterAPI }

        factory { DeepLinkRouter() }
        
        factory { UIDevice.current as DeviceInfo }

        single { AnalyticsService() as AnalyticsServiceAPI }

        // MARK: - AppCoordinator

        single { AppCoordinator() }

        factory { () -> DrawerRouting in
            let app: AppCoordinator = DIKit.resolve()
            return app as DrawerRouting
        }

        // MARK: - BlockchainSettings.App

        single { BlockchainSettings.App() }

        factory { () -> AppSettingsAPI in
            let app: BlockchainSettings.App = DIKit.resolve()
            return app as AppSettingsAPI
        }

        factory { () -> AppSettingsAuthenticating in
            let app: BlockchainSettings.App = DIKit.resolve()
            return app as AppSettingsAuthenticating
        }

        // MARK: - WalletManager

        single { WalletManager() }

        factory { () -> ReactiveWalletAPI in
            let manager: WalletManager = DIKit.resolve()
            return manager.reactiveWallet
        }

        factory { () -> MnemonicAccessAPI in
            let walletManager: WalletManager = DIKit.resolve()
            return walletManager.wallet as MnemonicAccessAPI
        }

        factory { () -> WalletRepositoryProvider in
            let walletManager: WalletManager = DIKit.resolve()
            return walletManager as WalletRepositoryProvider
        }

        factory { () -> JSContextProviderAPI in
            let walletManager: WalletManager = DIKit.resolve()
            return walletManager as JSContextProviderAPI
        }

        // MARK: - AppFeatureConfigurator

        single { AppFeatureConfigurator() }

        factory { () -> FeatureConfiguring in
            let featureFetching: AppFeatureConfigurator = DIKit.resolve()
            return featureFetching
        }

        factory { () -> FeatureFetching in
            let featureFetching: AppFeatureConfigurator = DIKit.resolve()
            return featureFetching
        }

        factory { () -> FeatureVariantFetching in
            let featureFetching: AppFeatureConfigurator = DIKit.resolve()
            return featureFetching
        }

        // MARK: - UserInformationServiceProvider

        single { UserInformationServiceProvider() as UserInformationServiceProviding }

        factory { () -> SettingsServiceAPI in
            let userInformationProvider: UserInformationServiceProviding = DIKit.resolve()
            return userInformationProvider.settings
        }

        factory { () -> FiatCurrencyServiceAPI in
            let userInformationProvider: UserInformationServiceProviding = DIKit.resolve()
            return userInformationProvider.settings
        }

        // MARK: - DataProvider

        single { DataProvider() }

        factory { () -> DataProviding in
            let provider: DataProvider = DIKit.resolve()
            return provider as DataProviding
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
