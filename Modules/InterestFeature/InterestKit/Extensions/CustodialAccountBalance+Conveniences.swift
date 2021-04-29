// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

extension CustodialAccountBalance {

    init?(currency: CryptoCurrency,
          response: SavingsAccountBalanceDetails) {
        guard let balance = response.balance else { return nil }
        self = .init(minorValue: balance, currencyType: .crypto(currency))
    }
}

