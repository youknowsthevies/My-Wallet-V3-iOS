//
//  CheckoutData.swift
//  PlatformKit
//
//  Created by Daniel Huri on 05/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public struct CandidateOrderDetails {
    
    /// The payment method
    public let paymentMethod: PaymentMethodType?
    
    /// Fiat value
    public let fiatValue: FiatValue
    
    /// Crypto value
    public let cryptoValue: CryptoValue
    
    /// The currency type
    public let cryptoCurrency: CryptoCurrency
    
    /// Whether the order is a `Buy` or a `Sell`
    public let action: Order.Action
    
    public let paymentMethodId: String?
    
    public init(paymentMethod: PaymentMethodType? = nil,
                action: Order.Action = .buy,
                fiatValue: FiatValue,
                cryptoValue: CryptoValue,
                paymentMethodId: String? = nil) {
        self.action = action
        self.paymentMethod = paymentMethod
        self.fiatValue = fiatValue
        self.cryptoValue = cryptoValue
        self.cryptoCurrency = cryptoValue.currencyType
        self.paymentMethodId = paymentMethodId
    }
    
    public static func buy(paymentMethod: PaymentMethodType? = nil,
                           fiatValue: FiatValue,
                           cryptoValue: CryptoValue,
                           paymentMethodId: String? = nil) -> CandidateOrderDetails {
        .init(
            paymentMethod: paymentMethod,
            action: .buy,
            fiatValue: fiatValue,
            cryptoValue: cryptoValue,
            paymentMethodId: paymentMethodId
        )
    }
    
    public static func sell(paymentMethod: PaymentMethodType? = nil,
                            fiatValue: FiatValue,
                            cryptoValue: CryptoValue,
                            paymentMethodId: String? = nil) -> CandidateOrderDetails {
        .init(
            paymentMethod: paymentMethod,
            action: .sell,
            fiatValue: fiatValue,
            cryptoValue: cryptoValue,
            paymentMethodId: paymentMethodId
        )
    }
}

public struct CheckoutData {
        
    public let order: OrderDetails
    public let paymentAccount: PaymentAccount!
    public let isPaymentMethodFinalized: Bool
    
    // MARK: - Properties

    public var hasCardCheckoutMade: Bool {
        order.is3DSConfirmedCardOrder || order.isPending3DSCardOrder
    }

    public var isPendingDepositBankWire: Bool {
        order.isPendingDepositBankWire
    }
    
    public var isPending3DS: Bool {
        order.isPending3DSCardOrder
    }
        
    public var outputCurrency: CurrencyType {
        order.outputValue.currencyType
    }
    
    public var inputCurrency: CurrencyType {
        order.inputValue.currencyType
    }
    
    public var fiatValue: FiatValue? {
        if let fiat = order.inputValue.fiatValue {
            return fiat
        }
        if let fiat = order.outputValue.fiatValue {
            return fiat
        }
        return nil
    }
    
    public var cryptoValue: CryptoValue? {
        if let crypto = order.inputValue.cryptoValue {
            return crypto
        }
        if let crypto = order.outputValue.cryptoValue {
            return crypto
        }
        return nil
    }
    
    /// `true` if the order is card but is undetermined
    public var isUnknownCardType: Bool {
        order.paymentMethod.isCard && order.paymentMethodId == nil
    }
    
    public var isPendingConfirmationFunds: Bool {
        order.isPendingConfirmation && order.paymentMethod.isFunds
    }
                
    public init(order: OrderDetails, paymentAccount: PaymentAccount? = nil) {
        self.order = order
        self.paymentAccount = paymentAccount
        isPaymentMethodFinalized = (paymentAccount != nil || order.paymentMethodId != nil)
    }

    public func checkoutData(byAppending cardData: CardData) -> CheckoutData {
        var order = self.order
        order.paymentMethodId = cardData.identifier
        return CheckoutData(order: order)
    }
    
    func checkoutData(byAppending paymentAccount: PaymentAccount) -> CheckoutData {
        CheckoutData(
            order: order,
            paymentAccount: paymentAccount
        )
    }
    
    func checkoutData(byAppending orderDetails: OrderDetails) -> CheckoutData {
        CheckoutData(
            order: orderDetails,
            paymentAccount: paymentAccount
        )
    }
}
