// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift
import ToolKit

public protocol CryptoAccount: SingleAccount {
    var asset: CryptoCurrency { get }
    var feeAsset: CryptoCurrency? { get }
}

extension CryptoAccount {
    public var feeAsset: CryptoCurrency? { nil }

    public var currencyType: CurrencyType {
        asset.currency
    }
}
