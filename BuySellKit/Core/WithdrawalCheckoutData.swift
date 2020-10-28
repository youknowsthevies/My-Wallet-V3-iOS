//
//  WithdrawalCheckoutData.swift
//  BuySellKit
//
//  Created by Dimitrios Chatzieleftheriou on 19/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public struct WithdrawalCheckoutData {
    public let currency: FiatCurrency
    public let beneficiary: Beneficiary
    public let amount: FiatValue
    public let fee: FiatValue

    public init(currency: FiatCurrency,
                beneficiary: Beneficiary,
                amount: FiatValue,
                fee: FiatValue) {
        self.currency = currency
        self.beneficiary = beneficiary
        self.amount = amount
        self.fee = fee
    }
}
