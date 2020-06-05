//
//  SimpleBuyStateService+Convenience.swift
//  Blockchain
//
//  Created by Daniel Huri on 04/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import BuySellKit
import BuySellUIKit

extension SimpleBuyStateService {
    
    static func make() -> SimpleBuyStateServiceAPI {
        SimpleBuyStateService(
            uiUtilityProvider: UIUtilityProvider.default,
            pendingOrderDetailsService: SimpleBuyServiceProvider.default.pendingOrderDetails,
            supportedPairsInteractor: SimpleBuyServiceProvider.default.supportedPairsInteractor,
            cache: SimpleBuyServiceProvider.default.cache
        )
    }
}
