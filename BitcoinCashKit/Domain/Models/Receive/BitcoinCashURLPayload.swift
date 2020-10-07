//
//  BitcoinCashURLPayload.swift
//  BitcoinCashKit
//
//  Created by Jack Pooley on 05/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

@objc public class BitcoinCashURLPayload: NSObject, BIP21URI {
    
    public static var scheme: String {
        AssetConstants.URLSchemes.bitcoinCash
    }
    
    @objc public var schemeCompat: String {
        BitcoinCashURLPayload.scheme
    }
    
    @objc public var absoluteString: String {
        let prefix = includeScheme ? "\(BitcoinCashURLPayload.scheme):" : ""
        let uri = "\(prefix)\(address)"
        if let amount = amount {
            return "\(uri)?amount=\(amount)"
        }
        return uri
    }
    
    @objc public var address: String
    
    @objc public var amount: String?
    
    @objc public var paymentRequestUrl: String?
    
    @objc public var includeScheme: Bool = false
    
    @objc public required init(address: String, amount: String?, paymentRequestUrl: String?) {
        self.address = address
        self.amount = amount
        self.paymentRequestUrl = paymentRequestUrl
    }
    
    @objc public required init(address: String, amount: String?, includeScheme: Bool = false) {
        self.address = address
        self.amount = amount
        self.includeScheme = includeScheme
    }
}
