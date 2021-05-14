// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Foundation

extension AnalyticsEvents {
    public enum New {
        
        public enum SimpleBuy: AnalyticsEvent {
            
            public var type: AnalyticsEventType {
                .new
            }
            
            case buyAmountEntered(inputAmount: Double, inputCurrency: String, outputAmount: Double, outputCurrency: String)
            case buyPaymentMethodSelected(paymentType: PaymentType)
            case buySellViewed(type: BuySellType)
            
            public var name: String {
                switch self {
                case .buyAmountEntered:
                    return "Buy Amount Entered"
                case .buyPaymentMethodSelected:
                    return "Buy Payment Method Selected"
                case .buySellViewed:
                    return "Buy Sell Viewed"
                }
            }
            
            public var params: [String : Any]? {
                switch self {
                case let .buyAmountEntered(inputAmount, inputCurrency, outputAmount, outputCurrency):
                    return [
                        "input_amount": inputAmount,
                        "input_currency": inputCurrency,
                        "output_amount": outputAmount,
                        "output_currency": outputCurrency,
                        "platform": "WALLET"
                    ]
                case let .buyPaymentMethodSelected(paymentType):
                    return [
                        "payment_type": "\(paymentType.rawValue)",
                        "platform": "WALLET"
                    ]
                case let .buySellViewed(type):
                    return [
                        "type": type.rawValue
                    ]
                }
            }
        }
        
        public enum PaymentType: String {
            case bankAccount = "BANK_ACCOUNT"
            case bankTransfer = "BANK_TRANSFER"
            case funds = "FUNDS"
            case paymentCard = "PAYMENT_CARD"
            
            public init(paymentMethod: PaymentMethod) {
                switch paymentMethod.type {
                case .card:
                    self = .paymentCard
                case .bankAccount:
                    self = .bankAccount
                case .bankTransfer:
                    self = .bankTransfer
                case .funds:
                    self = .funds
                }
            }
        }
        
        public enum BuySellType: String {
            case buy = "BUY"
            case sell = "SELL"
        }
    }
}
