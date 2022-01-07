// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import WalletPayloadKit

struct AddressLabelResponse: Equatable, Codable {
    let index: Int
    let label: String
}

extension WalletPayloadKit.AddressLabel {
    convenience init(from model: AddressLabelResponse) {
        self.init(
            index: model.index,
            label: model.label
        )
    }
}
