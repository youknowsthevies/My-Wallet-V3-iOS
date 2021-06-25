// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public extension BlockchainAccount {
    var logoResource: ImageResource {
        switch self {
        case is LinkedBankAccount:
            return .local(name: "icon-bank", bundle: .platformUIKit)
        default:
            return currencyType.logoResource
        }
    }
}
