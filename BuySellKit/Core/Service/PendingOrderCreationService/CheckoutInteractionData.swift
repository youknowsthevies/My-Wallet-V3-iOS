//
//  CheckoutInteractionData.swift
//  PlatformKit
//
//  Created by Daniel Huri on 02/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public struct CheckoutInteractionData {
    public let time: Date?
    public let fee: FiatValue
    public let amount: CryptoValue
    public let exchangeRate: FiatValue?
    public let card: CardData?
    public let orderId: String
    
    public init(time: Date?,
                fee: FiatValue,
                amount: CryptoValue,
                exchangeRate: FiatValue?,
                card: CardData?,
                orderId: String) {
        self.time = time
        self.fee = fee
        self.amount = amount
        self.exchangeRate = exchangeRate
        self.card = card
        self.orderId = orderId
    }
}
