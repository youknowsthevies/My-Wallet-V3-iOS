// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum DerivationType: String {
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

    static func create(from model: WalletResponseModels.Derivation.Format) -> DerivationType {
        switch model {
        case .legacy:
            return .legacy
        case .segwit:
            return .segwit
        }
    }
}

struct Derivation: Equatable {
    let type: DerivationType
    let purpose: Int
    let xpriv: String
    let xpub: String
    let addressLabels: [AddressLabel]
    let cache: AddressCache

    init(from model: WalletResponseModels.Derivation) {
        type = DerivationType.create(from: model.type)
        purpose = model.purpose
        xpriv = model.xpriv
        xpub = model.xpub
        addressLabels = model.addressLabels
        cache = model.cache
    }
}
