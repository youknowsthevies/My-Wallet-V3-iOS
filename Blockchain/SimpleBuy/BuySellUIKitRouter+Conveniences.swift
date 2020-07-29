//
//  BuySellUIKit+Conveniences.swift
//  Blockchain
//
//  Created by Daniel Huri on 04/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import BuySellUIKit
import PlatformKit
import PlatformUIKit

extension BuySellUIKit.Router {
    
    convenience init(stateService: BuySellUIKit.StateServiceAPI) {
        self.init(
            navigationRouter: NavigationRouter(),
            serviceProvider: DataProvider.default.buySell,
            cardServiceProvider: CardServiceProvider.default,
            userInformationProvider: UserInformationServiceProvider.default,
            stateService: stateService,
            kycServiceProvider: KYCServiceProvider.default,
            recordingProvider: RecordingProvider.default,
            kycRouter: KYCCoordinator.shared,
            exchangeProvider: DataProvider.default.exchange
        )
    }
}
