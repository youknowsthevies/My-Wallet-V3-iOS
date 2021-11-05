// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

// Helper wrapper for Account model variations
enum AccountWrapper {
    struct Version3: Equatable, Codable {
        let label: String
        let archived: Bool
        let xpriv: String
        let xpub: String
        let addressLabels: [AddressLabel]
        let cache: AddressCache

        enum CodingKeys: String, CodingKey {
            case label
            case archived
            case xpriv
            case xpub
            case addressLabels = "address_labels"
            case cache
        }
    }

    struct Version4: Equatable, Codable {
        let label: String
        let archived: Bool
        let defaultDerivation: String
        let derivations: [Derivation]

        enum CodingKeys: String, CodingKey {
            case label
            case archived
            case defaultDerivation = "default_derivation"
            case derivations
        }
    }
}
