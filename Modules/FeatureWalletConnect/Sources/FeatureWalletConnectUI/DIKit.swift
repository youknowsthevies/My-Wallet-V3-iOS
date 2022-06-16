// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureWalletConnectDomain

extension DependencyContainer {
    // MARK: - FeatureWalletConnectUI Module

    public static var featureWalletConnectUI = module {
        single { WalletConnectRouter() as WalletConnectRouterAPI }
    }
}
