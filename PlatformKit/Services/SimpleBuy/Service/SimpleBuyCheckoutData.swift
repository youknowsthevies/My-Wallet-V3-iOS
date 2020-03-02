//
//  SimpleBuyCheckoutData.swift
//  PlatformKit
//
//  Created by Daniel Huri on 05/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

/// TODO: Create a parent struct from the transfer/checkout details screen (use composition for `paymentAccount`).
public struct SimpleBuyCheckoutData {
    
    // MARK: - Types
    
    public enum DetailType {
        
        /// An order detail or an already existing order
        case order(SimpleBuyOrderDetails)
        
        /// Suggested candidate for a buy order
        case candidate(fiatValue: FiatValue, cryptoCurrency: CryptoCurrency)
    }
    
    // MARK: - Properties
    
    public var fiatValue: FiatValue {
        switch detailType {
        case .candidate(fiatValue: let fiatValue, cryptoCurrency: _):
            return fiatValue
        case .order(let order):
            return order.fiatValue
        }
    }
    
    public var cryptoCurrency: CryptoCurrency {
        switch detailType {
        case .candidate(fiatValue: _, cryptoCurrency: let cryptoCurrency):
            return cryptoCurrency
        case .order(let order):
            return order.cryptoCurrency
        }
    }
    
    public let paymentAccount: SimpleBuyPaymentAccount!
    public let detailType: DetailType
    
    public init(fiatValue: FiatValue,
                cryptoCurrency: CryptoCurrency) {
        detailType = .candidate(fiatValue: fiatValue, cryptoCurrency: cryptoCurrency)
        paymentAccount = nil
    }
    
    public init(orderDetails: SimpleBuyOrderDetails) {
        self.detailType = .order(orderDetails)
        paymentAccount = nil
    }
    
    private init(detailType: DetailType, paymentAccount: SimpleBuyPaymentAccount) {
        self.detailType = detailType
        self.paymentAccount = paymentAccount
    }
    
    public func checkoutData(byAppending paymentAccount: SimpleBuyPaymentAccount) -> SimpleBuyCheckoutData {
        return SimpleBuyCheckoutData(
            detailType: detailType,
            paymentAccount: paymentAccount
        )
    }
}
