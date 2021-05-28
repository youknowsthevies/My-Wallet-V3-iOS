// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import PlatformUIKit

extension PlatformUIKit.Router {

    convenience init(builder: PlatformUIKit.Buildable, currency: CryptoCurrency = .bitcoin) {
        self.init(
            navigationRouter: NavigationRouter(),
            builder: builder,
            kycRouter: resolve(),
            newKYCRouter: resolve(),
            currency: currency
        )
    }
}
