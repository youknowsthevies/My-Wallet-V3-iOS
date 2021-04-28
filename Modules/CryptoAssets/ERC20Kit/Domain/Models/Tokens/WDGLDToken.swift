//
//  WDGLDToken.swift
//  ERC20Kit
//
//  Created by Dimitrios Chatzieleftheriou on 18/11/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
import EthereumKit
import PlatformKit

public struct WDGLDToken: ERC20Token {
    public static let nonCustodialTransactionSupport: AvailableActions = [.swap]
    public static let legacySendSupport: Bool = false
    public static let assetType: CryptoCurrency = .wDGLD
    public static let contractAddress: EthereumContractAddress = "0x123151402076fc819b7564510989e475c9cd93ca"

    // swiftlint:disable:next force_try
    public static let smallestSpendableValue: ERC20TokenValue<Self> = try! ERC20TokenValue<Self>(
        crypto: CryptoValue.create(minor: 1, currency: assetType)
    )
}
