// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BuySellKit
import BuySellUIKit
import DIKit
import PlatformKit
import PlatformUIKit

extension BuySellUIKit.Router {
    
    convenience init(builder: BuySellUIKit.Buildable, currency: CryptoCurrency = .bitcoin) {
        self.init(
            navigationRouter: NavigationRouter(),
            builder: builder,
            kycRouter: resolve(),
            currency: currency
        )
    }
}
