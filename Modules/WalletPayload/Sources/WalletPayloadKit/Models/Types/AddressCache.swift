// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

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
