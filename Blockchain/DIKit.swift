//
//  DIKit.swift
//  Blockchain
//
//  Created by Paulo on 17/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformUIKit
import PlatformKit

public extension DependencyContainer {
    static var enabledCurrenciesService = module {
        single { EnabledCurrenciesService(featureFetcher: AppFeatureConfigurator.shared) }
    }
    static var appCoordinator = module {
        single { AppCoordinator() }
    }
    static var authenticationCoordinator = module {
        single { AuthenticationCoordinator() }
    }
    static var blockchainSettingsApp = module {
        single { BlockchainSettings.App() }
        factory { () -> AppSettingsAPI in
            let app: BlockchainSettings.App = DIKit.resolve()
            return app as AppSettingsAPI
        }
        factory { () -> AppSettingsAuthenticating in
            let app: BlockchainSettings.App = DIKit.resolve()
            return app as AppSettingsAuthenticating
        }
    }
    static var walletManager = module {
        single { WalletManager() }
    }
    static var onboardingRouter = module {
        single { OnboardingRouter() }
    }
    static var paymentPresenter = module {
        factory { PaymentPresenter() }
    }
    static var topMostViewControllerProviding = module {
        factory { UIApplication.shared as TopMostViewControllerProviding }
    }
    static var airdropRouter = module {
        factory { AirdropRouter() as AirdropRouterAPI }
    }
    static var loadingViewPresenter = module {
        single { LoadingViewPresenter() as LoadingViewPresenting }
    }
    static var appFeatureConfigurator = module {
        single { AppFeatureConfigurator() }
    }
    static var deepLinkRouter = module {
        factory { DeepLinkRouter() }
    }
}
