// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import WalletPayloadKit

struct DerivationResponse: Equatable, Codable {
    enum Format: String, Codable {
        case legacy
        case segwit = "bech32"

        var purpose: Int {
            switch self {
            case .legacy:
                return 44
            case .segwit:
                return 84
            }
        }

        static func create(from model: DerivationResponse.Format) -> DerivationType {
            switch model {
            case .legacy:
                return .legacy
            case .segwit:
                return .segwit
            }
        }
    }

    let type: Format
    let purpose: Int
    let xpriv: String
    let xpub: String
    let addressLabels: [AddressLabelResponse]
    let cache: AddressCacheResponse

    enum CodingKeys: String, CodingKey {
        case type
        case purpose
        case xpriv
        case xpub
        case addressLabels = "address_labels"
        case cache
    }
}

extension WalletPayloadKit.Derivation {
    convenience init(from model: DerivationResponse) {
        self.init(
            type: DerivationResponse.Format.create(from: model.type),
            purpose: model.purpose,
            xpriv: model.xpriv,
            xpub: model.xpub,
            addressLabels: transform(from: model.addressLabels),
            cache: transform(from: model.cache)
        )
    }
}

func transform(from model: [AddressLabelResponse]) -> [WalletPayloadKit.AddressLabel] {
    model.map { label in
        WalletPayloadKit.AddressLabel(
            index: label.index,
            label: label.label
        )
    }
}

func transform(from model: AddressCacheResponse) -> WalletPayloadKit.AddressCache {
    WalletPayloadKit.AddressCache(
        receiveAccount: model.receiveAccount,
        changeAccount: model.changeAccount
    )
}
