// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import stellarsdk

public struct StellarAccountDetails {
    public let account: StellarAssetAccount
    public let balance: CryptoValue
    public let actionableBalance: CryptoValue
}

// MARK: Extension

public extension StellarAccountDetails {
    static func unfunded(accountID: String) -> StellarAccountDetails {
        let account = StellarAssetAccount(
            accountAddress: accountID,
            name: CryptoCurrency.stellar.defaultWalletName,
            description: CryptoCurrency.stellar.defaultWalletName,
            sequence: 0,
            subentryCount: 0
        )

        return StellarAccountDetails(
            account: account,
            balance: .stellarZero,
            actionableBalance: .stellarZero
        )
    }
}
