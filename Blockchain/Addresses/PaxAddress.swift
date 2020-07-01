//
//  PaxAddress.swift
//  Blockchain
//
//  Created by Jack on 11/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

@objc
class PaxAddress: NSObject & AssetAddress {
    
    // MARK: - Properties
    
    private(set) var address: String
    
    let assetType = LegacyCryptoCurrency.pax
    
    override var description: String {
        address
    }
    
    // MARK: - Initialization
    
    required init(string: String) {
        self.address = string
    }
}
