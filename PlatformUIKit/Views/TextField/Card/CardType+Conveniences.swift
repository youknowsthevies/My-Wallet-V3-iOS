//
//  CardType.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 20/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import PlatformKit

extension CardType {
    
    public var thumbnail: String? {
        switch self {
        case .visa:
            return "logo-visa"
        case .mastercard:
            return "logo-mastercard"
        case .amex:
            return "logo-amex"
        case .diners:
            return "logo-diners"
        case .discover:
            return "logo-disover"
        case .jcb:
            return "logo-jcb"
        case .unknown:
            return nil
        }
    }
    
    var parts: [Int] {
        switch self {
        case .visa, .mastercard, .jcb, .discover:
            return [4, 4, 4, 4]
        case .amex:
            return [4, 6, 5]
        case .diners:
            return [4, 6, 4]
        case .unknown:
            return []
        }
    }
}
