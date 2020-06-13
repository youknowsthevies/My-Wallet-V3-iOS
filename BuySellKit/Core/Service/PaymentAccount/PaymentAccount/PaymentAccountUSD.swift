//
//  PaymentAccountUSD.swift
//  PlatformKit
//
//  Created by Daniel Huri on 30/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

struct PaymentAccountUSD: PaymentAccount, Equatable {
    var fields: [SimpleBuyPaymentAccountProperty.Field] {
        [
            .accountNumber(accountNumber),
            .recipientName(recipientName)
        ]
    }

    static let currency: FiatCurrency = .USD
    let identifier: String
    let state: SimpleBuyPaymentAccountProperty.State
    let currency: FiatCurrency = Self.currency
    let address: String
    let accountNumber: String
    let bankCode: String
    let recipientName: String
    let routingNumber: String

    init?(response: PaymentAccountResponse) {
        guard response.currency == Self.currency else {
            return nil
        }
        guard
            let accountNumber: String = response.agent.account,
            let address: String = response.address,
            let routingNumber: String = response.agent.routingNumber,
            let bankCode: String = response.agent.code,
            let recipientName: String = response.agent.recipient
            else { return nil }
        self.accountNumber = accountNumber
        self.bankCode = bankCode
        self.address = address
        self.routingNumber = routingNumber
        self.recipientName = recipientName
        self.identifier = response.id
        self.state = response.state
    }
}
