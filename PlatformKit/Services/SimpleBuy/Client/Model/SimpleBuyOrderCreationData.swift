//
//  SimpleBuyOrderCreationData.swift
//  PlatformKit
//
//  Created by Daniel Huri on 05/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct SimpleBuyOrder {
    public enum Action: String, Codable {
        case buy = "BUY"
        case sell = "SELL"
    }
}

public struct SimpleBuyOrderCreationData {
    
    public struct Request: Encodable {
        struct Input: Encodable {
            let symbol: String
            let amount: String
        }
        
        struct Output: Encodable {
            let symbol: String
        }
        
        let pair: String
        let action: SimpleBuyOrder.Action
        let input: Input
        let output: Output
        
        init(action: SimpleBuyOrder.Action, fiatValue: FiatValue, for cryptoCurrency: CryptoCurrency) {
            self.action = action
            input = .init(
                symbol: fiatValue.currencyCode,
                amount: fiatValue.string
            )
            output = .init(symbol: cryptoCurrency.code)
            pair = "\(output.symbol)-\(input.symbol)"
        }
    }
    
    public struct Response: Decodable {
        let id: String
        let inputCurrency: String
        let inputQuantity: String
        let outputCurrency: String
        let outputQuantity: String
        let state: String
        let insertedAt: String
        let updatedAt: String
        let expiresAt: String
    }
}
