//
//  StellarAssetAccountDetails.swift
//  StellarKit
//
//  Created by AlexM on 11/29/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import stellarsdk

public struct StellarAssetAccountDetails: AssetAccountDetails {
    public typealias Account = StellarAssetAccount
    
    public var account: StellarAssetAccount
    public var balance: CryptoValue
}

// MARK: Extension

public extension StellarAssetAccountDetails {
    static func unfunded(accountID: String) -> StellarAssetAccountDetails {
        let account = StellarAssetAccount(
            accountAddress: accountID,
            name: CryptoCurrency.stellar.defaultWalletName,
            description: CryptoCurrency.stellar.defaultWalletName,
            sequence: 0,
            subentryCount: 0
        )
        
        return StellarAssetAccountDetails(
            account: account,
            balance: CryptoValue.stellar(major: 0)
        )
    }
}
