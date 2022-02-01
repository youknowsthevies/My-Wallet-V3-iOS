// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import WalletPayloadKit

struct AddressLabelResponse: Equatable, Codable {
    let index: Int
    let label: String
}

extension WalletPayloadKit.AddressLabel {
    static func from(model: AddressLabelResponse) -> AddressLabel {
        AddressLabel(
            index: model.index,
            label: model.label
        )
    }

    var toAddressLabelResponse: AddressLabelResponse {
        AddressLabelResponse(
            index: index,
            label: label
        )
    }
}
