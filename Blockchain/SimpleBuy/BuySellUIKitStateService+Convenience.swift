//
//  SimpleBuyStateService+Convenience.swift
//  Blockchain
//
//  Created by Daniel Huri on 04/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import BuySellUIKit
import PlatformKit
import PlatformUIKit

extension BuySellUIKit.StateService {
    
    static func make() -> BuySellUIKit.StateServiceAPI {
        BuySellUIKit.StateService(
            uiUtilityProvider: UIUtilityProvider.default,
            pendingOrderDetailsService: DataProvider.default.buySell.pendingOrderDetails,
            supportedPairsInteractor: DataProvider.default.buySell.supportedPairsInteractor,
            kycTiersService: KYCServiceProvider.default.tiers,
            cache: DataProvider.default.buySell.cache,
            userInformationServiceProvider: UserInformationServiceProvider.default
        )
    }
}
