//
//  StellarURLPayload.swift
//  StellarKit
//
//  Created by Alex McGregor on 12/7/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import stellarsdk

public struct StellarURLPayload: SEP7URI {

    public static var scheme: String {
        AssetConstants.URLSchemes.stellar
    }

    public let cryptoCurrency: CryptoCurrency = .stellar
    public let address: String
    public let amount: String?
    public let paymentRequestUrl: String? = nil
    public let includeScheme: Bool = true

    public var absoluteString: String {
        let uriScheme = URIScheme()
        var amountInDecimal: Decimal?
        if let amount = amount {
            amountInDecimal = Decimal(string: amount)
        }
        return uriScheme.getPayOperationURI(accountID: address, amount: amountInDecimal)
    }

    public init(address: String, amount: String?) {
        self.address = address
        self.amount = amount
    }

    public init?(url: URL) {
        guard StellarURLPayload.scheme == url.scheme else { return nil }

        var destination: String? = url.absoluteString
        var paymentAmount: String?
        let urlString = url.absoluteString

        if let argsString = urlString.components(separatedBy: "\(StellarURLPayload.scheme):\(PayOperation)").last {
            let queryArgs = argsString.queryArgs
            destination = queryArgs["\(PayOperationParams.destination)"]
            paymentAmount = queryArgs["\(PayOperationParams.amount)"]
        }

        guard let address = destination else { return nil }
        self.init(address: address, amount: paymentAmount)
    }
}
