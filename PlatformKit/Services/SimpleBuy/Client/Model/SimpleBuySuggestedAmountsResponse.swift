//
//  SimpleBuySuggestedAmountsResponse.swift
//  PlatformKit
//
//  Created by Daniel Huri on 29/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

public struct SimpleBuySuggestedAmountsResponse {
        
    private(set) var eurAmounts: [String] = []
    private(set) var gbpAmounts: [String] = []

    init(rawResponse: [[String: [String]]]) {
        for rawItem in rawResponse {
            if let amounts = rawItem[FiatCurrency.EUR.code] {
                eurAmounts = amounts
            } else if let amounts = rawItem[FiatCurrency.GBP.code] {
                gbpAmounts = amounts
            }
        }
    }
}
