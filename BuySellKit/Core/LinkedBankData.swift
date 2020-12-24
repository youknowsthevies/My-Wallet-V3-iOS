//
//  LinkedBankData.swift
//  BuySellKit
//
//  Created by Dimitrios Chatzieleftheriou on 08/12/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public struct LinkedBankData {
    public struct Account {
        public let name: String
        public let type: String
        public let bankName: String
    }
    public let currency: FiatCurrency
    public let identifier: String
    public let account: Account
    public let state: PaymentAccountProperty.State

    var isActive: Bool {
        state == .active
    }

    init?(response: LinkedBankResponse) {
        identifier = response.id
        account = Account(name: response.details.accountName,
                          type: response.details.bankAccountType,
                          bankName: response.details.bankName)
        state = response.state
        guard let currency = FiatCurrency(code: response.currency) else {
            return nil
        }
        self.currency = currency
    }
}

extension LinkedBankData: Equatable {
    public static func == (lhs: LinkedBankData, rhs: LinkedBankData) -> Bool {
        lhs.identifier == rhs.identifier
    }
}
