// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import UIKit

extension BlockchainAccount {

    public var logoResource: ImageResource {
        switch self {
        case is LinkedBankAccount:
            return .local(name: "icon-bank", bundle: .platformUIKit)
        default:
            return currencyType.logoResource
        }
    }

    public var logoBackgroundColor: UIColor {
        .background
    }
}
