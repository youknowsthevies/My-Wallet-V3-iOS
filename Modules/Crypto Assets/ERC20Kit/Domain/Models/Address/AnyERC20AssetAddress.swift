//
//  AnyERC20AssetAddress.swift
//  ERC20Kit
//
//  Created by Alex McGregor on 6/11/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public final class AnyERC20AssetAddress<Token: ERC20Token>: AssetAddress {
    public let publicKey: String
    public let cryptoCurrency = Token.assetType
    public init(publicKey: String) {
        self.publicKey = publicKey
    }
}
