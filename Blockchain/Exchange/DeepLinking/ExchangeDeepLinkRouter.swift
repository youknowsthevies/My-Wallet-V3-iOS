// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import SettingsKit

class ExchangeDeepLinkRouter: DeepLinkRouting {
    
    private let appSettings: BlockchainSettings.App
    init(appSettings: BlockchainSettings.App = resolve()) {
        self.appSettings = appSettings
    }
    
    func routeIfNeeded() -> Bool {
        guard appSettings.didTapOnExchangeDeepLink else {
            return false
        }
        ExchangeCoordinator.shared.start()
        return true
    }
}
