//
//  BalanceDetailsResponse.swift
//  EthereumKit
//
//  Created by Jack on 19/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
import PlatformKit

public struct BalanceDetailsResponse: Decodable {
    let balance: String
    let nonce: UInt64

    var cryptoValue: CryptoValue {
        CryptoValue.create(minor: BigInt(balance) ?? BigInt(0), currency: .ethereum)
    }
}
