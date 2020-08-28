//
//  CryptoAccount.swift
//  PlatformKit
//
//  Created by Paulo on 30/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit

public protocol CryptoAccount: SingleAccount {
    var asset: CryptoCurrency { get }
    var feeAsset: CryptoCurrency? { get }
}

public extension CryptoAccount {
    var feeAsset: CryptoCurrency? { nil }

    var currencyType: CurrencyType {
        asset.currency
    }
}
