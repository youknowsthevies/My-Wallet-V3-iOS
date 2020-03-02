//
//  SimpleBuySuggestedAmounts.swift
//  PlatformKit
//
//  Created by Daniel Huri on 29/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct SimpleBuySuggestedAmounts {
    
    public subscript(currency: FiatCurrency) -> [FiatValue] {
        return amountsPerCurrency[currency] ?? []
    }
    
    private var amountsPerCurrency: [FiatCurrency: [FiatValue]] = [:]
    
    init(response: SimpleBuySuggestedAmountsResponse) {
        append(amounts: response.eurAmounts, for: .EUR)
        append(amounts: response.gbpAmounts, for: .GBP)
    }
    
    private mutating func append(amounts: [String], for currency: FiatCurrency) {
        amountsPerCurrency[currency] = amounts
            .map { FiatValue(minor: $0, currency: currency) }
    }
}
