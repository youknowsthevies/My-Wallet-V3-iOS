//
//  BitcoinCashURLPayload.swift
//  BitcoinCashKit
//
//  Created by Jack on 05/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

/// Encapsulates the payload of a "bitcoincash:" URL payload
public class BitcoinCashURLPayload: BIP21URI {

    public static var scheme: String {
        AssetConstants.URLSchemes.bitcoinCash
    }

    public var absoluteString: String {
        let prefix = includeScheme ? "\(Self.scheme):" : ""
        let uri = "\(prefix)\(address)"
        if let amount = amount {
            return "\(uri)?amount=\(amount)"
        }
        return uri
    }

    public let address: String

    public let amount: String?

    public let cryptoCurrency: CryptoCurrency = .bitcoinCash

    public let paymentRequestUrl: String?

    public let includeScheme: Bool

    public required init(address: String, amount: String?, paymentRequestUrl: String?) {
        self.address = address
        self.amount = amount
        self.paymentRequestUrl = paymentRequestUrl
        includeScheme = false
    }

    public required init(address: String, amount: String?, includeScheme: Bool = false) {
        self.address = address
        self.amount = amount
        paymentRequestUrl = nil
        self.includeScheme = includeScheme
    }
}
