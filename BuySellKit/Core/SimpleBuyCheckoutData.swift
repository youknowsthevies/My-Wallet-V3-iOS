//
//  SimpleBuyCheckoutData.swift
//  PlatformKit
//
//  Created by Daniel Huri on 05/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public struct SimpleBuyCheckoutData {
    
    // MARK: - Types
    
    public enum DetailType {
        
        /// The candidate order details
        public struct CandidateOrderDetails {
            
            /// The payment method
            public let paymentMethod: SimpleBuyPaymentMethodType
            
            /// Fiat value
            let fiatValue: FiatValue
            
            /// The currency type
            let cryptoCurrency: CryptoCurrency
        }
        
        /// An order detail or an already existing order
        case order(SimpleBuyOrderDetails)
        
        /// Suggested candidate for a buy order
        case candidate(CandidateOrderDetails)
        
        public var paymentMethod: SimpleBuyPaymentMethod.MethodType {
            switch self {
            case .candidate(let details):
                return details.paymentMethod.method
            case .order(let details):
                return details.paymentMethod
            }
        }
        
        public var order: SimpleBuyOrderDetails? {
            switch self {
            case .order(let details):
                return details
            case .candidate:
                return nil
            }
        }
        
        var paymentMethodId: String? {
            switch self {
            case .candidate(let details):
                return details.paymentMethod.methodId
            case .order(let details):
                return details.paymentMethodId
            }
        }
    }
    
    // MARK: - Properties

    public var hasCardCheckoutMade: Bool {
        switch detailType {
        case .candidate:
            return false
        case .order(let details):
            return details.is3DSConfirmedCardOrder || details.isPending3DSCardOrder
        }
    }

    public var isPendingDepositBankWire: Bool {
        switch detailType {
        case .candidate:
            return false
        case .order(let details):
            return details.isPendingDepositBankWire
        }
    }
    
    public var isPending3DS: Bool {
        switch detailType {
        case .candidate:
            return false
        case .order(let details):
            return details.isPending3DSCardOrder
        }
    }
    
    public var fiatValue: FiatValue {
        switch detailType {
        case .candidate(let details):
            return details.fiatValue
        case .order(let details):
            return details.fiatValue
        }
    }
    
    public var cryptoCurrency: CryptoCurrency {
        switch detailType {
        case .candidate(let details):
            return details.cryptoCurrency
        case .order(let details):
            return details.cryptoValue.currencyType
        }
    }
    
    /// Computes to `true` if the payment method is a suggested card
    public var isSuggestedCard: Bool {
        switch detailType {
        case .candidate(let details):
            switch details.paymentMethod {
            case .suggested(let method):
                return method.type.isCard
            default:
                return false
            }
        default:
            return false
        }
    }
    
    public let paymentAccount: SimpleBuyPaymentAccount!
    public let detailType: DetailType
    
    public init(fiatValue: FiatValue,
                cryptoCurrency: CryptoCurrency,
                paymentMethod: SimpleBuyPaymentMethodType) {
        let candidateDetails = DetailType.CandidateOrderDetails(
            paymentMethod: paymentMethod,
            fiatValue: fiatValue,
            cryptoCurrency: cryptoCurrency
        )
        detailType = .candidate(candidateDetails)
        paymentAccount = nil
    }
    
    public init(orderDetails: SimpleBuyOrderDetails, paymentAccount: SimpleBuyPaymentAccount? = nil) {
        self.detailType = .order(orderDetails)
        self.paymentAccount = paymentAccount
    }
    
    private init(detailType: DetailType, paymentAccount: SimpleBuyPaymentAccount) {
        self.detailType = detailType
        self.paymentAccount = paymentAccount
    }
    
    public func checkoutData(byAppending cardData: CardData) -> SimpleBuyCheckoutData {
        switch detailType {
        case .candidate(let candidate):
            return SimpleBuyCheckoutData(
                fiatValue: candidate.fiatValue,
                cryptoCurrency: candidate.cryptoCurrency,
                paymentMethod: .card(cardData)
            )
        case .order:
            fatalError("\(#function) should not be used with prepared order, only with candidate data")
        }
    }
    
    func checkoutData(byAppending paymentAccount: SimpleBuyPaymentAccount) -> SimpleBuyCheckoutData {
        SimpleBuyCheckoutData(
            detailType: detailType,
            paymentAccount: paymentAccount
        )
    }
    
    func checkoutData(byAppending orderDetails: SimpleBuyOrderDetails) -> SimpleBuyCheckoutData {
        SimpleBuyCheckoutData(
            orderDetails: orderDetails,
            paymentAccount: paymentAccount
        )
    }
}
