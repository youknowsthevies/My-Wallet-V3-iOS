//
//  FiatCurrency+Conveniences.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 03/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

extension FiatCurrency {
    public var logoImageName: String {
        switch self {
        case .GBP:
            return "icon-gbp"
        case .EUR:
            return "icon-eur"
        case .USD:
            return "icon-usd"
        default:
            fatalError("Currency \(self.code) does not have a logo image")
        }
    }
    
    public var brandColor: UIColor { .fiat }
}
