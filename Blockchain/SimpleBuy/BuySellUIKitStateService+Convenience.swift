//
//  SimpleBuyStateService+Convenience.swift
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

extension BuySellUIKit.StateService {
    
    static func make() -> BuySellUIKit.StateServiceAPI {
        BuySellUIKit.StateService(
            serviceProvider: DataProvider.default.buySell,
            uiUtilityProvider: UIUtilityProvider.default,
            recordingProvider: RecordingProvider.default,
            kycTiersService: resolve(),
            cache: DataProvider.default.buySell.cache,
            userInformationServiceProvider: UserInformationServiceProvider.default
        )
    }
}
