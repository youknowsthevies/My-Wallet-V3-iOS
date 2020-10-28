//
//  DIKit.swift
//  Blockchain
//
//  Created by Paulo on 17/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DebugUIKit
import BitcoinCashKit
import BitcoinKit
import BuySellKit
import DIKit
import ERC20Kit
import EthereumKit
import KYCKit
import PlatformKit
import PlatformUIKit
import StellarKit
import ToolKit
import TransactionKit
import TransactionUIKit

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
        
        factory { CrashlyticsRecorder() as MessageRecording }

        factory { LockboxRepository() as LockboxRepositoryAPI }

        single { TradeLimitsService() as TradeLimitsAPI }

        factory { BlockchainDataRepository.shared as DataRepositoryAPI }

        // MARK: - Send

        factory { () -> SendScreenProvider in
            let manager: SendControllerManager = DIKit.resolve()
            return manager
        }

        single { SendControllerManager() }

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

        factory { () -> PermissionSettingsAPI in
            let app: BlockchainSettings.App = DIKit.resolve()
            return app
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
        
        factory { () -> FeatureFetchingConfiguring in
            let featureFetching: AppFeatureConfigurator = DIKit.resolve()
            return featureFetching
        }

        factory { () -> FeatureVariantFetching in
            let featureFetching: AppFeatureConfigurator = DIKit.resolve()
            return featureFetching
        }

        // MARK: - UserInformationServiceProvider

        factory { () -> SettingsServiceAPI in
            let completeSettingsService: CompleteSettingsServiceAPI = DIKit.resolve()
            return completeSettingsService
        }

        factory { () -> FiatCurrencyServiceAPI in
            let completeSettingsService: CompleteSettingsServiceAPI = DIKit.resolve()
            return completeSettingsService
        }

        factory { () -> MobileSettingsServiceAPI in
            let completeSettingsService: CompleteSettingsServiceAPI = DIKit.resolve()
            return completeSettingsService
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
        
        factory { () -> EthereumWalletAccountRepository.Bridge in
            let ethereum: EthereumWallet = DIKit.resolve()
            return ethereum as EthereumWalletAccountRepository.Bridge
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
        
        // MARK: Simple Buy
        
    }
}
