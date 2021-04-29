// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public extension TriageCryptoCurrency {
    
    var logoImageName: String {
        switch self {
        case .blockstack:
            return "filled_stx_large"
        case .supported(let currency):
            return currency.logoImageName
        }
    }
    
    var logoImage: UIImage {
        UIImage(named: logoImageName)!
    }
}
