// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift
import ToolKit

public protocol CryptoAccount: SingleAccount {
    var asset: CryptoCurrency { get }
    var feeAsset: CryptoCurrency? { get }

    var requireSecondPassword: Single<Bool> { get }
}

public extension CryptoAccount {
    var feeAsset: CryptoCurrency? { nil }

    var currencyType: CurrencyType {
        asset.currency
    }
}
