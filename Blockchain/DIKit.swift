//
//  DIKit.swift
//  Blockchain
//
//  Created by Paulo on 17/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import ToolKit
import PlatformKit
import PlatformUIKit

extension DependencyContainer {
    
    // MARK: - Blockchain Module
    
    static var blockchain = module {
        
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
        
        single { OnboardingRouter() }
        
        factory { PaymentPresenter() }
        
        factory { UIApplication.shared as TopMostViewControllerProviding }
        
        factory { AirdropRouter() as AirdropRouterAPI }
        
        single { LoadingViewPresenter() as LoadingViewPresenting }
        
        single { AppFeatureConfigurator() }
        
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

        factory { () -> BalanceProviding in
            let provider: DataProviding = DIKit.resolve()
            return provider.balance
        }
    }
}
