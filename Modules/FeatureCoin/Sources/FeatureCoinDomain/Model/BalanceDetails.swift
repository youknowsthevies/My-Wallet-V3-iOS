// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MoneyKit

public struct BalanceDetails: Equatable {
    public var positiveBalance: Bool
    public var cryptoBalance: MoneyValue
    public var fiatBalance: MoneyValue
}
