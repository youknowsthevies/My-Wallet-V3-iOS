// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import WalletPayloadKit

struct AddressCacheResponse: Equatable, Codable {
    let receiveAccount: String
    let changeAccount: String
}

extension WalletPayloadKit.AddressCache {
    convenience init(from model: AddressCacheResponse) {
        self.init(
            receiveAccount: model.receiveAccount,
            changeAccount: model.changeAccount
        )
    }

    var toAddressCacheResponse: AddressCacheResponse {
        AddressCacheResponse(
            receiveAccount: receiveAccount,
            changeAccount: changeAccount
        )
    }
}
