//
//  WithdrawalPayload.swift
//  BuySellKit
//
//  Created by Dimitrios Chatzieleftheriou on 02/11/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

struct WithdrawalPayload: Encodable {
    let beneficiary: String
    let amount: String
    let currency: String

    init(data: WithdrawalCheckoutData) {
        self.beneficiary = data.beneficiary.identifier
        self.amount = data.amount.minorString
        self.currency = data.currency.code
    }
}
