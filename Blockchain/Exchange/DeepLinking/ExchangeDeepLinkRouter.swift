//
//  ExchangeDeepLinkRouter.swift
//  Blockchain
//
//  Created by AlexM on 7/23/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit

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
