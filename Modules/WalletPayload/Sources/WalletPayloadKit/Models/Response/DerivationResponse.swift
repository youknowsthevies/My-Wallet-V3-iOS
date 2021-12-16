// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension WalletResponseModels {
    struct Derivation: Equatable, Codable {
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
        let addressLabels: [AddressLabel]
        let cache: AddressCache

        enum CodingKeys: String, CodingKey {
            case type
            case purpose
            case xpriv
            case xpub
            case addressLabels = "address_labels"
            case cache
        }
    }
}
