// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public struct StellarAssetAccount: SingleAddressAssetAccount {

    public typealias Address = StellarAssetAddress

    public let address: StellarAssetAddress
    public let accountAddress: String
    public let name: String
    public let description: String
    public let sequence: Int
    public let subentryCount: Int
    public let walletIndex: Int

    public init(accountAddress: String,
                name: String,
                description: String,
                sequence: Int,
                subentryCount: Int) {
        self.walletIndex = 0
        self.accountAddress = accountAddress
        self.name = name
        self.description = description
        self.sequence = sequence
        self.subentryCount = subentryCount
        self.address = StellarAssetAddress(publicKey: accountAddress)
    }
}
