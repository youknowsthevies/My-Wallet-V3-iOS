//
//  BitcoinCashAssetAddress.swift
//  BitcoinCashKit
//
//  Created by Jack Pooley on 05/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public struct BitcoinCashAssetAddress: AssetAddress, Importable, Hashable {
    
    public let isImported: Bool
    public let publicKey: String
    public let cryptoCurrency: CryptoCurrency = .bitcoinCash
    
    public init(isImported: Bool = false, publicKey: String) {
        self.isImported = isImported
        self.publicKey = publicKey
    }
}
