//
//  SimpleBuyPaymentAccountEUR.swift
//  PlatformKit
//
//  Created by Paulo on 05/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct SimpleBuyPaymentAccountEUR: SimpleBuyPaymentAccount, Equatable {
    var fields: [SimpleBuyPaymentAccountProperty.Field] {
        return [
            .bankName(bankName),
            .bankCountry(bankCountry),
            .iban(iban),
            .bankCode(bankCode),
            .recipientName(recipientName)
        ]
    }

    static let currency: FiatCurrency = .EUR
    let identifier: String
    let state: SimpleBuyPaymentAccountProperty.State
    let currency: FiatCurrency = Self.currency
    let bankName: String
    let bankCountry: String
    let iban: String
    let bankCode: String
    let recipientName: String

    init?(response: SimpleBuyPaymentAccountResponse) {
        guard response.currency == Self.currency else {
            return nil
        }
        guard
            let bankName: String = response.agent.name,
            let iban: String = response.address,
            let bankCode: String = response.agent.code
            else { return nil }
        self.bankName = bankName
        self.bankCountry = response.agent.country ?? ""
        self.iban = iban
        self.bankCode = bankCode
        self.recipientName = response.agent.recipient ?? ""
        self.identifier = response.id
        self.state = response.state
    }

    init(identifier: String,
         state: SimpleBuyPaymentAccountProperty.State,
         bankName: String,
         bankCountry: String,
         iban: String,
         bankCode: String,
         recipientName: String) {
        self.bankName = bankName
        self.bankCountry = bankCountry
        self.iban = iban
        self.bankCode = bankCode
        self.recipientName = recipientName
        self.identifier = identifier
        self.state = state
    }

    func with(bankCountry: String) -> SimpleBuyPaymentAccountEUR {
        return .init(identifier: identifier,
                     state: state,
                     bankName: bankName,
                     bankCountry: bankCountry,
                     iban: iban,
                     bankCode: bankCode,
                     recipientName: recipientName)
    }

    func with(recipientName: String) -> SimpleBuyPaymentAccountEUR {
        return .init(identifier: identifier,
                     state: state,
                     bankName: bankName,
                     bankCountry: bankCountry,
                     iban: iban,
                     bankCode: bankCode,
                     recipientName: recipientName)
    }
}
