//
//  FiatCurrency+Conveniences.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 03/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

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
}

extension FiatCurrency {
    public var logoImageName: String {
        switch self {
        case .GBP:
            return "icon-gbp"
        case .EUR:
            return "icon-eur"
        default:
            fatalError("Currency \(self.code) does not have a logo image")
        }
    }
}
