// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

@available(*, deprecated, message: "We need to shift to using models returned by Coincore.")
public protocol FiatAccountBalanceType: SingleAccountBalanceType {
    var fiatCurrency: FiatCurrency { get }
    var fiatValue: FiatValue { get }
}
