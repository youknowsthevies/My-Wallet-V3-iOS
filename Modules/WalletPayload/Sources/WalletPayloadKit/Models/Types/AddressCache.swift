// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MetadataKit

public class AddressCache: Equatable {
    var receiveAccount: String
    var changeAccount: String

    public init(
        receiveAccount: String,
        changeAccount: String
    ) {
        self.receiveAccount = receiveAccount
        self.changeAccount = changeAccount
    }
}

extension AddressCache {
    public static func == (lhs: AddressCache, rhs: AddressCache) -> Bool {
        lhs.receiveAccount == rhs.receiveAccount
            && lhs.changeAccount == rhs.changeAccount
    }
}

/// Creates AdressCache from the given node
/// - Parameter node: A `PrivateKey` to derive the accounts
/// - Returns: An `AddressCache`
func createAddressCache(from node: PrivateKey) -> AddressCache {
    AddressCache(
        receiveAccount: node.derive(at: .hardened(0)).xpub,
        changeAccount: node.derive(at: .hardened(1)).xpub
    )
}
