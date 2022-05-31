// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformKit
import stellarsdk

public struct StellarAccountDetails: Equatable {
    public let account: StellarAssetAccount
    public let balance: CryptoValue
    public let actionableBalance: CryptoValue
}

extension StellarAccountDetails {
    public static func unfunded(accountID: String) -> StellarAccountDetails {
        let account = StellarAssetAccount(
            accountAddress: accountID,
            name: CryptoCurrency.stellar.defaultWalletName,
            description: CryptoCurrency.stellar.defaultWalletName,
            sequence: 0,
            subentryCount: 0
        )

        return StellarAccountDetails(
            account: account,
            balance: .zero(currency: .stellar),
            actionableBalance: .zero(currency: .stellar)
        )
    }
}
