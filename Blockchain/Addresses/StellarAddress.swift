//
//  StellarAddress.swift
//  Blockchain
//
//  Created by kevinwu on 10/15/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

// TODO: convert class to struct once there are no more objc dependents

@objc
class StellarAddress: NSObject & AssetAddress {

    // MARK: - Properties

    private(set) var address: String

    let assetType = LegacyCryptoCurrency.stellar

    override public var description: String {
        return address
    }

    // MARK: - Initialization

    required init(string: String) {
        self.address = string
    }
}
