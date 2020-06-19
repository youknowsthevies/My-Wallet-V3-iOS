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
    public let paymentMethod: PaymentMethodType
    
    /// Fiat value
    public let fiatValue: FiatValue
    
    /// The currency type
    public let cryptoCurrency: CryptoCurrency
    
    public let paymentMethodId: String?
    
    public init(paymentMethod: PaymentMethodType,
                fiatValue: FiatValue,
                cryptoCurrency: CryptoCurrency,
                paymentMethodId: String?) {
        self.paymentMethod = paymentMethod
        self.fiatValue = fiatValue
        self.cryptoCurrency = cryptoCurrency
        self.paymentMethodId = paymentMethodId
    }
}

public struct CheckoutData {
        
    public let order: OrderDetails
    public let paymentAccount: PaymentAccount!
    
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
        
    public var cryptoCurrency: CryptoCurrency {
        order.cryptoValue.currencyType
    }
    
    /// `true` if the order is card but is undetermined
    public var isUnknownCardType: Bool {
        order.paymentMethod.isCard && order.paymentMethodId == nil
    }
                
    public init(order: OrderDetails, paymentAccount: PaymentAccount? = nil) {
        self.order = order
        self.paymentAccount = paymentAccount
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
