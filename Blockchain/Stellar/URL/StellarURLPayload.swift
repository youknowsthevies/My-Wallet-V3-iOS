//
//  StellarURLPayload.swift
//  Blockchain
//
//  Created by kevinwu on 10/24/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import stellarsdk

/// Encapsulates the payload of a "web+stellar:" URL payload
class StellarURLPayload: SEP7URI {

    static var scheme: String {
        Constants.Schemes.stellar
    }

    static var payOperation: String {
        "\(PayOperation)"
    }

    var schemeCompat: String {
        StellarURLPayload.scheme
    }

    var absoluteString: String {
        let uriScheme = URIScheme()
        var amountInDecimal: Decimal?
        if let amount = amount {
            amountInDecimal = Decimal(string: amount)
        }
        return uriScheme.getPayOperationURI(accountID: address, amount: amountInDecimal)
    }

    var address: String

    var amount: String?
    
    var paymentRequestUrl: String?

    required init(address: String, amount: String? = nil) {
        self.address = address
        self.amount = amount
    }
}
