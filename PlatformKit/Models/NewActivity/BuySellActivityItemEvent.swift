//
//  BuySellActivityItemEvent.swift
//  PlatformKit
//
//  Created by Alex McGregor on 6/5/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization

public struct BuyActivityItemEvent: Tokenized {

    public enum EventStatus {
        case pending
        case cancelled
        case failed
        case expired
        case finished
    }

    public enum PaymentMethod {
        case card(paymentMethodId: String?)
        case bankTransfer
    }

    public var token: String {
        identifier
    }
    
    public var cryptoCurrency: CryptoCurrency {
        cryptoValue.currencyType
    }
    
    public let status: EventStatus
    public let paymentMethod: PaymentMethod
    
    public let identifier: String

    public let creationDate: Date

    public let fiatValue: FiatValue
    public let cryptoValue: CryptoValue
    public var fee: FiatValue
    
    public init(identifier: String,
                creationDate: Date,
                status: EventStatus,
                fiatValue: FiatValue,
                cryptoValue: CryptoValue,
                fee: FiatValue,
                paymentMethod: PaymentMethod) {
        self.creationDate = creationDate
        self.identifier = identifier
        self.status = status
        self.fiatValue = fiatValue
        self.cryptoValue = cryptoValue
        self.fee = fee
        self.paymentMethod = paymentMethod
    }
}
