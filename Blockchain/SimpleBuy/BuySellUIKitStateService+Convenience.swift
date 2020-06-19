//
//  SimpleBuyStateService+Convenience.swift
//  Blockchain
//
//  Created by Daniel Huri on 04/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import BuySellKit
import BuySellUIKit

extension BuySellUIKit.StateService {
    
    static func make() -> BuySellUIKit.StateServiceAPI {
        BuySellUIKit.StateService(
            uiUtilityProvider: UIUtilityProvider.default,
            pendingOrderDetailsService: ServiceProvider.default.pendingOrderDetails,
            supportedPairsInteractor: ServiceProvider.default.supportedPairsInteractor,
            kycTiersService: KYCServiceProvider.default.tiers,
            cache: ServiceProvider.default.cache,
            userInformationServiceProvider: UserInformationServiceProvider.default
        )
    }
}
