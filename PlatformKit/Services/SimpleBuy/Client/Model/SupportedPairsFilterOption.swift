//
//  SupportedPairsFilterOption.swift
//  PlatformKit
//
//  Created by Daniel Huri on 14/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

/// Filter option for simple buy
public enum SupportedPairsFilterOption {
    
    /// Fetch all supported pairs
    case all
    
    /// Fetch all supported pairs
    case only(fiatCurrency: FiatCurrency)
    
    var fiatCurrency: FiatCurrency? {
        switch self {
        case .only(fiatCurrency: let currency):
            return currency
        case .all:
            return nil
        }
    }
}
