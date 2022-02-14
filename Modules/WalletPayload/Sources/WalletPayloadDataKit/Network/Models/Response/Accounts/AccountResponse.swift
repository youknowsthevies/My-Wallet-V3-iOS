// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import WalletPayloadKit

struct AccountResponse: Equatable, Codable {
    let label: String
    let archived: Bool
    let defaultDerivation: DerivationResponse.Format
    let derivations: [DerivationResponse]

    enum CodingKeys: String, CodingKey {
        case label
        case archived
        case defaultDerivation = "default_derivation"
        case derivations
    }
}

extension WalletPayloadKit.Account {
    static func from(model: AccountResponse, index: Int) -> Account {
        Account(
            index: index,
            label: model.label,
            archived: model.archived,
            defaultDerivation: DerivationResponse.Format.create(from: model.defaultDerivation),
            derivations: model.derivations.map(WalletPayloadKit.Derivation.from(model:))
        )
    }

    var toAccountResponse: AccountResponse {
        AccountResponse(
            label: label,
            archived: archived,
            defaultDerivation: DerivationResponse.Format.create(type: defaultDerivation),
            derivations: derivations.map(\.derivationResponse)
        )
    }
}
