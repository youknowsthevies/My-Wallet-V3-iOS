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
        public enum AccountType {
            case savings
            case checking
        }
        public let name: String
        public let type: AccountType
        public let bankName: String
        public let number: String

        init?(details: LinkedBankResponse.Details?) {
            guard let details = details else {
                return nil
            }
            name = details.accountName
            type = AccountType(from: details.bankAccountType)
            bankName = details.bankName
            number = details.accountNumber.replacingOccurrences(of: "x", with: "")
        }
    }
    public let currency: FiatCurrency
    public let identifier: String
    public let account: Account?
    public let state: PaymentAccountProperty.State

    public var topLimit: FiatValue

    var isActive: Bool {
        state == .active
    }

    init?(response: LinkedBankResponse) {
        identifier = response.id
        account = Account(details: response.details)
        state = response.state
        guard let currency = FiatCurrency(code: response.currency) else {
            return nil
        }
        self.currency = currency
        topLimit = .zero(currency: .USD)
    }
}

extension LinkedBankData.Account.AccountType {
    init(from type: LinkedBankResponse.Details.AccountType) {
        switch type {
        case .savings:
            self = .savings
        case .checking:
            self = .checking
        }
    }
}

extension LinkedBankData: Equatable {
    public static func == (lhs: LinkedBankData, rhs: LinkedBankData) -> Bool {
        lhs.identifier == rhs.identifier
    }
}
