//
//  OrderPayload.swift
//  PlatformKit
//
//  Created by Daniel Huri on 05/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public struct Order {
    public enum Action: String, Codable {
        case buy = "BUY"
        case sell = "SELL"
    }
}

struct OrderPayload {

    public enum CreateActionType: String, Encodable {
        case confirm
        case pending
    }
    
    public struct ConfirmOrder: Encodable {
        
        public enum Partner {
            case everyPay(customerUrl: String)
            case bank
        }
        
        struct Attributes: Encodable {
            struct EveryPay: Encodable {
                let customerUrl: String
            }
            let everypay: EveryPay?
        }
                
        let action: CreateActionType
        let attributes: Attributes?
        
        init(partner: Partner, action: CreateActionType) {
            switch partner {
            case .everyPay(customerUrl: let url):
                attributes = Attributes(everypay: .init(customerUrl: url))
            case .bank:
                attributes = nil
            }
            self.action = action
        }
    }
    
    public struct Request: Encodable {
        struct Input: Encodable {
            let symbol: String
            let amount: String
        }
        
        struct Output: Encodable {
            let symbol: String
        }
        
        let pair: String
        let action: Order.Action
        let input: Input
        let output: Output
        let paymentMethodId: String?
        
        init(action: Order.Action,
             fiatValue: FiatValue,
             for cryptoCurrency: CryptoCurrency,
             paymentMethodId: String? = nil) {
            self.action = action
            self.paymentMethodId = paymentMethodId
            input = .init(
                symbol: fiatValue.currencyCode,
                amount: fiatValue.string
            )
            output = .init(symbol: cryptoCurrency.code)
            pair = "\(output.symbol)-\(input.symbol)"
        }
    }
    
    public struct Response: Decodable {
        struct Attributes: Decodable {
            struct EveryPay: Decodable {
                enum PaymentState: String, Decodable {
                    case waitingFor3DS = "WAITING_FOR_3DS_RESPONSE"
                    case confirmed3DS = "CONFIRMED_3DS"
                }
                
                let paymentLink: String
                let paymentState: PaymentState
            }
            
            let paymentId: String
            let everypay: EveryPay?
        }
        
        let state: String
        
        let id: String
        
        let inputCurrency: String
        let inputQuantity: String
        
        let outputCurrency: String
        let outputQuantity: String
        
        let updatedAt: String
        let expiresAt: String
        
        let price: String?
        let fee: String?
        let paymentMethodId: String?
        let attributes: Attributes?
    }
}

extension OrderPayload.Response.Attributes.EveryPay {
    
    private enum CodingKeys: String, CodingKey {
        case paymentLink
        case paymentState
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        paymentLink = try container.decode(String.self, forKey: .paymentLink)
        let paymentState = try container.decode(String.self, forKey: .paymentState)
        self.paymentState = PaymentState(rawValue: paymentState) ?? .confirmed3DS
    }
}
