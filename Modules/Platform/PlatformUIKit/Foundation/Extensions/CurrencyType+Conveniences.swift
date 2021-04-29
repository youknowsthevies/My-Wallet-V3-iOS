// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

extension CurrencyType {
    
    public var logoImageName: String {
        switch self {
        case .crypto(let currency):
            return currency.logoImageName
        case .fiat(let currency):
            return currency.logoImageName
        }
    }
    
    public var brandColor: UIColor {
        switch self {
        case .crypto(let currency):
            return currency.brandColor
        case .fiat(let currency):
            return currency.brandColor
        }
    }
}
