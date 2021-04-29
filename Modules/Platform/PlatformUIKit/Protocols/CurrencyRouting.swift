// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public protocol CurrencyRouting: class {
    func toSend(_ currency: CryptoCurrency)
    func toReceive(_ currency: CryptoCurrency)
}
