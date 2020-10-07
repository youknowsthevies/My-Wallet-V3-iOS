//
//  BitcoinCashQRMetadata.swift
//  BitcoinCashKit
//
//  Created by Jack Pooley on 05/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public struct BitcoinCashQRMetadata: CryptoAssetQRMetadata {
    
    public var address: String
    
    public var amount: String?
    
    public var paymentRequestUrl: String?
    
    public var absoluteString: String {
        let payload = BitcoinCashURLPayload(
            address: address,
            amount: amount,
            includeScheme: includeScheme
        )
        return payload.absoluteString
    }
    
    public var includeScheme: Bool = false
    
    public static var scheme: String {
        AssetConstants.URLSchemes.bitcoinCash
    }
    
    public init(address: String, includeScheme: Bool = false) {
        self.address = address
        self.includeScheme = includeScheme
    }
    
    public init(address: String, amount: String?, includeScheme: Bool = false) {
        self.address = address
        self.amount = amount
        self.includeScheme = includeScheme
    }
}
