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

extension DerivationResponse.Format {
    static func create(from model: DerivationResponse.Format) -> DerivationType {
        switch model {
        case .legacy:
            return .legacy
        case .segwit:
            return .segwit
        }
    }

    static func create(type: DerivationType) -> DerivationResponse.Format {
        switch type {
        case .legacy:
            return .legacy
        case .segwit:
            return .segwit
        }
    }
}

// MARK: - Derivation Creation

extension WalletPayloadKit.Derivation {
    static func from(model: DerivationResponse) -> Derivation {
        Derivation(
            type: DerivationResponse.Format.create(from: model.type),
            purpose: model.purpose,
            xpriv: model.xpriv,
            xpub: model.xpub,
            addressLabels: transform(from: model.addressLabels),
            cache: transform(from: model.cache)
        )
    }

    var derivationResponse: DerivationResponse {
        DerivationResponse(
            type: DerivationResponse.Format.create(type: type),
            purpose: DerivationResponse.Format.create(type: type).purpose,
            xpriv: xpriv,
            xpub: xpub,
            addressLabels: addressLabels.map(\.toAddressLabelResponse),
            cache: cache.toAddressCacheResponse
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
