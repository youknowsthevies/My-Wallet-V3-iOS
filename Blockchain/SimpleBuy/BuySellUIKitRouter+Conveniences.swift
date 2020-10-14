//
//  BuySellUIKit+Conveniences.swift
//  Blockchain
//
//  Created by Daniel Huri on 04/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import BuySellUIKit
import DIKit
import PlatformKit
import PlatformUIKit

extension BuySellUIKit.Router {
    
    convenience init(builder: BuySellUIKit.Buildable) {
        self.init(
            navigationRouter: NavigationRouter(),
            serviceProvider: DataProvider.default.buySell,
            cardServiceProvider: CardServiceProvider.default,
            userInformationProvider: UserInformationServiceProvider.default,
            builder: builder,
            kycServiceProvider: resolve(),
            recordingProvider: RecordingProvider.default,
            kycRouter: resolve(),
            exchangeProvider: DataProvider.default.exchange
        )
    }
}
