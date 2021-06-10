// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

extension TriageCryptoCurrency {

    public var logoResource: ImageResource {
        switch self {
        case .blockstack:
            return .local(name: "filled_stx_large", bundle: .platformUIKit)
        case .supported(let currency):
            return currency.logoResource
        }
    }
}
