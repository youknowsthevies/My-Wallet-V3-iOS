// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol MoneyValueFormatterAPI {
    func formatMoney(amount: String, currency: String) -> String
}
